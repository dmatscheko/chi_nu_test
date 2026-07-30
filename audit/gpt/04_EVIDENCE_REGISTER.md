# Evidence register — GPT

## 1. Snapshot

The audit is bound to the following local source state:

| Surface | Revision | State |
|---|---|---|
| `reverse-engineering-reality` | `b8ba5d024a1d223a4d7e5c8d218bb060c4032308` | `main`; paper release `r2004`; one unrelated generated-state modification noted below |
| `oph-physics-sim` | `ba4ce25aa6857cab9dca33927aa29d8db6c599c9` | `main`, clean |
| `chi_nu_test` | `663ef6168f024c75c8dfa50e7bfcc43f081a2ad8` plus the audited working tree | branch `audit` |

The three post-`r2004` commits through this HEAD were reviewed. They add and
then repair/refresh the bounded carrier/response specificity calibration and
its ledgers. They do not alter the χν owner paper, screen paper, dark-sector
paper, Lean tree, relevant `OPH-CHI-NU` registry row, falsification program, or
scoreboard. The calibration still explicitly says it is not a physical
forecast.

At final binding, that checkout also had one concurrent, unstaged change:
`code/particles/forecast_contract/outputs/forecast_contract_state.json`
(SHA-256
`2cfbe1097dc57cf506f0fe3112055043dbee90f27a3b9aaa85795f5a6a2fe947`).
Its diff refreshes only the frozen-prediction-register and state hashes. It
does not touch or supply evidence for this audit.

Pre-existing working-tree edits in `chi_nu_test` were preserved. This report's
deliverable is `audit/gpt/README.md` plus `audit/gpt/01_...` through
`audit/gpt/04_...`; it does not rewrite the experiment README, proof chain,
Documents A–C, or the untracked `CollarGatePresence.lean` correction. The
independent `audit/fable/` report was not used as evidence by this GPT audit.

Because that experiment checkout was dirty at audit time, its HEAD alone is
not the full evidence snapshot. The pre-existing non-audit status and SHA-256
bindings were:

| Status | Path | SHA-256 |
|---|---|---|
| `M` | `OPH_PROOF_CHAIN_PAPER.md` | `0568669346cd533ba97cf72218b5bdf8fa0085cebfd427689705fc601db7c0b7` |
| `M` | `README.md` | `cc6dbe27f4d094970714c5a073446f15c9edd92c5da432904ae39be92008edf1` |
| `M` | `proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md` | `accd9a68689892e46550e18ca701155b0564bd0ef8d48f49ec22ee6350f3ce90` |
| `M` | `proof_chain/formal_audits/DULA_REPOS_AUDIT_RAW.md` | `f19651ca13a1b25a9519300eecadd2e89ab0e94cf499c22346c2c9ce2f8b0a2f` |
| `M` | `proof_chain/formal_audits/PIE_AUDIT_RAW.md` | `c5d1b5aae2ad6b4924f215ae06b154b12ad12644cecef8498ae7b804565ce737` |
| `M` | `test/DOCUMENT_A_prediction_ledger.md` | `adfe704473b94f760be67b08654e60798f1833ff74fdf35a868e3146a3867d07` |
| `??` | `proof_chain/formal/OPHProofChain/CollarGatePresence.lean` | `2e72096d33c90b667b55820402025412bc589166371897d88b40c3629af9a704` |

Line anchors to edited experiment files are bound to these exact bytes, not
just to commit `663ef6168f024c75c8dfa50e7bfcc43f081a2ad8`.

## 2. Primary current-paper anchors

### Claim boundary and force

