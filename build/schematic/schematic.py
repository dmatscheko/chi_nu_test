#!/usr/bin/env python3
"""
schematic.py — render a path-based .sch netlist as an electronic-schematic SVG.

The language is documented in LANGUAGE.md next to this file. In short: wires
are written as paths (`LEDC.p -> [res Rb "1k"] -> OUT`), parts sit inline on
the paths, named nodes form junctions, and placement/routing is automatic
unless pinned down with `at`, exact moves (`down 28`) or waypoints. Every
endpoint is a named pin, so a path that does not connect fails the build.

    python3 schematic.py board.sch                # -> board.svg
    python3 schematic.py *.sch                    # any number at once
    python3 schematic.py board.sch -o out.svg     # explicit name (one input)
    python3 schematic.py *.sch -o ../             # -o DIR: write them all there
    python3 schematic.py *.sch --color-nets       # debug: colour per net
    python3 schematic.py *.sch --nets             # print electrical netlists
    python3 schematic.py --cleanup *.sch          # rewrite the .sch files:
                                                  # drop every position/length
                                                  # param whose removal keeps
                                                  # ALL the SVGs byte-identical

Zero dependencies (Python 3.8+).
"""

import sys, os, math, re, heapq

EPS = 0.5
DIRS = {"up": (0, -1), "down": (0, 1), "left": (-1, 0), "right": (1, 0)}
DIR_ROT = {(1, 0): 0, (0, 1): 90, (-1, 0): 180, (0, -1): 270}  # a->b axis


class SchError(Exception):
    pass


class Unresolved(SchError):
    """a reference that cannot resolve YET (part not defined so far, position
    not known so far). The statement is rolled back and retried once the rest
    of the file has been read — definition and placement order are free."""


# ============================================================== small helpers
def N(v):
    """compact number for SVG output"""
    if abs(v - round(v)) < 1e-6:
        return str(int(round(v)))
    return f"{v:.2f}".rstrip("0").rstrip(".")


def esc(s):
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def close(a, b):
    return abs(a[0] - b[0]) < EPS and abs(a[1] - b[1]) < EPS


def rot_pt(x, y, deg):
    """rotate clockwise (SVG y-down)"""
    t = math.radians(deg)
    c, s = math.cos(t), math.sin(t)
    return (x * c - y * s, x * s + y * c)


def unit(frm, to):
    dx, dy = to[0] - frm[0], to[1] - frm[1]
    L = math.hypot(dx, dy)
    return None if L < EPS else (round(dx / L, 3), round(dy / L, 3))


def wrap_text(text, maxchars):
    words, lines, cur = text.split(), [], ""
    for w in words:
        if cur and len(cur) + 1 + len(w) > maxchars:
            lines.append(cur)
            cur = w
        else:
            cur = f"{cur} {w}" if cur else w
    return lines + [cur] if cur else lines or [""]


# ================================================================== symbols
class Part:
    """A symbol at (cx,cy), rotated `rot` deg clockwise, optionally mirrored
    in X (mirror applies before rotation). Subclasses define local geometry:
    local_pins() -> {name:(x,y)}, ESC -> {name:(dx,dy)} outward pin normals,
    BODY -> (x0,y0,x1,y1) obstacle box (body only, leads excluded), body()
    -> local-coordinate SVG."""
    STYLE = "us"         # symbol style: "us" (ANSI) | "iec"; set by `sheet`
    ESC = {}
    BODY = (-6, -6, 6, 6)
    PINSEQ = ()          # (entry, exit) pin names for inline path placement

    def __init__(self, ref, x=0.0, y=0.0, rot=0, mirror=False,
                 label="", value="", lpos=""):
        self.ref, self.cx, self.cy = ref, float(x), float(y)
        self.rot, self.mirror = rot % 360, mirror
        self.label, self.value, self.lpos = label, value, lpos

    # --- geometry ---
    def local_pins(self):
        return {}

    def body(self):
        return ""

    def to_world(self, x, y):
        if self.mirror:
            x = -x
        x, y = rot_pt(x, y, self.rot)
        return (x + self.cx, y + self.cy)

    def pins(self):
        return {k: self.to_world(*v) for k, v in self.local_pins().items()}

    def pin(self, name):
        lp = self.local_pins()
        if name not in lp:
            raise SchError(f"{self.ref}: no pin '{name}' "
                           f"(has: {', '.join(sorted(lp)) or 'none'})")
        return self.to_world(*lp[name])

    def pin_esc(self, name):
        d = self.ESC.get(name)
        if d is None:
            return None
        x, y = d
        if self.mirror:
            x = -x
        x, y = rot_pt(x, y, self.rot)
        return (round(x, 3), round(y, 3))

    def bbox(self):
        x0, y0, x1, y1 = self.BODY
        pts = [self.to_world(x, y) for (x, y) in
               ((x0, y0), (x1, y0), (x0, y1), (x1, y1))]
        xs, ys = [p[0] for p in pts], [p[1] for p in pts]
        return (min(xs), min(ys), max(xs), max(ys))

    def transform(self):
        t = [f"translate({N(self.cx)},{N(self.cy)})"]
        if self.rot:
            t.append(f"rotate({N(self.rot)})")
        if self.mirror:
            t.append("scale(-1,1)")
        return " ".join(t)

    # --- labels: reference above, value below; vertical parts label right;
    #     lpos=up/down/left/right overrides. LBL_UP/LBL_DN/H_LEFT/H_RIGHT are
    #     text clearances from the symbol centre in the symbol's LOCAL frame;
    #     they follow the part's mirror/rotation (_label_dists). Text is drawn
    #     in world space and never moves the body or its centre. ---
    LBL_UP, LBL_DN, H_LEFT, H_RIGHT = 20, 28, 24, 24
    LPOS_DEFAULT = ""

    def _label_dists(self):
        """local clearances mapped onto world directions (mirror, then rot)"""
        d = {"up": self.LBL_UP, "down": self.LBL_DN,
             "left": self.H_LEFT, "right": self.H_RIGHT}
        if self.mirror:
            d["left"], d["right"] = d["right"], d["left"]
        order = ("up", "right", "down", "left")     # clockwise, like rot
        k = round(self.rot / 90) % 4
        return {order[(i + k) % 4]: d[order[i]] for i in range(4)}

    def _label_items(self):
        """(x, y, cls, text, anchor) per label line; cls is 'lbl' or 'val'"""
        if not (self.label or self.value):
            return []
        pos = self.lpos or self.LPOS_DEFAULT or \
            ("right" if self.rot % 180 == 90 else "updown")
        D = self._label_dists()
        out = []
        if pos in ("left", "right"):
            sgn = 1 if pos == "right" else -1
            tx, anc = self.cx + sgn * D[pos], "start" if pos == "right" else "end"
            if self.label:
                out.append((tx, self.cy - 3, "lbl", self.label, anc))
            if self.value:
                out.append((tx, self.cy + 11, "val", self.value, anc))
        elif pos == "up":
            y = self.cy - D["up"]
            if self.label:
                out.append((self.cx, y - (14 if self.value else 0),
                            "lbl", self.label, "middle"))
            if self.value:
                out.append((self.cx, y, "val", self.value, "middle"))
        elif pos == "down":
            y = self.cy + D["down"]
            if self.label:
                out.append((self.cx, y, "lbl", self.label, "middle"))
            if self.value:
                out.append((self.cx, y + 14, "val", self.value, "middle"))
        else:
            if self.label:
                out.append((self.cx, self.cy - D["up"], "lbl", self.label, "middle"))
            if self.value:
                out.append((self.cx, self.cy + D["down"], "val", self.value, "middle"))
        return out

    def label_svg(self):
        return "\n".join(
            f'<text x="{N(x)}" y="{N(y)}" class="{cls}" '
            f'text-anchor="{anc}">{esc(txt)}</text>'
            for x, y, cls, txt, anc in self._label_items())

    def svg(self):
        return (f'<g transform="{self.transform()}">\n{self.body()}\n</g>\n'
                + self.label_svg())

    # approximate world boxes of the label texts (for sheet auto-size)
    def label_ext(self):
        return [_text_ext(x, y, txt, 12.5 if cls == "lbl" else 11, anc)
                for x, y, cls, txt, anc in self._label_items()]


def _text_ext(x, y, txt, size, anchor="start"):
    """rough Helvetica text box around baseline point (x,y)"""
    w = 0.6 * size * len(txt)
    x0 = x - w / 2 if anchor == "middle" else (x - w if anchor == "end" else x)
    return (x0, y - 0.78 * size, x0 + w, y + 0.25 * size)


class TwoTerm(Part):
    """pin a at (-SPAN/2,0), pin b at (+SPAN/2,0); SPAN is uniform so
    chains and hanging parts share one rhythm"""
    SPAN = 60
    PINSEQ = ("a", "b")
    ESC = {"a": (-1, 0), "b": (1, 0)}

    def local_pins(self):
        h = self.SPAN / 2
        return {"a": (-h, 0), "b": (h, 0)}


class Res(TwoTerm):
    BODY = (-21, -12, 21, 12)
    LBL_UP, LBL_DN, H_LEFT, H_RIGHT = 16, 22, 28, 28

    def body(self):
        h, zz, amp, n = self.SPAN / 2, 18, 9, 6
        if Part.STYLE == "iec":         # IEC 60617: plain rectangle
            return (f'<path d="M{N(-h)},0 L{N(-zz)},0 M{N(zz)},0 L{N(h)},0"'
                    f' class="dev"/>'
                    f'<rect x="{N(-zz)}" y="{N(-amp)}" width="{N(2 * zz)}"'
                    f' height="{N(2 * amp)}" class="dev" fill="#fff"/>')
        pts = [(-h, 0), (-zz, 0)]
        step = 2 * zz / n
        pts += [(-zz + step * (i + .5), -amp if i % 2 == 0 else amp) for i in range(n)]
        pts += [(zz, 0), (h, 0)]
        d = "M" + " L".join(f"{N(x)},{N(y)}" for x, y in pts)
        return f'<path d="{d}" class="dev"/>'


class Pot(Res):
    """resistor + wiper w entering from above"""
    BODY = (-21, -30, 21, 12)
    LBL_UP, H_LEFT, H_RIGHT = 36, 28, 28

    def local_pins(self):
        p = super().local_pins()
        p["w"] = (0, -30)
        return p

    ESC = {"a": (-1, 0), "b": (1, 0), "w": (0, -1)}

    def body(self):
        arrow = ('<path d="M0,-30 L0,-14" class="dev"/>'
                 '<polygon points="0,-10 -4,-17 4,-17" fill="#222"/>')
        return super().body() + arrow

class Cap(TwoTerm):
    BODY = (-7, -18, 7, 18)
    LBL_UP, H_LEFT, H_RIGHT = 22, 14, 14

    def body(self):
        h, g, pl = self.SPAN / 2, 5, 16
        return (f'<path d="M{N(-h)},0 L{N(-g)},0 M{N(h)},0 L{N(g)},0" class="dev"/>'
                f'<line x1="{N(-g)}" y1="{N(-pl)}" x2="{N(-g)}" y2="{N(pl)}" class="dev"/>'
                f'<line x1="{N(g)}" y1="{N(-pl)}" x2="{N(g)}" y2="{N(pl)}" class="dev"/>')


class CapPol(Cap):
    LBL_UP, H_LEFT, H_RIGHT = 32, 17, 17

    def local_pins(self):
        h = self.SPAN / 2
        return {"a": (-h, 0), "b": (h, 0), "+": (-h, 0), "-": (h, 0)}

    def body(self):
        h, g, pl = self.SPAN / 2, 5, 16
        return (f'<path d="M{N(-h)},0 L{N(-g)},0 M{N(h)},0 L{N(g + 4)},0" class="dev"/>'
                f'<line x1="{N(-g)}" y1="{N(-pl)}" x2="{N(-g)}" y2="{N(pl)}" class="dev"/>'
                f'<path d="M{N(g)},{N(-pl)} Q{N(g + 9)},0 {N(g)},{N(pl)}" class="dev"/>'
                f'<text x="{N(-g - 4)}" y="{N(-pl - 3)}" class="pol">+</text>')


class Inductor(TwoTerm):
    LBL_UP, LBL_DN, H_LEFT, H_RIGHT = 16, 21, 29, 29

    @property
    def BODY(self):
        return (-22, -8, 22, 8) if Part.STYLE == "iec" else (-26, -9, 26, 2)

    def body(self):
        h, r, bumps = self.SPAN / 2, 6, 4
        if Part.STYLE == "iec":         # IEC 60617: filled bar
            return (f'<path d="M{N(-h)},0 L-20,0 M20,0 L{N(h)},0" class="dev"/>'
                    '<rect x="-20" y="-6" width="40" height="12" fill="#1a1a1a"/>')
        x = -bumps * r
        d = [f"M{N(-h)},0 L{N(x)},0"]
        for _ in range(bumps):
            d.append(f"A{r},{r} 0 0 1 {N(x + 2 * r)},0")
            x += 2 * r
        d.append(f"L{N(h)},0")
        return f'<path d="{" ".join(d)}" class="dev"/>'


class Piezo(TwoTerm):
    """crystal-style symbol: body rectangle between two electrode plates"""
    BODY = (-15, -19, 15, 19)
    LBL_UP, LBL_DN = 25, 33

    def body(self):
        h, g, pl, bw, bh = self.SPAN / 2, 7, 18, 14, 13
        return (f'<path d="M{N(-h)},0 L{N(-g)},0 M{N(h)},0 L{N(g)},0" class="dev"/>'
                f'<line x1="{N(-g)}" y1="{N(-pl)}" x2="{N(-g)}" y2="{N(pl)}" class="dev"/>'
                f'<line x1="{N(g)}" y1="{N(-pl)}" x2="{N(g)}" y2="{N(pl)}" class="dev"/>'
                f'<rect x="{N(-bw)}" y="{N(-bh)}" width="{N(2 * bw)}" height="{N(2 * bh)}"'
                f' class="dev" fill="#fff"/>')


class Xtal(TwoTerm):
    BODY = (-11, -19, 11, 19)
    LBL_UP, LBL_DN, H_LEFT, H_RIGHT = 26, 34, 19, 19

    def body(self):
        h, g, pl = self.SPAN / 2, 10, 14
        return (f'<path d="M{N(-h)},0 L{N(-g)},0 M{N(h)},0 L{N(g)},0" class="dev"/>'
                f'<line x1="{N(-g)}" y1="{N(-pl)}" x2="{N(-g)}" y2="{N(pl)}" class="dev"/>'
                f'<line x1="{N(g)}" y1="{N(-pl)}" x2="{N(g)}" y2="{N(pl)}" class="dev"/>'
                f'<rect x="-6" y="-18" width="12" height="36" class="dev" fill="#fff"/>')


