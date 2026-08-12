# Ledger divergences: the experiment documents against the 2026-07-30 corpus

Companion to [`README.md`](README.md); corpus state and shortcuts in
[`CORPUS_STATE_2026-07-30.md`](CORPUS_STATE_2026-07-30.md). This file lists,
item by item, where the pre-registration ledgers, the proof chain, and the
build documents diverge from the corpus they import from. None of the ledgers
is locked, so every divergence is repairable without breaching a
pre-registration.

## 1. Document A (prediction ledger, v0.2.3 body, unlocked)

| # | Ledger content | Corpus state 2026-07-30 | Severity |
|---|---|---|---|
| D1 | §1.4 falsification target χ_can = e^(−P/24) = 0.9343006394893864, band [0.9343, 1], "This band is the falsification target" (`:157–174`) | Canonical value 1 − P/24 = 0.9320429912748350 on the presence branch; band [0.93204, 1] (`OPH:/extra/chi_nu_susceptibility_bounds.tex:55, :170–175`). The corpus's exact value lies outside the pre-registered band. | Governing target names a superseded number |
| D2 | §1.5 force law F_χ = C_geom·A_perp·Δν imported from tex `:1311–1345` (eq. `force-law` at `:1325`) | The current tex is 475 lines; the equation and section are absent, and `:375` states the formula "is not a force theorem for a closed compact device" | The imported prediction has no source; the source repudiates it |
| D3 | §1.6 null-bound formula from tex `:1651` (eq. `null-bound-general`) | Absent from the current tex; `:433`: "Without these receipts, a null result does not measure χ_can" | The NULL branch of the decision rule has no corpus-side meaning |
| D4 | §3.3 coupon coefficient F_χ ≈ 5.14×10⁸·ΔS N; §4.1 illustrative 0.51 N / 52 gf | No benchtop force magnitude of any kind is stated in RER | Effect-size table floats free of the theory |
| D5 | §1.4 conditionality via L0–L7 with L5 a "declared Poisson branch" and L7 licensing the exact value | The corpus dropped the Poisson exact value for χ_ν; the counting theorem (issue #320) carries the coefficient as branch data with the presence branch 1 − P/24 | Clause structure describes the superseded derivation |
| D6 | §1.2 provenance note: two P branches, published P = φ + √π/137.035999177 | Unchanged in substance (fine-structure paper carries both branches) | None; note survives |
| D7 | §1.7 exemption clause: the four-factor gate is "the only thing exempting the active coupon from the existing null corpus" | The corpus deleted the c_U = 0 by-assignment disclosure and the Eötvös/MICROSCOPE reinstatement statement without retaining an answer | The EP obligation is undisclosed on both sides |
| D8 | §1.9 conservation cage, G10-convention pricing, battery ceiling 1.1×10⁻¹¹ | Unchanged; machine-checked in `EnergyCage.lean` / `LedgerNumerics.lean`; the adversarial audit's F15 grading (convention, not theorem) stands | None; this section is the healthiest import |
| D9 | Part 2 v3 design figures from `HOVER:/docs/` | `META:/hoverboard/` is live (last commit 2026-07-26) and carries the repudiated force law; RER deleted its applications surface | Reference targets cite a design whose theory basis is withdrawn |
| D10 | Part 5 NULL clause: "a back-solved χ_can < 0.9343 excludes the Tier-C band" | The tier ladder is absent from the current tex; the band moved; the paper denies that a null measures χ_can | Decision-rule exclusion clause is void twice over |

## 2. Document B (critique ledger, v0.3.1)

- G9 (ΔS-estimator bridge) is confirmed as the decisive open item by every
  newer source: the proof chain ("the decisive instrument for the tower is
  whatever supplies G9"), the OPH audit response ("it does not derive the
  numerical bridge from an apparatus record contrast to the gravitational
  scalar"), and the sim gate blocker ("missing numerical map from apparatus
  record contrast to gravitational scalar"). No draft of the calibration
  exists anywhere in the corpus.
- G10 (energy ledger) is unchanged: theorem-form cycle identities, the 3.5 MJ
  per-toggle figure a named pricing convention.
- Version-lag rows: the header pins proof-chain v7 (the chain is v10); `:174`
  counts 29 modules / 1480 declarations (the tree has 38 / 1284); `:181`
  states screen-capacity boost invariance without the T36 closure.

## 3. Proof chain and formal tree

- The chain (v10) grades the χ_ν tower L2.9–L2.12 as form-derived /
  conditional / attribution-open / bridge-open, and states that a NULL bounds
  the product χ·ΔS with no graded claim excluded. That grading is consistent
  with the 2026-07-30 corpus; the corpus moved further in the same direction
  (the response law itself withdrawn as a force theorem).
- L2.10 carries e^(−P/24) as the conditional exact value. The corpus-side
  supersession (presence branch) is not reflected in the chain, the formal
  README, or RESULTS.md.
- `OPHProofChain/CollarGatePresence.lean` (untracked, 2026-07-14, compiles
  clean, six `#print axioms` checks) proves: the mean receipt alone forces
  λ_presence = 1 − P/24 exactly; λ_presence < e^(−P/24) strictly, so the
  papers' band [e^(−P/24), 1] excludes the value implied by the presence
  reading; a Markov band [1 − P/24, 1] holds for any ℕ-valued occupancy; and
  every finite m-fold Bernoulli refinement sits strictly below e^(−P/24).
  This module anticipates exactly the substitution the corpus performed on
  2026-07-18, is cited from RER (`code/capacity_readback/F_CONSTRUCTION_2026-07-14.md:95–96`),
  and is invisible to the build: outside git, outside the umbrella import,
  absent from README/RESULTS.
- The chain's Layer-0 fence ("no spacetime, no gravity, no χ_ν, no derivation
  of P, by design") matches the RER Lean corpus, which contains zero theorems
  on this lane.

## 4. Build documents and hardware

- The Milestone-1 scope statement ("What M1 tests of the theory: nothing",
  `../build/MILESTONE_1_build.md` §9) is accurate under both the old and the
  current corpus. The receipt device carries no theory exposure.
- The KiCad board (`../build/kicad/MILESTONE_1_build/full_instrument/`,
  74 footprints, commits `57f1555` 2026-07-29 and `663ef61` 2026-07-30)
  implements the rev-2 Milestone-1 electronics. It is receipt
  instrumentation; nothing about it commits to the withdrawn force law.
- Open build-side item independent of the theory: the Stage-0 erratum
  (`../build/STAGE0_results_run1.md` §2a) records that the adopted 43.5 kHz
  drive is the parallel resonance f_p and that the series resonance f_s was
  not logged. The sim-side engineering audit names the same defect
  (`SIM:/docs/OPH_SIGNATURE_EXPERIMENT_TRACKER.md:1016–1022`). A Stage-0
  Run-2 logging f_s is owed before the receipt run regardless of any theory
  outcome.

## 5. Communication record

- The newest OPH-side input in this repository is dated 2026-07-06
  (`../proof_chain/AUDIT_RESPONSE.md`); the primary Q&A PDFs are 2026-06-03.
  Every substantive corpus change listed in
  [`CORPUS_STATE_2026-07-30.md`](CORPUS_STATE_2026-07-30.md) postdates the
  last communication. The 2026-06-03 commitments (the 5.14×10⁸·ΔS
  coefficient, the scaling laws, the sign conventions) predate the force-law
  withdrawal and are not current OPH positions.
- The magnitude tension this repo raised (`../communication/reply_to_bmu.md:10–18`:
  record contrasts 10⁻²–1 imply 10⁷–10⁸ N under the literal coefficient) was
  resolved on the corpus side by deletion of the coefficient's force reading;
  the suppression was never supplied. The reductio's bound
  (gravitational ΔS ≲ 10⁻¹⁰ from coupons at rest) is banked in
  `META:/verdicts/2026-07-16/` with dangling pin-cites.

## 6. Uncommitted working tree

The six modified files on branch `audit` are a punctuation and register pass
(em-dash removal, adverb deletion); a mechanical diff check found no change to
any number, threshold, grade, or decision-rule text. The Document A change log
ends at v0.2.2 while the body carries later edits, the defect the adversarial
audit filed as F28.2. Commit or discard the pass, and bump the change log
whenever Document A text moves.