| Question | Primary source |
|---|---|
| Is χν a force coefficient? | `reverse-engineering-reality/extra/chi_nu_susceptibility_bounds.tex:52–90` |
| Does the flagship synthesis agree? | `paper/observers_are_all_you_need.tex:1330–1348,1492–1500` |
| What is the source? | χν paper `:96–123`; `paper/screen_microphysics_and_observer_synchronization.tex:1356–1398` |
| What is the current coefficient? | χν paper `:125–188`; screen paper `:1846–1868,2012–2029` |
| What remains open in the action? | χν paper `:208–232`; `cosmology/oph_dark_matter_paper.tex:41–123` |
| What is the conditional force? | χν paper `:314–336`; dark paper `:284–332` |
| Does ACTIVE± reverse device charge? | χν paper `:338–347` |
| Can a neutral compact contrast lift? | χν paper `:349–412`; dark paper `:163–180,326–332` |
| What must a force experiment measure? | χν paper `:414–436` |
| Is there a binding falsifier? | `claims/claim_registry.yaml:1873–1894`; `claims/falsification_matrix.csv:61` |
| Is anti-gravity in the mature program? | `docs/OPH_FALSIFICATION_PROGRAM.md:59–81` |

### Coefficient provenance

| Question | Primary source |
|---|---|
| Are \(P/4\) and \(\mathbb Z_6\) equidistribution derived? | screen paper `:1551–1630` |
| Is an unconditioned reserve trace sufficient? | screen paper `:1828–1843` |
| Presence versus Poisson semantics | screen paper `:1846–1868` |
| Exact-value gate | screen paper `:2057–2090` |
| Which \(P\) does χν use? | `extra/fine_structure_constant_derivation.tex:270–286` |
| Is that \(P\) source-only? | same file `:867–909` |

### Core scope

| Question | Primary source |
|---|---|
| Does A1 imply response/gravity/lab identification? | `claims/axiom_registry.yaml:18–30` |
| Does A3 imply a source/response law? | same file `:73–82` |
| How many claims are physically established? | `tracking/claims_scoreboard.md:26–35` |
| Hardware claim subject boundary | `docs/HARDWARE_EVIDENCE_BUNDLE_H.md:23–28` |
| Extraordinary-claim attestation | same file `:105–124` |

## 3. Formal anchors

| Finding | Source |
|---|---|
| Primary Lean scope and explicit physical residues | `reverse-engineering-reality/Lean/ObserverPatchHolography.lean:35–77` |
| Collar-clause positive/negative witnesses | `Lean/ObserverPatchHolography/CollarLayer.lean:447–483` |
| Clause not layer-determined | same file `:485–497` |
| Equivariant-channel no-go | same file `:1064–1137` |
| State-side no-go | `Lean/ObserverPatchHolography/CollarStates.lean:1121–1148` |
| Capacity selector non-identifiability | `Lean/ObserverPatchHolography/CapacityNonidentifiability.lean:232–258` |
| Conditional Einstein composition premises | `Lean/ObserverPatchHolography/EinsteinBranch/Composition.lean:10–80` |
| Continuum kernel/geometric-expansion premises | `Lean/ObserverPatchHolography/EinsteinBranch/SmallBall.lean:95–133` |
| Correct local presence algebra, not in umbrella | `chi_nu_test/proof_chain/formal/OPHProofChain/CollarGatePresence.lean:81–166` |
| G9/null scope in the local proof chain | `chi_nu_test/proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md:889–896` |

## 4. Simulator anchors

| Finding | Source |
|---|---|
| OPH-FPE structural claim boundary | `oph-physics-sim/docs/WHAT_OPH_FPE_DOES.md:62–90` |
| Assumptions cannot promote gravity | `oph-physics-sim/docs/SIMULATION_ASSUMPTION_POLICY.md:3–21,44–59` |
| Current Einstein instruments not attained | `oph-physics-sim/docs/EINSTEIN_BRANCH.md:113–140` |
| Finite rows do not prove convergence | same file `:191–212` |
| Physical promotion is false | same file `:241–246` |
| Stale χ import, G9 hard-false | `oph-physics-sim/oph_fpe/consensus/proof_chain_imports.py:82–125` |
| Import is not a physical prediction | `oph-physics-sim/docs/PROOF_PACKET_AUDITS.md:105–121` |
| Local simulator's own hypothesis firewall | `chi_nu_test/oph_sim/README.md:76–92` |

## 5. Hardware anchors