class Diode(TwoTerm):
    """a=anode (entry), k=cathode; arrow points a->k"""
    BODY = (-10, -16, 10, 16)
    H_LEFT, H_RIGHT = 16, 16
    PINSEQ = ("a", "k")

    def local_pins(self):
        h = self.SPAN / 2
        return {"a": (-h, 0), "k": (h, 0)}

    ESC = {"a": (-1, 0), "k": (1, 0)}

    def parts_svg(self):
        h, tw, th = self.SPAN / 2, 14, 12
        bar = th + 2
        return (h, tw, th, bar,
                f'<path d="M{N(-h)},0 L{N(-tw / 2)},0 M{N(h)},0 L{N(tw / 2)},0" class="dev"/>'
                f'<polygon points="{N(-tw / 2)},{N(-th)} {N(-tw / 2)},{N(th)} {N(tw / 2)},0"'
                f' class="dev" fill="#222"/>')

    def body(self):
        h, tw, th, bar, base = self.parts_svg()
        return base + (f'<line x1="{N(tw / 2)}" y1="{N(-bar)}" x2="{N(tw / 2)}"'
                       f' y2="{N(bar)}" class="dev"/>')


class Schottky(Diode):
    LBL_UP, H_LEFT, H_RIGHT = 22, 18, 18

    def body(self):
        h, tw, th, bar, base = self.parts_svg()
        x, s = tw / 2, 5
        return base + (f'<path d="M{N(x - s)},{N(-bar)} L{N(x - s)},{N(-bar + s)} '
                       f'M{N(x)},{N(-bar)} L{N(x)},{N(bar)} '
                       f'M{N(x + s)},{N(bar)} L{N(x + s)},{N(bar - s)}" class="dev"/>')


class Zener(Diode):
    LBL_UP, LBL_DN = 24, 29

    def body(self):
        h, tw, th, bar, base = self.parts_svg()
        x, s = tw / 2, 5
        return base + (f'<path d="M{N(x - s)},{N(-bar - s)} L{N(x)},{N(-bar)} '
                       f'L{N(x)},{N(bar)} L{N(x + s)},{N(bar + s)}" class="dev"/>')


class Led(Diode):
    BODY = (-10, -26, 16, 16)
    LBL_UP = 30

    def body(self):
        return super().body() + (
            '<path d="M5,-16 L13,-24 M10,-24 L13,-24 L13,-21" class="dev"/>'
            '<path d="M-3,-16 L5,-24 M2,-24 L5,-24 L5,-21" class="dev"/>')


class Bjt(Part):
    """base left; npn: collector up / emitter down; pnp: emitter up
    (totem-pole ready). Pins on the grid: B (-40,0), C/E (20,±40)."""
    BODY = (-19, -19, 21, 19)
    LBL_UP, LBL_DN, H_LEFT, H_RIGHT = 45, 55, 28, 29
    R, PX, PIN, NPN = 18, 20, 40, True

    def local_pins(self):
        top, bot = ("C", "E") if self.NPN else ("E", "C")
        return {"B": (-self.PIN, 0), top: (self.PX, -self.PIN),
                bot: (self.PX, self.PIN)}

    @property
    def ESC(self):
        top, bot = ("C", "E") if self.NPN else ("E", "C")
        return {"B": (-1, 0), top: (0, -1), bot: (0, 1)}

    def body(self):
        R, P, X = self.R, self.PIN, self.PX
        bx, cxi = -R * .40, R * .45
        bbar = R * .62
        s = [f'<circle cx="0" cy="0" r="{N(R)}" class="dev" fill="#fff"/>',
             f'<path d="M{N(-P)},0 L{N(bx)},0" class="dev"/>',
             f'<line x1="{N(bx)}" y1="{N(-bbar)}" x2="{N(bx)}" y2="{N(bbar)}" class="dev"/>',
             f'<path d="M{N(bx)},{N(-bbar * .45)} L{N(cxi)},{N(-R * .62)} '
             f'L{N(X)},{N(-R * .62)} L{N(X)},{N(-P)}" class="dev"/>',
             f'<path d="M{N(bx)},{N(bbar * .45)} L{N(cxi)},{N(R * .62)} '
             f'L{N(X)},{N(R * .62)} L{N(X)},{N(P)}" class="dev"/>']
        # emitter arrow: outward on the lower diagonal for npn, inward for pnp
        a, b = (bx, bbar * .45), (cxi, R * .62)
        if not self.NPN:
            a, b = b, a
        s.append(self._arrow(a, b, .78))
        return "\n".join(s)

    @staticmethod
    def _arrow(p0, p1, at=.8, size=7):
        ax, ay = p0[0] + (p1[0] - p0[0]) * at, p0[1] + (p1[1] - p0[1]) * at
        ang = math.atan2(p1[1] - p0[1], p1[0] - p0[0])
        q = [(ax + size * math.cos(ang + math.radians(150 * s)),
              ay + size * math.sin(ang + math.radians(150 * s))) for s in (1, -1)]
        return (f'<polygon points="{N(ax)},{N(ay)} {N(q[0][0])},{N(q[0][1])} '
                f'{N(q[1][0])},{N(q[1][1])}" fill="#222"/>')

    LPOS_DEFAULT = "left"               # base side is usually free


class Npn(Bjt):
    NPN = True


class Pnp(Bjt):
    NPN = False


class Mosfet(Part):
    """gate left; nmos: drain up / source down; pmos mirrored vertically.
    Pins match the BJT grid: G (-40,0), D/S (20,±40)."""
    BODY = (-12, -18, 22, 18)
    LBL_UP, LBL_DN, H_LEFT, H_RIGHT = 45, 55, 22, 29
    NMOS = True

    def local_pins(self):
        top, bot = ("D", "S") if self.NMOS else ("S", "D")
        return {"G": (-40, 0), top: (20, -40), bot: (20, 40)}

    @property
    def ESC(self):
        top, bot = ("D", "S") if self.NMOS else ("S", "D")
        return {"G": (-1, 0), top: (0, -1), bot: (0, 1)}

    def body(self):
        s = ['<path d="M-40,0 L-9,0" class="dev"/>',
             '<line x1="-9" y1="-13" x2="-9" y2="13" class="dev"/>',   # gate plate
             '<line x1="-3" y1="-16" x2="-3" y2="16" class="dev"/>',   # channel
             '<path d="M-3,-11 L20,-11 L20,-40" class="dev"/>',
             '<path d="M-3,11 L20,11 L20,40" class="dev"/>']
        # arrow on the lower horizontal leg: into the channel = n, out = p
        a, b = ((14, 11), (0, 11)) if self.NMOS else ((0, 11), (14, 11))
        s.append(Bjt._arrow(a, b, .85))
        return "\n".join(s)

    LPOS_DEFAULT = "left"


class Nmos(Mosfet):
    NMOS = True


class Pmos(Mosfet):
    NMOS = False


class OpAmp(Part):
    BODY = (-30, -30, 30, 30)
    LBL_UP, LBL_DN, H_LEFT, H_RIGHT = 37, 43, 55, 38
    W = H = 60

    def local_pins(self):
        w, h = self.W, self.H
        return {"in+": (-w / 2 - 20, 10), "in-": (-w / 2 - 20, -10),
                "out": (w / 2 + 20, 0), "vcc": (0, -h / 2), "vee": (0, h / 2)}

    ESC = {"in+": (-1, 0), "in-": (-1, 0), "out": (1, 0),
           "vcc": (0, -1), "vee": (0, 1)}

    def body(self):
        w, h = self.W, self.H
        return (f'<polygon points="{N(-w / 2)},{N(-h / 2)} {N(-w / 2)},{N(h / 2)} '
                f'{N(w / 2)},0" class="dev" fill="#fff"/>'
                f'<path d="M{N(-w / 2 - 20)},10 L{N(-w / 2)},10 '
                f'M{N(-w / 2 - 20)},-10 L{N(-w / 2)},-10 '
                f'M{N(w / 2)},0 L{N(w / 2 + 20)},0" class="dev"/>'
                # vcc/vee leads: the pins sit at (0,±h/2); the triangle's
                # sloped edges pass through (0,±h/4)
                f'<path d="M0,{N(-h / 2)} L0,{N(-h / 4)} '
                f'M0,{N(h / 2)} L0,{N(h / 4)}" class="dev"/>'
                f'<text x="{N(-w / 2 + 6)}" y="-6" class="pol">−</text>'
                f'<text x="{N(-w / 2 + 6)}" y="15" class="pol">+</text>')


class Switch(TwoTerm):
    BODY = (-17, -17, 19, 4)
    LBL_DN, H_LEFT, H_RIGHT = 20, 26, 26

    def body(self):
        h, c = self.SPAN / 2, 14
        return (f'<path d="M{N(-h)},0 L{N(-c)},0 M{N(h)},0 L{N(c)},0" class="dev"/>'
                f'<circle cx="{N(-c)}" cy="0" r="2.5" class="dev" fill="#fff"/>'
                f'<circle cx="{N(c)}" cy="0" r="2.5" class="dev" fill="#fff"/>'
                f'<path d="M{N(-c + 2)},-1 L{N(c + 4)},-14" class="dev"/>')


class Button(TwoTerm):
    BODY = (-13, -19, 13, 4)
    LBL_UP, LBL_DN = 23, 20

    def body(self):
        h, c = self.SPAN / 2, 10
        return (f'<path d="M{N(-h)},0 L{N(-c)},0 M{N(h)},0 L{N(c)},0" class="dev"/>'
                f'<circle cx="{N(-c)}" cy="0" r="2.5" class="dev" fill="#fff"/>'
                f'<circle cx="{N(c)}" cy="0" r="2.5" class="dev" fill="#fff"/>'
                f'<line x1="{N(-c - 4)}" y1="-8" x2="{N(c + 4)}" y2="-8" class="dev"/>'
                f'<line x1="0" y1="-8" x2="0" y2="-17" class="dev"/>')


class Battery(TwoTerm):
    """classic cell:  +  long thin plate | short thick plate  −"""
    BODY = (-8, -18, 8, 18)
    LBL_UP, LBL_DN = 25, 30
    PINSEQ = ("+", "-")

    def local_pins(self):
        h = self.SPAN / 2
        return {"a": (-h, 0), "b": (h, 0), "+": (-h, 0), "-": (h, 0)}

    def body(self):
        h = self.SPAN / 2
        return (f'<path d="M{N(-h)},0 L-5,0 M{N(h)},0 L5,0" class="dev"/>'
                '<line x1="-5" y1="-16" x2="-5" y2="16" class="dev"/>'
                '<line x1="5" y1="-7" x2="5" y2="7" class="rail"/>'
                '<text x="-19" y="-9" class="pol">+</text>'
                '<text x="9" y="-9" class="pol">−</text>')


class Gnd(Part):
    BODY = (-13, 8, 13, 21)
    ESC = {"p": (0, -1)}

    def local_pins(self):
        return {"p": (0, 0)}

    def body(self):
        return ('<path d="M0,0 L0,10" class="dev"/>'
                '<line x1="-12" y1="10" x2="12" y2="10" class="dev"/>'
                '<line x1="-8" y1="15" x2="8" y2="15" class="dev"/>'
                '<line x1="-4" y1="20" x2="4" y2="20" class="dev"/>')

    def label_svg(self):
        return ""


class Rail(Part):
    """power flag; pin p at the bottom; label = rail name"""
    BODY = (-14, -14, 14, -10)
    ESC = {"p": (0, 1)}

    def local_pins(self):
        return {"p": (0, 0)}

    def body(self):
        return ('<path d="M0,0 L0,-12" class="dev"/>'
                '<line x1="-13" y1="-12" x2="13" y2="-12" class="rail"/>')

    def label_svg(self):
        if not self.label:
            return ""
        return (f'<text x="{N(self.cx)}" y="{N(self.cy - 18)}" class="rail-lbl" '
                f'text-anchor="middle">{esc(self.label)}</text>')

    def label_ext(self):
        if not self.label:
            return []
        return [_text_ext(self.cx, self.cy - 18, self.label, 11, "middle")]


class PortSym(Part):
    """labelled net stub (GPIO, probe, ...); pin p on the right; mirror to
    flip. The tag stretches to fit its label."""
    ESC = {"p": (1, 0)}

    def _w(self):
        return max(64, 14 + round(7.0 * len(self.label)))

    @property
    def BODY(self):
        return (-self._w() - 7, -14, 5, 14)

    def local_pins(self):
        return {"p": (30, 0)}

    def body(self):
        w = self._w()
        return ('<path d="M0,0 L30,0" class="dev"/>'
                f'<path d="M{N(-w - 6)},-13 L-6,-13 L4,0 L-6,13 L{N(-w - 6)},13 Z"'
                ' class="port"/>')

    def label_svg(self):
        if not self.label:
            return ""
        tx = (self.cx + 10) if self.mirror else (self.cx - self._w())
        out = [f'<text x="{N(tx)}" y="{N(self.cy + 4)}" class="port-lbl">'
               f'{esc(self.label)}</text>']
        if self.value:
            out.append(f'<text x="{N(tx)}" y="{N(self.cy + 27)}" class="val">'
                       f'{esc(self.value)}</text>')
        return "\n".join(out)

    def label_ext(self):
        if not self.label:
            return []
        tx = (self.cx + 10) if self.mirror else (self.cx - self._w())
        out = [_text_ext(tx, self.cy + 4, self.label, 11.5)]
        if self.value:
            out.append(_text_ext(tx, self.cy + 27, self.value, 11))
        return out


class TestPoint(Part):
    BODY = (-5, -14, 5, -3)
    ESC = {"p": (0, 1)}

    def local_pins(self):
        return {"p": (0, 0)}

    def body(self):
        return ('<path d="M0,0 L0,-5" class="dev"/>'
                '<circle cx="0" cy="-9" r="4" class="dev" fill="#fff"/>')

    def label_svg(self):
        if not self.label:
            return ""
        return (f'<text x="{N(self.cx)}" y="{N(self.cy - 18)}" class="lbl" '
                f'text-anchor="middle">{esc(self.label)}</text>')

    def label_ext(self):
        if not self.label:
            return []
        return [_text_ext(self.cx, self.cy - 18, self.label, 12.5, "middle")]


def _spread(n, lo, hi):
    if n == 1:
        return [(lo + hi) / 2]
    return [lo + (hi - lo) * (i + 1) / (n + 1) for i in range(n)]


