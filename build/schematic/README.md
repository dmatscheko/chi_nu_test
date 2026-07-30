# Schematic generator

`schematic.py` turns a compact **path-based** text netlist into a real
electronic schematic SVG — proper symbols in **US/ANSI or IEC/European
style**, obstacle-avoiding orthogonal autorouting, automatic junction dots,
and **auto-sized sheets** (leave the size off `sheet` and the canvas fits
itself around the drawing, title and notes included). Zero dependencies
(pure Python 3).

The core idea: **the route is the statement.** Wires are written as `->`
paths, parts sit inline *on* the paths, and named nodes form junctions:

```
LEDC.p -> [res Rb "R_base" "1k"] -> BASE
BASE -> up 72 -> [npn Q1 "Q1" "S8050"].B
Q1.E -> OUT <- Q2.E
OUT -> [res Rd "100 Ω"] -> [piezo RING "Ring 0"] -> GND
```

Everything can be pinned manually (`at`, `right 120`, `(x,y)` waypoints) —
but nothing has to be: `at` is optional even for standalone parts and chips
(the first wired pin places them), statement order is free (whatever cannot
resolve yet is retried once the whole file is read), a sheet with no
absolute coordinates at all seeds itself at the origin, and with no hints
placement advances along the path while the router finds a clear Manhattan
route. Full reference: **[LANGUAGE.md](LANGUAGE.md)**.
One-of-every-symbol galleries: [examples/symbols_us.sch](examples/symbols_us.sch)
and [examples/symbols_iec.sch](examples/symbols_iec.sch) (same kit, both styles).
The previous (v1) engine, sources, and SVGs live in git history (the `v1/`
snapshot was removed from the working tree in the July 2026 cleanup).

The build diagrams are generated from the `.sch` sources here:

| Source | Output (in `../`) |
|---|---|
| `stage0_characterization.sch` | Stage-0 piezo characterisation rig (gen + scope) |
| `drive_stage.sch` | push-pull TX drive buffer |
| `tx_select.sch` | CD4066 TX-select (Stage 1b, full 3×3) |
| `peak_detector.sch` | RX Schottky envelope detector |
| `controller_power.sch` | power tree + I²C bus |
| `system_overview.sch` | block/flow diagram |
| `system_connected.sch` | whole instrument as one connected block graph |
| `full_instrument.sch` | full instrument as one real schematic, **built from the parts**: `import`s `drive_buffer` (drive_stage), `CD4066` (tx_select), `rx_channel` ×3 + `vbias` (peak_detector) |

## Regenerate

The canonical SVGs live in `../` (next to `electronics.md`, which embeds
them). The Makefile writes there:

```sh
make            # build all ../*.svg from the .sch sources
make png        # also drop ../*.png previews (needs rsvg-convert)
make nets       # per-net colour debug views -> ./*_nets.svg (never into ../)
make kicad      # KiCad 9 schematics + symbol library -> ./kicad/
make cleanup    # rewrite the .sch: drop params that don't change the SVGs
make clean      # remove the PNG previews, *_nets.svg and ./kicad/
```

By hand — every mode takes any number of `.sch` files (`make` is just the
first line); with several inputs `-o` names a directory:

```sh
python3 schematic.py *.sch -o ../
python3 schematic.py drive_stage.sch -o ../drive_stage.svg
```

## KiCad output (`--kicad`)

The same sheets also compile to a **real KiCad 9 schematic** — not a picture of
one: `--kicad` writes `<sheet>.kicad_sch` with every symbol it uses embedded in
the file, plus those symbols as a standalone `schpy.kicad_sym` library next to
it (so they can be picked from KiCad's own symbol browser and re-used by hand).

```sh
python3 schematic.py full_instrument.sch --kicad      # -> full_instrument.kicad_sch
python3 schematic.py *.sch -o kicad/ --kicad          # all of them + schpy.kicad_sym
make kicad
```

Open the `.kicad_sch` with KiCad's Schematic Editor (it offers to create a
project around it), or drop it into an existing project *under that project's
name* — `MILESTONE_1_build/MILESTONE_1_build.kicad_sch` — and it opens as that
project's root sheet. Nothing else is needed: no library has to be installed,
because the symbols travel inside the file.