| Finding | Source |
|---|---|
| M1 is not a lift test | `chi_nu_test/build/MILESTONE_1_build.md:1–28` |
| Prediction is deferred | same file `:30–37` |
| A1 twelve-port local carrier | `reverse-engineering-reality/claims/axiom_registry.yaml:10–17` |
| Current manual's four-to-twelve-port engineering minimum | `reverse-engineering-reality/extra/hacking-the-simulation-anti-gravity-exploit/10-the-first-real-poc.md:11–24` |
| Declared interleaving requirement | `chi_nu_test/build/MILESTONE_1_build.md:39–57` |
| Stage-0 resonance correction | `build/STAGE0_results_run1.md:70–93` |
| Matrix calibration/diagonal limits | same file `:116–148,192–209` |
| Firmware controls | `build/chi_nu_poc.yaml:25–30,222–251` |
| Feed-forward measurement scripts | same file `:259–375` |
| External HA evidence statement | same file `:377–398` |
| BJT net assignments | `build/kicad/MILESTONE_1_build/full_instrument/full_instrument.kicad_pcb:5191–5570,13186–13959` |
| Floating unused CD4066 control | same PCB file `:12747–13153` |
| Intended decoupling | `build/electronics.md:320–329,416–418,576–589` |
| Weak ERC symbol pin types | `build/kicad/MILESTONE_1_build/full_instrument/schpy.kicad_sym:26–52,118–146,191–223` |

External primary component references used for the pinout check:

- [HY Electronic S8050/J3Y](https://www.hygroup.com.tw/upfiles/ADUpload/all_/S8050%20Rev-0.pdf);
- [Semiware S8550/2TY](https://en.semiware.com/uploads/datasheet/S8550.pdf);
- [Texas Instruments CD4066B](https://www.ti.com/lit/ds/symlink/cd4066b.pdf).

## 6. Verification run

### Lean

The following completed successfully:

```text
reverse-engineering-reality/Lean:
  lake build ObserverPatchHolography
  8307 jobs

chi_nu_test/proof_chain/formal:
  lake build
  8287 jobs

chi_nu_test/proof_chain/formal:
  lake env lean OPHProofChain/CollarGatePresence.lean
  success
```

The core Lean build ran at post-release commit `fd36a8ea`. During final QA the
OPH checkout advanced to the snapshot HEAD in Section 1; the reviewed diff
contains no changes under `Lean/`, so the built Lean tree is byte-identical
for this audit.

The direct presence-module build is important: the module is valid but is not
imported by `proof_chain/formal/OPHProofChain.lean`, so the 8287-job umbrella
build does not certify or count it.

### Experiment-local simulator

```text
node chi_nu_test/oph_sim/node/selftest.mjs
38 passed, 0 failed
```

The passing battery includes a stale T16 assertion for
\(e^{-P/24}\). It verifies reproducibility of the old conditional model, not
current physical validity.

### Core simulator

```text
oph-physics-sim/.venv/bin/python -m pytest -vv \
  tests/test_stress_coupling_producer.py
5 passed

oph-physics-sim/.venv/bin/python -m pytest -vv \
  tests/test_source_gap_receipt.py
5 passed
```

The stress test intentionally passes by confirming that the current source has
no universal coupling and that physical promotion remains false. A passing
test suite is therefore consistent with a failed physical gate.

### PCB

No independent KiCad ERC/DRC was run because `kicad-cli` is unavailable in the
audited environment. Static inspection found the unresolved pinout mapping,
floating switch control, decoupling, package, sensor, protocol-control, and
manufacturing-package issues documented in `02_DESIGN_ASSESSMENT.md`.

## 7. Limitations

- No new physical data were taken.
- No destructive or powered electrical test was performed.
- No ERC, DRC, SPICE, thermal, EMC, structural, or modal simulation was run.
- No balance, vacuum, electrostatic, or magnetic apparatus was inspected.
- This audit assesses current theory-to-measurement traceability and obvious
  design blockers; it is not a fabrication release or safety certification.
- Line anchors refer to the exact revisions in Section 1. Later source edits
  may move them.