class Chip(Part):
    """rectangle with named pin rows per side; 18px stubs, names inside"""
    LEAD = 20

    def __init__(self, ref, x, y, w, h, label="", sub="", sides=None):
        super().__init__(ref, x, y, label=label)
        self.w, self.h, self.sub = float(w), float(h), sub
        self.sides = {s: list(sides.get(s, [])) for s in
                      ("left", "right", "top", "bottom")} if sides else \
                     {"left": [], "right": [], "top": [], "bottom": []}

    @property
    def BODY(self):
        return (-self.w / 2, -self.h / 2, self.w / 2, self.h / 2)

    def _side_pts(self):
        w, h = self.w, self.h
        out = {}
        for ys, nm in zip(_spread(len(self.sides["left"]), -h / 2, h / 2), self.sides["left"]):
            out[nm] = (-w / 2, ys, "left")
        for ys, nm in zip(_spread(len(self.sides["right"]), -h / 2, h / 2), self.sides["right"]):
            out[nm] = (w / 2, ys, "right")
        for xs, nm in zip(_spread(len(self.sides["top"]), -w / 2, w / 2), self.sides["top"]):
            out[nm] = (xs, -h / 2, "top")
        for xs, nm in zip(_spread(len(self.sides["bottom"]), -w / 2, w / 2), self.sides["bottom"]):
            out[nm] = (xs, h / 2, "bottom")
        return out

    _OFF = {"left": (-1, 0), "right": (1, 0), "top": (0, -1), "bottom": (0, 1)}

    def local_pins(self):
        L = self.LEAD
        return {nm: (x + self._OFF[side][0] * L, y + self._OFF[side][1] * L)
                for nm, (x, y, side) in self._side_pts().items()}

    def pin_esc(self, name):
        for nm, (_x, _y, side) in self._side_pts().items():
            if nm == name:
                dx, dy = self._OFF[side]
                if self.mirror:
                    dx = -dx
                return rot_pt(dx, dy, self.rot)
        return None

    def body(self):
        w, h, L = self.w, self.h, self.LEAD
        # classic IC: sharp-cornered box, device name centred in the body
        s = [f'<rect x="{N(-w / 2)}" y="{N(-h / 2)}" width="{N(w)}" height="{N(h)}"'
             f' class="ic"/>']
        ty = -5 if self.sub else 4
        s.append(f'<text x="0" y="{N(ty)}" class="ic-ttl" text-anchor="middle">'
                 f'{esc(self.label)}</text>')
        if self.sub:
            s.append(f'<text x="0" y="{N(ty + 18)}" class="sm" text-anchor="middle">'
                     f'{esc(self.sub)}</text>')
        anch = {"left": ("start", 6, -4), "right": ("end", -6, -4),
                "top": ("middle", 0, 13), "bottom": ("middle", 0, -7)}
        for nm, (x, y, side) in self._side_pts().items():
            dx, dy = self._OFF[side]
            s.append(f'<line x1="{N(x)}" y1="{N(y)}" x2="{N(x + dx * L)}"'
                     f' y2="{N(y + dy * L)}" class="dev"/>')
            a, ox, oy = anch[side]
            s.append(f'<text x="{N(x + ox)}" y="{N(y + oy)}" class="pin"'
                     f' text-anchor="{a}">{esc(nm)}</text>')
        return "\n".join(s)

    def label_svg(self):
        return ""

    def label_ext(self):
        return []                       # all chip/block text sits inside


class Block(Chip):
    """rounded box for system/flow diagrams; label text inside ('|' = newline);
    pins n/s/e/w/c always, plus declared side pins ON the edge (invisible)"""
    def __init__(self, ref, x, y, w, h, label="", sub="", sides=None, accent=False):
        super().__init__(ref, x, y, w, h, label=label, sub=sub, sides=sides)
        self.accent = accent

    def local_pins(self):
        w, h = self.w, self.h
        pins = {"n": (0, -h / 2), "s": (0, h / 2), "e": (w / 2, 0),
                "w": (-w / 2, 0), "c": (0, 0)}
        for nm, (x, y, _s) in self._side_pts().items():
            pins[nm] = (x, y)          # on the edge, no stub
        return pins

    _NSEW = {"n": (0, -1), "s": (0, 1), "e": (1, 0), "w": (-1, 0)}

    def pin_esc(self, name):
        if name in self._NSEW:
            return rot_pt(*self._NSEW[name], self.rot)
        for nm, (_x, _y, side) in self._side_pts().items():
            if nm == name:
                return rot_pt(*self._OFF[side], self.rot)
        return None

    def body(self):
        w, h = self.w, self.h
        cls = "blk" if self.accent else "act"
        s = [f'<rect x="{N(-w / 2)}" y="{N(-h / 2)}" width="{N(w)}" height="{N(h)}"'
             f' rx="9" class="{cls}"/>']
        lines = self.label.split("|")
        n = len(lines) + (1 if self.sub else 0)
        y0 = -((n - 1) * 9)
        for i, ln in enumerate(lines):
            s.append(f'<text x="0" y="{N(y0 + i * 18 + 5)}" class="blk-ttl"'
                     f' text-anchor="middle">{esc(ln)}</text>')
        if self.sub:
            for j, sl in enumerate(self.sub.split("|")):
                s.append(f'<text x="0" y="{N(y0 + len(lines) * 18 + j * 14 + 4)}"'
                         f' class="sm" text-anchor="middle">{esc(sl)}</text>')
        return "\n".join(s)


SYMBOLS = {
    "res": Res, "pot": Pot, "cap": Cap, "cap_pol": CapPol, "inductor": Inductor,
    "piezo": Piezo, "xtal": Xtal,
    "diode": Diode, "schottky": Schottky, "zener": Zener, "led": Led,
    "npn": Npn, "pnp": Pnp, "nmos": Nmos, "pmos": Pmos, "opamp": OpAmp,
    "switch": Switch, "button": Button, "battery": Battery,
    "gnd": Gnd, "rail": Rail, "port": PortSym, "testpoint": TestPoint,
}


# ==================================================================== router
def _seg_hits(a, b, rect):
    """axis-aligned segment (shrunk at both ends) vs inflated rect"""
    x0, y0, x1, y1 = rect
    ax, ay = a
    bx, by = b
    L = math.hypot(bx - ax, by - ay)
    if L < 8:
        return False
    t = 3.0 / L
    ax, ay = ax + (bx - a[0]) * t, ay + (by - a[1]) * t
    bx, by = b[0] + (a[0] - b[0]) * t, b[1] + (a[1] - b[1]) * t
    lo_x, hi_x = sorted((ax, bx))
    lo_y, hi_y = sorted((ay, by))
    return not (hi_x < x0 or lo_x > x1 or hi_y < y0 or lo_y > y1)


def _clear(poly, obstacles):
    return not any(_seg_hits(a, b, r)
                   for a, b in zip(poly, poly[1:]) for r in obstacles)


def _dedup(poly):
    out = [poly[0]]
    for p in poly[1:]:
        if not close(p, out[-1]):
            # drop collinear middle points
            if len(out) >= 2 and unit(out[-2], out[-1]) == unit(out[-1], p):
                out[-1] = p
            else:
                out.append(p)
    return out


def _manhattan(a, b, prefer=None):
    """plain L-route with no obstacle check (used between explicit waypoints)"""
    if abs(a[0] - b[0]) < EPS or abs(a[1] - b[1]) < EPS:
        return [a, b]
    if prefer and abs(prefer[1]) > abs(prefer[0]):
        return [a, (a[0], b[1]), b]      # vertical first
    return [a, (b[0], a[1]), b]


def route(a, b, obstacles, first_dir=None, last_dir=None, sheet_wh=(4000, 2000)):
    """orthogonal path a->b avoiding obstacle rects; prefers matching the
    requested leaving/arriving directions and few bends."""
    if close(a, b):
        return [a, b]
    cands = []
    if abs(a[0] - b[0]) < EPS or abs(a[1] - b[1]) < EPS:
        cands.append([a, b])
    cands += [[a, (b[0], a[1]), b], [a, (a[0], b[1]), b]]
    for t in (.5, .35, .65, .25, .75, .15, .85):
        xm = a[0] + (b[0] - a[0]) * t
        ym = a[1] + (b[1] - a[1]) * t
        cands.append([a, (xm, a[1]), (xm, b[1]), b])
        cands.append([a, (a[0], ym), (b[0], ym), b])
    # detours around blockage when endpoints are aligned
    for off in (40, -40, 70, -70, 110, -110):
        if abs(a[1] - b[1]) < EPS:
            cands.append([a, (a[0], a[1] + off), (b[0], b[1] + off), b])
        if abs(a[0] - b[0]) < EPS:
            cands.append([a, (a[0] + off, a[1]), (b[0] + off, b[1]), b])

    def score(poly):
        p = _dedup(poly)
        lens = [math.hypot(q[0] - r[0], q[1] - r[1]) for q, r in zip(p, p[1:])]
        s = (len(p) - 2) * 2.0 + sum(lens) / 1000.0
        # a corner right in front of a pin looks broken: penalise stubby
        # segments, hardest at the two ends of the run
        s += sum(1.2 for L in lens if 0 < L < 18)
        if len(lens) > 1 and lens[0] < 28:
            s += 0.6
        if len(lens) > 1 and lens[-1] < 28:
            s += 0.8
        # escape/approach preferences are tie-breakers, weaker than one bend
        if first_dir and len(p) > 1:
            if unit(p[0], p[1]) != (round(first_dir[0], 3), round(first_dir[1], 3)):
                s += 1.25
        if last_dir and len(p) > 1:
            if unit(p[-2], p[-1]) != (round(last_dir[0], 3), round(last_dir[1], 3)):
                s += 1.25
        return s

    best = None
    for c in cands:
        c = _dedup(c)
        if len(c) < 2 or not _clear(c, obstacles):
            continue
        sc = score(c)
        if best is None or sc < best[0]:
            best = (sc, c)
    if best:
        return best[1]
    p = _astar(a, b, obstacles, sheet_wh)
    if p:
        return p
    return _dedup([a, (b[0], a[1]), b])    # last resort: overlap and be visible


def _astar(a, b, obstacles, wh, step=10):
    """coarse grid A* anchored at `a`; used only when simple shapes collide"""
    W, H = wh

    def blocked(p):
        return any(r[0] <= p[0] <= r[2] and r[1] <= p[1] <= r[3] for r in obstacles)

    def nearb(p):
        return abs(p[0] - b[0]) < step and abs(p[1] - b[1]) < step

    start = (a[0], a[1])
    openq = [(0, 0, start, None, None)]
    seen = {}
    parent = {}
    pops = 0
    while openq and pops < 30000:
        f, g, p, dirn, par = heapq.heappop(openq)
        pops += 1
        key = (round(p[0]), round(p[1]), dirn)
        if key in seen and seen[key] <= g:
            continue
        seen[key] = g
        parent[key] = (par, p)
        if nearb(p) or close(p, b):
            pts = [p]
            k = key
            while parent[k][0] is not None:
                k = parent[k][0]
                pts.append(parent[k][1])
            pts.reverse()
            pts.append((b[0], p[1]) if abs(p[1] - b[1]) < abs(p[0] - b[0]) else (p[0], b[1]))
            pts.append(b)
            return _dedup(pts)
        for d in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            q = (p[0] + d[0] * step, p[1] + d[1] * step)
            if not (-20 <= q[0] <= W + 20 and -20 <= q[1] <= H + 20) or blocked(q):
                continue
            ng = g + step + (30 if (dirn and d != dirn) else 0)
            nh = abs(q[0] - b[0]) + abs(q[1] - b[1])
            heapq.heappush(openq, (ng + nh, ng, q, d, key))
    return None


# ================================================================ the sheet
NET_COLORS = ["#d62728", "#1f77b4", "#2ca02c", "#ff7f0e", "#9467bd", "#8c564b",
              "#e377c2", "#17becf", "#bcbd22", "#1a7f5a", "#393b79", "#b5651d",
              "#7b4173", "#637939", "#843c39", "#3182bd"]

AUTO_MARGIN = 40    # auto-size: white space around the drawing
AUTO_TITLE_H = 40   # auto-size: room reserved for the title row

TERM_STUB = 40      # default rail/gnd drop when the path gives no hints
INLINE_LEAD = 40    # wire run before an auto-placed inline part
PAIR_SPREAD = 80    # ± offset when a hint-less pair meets at one node
DROP_MARGIN = 12    # node pinned by a drop stays this far inside its span
BLOCK_STUB = 20     # forced perpendicular escape at block-edge pins (wires)
FLOW_STUB = 20      # same for flow arrows
PIN_STUB = 10       # forced straight escape out of every other pin
                    # (per-sheet override: `escape N`; 0 disables)


class EndPt:
    """one end of a link: a fixed point, a part pin, or a (maybe deferred) node"""
    def __init__(self, pt=None, node=None, esc=None, part=None):
        self.pt, self.node, self.esc, self.part = pt, node, esc, part


class Link:
    def __init__(self, a, b, mods, color=None, kind="wire", label="", dashed=False):
        self.a, self.b, self.mods = a, b, mods       # mods: ('must',pt)|('dir',d)
        self.color, self.kind = color, kind
        self.label, self.dashed = label, dashed


