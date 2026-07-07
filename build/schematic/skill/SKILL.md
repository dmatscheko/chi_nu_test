---
name: electronic-schematic
description: >-
  Generate real electronic schematic diagrams as SVG from a compact path-based
  text netlist, using the schematic.py engine bundled alongside this skill. It
  draws proper symbols in US/ANSI or IEC/European style (resistors, capacitors,
  pots, diodes/Schottky/zener/LED, BJTs, MOSFETs, op-amps, switches, batteries,
  crystals, piezos, chips with named pin rows, ground/power-rail terminals)
  with obstacle-avoiding orthogonal autorouting, automatic junction dots,
  auto-sized sheets, per-net colours, and a per-net colour debug mode. Also
  renders system block/flow diagrams with labelled signal-flow arrows. Use
  this whenever the user wants to create, draw, edit, lay out, or regenerate a
  circuit schematic, wiring diagram, electronics connection diagram, or signal
  block diagram — especially from a parts list, BOM, pin map, or netlist, or
  when working with `.sch` files. Strongly prefer this over hand-writing raw
  SVG for any circuit or wiring diagram: every path endpoint is a named pin,
  so the netlist mechanically guarantees that pins actually connect (it errors
  on a dangling reference).
---

# Electronic schematic generator

This skill drives `schematic.py`, a zero-dependency Python tool that turns a
path-based text netlist into a real schematic SVG. You write a `.sch` file —
wires as `->` paths with parts sitting inline on them — and the engine places
the symbols, autoroutes orthogonal wires around symbol bodies, and adds
junction dots.

**The engine lives one directory up from this skill.** Easiest — run it by its
absolute path (works from any cwd):

```
python3 /Users/dma/Eigenes/Test/oph/chi_nu_test/build/schematic/schematic.py IN.sch -o OUT.svg
```

Every mode accepts many `.sch` at once (`schematic.py *.sch`, `*.sch --nets`,
`*.sch --color-nets`, `--cleanup *.sch`); with several inputs `-o` must be a
directory (`*.sch -o ../`), and without `-o` each SVG lands next to its
source. One failing sheet doesn't stop the rest (exit 1 at the end).

If that path is wrong (the repo moved) or you want to be symlink-proof, derive
the engine from this skill's *real* location instead — let `SKILLDIR` be the
directory you read this SKILL.md from:

```
ENGINE="$(dirname "$(realpath "$SKILLDIR")")/schematic.py"
python3 "$ENGINE" IN.sch -o OUT.svg
```

The full language reference is `<engine-dir>/LANGUAGE.md`. Complete worked
examples to read before drawing anything non-trivial: `drive_stage.sch`
(inline parts, node meeting), `peak_detector.sch` (a bus with hanging parts;
its channel + bias divider live in relative-coordinate `def` groups),
`controller_power.sch` (power/I²C buses threaded through named `_` nodes),
`full_instrument.sch` (built entirely from `import`ed groups — drive buffer,
CD4066, detector channel ×3 — stamped with `def`/`use`),
`system_overview.sch` (block/flow diagram), and `examples/symbols_us.sch` /
`examples/symbols_iec.sch` (one of every symbol, in each style).

## Why this exists / when to reach for it

Hand-drawn SVG circuit diagrams drift out of sync and "connect" only by visual
coincidence. Here every path endpoint is a **named pin** (`Q1.E`, `ADS.AIN0`);
if a ref or pin doesn't exist the tool errors, so "do all the paths connect?"
is checked mechanically. Reach for this for any schematic, wiring diagram, or
labelled block diagram — not just when the user says the word "schematic".

## The core workflow (do this every time)

You cannot tell whether a schematic is good without looking at it. Overlapping
labels, a part auto-placed into a crowded corner, a ground hidden under the
notes box — none of these show up in the source. So:

1. **Write the `.sch`** (see below; copy structure from an example).
2. **Generate:** `python3 .../schematic.py foo.sch -o foo.svg`
3. **Render to PNG and actually view it:** `rsvg-convert foo.svg -o /tmp/foo.png -z 1.3`
   then open/read the image. (If `rsvg-convert` is missing, try `cairosvg` or
   any SVG→PNG path; viewing is non-negotiable.)
4. **Fix what you see and repeat.** Expect 2-4 passes. Typical fixes: a length
   hint to space parts out (`-> right 120 ->`), `lpos left`. With an auto-sized
   sheet (no `WxH`) the canvas, title row and notes box always fit themselves
   around the drawing — prefer that; only a fixed `sheet WxH` can clip.

