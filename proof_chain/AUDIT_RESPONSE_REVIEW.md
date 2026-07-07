# Review of `AUDIT_RESPONSE.md`

**Verification of the OPH-side audit response and the July 2026 paper pass**

| | |
|---|---|
| Date | 2026-07-06 |
| Reviews | `AUDIT_RESPONSE.md` (OPH side, 2026-07-06) against the post-pass corpus |
| Method | every pin-cite checked against the tex/code (three parallel sweeps + direct deep-reads of the load-bearing theorems); the P-derivation code was **executed and reproduced** |
| Outcome | response verified as **substantially correct and honest**; three refinements below; proof chain updated to v2 |

## Executive verdict

The response is what a good referee reply looks like. Of the ~40 pin-cites we
checked, **all exist and say what the response claims**; the new theorem
surfaces are real theorems with written proofs, not relabeled assumptions; the
scope boundaries and receipts are genuinely self-limiting; and the response's
own "Items That Remain Open" list matches our ledger almost one-to-one. Three
places need refinement — one in our favor being corrected (the layered
carrier's strength), one in theirs (the source-lift falsifiers are not energy
accounting), and one decisive adjudication of their only real pushback (P).

**What is genuinely new and correct (paper-side, verified):**

1. **The quotient repair operator package**
   (`reality_as_consensus_protocol.tex:433–610`). A finite quotient repair
   presentation with the four hypotheses the Lean work identified as necessary
   — boundary preservation (H_B), strict exact descent (H_↓), local confluence
   (H_◇), completeness (H_comp) — a fixed total order on transactions
   (deterministic scheduler), and proved theorems: the global repair operator
   is total, idempotent, boundary-preserving, lands exactly on the consistent
   set, and is schedule-independent. **This is the honest resolution of the
   Lean non-confluence counterexample**: objectivity is bought with a declared
   canonical order (Route B) — now stated as a hypothesis, not smuggled.
