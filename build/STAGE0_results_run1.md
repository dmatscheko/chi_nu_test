# Stage 0 — bench characterization results (Run 1)

Lab-notebook record of the Stage-0 ring characterization: resonance, Q, and the
ring-to-ring coupling matrix measured on the Rigol **before** any custom
electronics. This is the procedure in
[`electronics.md` §1 — Characterize the rings (Stage 0)](electronics.md#1-characterize-the-rings-stage-0)
and Stage 0 of [`MILESTONE_1_build.md`](MILESTONE_1_build.md). Scope and decision
rules live in [`../test/DOCUMENT_A_prediction_ledger.md`](../test/DOCUMENT_A_prediction_ledger.md).

| | |
|---|---|
| Run | **1** |
| Date | 2026-06-06 |
| Operator | _____________ |
| Stage | 0 (characterization only — **no weighing, no lift claim**) |
| Status | mostly complete; open items in §6 |
| Rings | 3× PZT, OD 38 mm / ID 14.8 mm / 5 mm (per [`milestone1_jig.scad`](milestone1_jig.scad)) |
| Layout | `row` (ring 0 — ring 1 — ring 2 in a line; 0↔1 and 1↔2 adjacent, 0↔2 far) |

> **This is a versioned document.** Run 1 is the first build, with the
> heat-degraded ring 2 (see §5). To repeat the experiment — e.g. with fresh
> piezos — **copy this file to `STAGE0_results_run2.md`** and refill the tables,
> rather than overwriting Run 1. Keep each run as its own snapshot.
>
> If any later run produces a result that hints at new physics, interpretation is
> **not** decided here — it is governed by the pre-registered decision rule in
> [`../test/DOCUMENT_A_prediction_ledger.md`](../test/DOCUMENT_A_prediction_ledger.md) Part 5.
> This document only records what was measured.

---

## 1. Equipment & setup

- **Instrument:** Rigol MHO954 (built-in generator GI + oscilloscope).
- **Rig:** series-R current sense per
  [`electronics.md` §1](electronics.md#1-characterize-the-rings-stage-0) —
  GI → **R_sense 100 Ω** → ring hot; ring cold → common GND.
  Diagram: [`stage0_characterization.svg`](stage0_characterization.svg).
- **Probes:** ×10 (10 MΩ) on CH1 (drive node) and CH2 (piezo / read node).
- **Grounding:** single **star** — all three ring cold faces bussed to one common
  point (TX return kept off the RX ground legs). Same poled face = ground on all
  rings.
- **Ring leads:** twisted pairs (salvaged network cable), one pair per ring.
- **Generator note:** this unit has **no dedicated Sweep/Burst tab** (only Basic
  waveforms + Modulation AM/FM/PM). Resonances in this run were found by **manual
  frequency-knob scan**. (Automated alternatives if needed: FM + ramp modulating
  wave = a sweep; AM + 100 % square = a burst train for ringdown.)

---

## 2. Resonance (`f_r`) — Use 1

Manual sine scan, ~2 Vpp into R_sense, watching CH2 for the amplitude peak +
phase flip.

| Ring | `f_r` (amplitude peak) | Notes |
|---|---|---|
| 0 | **43.5 kHz** | sharp peak; phase flip ~43.6 kHz |
| 1 | **43.5 kHz** | sharp peak |
| 2 | **43.5 kHz** | resonates at same `f_r`, but weak (see §5) |

- **Drive frequency adopted for Stage 1: 43 500 Hz** (replaces the placeholder
  `frequency: 50000Hz` in [`chi_nu_poc.yaml`](chi_nu_poc.yaml) once confirmed in
  firmware).
- The amplitude peak (43.5 kHz) and the sharpest phase flip (~43.6 kHz) differ by
  ~0.2 % — normal for a piezo (the flat electrode capacitance C0 shifts the
  zero-phase point off the response maximum). **Drive at the peak** for maximum
  energy into the ring.

### 2a. Erratum (2026-07-05) — the 43.5 kHz "amplitude peak" is f_p, not f_s

*(Annotation; the recorded numbers above are untouched.)* In this rig (drive
through R_sense = 100 Ω, CH2 across the ring) a **CH2 amplitude *peak* is the
parallel/anti-resonance `f_p`** (ring impedance maximum, minimum current). The
**series resonance `f_s`** — impedance minimum, maximum current, and the
frequency at which a low-impedance source pumps the most energy into the ring —
shows as a **CH2 *dip* a few percent *below* `f_p`** and was not logged in this
run. Consequences:

- The interpretive note above ("drive at the peak for maximum energy") has it
  backwards for a series-driven TX: near **`f_s`** the drive current, and with
  it the mechanical excitation, is maximal. The `k_eff²` of these PZT rings puts
  `f_p − f_s` at a few % of f_r, i.e. **many bandwidths** (BW = f_r/Q ≈ 0.6 kHz).
- The §4 coupling matrix was therefore measured at a drive frequency that is
  likely several bandwidths above the optimum — the 10/5/2 mV values are valid
  *relative* numbers for 43.5 kHz but probably **undersell the achievable
  coupling by a factor of a few**.
- The §5 ring-2 conclusion (≈50 % efficiency, both directions) is a *ratio* at
  fixed frequency and is **unaffected**.
- **Action for Run 2 / Stage 1:** log the CH2 dip (`f_s`) per ring, then sweep
  the burst frequency between `f_s` and `f_p` and freeze `drive_freq` at the
  point of maximum coupled RX amplitude (procedure now in
  [`electronics.md` §1](electronics.md#1-characterize-the-rings-stage-0)).

---

## 3. Quality factor (`Q`) — Use 1

From the −3 dB width of ring 0's resonance peak:

| Quantity | Value |
|---|---|
| `f_r` | 43 500 Hz |
| −3 dB (0.707·max) low | ≈ 43 200 Hz |
| −3 dB (0.707·max) high | ≈ 43 770 Hz |
| Δf | ≈ 570 Hz |
| **Q = f_r / Δf** | **≈ 76** (call it ~75, approximate) |

> The response fluctuated a little during the measurement (probable pickup on the
> high-Z node), so the −3 dB points wander a bit around the values above; treat
> Q ≈ 75 as a ballpark. A burst of ~50–100 cycles is appropriate (energy builds
> over ~Q cycles). Cross-check via ringdown later: `Q = π·f_r·τ`.

---

## 4. Cross-coupling matrix `C_ij` — Use 3

Drive one ring at 2 Vpp / 43.5 kHz through R_sense; read the **peak amplitude of
the coupled sine** at another ring (×10 probe, same 43.5 kHz). Raw scope
millivolts — **relative, uncalibrated** (sufficient for the matrix and for the
shuffled-control comparison in Milestone 1).

**TX (row) → RX (column), mV peak @ 2 Vpp, 43.5 kHz** (values averaged for precision):

| | RX ring 0 | RX ring 1 | RX ring 2 |
|---|---|---|---|
| **TX ring 0** | — (self) | **10** | 2 *(far pair)* |
| **TX ring 1** | **9.6** | — (self) | 5 *(ring 2 weak)* |
| **TX ring 2** | 2 | 5 | — (self) |

- **Fully reciprocal:** C(0→1)=10 / C(1→0)=9.6, C(0→2)=C(2→0)=2,
  C(1→2)=C(2→1)=5. Symmetric within measurement scatter → the rig is sound;
  the asymmetries are in the parts, not the setup.
- **Distance gradient confirmed** (the `row`-layout prediction C01 > C02):
  adjacent pair 0↔1 ≈ **9.8 mV** vs far pair 0↔2 ≈ **2 mV**.
- **Internal consistency / decomposition.** Modeling C_ij ≈ (distance factor)·e_i·e_j
  with a per-ring efficiency `e`:
  - *Ring 2 efficiency:* the two adjacent pairs share ring 1, so
    e₂/e₀ ≈ C12/C01 = 5/10 ≈ **0.5** → ring 2 ≈ half (matches §5).
  - *Plate falloff:* the far/adjacent geometric ratio ≈ **0.4** from two
    independent routes (C02/C01 ÷ efficiency, and C02/C12) — they agree, so the
    simple model holds and the 2 mV far reading is just geometry × half-strength ring 2.
- The structure (strong 0↔1 pair, weak ring-2 row/column, clean distance gradient)
  is well-defined and far above any plausible shuffled-control baseline → good
  footing for the Stage-1 receipt.
- Diagonals (same-port self-read C00/C11/C22) **not measured on the scope** —
  they need the reset-after-drive trick and are a Stage-1 firmware step
  ([`electronics.md` §5](electronics.md#5-peak-detector-rx)).

---

## 5. Finding: ring 2 is heat-degraded (~50 %) — depoling, confirmed

**Cause:** during soldering, a ~3×2 mm patch of ring 2's electrode coating was
overheated, blistered, and de-coated; it was bridged with a small ring of solder
to the surrounding intact electrode. The prolonged heat **partially depoled** the
ceramic — confirmed by the C0/ESR measurement below.

**Evidence (controlled comparison):** driving the **center ring (ring 1)**, its
two neighbors are at **equal distance**, yet:

- ring 1 → ring 0 = **9.6 mV**
- ring 1 → ring 2 = **5 mV**

Same driver, same geometry, ~half the signal (e₂/e₀ ≈ 0.5) ⇒ the deficit is **ring 2 itself**,
not the layout. The reduction appears in **both** directions (ring 2 weak as TX
*and* as RX), consistent with **partial depoling** of the ceramic from the
soldering heat: piezoelectric coupling is reciprocal, so lost activity lowers TX
and RX equally. `f_r` is unchanged (set by mechanical dimensions, which the heat
did not alter) — only the electromechanical conversion dropped. The clean, stable
5 mV sine (not flaky/noisy) argues against a bad joint and toward genuine
depoling.

**Confirmed by C0 / ESR (MTester V2.07):** ring 0 = 2264 pF, ring 1 = 2260 pF,
ring 2 = 2314 pF; **ESR = 17 Ω on all three.** Ring 2's capacitance is normal (if
anything marginally *higher*, not lower) and its ESR matches the others, so
electrode area, dielectric, and contact resistance are all intact. A lost-area or
bad-joint failure would have dropped C0 or raised ESR — neither happened. With
C0, ESR, and `f_r` all normal but coupling halved in both directions, **reduced
piezoelectric activity (partial depoling) is the only consistent explanation.**
(Measurement valid despite the still-bussed grounds: the other rings' hot leads
were open, forming no return path.)

**Disposition:** ring 2 is **still usable for Milestone 1** — 5 mV @ 43.5 kHz is
well above noise and reproducible, and the self-read receipt only needs a stable
matrix clearly above the shuffled control. Ring 2 is flagged as the deliberately
**weak row/column**; do **not** use it as a reference ring. Replace with a fresh
piezo when stock arrives (→ Run 2).

---

## 6. Open items / TODO

- [x] ~~**C0 (static capacitance)** of all three rings~~ — done (MTester V2.07):
  ring 0 = **2264 pF**, ring 1 = **2260 pF**, ring 2 = **2314 pF**; ESR = **17 Ω**
  on all three. All equal within scatter (~2.26 nF, validating the ≈2 nF design
  assumption); ring 2 not lower ⇒ **§5 depoling confirmed**, not electrode/contact loss.
- [x] ~~Fill the missing matrix cell **C(2→0)** and re-read C(0→2)~~ — done (§4):
  both = 2 mV, reciprocal; far/adjacent ratio ≈ 0.4 (consistent with geometry).
- [ ] Diagonals C00/C11/C22 (same-port self-read) — **implemented** in
  [`chi_nu_poc.yaml`](chi_nu_poc.yaml) (rev 2: two-burst capture, reset after
  drive-off, `diag_tail_ms ≈ 3 ms` so the ×120 amp is back in range);
  pending bench validation (diagonal should track drive and sit above the
  shuffle baseline). Tune `diag_tail_ms` if it reads rail (too early) or ~0
  (too late).
- [ ] Ringdown `τ` per ring → independent Q (`Q = π·f_r·τ`), cross-check §3.
- [ ] **Log `f_s` (CH2 dip) per ring and re-measure C_ij at the
  max-coupling frequency** — see erratum §2a; expect larger values than §4.
- [ ] Per-ring `f_r` to finer resolution (all read 43.5 kHz at scan resolution).

---

## 7. Status & next step

Stage 0 essentially done: rings characterized (`f_r ≈ 43.5 kHz`, `Q ≈ 75`), a
clean reciprocal coupling matrix obtained, and one degraded ring identified and
understood. **No weighing, no lift claim** — that is by design for this stage.

**Next:** Stage 1 — flash [`chi_nu_poc.yaml`](chi_nu_poc.yaml) (drive 43 500 Hz),
have the ESP32 log the coupling matrix to Home Assistant, and show it stands above
the shuffled control. That logged, reproducible matrix is the Milestone-1
**self-read receipt** ([`MILESTONE_1_build.md` §1](MILESTONE_1_build.md)).

**Run 2 trigger:** repeat with fresh piezos (healthy ring 2) — copy this file to
`STAGE0_results_run2.md`.