The engine prints `(N parts, N wires, N junctions)` — a quick sanity check.

## The language in one screen

One statement per line; `#` starts a comment (`#rrggbb` colours are exempt).
Coordinates are SVG pixels, y downward. A line ending in `->`/`<-` continues.

```
sheet "Drive stage — push-pull buffer"        # no size -> AUTO-SIZE: canvas fits
                                              # the drawing + title + notes, centred
sheet 640x530 "Drive stage" iec               # fixed size; iec = European symbols
                                              # (rectangle res, filled inductor;
                                              # default us = ANSI zigzag)
net +5V #e8412f "+5 V"            # net colours ONCE; the display label is optional
net GND #2166ac
note free-text footnote (auto-wrapped); repeatable

port LEDC "LEDC GPIO2" "f_r square" at 120,250

# The route is the statement. Parts sit ON it; [type ref "label" "value"].
LEDC.p -> [res Rb "R_base" "1k"] -> BASE      # BASE = a named node
[npn Q1 "Q1" "S8050"].B -> BASE <- [pnp Q2 "Q2" "S8550"].B
                                              # pair-meet: two hint-less parts
                                              # converging on a node spread ±80
                                              # perpendicular to its wire
                                              # (first written = up/left);
                                              # or place precisely with hints:
                                              #   BASE -> up 72 -> [npn Q1].B
                                              #   [npn Q1].B -> down 72 -> BASE
Q1.C -> up 58 -> +5V                          # net terminal: rail flag + red net
Q2.C -> GND                                   # no hints → default stub, autoroute
Q1.E -> OUT <- Q2.E                           # two runs meet: OUT = midpoint + dot
OUT -> [res Rd "R_drive" "100 Ω"] -> [piezo RING "Ring 0"] -> down 90 -> GND

# Standalone parts: `at` is OPTIONAL — without it, a part (chip/block too) is
# placed by the first path that wires one of its pins, like an inline part;
# a sheet can have NO absolute coordinates at all (first pin seeds the origin,
# auto-size / centring provides the frame).
port GEN "Rigol GEN"                          # placed by its first wired use
res Rref "R_ref" "1 MΩ" a at RING.b +40,0 down    # or exact: pin a lands there
RING.b -> Rref.a
RING.a -> CH2.p                               # autoroutes around symbol bodies
rail F1 "+5V" at 300,80                       # standalone net terminals: label =
gnd  G1 at 300,400                            # net name; colours + --nets tie in

# Chips: rectangle + named pin rows (define reusable types with defchip+include)
chip ADS at 740,250 200x180 "ADS1015" "I²C 0x48"
  left  AIN0 AIN1 AIN2 AIN3
  right VDD SDA SCL
end
Rdis.a -> ADS.AIN0

# Buses & taps — PREFERRED: thread named _ nodes into the line with aligned
# moves (`DIR to PLACE ±N` = go DIR until level with PLACE on that axis),
# then connect by name. No coordinates, no measured distances, survives moves:
XIAO.GPIO6 -> right to Rsda.b -> _SDA -> ADS.SDA   # _SDA pinned under Rsda
Rsda.b -> _SDA                                     # the tap; autoroutes, dot
_3V3 -> right to XIAO.V3 -80 -> _V3 -> right 80 -> _END   # a threaded bus
_V3 -> XIAO.V3                                     # each drop = NODE -> PIN
# Node names: plain = signal, listed in --nets (BASE, OUT); leading _ = pure
# trace point, hidden from --nets and never mistaken for a part or net.
# Sketch fallback (joins by geometric coincidence — fine for quick work):
(382,85) -> (1250,85)                         # a bus at literal waypoints
Rsda.b -> down 68                             # tap DOWN onto a line below

# Repetition: define once, stamp many (refs become ch0.D, ch0.CH, node ch0.N)
def channel(hot, ring)
  hot -> down -> [piezo RNG ring "C0≈2 nF" lpos left] -> down 40 -> GND
  hot -> right 215 -> [schottky D "D" "1N5819"] -> right 72 -> down -> [cap CH "C_hold" "1 nF"] -> down 46 -> GND
end
use channel ch0(H0, "Ring 0")                 # or: use channel ch0 at H0
node H0 at SW.OUTA +120,0                     # pin a node explicitly when needed

# Block / flow diagrams (system pictures, not circuits)
block XIAO "Xiao ESP32-C6" "line1|line2" at 500,100 200x96 accent
  bottom DRIVE RESET I2C                      # named invisible taps on an edge
end
flow POWER.e -> XIAO.w "3.3 V"                # arrow + label
flow XIAO.DRIVE -> down -> BUF.e "DRIVE" dash # dashed = control; hint steers route
```

