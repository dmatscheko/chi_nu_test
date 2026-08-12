# Corpus state, 2026-07-30: what the OPH source repositories assert about the χ_ν lane

Companion to [`README.md`](README.md). Path shortcuts: `OPH:/` is the OPH corpus
clone (`reverse-engineering-reality`, upstream
`github.com/FloatingPragma/observer-patch-holography`), audited at commit
`fd36a8ea` (paper release r2004, 2026-07-30, working tree clean). `SIM:/` is
`oph-physics-sim`. `META:/` is the parent `oph-meta` repository. Line anchors
are against those trees on the audit date.

## 1. The χ_ν paper is a different document from the one Document A imports

`OPH:/extra/chi_nu_susceptibility_bounds.tex` is 475 lines. The version every
ledger anchor in [`../test/DOCUMENT_A_prediction_ledger.md`](../test/DOCUMENT_A_prediction_ledger.md)
points at was ~2,690 lines. Commit `0c986ccb` ("Repo hygiene (WIP)",
2026-07-18) removed 2,216 lines from the file. Every Document A pin-cite above
line 475 dangles.

What the current paper asserts:

- Coefficient (abstract, `:55`): "On the co-registered presence branch, the
  dimensionless coupling is χ_ν^can = 1 − P/24 = 0.9320429912748350…. Under
  the weaker mean-count reading it lies between that value and one. This is a
  channel coefficient, not a force coefficient."
- Lift (abstract, `:62`): "A compact neutral coherence contrast has no
  monopole and cannot support a closed device. The dimensional source
  calibration, ambient repair field, compact-phase completion, and laboratory
  source receipt are work in progress; no numerical lift prediction follows
  from χ_ν alone."
- Claim-boundary table (`:80–90`): χ_can = 1 − P/24 "exact on the presence
  branch"; dimensional coupling q★ "work in progress"; device force
  "conditional on source charge, external field, and momentum closure";
  "Numerical lift: absent".
- Band (`:170–175`): boxed 0.9320429912748350… ≤ χ_can ≤ 1.
- Compact-source no-go (`:351–378`, closing at `:375`): "No formula
  proportional only to g²Aχ_ν ΔS/(4πG) is a force theorem for a closed
  compact device." That formula is, verbatim, the force law Document A §1.5
  imports and the 5.14×10⁸ N per unit ΔS coupon coefficient in §3.3.
- Momentum closure (`:396–398`): "A static, closed, repair-neutral device
  cannot lift itself."
- Conclusion (`:445–449`): "Repulsive response is conditionally allowed.
  Reactionless lift from a compact neutral contrast is excluded."
- Laboratory Evidence Conditions (`:414–431`): eight mandatory receipts,
  including the dimensional calibration q★ and "a nonzero integrated repair
  charge, or a measured outgoing repair-current and momentum flux", closing
  at `:433`: "Without these receipts, a null result does not measure χ_can,
  and a nonzero balance signal does not establish repair charge."

Content absent from the current tex (grep-verified): `Tier`, `Poisson`,
`e^`, `benchtop`, `5.14`, `torsion`, `Eötvös`, `MICROSCOPE`, `c_U`, the
platform tables, the null-bound formula (`null-bound-general`), the
source-lift falsifiers, and the "Falsifiability Status" section.

## 2. The coefficient moved: presence branch 1 − P/24 is canonical

The 2026-07-14 presence-correction note (ε(y) is a conditional trace of a
projection, a presence probability; consuming it as a Poisson mean count is a
type substitution; the receipt-consistent exact value is 1 − P/24) was adopted
into the corpus in two steps: commit `0c986ccb` (2026-07-18) swapped the
paper's value and band, and commit `261ed96e` ("Fold collar survival
correction into canonical source", 2026-07-28) deleted the standalone note and
repointed its four citations at the tex. Downstream corpus surfaces carry the
presence value: `OPH:/paper/screen_microphysics_and_observer_synchronization.tex:2082`
(λ_collar = 1 − P/24), `OPH:/paper/deriving_the_particle_zoo_from_observer_consistency.tex:2444`,
and `OPH:/code/cosmology/edge_center_clock_certificate.py:901`. GitHub issue
#320 (closed 2026-07-17) carries the collar-Poisson counting theorem with the
coefficient as branch data: "unit branch 1; Z6 presence branch 1 − P/24".

