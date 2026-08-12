# Audit 2026-07-30: the χ_ν lift test against the current OPH corpus

An independent audit of this experiment (design, ledgers, proof chain,
Milestone-1 hardware including the 2026-07-29/30 KiCad board) against the OPH
corpus at paper release r2004 (`reverse-engineering-reality` commit
`fd36a8ea`, 2026-07-30), its Lean corpus, and `oph-physics-sim`. Requested by
the OPH side to answer two questions before further hardware work.

## Verdict in brief

**Question 1: is the theory at the right state for a hardware experiment?**
No. The corpus at r2004 carries no laboratory force prediction. The force law
this experiment imports was removed from the χ_ν paper on 2026-07-18 and is
repudiated for this device class ("No formula proportional only to
g²Aχ_ν ΔS/(4πG) is a force theorem for a closed compact device"; "A static,
closed, repair-neutral device cannot lift itself"). The paper states that
without eight named receipts "a null result does not measure χ_can, and a
nonzero balance signal does not establish repair charge." The lane is an
ineligible surface of the falsification program and sits at
`resource_deferred` in the claim registry with no gating issue. The theory
work owed first, in order of leverage: the G9 record→gravity bridge, the
dimensional calibration q★, a derived force law with a momentum ledger and a
geometry that evades the compact-source no-go, and the equivalence-principle
reconciliation for the c_U = 0 assignment.

**Question 2: is this particular design useful; would it confirm or falsify
anything about OPH?** As a lift test, no, on all three outcome branches: a
null excludes nothing the corpus asserts (the theory predicts null for this
coupon independently of χ_ν, and the pre-registered exclusion band targets a
coefficient the corpus replaced with 1 − P/24 on 2026-07-18); a detect would
be a freestanding anomaly the corpus declines to predict; artifacts carry no
content either way. What retains value: the Milestone-1 receipt instrument as
instrumentation (its own scope statement, "tests nothing of the theory," is
accurate), the pre-registration machinery as a template, the formal tree, and
the collaboration record itself, which terminates cleanly because Document A
was never locked.

**Recommendation.** Do not lock Document A; do not build the weighing
milestones; optionally finish Milestone 1 on its own merits; record the
theory-side withdrawal in Document B; define re-engagement triggers keyed to
a corpus release that supplies the missing theory objects. Details in the
verdict file.

## Files

| File | Content |
|---|---|
| [`CORPUS_STATE_2026-07-30.md`](CORPUS_STATE_2026-07-30.md) | What the corpus asserts about the lane at r2004: the 2,216-line excision of the χ_ν paper, the presence-branch coefficient 1 − P/24, the compact-source no-go, registry and falsification-program status, the deleted applications surface, the absence of Lean or sim support, and the demotion-by-excision finding (the benchtop reductio and the c_U = 0 disclosure were deleted without retained answers). |
| [`LEDGER_DIVERGENCES.md`](LEDGER_DIVERGENCES.md) | Item-by-item divergence table: Document A's superseded target and dangling anchors (D1–D10), Document B version lags, proof-chain status, the untracked `CollarGatePresence.lean`, the build documents (the KiCad board is clean; the f_s drive-frequency erratum is the one open build item), and the staleness of the communication record. |
| [`VERDICT_READINESS_AND_DESIGN.md`](VERDICT_READINESS_AND_DESIGN.md) | The two questions answered in full, the ordered theory prerequisites, the outcome-branch analysis, what retains value, and the recommendation with re-engagement triggers. |

## Housekeeping items surfaced by this audit

On this repository:

1. Commit `proof_chain/formal/OPHProofChain/CollarGatePresence.lean` and add
   it to the umbrella import, README, and RESULTS. It is cited from the OPH
   corpus (`code/capacity_readback/F_CONSTRUCTION_2026-07-14.md:95–96`) and
   the citation dangles while the file is untracked here. Its theorems
   anticipated the corpus's own 2026-07-18 coefficient correction.
2. Commit or discard the pending punctuation pass on the six modified files;
   bump the Document A change log whenever its text moves (holes-audit
   F28.2).
3. Refresh the version pins: repo README says proof-chain v7 (the chain is
   v10); Document B carries v7-era module and declaration counts and an
   unqualified boost-invariance row closed by T36.

On the OPH side (for the maintainers):

4. `code/cosmology/edge_center_clock_certificate.py:901` attributes the
   depth-limit rationale to a tex that does not contain it.
5. The book chapter `06-susceptibility-coefficient.md` attributes a tier
   ladder to a paper without one.
6. `hoverboard/` and `anti-gravity-student-experiments/theory_branch.yaml`
   carry the repudiated force law and the superseded coefficient;
   `theory_branch.yaml` marks the force law load-bearing for the student
   package.
7. The benchtop reductio and the c_U = 0 disclosure survive only in
   `oph-meta/verdicts/2026-07-16/` with dangling pin-cites into three deleted
   files; this audit restates both with self-contained quotes.