**Placement & routing rules (the heart of it):**
- With **no hints**, everything is automatic: inline parts advance ~44 px along
  the route direction; connections route straight/L/Z around symbol bodies.
- **Standalone parts/chips/blocks without `at`** are placed by the first path
  that wires one of their pins (forward from the cursor, or solved backward
  from the known end). **Statement order is free**: anything that cannot
  resolve yet — a part defined further down, an `at` anchor still unplaced —
  is retried after the whole file is read. Only circular positions, refs that
  never exist, or a part related to nothing fail the build.
- **Exact hints** (`right 120`, `down 28`, `(x,y)` waypoints, aligned moves
  `right to PLACE ±N`) are literal — the router never second-guesses them. An
  inline part right after an exact hint sits exactly at the hinted point (no
  lead). The aligned move is the exact hint that needs no numbers: it stops
  level with another element on one axis only.
- **Direction-only hints** (`-> down ->`) steer both the router's first move
  and an inline part's orientation, and leave lengths automatic.
- A **node** pins down: by exact hints (`-> down 28 -> OUT`), by statement
  (`node OUT at X,Y`), by meeting (`A -> OUT <- B` = midpoint — a further
  anchor dropping perpendicularly onto the A–B line pins the free coordinate
  so its tap lands straight), or lazily — the first time a later statement
  needs its position (single anchor + 40 px).
- Two-terminal parts enter at `a` (anode) and exit at `b`/`k`; append `.k` /
  `.b` to enter from the cathode side. 3+ pin parts (`[npn Q].B`) must name
  the entry pin and end the path — continue from their other pins in new paths.

**Pin names:** `res cap cap_pol inductor piezo xtal switch button`: `a b` ·
`pot`: `a b w` · `diode schottky zener led`: `a k` · `npn`: `B C E` · `pnp`:
`B E C` · `nmos`/`pmos`: `G D S` · `opamp`: `in+ in- out vcc vee` · `battery`:
`+ -` · `gnd rail port testpoint`: `p` · `chip`/`block`: as declared (`block`
also `n s e w c`). Orientation words `up/down/left/right` set a part's a→b
axis (`down` = vertical, a on top); `mirror` flips; `lpos up|down|left|right`
moves the label.

## Conventions that make the difference between clean and tangled

- **Give each part room; lay out in zones.** Power on one side, controller in
  the middle, I/O on the other. If lines tangle, the fix is almost always
  "spread parts out" — add `-> right N ->` spacing hints or `at` anchors, not
  clever routing (an auto-sized sheet grows with you). `controller_power.sch`
  is a three-zone example.
- **Let terminals do the rails.** `X -> GND` / `X -> +5V` drops the symbol,
  wires it, and colours the whole net from the single `net` declaration; a
  standalone `rail F1 "+5V" at …` / `gnd G1 at …` is the same terminal placed
  by hand. Never put colours on individual wires except for special nets
  (`color #7a4b1e` as a trailing path attribute).
- **Different signals need different connection points.** A block edge pin is
  ONE electrical node. When several nets leave the same edge, declare named
  pins on that side (`bottom DRIVE RESET I2C`) and route to `XIAO.DRIVE` etc.
  — distinct, engine-checked taps.
- **Buses are lines threaded through named `_` nodes; taps connect by name.**
  Pin a node over each consumer with an aligned move (`-> right to PIN -80 ->
  _V3 ->`), then each drop is `_V3 -> PIN` — no coordinates, no distances, and
  moving a part moves its tap. A wire crossing without an endpoint stays a
  no-connect (no dot). To make a corner read as a bus-with-tap, overshoot the
  bus a little past the last tap (`-> right 80 -> _END`). Leading-waypoint
  buses and distance taps (`Rsda.b -> down 68`) still work as a quick sketch —
  they join by geometric coincidence.
- **Place by anchor, not by pixel.** `at REF.PIN +dx,dy` (or `PIN at` to land
  a specific pin) keeps groups rigid when you nudge the anchor. Zero absolute
  seeds is fine (the first wired pin seeds the origin); use at most one or two
  when you want explicit control.
- **Junction dots are automatic and meaningful.** A dot appears where ≥3
  conductor directions meet (component pin leads count). No dot on plain
  crossings — standard no-connect convention.
- **Chips: pick heights for round pin pitch.** A side with k pins on height H
  spaces them H/(k+1) apart; choose H so taps land on integers.
