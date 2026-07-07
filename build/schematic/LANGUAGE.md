# The `.sch` path language (v2)

One statement per line, `#` starts a comment (except inside quotes), blank
lines ignored. A line ending in `->` or `<-` continues on the next line.

The core idea: **the route is the statement.** You draw wires as paths, and
parts sit inline *on* the paths. Everything can be pinned down manually
(`at`, `up 40`, waypoints) — but nothing has to be: with no hints, placement
advances along the path and the router finds a clear Manhattan route
automatically. Junction dots and connectivity checking are automatic; an
unknown ref or pin fails the build.

```
sheet "Drive stage — push-pull buffer"      # no size: auto-sizes around content
net +5V #e8412f
net GND #2166ac

port LEDC "LEDC GPIO2"                      # no `at`: placed by its first use

LEDC.p -> [res Rb "R_base" 1k] -> BASE      # parts live ON the route
BASE -> up 72 -> [npn Q1 "S8050"].B         # hint steers route & placement…
BASE -> [pnp Q2 "S8550"].B at Rb.b +64,72   # …or pin the part manually…
Q1.C -> +5V                                 # …or no hints at all: autoroute
Q2.C -> GND
Q1.E -> OUT <- Q2.E                         # two paths meet: node OUT + dot
OUT -> [res Rd "100 Ω"] -> [piezo RING "Ring 0"] -> GND
```

## Sheet & nets

| Statement | Meaning |
|---|---|
| `sheet [WxH] ["title"] [us\|iec]` | canvas size (px), optional title, optional **symbol style**: `us` (ANSI, default — zigzag resistor) or `iec` (European — rectangle resistor, filled inductor; aliases `ansi` / `din`, `eu`). **With no size the sheet auto-sizes**: bounding box of everything drawn + a margin, plus header room for the title and a footer for the notes; the drawing is centred in that area no matter where its coordinates live. A **fixed-size** sheet whose content uses no absolute coordinates anywhere likewise centres the drawing in the given canvas |
| `title text…` | set/override the title |
| `note text…` | footnote, word-wrapped at the bottom (repeatable) |
| `net NAME #rrggbb` | declare a net name + colour (e.g. `+5V`, `GND`, `+3.3V`) |
| `escape N` | straight run forced out of every pin before the first bend (default 10; 0 disables) |
| `include "file.sch"` | read another file in place (shared `defchip`/`def` libraries) |
| `import "file.sch" [NAME …]` | read another file but keep **only its `def`/`defchip` definitions** — the sheet itself (canvas, parts, wires, notes) is skipped. Optional names select just those definitions (error if one is missing). Any detail sheet thus doubles as a library of its groups: `full_instrument.sch` imports `drive_buffer` from `drive_stage.sch` and `rx_channel`/`vbias` from `peak_detector.sch` |
| `colornets` | debug: distinct colour per electrical net (also CLI `--color-nets`) |

A **terminal** is a net name used as the last element of a path: `Q2.C -> GND`
drops a ground symbol below `Q2.C` and wires to it; `Q1.C -> +5V` raises a
rail flag. Names starting with `GND`/`VSS` (any case, declared or not) draw
the ground symbol; `+…`/`-…` names and declared net names draw a rail flag
labelled with the net's display string (`net +5V #e8412f "+5 V"`). With no
hints the symbol sits a default stub below (ground) or above (rail) the
previous point; exact hints place it exactly (`-> up 58 -> +5V`). Every
wire-net touching a terminal takes that net's colour — declared once, never
per wire.

Terminals also exist as **standalone symbols**: `rail F1 "+5V" at 300,80` and
`gnd G1 at 300,400` place the same flags anywhere. The label is the *net
name* — the flag shows the net's display text (`"+5 V"`), joins its colour,
and counts as a `<NET>` member in `--nets`, exactly like a path terminal
(`gnd` defaults to net `GND`). Wire to their `p` pin like any other part.

## Paths (wires)

```
ELEM -> ELEM -> … [color #rrggbb]
```

`->` and `<-` connect neighbouring elements (`A <- B` = `B -> A`; useful to
make two runs meet in the middle: `Q1.E -> OUT <- Q2.E`). Elements:

| Element | Meaning |
|---|---|
| `REF.PIN` | a pin of an already-defined part / chip / block |
| `NAME` | a **node** — a named electrical point (see below) |
| `+5V`, `GND`, … | a terminal of a declared net |
| `(X,Y)` | absolute waypoint |
| `up N` `down N` `left N` `right N` | exact relative move of N px |
| `up` `down` `left` `right` (no N) | direction constraint — the router picks the length |
| `DIR to PLACE [±N]` | **aligned move** — go `DIR` until level with `PLACE` on that axis only, `±N` beyond |
| `[TYPE REF "label" "value" …]` | an **inline part** placed on the route |

