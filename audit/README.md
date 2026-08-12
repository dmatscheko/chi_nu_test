# χν / local anti-gravity experiment: combined audit and recommendation

**Audit date:** 2026-07-30  
**Scope:** current `reverse-engineering-reality`, Lean libraries, OPH physics
simulation, Dave's `chi_nu_test` theory/protocol documents, firmware, and KiCad
design.  
**Detailed audits:** [Fable](fable/README.md) and [GPT](gpt/README.md).

## Executive conclusion

Dave's present design does **not** test an anti-gravity claim made by current
OPH. The claim for which the experiment was originally designed—the direct
force formula proportional to
\(g^2 A\chi_\nu\Delta S/(4\pi G)\)—has been explicitly withdrawn. The current
χν paper retains a dimensionless susceptibility coefficient and discusses a
possible repair-charge rotor continuation, but it does not derive a
laboratory force, fix the dimensional coupling, identify an ambient repair
field, or predict a sign or magnitude for this apparatus.

The design can still be useful as a conventional self-characterizing
piezoelectric instrument and as an engineering precursor to an OPH
source-candidate experiment. In its current form it can verify neither the OPH
core nor the proposed repair-charge continuation. A null balance result would
not falsify either; a nonzero result would initially be an unexplained
state-correlated force, not confirmation of OPH.

The recommended decision is therefore:

| Work item | Decision now |
|---|---|
| Archive and update the theory/protocol record | **Proceed** |
| One-channel electrical and piezo characterization | **Proceed if independently useful** |
| Fabricate the present PCB unchanged | **Do not proceed** |
| Corrected PCB as a metrology/source-development platform | **Conditional proceed** |
| Precision balance, vacuum, scale-up, or “anti-gravity” campaign | **Wait** |
| OPH force experiment | **Wait until the theory and source gates below pass** |

This conclusion is not a claim that OPH forbids every propulsion effect. It is
a claim about inference: the present theory and apparatus do not connect a
measured balance signal to OPH in a unique, quantitative way.

## 1. Does the design test an anti-gravity claim?

No—not a current OPH claim.

