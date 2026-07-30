# Verdict: readiness for a hardware experiment, and the usefulness of this design

Companion to [`README.md`](README.md). Evidence base:
[`CORPUS_STATE_2026-07-30.md`](CORPUS_STATE_2026-07-30.md) and
[`LEDGER_DIVERGENCES.md`](LEDGER_DIVERGENCES.md). The two questions are
answered against the OPH corpus at release r2004 (2026-07-30).

## Question 1: is the theory at the right state for a hardware experiment?

No. The corpus at r2004 supplies no laboratory prediction for this device
class, and states so itself, four separate ways:

1. "No numerical lift prediction follows from χ_ν alone"
   (`OPH:/extra/chi_nu_susceptibility_bounds.tex:62`); claim table row
   "Numerical lift: absent" (`:89`).
2. The force law this experiment was designed to test is repudiated at
   theorem level for exactly this device class: "No formula proportional only
   to g²Aχ_ν ΔS/(4πG) is a force theorem for a closed compact device"
   (`:375`); "A static, closed, repair-neutral device cannot lift itself"
   (`:396–398`). The coupon of Document A §3.1 is a static, closed,
   battery-powered, repair-neutral device.
3. The lane is an "Ineligible Surface" of the falsification program, carrying
   no falsification verdict (`OPH:/docs/OPH_FALSIFICATION_PROGRAM.md:61–80`),
   and the claim registry holds it at `resource_deferred` with an explicit
   falsifier precondition: "No binding force falsifier exists until the
   coherent-source receipt, dimensional coupling, ambient repair field, and
   momentum ledger are operational" (`OPH:/claims/claim_registry.yaml:1888`).
4. The paper's own gate on laboratory work: "Without these receipts, a null
   result does not measure χ_can, and a nonzero balance signal does not
   establish repair charge" (`:433`).

### Theory work required before any weighing is decisive

Ordered by leverage, with the corpus's own names:

1. **G9, the record→gravity bridge.** A numerical map from an apparatus
   record contrast to the gravitational scalar. Named decisive by the proof
   chain ("the decisive instrument for the tower is whatever supplies G9"),
   confirmed open by the OPH audit response, and hard-coded false in the sim
   gate. Without it a null bounds only the product χ·ΔS, which no graded
   claim consumes.
2. **q★, the dimensional source calibration.** The paper's claim table marks
   it work in progress; without it the channel coefficient χ_can has no
   dimensional route to a force.
3. **A derived force law with a momentum and energy ledger.** The compact-source
   no-go means any completed law must involve an external repair field,
   outgoing repair current, or non-closed geometry; the book's ladder calls
   this the repair-charge rotor completion (Tier D). The Document B G10
   obligation (where does F·h per cycle come from?) binds any candidate.
4. **The equivalence-principle reconciliation.** Ordinary matter carried
   c_U = 0 by assignment in the pre-excision paper; the current corpus is
   silent. A derivation is owed either way: if coherent matter couples and
   ordinary matter does not, the selection rule needs a theorem; if the
   coupling is ambient, torsion-balance and MICROSCOPE nulls bind at
   ~10⁻¹³ and the lane is dead on existing data.