**It really connects.** 10 px become 1.27 mm — KiCad's 50 mil grid, which is
also the raster these symbols were drawn on, so a resistor lead lands on
±3.81 mm exactly like KiCad's own `Device:R`. Three things make the connections
hold:

* **Snapped before routing.** The sheet is re-laid-out with parts, nodes and
  chip pin rows snapped onto the 50 mil raster *before* the autorouter runs, so
  the schematic lands on KiCad's grid and stays editable — drag a symbol and
  its wires come along. Snapping is a function of the coordinate, so equal
  coordinates stay equal and every row, column and alignment survives. If a
  sheet is drawn finer than that, the exporter falls back through 25 → 12.5 →
  5 → 2.5 mil until the circuit comes out **exactly** as the SVG draws it — the
  netlists are compared, and a sheet that cannot be reproduced is an error, not
  a silent rewiring. The grid it settled on is printed with each file.
* **Exact arithmetic.** Every coordinate is quantised to half a pixel before
  scaling, which makes each millimetre value an exact 4-decimal number, so a
  pin's absolute position (symbol origin + pin offset, the way KiCad adds them
  up) is bit-identical to the wire end drawn on it.
* **A real wire graph.** The routed polylines are re-cut before they are
  written: split at every point where another wire ends or a pin sits,
  overlapping duplicates dropped, junction dots where three or more segments
  meet, hair-off-axis runs pulled straight. KiCad joins wires at shared
  endpoints, not by "they look like they touch".

The result: **the netlist KiCad reads back is the netlist `--nets` prints**,
pin for pin — checked with `kicad-cli sch export netlist` on every sheet here.

What carries over:

