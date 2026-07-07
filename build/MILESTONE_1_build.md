# Milestone 1 — Self-Reading Piezo PoC (build v0)

**Goal:** prove the OPH **self-read loop** in hardware — a bounded object that
drives its own ports, senses the response, records it, and shows the records are
reproducible and predictive. **No weighing in this milestone.** No balance, no
torsion stage, no high voltage. Round piezo rings are fine (shape is irrelevant
to the self-read receipt).

Path shortcuts (`OPH:/`, `HOVER:/`, `ANS:/answer`, `ANS:/guide`) are defined in
`../test/DOCUMENT_A_prediction_ledger.md`. This build implements Milestone 1 of
`ANS:/guide` "Build Roadmap" and the §3.5 self-read gate of Document A.

---

## 1. What "done" looks like (exit receipt)

Milestone 1 is complete when you can produce, and log to Home Assistant:

1. **Coupling matrix C_ij** — drive port *i*, read every port *j*, store the
   response. Reproducible across repeats and **different from a shuffled/dummy
   control**.
2. **Same-port (or co-located) readback** — drive a port, then sense its own
   ringdown on the same port (or a fixed co-located partner). Response changes
   predictably with drive state.
3. **Stable logs** — every drive/read event timestamped, re-readable later.

That's it. ΔS, ACTIVE±/SHAM, top/bottom zoning, and the balance come in
Milestones 2–4.

How each piece maps to the OPH gate `S_coh = 1_self-read · R_U · P_U · C_U`:

| Build element | Gate it serves |
|---|---|
| Same-port / co-located drive+sense | `1_self-read` |
| Repeatable coupling matrix | `R_U` (record stability) |
| Past readings predict next reading | `P_U` (predictive boundary) — Milestone 2 |
| Structured, state-dependent coupling | `C_U` (visible coherence) |

### 1.1 Receipt acceptance thresholds (proposed pre-registration values)

`DOCUMENT_A` §3.5 requires the `R_U`/`C_U` tolerances to be **preregistered**
but leaves the numbers to the build. These are the proposed values — grounded
in the Run-1 Stage-0 measurements and the Chapter-5 signal chain — to freeze
(or amend, *before* the receipt run) in the ledger:

| # | Criterion | Pass threshold | Why this number |
|---|---|---|---|
| A1 | **Separation** (`C_U`) | every active off-diagonal cell mean ≥ **10×** the pooled shuffle σ, and ≥ **5×** the off-resonance mean | the weakest Run-1 cell (2 mV → ≈ 40–90 mV held ≈ 80–180 ADC LSB) sits ~40σ above the ADS noise floor (~1–2 LSB), so z ≥ 10 is conservative yet unambiguous |
| A2 | **Repeatability** (`R_U`) | per-cell CV ≤ **10 %** over ≥ **20** full matrices spanning ≥ **30 min** | Run-1 pair asymmetry was ~4 %; 10 % leaves room for the diode-knee tempco *with* interleaved controls (see A5 and `electronics.md` §5 noise budget) |
| A3 | **Reciprocity** | `\|C_ij − C_ji\|` ≤ **20 %** of the pair mean | Run-1 measured 4 % (10 vs 9.6 mV); 20 % catches a broken channel without failing honest part scatter |
| A4 | **Structure** | the distance gradient `C01 > C02` (row layout) holds in **every** repeat | the one ordering Stage 0 predicts independent of ring efficiency |
| A5 | **Controls, interleaved** | shuffle and off-resonance blocks are **interleaved with active blocks inside each repeat** (A-S-A-O pattern), not batched at the end; both control means < **1/10** of the weakest active cell | slow drift (thermal, battery, diode knee ≈ −1…−2 mV/°C) then cancels in the comparison instead of masquerading as signal — same ABBA logic as the eventual balance runs (`DOCUMENT_C` §1.3) |
| A6 | **Diagonals** | `C_ii` compared only against `C_ii` (repeats and controls), never against off-diagonals | tail-capture volts and peak-capture volts are different scales by design (`electronics.md` §5) |

A run that passes A1–A6 *is* the Milestone-1 receipt. A run that fails stays a
lab-notebook entry (`STAGE0_results_runN.md` style) — no partial credit, per
the ledger's receipt discipline.

---

## 2. Architecture (with your parts)

