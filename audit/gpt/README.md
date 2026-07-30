# χν / local anti-gravity audit — GPT

**Audit date:** 2026-07-30

**Decision:** pause the OPH force claim; retain the PCB as an instrumentation
prototype.

## Bottom line

The project is **not at the theory state required for a confirmatory or
falsifying anti-gravity experiment**.

The latest core `reverse-engineering-reality` corpus no longer contains the
prediction on which the existing `chi_nu_test` preregistration is built:

- \(\chi_\nu\) is now a **dimensionless scalar-channel coefficient**, not a
  force coefficient.
- The old value \(e^{-P/24}=0.934300639\ldots\) has been superseded on the
  canonical presence branch by
  \(1-P/24=0.932042991\ldots\).
- The old planar formula
  \(g^2A\chi_\nu\Delta S/(4\pi G)\) is explicitly retired.
- The current force expression belongs to a **proposed repair-charge rotor
  action**, not to recovered core OPH.
- That expression still needs an instrument-independent source, a dimensional
  coupling \(q_\star\), nonzero integrated repair charge or measured outgoing
  momentum, an independently measured repair-field gradient, and a complete
  momentum/energy ledger.
- Within the proposed repair-charge action, a closed, compact, repair-neutral
  top/bottom contrast has no monopole and cannot support itself.
- The canonical claim registry says no binding force falsifier exists yet.

Therefore:

| Result from the present project | Defensible interpretation |
|---|---|
| Stage-0 reciprocal piezo coupling | The piezos and bench setup couple conventionally. |
| PCB measures a repeatable \(3\times3\) matrix | The drive/read electronics work. This is not yet the current OPH scalar receipt. |
| No balance-correlated force | A bound on this apparatus and state schedule only; not a bound on \(\chi_\nu\) or OPH. |
| A balance-correlated anomaly | A candidate apparatus anomaly/new-force residual after controls; not confirmation of OPH. |
| Future repeated null after every rotor receipt and a nonzero force interval above validated sensitivity are independently fixed | Retires the coherent-matter force continuation in the frozen domain; core OPH remains separate. |

## Answer to question 1: are we ready for hardware?

There are two different answers.

1. **For an OPH anti-gravity force experiment: no.** The source-to-force map is
   not closed, no numerical force interval exists, and neither sign nor flip
   behavior is currently predicted for this device.
2. **For low-cost observer-loop/source-candidate instrumentation: yes, with a
   narrower label.** Dave's board can be useful for learning how to drive,
   read, store, and control a resonant object. The present firmware and
   three-ring layout do not yet meet even the current source-receipt
   requirements, but they are a reasonable electronics precursor. The
   present KiCad revision should not be fabricated unchanged; the design audit
   found an unresolved BJT pinout mismatch, a floating CMOS switch-control
   input, and missing local decoupling.

The force path should remain on theory hold until the gates in
[`03_THEORY_AND_EXPERIMENT_GATES.md`](03_THEORY_AND_EXPERIMENT_GATES.md) are
closed. In particular, do not spend on analytical-balance, vacuum, scale-up, or
replication infrastructure on the premise that the current OPH papers predict
a signal.

## Answer to question 2: is this design useful?

**Useful as a metrology and observer-like-loop prototype: yes. Useful as the
declared χν falsifier: no.**

The board contains an ESP32-C6, three selectable piezo ports, three amplified
envelope readouts, an ADS1015, and battery operation. It can help establish:

- resonance and ringdown repeatability;
- same-port and cross-port readback;
- electrical and mechanical cross-coupling;
- control scheduling and raw-data capture;
- a future prediction/checkpoint/feedback experiment;
- the evidence-bundle workflow.

It presently lacks or has not demonstrated:

- held-out prediction from prior records;
- record-conditioned repair/update and checkpoint continuation;
- an internally persistent, replayable raw record;
- top and bottom source zones;
- a frozen, instrument-independent \(S_{\rm coh}^{\rm can}\) estimator;
- the integrated scalar as distinct from its top/bottom difference;
- \(q_\star\), repair charge, or outgoing repair-current momentum;
- an external repair-field source and detector;
- a derived sign operation;
- a power-matched record-shuffled sham in the implemented firmware;
- the sensors and raw phase/waveform capture needed to diagnose force artifacts.

Passing the current Milestone 1 would therefore show that the instrument works,
not that an OPH source or force exists.

## Recommended decision

Proceed only under one of these explicitly separated scopes:

- **Recommended now — observer-loop instrumentation R&D.** Breadboard one
  corrected channel, then revise the PCB if the cost is modest and the goal is
  conventional readback, controls, firmware, and evidence-bundle development.
  Rename the milestone accordingly.
- **Optional — theory-neutral anomaly search.** A balance study can be run for
  engineering curiosity, but its preregistration must not claim to measure
  \(\chi_\nu\) or falsify OPH.
- **Not ready — OPH force test.** Wait for independently calibrated source,
  charge, field, sign, conservation, and numerical-prediction receipts.

The existing `README.md` and Documents A–C should not be locked or used to
adjudicate data. They import a superseded coefficient, a retired force law, and
invalid null/sign rules. This audit deliberately leaves those user-edited files
untouched.

## Audit map

- [`01_THEORY_TRACEABILITY.md`](01_THEORY_TRACEABILITY.md): papers, claim
  registry, Lean, and simulator findings.
- [`02_DESIGN_ASSESSMENT.md`](02_DESIGN_ASSESSMENT.md): PCB/firmware mapping
  against the current theory and evidence requirements.
- [`03_THEORY_AND_EXPERIMENT_GATES.md`](03_THEORY_AND_EXPERIMENT_GATES.md):
  theory-first and hardware-first go/no-go plan.
- [`04_EVIDENCE_REGISTER.md`](04_EVIDENCE_REGISTER.md): exact source snapshots,
  line anchors, commands, and limitations.