class Sheet:
    def __init__(self):
        self.w, self.h = 800, 500
        self.auto_size = True    # no explicit `sheet WxH` -> size from content
        self.has_abs = False     # any absolute X,Y used? (else content floats)
        self.title = ""
        self.notes = []
        self.parts = {}          # ref -> Part (insertion order = z-order)
        self.nodes = {}          # name -> (x,y) | None while deferred
        self.nets = {}           # net name -> {"color":..., "disp":...}
        self.links = []          # wires + flows
        self.color_nets = False
        self.pin_stub = PIN_STUB
        self._auto = 0
        self.wires = []          # routed polylines (filled by layout())
        self._wire_color = []
        self.flow_polys = []

    # ---- registry ----
    def add_part(self, part):
        if part.ref in self.parts or part.ref in self.nodes:
            raise SchError(f"duplicate ref '{part.ref}'")
        self.parts[part.ref] = part
        return part

    def auto_ref(self, prefix):
        self._auto += 1
        return f"_{prefix}{self._auto}"

    def find_part(self, ref, ns=""):
        parts = ns.split(".") if ns else []
        for i in range(len(parts), -1, -1):
            q = ".".join(parts[:i] + [ref])
            if q in self.parts:
                return self.parts[q]
        return None

    def find_node(self, name, ns=""):
        parts = ns.split(".") if ns else []
        for i in range(len(parts), -1, -1):
            q = ".".join(parts[:i] + [name])
            if q in self.nodes:
                return q
        return None

    def pin_of(self, token, ns=""):
        """resolve 'REF.PIN' (longest existing ref wins) -> (part, pinname)"""
        idxs = [i for i, ch in enumerate(token) if ch == "."]
        for i in reversed(idxs):
            p = self.find_part(token[:i], ns)
            if p is not None:
                pin = token[i + 1:]
                if pin in p.local_pins():
                    return p, pin
                raise SchError(f"{p.ref}: no pin '{pin}' "
                               f"(has: {', '.join(sorted(p.local_pins()))})")
        raise Unresolved(f"unknown part in '{token}'")

    # ---- node resolution ----
    def _node_anchors(self, name):
        """known endpoints of links incident to the node, with a direction
        toward the node (an explicit dir hint, else the pin's escape)"""
        pts, dirs = [], []
        for lk in self.links:
            for me, other in ((lk.a, lk.b), (lk.b, lk.a)):
                if me.node == name:
                    p = other.pt if other.node is None else self.nodes.get(other.node)
                    if p is not None:
                        pts.append(p)
                        d = next((m[1] for m in lk.mods if m[0] == "dir"), None)
                        dirs.append(d or other.esc)
        return pts, dirs

    def try_resolve_node(self, name, allow_single):
        """midpoint of the first two known anchors — but a later anchor that
        drops perpendicularly onto the line between them pins the free
        coordinate, so its tap lands straight. With allow_single, a single
        anchor plus 40px in its outgoing direction. True if now placed."""
        if self.nodes.get(name) is not None:
            return True
        pts, dirs = self._node_anchors(name)
        uniq, udirs = [], []
        for p, d in zip(pts, dirs):
            if not any(close(p, q) for q in uniq):
                uniq.append(p)
                udirs.append(d)
        if len(uniq) >= 2:
            (x1, y1), (x2, y2) = uniq[0], uniq[1]
            if abs(x1 - x2) < EPS:
                x, y = x1, (y1 + y2) / 2
            elif abs(y1 - y2) < EPS:
                x, y = (x1 + x2) / 2, y1
            else:
                x, y = (x1 + x2) / 2, (y1 + y2) / 2
            # centring between the through anchors is only a default: anchors
            # beyond the first two are drops onto that line (pull-up onto a
            # bus, tap onto a rail); the first drop landing inside the span
            # takes over the free coordinate so its wire connects straight
            ax = 0 if abs(x2 - x1) >= abs(y2 - y1) else 1
            lo, hi = sorted((uniq[0][ax], uniq[1][ax]))
            for p, d in zip(uniq[2:], udirs[2:]):
                off_line = abs(p[1] - y) if ax == 0 else abs(p[0] - x)
                if off_line < EPS:
                    continue                  # on the line — nothing to drop
                if d and abs(d[ax]) > 1e-6:
                    continue                  # arrives along the line
                if lo + DROP_MARGIN <= p[ax] <= hi - DROP_MARGIN:
                    if ax == 0:
                        x = p[0]
                    else:
                        y = p[1]
                    break
            self.nodes[name] = (x, y)
        elif len(uniq) == 1 and allow_single:
            d = next((d for d in dirs if d), None) or (1, 0)
            self.nodes[name] = (uniq[0][0] + d[0] * 40, uniq[0][1] + d[1] * 40)
        else:
            return False
        return True

    def resolve_nodes(self):
        for allow_single in (False, True):
            changed = True
            while changed:
                changed = any(self.try_resolve_node(n, allow_single)
                              for n, p in list(self.nodes.items()) if p is None)
        bad = [n for n, p in self.nodes.items() if p is None]
        if bad:
            raise SchError(f"cannot place node(s): {', '.join(bad)} "
                           f"(no connected anchor — add hints or `node NAME at X,Y`)")

    # ---- layout: route every link ----
    def obstacles(self, exclude=()):
        out = []
        for p in self.parts.values():
            if p in exclude:
                continue
            x0, y0, x1, y1 = p.bbox()
            out.append((x0 - 7, y0 - 7, x1 + 7, y1 + 7))
        return out

    def layout(self):
        bad = [r for r, p in self.parts.items() if p.cx is None]
        if bad:
            raise SchError(f"part(s) never placed: {', '.join(sorted(bad))} — "
                           f"wire one of their pins in a path, or give 'at'")
        self.resolve_nodes()
        self.wires, self._wire_color, self.flow_polys = [], [], []
        for lk in self.links:
            pa = lk.a.pt if lk.a.node is None else self.nodes[lk.a.node]
            pb = lk.b.pt if lk.b.node is None else self.nodes[lk.b.node]
            # a part whose body sits at/behind its own pin must not block its
            # own wire; larger symbols keep blocking (pins clear them anyway)
            excl = tuple(ep.part for ep in (lk.a, lk.b)
                         if isinstance(ep.part, (Gnd, Rail, TestPoint, PortSym, Block)))
            obst = self.obstacles(exclude=excl)
            musts = [m for m in lk.mods if m[0] == "must"]
            a_manual = bool(lk.mods) and lk.mods[0][0] == "must"
            b_manual = bool(musts) and lk.kind != "flow"

            def stub_len(ep):
                """forced straight escape at this endpoint: perpendicular at
                block edges / flow ends, `pin_stub` px at every other pin"""
                if lk.kind == "flow":
                    return FLOW_STUB
                if isinstance(ep.part, Block):
                    return BLOCK_STUB
                return self.pin_stub

            def toward(esc, frm, tgt):
                """does tgt lie on the esc side of frm? (never stub a wire
                into a double-back through its own pin)"""
                return esc[0] * (tgt[0] - frm[0]) + esc[1] * (tgt[1] - frm[1]) > EPS

            hard_a = lk.kind == "flow" or isinstance(lk.a.part, Block)
            hard_b = lk.kind == "flow" or isinstance(lk.b.part, Block)
            first_must = next((m[1] for m in lk.mods if m[0] == "must"), None)
            pts = [pa]
            dir_pref = lk.a.esc
            # forced straight escape — unless the user's own first waypoint
            # already controls the exit, or the run heads the other way
            sa = stub_len(lk.a) if lk.a.esc and not a_manual else 0
            if sa and (hard_a or toward(lk.a.esc, pa, first_must or pb)):
                pts.append((pa[0] + lk.a.esc[0] * sa, pa[1] + lk.a.esc[1] * sa))
                # blocks/flows: any direction is fine past the stub; plain
                # pins keep preferring to continue straight
                if hard_a:
                    dir_pref = None
            segs = []                    # (from, to, first_dir, last_dir, manual)
            cur = pts[-1]
            for m in lk.mods:
                if m[0] == "dir":
                    dir_pref = m[1]
                else:
                    segs.append((cur, m[1], dir_pref, None, True))
                    cur, dir_pref = m[1], None
            end = pb
            enter = tuple(-c for c in lk.b.esc) if lk.b.esc else None
            tail = []
            sb = stub_len(lk.b) if lk.b.esc and not b_manual else 0
            if sb and (hard_b or toward(lk.b.esc, pb, pa)):
                end = (pb[0] + lk.b.esc[0] * sb, pb[1] + lk.b.esc[1] * sb)
                tail = [pb]
                if hard_b:
                    enter = None
            segs.append((cur, end, dir_pref, enter, False))
            poly = list(pts)
            for (s, e, fd, ld, manual) in segs:
                if manual:
                    # explicit waypoints override the autorouter entirely
                    sub = _manhattan(s, e, fd)
                else:
                    sub = route(s, e, obst, first_dir=fd, last_dir=ld,
                                sheet_wh=(self.w, self.h))
                poly.extend(sub[1:])
            poly.extend(tail)
            poly = _dedup(poly)
            if lk.kind == "flow":
                self.flow_polys.append((poly, lk.dashed, lk.label))
            else:
                if len(poly) >= 2:
                    self.wires.append(poly)
                    self._wire_color.append(lk.color)

    # ---- electrical analysis (same rules as v1) ----
    def junctions(self):
        """dot where >=3 distinct conductor directions meet (wire segments and
        pin leads; overlapping same-direction conductors collapse to one)"""
        segs, verts = [], []
        for poly in self.wires:
            segs.extend((a, b) for a, b in zip(poly, poly[1:]) if not close(a, b))
            verts.extend(poly)
        pinrefs = [(q, (p.cx, p.cy)) for p in self.parts.values()
                   for q in p.pins().values()]
        dots, seen = [], []
        for v in verts:
            if any(close(v, s) for s in seen):
                continue
            seen.append(v)
            dirs = set()
            for a, b in segs:
                if close(v, a):
                    d = unit(v, b)
                    if d:
                        dirs.add(d)
                elif close(v, b):
                    d = unit(v, a)
                    if d:
                        dirs.add(d)
                elif _on_seg(v, a, b):
                    for d in (unit(v, a), unit(v, b)):
                        if d:
                            dirs.add(d)
            for q, c in pinrefs:
                if close(v, q):
                    d = unit(q, c)
                    if d:
                        dirs.add(d)
            if len(dirs) >= 3:
                dots.append(v)
        return dots

    def wire_nets(self):
        n = len(self.wires)
        parent = list(range(n))

        def find(i):
            while parent[i] != i:
                parent[i] = parent[parent[i]]
                i = parent[i]
            return i
        for i in range(n):
            for j in range(i + 1, n):
                if _touch(self.wires[i], self.wires[j]):
                    parent[find(i)] = find(j)
        order, nets = {}, []
        for i in range(n):
            r = find(i)
            order.setdefault(r, len(order))
            nets.append(order[r])
        return nets

    def render_colors(self):
        if not self.wires:
            return []
        nets = self.wire_nets()
        if self.color_nets:
            return [NET_COLORS[nets[i] % len(NET_COLORS)] for i in range(len(self.wires))]
        net_col = {}
        for i, c in enumerate(self._wire_color):      # explicit `color` first
            if c and nets[i] not in net_col:
                net_col[nets[i]] = c
        for p in self.parts.values():                 # then terminal net colours
            netname = getattr(p, "netname", None)
            col = self.nets.get(netname, {}).get("color") if netname else None
            if not col:
                continue
            q = p.pin("p")
            for i, poly in enumerate(self.wires):
                if _pt_on_wire(q, poly):
                    net_col.setdefault(nets[i], col)
                    break
        return [net_col.get(nets[i]) for i in range(len(self.wires))]

    # ---- electrical netlist (debug / equivalence checking) ----
    def netlist(self):
        """each electrical net as a sorted tuple of member labels:
        `REF.PIN` for part pins, `<NETNAME>` for rail/gnd terminals,
        `(NAME)` for named nodes. Layout-independent — two builds of the
        same circuit print identical netlists regardless of positions."""
        ids = self.wire_nets()
        groups = {i: set() for i in set(ids)}
        for ref, part in self.parts.items():
            seen_pos = []
            for pin, pos in part.pins().items():
                if any(close(pos, q) for q in seen_pos):
                    continue            # alias pins (cap_pol +/-, battery a/b)
                seen_pos.append(pos)
                net = getattr(part, "netname", None)
                lbl = f"<{net}>" if net else f"{ref}.{pin}"
                hit = False
                for i, poly in enumerate(self.wires):
                    if _pt_on_wire(pos, poly):
                        groups[ids[i]].add(lbl)
                        hit = True
                if not hit and not net:
                    groups.setdefault(None, set()).add(lbl)
        for name, pos in self.nodes.items():
            # `_`-names are plumbing (incl. inside def/use instances) — hidden
            if name.split(".")[-1].startswith("_") or pos is None:
                continue
            for i, poly in enumerate(self.wires):
                if _pt_on_wire(pos, poly):
                    groups[ids[i]].add(f"({name})")
                    break
        loose = sorted(groups.pop(None, ()))
        nets = sorted(tuple(sorted(g)) for g in groups.values() if g)
        return nets, loose

    # ---- auto-size: bounding box of everything drawn ----
    def content_bbox(self):
        xs, ys = [], []

        def add(x0, y0, x1=None, y1=None):
            xs.extend((x0, x1 if x1 is not None else x0))
            ys.extend((y0, y1 if y1 is not None else y0))
        for p in self.parts.values():
            add(*p.bbox())
            for px, py in p.pins().values():
                add(px, py)
            for e in p.label_ext():
                add(*e)
        for poly in self.wires:
            for x, y in poly:
                add(x, y)
        for poly, _dashed, label in self.flow_polys:
            for x, y in poly:
                add(x, y)
            if label:
                mx, my = _midpoint(poly)
                lines = label.split("|")
                y0 = my - 6 - (len(lines) - 1) * 12
                for k, ln in enumerate(lines):
                    add(*_text_ext(mx, y0 + k * 12, ln, 11, "middle"))
        if not xs:
            return (0.0, 0.0, self.w, self.h)
        return (min(xs), min(ys), max(xs), max(ys))

    def print_nets(self, out=sys.stdout):
        nets, loose = self.netlist()
        print(f"{len(nets)} nets:", file=out)
        for members in nets:
            print("  " + "  ".join(members), file=out)
        if loose:
            print("unconnected pins: " + "  ".join(loose), file=out)

    # ---- output ----
    def svg(self):
        dx = dy = 0.0
        if self.auto_size:
            # size the sheet from its content: margin all around, a header
            # row for the title, the note box below — and centre the drawing
            # in the remaining area, wherever its coordinates happen to live
            x0, y0, x1, y1 = self.content_bbox()
            top = AUTO_MARGIN + (AUTO_TITLE_H if self.title else 0)
            self.w = (x1 - x0) + 2 * AUTO_MARGIN
            self.h = top + (y1 - y0) + AUTO_MARGIN
            if self.notes:
                maxchars = int((self.w - 52) / 5.6)
                wrapped = [ln for note in self.notes
                           for ln in wrap_text(note, maxchars)]
                self.h += 14 * len(wrapped) + 26
            self.w, self.h = math.ceil(self.w), math.ceil(self.h)
            dx, dy = AUTO_MARGIN - x0, top - y0
        elif not self.has_abs:
            # fixed sheet size but no absolute coordinate anywhere: the
            # drawing floats — centre it in the area between title and notes
            x0, y0, x1, y1 = self.content_bbox()
            top = AUTO_MARGIN + (AUTO_TITLE_H if self.title else 0)
            foot = 0
            if self.notes:
                maxchars = int((self.w - 52) / 5.6)
                wrapped = [ln for note in self.notes
                           for ln in wrap_text(note, maxchars)]
                foot = 14 * len(wrapped) + 26
            dx = (self.w - (x1 - x0)) / 2 - x0
            dy = top + (self.h - top - AUTO_MARGIN - foot - (y1 - y0)) / 2 - y0
        S = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{N(self.w)}" '
             f'height="{N(self.h)}" viewBox="0 0 {N(self.w)} {N(self.h)}" '
             f'font-family="Helvetica,Arial,sans-serif">',
             _DEFS, _STYLE,
             f'  <rect x="0" y="0" width="{N(self.w)}" height="{N(self.h)}" fill="#fff"/>']
        if self.title:
            S.append(f'  <text x="20" y="26" class="ttl">{esc(self.title)}</text>')
        if dx or dy:
            S.append(f'  <g transform="translate({N(dx)},{N(dy)})">')
        cols = self.render_colors()
        for i, poly in enumerate(self.wires):
            d = "M" + " L".join(f"{N(x)},{N(y)}" for x, y in poly)
            if cols[i]:
                wd = "2.4" if self.color_nets else "2.0"
                S.append(f'  <path d="{d}" fill="none" stroke="{cols[i]}" '
                         f'stroke-width="{wd}" stroke-linecap="round" '
                         f'stroke-linejoin="round"/>')
            else:
                S.append(f'  <path d="{d}" class="wire"/>')
        for v in self.junctions():
            col = next((cols[i] for i, poly in enumerate(self.wires)
                        if _pt_on_wire(v, poly) and cols[i]), None)
            if col:
                S.append(f'  <circle cx="{N(v[0])}" cy="{N(v[1])}" r="3.3" fill="{col}"/>')
            else:
                S.append(f'  <circle cx="{N(v[0])}" cy="{N(v[1])}" r="3" class="dot"/>')
        for poly, dashed, label in self.flow_polys:
            d = "M" + " L".join(f"{N(x)},{N(y)}" for x, y in poly)
            S.append(f'  <path d="{d}" class="{"flowc" if dashed else "flow"}"/>')
            if label:
                mx, my = _midpoint(poly)
                lines = label.split("|")
                y0 = my - 6 - (len(lines) - 1) * 12
                for k, ln in enumerate(lines):
                    S.append(f'  <text x="{N(mx)}" y="{N(y0 + k * 12)}" class="flbl"'
                             f' text-anchor="middle">{esc(ln)}</text>')
        for p in self.parts.values():
            S.append(p.svg())
        if dx or dy:
            S.append('  </g>')
        if self.notes:
            maxchars = int((self.w - 52) / 5.6)
            wrapped = [ln for note in self.notes for ln in wrap_text(note, maxchars)]
            y = self.h - 14 * len(wrapped) - 12
            S.append(f'  <rect x="16" y="{N(y - 14)}" width="{N(self.w - 32)}" '
                     f'height="{N(14 * len(wrapped) + 12)}" rx="6" fill="#fbfbf2"'
                     f' stroke="#ddd"/>')
            for i, ln in enumerate(wrapped):
                S.append(f'  <text x="26" y="{N(y + i * 14)}" class="note">{esc(ln)}</text>')
        S.append("</svg>")
        return "\n".join(S)