```
   ┌──────── self-contained PoC ────────┐
   │  Xiao ESP32-C6  (ESPHome)          │
   │   ├─ drive: LEDC PWM (50% duty) → buffer → TX piezo
   │   ├─ read : RX piezo → ×120 amp → peak-detector → ADS1015 (I2C: 4-ch mux + PGA)
   │   ├─ sensors: temp, IMU/accel, magnetometer, battery V
   │   └─ WiFi → Home Assistant (timestamped log = evidence bundle)
   │  3 piezo rings on a 3D-printed nonmagnetic jig
   │  1S LiPo on the XIAO BAT pads (later: untethered)         │
   └────────────────────────────────────┘
   Bench instrument (ground truth, not on the PoC):
     Rigol MHO954 — siggen drives, scope captures real ringdown/Q/phase
```

Two readout paths, on purpose:

- **ESP32 + peak-detector** gives one *amplitude* number per drive burst → the
  coupling-matrix entries C_ij. Slow ADC is fine because the detector holds the
  peak. This is the self-contained PoC path.
- **Rigol scope** gives the full fast waveform (ringdown shape, Q, phase). Use it
  to find resonances and to validate that the peak-detector numbers are real.
  The scope is *bench ground truth*, not part of the flying object.

> Why ESPHome/WiFi is the right call: for the later balance run the PoC must have
> **no force-bearing cable**. Battery + WiFi logging satisfies that for free, and
> Home Assistant gives you clean, timestamped, exportable records (the OPH
> "evidence bundle", `ANS:/answer` §3.12). What you build now is the logging spine
> you'll reuse at the balance.

---

## 3. Build during the day — three stages

### Stage 0 — Characterize the rings on the Rigol (no custom electronics)

You can do this immediately with what's on the bench.

1. Solder a thin wire to each face of one piezo ring (the two silvered
   electrodes). Repeat for all three.
2. **Find resonances:** Rigol siggen → ring (through ~100 Ω series). Sweep
   1 kHz → 1 MHz while watching the current/voltage or the ring's own response on
   the scope. Expect strong modes somewhere in **~20 kHz–500 kHz** (a radial mode
   lower, a thickness mode near a few hundred kHz). Record every resonance f and
   its sharpness (Q).
3. **Ringdown (same-port self-read, manual version):** drive a short burst
   (siggen burst mode, ~20–100 cycles at a resonance), then watch the ring's own
   voltage decay on the scope after the drive stops. That decay *is* the self-read
   signal. Note amplitude and decay time.
4. **Cross-coupling (coupling matrix, manual version):** mount two rings close
   together (touching faces or on a shared plate). Drive ring A, scope ring B.
   Record amplitude/phase for each ordered pair. This is C_ij by hand.

**Stage 0 output:** a table of resonances, ringdown times, and a 3×3
cross-coupling matrix measured on the scope. This already tells us the rings are
usable and fixes the drive frequency for Stage 1. Genuinely useful even if we
stop here for the day.

### Stage 1 — ESP32 reads its own coupling matrix (ESPHome + HA)

Turn the manual measurement into an automated, logged, self-contained loop.

1. **Drive stage:** ESP32 LEDC PWM pin (50 % duty square) → S8050/S8550 push-pull
   → ~100 Ω → TX ring, all on the 3.3 V rail (the swing is set by the base drive,
   not the rail — see `electronics.md` ch. 4).
2. **Read stage (per RX ring):** RX ring → **two-stage ×120 amplifier**
   (MCP6022; the Stage-0 coupled signals are only 2–10 mV — a bare diode cannot
   see them) → Schottky envelope detector (1N5819 → 10 nF hold, 10 MΩ bleed) →
   ADC. A GPIO-driven transistor across the hold cap **resets** it right *after*
   each burst, so each reading is pure post-drive ringdown, never burst
   feedthrough. (Full design + values: `electronics.md` ch. 5.)
3. **Channel select + digitize:** feed each RX peak-detector into a channel of the
   **GY-ADS1015** (I2C; 4-channel internal mux + programmable gain). One I2C ADC
   reads all rings and amplifies tiny peaks — no CD4051, no scarce ESP ADC pins.
