# Document A: Prediction Ledger (Pre-Registration)

**χ_ν coherent-matter lift test · BTTF-chi mechanism**

| | |
|---|---|
| Status | DRAFT: not yet locked |
| Version | 0.2.2 (2026-07-07; v0.2/v0.2.1 and the v0.1 correction pass are in git) |
| Date created | 2026-06-02 |
| Date locked | _____________ (no edits to Parts 1–4 after this date) |
| OPH theory representative (predictions) | _____________ |
| Experimenter (apparatus) | _____________ |
| Lock hash (sha256 of this file at lock) | _____________ |

> **What changed in v0.2.** The 2026-06-02/03 question-and-answer history is
> compressed to its resolved state; all source line references are re-anchored
> to the current tex files; a numeric error in the §3.4 sanity rail is fixed;
> and the conservation-law constraints are disclosed up front (§1.9). The
> decision rule (Part 5) is unchanged in substance. **v0.2.1 (2026-07-06):**
> after the OPH-side `proof_chain/AUDIT_RESPONSE.md` and the July paper consistency pass,
> all `chi_nu_susceptibility_bounds.tex` anchors are re-anchored to the
> restructured file (now 1860 lines, Tier B split into B0/B1, lemmas L1–L7),
> and §1.3/§1.4/§1.7 reflect the new theorem surface. Audit trail:
> `proof_chain/AUDIT_RESPONSE.md` and git history (which also holds the former
> `CORRECTIONS_2026-07-05.md`, absorbed at the v3 reorganization).
> **v0.2.2 (2026-07-07): status-citation notes only.** The proof chain is now
> v4: its `formal/` Lean tree machine-proves the whole mathematical side of
> the chain (0 `sorry`, incl. the OPH core's three, discharged in an
> attributed in-repo copy). §1.4, §1.5 and §1.9 gain machine-checked-status
> notes pointing at `proof_chain/formal/`. **No number, threshold, disclosure
> or decision-rule text changed.**
> **v0.2.3 (2026-07-07): the G10-convention naming and one erratum.** Per the
> adversarial audit (F15/F28): §1.9 restructured to name the **G10-convention**
> pricing as the decision-layer hypothesis it is, with the theorem-grade
> anchors stated beside it (machine-checked in v7: `anchor_ordering`); the
> printed battery-coupon ceiling corrected from "≲ 1×10⁻¹¹ (≈ 0.5 gf)" to
> "≲ 1.1×10⁻¹¹ (≈ 0.58 gf)" (erratum note in place, `battery_coupon_bounds`).
> One number changed (the erratum, in the unsafe-to-omit direction); no
> threshold or decision-rule text changed. §1.4's hypothesis family now reads
> L0–L7 (L0 = the named collar-shape clause).

## Source repositories (path shortcuts)

