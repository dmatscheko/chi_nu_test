# Document C — Run Matrix, Measurement Method, and Error Budget

**χ_ν coherent-matter lift test · companion to Document A**

| | |
|---|---|
| Status | DRAFT — not yet locked |
| Version | 0.2.1 (2026-07-07: Part 7 energy-budget logging now cites the named G10-convention audit scale per proof-chain v6.1/v7; 0.2 of 2026-07-05 and v0.1 are in git) |
| Companion to | `DOCUMENT_A_prediction_ledger.md` (governs interpretation) |
| Governs | apparatus sensitivity F_min, the run sequence, and the analysis |

> Path shortcuts (`OPH:/`, `HOVER:/`, `ANS:/…`) are defined in Document A.
> The primary method is a **no-cables ABBA** comparison of ACTIVE± against a
> power-matched SHAM state **within one self-contained, battery-powered,
> self-reading PoC** (A §3.1). The dummy is an artifact control, never the
> mass baseline. A balance null bounds χ_ν·ΔS — χ_ν alone only given the
> ΔS-estimator bridge (A §3.2).

## Purpose

Document A leaves the apparatus force resolution F_min symbolic. This document
fixes F_min for a specific balance and method, derives the detection floor,
and specifies the run sequence and analysis. Nothing physical originates here
except the apparatus model and the statistics.

---

## Part 1 — Imported quantities (no new physics here)

| Symbol | Value | Source |
|---|---|---|
| C_geom = g²/(4πG) | 1.146637×10¹¹ N m⁻² | A §1.1 (← `OPH:/extra/chi_nu_susceptibility_bounds.tex:1347–1361`) |
| Force law | F = C_geom·A·Δν, Δν = χ_can·ΔS_coh^can | A §1.5 |
| Detection floor | Δν_min = F_min/(C_geom·A) | A §4.2 / §1.6 |
| χ_can null bound | χ_can ≤ Δν_min/ΔS_coh^can (given the bridge) | A §4.4 |
| Theorem floor under test | χ_can ≥ 0.9343006394893864 | A §1.4 |
| Coupon area (baseline) | A = 4.8×10⁻³ m² (one zone, 80×60 mm) | A §3.1 |
| Conservation-law priors | NULL expected; toggle-energy logging required | A §1.9 |
| Controls / data per run | control matrix + data list | `HOVER:/docs/acceptance.md`; Part 7 |
| Safety | HV, brittle substrate, magnets | `HOVER:/docs/safety.md` |

---

## Part 2 — The chosen instrument

### 2.1 Primary balance (baseline)

**Analytical balance, 0.1 mg readability, below-balance weighing hook, digital
output** — reference model Sartorius Quintix224-1S (equivalents fine: Mettler
MS204TS, Kern ADB; the requirements matter, not the brand):

| Property | Required |
|---|---|
| Readability d | ≤ 0.1 mg |
| Repeatability (1σ, single reading) | ≤ 0.1 mg |
| Capacity | ≥ 50 g |
| **Below-balance weighing hook** | required |
| Data interface | RS232/USB, ≥ 5 readings/s streaming |
| Internal calibration | + class-E2 check weights |

Force-equivalent of one reading (d = 0.1 mg = 1×10⁻⁷ kg):
`σ₁ = d·g = 9.81×10⁻⁷ N ≈ 1×10⁻⁶ N`.

**Why self-contained, no cables:** the PoC carries battery, MCU and logger;
no power or data cable touches it during weighing (A §3.1). This removes the
single biggest artifact of tethered rigs *by design*. State changes run from
the onboard schedule or a non-contact trigger.

### 2.2 Optional upgrades (only if Part 5 returns NULL and a deeper bound is wanted)

- Semi-micro balance (0.01 mg): σ₁ ≈ 1×10⁻⁷ N → 10× deeper.
- Torsion balance in vacuum (mirror + autocollimator): F_min ~ 1×10⁻⁹ N.

### 2.3 Environment

- Closed draft shield baseline (`ANS:/answer` §3.5); a small **vacuum
  chamber / bell jar (a few mbar) is strongly recommended** — kills convection
  and acoustics together and enables the R8 air↔vacuum gate.
- Grounded Faraday liner (electrostatics); guard ring near the pan.
- Nonmagnetic fixture; all ferromagnetic parts ≥ 0.3 m from the coupon's
  magnetic hardware (`HOVER:/docs/safety.md`).