5. **Coefficient hygiene.** The presence-branch value 1 − P/24 through every
   downstream surface (this repo's ledgers, `META:/hoverboard/`,
   `META:/anti-gravity-student-experiments/theory_branch.yaml`, the sim test
   literal, the book chapter's tier ladder).

Items 1–4 are theory constructions, none of which any hardware can supply.
The experiment's own proof chain reached the same conclusion from the other
direction: the decisive instrument is whatever supplies G9, before any
weighing.

## Question 2: is this particular design useful? Would it confirm or falsify anything about OPH?

As a χ_ν lift test: no, under the current corpus, on all three outcome
branches of the pre-registered decision rule.

- **NULL.** The theory side predicts null for this coupon independently of
  χ_ν (compact-source no-go), and states that a null without the eight
  receipts does not measure χ_can. The ledger's exclusion clause
  ("back-solved χ_can < 0.9343 excludes the Tier-C band") names a band the
  corpus replaced and a tier ladder the paper dropped. A null would exclude
  nothing the corpus asserts. This was true in weaker form before the
  excision (the F16 finding: a null bounds only χ·ΔS, no graded claim
  excluded); the r2004 corpus makes it unconditional.
- **DETECT.** No corpus coefficient, force law, or magnitude exists for the
  signal to match, so a genuine state-correlated, sign-reversing,
  flip-reversing, dummy-null, vacuum-surviving force would be a freestanding
  anomaly. It would be publishable on its own terms and would confront the
  conservation cage (theorem-grade minimum ledger, convention-grade 3.5 MJ
  pricing), and OPH would gain no confirmation from it: the corpus declines
  to predict it.
- **MUNDANE / UNDEFINED.** Unchanged: artifacts and gate failures carry no
  theory content in either direction.

The deepest defect predates the corpus retreat and is recorded in the
experiment's own ledgers: the exemption clause (Document A §1.7) is the only
thing separating the active coupon from the existing null corpus of
precision-weighed piezo devices, the record→gravity bridge behind it is
absent, and record contrasts of a healthy device (10⁻²–1) imply
5×10⁶–5×10⁸ N under the literal coefficient. Resting coupons bound the
gravitational record contrast at ≲10⁻¹⁰ for free. The strongest physical
result this apparatus class could produce was therefore banked without a
balance in 2026-07 (`META:/verdicts/2026-07-16/V4_symmetric_scoreboard.md`,
row 47), and the corpus response was withdrawal of the force reading of the
coefficient; the suppression was never supplied.

### What retains value

- **The Milestone-1 receipt instrument, as instrumentation.** The build's own
  scope statement ("What M1 tests of the theory: nothing") is accurate and
  keeps it clean of the withdrawn claims. The 74-footprint KiCad board, the
  rev-2 signal chain, the A1–A6 acceptance thresholds, and the interleaved
  A-S-A-O control pattern are competent measurement engineering. If a
  completed force law ever names a testable geometry, this logging spine is
  the part that carries over. The board also stands alone as a
  self-characterizing piezo-array instrument.
- **The pre-registration discipline.** Documents A/B/C are a working template
  for adversarial pre-registration (import-with-provenance, decision rule
  before data, matched-dummy design, energy-budget logging). That machinery
  outlives this lane.
- **The audit record.** The proof chain, the holes audit, the formal tree
  (1,284 declarations, 0 sorry), and `CollarGatePresence.lean` are standing
  mathematics regardless of the lane's fate. The presence-branch module
  anticipated the corpus's own 2026-07-18 correction by four days.
- **The collaboration record itself.** The sequence is documented end to end:
  predictions imported with provenance, the magnitude tension raised by this
  side, the theory side's force law withdrawn before lock. Document A was
  never locked, so no pre-registration was breached. Few speculative-physics
  exchanges terminate this cleanly, and the record is worth preserving as the
  outcome.

### Recommendation

1. Do not lock Document A. Re-running its Part 1 import against the r2004
   corpus returns an empty Part 4: no force law, no null-bound formula, no
   band to exclude. In the ledger's own vocabulary the experiment is
   UNDEFINED at import time, upstream of any coupon.
2. Do not build the weighing milestones (M2–M4: zoning, ΔS receipt, balance).
   The balance run has no prediction to meet and no bound to land.
3. Milestone 1 may be finished as an instrumentation exercise on its own
   merits (the PCB exists; the f_s drive-frequency erratum from Stage 0 is
   the one open build item), with its scope statement kept as is.
4. Record the theory-side state change in Document B and freeze this
   directory as the record: force reading of the coefficient withdrawn
   2026-07-18, applications surface deleted 2026-07-28, lane
   `resource_deferred` with no gating issue.
5. Define re-engagement triggers, so the decision reverses itself
   automatically if the theory moves: a corpus release whose χ_ν paper
   states a device force law with q★ fixed, a momentum ledger, a G9 bridge,
   and a c_U derivation, together with a named device geometry that evades
   the compact-source no-go. On such a release, re-register from scratch
   against the new paper (presence-branch coefficient, new anchors); the
   Milestone-1 instrument and Documents A/B/C are the reusable parts.