The experiment imported an older interpretation of \(\chi_\nu\), including
the coefficient \(\exp(-P/24)\), a top/bottom “coherent-source contrast,” and a
direct force estimate. The current presence-branch coefficient is instead
\(1-P/24\), numerically about \(0.932043\) for the comparison value of \(P\).
More importantly, current OPH explicitly says that no force formula depending
only on \(g\), area, \(\chi_\nu\), and a source contrast is a theorem for a
closed compact device. The old ledger's expected force, exclusion band,
sign-flip rule, and back-solved bound on \(\chi_\nu\) are consequently void.
The detailed history and exact dangling ledger anchors are recorded in
[Fable's corpus state](fable/CORPUS_STATE_2026-07-30.md) and
[ledger-divergence audit](fable/LEDGER_DIVERGENCES.md).

Current theory leaves open a proposed force of the schematic form

\[
F_i=-q_\star\chi_\nu
 \int S_{\rm coh}(x)\,\partial_i\theta_{\rm ext}(x)\,d^3x .
\]

That expression does not rescue the current test. The device has no
independently established \(S_{\rm coh}\), no calibrated nonzero
\(q_\star\), and no generated or measured external repair-field gradient
\(\partial_i\theta_{\rm ext}\). Ordinary gravitational acceleration cannot
simply be substituted for that field. Nor does exchanging two nonnegative
top/bottom activity profiles establish the sign reversal assumed in the old
protocol.

There is an important nuance between the two detailed audits. It is too broad
to say that “OPH predicts null for the coupon” without qualification: the OPH
core currently makes no force prediction for it. **Within the proposed rotor
action**, however, a compact, repair-neutral, closed device has no monopole
charge and cannot statically lift itself. Propulsion would require interaction
with an external repair field or a measured outgoing repair-current/field-
momentum flux. That would be a field-propulsion mechanism, not reactionless
self-lift.

## 2. Does the current design test anything useful?

### What it can test

After electrical corrections, the design can test useful conventional and
OPH-adjacent engineering questions:

- whether three piezo rings can be driven, reset, and read reproducibly;
- their complex impedance, series and parallel resonance, \(Q\), ringdown,
  cross-coupling, drift, and reciprocity;
- whether a bounded device can produce atomic, replayable records of its own
  port responses;
- whether a real prediction → mismatch → repair/update → checkpoint loop can
  outperform detuned, shuffled-history, dummy, and power-matched controls;
- whether an operational source estimator can later be implemented without
  using force data to define it.

The reported Stage-0 matrix is therefore useful preliminary piezo metrology.
It is not an OPH self-read receipt by itself: it lacks validated same-port
diagonals, raw repeats and uncertainties, phase, a held-out predictor, a
registered repair move, an internal checkpoint, and durable atomic records.
The measured 43.5 kHz point is parallel resonance \(f_p\), not the still-open
series-resonance \(f_s\). Details are in the
[GPT design assessment](gpt/02_DESIGN_ASSESSMENT.md).

### What it cannot verify or falsify

The present design cannot verify the OPH core. Its observed electrical and
mechanical behavior is expected from standard piezoelectricity. It also cannot
falsify the core, because the current claim registry supplies no binding force
falsifier for this lane.

The outcome interpretation is:

| Outcome | Scientific meaning now |
|---|---|
| Null | Bounds this apparatus and protocol only; does not measure or exclude \(\chi_\nu\) or OPH |
| Repeatable anomaly | Potentially important theory-neutral new-force result; not OPH confirmation until a frozen model distinguishes it from ordinary and rival mechanisms |
| Artifact or failed gate | No OPH content |

Even after all future gates pass, a null could retire only the particular
coherent-source/rotor continuation in the tested domain, not the finite
consensus mathematics or unrelated branches of OPH.

The old literal force interpretation also failed a powerful sanity check
before a balance was built. Healthy record contrasts of roughly
\(10^{-2}\)–\(1\) inserted into the old normalization implied forces of order
\(5\times10^6\)–\(5\times10^8\) N. The absence of such forces in ordinary
powered piezo systems already rules out a naive one-to-one
record-contrast-to-gravity map. OPH responded by withdrawing the force
interpretation; it has not yet derived the suppression or selection rule that
would replace it.

## 3. What is needed to test the propulsion possibilities OPH leaves open?

### 3.a Theory and mathematics

The decisive missing result is sometimes called **G9**, the historical
record-to-gravity bridge. That name remains a useful warning, but G9 alone is
no longer sufficient because the current paper has structurally replaced the
old force formula. A credible new test needs the following chain:

1. **Physical carrier attachment.** Map the actual bounded device, ports,
   records, and updates to the chosen finite OPH carrier in an
   instrument-independent and presentation-invariant way.
2. **Frozen χν semantics.** Fix the presence/occupancy branch, provenance of
   \(P\), regulator behavior, coefficient, and uncertainty throughout every
   downstream document and simulation.
3. **Physical source map.** Derive and independently verify
   \(S_{\rm coh}(x,t)\), including units, normalization, zero/saturation
   rules, top/bottom/sum/volume observables, and controls. Force data must not
   calibrate this source.
4. **Dynamics or explicit EFT hypothesis.** Derive the repair-charge action
   from OPH, or label it honestly as an additional effective-field-theory
   conjecture. Establish its domain, stability, causality, and boundary
   conditions.
5. **Dimensional coupling.** Derive or independently measure a nonzero
   \(q_\star\), including uncertainty and material/device dependence.
6. **Charge or flux topology.** Show how the device has nonzero integrated
   repair charge, the required long-range field tail, or a measured outgoing
   repair-current/momentum flux. A top-minus-bottom contrast is insufficient.
7. **External field.** Identify, generate, measure, and reverse
   \(\nabla\theta_{\rm ext}\) independently of the device.
8. **Sign and conservation.** Derive the sign operation and close the complete
   matter-plus-field momentum and energy ledger over a full cycle.
9. **Existing-constraint reconciliation.** Explain why a coherent-state
   coupling would evade—or predict signals within—equivalence-principle,
   torsion-balance, ordinary piezo, electromagnetic, acoustic, and thermal
   constraints. The deleted historical assignment \(c_U=0\) for ordinary
   matter is not a current solution.
10. **Prospective numerical prediction.** Before force data, freeze a
    nonzero magnitude interval above measured sensitivity, sign/phase,
    distance and geometry dependence, null rule, alternatives, and the exact
    claim affected by each outcome.

The Lean library currently supports substantial OPH mathematics, but it
contains no χν force theorem. The local proof-chain formalization is
conditional and partially stale. The untracked
`CollarGatePresence.lean` result compiles and is relevant evidence, but should
be committed, imported by the umbrella module, and reflected in the formal
README/results. The broader Lean collar no-go and simulator
non-identifiability results are valuable constraints; they are not direct
premises of a χν force theorem unless a future derivation supplies that typed
dependency. See [theory traceability](gpt/01_THEORY_TRACEABILITY.md) and
[the full gate specification](gpt/03_THEORY_AND_EXPERIMENT_GATES.md).

Both audited Lean projects built successfully (8,307 core jobs and 8,287 local
proof-chain jobs at the captured revisions), so this is not a verdict based on
broken formalization. It is the stronger and more specific result that the
formalized theorems do not include the required source or force bridge.

The present OPH physics simulator is likewise not a gravity or force
simulation. Its explicit refusal to promote abstract witnesses to physical
measurements is a useful guardrail, not a numerical prediction for this
coupon. A new simulator should be written only after the source, action,
coupling, boundary conditions, and conservation equations are frozen; it
should solve the actual device-plus-field boundary problem and emit synthetic
blinded analysis receipts. The audited simulator tests passed while preserving
that physical-promotion refusal. The local Node showroom also passed its 38
self-tests, but still contains the superseded exponential coefficient literal;
passing those tests therefore confirms internal software consistency, not
current-theory or experimental validity.

### 3.b Hardware: proceed selectively, wait on weighing

Do not wait on every piece of hardware. Cheap work that has independent
metrology value can proceed, but the current board should not be fabricated
unchanged and the balance/vacuum campaign should wait.

The immediate hardware sequence should be:

1. Validate a single channel on the bench and measure \(f_s\), \(f_p\),
   complex impedance, drive voltage/current/power, \(Q\), ringdown, phase,
   temperature drift, and calibration injection.
2. Correct the PCB, run meaningful ERC/DRC, and generate a complete Gerber,
   drill, BOM, placement, stackup, commissioning, and inspection package.
3. Add raw waveform or coherent I/Q capture; environmental, acceleration,
   magnetic, battery, and drive-power sensors; local append-only atomic
   records; immutable run IDs/configuration hashes; and radio-off acquisition.
4. Implement the actual observer-like loop: self-read, record, held-out
   prediction, measured mismatch, registered update/repair, checkpoint, and
   continuation. Automatically interleave active, shuffled-history, detuned,
   dummy, and electrically/mechanically power-matched sham conditions.
5. Build a source-candidate article with physically separated zones and four
   to twelve active boundary ports—or provide a source-bound proof that a
   smaller physical set realizes the required logical carrier. The ideal
   research article would retain the twelve-port carrier, a matched twin, and
   independent raw-data verification.
6. Start force metrology only after the theory yields a prospective effect
   \(F_0\) comfortably above an empirically demonstrated detection floor.
   Then use a blind randomized protocol, injected-force calibration, Allan
   analysis, pressure sweep/high vacuum as needed, charge control, magnetic
   reversal, thermal and center-of-mass controls, dummy loads, rotation/flip
   tests, and independent replication.

Dave's balance floor should also be revised. \(5\times10^{-8}\) N corresponds
to about 5.1 micrograms weight, roughly twenty times below a 0.1 mg single
reading. That sensitivity might be recovered statistically in a carefully
characterized system, but it cannot be assumed from display readability. A
few millibar is not by itself an adequate convection/outgassing control, an
electrostatic force can contain a drive-frequency component, and physical
flipping changes cable, thermal, magnetic, and center-of-mass geometry.

### PCB-specific hold items

The fabrication-level review found issues not reached by Fable's broader
design audit. Its earlier statement that the board looked clean should
therefore not be treated as a manufacturing sign-off. The present release has:

- an unresolved S8050/J3Y and S8550/2TY SOT-23 pinout: the board maps
  pads 1/2/3 as base/collector/emitter, while cited implementations map
  base/emitter/collector; exact manufacturers and MPNs are not locked;
- no local 100 nF IC bypass capacitors or board-level 10 µF bulk capacitor;
- a floating unused CD4066 control;
- an unspecified CD4066 whose on-resistance at 3.3 V may dominate the nominal
  100 Ω drive impedance;
- conflicting bare-IC/module, diode/footprint, and LiPo/18650 specifications;
- custom symbol electrical types that make ERC less informative;
- no frozen manufacturing package, test-point/calibration plan, mounting
  scheme, or fiducials;
- firmware controls that are not power-matched or record-shuffled, batch
  rather than interleave A-S-A-O, and allow a mid-batch global-mode race.

These defects are repairable. They make the current revision a fabrication
hold, not a reason to discard the instrument concept.

## 4. Chances, extra assumptions, workload, and cost

### Probability

OPH being the correct fundamental theory does **not** imply an anti-gravity
hack. It would establish, at most, the relevance of the observer/repair
framework. The propulsion conclusion additionally requires all of these
not-yet-proven assumptions:

- the proposed rotor action is physically realized, rather than merely an
  allowed continuation;
- the apparatus implements a nonzero, physical \(S_{\rm coh}\);
- \(q_\star\) exists, is nonzero, and is not extraordinarily small;
- coherent devices have the required charge/selection rule without already
  excluded ordinary-matter effects;
- an accessible external repair gradient or outgoing repair-current channel
  exists;
- the device can control its sign or orientation;
- the effect survives the complete momentum/energy ledger;
- its laboratory magnitude exceeds unavoidable conventional backgrounds.

There is no evidence-backed frequency or Bayesian prior for those premises, so
the audits cannot supply a scientific percentage. For project planning—not
as an OPH prediction—a reasonable assessment is:

- **present design yielding a credible OPH anti-gravity discovery:** effectively
  0% for the present Milestone-1 board, which does not measure force; adding
  the currently drafted weighing stages would still leave essentially zero
  chance of a *credible OPH attribution* because they have no identifiable OPH
  prediction;
- **all extra premises producing a laboratory-scale propulsion effect,
  conditional on core OPH being right:** approximately **0.1–3% as a
  deliberately subjective planning prior**, with a central expectation below
  1%;
- **detecting the effect after every premise has independently passed:** this
  should no longer be guessed; the apparatus can be designed for greater than
  95% statistical power against the frozen predicted interval.

The low planning prior is not a declaration that the continuation is false.
It reflects a conjunction of many open bridges, each of which can fail or
produce an immeasurably small coupling. The correct response is staged
spending with explicit kill criteria, not a large force campaign now.

### Work and budget envelope

The following are order-of-magnitude planning estimates, not vendor quotes.
They assume professional labor and access to an ordinary electronics bench;
cash cost can be lower if existing staff and equipment are treated as sunk
cost.

| Stage | Effort / elapsed time | Incremental budget | Exit criterion |
|---|---:|---:|---|
| Corpus cleanup, coefficient sync, formal integration, theory problem statement | 2–6 person-weeks | €10k–€40k | One current claim/obligation ledger |
| Corrected one-channel and PCB metrology platform | 2–4 engineer-months | €5k–€25k | H0/H1 calibrated raw receipt |
| Observer-loop/source-candidate article | 6–12 months, mixed theory/engineering | €25k–€100k | H2/H3 source-only evidence bundle |
| Source/action/\(q_\star\)/field/conservation theory closure and dedicated simulation | 12–36 researcher-months | €150k–€500k | T1–T10 and prospective force interval |
| Precision-force pilot after theory closure | 9–18 months | €100k–€400k | Blinded, calibrated, receipt-complete result |
| Independent replication | 6–18 months | €100k–€500k | Independent end-to-end confirmation |

A credible end-to-end program is therefore roughly **2–5 years and
€300k–€1m+**, with stop/go decisions at each stage. The bare PCB is not the
cost driver: commercial prototype fabrication is advertised from a few
dollars, while component selection, review, calibration, mechanics,
environmental control, precision-force metrology, and skilled labor dominate.
Vacuum hardware alone can range from a few thousand to tens of thousands
before vibration isolation, balance/torsion instrumentation, sensors, and
custom mechanics. Those ranges are consistent with current public
[JLCPCB prototype pricing](https://jlcpcb.com/) and
[commercial diaphragm-pump pricing](https://www.idealvac.com/files/literature/Sec_05_Ideal_Vacuum_Dry_Diaphragm.pdf);
actual European quotations, VAT, shipping, and lab integration would need a
separate procurement exercise.

## Record and housekeeping recommendations

Document A was never locked, so the theory change did not breach a
preregistration. Do not lock it now. Preserve Documents A/B/C as the historical
record, add a dated notice that the imported force claim was withdrawn, and
start a new preregistration only after T1–T10 identify an eligible experiment.

The old coefficient and force language should be removed or clearly marked
historical in the local proof-chain paper, ledgers, simulation literals,
hoverboard material, student-experiment branch, and communication record.
This is both scientific hygiene and protection against accidentally reviving
the withdrawn claim.

The most valuable result of the work so far may be methodological: the
experiment exposed the missing record-to-physics bridge before expensive
hardware was commissioned. The PCB architecture, adversarial
preregistration, control logic, evidence-bundle discipline, and formal
countermodel work are reusable. What should be retired is the inference from
“self-reading piezo system” to “anti-gravity source” without the missing
physical derivation.

## Detailed reference map

- [Combined GPT overview](gpt/README.md)
- [Theory and claim traceability](gpt/01_THEORY_TRACEABILITY.md)
- [PCB, firmware, protocol, and Stage-0 review](gpt/02_DESIGN_ASSESSMENT.md)
- [Theory/hardware gates and re-entry criteria](gpt/03_THEORY_AND_EXPERIMENT_GATES.md)
- [Commands, revisions, and evidence register](gpt/04_EVIDENCE_REGISTER.md)
- [Fable corpus reconstruction](fable/CORPUS_STATE_2026-07-30.md)
- [Fable ledger divergences](fable/LEDGER_DIVERGENCES.md)
- [Fable readiness/design verdict](fable/VERDICT_READINESS_AND_DESIGN.md)
