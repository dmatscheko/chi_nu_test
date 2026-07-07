
## 6. Standalone terminals + US/IEC symbol styles (2026-07-05)

*Q: add the terminals (what `+5V` draws) as placeable symbols; allow choosing
US vs IEC/European symbols on the sheet line.*

* `rail F1 "+5V" at 300,80` / `gnd G1 at 300,400` — the label is the **net
  name**: the flag takes the net's display text and colour and appears as
  `<NET>` in `--nets`, exactly like a path terminal (`gnd` defaults to GND).
* `sheet ["title"] us|iec` (aliases `ansi` / `din`,`eu`; default `us`; reset
  per build). Only the glyphs differ — IEC resistor = rectangle (pot follows),
  IEC inductor = filled bar; pins/spans/routing identical, so switching style
  never re-routes a sheet. Unknown bare words on the sheet line now error.
* `examples/symbols.sch` → `examples/symbols_kit.sch` (shared gallery, incl.
  the terminal symbols) + thin `symbols_us.sch` / `symbols_iec.sch` wrappers
  that set the style and `include` the kit; both auto-sized.
* SKILL.md, README.md and LANGUAGE.md brought up to the full current feature
  set (auto-size, `_` nodes, aligned moves, styles, standalone terminals).

## 8. Order-free position resolution — the defer/retry resolver (2026-07-05)

*Q: removing `at 700,330` from the XIAO chip failed with "'XIAO' has no
position yet — wire it first". Nothing should need wiring, nothing should
need to be defined before use — every element should resolve its position
relative to the others, in any order.*

Implemented as an **iterative resolver** on top of the existing single-pass
rules, so every current placement behaviour is preserved exactly:

* All "cannot resolve YET" errors (unknown part so far, unplaced `at` anchor,
  node without position, pending part with nothing known) became a distinct
  `Unresolved` exception. A statement that raises it is **rolled back**
  (cheap sheet-state snapshot: part set + positions, nodes, link count, nets,
  auto counter) and queued; after the whole file is read, the queue is
  retried in document order until a fixpoint.
* On a full stall — nothing absolutely anchored — ONE element is seeded at
  the origin and resolution continues: first a path that starts at a part
  pin (structural root), else a bare-node path, else a lone declared part
  (declaration-only sheets). Additional disconnected clusters seed below the
  already-placed content. Genuinely broken sheets (circular `at` chains,
  refs that never exist, a part related to nothing) still fail with the
  original message plus "unresolvable even after reading the whole sheet".
* `chip`/`block` heads now keep their `at` tokens unresolved until the pin
  rows are consumed, so a deferred chip still knows where its statement ends.
  `sheet` accepts `WxH` after the title too. Remaining ordering rule:
  `defchip`/`def`/`include` before instantiation.

Verified: the seven untouched sheets and both galleries stay **byte-
identical**; `controller_power.sch` without the XIAO `at` (the failing case)
builds **pixel-identical** to the published SVG; a fully shuffled variant
(all wires before all declarations) differs only in 6 anti-aliased pixels at
one wire crossing (draw order); circular/orphan cases give clear errors.

## 9. Drops pin deferred nodes — centring is only a default (2026-07-06)

*Q: in `controller_power.sch`, `Rscl.b -> _SCL` dropped down and then jogged
82 px left to reach the node. `Rscl.b` is fixed by the 3.3 V rail, so the
centring of `_SCL` should be lower priority and the drop should land straight.*

* Cause: `try_resolve_node` placed a deferred node at the midpoint of its
  **first two** known anchors and ignored all further ones. `_SCL`'s first
  two anchors are XIAO.GPIO23 and ADS.SCL → centred at x = 497.5, while the
  pull-up hangs at x = 580.
* Fix: the first two anchors still define the through-line (an aligned pair
  keeps its common coordinate, else dominant-axis midpoint), but the first
  **later** anchor that drops perpendicularly onto that line — off the line,
  arriving across it when its direction is known, landing at least
  `DROP_MARGIN` = 12 px inside the span — pins the free coordinate, so its
  tap connects dead straight.
* controller_power: `_SCL` x 497.5 → 580 (the Rscl drop is now vertical) and
  `_SDA` x 497.5 → 500 (a 2.5 px jog under Rsda gone; the SDA run stays one
  straight line). The remaining ~3 px step in the SCL run, now folded into
  the junction, is pin-pitch mismatch (XIAO 43.33 px vs ADS1015 40 px; the
  `+490,20` offset aligns SDA exactly) — sheet geometry, not routing.
* All other sheets and both symbol galleries stay **byte-identical** and
  `--nets` is unchanged for every sheet. LANGUAGE.md and skill/SKILL.md
  updated (also corrected the stale "single anchor + 60 px" — the code backs
  off 40 px).