def _on_seg(p, a, b):
    (px, py), (ax, ay), (bx, by) = p, a, b
    if abs(ax - bx) < EPS:
        if abs(px - ax) > EPS:
            return False
        lo, hi = sorted((ay, by))
        return lo + EPS < py < hi - EPS
    if abs(ay - by) < EPS:
        if abs(py - ay) > EPS:
            return False
        lo, hi = sorted((ax, bx))
        return lo + EPS < px < hi - EPS
    return False


def _pt_on_wire(p, poly):
    return (any(close(p, v) for v in poly) or
            any(_on_seg(p, a, b) for a, b in zip(poly, poly[1:])))


def _touch(A, B):
    return (any(_pt_on_wire(v, B) for v in A) or
            any(_pt_on_wire(v, A) for v in B))


def _midpoint(poly):
    segs = list(zip(poly, poly[1:]))
    total = sum(math.hypot(b[0] - a[0], b[1] - a[1]) for a, b in segs)
    half, acc = total / 2, 0.0
    for a, b in segs:
        d = math.hypot(b[0] - a[0], b[1] - a[1])
        if acc + d >= half:
            t = (half - acc) / d if d else 0
            return (a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t)
        acc += d
    return poly[len(poly) // 2]


_DEFS = """  <defs>
    <marker id="arr" markerWidth="10" markerHeight="10" refX="8" refY="4.5" orient="auto">
      <path d="M0,0 L9,4.5 L0,9 z" fill="#1a1a1a"/>
    </marker>
    <marker id="arrc" markerWidth="10" markerHeight="10" refX="8" refY="4.5" orient="auto">
      <path d="M0,0 L9,4.5 L0,9 z" fill="#7a2d2d"/>
    </marker>
  </defs>"""

_STYLE = """  <style>
    .wire{stroke:#1a1a1a;stroke-width:1.7;fill:none;stroke-linecap:round;stroke-linejoin:round}
    .dev{stroke:#1a1a1a;stroke-width:1.7;fill:none;stroke-linecap:round;stroke-linejoin:round}
    .rail{stroke:#1a1a1a;stroke-width:2.4;fill:none}
    .ic{fill:#fffbdd;stroke:#1a1a1a;stroke-width:2}
    .port{fill:#fbf3e6;stroke:#9a6a1a;stroke-width:1.3}
    .dot{fill:#1a1a1a}
    .lbl{font-size:12.5px;fill:#111}
    .val{font-size:11px;fill:#555}
    .pin{font-size:10px;fill:#1a1a1a}
    .pol{font-size:12px;fill:#111}
    .sm{font-size:10.5px;fill:#555}
    .ic-ttl{font-size:13px;font-weight:bold;fill:#111}
    .port-lbl{font-size:11.5px;fill:#7a2d2d;font-weight:bold}
    .rail-lbl{font-size:11px;fill:#1a5e1a;font-weight:bold}
    .ttl{font-size:15px;font-weight:bold;fill:#111}
    .note{font-size:10.5px;fill:#555}
    .act{fill:#fff;stroke:#1a1a1a;stroke-width:1.5}
    .blk{fill:#eef3fb;stroke:#33507a;stroke-width:1.5}
    .blk-ttl{font-size:13px;font-weight:bold;fill:#1b2c4a}
    .flow{stroke:#1a1a1a;stroke-width:1.8;fill:none;marker-end:url(#arr)}
    .flowc{stroke:#7a2d2d;stroke-width:1.8;fill:none;stroke-dasharray:6 4;marker-end:url(#arrc)}
    .flbl{font-size:11px;fill:#1a5e1a;font-weight:bold}
  </style>"""


# ==================================================================== parser
TOK = re.compile(r'"[^"]*"|\[[^\]]*\](?:\.[^\s]+)?|\([^()]*\)|->|<-|\S+')
HEXCOLOR = re.compile(r"#[0-9a-fA-F]{6}\b|#[0-9a-fA-F]{3}\b")
WXH = re.compile(r"([\d.]+)x([\d.]+)$")
XY = re.compile(r"(-?[\d.]+),(-?[\d.]+)$")
OFFSET = re.compile(r"([+-][\d.]+),([+-]?[\d.]+)$")
IDENT = re.compile(r"[A-Za-z_]\w*$")


def strip_comment(line):
    inq = False
    i = 0
    while i < len(line):
        ch = line[i]
        if ch == '"':
            inq = not inq
        elif ch == "#" and not inq:
            if not HEXCOLOR.match(line, i):
                return line[:i]
        i += 1
    return line


def tokens(text):
    return TOK.findall(text)


def unq(tok):
    return tok[1:-1] if len(tok) >= 2 and tok[0] == '"' and tok[-1] == '"' else tok


class Parser:
    def __init__(self):
        self.sheet = Sheet()
        self.defs = {}       # name -> (params, [(file, lineno, rawline), ...])
        self.defchips = {}   # name -> dict(w,h,label,sub,sides)
        self._files = set()
        self._depth = 0      # include nesting; deferred stmts flush at 0
        self._deferred = []  # [fname, ns, lineno, line, extra_lines, err]
        self._seed_ok = False    # stall: a path may seed itself at the origin
        self._seed_nodes = False  # …even when its first element is a bare node
        Part.STYLE = "us"    # symbol style is per-build; `sheet … iec` flips it

    # ---- deferral: statements whose references cannot resolve YET are
    # rolled back and retried until everything settles (order-free layout) --
    def _snap(self):
        sh = self.sheet
        return ({r: (p.cx, p.cy) for r, p in sh.parts.items()},
                dict(sh.nodes), len(sh.links), sh._auto,
                set(sh.nets), sh.has_abs)

    def _restore(self, snap):
        sh = self.sheet
        poss, nodes, nlinks, auto, netkeys, has_abs = snap
        for r in [r for r in sh.parts if r not in poss]:
            del sh.parts[r]
        for r, (cx, cy) in poss.items():
            sh.parts[r].cx, sh.parts[r].cy = cx, cy
        sh.nodes = nodes
        del sh.links[nlinks:]
        sh._auto = auto
        for n in [n for n in sh.nets if n not in netkeys]:
            del sh.nets[n]
        sh.has_abs = has_abs

    def _seed_pt(self):
        """origin for an anchor-free cluster; further clusters stack below"""
        placed = [p for p in self.sheet.parts.values() if p.cx is not None]
        if not placed:
            return (0.0, 0.0)
        return (0.0, max(p.bbox()[3] for p in placed) + 160)

    def _retry(self, unit):
        fname, ns, lineno, line, extra, _err = unit
        snap = self._snap()
        try:
            self.statement(line, extra, 0, fname, ns, lineno)
            return True
        except Unresolved as e:
            self._restore(snap)
            unit[5] = str(e)
            self._deferred.append(unit)
            return False
        except SchError as e:
            raise SchError(f"{fname}:{lineno}: {e}") from None

    def _flush_deferred(self):
        while self._deferred:
            queue, self._deferred = self._deferred, []
            progress = False
            for u in queue:
                progress = self._retry(u) or progress
            if self._deferred and not progress:
                # full stall: nothing is absolutely anchored (or a reference
                # is broken). Let the first statement that can seed itself
                # place its first element at the origin, then keep going —
                # part-pin paths first (structural roots), bare nodes only
                # if no pin path can.
                seeded = False
                for allow_nodes in (False, True):
                    if seeded:
                        break
                    queue, self._deferred = self._deferred, []
                    self._seed_ok, self._seed_nodes = True, allow_nodes
                    try:
                        for u in queue:
                            if seeded:
                                self._deferred.append(u)
                            else:
                                seeded = self._retry(u)
                    finally:
                        self._seed_ok = self._seed_nodes = False
                if not seeded:
                    # declaration-only cluster (chips chained by `at`, no
                    # paths): anchor the first still-unplaced part instead
                    for p in self.sheet.parts.values():
                        if p.cx is None:
                            p.cx, p.cy = self._seed_pt()
                            seeded = True
                            break
                if not seeded:
                    fname, _ns, lineno, _l, _x, err = self._deferred[0]
                    raise SchError(
                        f"{fname}:{lineno}: {err} — unresolvable even after "
                        f"reading the whole sheet (missing part, or circular "
                        f"positions)")

    # ---------------- file / line driving ----------------
    def parse_file(self, path):
        rp = os.path.realpath(path)
        if rp in self._files:
            return
        self._files.add(rp)
        with open(path) as f:
            lines = f.read().splitlines()
        self._depth += 1
        try:
            self.parse_lines(lines, path)
        finally:
            self._depth -= 1
        if self._depth == 0:
            self._flush_deferred()
        return self.sheet

    def import_file(self, path, only=None):
        """`import "file.sch" [NAME …]` — read a file but keep ONLY its
        def/defchip definitions (optionally just the named ones); the sheet
        itself (canvas, parts, wires, notes) is skipped entirely, so any
        detail sheet doubles as a library of its reusable groups"""
        try:
            with open(path) as f:
                lines = f.read().splitlines()
        except OSError as e:
            raise SchError(f"import: cannot read '{path}': {e.strerror}")
        only = set(only) if only else None
        found = set()
        i = 0
        while i < len(lines):
            lineno = i + 1
            line = strip_comment(lines[i]).strip()
            i += 1
            if not line:
                continue
            while line.endswith(("->", "<-")) and i < len(lines):
                line += " " + strip_comment(lines[i]).strip()
                i += 1
            toks = tokens(line)
            head = toks[0]
            try:
                if head == "def":
                    m = re.match(r"def\s+(\w+)", line)
                    name = m.group(1) if m else ""
                    prev = self.defs.get(name)
                    i = self.st_def(line, lines, i, path, 0)
                    if only is not None and name not in only:
                        if prev is None:        # filtered out: leave no trace
                            self.defs.pop(name, None)
                        else:
                            self.defs[name] = prev
                    else:
                        found.add(name)
                elif head == "defchip":
                    name = toks[1] if len(toks) > 1 else ""
                    prev = self.defchips.get(name)
                    i = self.st_defchip(toks[1:], lines, i, 0)
                    if only is not None and name not in only:
                        if prev is None:
                            self.defchips.pop(name, None)
                        else:
                            self.defchips[name] = prev
                    else:
                        found.add(name)
                elif head in ("import", "include"):
                    sub = os.path.join(os.path.dirname(path), unq(toks[1]))
                    self.import_file(
                        sub, toks[2:] or None if head == "import" else None)
                elif head in ("chip", "block"):
                    # skip the instance, but consume its pin rows if present
                    _s, i, _e = self._read_sides(lines, i, 0)
            except SchError as e:
                raise SchError(f"{path}:{lineno}: {e}") from None
        if only:
            missing = only - found
            if missing:
                raise SchError(f"import '{path}': no def/defchip named "
                               + ", ".join(sorted(missing)))

    def parse_lines(self, lines, fname, ns="", base_lineno=0):
        i = 0
        while i < len(lines):
            raw = lines[i]
            lineno = base_lineno + i + 1
            i += 1
            line = strip_comment(raw).strip()
            if not line:
                continue
            while line.endswith(("->", "<-")) and i < len(lines):   # continuation
                line += " " + strip_comment(lines[i]).strip()
                i += 1
            i_body = i
            snap = self._snap()
            try:
                i = self.statement(line, lines, i, fname, ns, base_lineno)
            except Unresolved as e:
                # not resolvable yet (forward reference / unplaced anchor):
                # roll back and retry after the rest of the file
                self._restore(snap)
                i = getattr(e, "next_i", i_body)
                self._deferred.append(
                    [fname, ns, lineno, line, lines[i_body:i], str(e)])
            except SchError as e:
                raise SchError(f"{fname}:{lineno}: {e}") from None

    # returns the (possibly advanced) next line index
    def statement(self, line, lines, i, fname, ns, base):
        toks = tokens(line)
        head = toks[0]
        if head == "wire":
            toks, head = toks[1:], toks[1] if len(toks) > 1 else ""
        if head == "sheet":
            self.st_sheet(toks[1:])
        elif head == "title":
            self.sheet.title = line.split(None, 1)[1] if " " in line else ""
        elif head == "note":
            self.sheet.notes.append(line.split(None, 1)[1] if " " in line else "")
        elif head == "net":
            self.st_net(toks[1:])
        elif head == "colornets":
            self.sheet.color_nets = True
        elif head == "escape":
            if len(toks) < 2 or not re.fullmatch(r"[\d.]+", toks[1]):
                raise SchError("usage: escape N   "
                               "(straight px out of every pin; 0 disables)")
            self.sheet.pin_stub = float(toks[1])
        elif head == "include":
            inc = os.path.join(os.path.dirname(fname), unq(toks[1]))
            self.parse_file(inc)
        elif head == "import":
            if len(toks) < 2:
                raise SchError('usage: import "file.sch" [NAME ...]')
            inc = os.path.join(os.path.dirname(fname), unq(toks[1]))
            self.import_file(inc, toks[2:] or None)
        elif head == "node":
            self.st_node(toks[1:], ns)
        elif head == "defchip":
            i = self.st_defchip(toks[1:], lines, i, base)
        elif head == "chip":
            i = self.st_chip(toks[1:], lines, i, ns, base)
        elif head == "block":
            i = self.st_block(toks[1:], lines, i, ns, base)
        elif head == "def":
            i = self.st_def(line, lines, i, fname, base)
        elif head == "use":
            self.st_use(toks[1:], fname, ns)
        elif head == "flow":
            self.path(toks[1:], ns, kind="flow")
        elif head in SYMBOLS:
            self.st_part(toks, ns)
        elif "->" in toks or "<-" in toks:
            self.path(toks, ns, kind="wire")
        else:
            raise SchError(f"unknown statement '{head}'")
        return i

    # ---------------- simple statements ----------------
    def st_sheet(self, toks):
        if toks and WXH.match(toks[0]):
            w, h = WXH.match(toks[0]).groups()
            self.sheet.w, self.sheet.h = float(w), float(h)
            self.sheet.auto_size = False
            toks = toks[1:]
        elif len(toks) >= 2 and XY.match(f"{toks[0]},{toks[1]}"):
            self.sheet.w, self.sheet.h = float(toks[0]), float(toks[1])
            self.sheet.auto_size = False
            toks = toks[2:]
        # no size given -> auto-size: content bbox + margins, drawing centred
        rest = []
        for t in toks:
            if t.startswith('"'):
                rest.append(unq(t))
            elif WXH.match(t):              # size may follow the title too
                w, h = WXH.match(t).groups()
                self.sheet.w, self.sheet.h = float(w), float(h)
                self.sheet.auto_size = False
            elif t in ("us", "ansi"):
                Part.STYLE = "us"
            elif t in ("iec", "din", "eu"):
                Part.STYLE = "iec"
            else:
                raise SchError(f"sheet: unknown option '{t}' "
                               f"(expected WxH, \"title\", us|iec)")
        if rest:
            self.sheet.title = rest[0]

    def st_net(self, toks):
        if not toks:
            raise SchError("net needs a name")
        name = toks[0]
        if "." in name and IDENT.match(name.split(".", 1)[0]):
            raise SchError(
                f"net name '{name}' looks like a pin 'REF.PIN': net names "
                f"double as path endpoint tokens and would shadow that pin; "
                f"to colour the net of a pin, put `color <col>` on a path "
                f"touching it (e.g. `A.p -> B.q color #e8412f`)")
        color = None
        disp = None
        for t in toks[1:]:
            if t.startswith('"'):
                disp = unq(t)
            else:
                color = t
        self.sheet.nets[name] = {"color": color, "disp": disp or name}

    def st_node(self, toks, ns):
        if len(toks) == 1:
            # bare declaration: bring the name into being HERE (unplaced),
            # so a `use` below can bind a group's node to it — inside a def
            # body an unknown bare name would otherwise be created inside
            # the instance namespace instead of joining this one
            name = (ns + "." if ns else "") + toks[0]
            self.sheet.nodes.setdefault(name, None)
            return
        if len(toks) < 3 or toks[1] != "at":
            raise SchError("usage: node NAME [at PLACE [+dx,dy]]")
        name = (ns + "." if ns else "") + toks[0]
        pt = self.place(toks[2:], ns)[0]
        if name in self.sheet.nodes and self.sheet.nodes[name] is not None:
            raise SchError(f"node '{toks[0]}' already placed")
        self.sheet.nodes[name] = pt

    @staticmethod
    def _place_used(toks):
        """how many tokens a PLACE consumes — must agree with place()"""
        return 2 if len(toks) > 1 and OFFSET.match(toks[1]) else 1

    def place(self, toks, ns):
        """PLACE [+dx,dy] -> ((x,y), tokens_consumed)"""
        if not toks:
            raise SchError("missing position after 'at'")
        t = toks[0]
        m = XY.match(t)
        if m:
            x, y = float(m.group(1)), float(m.group(2))
            self.sheet.has_abs = True
        elif "." in t:
            part, pin = self.sheet.pin_of(t, ns)
            if part.cx is None:
                raise Unresolved(f"'{part.ref}' has no position (yet)")
            x, y = part.pin(pin)
        else:
            p = self.sheet.find_part(t, ns)
            if p is None:
                nd = self.sheet.find_node(t, ns)
                if nd is None or self.sheet.nodes[nd] is None:
                    raise Unresolved(f"unknown place '{t}'")
                x, y = self.sheet.nodes[nd]
            else:
                if p.cx is None:
                    raise Unresolved(f"'{p.ref}' has no position (yet)")
                x, y = p.cx, p.cy
        used = 1
        if len(toks) > 1 and OFFSET.match(toks[1]):
            mo = OFFSET.match(toks[1])
            x, y = x + float(mo.group(1)), y + float(mo.group(2))
            used = 2
        return (x, y), used

    # ---------------- parts ----------------
    def st_part(self, toks, ns):
        typ = toks[0]
        if len(toks) < 2:
            raise SchError(f"{typ}: missing ref")
        ref = (ns + "." if ns else "") + toks[1]
        cls = SYMBOLS[typ]
        strings, words = [], []
        j = 2
        anchor_pin, pos, at_toks = None, None, None
        rot, mirror, lpos = 0, False, ""
        while j < len(toks):
            t = toks[j]
            if t.startswith('"'):
                strings.append(unq(t))
            elif t == "at":
                if words and words[-1] in cls("_probe").local_pins():
                    anchor_pin = words.pop()
                used = self._place_used(toks[j + 1:])
                at_toks = toks[j + 1:j + 1 + used]
                j += used
            elif t == "mirror":
                mirror = True
            elif t == "lpos" and j + 1 < len(toks):
                lpos = toks[j + 1]
                j += 1
            elif t in DIRS:
                rot = DIR_ROT[DIRS[t]]
            else:
                words.append(t)
            j += 1
        if at_toks is not None:
            pos = self.place(at_toks, ns)[0]
        label = strings[0] if strings else ""
        value = strings[1] if len(strings) > 1 else ""
        if value == "" and words and words[-1] not in cls("_probe").local_pins():
            value = words[-1]
        part = cls(ref, 0, 0, rot=rot, mirror=mirror,
                   label=label, value=value, lpos=lpos)
        if pos is None:
            part.cx = part.cy = None    # no `at`: placed by its first wired use
        elif anchor_pin:
            ox, oy = part.to_world(*part.local_pins()[anchor_pin])
            part.cx, part.cy = pos[0] - ox, pos[1] - oy
        else:
            part.cx, part.cy = pos
        self.sheet.add_part(part)
        # a standalone rail/gnd symbol IS a net terminal: tie it to its net
        # (label = net name; gnd defaults to GND) so net colouring and --nets
        # treat it exactly like a terminal dropped at the end of a path
        if isinstance(part, (Rail, Gnd)):
            netname = part.label or ("GND" if isinstance(part, Gnd) else "")
            if netname:
                net = self.sheet.nets.setdefault(
                    netname, {"color": None, "disp": netname})
                part.netname = netname
                if isinstance(part, Rail):
                    part.label = net["disp"]

    # ---------------- chip / block ----------------
    def _read_sides(self, lines, i, base):
        sides = {"left": [], "right": [], "top": [], "bottom": []}
        found = False
        while i < len(lines):
            pk = strip_comment(lines[i]).strip()
            if not pk:
                i += 1
                continue
            w = pk.split()
            if w[0] == "end":
                i += 1
                return sides, i, True
            if w[0] in sides:
                # several side lists may share one line: left A B right C D
                cur = None
                for t in w:
                    if t in sides:
                        cur = t
                    elif cur:
                        sides[cur].append(t)
                    else:
                        raise SchError(f"bad pin row '{pk}'")
                found = True
                i += 1
            else:
                break
        if found:
            raise SchError("pin rows must be closed with 'end'")
        return sides, i, False

    def _box_head(self, toks):
        """shared for chip/block: ref, strings, at-TOKENS (resolved later, so
        a deferred position still leaves the statement's extent known), WxH,
        flags"""
        ref = toks[0]
        strings, wxh, at_toks, flags, words = [], None, None, [], []
        j = 1
        while j < len(toks):
            t = toks[j]
            if t.startswith('"'):
                strings.append(unq(t))
            elif t == "at":
                used = self._place_used(toks[j + 1:])
                at_toks = toks[j + 1:j + 1 + used]
                j += used
            elif WXH.match(t):
                wxh = tuple(float(g) for g in WXH.match(t).groups())
            elif t == "accent":
                flags.append(t)
            else:
                words.append(t)
            j += 1
        return ref, strings, wxh, at_toks, flags, words

    def _box_place(self, at_toks, ns, next_i):
        """resolve a chip/block 'at' after its pin rows were consumed; a
        deferral carries next_i so the parser can skip the whole statement"""
        if at_toks is None:
            return None
        try:
            return self.place(at_toks, ns)[0]
        except Unresolved as e:
            e.next_i = next_i
            raise

    def st_chip(self, toks, lines, i, ns, base):
        ref, strings, wxh, at_toks, _fl, words = self._box_head(toks)
        proto = self.defchips.get(words[0]) if words else None
        # pin rows may follow even with a proto: an instance-level override
        # (same part, but this sheet's layout wants the pins on other sides)
        sides, i, ended = self._read_sides(lines, i, base)
        if proto is None and not ended:
            raise SchError(f"chip {ref}: needs a defchip name or pin rows + end")
        pos = self._box_place(at_toks, ns, i)
        if proto:
            w, h = wxh or (proto["w"], proto["h"])
            label = strings[0] if strings else proto["label"]
            sub = strings[1] if len(strings) > 1 else proto["sub"]
            if not ended:
                sides = proto["sides"]
        else:
            if wxh is None:
                raise SchError(f"chip {ref}: needs WxH")
            w, h = wxh
            label = strings[0] if strings else ref
            sub = strings[1] if len(strings) > 1 else ""
        p = Chip((ns + "." if ns else "") + ref, 0, 0,
                 w, h, label=label, sub=sub, sides=sides)
        if pos is None:
            p.cx = p.cy = None          # no `at`: placed by its first wired use
        else:
            p.cx, p.cy = pos
        self.sheet.add_part(p)
        return i

    def st_block(self, toks, lines, i, ns, base):
        ref, strings, wxh, at_toks, flags, _w = self._box_head(toks)
        sides, i, _ended = self._read_sides(lines, i, base)
        if wxh is None:
            raise SchError(f"block {ref}: needs WxH")
        pos = self._box_place(at_toks, ns, i)
        p = Block((ns + "." if ns else "") + ref, 0, 0, wxh[0], wxh[1],
                  label=strings[0] if strings else ref,
                  sub=strings[1] if len(strings) > 1 else "",
                  sides=sides, accent="accent" in flags)
        if pos is None:
            p.cx = p.cy = None          # no `at`: placed by its first wired use
        else:
            p.cx, p.cy = pos
        self.sheet.add_part(p)
        return i

    def st_defchip(self, toks, lines, i, base):
        name = toks[0]
        wxh = next((WXH.match(t) for t in toks[1:] if WXH.match(t)), None)
        if wxh is None:
            raise SchError(f"defchip {name}: needs WxH")
        strings = [unq(t) for t in toks[1:] if t.startswith('"')]
        sides, i, ended = self._read_sides(lines, i, base)
        if not ended:
            raise SchError(f"defchip {name}: missing pin rows / 'end'")
        self.defchips[name] = {"w": float(wxh.group(1)), "h": float(wxh.group(2)),
                               "label": strings[0] if strings else name,
                               "sub": strings[1] if len(strings) > 1 else "",
                               "sides": sides}
        return i

    # ---------------- def / use ----------------
    def st_def(self, line, lines, i, fname, base):
        m = re.match(r"def\s+(\w+)\s*\(([^)]*)\)\s*$", line)
        if not m:
            raise SchError("usage: def NAME(param, ...)")
        name = m.group(1)
        params = [p.strip() for p in m.group(2).split(",") if p.strip()]
        body, depth = [], 1
        while i < len(lines):
            raw = lines[i]
            pk = strip_comment(raw).strip()
            w = pk.split()
            i += 1
            if w and w[0] in ("def", "defchip"):
                depth += 1
            elif w and w[0] in ("chip", "block"):
                # opens a side block only if pin rows follow
                k = i
                while k < len(lines) and not strip_comment(lines[k]).strip():
                    k += 1
                nxt = strip_comment(lines[k]).strip().split() if k < len(lines) else []
                if nxt and nxt[0] in ("left", "right", "top", "bottom"):
                    depth += 1
            elif w and w[0] == "end":
                depth -= 1
                if depth == 0:
                    self.defs[name] = (params, body, fname, base + i)
                    return i
            body.append(raw)
        raise SchError(f"def {name}: missing 'end'")

    def st_use(self, toks, fname, ns):
        if len(toks) < 2:
            raise SchError("usage: use NAME INST(args)  or  use NAME INST at ARG")
        name = toks[0]
        if name not in self.defs:
            raise SchError(f"unknown def '{name}'")
        m = re.match(r"(\w+)\((.*)\)$", " ".join(toks[1:]))
        if m:
            inst, argstr = m.group(1), m.group(2)
        else:
            inst = toks[1]
            argstr = " ".join(toks[2:])
            if argstr.startswith("at "):
                argstr = argstr[3:]
            elif argstr:
                raise SchError("usage: use NAME INST(args)  or  use NAME INST at ARG")
        args = [a.strip() for a in argstr.split(",") if a.strip()]
        params, body, dfile, dline = self.defs[name]
        if len(args) != len(params):
            raise SchError(f"use {name}: expected {len(params)} arg(s) "
                           f"({', '.join(params)}), got {len(args)}")
        sub_lines = []
        for raw in body:
            line = raw
            for p, a in zip(params, args):
                line = re.sub(rf"(?<![\w.]){re.escape(p)}(?![\w])", a, line)
            sub_lines.append(line)
        new_ns = (ns + "." if ns else "") + inst
        self.parse_lines(sub_lines, f"{dfile}(use {inst})", ns=new_ns)

    # ---------------- paths ----------------
    def path(self, toks, ns, kind):
        items = []      # ('arrow',s)|('hint',dir,len)|('wp',pt)|('part',..)|('ep',tok)
        label, dashed, color = "", False, None
        j = 0
        while j < len(toks):
            t = toks[j]
            if t in ("->", "<-"):
                items.append(("arrow", t))
            elif t in DIRS:
                if j + 1 < len(toks) and re.fullmatch(r"-?[\d.]+", toks[j + 1]):
                    items.append(("hint", DIRS[t], float(toks[j + 1])))
                    j += 1
                elif j + 1 < len(toks) and toks[j + 1] == "to":
                    # aligned move: travel in DIR until level with PLACE ±N
                    if j + 2 >= len(toks):
                        raise SchError(f"'{t} to' needs a place")
                    pt, used = self.place(toks[j + 2:], ns)
                    j += 1 + used
                    off = 0.0
                    if j + 1 < len(toks) and re.fullmatch(r"[+-][\d.]+", toks[j + 1]):
                        off = float(toks[j + 1])
                        j += 1
                    items.append(("align", DIRS[t], pt, off))
                else:
                    items.append(("hint", DIRS[t], None))
            elif t.startswith("("):
                m = XY.match(t[1:-1].replace(" ", ""))
                if not m:
                    raise SchError(f"bad waypoint '{t}'")
                items.append(("wp", (float(m.group(1)), float(m.group(2)))))
                self.sheet.has_abs = True
            elif t.startswith("["):
                part_toks, entry = self._split_inline(t)
                at = None
                if j + 1 < len(toks) and toks[j + 1] == "at":
                    at, used = self.place(toks[j + 2:], ns)
                    j += 1 + used
                items.append(("part", part_toks, entry, at))
            elif t == "dash":
                dashed = True
            elif t == "color":
                if j + 1 >= len(toks):
                    raise SchError("color needs a value")
                color = unq(toks[j + 1])
                j += 1
            elif t.startswith('"'):
                label = unq(t)
            else:
                items.append(("ep", t))
            j += 1
        self._walk(items, ns, kind, label, dashed, color)

    @staticmethod
    def _split_inline(tok):
        entry = None
        if tok.endswith("]"):
            inner = tok[1:-1]
        else:
            inner, entry = tok.rsplit("].", 1)
            inner = inner[1:]
        return tokens(inner), entry

    @staticmethod
    def _align_pt(cur, d, pt, off):
        """target of an aligned move (`DIR to PLACE ±N`): cur shifted along
        axis d until level with pt; the stated direction must be honoured"""
        if d[0]:
            tgt, mv, axis = (pt[0] + off, cur[1]), pt[0] + off - cur[0], "x"
        else:
            tgt, mv, axis = (cur[0], pt[1] + off), pt[1] + off - cur[1], "y"
        if mv * (d[0] + d[1]) < 0:
            name = next(k for k, v in DIRS.items() if v == d)
            raise SchError(f"'{name} to' goes the wrong way: target {axis}="
                           f"{N(tgt[0] if d[0] else tgt[1])} but starting at "
                           f"{axis}={N(cur[0] if d[0] else cur[1])}")
        return tgt

    def _is_term(self, token):
        return (token == "gnd" or token in self.sheet.nets
                or (token.startswith(("+", "-")) and not IDENT.match(token))
                or bool(re.fullmatch(r"(?i)(GND|VSS)\w*", token)))

    def _endpoint(self, token, ns, make_nodes=True):
        """classify a bare path endpoint"""
        sh = self.sheet
        if self._is_term(token):
            return ("term", "GND" if token == "gnd" else token)
        nd = sh.find_node(token, ns)
        if nd is not None:
            return ("node", nd)
        if "." in token:
            part, pin = sh.pin_of(token, ns)
            return ("pin", part, pin)
        if IDENT.match(token):
            if not make_nodes:
                raise SchError(f"unknown endpoint '{token}'")
            name = (ns + "." if ns else "") + token
            sh.nodes.setdefault(name, None)
            return ("node", name)
        raise SchError(f"bad path element '{token}'")

    def _make_term(self, netname, pos):
        sh = self.sheet
        net = sh.nets.setdefault(netname, {"color": None, "disp": netname})
        if netname.upper().startswith(("GND", "VSS")):
            p = Gnd(sh.auto_ref("gnd"), pos[0], pos[1])
        else:
            p = Rail(sh.auto_ref("rail"), pos[0], pos[1], label=net["disp"])
        p.netname = netname
        sh.add_part(p)
        return p

    def _parse_inline(self, part_toks, entry, ns, kind):
        """parse an [inline part] token into a placement-ready spec"""
        if kind == "flow":
            raise SchError("inline parts are not allowed in flow paths")
        if not part_toks or part_toks[0] not in SYMBOLS:
            raise SchError(f"inline part needs a type: [{' '.join(part_toks)}]")
        typ = part_toks[0]
        cls = SYMBOLS[typ]
        if len(part_toks) < 2 or part_toks[1].startswith('"'):
            raise SchError(f"inline {typ}: needs a ref")
        ref = (ns + "." if ns else "") + part_toks[1]
        strings, rot, mirror, lpos, value_w = [], None, False, "", None
        k = 2
        while k < len(part_toks):
            t = part_toks[k]
            if t.startswith('"'):
                strings.append(unq(t))
            elif t == "mirror":
                mirror = True
            elif t == "lpos" and k + 1 < len(part_toks):
                lpos = part_toks[k + 1]
                k += 1
            elif t in DIRS:
                rot = DIR_ROT[DIRS[t]]
            else:
                value_w = t
            k += 1
        seq = cls.PINSEQ
        if not seq and entry is None:
            raise SchError(f"inline [{typ}]: name the entry pin ([...].PIN)")
        entry = entry or seq[0]
        if entry not in cls("_probe").local_pins():
            raise SchError(f"{typ}: no pin '{entry}'")
        return {"cls": cls, "typ": typ, "ref": ref, "entry": entry, "seq": seq,
                "rot": rot, "mirror": mirror, "lpos": lpos,
                "label": strings[0] if strings else "",
                "value": strings[1] if len(strings) > 1 else (value_w or "")}

    @staticmethod
    def _place_by_pin(part, pin, target):
        """translate a not-yet-placed standalone part so `pin` lands on
        target (declared orientation/mirror are kept)"""
        part.cx = part.cy = 0.0
        ox, oy = part.pin(pin)
        part.cx, part.cy = target[0] - ox, target[1] - oy

    def _pending_place(self, ent, target, away):
        """materialise one pending element: an inline spec (oriented along
        `away`) or a ('fixed', part, pin) standalone part (translated only)"""
        if isinstance(ent, tuple):
            _t, part, pin = ent
            self._place_by_pin(part, pin, target)
            return ("pin", part, pin)
        return ("part", *self._make_inline(ent, target, away))

    def _make_inline(self, spec, target, dirv):
        """create the part so its entry pin lands exactly on `target`;
        `dirv` orients two-terminal parts along the travel direction"""
        cls, entry, seq = spec["cls"], spec["entry"], spec["seq"]
        rot = spec["rot"]
        two_term = bool(seq) and entry in seq
        exitpin = None
        if two_term:
            exitpin = seq[1] if entry == seq[0] else seq[0]
            if rot is None:
                d = dirv or (1, 0)
                rot = DIR_ROT.get((round(d[0]), round(d[1])), 0)
                if entry != seq[0]:
                    rot = (rot + 180) % 360
        part = cls(spec["ref"], 0, 0, rot=(0 if rot is None else rot),
                   mirror=spec["mirror"], label=spec["label"],
                   value=spec["value"], lpos=spec["lpos"])
        ox, oy = part.to_world(*part.local_pins()[entry])
        part.cx, part.cy = target[0] - ox, target[1] - oy
        self.sheet.add_part(part)
        return part, entry, exitpin

    def _walk(self, items, ns, kind, label, dashed, color):
        """place inline parts / terminals / nodes in written order, then emit
        one Link per span between consecutive real elements"""
        sh = self.sheet
        # a path may start at a bare waypoint, or end in moves ("tap" idiom:
        # `Rsda.b -> down 68`); synthesize anonymous nodes for those ends
        real = [k for k, it in enumerate(items) if it[0] in ("ep", "part")]
        if not real or real[0] > 0:
            if not items or items[0][0] != "wp":
                raise SchError("a path cannot start with a bare move — "
                               "start at a pin, node, or (x,y) waypoint")
            name = sh.auto_ref("n")
            sh.nodes[name] = items[0][1]
            items[0] = ("ep", name)
            real = [k for k, it in enumerate(items) if it[0] in ("ep", "part")]
        if real[-1] < len(items) - 1:
            tail = [it for it in items[real[-1] + 1:] if it[0] != "arrow"]
            if not all(it[0] in ("wp", "align")
                       or (it[0] == "hint" and it[2] is not None)
                       for it in tail):
                raise SchError("a path cannot end on a length-less direction")
            name = sh.auto_ref("n")
            sh.nodes[name] = None
            items.append(("ep", name))
        real = [k for k, it in enumerate(items) if it[0] in ("ep", "part")]

        # a sheet needs no absolute anchor at all: when nothing in this path
        # has (or can get) a position, the statement is normally deferred and
        # retried later; only when the WHOLE file has stalled (`_seed_ok`) is
        # its first pin/node seeded at the origin — relative layout is all
        # that matters, auto-size / centring frames it afterwards
        def _known(it):
            if it[0] == "wp":
                return True
            if it[0] == "part":
                return it[3] is not None
            if it[0] != "ep":
                return False
            kl = self._endpoint(it[1], ns)
            if kl[0] == "pin":
                return kl[1].cx is not None
            if kl[0] == "node":
                return (sh.nodes.get(kl[1]) is not None
                        or bool(sh._node_anchors(kl[1])[0]))
            return False
        if not any(_known(it) for it in items):
            first = self._endpoint(items[real[0]][1], ns) \
                if items[real[0]][0] == "ep" else None
            if not self._seed_ok or first is None or first[0] == "term" \
                    or (first[0] == "node" and not self._seed_nodes):
                raise Unresolved("nothing in this path has a position yet")
            if first[0] == "pin":
                self._place_by_pin(first[1], first[2], self._seed_pt())
            else:
                sh.nodes[first[1]] = self._seed_pt()

        gaps = []                       # (arrow, mods) before real[k], k>=1
        for k in range(len(real) - 1):
            between = items[real[k] + 1:real[k + 1]]
            arrows = {it[1] for it in between if it[0] == "arrow"}
            if len(arrows) > 1:
                raise SchError("mixed -> and <- within one span")
            gaps.append((arrows.pop() if arrows else "->",
                         [it for it in between if it[0] != "arrow"]))

        def needs_pos(k):
            """does anything after real[k] (in a '->' span) require its point?"""
            if k >= len(real) - 1:
                return False
            arrow, mods = gaps[k]
            if arrow != "->":
                return False
            if any(m[0] == "align" or (m[0] == "hint" and m[2] is not None)
                   for m in mods):
                return True
            if any(m[0] == "wp" for m in mods):
                return False            # a waypoint re-anchors the cursor
            nxt = items[real[k + 1]]
            if nxt[0] == "part" and nxt[3] is None:
                return True
            if nxt[0] != "ep":
                return False
            if self._is_term(nxt[1]):
                return True
            kl = self._endpoint(nxt[1], ns)
            return kl[0] == "pin" and kl[1].cx is None   # unplaced part next

        cur, dirv, dirk = None, (1, 0), False   # dirk: dirv actually established
        info = {}                       # items index -> resolved element
        pending = {}                    # items index -> inline spec (placed later)
        for k, i0 in enumerate(real):
            it = items[i0]
            arrow = gaps[k - 1][0] if k else "->"
            mods = gaps[k - 1][1] if k else []
            had_exact = False
            if k and arrow == "->":
                for m in mods:
                    if m[0] == "hint":
                        dirv, dirk = m[1], True
                        if m[2] is not None and cur is not None:
                            cur = (cur[0] + m[1][0] * m[2], cur[1] + m[1][1] * m[2])
                            had_exact = True
                    elif m[0] == "align":
                        dirv, dirk = m[1], True
                        if cur is not None:
                            cur = self._align_pt(cur, m[1], m[2], m[3])
                            had_exact = True
                    else:               # waypoint
                        cur, had_exact = m[1], True
            elif k:
                cur, dirv, dirk, had_exact = None, (1, 0), False, False
                # '<-' starts a new run

            if it[0] == "part":
                spec = self._parse_inline(it[1], it[2], ns, kind)
                if it[3] is not None:                 # explicit `at`
                    target = it[3]
                elif cur is not None:
                    lead = 0 if had_exact else INLINE_LEAD
                    d = dirv or (1, 0)
                    target = (cur[0] + d[0] * lead, cur[1] + d[1] * lead)
                else:
                    # no forward cursor (line start / '<-' span): the part will
                    # be solved backward from its target once that is known
                    info[i0] = None
                    pending[i0] = spec
                    cur = None
                    continue
                part, entry, exitpin = self._make_inline(spec, target, dirv)
                info[i0] = ("part", part, entry, exitpin)
                if exitpin:
                    d = unit(part.pin(entry), part.pin(exitpin))
                    dirv = d or dirv
                    dirk = dirk or d is not None
                cur = part.pin(exitpin or entry)
                continue
            kl = self._endpoint(it[1], ns)
            if kl[0] == "term":
                if cur is None:
                    raise Unresolved(f"net terminal '{kl[1]}' needs a preceding "
                                     f"point — put it at the '->' end of the path")
                if had_exact:
                    pos = cur
                else:
                    down = kl[1].upper().startswith(("GND", "VSS"))
                    pos = (cur[0], cur[1] + (TERM_STUB if down else -TERM_STUB))
                part = self._make_term(kl[1], pos)
                info[i0] = ("pin", part, "p")
                cur, dirv = part.pin("p"), dirv
            elif kl[0] == "pin":
                _t, part, pin = kl
                if part.cx is None:            # declared without `at`
                    if cur is not None:
                        # place it like an inline part: the named pin lands
                        # on the cursor (exact hints) or a lead ahead of it.
                        # When the span never established a direction (a path
                        # starting at a node), the travel default must not
                        # decide — back the pin off along its own escape
                        # instead, the same rule the backward solver uses
                        # (`_RSDA -> Rsda.a` hangs a `down` part under the
                        # node rather than pushing it to the right)
                        lead = 0 if had_exact else INLINE_LEAD
                        d = dirv or (1, 0)
                        if not dirk:
                            e = part.pin_esc(pin)
                            if e:
                                d = (-e[0], -e[1])
                        self._place_by_pin(part, pin, (cur[0] + d[0] * lead,
                                                       cur[1] + d[1] * lead))
                    else:
                        info[i0] = None        # solve backward like a pending
                        pending[i0] = ("fixed", part, pin)   # inline part
                        cur = None
                        continue
                info[i0] = ("pin", part, pin)
                cur = part.pin(pin)
                esc = part.pin_esc(pin)
                dirv, dirk = esc or dirv, dirk or esc is not None
            else:                       # node
                name = kl[1]
                if sh.nodes.get(name) is None:
                    if had_exact and cur is not None:
                        sh.nodes[name] = cur      # pinned by exact moves
                    elif needs_pos(k):
                        # something after this node needs a point: resolve it
                        # now from the links recorded so far
                        if not sh.try_resolve_node(name, allow_single=True):
                            raise Unresolved(
                                f"node '{it[1]}' has no position yet — give it "
                                f"hints, `node {it[1]} at X,Y`, or wire it from "
                                f"a pin")
                info[i0] = ("nd", name)
                cur = sh.nodes.get(name)          # None while deferred

        if pending:
            self._resolve_pending(pending, info, real, gaps)

        for k in range(len(real) - 1):
            arrow, mods = gaps[k]
            ia, ib = real[k], real[k + 1]
            if arrow == "<-":
                ia, ib = ib, ia
                mods = list(reversed(mods))
            a = self._link_end(info[ia], as_source=True)
            b = self._link_end(info[ib], as_source=False)
            lm, curp = [], a.pt
            for m in mods:
                if m[0] == "hint" and m[2] is None:
                    lm.append(("dir", m[1]))
                    curp = None
                elif m[0] == "hint":
                    if curp is None:
                        raise Unresolved("an exact move cannot follow a length-"
                                         "less direction hint or an unplaced "
                                         "node")
                    curp = (curp[0] + m[1][0] * m[2], curp[1] + m[1][1] * m[2])
                    lm.append(("must", curp))
                elif m[0] == "align":
                    if curp is None:
                        raise Unresolved("an aligned move ('to') cannot follow "
                                         "a length-less direction hint or an "
                                         "unplaced node")
                    curp = self._align_pt(curp, m[1], m[2], m[3])
                    lm.append(("must", curp))
                else:
                    curp = m[1]
                    lm.append(("must", curp))
            sh.links.append(Link(a, b, lm, color=color, kind=kind,
                                 label=label, dashed=dashed))

    def _elem_pos(self, info, i0):
        """known position of a placed element (entry pin for parts), or None"""
        rec = info.get(i0)
        if rec is None:
            return None
        if rec[0] in ("part", "pin"):
            return rec[1].pin(rec[2])
        name = rec[1]
        if self.sheet.nodes.get(name) is None:
            self.sheet.try_resolve_node(name, allow_single=True)
        return self.sheet.nodes.get(name)

    def _elem_dir(self, info, i0):
        rec = info.get(i0)
        if rec is None:
            return None
        if rec[0] in ("part", "pin"):
            return rec[1].pin_esc(rec[2])
        _pts, dirs = self.sheet._node_anchors(rec[1])
        return next((d for d in dirs if d), None)

    def _resolve_pending(self, pending, info, real, gaps):
        """place inline parts that had no forward cursor, by solving backward
        from the known element they route to"""
        def spans_as_source(k):
            out = []
            if k < len(real) - 1 and gaps[k][0] == "->":
                out.append((real[k + 1], gaps[k][1]))
            if k > 0 and gaps[k - 1][0] == "<-":
                out.append((real[k - 1], list(reversed(gaps[k - 1][1]))))
            return out

        # exact hints back-solve: entry pin = target - sum(moves); the body
        # grows away from the target (axis = opposite of the travel direction)
        changed = True
        while changed and pending:
            changed = False
            for i0 in list(pending):
                k = real.index(i0)
                for tgt, mods in spans_as_source(k):
                    if not mods or not all(m[0] == "hint" and m[2] is not None
                                           for m in mods):
                        continue
                    tpos = self._elem_pos(info, tgt)
                    if tpos is None:
                        continue
                    dx = sum(m[1][0] * m[2] for m in mods)
                    dy = sum(m[1][1] * m[2] for m in mods)
                    away = (-mods[0][1][0], -mods[0][1][1])
                    info[i0] = self._pending_place(
                        pending.pop(i0), (tpos[0] - dx, tpos[1] - dy), away)
                    changed = True
                    break

        # hint-less parts meeting a known element: a PAIR spreads ±PAIR_SPREAD
        # perpendicular to the target's existing wire (first written = up/left);
        # a single part backs off along its entry pin's escape direction
        groups = {}
        for i0 in list(pending):
            for tgt, mods in spans_as_source(real.index(i0)):
                if not mods and self._elem_pos(info, tgt) is not None:
                    groups.setdefault(tgt, []).append(i0)
                    break
        for tgt, members in groups.items():
            tpos = self._elem_pos(info, tgt)
            d0 = self._elem_dir(info, tgt)
            perp = (1, 0) if (d0 and abs(d0[1]) > abs(d0[0])) else (0, 1)
            offs = (-PAIR_SPREAD, PAIR_SPREAD) if len(members) == 2 \
                else (None,) * len(members)
            for i0, off in zip(sorted(members), offs):
                ent = pending.pop(i0)
                if off is None:
                    if isinstance(ent, tuple):
                        esc = ent[1].pin_esc(ent[2]) or (-1, 0)
                    else:
                        probe = ent["cls"]("_probe", mirror=ent["mirror"],
                                           rot=(0 if ent["rot"] is None else ent["rot"]))
                        esc = probe.pin_esc(ent["entry"]) or (-1, 0)
                    target = (tpos[0] - esc[0] * INLINE_LEAD,
                              tpos[1] - esc[1] * INLINE_LEAD)
                    away = (-esc[0], -esc[1])
                else:
                    target = (tpos[0] + perp[0] * off, tpos[1] + perp[1] * off)
                    s = 1 if off < 0 else -1
                    away = (perp[0] * -s, perp[1] * -s)
                info[i0] = self._pending_place(ent, target, away)

        if pending:
            refs = ", ".join(e[1].ref if isinstance(e, tuple) else e["ref"]
                             for e in pending.values())
            raise Unresolved(
                f"cannot place part(s) {refs}: nothing known to place "
                f"them against — start the path at a placed pin, give the "
                f"part 'at', or route it to a known node (exact hints work "
                f"in reverse: [npn Q].B -> down 72 -> BASE)")

    def _link_end(self, rec, as_source):
        if rec[0] == "part":
            _t, part, entry, exitpin = rec
            pin = (exitpin or entry) if as_source else entry
            return EndPt(pt=part.pin(pin), esc=part.pin_esc(pin), part=part)
        if rec[0] == "pin":
            _t, part, pin = rec
            return EndPt(pt=part.pin(pin), esc=part.pin_esc(pin), part=part)
        name = rec[1]
        pos = self.sheet.nodes.get(name)
        return EndPt(pt=pos) if pos is not None else EndPt(node=name)


# ====================================================================== main
def build(path, color_nets=False):
    ps = Parser()
    ps.parse_file(path)
    sh = ps.sheet
    if color_nets:
        sh.color_nets = True
    sh.layout()
    return sh


# ================================================================== cleanup
# `--cleanup a.sch b.sch …` — try deleting every position / path-length
# parameter (an `at` clause, an `at` offset, an exact move, a bare direction
# element, an aligned-move offset) and keep each deletion ONLY if the
# rendered SVG of every given sheet stays byte-identical. Sheets that
# `include`/`import` an edited file are re-rendered too, so pass the whole
# family (e.g. *.sch) to protect defs used across files.

_CLEAN_SKIP = {"note", "sheet", "title", "defchip", "escape", "net",
               "colornets", "include", "import",
               "left", "right", "top", "bottom", "end"}
_DIRWORD = r"(?:up|down|left|right)"


def _clean_mask(line, brackets=False):
    """blank quoted strings, the comment tail and (optionally) inline-part
    [...] groups — keeping length — so regexes only see live geometry"""
    body = strip_comment(line)
    out, q, b = [], False, 0
    for ch in body:
        if q:
            out.append(" ")
            q = ch != '"'
        elif ch == '"':
            q = True
            out.append(" ")
        elif brackets and (b or ch == "["):
            b += (ch == "[") - (ch == "]")
            out.append(" ")
        else:
            out.append(ch)
    out.append(" " * (len(line) - len(body)))
    return "".join(out)


def _clean_splice(line, s, e):
    left, right = line[:s], line[e:]
    if left.rstrip() and right.lstrip():
        return left.rstrip() + " " + right.lstrip()
    return (left + right).rstrip()


def _clean_candidates(line):
    """yield (what, replacement) — one parameter removal each"""
    st = line.strip()
    if not st or st.startswith("#") or st.split()[0] in _CLEAN_SKIP:
        return
    mq = _clean_mask(line)
    mb = _clean_mask(line, brackets=True)
    # `at PLACE [+dx,dy]`: drop the whole clause; if offset, also just it
    for m in re.finditer(r"[ \t]+at[ \t]+(\(?-?[\d.]+,-?[\d.]+\)?|[\w.+/]+)"
                         r"([ \t]+[+-][\d.]+,[+-]?[\d.]+)?", mq):
        yield (line[m.start():m.end()].strip(),
               _clean_splice(line, m.start(), m.end()))
        if m.group(2):
            yield (line[m.start(2):m.end(2)].strip(),
                   _clean_splice(line, m.start(2), m.end(2)))
    # aligned move `DIR to PLACE ±N`: drop the trailing offset
    for m in re.finditer(r"\bto[ \t]+[\w.]+([ \t]+[+-][\d.]+)(?![\d.,])", mb):
        yield (line[m.start():m.end()].strip(),
               _clean_splice(line, m.start(1), m.end(1)))
    if "->" in mb or "<-" in mb:
        # whole exact-hint element `-> DIR N` (only mid-path)
        for m in re.finditer(rf"->[ \t]+{_DIRWORD}[ \t]+-?[\d.]+[ \t]*(?=->)", mb):
            yield (line[m.start():m.end()].strip(),
                   _clean_splice(line, m.start(), m.end()))
        # bare direction element `-> DIR ->`
        for m in re.finditer(rf"->[ \t]+{_DIRWORD}[ \t]*(?=->)", mb):
            yield (line[m.start():m.end()].strip(),
                   _clean_splice(line, m.start(), m.end()))
        # exact length only: `DIR N` -> `DIR` (direction constraint stays)
        for m in re.finditer(rf"\b{_DIRWORD}[ \t]+(-?[\d.]+)\b(?![.,\d])", mb):
            yield ("length of '" + line[m.start():m.end()].strip() + "'",
                   _clean_splice(line, m.start(1), m.end(1)))


def _clean_reads(path, seen=None):
    """every file `path` reads, transitively, via include/import"""
    seen = set() if seen is None else seen
    rp = os.path.realpath(path)
    if rp in seen:
        return seen
    seen.add(rp)
    try:
        with open(path) as f:
            lines = f.read().splitlines()
    except OSError:
        return seen
    for ln in lines:
        t = tokens(strip_comment(ln).strip())
        if len(t) > 1 and t[0] in ("include", "import"):
            _clean_reads(os.path.join(os.path.dirname(path), unq(t[1])), seen)
    return seen


def cleanup(paths):
    ref = {p: build(p).svg() for p in paths}       # must render to start with
    reads = {p: _clean_reads(p) for p in paths}
    removed = 0
    for p in paths:
        rp = os.path.realpath(p)
        affected = [q for q in paths if rp in reads[q]]
        lines = open(p).read().splitlines()

        def flush():
            with open(p, "w") as f:
                f.write("\n".join(lines) + "\n")

        try:
            for i in range(len(lines)):
                tried = set()
                while True:
                    for what, new in _clean_candidates(lines[i]):
                        if new == lines[i] or new in tried:
                            continue
                        old, lines[i] = lines[i], new
                        flush()
                        try:
                            same = all(build(q).svg() == ref[q]
                                       for q in affected)
                        except SchError:
                            same = False
                        if same:
                            print(f"{p}:{i + 1}: removed  {what}")
                            removed += 1
                            break               # rescan the shortened line
                        lines[i] = old
                        tried.add(new)
                    else:
                        break
        finally:
            flush()                             # never leave a trial on disk
    print(f"{removed} parameter(s) removed; all SVGs byte-identical"
          if removed else
          "nothing removable — every parameter changes a drawing")
    return 0


def main(argv):
    srcs, out, flags = [], None, set()
    it = iter(argv[1:])
    for a in it:
        if a == "-o":
            out = next(it, None)
            if out is None:
                print("error: -o needs a value", file=sys.stderr)
                return 1
        elif a.startswith("-"):
            flags.add(a)
        else:
            srcs.append(a)
    if not srcs:
        print(__doc__)
        return 1
    if "--cleanup" in flags:
        try:
            return cleanup(srcs)
        except SchError as e:
            print(f"error: {e}", file=sys.stderr)
            return 1
    color = "--color-nets" in flags or "--colors" in flags
    multi = len(srcs) > 1
    out_dir = out is not None and (os.path.isdir(out) or out.endswith(os.sep))
    if multi and out is not None and not out_dir:
        print("error: with several inputs -o must be a directory",
              file=sys.stderr)
        return 1
    rc = 0
    for src in srcs:
        stem = src[:-4] if src.endswith(".sch") else src
        name = os.path.basename(stem) + ("_nets.svg" if color else ".svg")
        if out is None:
            dst = os.path.join(os.path.dirname(stem), name)
        elif out_dir:
            dst = os.path.join(out, name)
        else:
            dst = out
        try:
            sh = build(src, color_nets=color)
        except SchError as e:
            print(f"error: {e}", file=sys.stderr)
            rc = 1
            continue
        if "--nets" in flags:       # print the electrical netlist, write nothing
            if multi:
                print(f"== {src}")
            sh.print_nets()
            continue
        try:
            with open(dst, "w") as f:
                f.write(sh.svg())
        except OSError as e:
            print(f"error: cannot write '{dst}': {e.strerror}", file=sys.stderr)
            rc = 1
            continue
        print(f"wrote {dst}  ({N(sh.w)}x{N(sh.h)}, {len(sh.parts)} parts, "
              f"{len(sh.wires)} wires, {len(sh.junctions())} junctions)")
    return rc


if __name__ == "__main__":
    sys.exit(main(sys.argv))