2. **"Bare finite consensus is not Einstein-complete"** (`:244–271`) — a real
   negative theorem with a two-counter-model proof. The papers now prove,
   first-party, the boundary we drew in the proof chain ("Layer 0 contains no
   spacetime/gravity").
3. **"Repair respects gauge"** (`:1143–1170`) — proved for the quotient
   construction (the Lean statement of this is still `sorry`).
4. **The layered functional boundary carrier** (`:1225–1364`) — a correct,
   fully-written induction proving H_B ∧ H_fib plus reconstruction by global
   repair on a genuinely multi-edge, multi-layer carrier. *See refinement R1.*
5. **The scalar-channel theorem stack**
   (`screen_microphysics…tex:817–864, 1300–1411, 1475–1492`): same-channel
   forcing and **unique scalar linear response** under one named hypothesis
   (Scalar Edge-Center Exhaustion), and the exact e^(−P/24) as a **conditional
   theorem with an explicit gate** (uniform product-thickening + slice-wise
   reserve-unbiasedness) plus a receipt ledger that *forbids* exact-value
   claims without the gate — including the frank remark that uniformity is
   strictly stronger than the trace condition. The old diffuse "granted collar
   lemmas" are now L1–L7 with imports; conditionality is concentrated and
   auditable.
6. **The finite coherent-matter source generator**
   (`chi_nu_susceptibility_bounds.tex:625–746`) — the *definition side* of the
   ΔS bridge (G9) is now first-party paper content (self-reading
   subfederation, quotient-visible scalar-slot footprint, source generator,
   null conditions). The numerical bridge remains open — as the response
   itself says.
7. **Honest misfit disclosure**: the dark paper's Correction Audit
   (`oph_dark_matter_paper.tex:2304–2338`) tabulates that e^(−P/24) = 0.9343
   sits between the binned-RAR (0.9367) and common-empirical-a₀ (0.9261)
   preferred values and *cannot* reach the latter without ~13 % more protected
   reserve "that needs an OPH theorem before use". Confessional trace-convention
   fix (P/24 vs 24/P) at `screen…tex:372–396`.

**What did not change:** the Lean core (three sorries intact; PROOF_INDEX
still 0 % of Prop 4.2 and does not yet track the new theorems); MAR (still an
axiom, now with a well-founded-minimum proposition); the force law (still a
declared response input — "search and response branch", their words); the ΔS
numerical bridge; the energy ledger.

## Refinements

### R1 — The layered carrier discharges the *form* of H_B ∧ H_fib, not yet the erasure-correction content

The construction is a **feed-forward carrier**: interior values are
deterministic functions of earlier layers, and the "boundary" is the complete
input layer L₀. Reconstruction is therefore determination-by-construction —
correct, genuinely multi-edge, and a valid joint witness of the hypotheses the
Lean file named as an open modeling task. But the physically interesting
statement — the one the Lean **Rule-90 theorem** actually exhibits — is
reconstruction from a **proper subset** of the natural boundary, forced by
constraint redundancy (erasure correction). The layered theorem does not do
that (its optional cross-check predicates are not exploited for erasure). So:
*promotion accepted at "paper-side theorem, feed-forward class"; the
QECC-strength multi-edge theorem — proper-subset boundaries on carriers with
code redundancy — remains the open jewel.*

### R2 — The source-lift falsifiers are identity tests, not an energy ledger

The response lists `Power and Stored-Energy Bounds` and `Source-Lift
Falsifiers` under the conservation-law item (G10). Verified: the falsifiers
(`chi_nu…tex:1696–1719`) are five *operational identity* tests
(record-shuffled dummy, relabeling invariance, register identity, receipt-zero
vs force, signed-flip tracking) — good tests, but none is energy-flow
accounting; the power section prices *maintenance*, not the *toggle
transaction*. The response's own "Open" line concedes this ("the exact local
toggle-energy ledger is not derived"), so there is no dispute — but the
paper-side fix listed under G10 should not be read as partial progress on the
ledger itself. The battery-energy logging in Document C Part 7 remains the
only concrete instrument on this question.

### §P — The P adjudication (the response's one pushback, settled by running the code)

The response grades our "P is an asserted numerical input" as *partly valid*,
calling the stronger reading ("free fitted constant") overstated, and
describes P as "a declared pixel fixed-point branch readout with an executable
source map and an open endpoint transport gate." We traced and **executed**
`code/P_derivation/`. Finding: **both sides need refinement — there are two
P's.**

- **The executable source map is real.** A zero-empirical-input fixed-point
  solver (inputs: π, φ, e^(−2π), small integers, group theory, MSSM beta
  coefficients, a Koide-angle ansatz δ = 2/9; guarded `codata_enters_solver:
  False`) solves P = φ + √π/A_Th(P) and outputs
  **P_root = 1.63097209569…, α⁻¹ = 136.9948351646…** — reproduced by us.
  That is ~300 ppm (≈2×10⁶ σ) from measurement.
- **The published constant is not that output.** P = 1.630968209403959… is
  *by definition* φ + √π/137.035999177 — the CODATA α value read back through
  the outer identity (`fine_structure…tex:738–744`;
  `measured_endpoint_calibration.py:104–109`, which itself flags
  `external_input_used: True`). The 39-digit "hadron closure delta" in
  `derive_p.py:19` equals CODATA-minus-source-output exactly. Every downstream
  consumer of the famous digits — including χ_ν's e^(−P/24) — is silently
  consuming measured α.
- **The claimed 0.3-ppm "near-endpoint" (137.0359595) is bookkeeping, not a
  prediction.** It adds a *coupling* α_U ≈ 0.0411 (evaluated at the
  CODATA-derived pixel) to an *inverse* coupling — an operation that exists
  only in prose, appears in no code, fails the fixed-point identity, is
  refuted as a determination by the paper's **own no-go theorem**
  (`:1015–1094`, "a back-solving theorem rather than a source derivation"),
  and is disqualified by the repo's own source-input rule
  (`SOURCE_SPECTRAL_THEOREM.md:77–78`).
- **Credit where due:** the branch labeling discipline is real (the guards,
  the no-go theorems, the "OPH plus empirical hadron closure" row class, the
  compact paper's own "empirical hadron closure does not promote the endpoint
  to a source-only theorem" at `:6834`). The corpus is honest in the fine
  print. The headline rhetoric ("zero fitted parameters") is not.

**Verdict on the pushback:** our original wording sharpens rather than
retracts — *"P has a genuine executable derivation that yields a different
number (P_root, α off by 300 ppm); the published P is a definitional
restatement of measured α."* The response's "not a free fitted constant" is
true only in the narrow sense that nothing is tuned *inside* the solver.

**Consequence for this experiment: none.** The two branches shift
χ_can = e^(−P/24) by ~1.6×10⁻⁷ relative (0.93430064 vs 0.93430049) — far
inside every tolerance in Documents A/C. Recorded in A §1.2.

## Scorecard

| Response item | Their label | Our adjudication |
|---|---|---|
| Layer 0 / Lean separation | Valid | Confirmed; papers absorbed it (negative theorem + hypothesis-explicit repair) |
| Layer 1 external hooks | Valid | Confirmed |
| L2.1 MAR | Valid | Confirmed (axiom + well-founded-minimum proposition) |
| L2.2/2.3 Lorentz/Einstein | Valid | Confirmed (D1–D9 dependency table; still tex-conditional) |
| L2.4 ℤ₆ / MAR selection | Valid | Confirmed |
| **L2.5 P** | **Partly valid; "fitted" overstated** | **Pushback itself overstated — settled by code trace (§P): two P's; published value is CODATA-calibrated by definition; solver's own output misses by 300 ppm** |
| L2.6/L2.10 e^(−P/24) | Valid, partly outdated | Confirmed upgraded: conditional theorem + explicit gate + receipts (numerically inherits P — see §P) |
| L2.7 phantom density | Valid | Confirmed |
| L2.8 activation law | Valid | Confirmed (+ honest Correction Audit; abundance selector is paper-side selection, CMB promotion gated) |
| L2.9 continuation law | Valid | Confirmed upgraded: **form derived under SEE** (Tier B0/B1); value still Tier C |
| L2.11 force law | Valid | Confirmed still open (falsifiers ≠ derivation; see R2) |
| L2.12/G9 bridge | Valid | Confirmed: definition side closed (source generator); numerical map open |
| G10 energy ledger | Valid | Confirmed open (R2: listed fixes are identity tests, not accounting) |
| Lean status | (implicit) | **Unchanged** — three sorries; PROOF_INDEX 0 % of Prop 4.2, not yet tracking the new theorems; the formalization gap is now the program's bottleneck |

## What this changes for the test

Nothing in the decision rule. Documents A/B/C were re-anchored to the
restructured tex (A §1.3/§1.4/§1.7 now carry Tier B0/B1, L1–L7 and the
source-generator reference); A §1.2 carries the two-branch P provenance; the
run matrix, floors and conservation-law cage are untouched. The experiment
remains a clean bound on χ_ν·ΔS with the same numbers.

## The updated ask list (mirrors the response's own open items, prioritized)

1. **Lean port of the new surface** — quotient repair presentation +
   layered-carrier theorem are small, self-contained targets; formalizing them
   would make the paper-side tier machine-checked.
2. **The QECC-strength carrier theorem** (R1): reconstruction from proper
   boundary subsets on redundant multi-edge carriers — the true holography
   content; Rule 90 generalizations are the natural route.
3. **G9 numerical bridge** and **G10 toggle-energy ledger** — unchanged, still
   decisive for the lift chain.
4. **P**: either promote the source branch (find the physics that moves
   136.9948 → 137.0360 *forward*, i.e. the Ward-projected hadronic spectral
   measure they name) or complete the demotion of the published digits to
   "calibration" everywhere downstream (the χ_ν convention note already half
   does this).