4. **State machine (ESPHome script):** for each TX ring → fire a burst at the
   Stage-0 resonance (LEDC at 50 % duty for ~1 ms ≈ 44 cycles @ 43.5 kHz, then
   off) → open all TX switches → **reset pulse ~120 µs after drive-off** → the
   hold caps recharge from pure ringdown → read each RX peak through the mux →
   publish all C_ij to Home Assistant with a timestamp and a run/state label.
   The diagonal C_ii uses a second burst with a ~3 ms tail delay (the driven
   ring saturates its own ×120 amp until the ringdown decays into range).
5. **Repeat** the full matrix many times → that gives R_U (stability). Run two
   controls: **shuffled** (no drive at all — the noise floor) and
   **off-resonance** (full drive at ~29 kHz — same electrical feedthrough, no
   resonance). **Interleave them**: each repeat cycle runs
   active → shuffle → active → off-resonance (A-S-A-O), so slow drift cancels
   in the comparison (threshold A5). Log board temperature with every sweep —
   the weakest cell moves ~2–5 %/°C through the Schottky knee
   (`electronics.md` §5, noise budget).

**Stage 1 output:** automated, timestamped C_ij logged in HA, passing the §1.1
thresholds A1–A6. **That is the Milestone 1 receipt.**

### Stage 2 — preview (Milestone 2, not today)

Designate one ring "top zone", one "bottom zone" (mount them vertically separated
on the jig); add the ACTIVE+ / ACTIVE− / SHAM drive patterns and the
predictive-boundary test (records at cycle *t* predict readout at *t+1* better
than shuffled). That produces the signed ΔS receipt. We'll write its own doc.

---

## 4. Circuit detail (one TX + one RX channel)

```
ESP32 LEDC ──┬── S8050/S8550 push-pull (3.3V rail) ──[100Ω]── TX ring ──┐
             │                                                           │ (coupling)
            GND ───────────────────────────────────────────────────────GND
                                                                         │
RX ring ──[C_in 10n]──[×21]──[×5.7]──[100Ω]──[C_c 100n]──[1N5819]──┬── ADS1015 AINx
   │                  (MCP6022, biased mid-rail)                     │
 [R_ref 1M]                                     [Chold 10nF]──┬──[Rbleed 10M]
   │                                                          │
  GND                                            [reset NPN + 100Ω, GPIO21]
```

One RX amp+detector per ring → ADS1015 AIN0..AIN2 (its internal mux + PGA select
each channel over I2C). **The ×120 amp is not optional** — Stage 0 measured the
coupled signals at 2–10 mV, below any Schottky's knee; the old amp-less sketch
could not read the off-diagonals. Full schematic + values: `electronics.md`
ch. 5 / `peak_detector.svg`.
Keep all grounds common and short. No voltages here exceed a few volts — ordinary
bench safety only. (High-voltage piezo drive, if ever needed, is a later milestone
with its own safety doc, `HOVER:/docs/safety.md`.)

---

## 5. ESPHome config — skeleton

Not complete firmware, but the shape (fill pins from your wiring):

```yaml
esphome:
  name: chi-nu-poc
esp32:
  board: seeed_xiao_esp32c6      # XIAO C6; a XIAO C3 needs its own pin map
wifi: { ssid: !secret wifi_ssid, password: !secret wifi_password }
api:                              # Home Assistant logging
logger:

output:
  - platform: ledc               # drive tone
    pin: GPIO2                   # D2
    id: drive_pwm
    frequency: 43500Hz           # Stage-0 resonance (recheck f_s vs f_p!)

switch:
  - platform: gpio               # peak-detector reset (all channels)
    pin: GPIO21                  # D3
    id: pk_reset

i2c: { sda: GPIO22, scl: GPIO23 }   # the C6's real I2C pins (D4/D5)

ads1115:                         # ESPHome has no ads1015 platform —
  - address: 0x48                # the ads1115 hub drives the ADS1015

sensor:
  - platform: ads1115            # one channel; repeat A0..A2
    multiplexer: A0_GND
    gain: 1.024                  # amped chain → held peaks ~0.05–1 V
    resolution: 12_BITS          # <- this makes it an ADS1015
    id: rx_peak0
    update_interval: never       # read on demand from the script
  # add rx_peak1..2 on A1_GND/A2_GND
  # I2C IMU + magnetometer + temperature + battery-voltage sensors here

script:
  - id: sweep_matrix
    then:
      - repeat:
          count: 3               # for each TX ring i
          then:
            # IMPORTANT: output.turn_on would mean 100% duty = DC, not a tone —
            # always burst with set_level 0.5 (50% square) / 0.0.
            - output.set_level: { id: drive_pwm, level: 50% }
            - delay: 1ms                     # ≈ 44 cycles @ 43.5 kHz
            - output.set_level: { id: drive_pwm, level: 0% }
            # reset AFTER the burst (dump feedthrough, hold pure ringdown);
            # the ~100 µs pulse timing lives in a lambda in the real config
            - switch.turn_on: pk_reset
            - switch.turn_off: pk_reset
            - delay: 2ms                     # settle
            # for each RX ring j: component.update rx_peak, log C_ij
```