- **Leave space below the lowest part for the notes box**, and check labels
  with your eyes; `lpos` fixes collisions.
- **Repeat = `def`/`use`; reuse across sheets = `import`.** Any repeated
  sub-circuit (a detector channel, a filter pole) should be one `def`, stamped
  with `use NAME inst(args)`. Instance refs are addressable from outside
  (`ch0.RDS.a -> ADS.AIN0`). Keep def bodies *relative* (offsets from a
  parameter, e.g. `at hot +350,-10` — never absolute coordinates, or every
  stamp lands on one spot); then a detail sheet that defines the group and
  `use`s it once still renders standalone, and another sheet pulls the same
  circuit in with `import "file.sch" [NAME …]` — definitions only, the
  imported sheet's own drawing is skipped. To bind a group node to a caller
  node passed as an argument, the caller's node must already exist — declare
  it bare (`node OUT`) before the `use` if nothing placed it yet. A `chip`
  instance of a `defchip` may restate pin rows to re-side the pins for this
  sheet's layout (same part, controls moved to the top, say).

## Colouring nets

- **Meaningful colours:** declare once — `net GND #2166ac`, `net +5V #e8412f
  "+5 V"` — and just end paths at `GND`/`+5V`. A whole connected net takes the
  colour of the terminal it touches. For a coloured net without a terminal,
  put `color #hex` at the end of one of its paths.
- **Debug view:** `--color-nets` gives every electrical net a distinct colour
  and overrides everything — one net in two colours = broken; two nets sharing
  a colour = accidental short. It writes `foo_nets.svg` (never clobbers).
  There's also a `colornets` in-file directive.
- **Netlist print:** `--nets` prints each electrical net as one sorted line of
  members and writes nothing. It is layout-independent, so it is THE tool for
  re-layout work: capture it before, `diff` after — any change means you
  altered the circuit, not just the drawing. Do this after every re-layout.

## Editing existing diagrams

If `.sch` sources exist, edit those and regenerate — never hand-edit the SVG.
A `Makefile` usually sits next to the sources (`make` = all canonical SVGs,
`make nets` = debug views, `make png` = PNG previews, `make cleanup` =
minimize sources). The `.sch` files are the source of truth; `v1/` (if
present) is the frozen pre-rewrite backup.

After a layout settles, `python3 schematic.py --cleanup *.sch` rewrites the
sources dropping every position/length parameter whose removal keeps ALL the
SVGs byte-identical (importers of an edited file are re-rendered too — so
always pass the whole family, and expect it to take a minute). What remains
is exactly the load-bearing set; run it before committing a big re-layout.

## Adding a new symbol (engine internals)

Most "I need a part with pins" cases are covered by `chip` / `defchip` /
`block` — no code change. For a genuinely new *symbol*, subclass `Part` in
`schematic.py` and register it in the `SYMBOLS` dict:

- `local_pins() -> {name: (x, y)}` — pin coords in the local frame (this IS
  the connectivity model).
- `ESC = {name: (dx, dy)}` — outward pin normals; the router uses them to
  leave/enter sensibly, terminals to pick their stub direction.
- `BODY = (x0, y0, x1, y1)` — the obstacle box (body only, leads excluded).
- `PINSEQ = ("a", "b")` — entry/exit pins for inline path placement (omit for
  parts that must end a path).
- `body() -> str` — the SVG, local coords; the base class transforms it.

Two-terminal parts subclass `TwoTerm` and mostly just set `SPAN`, `BODY`, and
`body()`. After any engine change: rebuild all sheets, view them, and run
`--color-nets` to confirm no accidental shorts.

## Common gotchas

- Unknown ref/pin → clear error with the pin list. That's the connectivity
  check working; fix the reference. Declaration order doesn't matter for
  parts/positions — but `defchip`/`def` definitions and `include`s/`import`s
  must precede their instantiation.
- A path cannot *start* at a net terminal or a bare move; start at a pin,
  node, waypoint — or an inline part that routes to something known (it is
  then solved backward; see the pair-meet idiom above).
- An exact move can't follow a length-less direction hint (`-> up -> right 40`
  is ambiguous — give `up` a length).
- A node used before anything anchors it errors — wire it from a pin first,
  give it hints, or `node NAME at X,Y`.
- Auto-placement doesn't avoid collisions; it advances blindly along the
  route. If a part lands in a crowd, add a length hint or `at`.
- Pin coordinates are world coordinates after orientation/mirror. When in
  doubt where a rotated part's `a` ended up, render and look.