| `.sch` | KiCad |
|---|---|
| `res`, `cap`, `diode`, `npn`, `opamp`, … | symbols in the embedded `schpy` library (`schpy:R`, `schpy:Q_NPN_BCE`, … — KiCad's own names and pin numbering, so swapping in `Device:R` later keeps the pins) |
| part `ref` + label / value | `R1` / `100 Ω` (auto designators; the source name is kept in a hidden `Sch` property, the label in `Description`) |
| `net GND`, `net +3.3V`, rail/gnd terminals | power symbols — one per terminal, all on the named net |
| `node NAME` | a net label on the wire (`_`-names stay plumbing, as in `--nets`) |
| `port` | a global label |
| `chip` / `block` | a per-sheet symbol: box, named pins, pin numbers 1..n in declaration order |
| `note` | text block under the drawing; `sheet` title → title block |
| `flow` arrows (system diagrams) | plain graphic polylines — they are drawings, not nets |

### Footprints

Every standard part gets a default footprint from KiCad's own libraries, so the
netlist is ready for the PCB step without a round of field-filling:

| part | footprint |
|---|---|
| `res` | `Resistor_SMD:R_1206_3216Metric` |
| `cap` | `Capacitor_SMD:C_1206_3216Metric` |
| `cap_pol` | `Capacitor_Tantalum_SMD:CP_EIA-3216-18_Kemet-A` (EIA-3216 = 1206) |
| `inductor` | `Inductor_SMD:L_1206_3216Metric` |
| `diode` `schottky` `zener` | `Diode_SMD:D_1206_3216Metric` |
| `led` | `LED_SMD:LED_1206_3216Metric` |
| `npn` `pnp` `nmos` `pmos` | `Package_TO_SOT_SMD:SOT-23` |
| `opamp` | `Package_SO:SOIC-8_3.9x4.9mm_P1.27mm` |
| `xtal` | `Crystal:Crystal_SMD_2012-2Pin_2.0x1.2mm` |
| `testpoint` | `TestPoint:TestPoint_Pad_D1.5mm` |
| `piezo` `battery` `switch` `button` `pot`, `chip`, `block` | left empty — those are the custom / mechanical ones (the rings, the LiPo, the modules) |

Override any of them per part with **`fp "Lib:Footprint"`**, which works on
standalone parts, inline parts, chips and `defchip` types alike:

```
res Rsda "Rp" "4.7 kΩ" fp "Resistor_SMD:R_0805_2012Metric" at 300,80
DRVOUT -> [res Rdd "R_drive" "100 Ω" fp "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal"] -> SW.INB
chip SW CD4066 fp "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" at DRVIN +460,0
```

The default also lands in the generated `schpy.kicad_sym`, so a symbol picked
from that library by hand arrives with its footprint already set.

The instrument's own parts carry their package in the `.sch` next to the
circuit, so the netlist is complete without touching KiCad:

| part | footprint | declared in |
|---|---|---|
| CD4066 | `Package_SO:SOIC-14_3.9x8.7mm_P1.27mm` | the `defchip` in `tx_select.sch` — every instance inherits it |
| ADS1015 | `Package_SO:TSSOP-10_3x3mm_P0.5mm` (TI's DGS body) | each sheet that draws it |
| MCP6022 ×3 | `Package_SO:SOIC-8_3.9x4.9mm_P1.27mm` | the `package AMP` line in `peak_detector.sch` |
| Xiao ESP32-C6 | `Seeed_Studio_XIAO_Series:XIAO-ESP32-C6-SMD` | `full_instrument.sch` (Seeed's own library; add the `.pretty` to KiCad's footprint table) |
| ring 0..2 | `Connector_JST:JST_PH_B2B-PH-K_1x02_P2.00mm_Vertical` | `peak_detector.sch` / `drive_stage.sch` — the two ring wires plug into the board |
| 1S LiPo | `Battery:BatteryHolder_MPD_BH-18650-PC` | `controller_power.sch`, `full_instrument.sch` |

`stage0_characterization.sch` has none: it is a bench rig (generator, scope
probes, loose rings), not a board.

### Real pin numbers and multi-unit packages

A generic symbol knows nothing about its package, so by default pins are
numbered 1..n in the order the symbol declares them. Two keywords fix that,
and neither changes the SVG:

* **`pins "…"`** gives the real package pin numbers, either by name
  (`pins "in+=3 in-=2 out=1 vcc=8 vee=4"`, the sheet's pin names or the KiCad
  symbol's, whichever reads better) or positionally (`pins "3,2,1,8,4"`). On a
  `defchip` it applies to every instance of that type.
* **`unit PKG [A]`** says this part is one unit of the physical package `PKG`
  (a name in the current namespace, so a `def` stamped three times gives three
  packages). Units of one package share a designator, a footprint and one
  multi-unit KiCad symbol — KiCad shows them as `U1A`, `U1B`. The optional
  letter fixes the order.
* **`package PKG "Device" [fp "Lib:Footprint"]`** names the physical part the
  units share (KiCad `Value`) and its footprint.

That is how the two `½ MCP6022` amplifiers in `peak_detector.sch` become one
SOIC-8 with the datasheet's pinout, while still being drawn as two op-amp
triangles in both the SVG and KiCad:

```
opamp A1 "A1 ½ MCP6022" "x21"  unit AMP A pins "in+=3 in-=2 out=1 vcc=8 vee=4" …
opamp A2 "A2 ½ MCP6022" "x5.7" unit AMP B pins "in+=5 in-=6 out=7 vcc=8 vee=4" …
package AMP "MCP6022" fp "Package_SO:SOIC-8_3.9x4.9mm_P1.27mm"
```

A unit's own value (`x21`) travels in a visible `Note` field, since KiCad's
`Value` belongs to the whole package. `tx_select.sch` and `full_instrument.sch`
carry the CD4066 and ADS1015 pinouts the same way (taken from KiCad's own
`4xxx` and `Analog_ADC` libraries).

Without `pins`, *Update PCB from Schematic* warns `No net found for component
U1 pad N (no pin N in symbol)` for every package pad the sheet does not draw —
which is also the honest warning for pins that really are unused (the CD4066's
fourth switch, the ADS1015's `AIN3`/`ALERT`, the Xiao's spare GPIOs). Declare
those pins in the `chip` block if you want them silent and reachable.

Two things are deliberately *not* claimed: there are no footprints (the
`Footprint` field is empty — that is the PCB step's job), and ERC will report
`power_pin_not_driven` for every power net, because nothing in a generated
sheet is a power *source*. Add a `PWR_FLAG` on each rail in KiCad, or silence
that rule, as usual. ERC also notes `lib_symbol_issues` until `schpy.kicad_sym`
is added to the symbol library table (Preferences → Manage Symbol Libraries),
and `endpoint_off_grid` on sheets that had to fall back to a finer grid —
harmless, the connections there are exact; set KiCad's grid to the size the
export reported and editing is comfortable again.

## Why a netlist instead of hand-drawn SVG

Every path endpoint is a **named pin** (e.g. `Q1.E`, `ADS.AIN0`). If a path
references a pin that does not exist, the tool **errors out** — so "do all
the paths connect?" is checked mechanically on every build. The diagrams are
also diffable and re-generatable, unlike hand-placed `<line>`s. Repetition is
first-class: a `def` block stamps a whole sub-circuit per `use`, and
`import "file.sch" [NAME …]` pulls just the `def`/`defchip` definitions out
of another sheet (its own drawing is skipped) — so every detail sheet doubles
as a library. `full_instrument.sch` contains no redrawn circuitry at all: it
imports the drive buffer from `drive_stage.sch`, the CD4066 from
`tx_select.sch`, and the amp+detector channel (stamped ×3 around one shared
bias divider) from `peak_detector.sch`.

## Colouring nets

1. **Meaningful colours (normal render):** declare a net colour once —
   `net GND #2166ac` — and end paths at its terminal (`-> GND`, `-> +5V`).
   The whole electrically-connected net inherits the colour. The build
   diagrams use +5 V `#e8412f`, +3.3 V `#a31515`, GND `#2166ac`, signals
   black. (For a coloured net without a terminal, put `color #hex` at the
   end of one of its paths.)
2. **Debug view (`--color-nets`):** auto-assigns a *distinct* colour per net,
   overriding everything — so a net showing two colours is broken and two
   nets sharing a colour are an accidental short:

```sh
python3 schematic.py controller_power.sch --color-nets   # -> controller_power_nets.svg
make nets
```

3. **Netlist print (`--nets`):** prints each electrical net as one sorted line
   (`REF.PIN` members, `<NET>` terminals, `(NAME)` nodes). Layout-independent —
   `diff` it before/after a re-layout to prove the electronics didn't change:

```sh
python3 schematic.py drive_stage.sch --nets
```

4. **Cleanup (`--cleanup`):** rewrites the given `.sch` files in place, deleting
   every position / path-length parameter (`at` clauses and offsets, exact
   moves, bare direction elements, aligned-move offsets) whose removal keeps
   the rendered SVG of **every** given sheet byte-identical — proof that the
   parameter was dead weight. Always pass the whole family so `def`s imported
   across files stay protected (that is what `make cleanup` does):

```sh
python3 schematic.py --cleanup *.sch
make cleanup
```

A net is the set of wires that electrically touch (coincident endpoints or
T-junctions). Plain crossings don't touch — a wire crossing another with no
dot keeps its own colour, visual proof it's a no-connect. The colour views
write to `*_nets.svg` *here* (never into `../`).

## Language cheat-sheet

See [LANGUAGE.md](LANGUAGE.md) for the full reference. The essentials:

```
sheet 1050x800 "Title"                  # canvas; note …  adds footnotes
sheet "Title"                           # no size -> auto-size, content centred
sheet "Title" iec                       # IEC/European symbols (default: us)
net +5V #e8412f "+5 V"                  # net colour + rail label, once

port DRV "Drive buffer OUT"             # no `at`: placed by its first wired use
chip T1 NE555                           # works for chips/blocks too
res  Rref "R_ref" "1 MΩ" a at RING.b +40,0 down   # or placed BY pin a, vertical
res  Rp "4.7 kΩ" fp "Resistor_SMD:R_0805_2012Metric"   # KiCad footprint override
rail F1 "+5V" at 300,80                 # standalone net terminal (label = net)
gnd  G1 at 300,400                      # same for ground (net GND)

DRV.p -> [res Rd "100 Ω"] -> SW.INB     # parts live ON the route
RING.b -> right 40 -> down -> [res Rr "1 MΩ"] -> down 30 -> GND   # hang + ground
Q1.E -> OUT <- Q2.E                     # runs meet: node at the midpoint + dot
[npn Q1].B -> BASE <- [pnp Q2].B        # pair-meet: spreads ±80 around the node
GPIO6 -> right to Rsda.b -> _SDA -> SDA # thread node _SDA into the line …
Rsda.b -> _SDA                          # … and tap it by name (preferred)
(382,85) -> (1250,85)                   # a bus (waypoints are literal)
Rsda.b -> down 68                       # tap down ONTO a line below (sketch)
Ra.b -> right to XIAO.V5 +50            # aligned tap: right only, to V5's x +50

chip ADS at 740,250 200x180 "ADS1015" "I²C 0x48"   # or defchip + include
  left  AIN0 AIN1 AIN2 AIN3
  right VDD SDA SCL
end

def channel(hot, ring)                  # define once …
  hot -> down -> [piezo RNG ring lpos left] -> down 40 -> GND
end
use channel ch0(H0, "Ring 0")           # … stamp: parts become ch0.RNG, …
node OUT                                # declare (unplaced) so a use can bind it
import "peak_detector.sch" rx_channel   # defs/defchips only, sheet skipped

block XIAO "Xiao ESP32-C6" "l1|l2" at 500,100 200x96 accent   # system diagrams
  bottom DRIVE RESET I2C
end
flow XIAO.DRIVE -> down -> BUF.e "DRIVE (GPIO2)" dash
```

Pin names by type:

| Type | Pins |
|---|---|
| `res` `cap` `cap_pol` `inductor` `piezo` `xtal` `switch` `button` | `a` `b` |
| `pot` | `a` `b` `w` (wiper) |
| `diode` `schottky` `zener` `led` | `a` (anode) `k` (cathode) |
| `npn` | `B` `C` `E` — `pnp`: `B` `E` `C` |
| `nmos` `pmos` | `G` `D` `S` |
| `opamp` | `in+` `in-` `out` `vcc` `vee` |
| `battery` | `+` `-` (aliases `a` `b`) |
| `gnd` / `rail` / `port` / `testpoint` | `p` |
| `chip` / `block` | the pins you declare (`block` also: `n s e w c`) |

Orientation words `up/down/left/right` set a part's a→b axis; `mirror` flips
it; `lpos up|down|left|right` moves the label. Junction dots appear only
where ≥3 conductor directions meet; plain crossings get **no** dot. Autorouted
wires leave/enter each pin with a straight 10 px run along the pin's direction
(`escape N` adjusts it; 0 disables).

Node naming: plain names (`BASE`, `OUT`) are circuit signals and appear in
`--nets`; a leading underscore (`_SDA`, `_V33`) marks a pure trace point —
hidden from `--nets` like the tool's own anonymous nodes, and never
confusable with a part ref or a net terminal.