With no hints between two known points, the route is automatic: straight if
possible, else an L / Z around symbol bodies. Hints override exactly where
given — **exact moves and waypoints are literal** (the router never reroutes
between them; only the unhinted remainder of a run autoroutes). Autorouted
wires leave and enter every pin with a short straight run along the pin's own
direction (10 px; `escape N` changes it, `escape 0` disables) whenever the run
continues to that side of the pin — explicit moves override, and a wire never
doubles back through its pin just to satisfy the rule. Plain crossings carry
no dot (no-connect); dots appear only where ≥3 conductor directions meet.

The leading `wire` keyword is optional. Two bus/tap idioms fall out of the
rules: a path may *start at a bare waypoint* (`(382,85) -> (1250,85)` — a
bus), and it may *end in exact moves* (`Rsda.b -> down 68` — a tap dropped
onto whatever runs below; the landing point becomes an anonymous node). A
tap whose endpoint lands on another wire joins its net (junction dot); mere
crossings stay separate. Both idioms join by *geometric coincidence* — keep
them for quick sketches, and prefer **named `_` nodes threaded into the
line** (see Nodes below), which say the same thing with no coordinates and
no measured distances.

The **aligned move** writes such positions relative to another element in
*one* axis only: `Ra.b -> right to XIAO.V5 +50` goes straight right and stops
level with `XIAO.V5` plus 50 on x — the y never changes, so it usually does
*not* hit `XIAO.V5` (that is the point). `PLACE` is anything `at` accepts; a
lone `±N` shifts along the axis of travel (`±dx,dy` after the place also
works). The build fails if the place lies opposite the stated direction, and
an aligned move may end a path like any exact tap.

### Inline parts

`[res Rb "R_base" "1k"]` places the part on the route: entry pin ~40 px ahead
of the current point, oriented along the route direction. Options inside the
brackets: `mirror`, an orientation word, `lpos up|down|left|right` (label
side), and `PIN at PLACE [±dx,dy]` to pin it manually. Two-terminal parts are
entered at `a` (anode) and left at `b` (cathode) — append `.k`/`.b` to enter
from the other side: `-> [schottky D].k ->`. Parts with 3+ pins must name the
entry pin (`[npn Q1].B`) and end the path; continue from their other pins in
new paths (`Q1.C -> +5V`).

A part may also sit at the **start** of a path (or arrive via `<-`) — it is
then solved *backward* from the known element it routes to:

```
[npn Q1 "S8050"].B -> down 72 -> BASE     # B exactly 72 above BASE
[npn Q1 "S8050"].B -> BASE <- [pnp Q2 "S8550"].B   # the pair-meet idiom
```

Exact hints are applied in reverse (entry pin = target − moves; the body
grows away from the target). With **no hints**, a *pair* meeting one element
from a single line spreads ±80 perpendicular to that element's existing wire
(first written = up/left — the totem-pole idiom above is exactly the drive
stage); a *single* hint-less part backs off ~44 px along its entry pin's
escape direction. Anything less determined than that is an error — add a
hint or `at`.

### Nodes

A bare name is a node. It gets its position from the first place that implies
one: after an exact move (`A -> down 28 -> OUT` pins `OUT` 28 below `A`), by
explicit statement (`node OUT at 320,235`), or — if used between known
endpoints — the midpoint (`Q1.E -> OUT <- Q2.E`). A lone `node OUT` (no `at`)
*declares* the node here, unplaced — needed when a `use` below should bind a
group-internal name to this sheet's node: name lookup inside a `def` body
walks outward through the instance namespaces, but only finds names that
already exist (see `def`/`use`). A node still unplaced when
a *later* statement needs its position resolves right then from the links
recorded so far (two anchors → midpoint — but a further anchor that drops
perpendicularly onto the line between them, e.g. a pull-up onto a bus, pins
the free coordinate instead, so its tap lands dead straight; one anchor →
40 px along its outgoing direction). Reference it from any later path
(`OUT -> [res Rd] -> …`).

**Naming convention — leading `_` marks a pure trace point.** The tool names
its own anonymous nodes `_n1`, `_n2`, … and `--nets` hides every node whose
name starts with `_` (also inside `use` instances). Follow the same rule: a
node that *is* a circuit signal gets a plain name and shows up in the netlist
(`BASE`, `OUT`, `H1`); a node that only exists so a trace point can be named —
a bus anchor, the spot where a tap meets a line — gets a leading underscore
(`_SDA`, `_V3`, `_5V`). An `_` name can never collide with a net terminal
(`GND…`/`VSS…`/`+…`/`-…` detection never matches it) and is instantly
distinguishable from part refs in a path.