Consequence for the ledger: Document A's falsification target
χ_can = e^(−P/24) = 0.9343006394893864 with band [0.9343, 1] names a value the
corpus does not defend, and the corpus's current exact value 0.93204… lies
outside that pre-registered band. The numeric shift is 0.24 %, immaterial to
any detection threshold; the governance consequence (the band test names the
wrong target) is the material part.

## 3. The lane is off every falsification and application surface

- `OPH:/docs/OPH_FALSIFICATION_PROGRAM.md:61–80` lists as "Ineligible
  Surfaces": "the repair-charge condensate dark-sector continuation,
  including … laboratory force claims" and "coherent-matter, anti-gravity,
  hardware enrichment … continuations", with "Diagnostic comparisons …
  carry no falsification verdict."
- `OPH:/claims/claim_registry.yaml:1871–1893` (`OPH-CHI-NU`): tier
  `work_in_progress_experimental_continuation`, status `resource_deferred`,
  `gates: []`, falsifier: "No binding force falsifier exists until the
  coherent-source receipt, dimensional coupling, ambient repair field, and
  momentum ledger are operational."
- `OPH:/docs/APPLICATIONS.md` (the hoverboard/hoverbike applications page)
  was deleted by commit `397a0231` (2026-07-28), downstream of issue #519
  (closed 2026-07-20), which required removal of hoverboard-class claims
  unless receipt-backed. `PATENTS.md` was deleted by `3ab81993` (2026-07-22).