| Shortcut | Repository (cloned dir) | Upstream | Typical subpaths |
|---|---|---|---|
| `OPH:/` | `observer-patch-holography/` | https://github.com/FloatingPragma/observer-patch-holography | `OPH:/paper/`, `OPH:/extra/`, `OPH:/cosmology/`, `OPH:/LEAN/` |
| `HOVER:/` | `hoverboard/` | https://github.com/muellerberndt/hoverboard | `HOVER:/docs/`, `HOVER:/bom/` |
| `ANS:/` | `chi_nu_test/communication/` (absorbed into this repo 2026-07-06; history at https://github.com/dmatscheko/hoverboard-experimental-precursor) | Q&A with OPH-side research | `ANS:/`, `ANS:/input_from_bmu/` |
| `ANS:/answer` | `communication/input_from_bmu/chi_nu_lift_test_answer_and_experiment.pdf` | OPH-side answer + balance protocol (2026-06-03) | cited by § number |
| `ANS:/guide` | `communication/input_from_bmu/hacking-the-simulation-anti-gravity-exploit.pdf` | OPH-side research draft (2026-06-03) | cited by chapter title |

The trailing `:` marks a prefix as a repo shortcut, never a real directory.
Our own repo is laid out as **`test/`** (the pre-registration ledgers
`DOCUMENT_A/B/C`, this file's directory), **`proof_chain/`** (the audit work:
`OPH_CORE_MINIMAL_PROOF_CHAIN.md`, `AUDIT_RESPONSE*.md`, corrections log),
**`build/`** (Milestone-1 hardware) and **`communication/`** (the Q&A with the
OPH side, = `ANS:/`). Bare filenames refer to files in the same directory;
cross-directory prose uses repo-root-relative paths.

## Purpose

This document fixes, **before any data is taken**, exactly what the χ_ν lift
mechanism predicts for our coupon, so that neither side can re-interpret the
result after the fact. It does three things:

1. **Imports the OPH math verbatim** (Parts 1–2) with file/line provenance,
   so the prediction is *OPH's*, not our paraphrase.
2. **Records the inputs only the OPH side can supply** (Part 3), filled
   with the agreed 2026-06-03 answers.
3. **Derives the falsifiable predictions** (Part 4), including the detection
   threshold and the bound a null places on the OPH coefficient.

Parts 1, 2 and 4 are computed/imported and fixed at lock; Part 3 is the only
place free choices enter. The pre-registered decision rule is Part 5.
Background: the standing of every imported claim (proven / conditional /
asserted) is assessed in [`proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md`](../proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md);
open questions and credit are ledgered in
[`DOCUMENT_B_critique_ledger.md`](DOCUMENT_B_critique_ledger.md); the
apparatus, run matrix and error budget are
[`DOCUMENT_C_run_matrix_and_error_budget.md`](DOCUMENT_C_run_matrix_and_error_budget.md).

---

## Part 1: Imported constants and equations (OPH math)

All references are to the cloned repositories; equation tags are the LaTeX
labels in the source. Line anchors verified 2026-07-06 (post-restructure).

### 1.1 Fixed physical constants

| Symbol | Value | Source |
|---|---|---|
| g | 9.80665 m s⁻² | `OPH:/extra/chi_nu_susceptibility_bounds.tex:1359` |
| G | 6.67430×10⁻¹¹ m³ kg⁻¹ s⁻² | `:1360` |
| C_geom ≡ g²/(4πG) | **1.146637×10¹¹ N m⁻²** | `:1347–1361` (cor. `geometric-ceiling`) |
| 4πG | 8.387173×10⁻¹⁰ m³ kg⁻¹ s⁻² | derived |

### 1.2 OPH readout numbers

| Symbol | Value | Source |
|---|---|---|
| P (screen-cell area a_cell/ℓ★², the OPH "pixel-area ratio") | 1.630968209403959 | `OPH:/extra/chi_nu_susceptibility_bounds.tex:1109–1116` (eq. `z6-reserve`) |
| P/24 | 0.06795700872516496 | same |
| χ_can^exact = e^(−P/24) | **0.9343006394893864** | `:1190–1210` (cor. `chi-can-exact`) |
| u₀ (reference energy density) | 8.5×10⁻¹⁰ J m⁻³ | `:1462, :1620` (table captions only) |

> **Provenance (refined 2026-07-06 after tracing the code).** The corpus holds
> **two** values of P on two labeled branches
> (`OPH:/extra/fine_structure_constant_derivation.tex`; executable in
> `OPH:/code/P_derivation/`, reproduced by us): a genuine zero-empirical-input
> fixed-point solver outputs **P_root = 1.6309721** with α⁻¹ = 136.9948 (~300
> ppm from measurement), while the published **P = 1.630968209403959… is by
> definition φ + √π/137.035999177**, i.e. a restatement of the measured
> CODATA α (the repo's own calibration file marks `external_input_used: True`).
> The value imported here is the published (CODATA-calibrated) one, per the
> OPH side's χ_ν convention. **This choice is immaterial for this experiment:**
> the two branches shift χ_can = e^(−P/24) by only ~1.6×10⁻⁷ relative
> (0.93430064 vs 0.93430049), far inside every tolerance in Part 4. u₀ is a
> declared reference density. (Arithmetic verified: P/24, e^(−P/24), C_geom as
> quoted. Full adjudication: `proof_chain/AUDIT_RESPONSE_REVIEW.md` §P.)

### 1.3 The continuation law (Tier B)

The local response law the mechanism rests on
(`OPH:/extra/chi_nu_susceptibility_bounds.tex:342`, eq. `chinu-law`; `:540`,
eq. `continuation-axiom`):

```
ν_eff(x,t) = ν_OPH(x,t) + χ_can · S_coh^can(x,t)
                        = ν_OPH(x,t) + χ_eng · S_coh^eng(x,t)
```

with charts related by `χ_eng = χ_can/N_coh`, `S_coh^eng = N_coh·S_coh^can`,
`N_coh = ε_sub·u_stored/u₀` (`:547, :516, :508`). Because
`χ_eng·S_coh^eng = χ_can·S_coh^can`, the engineering chart is an exact
rescaling with no independent content, confirmed by the OPH side
(`ANS:/guide` "The Susceptibility Coefficient"). We work in the **canonical
chart** throughout: the physics sits entirely in χ_can (fixed by the Tier-C
branch) and S_coh^can (measured, §3.2).

> **Tier structure upgrade (2026-07-06).** The July paper pass splits
> Tier B in two (`:319–351`): **Tier B0**, a *finite source theorem*: under
> the named hypothesis **Scalar Edge-Center Exhaustion** (SEE), every
> nondegenerate self-reading material source is forced into the same scalar
> register the dark-sector collar prices (screen paper `:817–840`), and the
> weak-field response then has the *unique* linear form above (`:842–864`);
> so the **form** of the law is derived on the branch, not merely
> declared; **Tier B1**, the response law with χ still unassigned. The
> conditionality is thereby concentrated into SEE + the Tier-C branch.

### 1.4 The coefficient under test (Tier C)

Granting the dark-sector collar lemmas **L0–L7** (L0 the named icosahedral-shape clause, added in v6.1)
(`OPH:/extra/chi_nu_susceptibility_bounds.tex:1021–1210`):

```
0.9343006394893864 ≤ χ_can ≤ 1          (cor. chi-can-band, :1170, under L1–L6)
χ_can = e^(−P/24) = 0.9343006394893864  (cor. chi-can-exact, :1199, adds L7)
```

**This band is the falsification target.** It is *conditional*, and the
conditionality is precise: L2–L4 are imported theorems from
the screen paper **under SEE** (scalar-channel exhaustion / same-register
commutation); L5 is a declared Poisson branch; L6 fixes the scalar-weighted
reserve mean to P/24; **L7** is the *uniform product-thickening branch*
whose slice-wise reserve-unbiasedness is exactly what licenses the exact value
(screen paper `:1300–1411`, with a receipt ledger `:1475–1492` forbidding
exact-value claims without it, and an explicit remark that uniformity is
*stronger* than the trace condition). The dark-matter paper's Correction Audit
(`OPH:/cosmology/oph_dark_matter_paper.tex:2304–2338`) tabulates that
e^(−P/24) sits between the binned-RAR and common-empirical-a₀ preferred
values and cannot reach the latter without ~13 % more reserve. The experiment
tests whether the substrate's response is consistent with χ_can anywhere in
[0.9343, 1].

> **Machine-checked status (v0.2.2, proof-chain v4).** Both the *digits* and
> the *conditional structure* above are Lean theorems: e^(−P/24) =
> 0.9343006… to 9 digits (`proof_chain/formal/OPHProofChain/PBranches.lean`),
> and L-clause unbiasedness ⇒ exactly e^(−P/24), with the [e^(−P/24), 1]
> Jensen band under the weaker mean condition
> (`proof_chain/formal/OPHProofChain/CollarGate.lean`). The conditionality of
> this target therefore rests *entirely* on the L-clauses themselves. The
> band and the falsification target stand as stated.

### 1.5 The force law

Planar response theorem
(`OPH:/extra/chi_nu_susceptibility_bounds.tex:1311–1345`, eq. `force-law` at `:1325`):

```
F_χ = C_geom · A_perp · Δν ,   Δν ≡ χ_can·ΔS_coh^can ,
ΔS_coh = (S_coh)_bottom − (S_coh)_top          (:1313, :1343)
```

> **Derivation status (disclosed at import).** `force-law` has no derivation from
> local dynamics: it inserts the continuation into the weak-field
> effective-density identity `ρ_A = −(1/4πG)∇·[(ν−1)g_b]`
> (`OPH:/cosmology/oph_dark_matter_paper.tex:835–841`), an exact rewriting of
> Poisson's equation, and **reads the resulting phantom mass as a weight
> change of the device itself**. That attribution is a postulate, conceded by
> the OPH side ("the local force is a continuation, not derived"; Document B
> G5). Its lever is transparent: a step Δν across the faces is equivalent to a
> phantom surface density σ = Δν·g/(4πG) ≈ 11.7 kg m⁻² per Δν = 10⁻⁹. The
> experiment *tests* the attribution; nothing here assumes it.
> *(Status note, v0.2.2: the two derived steps around the postulate are
> machine-checked: the effective-density identity as exact bookkeeping and
> the thin-device integration to `force-law`
> (`proof_chain/formal/OPHProofChain/DarkSector.lean`: `phantom_bookkeeping`,
> `thin_device_force`), and σ as the interval (11.6, 11.8) kg m⁻²
> (`…/EnergyCage.lean`). The **attribution itself is the postulate under
> test**.)*

Engineering construction variable, for cross-checks only
(`:1376`, eq. `Gamma-definition`): `ΔS_coh^eng = Γ_eff·(u/u₀)`, 0 ≤ Γ_eff ≤ 1.
The paper also carries **source-lift falsifiers** (`:1696–1719`): five
operational tests any material lift claim must survive (record-shuffled dummy,
relabeling invariance, register identity, receipt-zero vs force, signed-flip
tracking), adopted implicitly by our run matrix (Document C Part 5).

### 1.6 Null-result bound formula (OPH's own)

A null at force sensitivity F_min over area A
(`OPH:/extra/chi_nu_susceptibility_bounds.tex:1651`, eq. `null-bound-general`):

```
Δν ≤ Δν_min ≡ F_min / (C_geom · A)
χ_can · ΔS_coh^can ≤ Δν_min                    (always)
χ_can ≤ Δν_min / ΔS_coh^can                    (given the §3.2 bridge)
```

A back-solved χ_can bound < 0.9343 excludes the Tier-C band (§1.4).

### 1.7 Null conditions on the scalar (the exemption clause)

Matter without observer structure gives zero scalar, hence zero force
(`OPH:/extra/chi_nu_susceptibility_bounds.tex:568–580`, prop. `chi-null-conditions`;
core scalar `:473`, eq. `canonical-core`):

```
S_coh^can = 1_self-read · R_U · P_U · C_U
S_coh^can = 0  if (no self-read) OR (no stable records) OR (no predictive boundary coupling)
```

and such configurations "impose no bound on χ" (`:1668–1680`). The paper
also carries the full **finite coherent-matter source
generator** (`:625–746`): the self-reading subfederation, its scalar-slot
footprint ("not a new field": a quotient-visible map, descent proof in the
section's Lemma B.6), and the source generator; the *definition side* of
the ΔS bridge is thus first-party paper content. **This clause
is load-bearing**: it is the only thing exempting the active coupon from the
existing null corpus of precision-weighed piezo/ferroelectric devices. OPH
defines self-read operationally, as a **self-bounded read-write substrate**
(the same ports emit and read; H1/H2 device bounds,
`OPH:/extra/thinking_as_patch_net_fixed_point_search.tex:2218–2234`; observer
tuple with records and checkpoints,
`OPH:/paper/screen_microphysics_and_observer_synchronization.tex:94–148`), and
never as a material property. §3.5 therefore uses the read-write loop as
the operational criterion, and the dummy differs from the active coupon in
exactly that loop (§3.6).

### 1.8 Terrestrial baseline

On Earth `g_b/a₀ ~ 10¹¹`, so ν_OPH is pinned to unity (suppression is
hyper-exponential in the activation law) and the ordinary OPH dark sector
reads **null** on a tabletop
(`OPH:/extra/chi_nu_susceptibility_bounds.tex:423–426`; activation law and
limits: `OPH:/cosmology/oph_dark_matter_paper.tex:681–751`). The χ_ν
continuation is tested against a null baseline as a separate, added effect:
it is **not** a prediction of the recovered OPH core, which leaves χ_ν unfixed
(`OPH:/extra/chi_nu_susceptibility_bounds.tex:319–325`, Tier A).

### 1.9 Conservation-law constraints (disclosed prior physics)

Independent of any apparatus, a vertical force controlled by an internal
switchable state obeys `F = −∇E_state`, so `E_state = ΔM·Φ_N(z) + const` with
`ΔM = F/g`. Two exhaustive cases
(full derivation: `proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md` §5,
in theorem form, with the numbers below as machine-checked
intervals: `proof_chain/formal/OPHProofChain/EnergyCage.lean`):

- **height-independent toggle cost** ⇒ an ACTIVE-on / rise / ACTIVE-off /
  descend cycle extracts F·h per pass: perpetual motion. *What the cycle
  theorems themselves force* (proof-chain v6.1, after the adversarial
  audit's F15): a ledger entry at the scale of **realized cycle work**:
  ΔM·g·Δh ≈ 0.55 J per metre of stroke at the design point; ≈ 0 for the
  balance protocol at fixed height.
- **the G10-convention** *(named pricing hypothesis of this decision
  layer, not a consequence of the cycle theorems)*: each ACTIVE toggle is
  priced as the full infinity-referenced interaction transaction
  |ΔM·Φ_N| ≈ **3.5 MJ for the 56 gf design point** (Φ_N ≈ −6.3×10⁷ J kg⁻¹):
  ~1 kg-TNT-scale heat/work per state change, never observed in any
  piezo. (Pricing genuine source *creation* relativistically would give
  ΔM·c² ≈ 5×10¹⁵ J instead; the convention adopts the interaction-energy
  reading as the audit scale.) Under this convention a battery-powered
  coupon (E_batt ~ 3.6×10⁴ J) can source at most
  **χ·ΔS ≲ 1.1×10⁻¹¹** (≈ 0.58 gf) per toggle.
  > *Erratum (2026-07-07):* the v0.2.2 print read "≲ 1×10⁻¹¹ (≈ 0.5 gf)". The
  > interval-checked value is (1.02–1.03)×10⁻¹¹ (0.575–0.578 gf), so that
  > print understated the coupon ceiling by ≈ 2.5 %, the unsafe direction for a
  > discrimination bound. Machine-checked:
  > `proof_chain/formal/OPHProofChain/LedgerNumerics.lean`
  > (`battery_coupon_bounds`).

Consequence, agreed by both sides at lock: a NULL is the theoretically
expected outcome and still yields the §1.6 bound; a genuine DETECT with
transport cycles must reconcile its logs against the theorem-grade minimum
(realized cycle work), and carries an extraordinary-evidence burden against
the G10-convention audit scale, which the Part 5 conjunction and the
energy-budget logging (Document C Part 7) are designed to meet. The
convention is a *named hypothesis of the decision layer* (it can be
contested without touching any theorem); the cycle identities and the
arithmetic are machine-checked. This section calibrates interpretation; it
does **not** alter the decision rule.

---

## Part 2: The v3 design figures (reference targets)

From `HOVER:/`, orientation only; we do **not** build the v3 board:

| Quantity | Value | Source |
|---|---|---|
| v3 projected area A_perp | 0.063 m² | HOVER:/docs/explainer.md:120 |
| v3 hover threshold Δν | 3.4×10⁻¹⁰ | HOVER:/docs/explainer.md:122 |
| v3 design target Δν | ≥ 1.0×10⁻⁹ | HOVER:/docs/explainer.md:123 |
| Required ΔS_coh^can (v3) | ≥ 3.7×10⁻¹⁰, design ≈ 1.0×10⁻⁹ | HOVER:/docs/theory-assumptions.md:55,61 |
| Force at design target | ≈ 7.25 N (≈ 739 gf) | HOVER:/docs/explainer.md:125–126 |
| Formal success criteria | A ≥ 0.063 m², M ≤ 0.25 kg, Δν ≥ 1×10⁻⁹, F ≥ 7.2 N | HOVER:/docs/acceptance.md |
| OPH force table (Δν → F) | 1e-10 → 0.72 N · 3.5e-10 → 2.54 N · 1e-9 → 7.25 N · 1e-8 → 72.5 N | HOVER:/docs/concept.md |

`HOVER:/docs/acceptance.md` accepts Δν "measured **or inferred**": our
balance measures F and infers Δν via §1.5, satisfying that criterion.

---

## Part 3: Inputs from the OPH side (agreed 2026-06-03; confirm at lock)

> These are the only free choices; Part 4 is computed from them. If a field
> cannot be filled, write "UNDEFINED" (see §4.7).

### 3.1 Active substrate: the self-reading PoC

The coupon is an **active, self-reading PoC** (`ANS:/answer` §3.1–3.2;
`ANS:/guide` "The First Real PoC"), not a passive material stack:

- battery-powered nonmagnetic plate (quartz / alumina / glass-ceramic /
  sapphire / insulated aluminum);
- 4–12 **same-port or tightly co-located TX/RX piezo (or optical) ports**,
  **top and bottom zones read separately**;
- onboard MCU + logger + battery; **no cables during weighing**;
- BiFeO₃ is an *optional* coherent insert, not the active ingredient: the
  read→record→predict→repair loop is what puts the coupon on the signal
  branch. (The TDK piezo "proxy stage" of the original BOM is checkout-only,
  `HOVER:/docs/build-tutorial.md:256`; it lacks the loop and is not a test
  article.)
- Projected active area **A = 4.8×10⁻³ m²** (one zone, ≈ 80×60 mm), confirmed
  by the OPH side (`ANS:/answer` §3.1). Predicted force scales with A (§1.5),
  so coupon scale is on-protocol: the OPH prototype sequence itself begins
  "1. Single-zone coupon" (`HOVER:/docs/architecture.md`).

| Coupon (at Δν = 1×10⁻⁹) | A [m²] | Predicted F | gf |
|---|---|---|---|
| full board (reference only) | 0.063 | 7.2 N | 735 |
| **one zone ≈ 80×60 mm (baseline)** | 4.8×10⁻³ | 0.55 N | 56 |
| small coupon 20×20 mm | 4.0×10⁻⁴ | 0.046 N | 4.7 |

The Milestone-1 build of the self-reading object (rings, ×120 RX chain,
coupling-matrix logging) is specified in [`build/`](../build/README.md).

### 3.2 Primary prediction input: the coherence contrast is measured

- **ΔS_coh^can is measured, not pre-predicted** (`ANS:/answer` §1, §3.4): the
  coupon reads S_top^can and S_bottom^can from its own port records in the
  mandatory pre-test (§3.5), giving a **signed** ΔS_coh^can = S_bottom − S_top
  with a commanded sign (ACTIVE+ vs ACTIVE−).
- Magnitude is back-solved from the balance via §1.5; the pre-test fixes
  existence, sign and relative scaling.
- Passive stacks: ΔS_coh^can = 0 (confirmed null branch).

> **⚠ The ΔS-estimator bridge (load-bearing, open; Document B G9).** The test
> assumes the record-derived ΔS_coh^can is the same scalar that enters the
> force law. The OPH side states openly that a null bounds the **product
> χ_ν·ΔS**, and χ_ν alone only if the estimator is accepted (`ANS:/answer`
> §4). The magnitude tension is acknowledged by both sides: a record contrast
> of even ΔS ~ 10⁻⁶ would predict ~500 N on this coupon (F ≈ 5.14×10⁸·ΔS), so
> the bridge cannot be a literal identity at the magnitudes a healthy
> self-reading device naturally produces. The experiment therefore tests
> **sign, scaling and branch**, and back-solves a bound.

### 3.3 Coefficient used

- χ_can = **0.9343006394893864** (§1.4), confirmed by the OPH side
  (`ANS:/guide` "The Susceptibility Coefficient").
- Coupon coefficient: **F_χ ≈ 5.14×10⁸ · ΔS_coh^can N** (= C_geom·A·χ_can at
  A = 4.8×10⁻³ m²). Scale: ΔS = 10⁻⁹ → 0.514 N (52 gf); 10⁻¹¹ → 0.52 gf; a
  1 g apparent change ⇔ ΔS ≈ 1.9×10⁻¹¹.

### 3.4 Engineering-chart cross-check (not used)

The OPH side works in the canonical chart (§1.3); the engineering-chart fields
stay empty. Retained sanity rail: the operating mode is static pre-stress, so
any stored density is elastic, `u = σ²/(2E)`
(`OPH:/extra/chi_nu_susceptibility_bounds.tex:1521`). For quartz/LiNbO₃
(E ≈ 70–200 GPa) at safe tens of MPa, **u ~ 10³–10⁴ J m⁻³** (e.g. 30 MPa on
100 GPa → 4.5×10³); even near the brittle limit u ≲ 10⁵ J m⁻³. Any input
implying more stored density than the material can hold is out of bounds
before testing.

### 3.5 Self-read criterion (REQUIRED: the §1.7 gate, resolved as case ii)

The active element **is** the self-reading system (`ANS:/answer` Q2); passive
BiFeO₃ does not satisfy self-read. Operational property: the **self-read
loop** `drive → self-read → record → predict boundary → repair/update →
repeat`, gated by `S_coh^can = 1_self-read·R_U·P_U·C_U` (all four nonzero):

- **1_self-read**: each zone drives and senses its own mode through the same
  port or a fixed co-located TX/RX pair;
- **R_U**: repeated runs reproduce the records within preregistered tolerance;
- **P_U**: records at cycle *t* predict held-out boundary readouts better
  than shuffled records / the dummy;
- **C_U**: port data show repeatable, state-dependent coherent structure
  (implemented check: the coupling matrix stands above **both** the shuffled
  and the off-resonance control, `build/electronics.md`).

Present in the active coupon by design (firmware logs the receipt onboard);
absent in the dummy (§3.6); tunable (ACTIVE± commands opposite signs of ΔS;
drive amplitude / pre-stress vary the stored state, §3.7). **The pre-test
passing this gate is a precondition for any weighing** (Document C, R-pre): a
null on a coupon that failed the gate is uninformative: OPH predicts null
there too.

### 3.6 Matched dummy specification

Artifact-control object (not a mass baseline; Document C §3.1): matches the
active coupon in mass, CoM, geometry, coating/emissivity, thermal mass,
battery SoC, electrical draw, shielding, wiring and state schedule, and lacks
**only** a valid self-read loop, broken via resistive loads, phase-scrambled
drive, damped transducers, or record-shuffled firmware (`ANS:/answer` §3.3).
Magnetic hardware matched; magnetic bias never toggles inside a comparison
(Document C §3.2).

### 3.7 Predicted scaling laws (OPH side, 2026-06-03)

- vs **measured ΔS_coh^can**: F ∝ ΔS_coh^can, the headline scaling test (not ∝ power);
- **ACTIVE+ → ACTIVE−** (commanded sign): force reverses at matched power;
- **physical FLIP**: force reverses relative to gravity;
- vs **active area A**: F ∝ A (second geometry, a later milestone);
- vs **drive amplitude / stored state**: monotone with stored state, but F must
  track measured ΔS, not raw input power (power-matched SHAM isolates this).

### 3.8 Pass/fail thresholds (OPH side, 2026-06-03)

- No fixed minimum force is committed: magnitude is back-solved (§3.2).
- Detection significance **> 5σ** after corrections, plus the full control
  conjunction, not one lucky block.
- Dummy signal **null or < 10 %** of the active effect (preregistered).
- Candidate lift = ACTIVE+ sign **and** ACTIVE− reversal **and** flip reversal
  **and** dummy null **and** thermal/EM rejection **and** scaling with
  measured ΔS_coh^can.
- A clean receipt + balance null ⇒ bound on χ_ν·ΔS (or χ_ν given the §3.2
  bridge); a back-solved χ_can < 0.9343 excludes the Tier-C band.

---

## Part 4: Derived predictions (computed at lock from Parts 1–3)

> ΔS_coh^can is measured per run (§3.2), so §4.1 is a per-run consistency
> check, not an a-priori number. The decisive comparisons are sign control,
> flip reversal, dummy null, and scaling of F with measured ΔS. Worked numbers
> use the illustrative ΔS_coh^can = 1.0×10⁻⁹ on the baseline coupon
> (A = 4.8×10⁻³ m², χ_can = 0.9343…).

### 4.1 Predicted lift force

```
Δν_pred = χ_can · ΔS_coh^can          F_pred = C_geom · A · Δν_pred
```

Illustrative: Δν_pred = 9.343×10⁻¹⁰ → **F_pred = 0.51 N ≈ 52 gf**.
Locked value: F_pred = `[[COMPUTED]]`.

### 4.2 Detection floor of the apparatus

With F_min from Document C (baseline lock-in **F_min = 5×10⁻⁸ N**):

```
Δν_min = F_min / (C_geom · A) = 9.1×10⁻¹⁷        (baseline coupon)
```

Locked value: Δν_min = `[[COMPUTED]]`.

### 4.3 Signal-to-floor margin

`margin = F_pred/F_min`: illustrative ≈ **1.0×10⁷**. The test is decisive
only if margin ≫ 1; if not, revise area or floor **before** lock.
Locked value: `[[COMPUTED]]`.

### 4.4 Bound a null imposes

```
χ_can·ΔS_coh^can ≤ Δν_min                        (always)
χ_can ≤ Δν_min / ΔS_coh^can                      (given the §3.2 bridge)
```

Illustrative: 9.1×10⁻¹⁷/1.0×10⁻⁹ = **9.1×10⁻⁸**, seven orders below the
Tier-C floor 0.9343, excluding the band for this substrate.
Locked value: `[[COMPUTED]]`.

> Sensitivity is not the risk: the OPH build itself sized the test for ~gram
> resolution (TAL220 cells, `HOVER:/bom/parts-list.md:40`); our 0.1 mg balance
> over-resolves the smallest OPH-predicted force by ~10⁶ (Document C Part 4).

### 4.5 Predicted response surface (fill at lock)

| Active area | Stored state | Commanded sign | Predicted F | Sign |
|---|---|---|---|---|
| full | max | + | `[[COMPUTED]]` | + |
| full | max | − | `[[COMPUTED]]` | − |
| 1/2 | max | + | `[[COMPUTED]]` | + |
| full | 1/2 | + | `[[COMPUTED]]` | + |
| full | 0 (off) | n/a | 0 (baseline) | — |
| dummy | max | + | 0 (§1.7 null clause) | — |

### 4.6 The control matrix, adopted

The OPH-prescribed runs (`HOVER:/docs/build-tutorial.md:416–430`) are adopted
verbatim (A active · B same-power dummy · C flipped · D bias/sign reversed ·
E half area · F lower stored state · G over absorber · H open-air), plus four
rigor upgrades: **(1) vacuum** (subsumes G/H), **(2) lock-in/ABBA on the state
toggle**, **(3) blind labels**, **(4) 0.1 mg balance / torsion option**.
Concrete run matrix: Document C Part 5 (R-pre, R0–R8).

### 4.7 UNDEFINED inputs

With Part 3 filled (2026-06-03), UNDEFINED survives only one way: **the R-pre
self-read receipt fails**. Then there is nothing to weigh, the lift claim is
not yet testable on this coupon, and the open problem is the §3.2 bridge
(Document B Part 2). That outcome is recorded as UNDEFINED, not as a null.

---

## Part 5: Pre-registered decision rule

Evaluated **once**, after blind analysis of the response-surface runs.

**DETECT**: a force (a) above the §3.8 significance, (b) reversing under
commanded ACTIVE− and under physical flip, (c) scaling with measured ΔS (and
area, where tested), (d) absent on the matched dummy, and (e) surviving
vacuum. → Write up as detection and escalate to torsion-balance replication.
A real force weaker than F_pred still counts as DETECT (it refutes the
coefficient, not the idea). The §1.9 energy accounting must be confronted in
the writeup: report the logged toggle-energy budget (Document C Part 7)
alongside the force.

**NULL**: no state-correlated force above F_min across the response surface,
all controls passed. → Record the §4.4 bound; if the back-solved χ_can bound
is < 0.9343, the Tier-C band is excluded for this substrate. Document B's
open-questions section then frames the writeup.

**MUNDANE**: a force that fails sign symmetry, vanishes in vacuum, or appears
on the dummy. → Logged as an ordinary artifact; evidence neither for nor
against χ_ν.

**UNDEFINED**: per §4.7.

Mapping to the OPH failure classification (`HOVER:/docs/acceptance.md`):
DETECT (replicated) → `accepted`; DETECT (single run) → `candidate`; NULL →
`null`; MUNDANE → `ordinary`; sensor/fixture fault → `instrumental`. Per-run
logging follows "Data Required Per Run" there, plus Document C Part 7.

---

## Part 6: Sign-off

By signing, both parties agree Parts 1–4 are fixed and that Part 5 governs
interpretation, regardless of either party's prior.

- OPH theory representative: __________________  date: __________
- Experimenter: _______________________  date: __________
- Lock hash recorded above: [ ] yes