- Vibration-isolated bench; log chamber pressure and two temperatures
  (coupon, frame).

---

## Part 3 — Measurement method: power-symmetric ABBA (no cables)

### 3.1 The comparison: ACTIVE± vs SHAM within one object

A static "weigh active, weigh dummy" comparison fails twice — balance drift
(0.1–0.5 mg/min) and unequal true masses. The method (`ANS:/answer` §3.7–3.8):

- **Compare states within the same physical PoC.** The baseline state is
  **SHAM-PWR**: same average power as ACTIVE, dissipated incoherently
  (resistive load / phase-scrambled drive) — heat, current, RF envelope and
  battery load match; only the coherent self-read mode is absent.
- The **ABBA estimator** cancels slow drift:
  `Δm_X = mean(X1, X2) − mean(SHAM1, SHAM2)`, using the stable window of each
  state after a preregistered settling discard.
- Draft shield stays closed for a whole block; states are switched by the
  onboard schedule.

### 3.2 The discriminators (what carries the result)

A one-direction Δm can be heat, charge or acoustics. A real χ signal must
satisfy the conjunction (A §3.7–3.8): ACTIVE+ gives the declared sign;
ACTIVE− reverses it at matched power; **FLIP** (invert the PoC) reverses it
relative to gravity; the **DUMMY** stays null on the same script; and the
magnitude **scales with the measured ΔS_coh^can**, not with raw input power.

> Magnetic bias stays **fixed** across ACTIVE±/SHAM — reversing a magnet flips
> a real magnetic force and would mimic the signal. Magnetic-bias reversal is
> tested separately (R7) with a magnetic dummy.

### 3.3 Mandatory pre-test (before any weighing)

The PoC must emit its **self-read receipt** (A §3.5): reproducible coupling
matrix standing above **both** controls (shuffled = noise floor;
off-resonance = electrical-crosstalk floor), record stability R_U, predictive
boundary P_U (beats shuffled records / dummy), state-dependent coherence C_U,
and separate S_top/S_bottom giving a **signed ΔS_coh^can that reverses under
ACTIVE−**. Implementation: [`build/`](../build/README.md) (Milestone 1, rev-2
electronics). **No receipt ⇒ no balance interpretation** (outcome UNDEFINED,
A §4.7).

### 3.4 Optional offline lock-in (deeper floor, same data)

The onboard schedule is timestamped, so the balance stream can also be
demodulated against the ACTIVE±/SHAM square wave offline:
`F_demod = (1/N)Σ[w(tᵢ)−w̄]·s(tᵢ)`, σ_F from quadrature and off-frequency
bins; the **2·f bin** catches the charge-squared electrostatic artifact
(Part 6). The ABBA number stays the auditable headline.

### 3.5 Noise floor

```
σ_F (lock-in) ≈ σ₁ · √(2/n_eff),   n_eff ≈ 1800 over 1 h
```

(≥ 5 readings/s = 18 000 raw samples; balance readings are correlated over
~1 s, so n_eff ≈ T/2τ_corr ≈ 1800; √2 is the two-state differencing penalty.)

- **ABBA headline** (0.1 mg balance, multi-quad hour): F_min ≈ **1×10⁻⁷ N**.
- **Offline lock-in** (same data): statistical term ≈ 3.3×10⁻⁸ N; quoted
  **F_min = 5×10⁻⁸ N** carries the residual systematic allowance.

Both are far below any predicted force (Part 4): resolution is not the
obstacle; artifact rejection is (`ANS:/answer` §3.9).

---

## Part 4 — Detection floor and the Document A Part 4 numbers

Δν_min = F_min/(C_geom·A). **Baseline = one-zone coupon, lock-in.**

| Coupon | A [m²] | C_geom·A [N] | Method | F_min [N] | Δν_min |
|---|---|---|---|---|---|
| one-zone 80×60 mm | 4.8×10⁻³ | 5.50×10⁸ | static A/B | 1×10⁻⁶ | 1.8×10⁻¹⁵ |
| **one-zone 80×60 mm** | **4.8×10⁻³** | **5.50×10⁸** | **lock-in 1 h** | **5×10⁻⁸** | **9.1×10⁻¹⁷** |
| one-zone 80×60 mm | 4.8×10⁻³ | 5.50×10⁸ | torsion (opt.) | 1×10⁻⁹ | 1.8×10⁻¹⁸ |
| small 20×20 mm | 4.0×10⁻⁴ | 4.59×10⁷ | lock-in 1 h | 5×10⁻⁸ | 1.1×10⁻¹⁵ |
| full board (ref only) | 6.3×10⁻² | 7.22×10⁹ | lock-in 1 h | 5×10⁻⁸ | 6.9×10⁻¹⁸ |