This is only the *shape* — the real, complete config is
[`chi_nu_poc.yaml`](chi_nu_poc.yaml) (µs-precise reset timing in lambdas, the
two-burst diagonal capture, the shuffled + off-resonance controls, and the
matrix publishing). Ringdown-shape / Q / phase capture wants custom ESP-IDF
firmware or the Rigol — Milestone-2 territory.

---

## 6. Parts: have vs. order

### Core self-read electronics — fully covered by your stock

| Build block | Use |
|---|---|
| Controller + logging | Xiao ESP32-C6 + ESPHome → Home Assistant (stock) |
| **ADC + channel mux + gain** | **GY-ADS1015** (I2C, 4-ch internal mux, PGA) — removes both the CD4051 *and* the ESP internal-ADC limits (stock) |
| Drive buffer | S8050 + S8550 complementary emitter-follower (or 2N3904/2N3906) — **off the 3.3 V rail** (the rail doesn't set the swing; the base drive does) |
| Drive series R | 100 Ω (1206, stock) |
| **RX amplifier ×120 (×3)** | **MCP6022 / TLV2372 dual RRIO op-amps — ORDER 3.** The measured couplings are 2–10 mV; without this amp the detector reads nothing. LM358 (stock) works as a reduced-gain fallback (~×55, less stable) |
| Peak-detect diode | **1N5819 (SS14)** Schottky — *not* 1N4007 (too slow / high-C) (stock) |
| Hold cap | **10 nF** (1206, stock) — τ = 100 ms with the 10 MΩ bleed |
| Bleed resistor | **10 MΩ** (1206, stock) |
| Detector reset | small NPN (S8050 / 2N3904) across the hold cap via 100 Ω, GPIO21-driven (stock) |
| Power | **one 3.3 V rail from the Xiao** (USB-C bench / 1S LiPo on BAT pads untethered). The 7805/Mini560/2S chain is dropped — 7805 dropout and AMS1117 thermals made it a trap; 5 V is optional for LM358/LM386 experiments only |
| Battery + jig | 1S LiPo + 3D print |
| Precision scale | **not needed for Milestone 1** (torsion-vs-precision decision is Milestone 3/4) |

Everything except the three MCP6022/TLV2372 is on hand; the LM358 fallback lets
you get first light before they arrive.

### Order — sensors only (deferrable past the first receipt)

| Part | Why | When |
|---|---|---|
| I2C IMU (MPU6050 / LSM6DS3) | vibration / accel log | M1 sensor; C_ij works without it |
| I2C magnetometer (QMC5883L) | magnetic-artifact log | essential at the balance, not for the self-read receipt |
| DS18B20 temperature probe | thermal log | M1 nice-to-have; meanwhile read a 1N4148 forward voltage on a spare ADS1015 channel as a crude temp |

### Use-this-not-that notes
- **ADS1015 + ESPHome:** use the **`ads1115:` hub with `resolution: 12_BITS`** —
  ESPHome has no separate ads1015 platform; the ads1115 component drives the
  ADS1015 (verified against the ESPHome docs, 2026-07).
- **Amplify before detecting, not after:** a follower *behind* the diode fixes
  droop but not sensitivity — and with C_hold = 10 nF (τ = 100 ms) droop is a
  non-issue anyway. The gain must come **before** the 1N5819, which is why the
  LM358's role changed from "optional buffer" to "fallback front-end amp".
- **LEDC bursts:** `output.turn_on` = 100 % duty = DC. Always burst with
  `set_level 0.5` / `0.0`.
- **LM386** = optional drive amp for the radial mode only (needs ≥4 V — the
  optional bench 5 V); too slow for a ~400 kHz thickness mode.
- **LM339** on hand if you later want a zero-cross / phase comparator.
- **NE555** could self-generate the drive tone, but ESP-LEDC bursts are better
  (commanded timing + state labels).

### Order (nice-to-have / next milestones)
| Part | Why |
|---|---|
| **3× MCP6022 (or TLV2372)** | the ×120 RX front ends — the one genuinely required order (LM358 = interim fallback) |
| 3–5 **more matching piezo rings** | richer coupling matrix, dedicated top/bottom zones |
| **74HC4066** | low-R_on (~50 Ω) drop-in for the CD4066 at 3.3 V (optional) |
| Small **gate driver / op-amp drive buffer** | stronger, cleaner drive than a bare GPIO |
| **MicroSD breakout** | onboard logging fallback for untethered balance runs (WiFi already covers it) |
| Nonmagnetic plate (acrylic / aluminum) | dimensionally stable carrier vs printed jig |
| INA219 / resistor divider | battery voltage/current monitor for the receipt |

---

## 7. 3D-printed jig (print today)

- A flat plate with three recessed pockets for the rings, fixed spacing, plus a
  shelf for the Xiao + protoboard. PETG or PLA is fine for Milestone 1.
- Keep it **nonmagnetic** (no steel inserts) — habit for later balance runs.
- Make ring spacing a parameter; you'll want to vary coupling later.
- For the Stage-2 top/bottom version, print a variant that holds one ring high and
  one low on a vertical web.

---

## 8. Order of operations today

1. Solder leads to the 3 rings.
2. **Stage 0** on the Rigol → resonance table + ringdown + 3×3 cross-coupling. (No
   ordered parts needed — pure win for the day.)
3. Print the jig.
4. Flash ESPHome to the Xiao; verify WiFi → Home Assistant; check the LEDC drive
   frequency on the Rigol (your scope confirms the ESP32 makes the right tone).
5. Breadboard one TX + one RX peak-detector channel; confirm the ESP reads a peak
   that tracks the scope. (This is the first real self-read.)
6. When the Schottky/mux/op-amp arrive: expand to 3 channels, run `sweep_matrix`,
   log C_ij to HA, add the shuffled control.

Stages 0, 3, 4, and 5 need **only what you already have** — that's a full, useful
day of building before any parts arrive.

---

## 9. What this does *not* claim — and how it hooks into the proof chain

Milestone 1 produces a self-read receipt, nothing more. It does **not** weigh
anything, does **not** test lift, and says nothing about χ_ν yet. Its value:
it builds (and proves) the self-reading object that the whole experiment depends
on — and, per the reasoning in `ANS:/reply_to_bmu.md`, the magnitude of the
record-level ΔS it later produces is exactly what lets us check the ΔS-estimator
bridge empirically.

Where each piece sits in the proof chain
(`../proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md`, v6):

- **What M1 instantiates.** The receipt is the *operational input* to
  `S_coh = 1_self-read·R_U·P_U·C_U` (`DOCUMENT_A` §3.5). The record-side
  object that quantity feeds — the finite coherent-source generator, whose
  increment is what the collar prices — exists as a machine-checked formal
  object (`proof_chain/formal/OPHProofChain/DeltaSBridge.lean`, T17). M1
  supplies the *receipts*; what number of record-activations corresponds to
  how much gravity-side ΔS is exactly the open gap **G9** — which is why a
  later null bounds only the product χ·ΔS.
- **What M1 tests of the theory: nothing.** Both the proven OPH core and the
  conditional χ_ν continuation predict that a competently built self-read
  loop passes A1–A6 — this milestone is instrumentation, and a failure here
  would say "build problem", not "theory refuted". The first
  theory-adjudicating step is the Milestone-4 weighing, whose conversion
  constants are theorem-form (`LedgerNumerics.lean`, T24: the 5.50×10⁸ N
  per unit Δν, the 9.1×10⁻¹⁷ lock-in floor) and whose expected outcome is
  **NULL** by the conservation cage (`EnergyCage.lean`, T10; chain §5) —
  a genuine DETECT must arrive with a ≥ 3.5 MJ-scale energy-ledger entry.
- **Why build it anyway.** A null with a *passing* self-read gate is
  informative (it prices χ·ΔS at ≤ 9.1×10⁻¹⁷ on this coupon); a null on a
  coupon that failed the gate is worthless — OPH predicts null there too
  (`DOCUMENT_A` §3.5). M1 is what makes the eventual null *mean something*.