- The RER `README.md` and the main book contain no occurrence of χ_ν,
  susceptibility, anti-gravity, or hoverboard. The anti-gravity book under
  `OPH:/extra/hacking-the-simulation-anti-gravity-exploit/` is retained with
  hedged framing ("A compact repair-neutral device cannot lift itself, and
  every force claim needs a closed repair-field momentum ledger").
- The live issue tracker (33 open issues, snapshot 2026-07-30) contains no
  issue on χ_ν, lift, or coherent matter.

## 4. The demotion is by excision, without a retraction record

A repo-wide grep for retraction language finds no χ_ν entry. Two disclosures
removed in `0c986ccb` were not retained anywhere in RER:

1. The benchtop reductio. The pre-2026-07-18 paper stated that healthy-device
   record contrasts of order 10⁻²–1, multiplied by the 5.14×10⁸ N
   record-gravity coefficient, predict benchtop forces of 10⁷–10⁸ N that
   resting coupons do not show, bounding the gravitationally coupled record
   contrast at ΔS ≲ 10⁻¹⁰. The corrected strict range is [5.1×10⁶, 5.1×10⁸] N
   (`META:/verdicts/2026-07-16/MISS_ROOT_CAUSE_REGISTER.md:47`). The banked
   kill of the 1:1 record↔gravity identity survives only in
   `META:/verdicts/2026-07-16/V4_symmetric_scoreboard.md:82` (row 47), whose
   RER pin-cites all dangle (the cited `docs/OPH_falsifiability.md`,
   `docs/CLOSURE_LEDGER.md`, and `docs/CONSISTENCY_STACK.md` were deleted
   2026-07-17/21).
2. The equivalence-principle exemption. The old paper disclosed that ordinary
   matter carries c_U = 0 "by assignment, not by derivation", and that
   torsion-balance, Eötvös-type, and MICROSCOPE nulls impose no constraint on
   the branch only because of that assignment. The current corpus contains no
   occurrence of c_U. The disclosure survives only in
   `META:/proof/epic_wins/chinu_band/FROZEN_BAND_DRAFT_coherent_weight_2026-07-17.md`
   (marked "UNANCHORED DRAFT. This document carries no verdict weight").

## 5. Machine-checked and simulated support: none on this lane

- RER Lean (86 files, ~1,073 theorem/lemma declarations): zero theorems about
  χ_ν, the collar survival coefficient, P/24, or presence probability. The
  only contact is a scope-warning docstring
  (`OPH:/Lean/ObserverPatchHolography/SeedPi.lean:26–30`) stating that the
  survival factors e^(−P/24) and 1 − P/24 "are abstracted to a real
  parameter" and stay outside the formalised set. The "collar" Lean modules
  are the issue-#544 central-interface collar clause, and their content is
  negative (the clause is a declared input; machine-checked no-gos that the
  axioms cannot force it).
- The simulator computes no lift, no force, no χ_ν. The only χ_ν object is
  the status gate `SIM:/oph_fpe/consensus/proof_chain_imports.py:112–125`,
  hard-coded `CHI_NU_G9_RECORD_GRAVITY_BRIDGE_RECEIPT: False` with blocker
  "missing numerical map from apparatus record contrast to gravitational
  scalar", claim level `DEMO`, and the note "it is not a physical
  prediction." A test locks the receipt to `False`
  (`SIM:/tests/test_matscheko_proof_chain_imports.py:40`).
- The sim's experiment tracker carries the lab lane as unbuilt:
  `SIM:/docs/OPH_SIGNATURE_EXPERIMENT_TRACKER.md:245` (LB-01, status BUILD)
  and `:1016–1022`: fix the 43.5 kHz drive bug, replace the passive Schottky
  detector, add power-matched shuffled controls, use a geometry capable of
  lift, "Default hypothesis zero force."
- λ_collar = e^(−P/24) appears in the sim only as a diagnostic input constant
  behind an unclosed promotion gate (`SIM:/oph_fpe/cosmology/oph_kernels.py:75`;
  `SIM:/docs/CLAIM_LANES.md:95`), and `SIM:/tests/test_comparable_data.py:1537`
  carries the superseded literal 0.9343006394893864.

## 6. Cross-repository citation defects found during this audit

1. `OPH:/code/capacity_readback/F_CONSTRUCTION_2026-07-14.md:95–96` cites
   "Lean module `CollarGatePresence.lean`". No such file exists in RER. The
   module exists only as an untracked file in this repository
   (`../proof_chain/formal/OPHProofChain/CollarGatePresence.lean`), outside
   the umbrella import and absent from the formal tree's README and RESULTS.
2. `OPH:/code/cosmology/edge_center_clock_certificate.py:901` (and its
   manifest) attribute the sentence "e^(−P/24) is the depth limit,
   unreachable at any finite regulator" to
   `extra/chi_nu_susceptibility_bounds.tex`. The current tex contains no
   occurrence of `e^`, `exp`, `depth`, `regulator`, or `unreachable`; the
   demotion rationale was deleted with the folded note.
3. The book chapter
   `OPH:/extra/hacking-the-simulation-anti-gravity-exploit/06-susceptibility-coefficient.md:15`
   attributes a Tier A/B0/B1/C/D ladder to "the chi-nu paper"; the current
   tex contains no tier ladder.
4. Two sibling hardware repositories carry the repudiated force law as
   load-bearing: `META:/hoverboard/` (BTTF-chi Mini v3, design contrast
   Δν ≥ 1.0×10⁻⁹) and `META:/anti-gravity-student-experiments/theory_branch.yaml`
   (`force_law.equation: F = g0^2/(4*pi*G) * A_perp * chi_can * delta_S_can`,
   `finite_thickness_band: 0.9343006394893864 <= chi_can <= 1`,
   `load_bearing_for_student_package: true`, `bridge_to_canonical.status: absent`).