### 4.1 Margin against the OPH prediction (baseline coupon, lock-in)

| OPH Δν (source) | F_pred | gf | margin F_pred/F_min |
|---|---|---|---|
| 3.4×10⁻¹⁰ hover threshold | 0.187 N | 19 | 3.7×10⁶ |
| 1.0×10⁻⁹ design target | 0.550 N | 56 | 1.1×10⁷ |
| 3.0×10⁻⁹ stretch | 1.65 N | 168 | 3.3×10⁷ |

The apparatus over-resolves the smallest OPH-predicted force by ~10⁶–10⁷;
A §4.3's margin ≫ 1 requirement is met with six to seven orders to spare.

### 4.2 What a null proves (baseline coupon)

With ΔS_coh^can measured per run (A §3.2/§3.5), a balance null gives

```
χ_can·ΔS_coh^can ≤ Δν_min = 9.1×10⁻¹⁷            (always)
χ_can ≤ Δν_min/ΔS_coh^can(measured)               (given the bridge)
```

e.g. reported ΔS = 1×10⁻⁹ → χ_can ≤ 9.1×10⁻⁸ — seven orders below the 0.9343
floor, excluding the Tier-C band for this substrate. Without the bridge it is
still a clean bound on the product χ_ν·ΔS.

---

## Part 5 — The run matrix

Run states (`ANS:/answer` §3.6): OFF, SHAM-PWR, ACTIVE+, ACTIVE−, FLIP, DUMMY,
plus heater-only. Primary comparison: ACTIVE± vs SHAM within the same object
(ABBA). Log every run per `HOVER:/docs/acceptance.md` + Part 7.

| ID | Config | States (ABBA) | Env | Primary statistic | OPH predicts | Null predicts |
|---|---|---|---|---|---|---|
| **R-pre** | active PoC, bench | self-read receipt (§3.3) | shield | R_U, P_U, C_U, signed ΔS | nonzero; sign reverses under ACTIVE− | gate fails → stop (UNDEFINED) |
| **R0** | inert mass + E2 weights | none | shield/vac | σ_F, drift, calibration | establishes F_min | establishes F_min |
| **R1** | **active** | ACTIVE+ / SHAM | shield/vac | Δm (ABBA) | declared sign; F tracks ΔS | 0 |
| **R2** | active | ACTIVE− / SHAM | shield/vac | Δm sign | reverses vs R1 | 0 |
| **R3** | active, inverted | ACTIVE+ / SHAM | shield/vac | Δm sign | reverses vs R1 (gravity ref) | 0 |
| **R4** | **dummy** (no self-read) | ACTIVE-labeled / SHAM | shield/vac | Δm | null / < 10 % of active | 0 |
| **R5** | active + heater-only | heater / SHAM | shield/vac | Δm | thermal artifact quantified | — |
| **R6** | active, varied stored state / area | ACTIVE± / SHAM | shield/vac | Δm vs measured ΔS | F ∝ ΔS_coh^can | 0 |
| **R7** | active + magnetic dummy + guard; 2·f analysis | ACTIVE± / SHAM | vac | f vs 2·f; guard on/off | χ tracks ACTIVE±, not 2·f | electrostatic at 2·f / magnetic in dummy |
| **R8** | air↔vacuum; 2nd operator; blind labels | ACTIVE± / SHAM | air & vac | Δm(air)−Δm(vac); blind | unchanged; survives blind | artifact in air / vanishes blind |

Notes:
- A null on a PoC that **passed R-pre** is a real bound; a null on one that
  failed R-pre is uninformative (OPH predicts null there too).
- R4/R5 are artifact controls, never mass baselines.
- R8 air↔vacuum is the decisive convection/acoustics gate.
- Candidate lift requires the full conjunction (A §3.8): R1 sign + R2
  reversal + R3 flip + R4 dummy null + R5/R7 artifact rejection + R6 scaling +
  R8 replication.

---

## Part 6 — Error budget

Per term: rough size, whether it survives the discriminators (flips with
ACTIVE±? reverses under FLIP? absent in dummy?), and the mitigation.