**Prefer threading named nodes over coordinate joins.** Instead of a bus at
absolute coordinates plus taps that hit it by measured distances, pin the
node into the line with an aligned move and connect to it by name — the tap
then autoroutes, and nothing breaks when a part moves:

```
XIAO.GPIO6 -> right to Rsda.b -> _SDA -> ADS.SDA   # node exactly under Rsda
Rsda.b -> _SDA                                     # tap: no distance needed
```

## Standalone parts

```
TYPE REF ["label" ["value"]] [[PIN] at PLACE [±dx,dy]] [orient] [mirror] [lpos DIR]
```

`PLACE` is `X,Y`, `REF` (that part's centre) or `REF.PIN`; the optional
`±dx,dy` shifts from there. With a leading `PIN`, the *pin* (not the centre)
lands on the spot — no half-symbol arithmetic:

```
res Rref "R_ref" "1 MΩ" a at RING.b +40,0 down   # pin a exactly 40 right of RING.b
```

`orient` = `up down left right`: the direction the part's a→b axis points
(default `right`). `mirror` flips the symbol; `lpos` forces the label side.

**`at` is optional — and resolution is order-free.** A part declared without
`at` is placed by the first path that wires one of its pins — exactly like an
inline part: after exact moves the pin lands on the hinted point, hint-less
it lands a 40 px lead ahead of the cursor, and at a path start it is solved
backward from the known element (declared orientation is kept; only the
position is derived). Statements need not appear in dependency order: one
whose references cannot resolve *yet* — a part defined further down, an `at`
anchor that is still unplaced — is rolled back and retried after the rest of
the file has been read, until everything settles. If nothing in the whole
sheet is absolutely anchored, one element gets seeded at the origin (a
part-pin path first, else a bare-node path, else a lone part): **a sheet
needs no absolute coordinates at all** — only relative layout matters, and
the frame comes from auto-size or centring. Only genuinely unresolvable
sheets fail: circular `at` chains, references that never exist, or a part
related to nothing (never wired, never placed, never used as an anchor).
The one ordering rule that remains: `defchip` / `def` definitions and
`include`s / `import`s must appear before they are instantiated.

## Chips & blocks

```
defchip CD4066 240x320 "CD4066" "quad bilateral switch"   # reusable type
  left   INA INB INC
  right  OUTA OUTB OUTC
  top    VDD
  bottom CTLA CTLB CTLC VSS
end

chip SW CD4066 at 480,350            # instance of the defchip
chip ADS at 740,250 200x150 "ADS1015" "I²C 0x48"          # or inline, anonymous
  left  AIN0 AIN1 AIN2 AIN3
  right VDD SDA SCL
end
```

Pins spread evenly along their side and get an 18 px stub + name. `defchip`s
belong in a shared file pulled in with `include` (or picked out of another
sheet with `import`); an instance may override the type's size
(`chip SW CD4066 at 480,350 200x280`) and label strings — and, by giving its
own pin rows, the **pin sides** (same part, but this sheet's layout wants the
controls on top):

```
chip SW CD4066 at 480,350        # instance-level pin-row override
  left   INA INB INC
  right  OUTA OUTB OUTC
  top    VDD CTLA CTLB CTLC
  bottom VSS
end
```
`at` is optional for chips and blocks too — `chip T1 NE555` is placed by the
first path that wires one of its pins, same rules as standalone parts.
Labels and values on any part may be quoted strings; a lone unquoted word
also works as the value (`[res Rb "R_base" 1k]`).

`block` is the same shape for **system/flow diagrams** (rounded, label text
inside, `|` breaks lines, `accent` tints it). Blocks always expose `n s e w c`
plus any declared side pins (invisible taps):

```
block XIAO "Xiao ESP32-C6" "runs ESPHome" at 790,210 250x170 accent
  bottom DRIVE SEL RESET I2C
end
flow XIAO.DRIVE -> BUF.n "DRIVE (GPIO2)" dash
```

`flow` is a path drawn as an arrow (for block diagrams): same elements as a
wire, plus a trailing `"label"` and optional `dash`. Arrows leave/enter block
edges perpendicularly.

## Blocks of circuitry: `def` / `use`

```
def channel(hot)                     # parameters are substituted textually
  hot -> [schottky D "1N5819"] -> N
  N -> down 40 -> [cap Ch "1 nF"] -> GND
end

use channel ch0 at SW.OUTA           # 1-arg sugar; == use channel ch0(SW.OUTA)
use channel ch1(SW.OUTB)
```

Everything defined inside gets the instance prefix: parts `ch0.D`, `ch0.Ch`,
node `ch0.N` — so instances never collide and stay addressable from outside.
Name lookup inside a body walks outward (`ch0.N` first, then `N`), so an
argument can hand the body an outer node — declare it first (`node OUT`,
bare) if no earlier statement created it, or the body will mint its own
`ch0.OUT` instead.

**Groups — one circuit, drawn in its sheet AND reused elsewhere.** Put the
sub-circuit in a `def`, stamp it locally with `use`, and keep everything in
the body *relative* (offsets from a parameter like `at hot +350,-10`, exact
moves, pair-meets — no absolute coordinates, or every stamp lands on the same
spot). The detail sheet renders exactly as before, and any other sheet pulls
the group in with `import`:

```
# peak_detector.sch                       # full_instrument.sch
def rx_channel(hot, ring, vb)             import "peak_detector.sch" rx_channel vbias
  hot -> [piezo RNG ring] at hot -> GND   use vbias BIAS(VB)
  …                                       use rx_channel ch0(H0, "Ring 0", VB)
end                                       use rx_channel ch1(H1, "Ring 1", VB)
node H at 150,200                         use rx_channel ch2(H2, "Ring 2", VB)
use rx_channel CH(H, "RX ring", VB)
```

## Symbol kit

Two drawing styles, chosen on the `sheet` line: `us` (ANSI, default) draws
the zigzag resistor and hump inductor; `iec` draws the IEC 60617 rectangle
resistor (pot follows) and filled-bar inductor. Everything else — and all
pins, spans and routing — is identical in both. Galleries:
`examples/symbols_us.sch` / `examples/symbols_iec.sch`.

| Type | Pins | Notes |
|---|---|---|
| `res` `cap` `inductor` `piezo` `xtal` | `a b` | two-terminal |
| `cap_pol` | `a b` (`+`=`a` `-`=`b`) | polarised, `+` marked |
| `pot` | `a b w` | wiper `w` perpendicular |
| `diode` `schottky` `zener` `led` | `a k` | anode → cathode |
| `npn` | `B C E` | base left, collector up |
| `pnp` | `B E C` | base left, emitter up (totem-pole ready) |
| `nmos` `pmos` | `G D S` | gate left |
| `opamp` | `in+ in- out vcc vee` | |
| `switch` `button` | `a b` | SPST / momentary |
| `battery` | `+ -` (`a`/`b` aliases) | |
| `gnd` | `p` | standalone ground terminal (net from label, default `GND`) |
| `rail` | `p` | standalone rail terminal (label = net name, shows its display text) |
| `port` | `p` | labelled net stub (GPIO, probe, …) |
| `testpoint` | `p` | small ring + label |
| `chip` / `block` | as declared | + `n s e w c` on blocks |

## CLI

```
python3 schematic.py board.sch                 # -> board.svg
python3 schematic.py *.sch                     # any number at once
python3 schematic.py board.sch -o ../board.svg # explicit name (one input)
python3 schematic.py *.sch -o ../              # -o DIR: write them all there
python3 schematic.py *.sch --color-nets        # -> *_nets.svg (debug)
python3 schematic.py *.sch --nets              # print netlists (== headers)
python3 schematic.py --cleanup *.sch           # rewrite the .sch in place:
                                               # drop dead position/length params
```

Every mode takes any number of `.sch` files. With several inputs `-o` must
name a directory; without `-o` each SVG lands next to its source. A sheet
that fails is reported and the rest still build (exit code 1 at the end).

`--cleanup` tries deleting every position / path-length parameter — an `at`
clause, an `at`/aligned-move offset, an exact move (`right 40`), a bare
direction element (`-> down ->`), or just a move's length — and keeps a
deletion only if the rendered SVG of **every** file on the command line stays
byte-identical (files that `include`/`import` an edited file are re-rendered
too). Pass the whole sheet family together so `def`s used across files stay
protected. What survives is exactly the set of load-bearing parameters.

`--nets` prints each electrical net as one sorted line of members — `REF.PIN`
for part pins, `<NET>` for rail/gnd terminals, `(NAME)` for named nodes — and
is layout-independent: re-arrange a sheet freely, then `diff` the two `--nets`
outputs to prove the circuit itself did not change. Nodes whose name starts
with `_` (your trace points and the tool's own anonymous ones) are plumbing
and stay out of the listing.

The build fails (with a line number) on: unknown statement, a ref/pin that
exists nowhere in the file, duplicate ref, circular `at` chains, a node or
part whose position can never be resolved (related to nothing), or an
unclosed `chip`/`def`. That is the "do all the paths connect?" check, kept
mechanical.