| # | Term | Rough magnitude | State-correlated? | Mitigation |
|---|---|---|---|---|
| 1 | Balance drift / zero | 10⁻⁶–10⁻⁵ N /min | no (slow) | ABBA/lock-in reject; R0 quantifies |
| 2 | Thermal buoyancy of warm coupon | up to ~10⁻⁵ N in air | no* | SHAM-PWR is power-matched by construction (§3.1) → no heat modulation; R5 quantifies residue; vacuum removes |
| 3 | Acoustic streaming / radiation | up to ~10⁻⁴ N in air (if driven) | maybe | vacuum (R8); static pre-stress baseline; below-hook standoff |
| 4 | Electrostatic image force | 10⁻⁶–10⁻⁴ N near grounded parts | **at 2f** | ∝ charge² → lands at 2f, not f; Faraday + guard; R7 |
| 5 | Magnetic attraction to fixture | mN if steel nearby | only if bias toggled | bias fixed inside comparisons; nonmagnetic fixture; magnetic dummy (R7); ≥ 0.3 m rule |
| 6 | Cable/tether force | — | — | **eliminated by design** (no cables, A §3.1) |
| 7 | Fixture thermal expansion | small | no (slow) | out of band; temperatures logged |
| 8 | Balance nonlinearity / calibration | %-scale on magnitude | no | affects scale not detection; E2 cal in R0 |
| 9 | Seismic / vibration | varies | broadband | isolated bench; averaging |

\* Reaches the modulation only if the state change carries a dissipated-power
change; SHAM-PWR exists precisely to prevent that.

**Combined floor:** the statistical term (3.3×10⁻⁸ N) dominates once the terms
above are out of band or out of phase; the quoted F_min = 5×10⁻⁸ N carries
the residual allowance. The two terms that can reach the modulation
(electrostatic, cable) are handled by phase (2f), guarding, and design
(no cables), and are bounded in R7 below F_min.

---

## Part 7 — Blind analysis & data package

- **Blinding (R8, ideally R1–R2 as well):** the analyst receives the weight
  series with a scrambled label/sign log; true labels are revealed only after
  F and σ_F are emitted. (Same discipline the OPH falsifiability ledger
  applies to its hardware tests, `OPH:/extra/OPH_falsifiability.md:610–630`.)
- **Data package per run** (per `HOVER:/docs/acceptance.md` "Data Required Per
  Run", plus): material stack & zone map, mass & area, drive waveform /
  V / I / power / duty, pre-stress estimate, force trace, temperature and
  pressure traces, the self-read receipt (coupling matrices vs both controls,
  R_U/P_U/C_U scores, signed ΔS series), the state-schedule reference series,
  the analysis notebook, photos.
- **Energy budget (new in v0.2, per A §1.9; v6.1 note):** log battery
  voltage & current through every state toggle; report the per-toggle
  energy and the block energy balance alongside any force result. On a
  NULL this quantifies G10; on a candidate it is the first thing reviewers
  will ask for. Reconciliation standard (per A §1.9 as revised after the
  adversarial audit's F15): the theorem-grade minimum is the realized
  cycle work (≈ 0 for fixed-height balance blocks; ΔM·g·Δh for any
  transport cycles); the ≈ 3.5 MJ-per-toggle figure is the **named
  G10-convention** audit scale, carried as a hypothesis of the decision
  layer.
- **Classification** per A Part 5 ↔ `HOVER:/docs/acceptance.md`
  (null / ordinary / instrumental / candidate / accepted).

---

## Part 8 — Lock checklist (this document)

- [ ] Balance model + below-hook + data rate confirmed (Part 2)
- [ ] F_min for the chosen method recorded (Parts 3–4)
- [ ] Coupon area A confirmed with Document A §3.1
- [ ] **R-pre receipt passed and archived** (§3.3; both controls)
- [ ] Δν_min, margin, χ_can null bound computed into Document A §4.2–4.4
- [ ] Energy-budget logging configured (Part 7; A §1.9)
- [ ] Run matrix dates/operators assigned (Part 5)
- [ ] Vacuum, Faraday, nonmagnetic fixture verified (Part 2.3)
- [ ] Blind procedure agreed (Part 7)
- [ ] **ΔS-estimator-bridge caveat acknowledged by both sides** (A §3.2; B G9)
- [ ] Locked alongside Document A; same lock hash recorded

- Experimenter: _______________________  date: __________
- OPH theory representative (ack.): _______________  date: __________
