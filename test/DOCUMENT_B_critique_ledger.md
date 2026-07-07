# Document B — Open Questions & Credit Ledger

**χ_ν coherent-matter lift test · what remains open, what is settled, what stands regardless**

| | |
|---|---|
| Status | OPEN ledger — shared working document (no longer a held critique) |
| Version | 0.3.1 (2026-07-07, second refresh: counts and open items updated to proof-chain v7 — the earlier 0.3 row said "v4" over v4-era counts; 0.3, 0.2 and the v0.1 critique ledger are in git) |
| Companion to | `DOCUMENT_A_prediction_ledger.md`, `DOCUMENT_C_run_matrix_and_error_budget.md` (this directory), `proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md` |

> Path shortcuts (`OPH:/`, `HOVER:/`, `ANS:/…`) are defined in Document A.

> **2026-07-06 — OPH-side audit response received** (`proof_chain/AUDIT_RESPONSE.md`, via
> PR): it grades every gap in this ledger, accepts nearly all of them as valid,
> and answers with a July paper pass that adds theorem surfaces, receipts and
> scope boundaries. Our verification of that response (all pin-cites checked):
> `proof_chain/AUDIT_RESPONSE_REVIEW.md`. Dispositions below updated accordingly.

> **2026-07-07 — proof-chain v4: the `formal/` Lean tree completes.** The whole
> mathematical side of the chain is now machine-proven in one tree
> (`proof_chain/formal/`: 29 modules as of v7, environment-swept — **0
> `sorry`** — including an attributed copy of the OPH Lean core with its three
> declared `sorry`s discharged). **No physics grade changed and nothing in the
> decision rule moved**; the v0.3 edits below are status/credit refreshes only
> (G6, G9, G10 pointers; V2, V3, V6 credits; Part 5 item 3 executed). Details:
> `proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md` (v4), `proof_chain/formal/README.md`,
> `proof_chain/formal/RESULTS.md`.

## Why this document changed character

Version 0.1 was written 2026-06-02 as a *held* critique — nine logical gaps
(G1–G8, later G9), firewalled so they would only be argued from after a
confirmed null. It is now mostly a historical success story: the OPH side's
2026-06-03 answers closed or openly acknowledged nearly everything, the
engineering prose adopted the conditional framing the ledger asked for, and
the 2026-07-05 verification pass moved the remaining derivation-status caveats
*into Document A itself*, disclosed at the point of import (A §1.4, §1.5,
§1.9). There is nothing left to hold back: what remains are **two open
questions both sides share**, and a credit list. On a NULL outcome, this
document frames the discussion section; on a DETECT it records what a
detection must overturn.

## Part 1 — Disposition of the original gaps

| Gap (v0.1) | Disposition (v0.2) |
|---|---|
| G1 conditional-as-recovered | **Closed.** The explainer now *leads* with the conditional ("Recovered OPH alone leaves tabletop lift unforced … Under those assumptions…", `HOVER:/docs/explainer.md:6–9`). |
| G2 no operational scalar | **Closed** → operationalized as the self-read receipt (A §3.2, §3.5); the residue is G9. |
| G3 self-read undefined | **Closed.** Defined as the read-write loop (case ii); BiFeO₃ demoted to optional insert (A §1.7, §3.1, §3.5). |
| G4 engineering chart | **Closed.** Both sides treat it as an exact rescaling and work canonically (A §1.3). |
| G5 force law not derived | **Acknowledged, stands — now disclosed in A §1.5** and by the OPH side ("the paper stack has made the force law a search and response branch, not a closed recovered-core prediction", `proof_chain/AUDIT_RESPONSE.md`). The papers add source-lift falsifiers + power/stored-energy bounds (`OPH:/extra/chi_nu_susceptibility_bounds.tex:1412–1424, 1472–1495, 1696–1719`). Folded forward into G10. |
| G6 "theorem-grade" wording | **Closed (July pass).** The exact e^(−P/24) is now a conditional theorem with an explicit gate — lemmas L1–L7 with the uniform product-thickening branch and slice-wise reserve-unbiasedness — plus a receipt ledger forbidding exact-value claims without the gate (`OPH:/paper/screen_microphysics_and_observer_synchronization.tex:1300–1411, 1475–1492`; imported at `OPH:/extra/chi_nu_susceptibility_bounds.tex:1021–1210`). A §1.4 reflects this. **v4 (2026-07-07):** the gate's consequence structure is itself machine-checked — unbiasedness ⇒ e^(−P/24) exactly, plus the [e^(−P/24), 1] Jensen band (`proof_chain/formal/OPHProofChain/CollarGate.lean`); the conditionality now rests entirely on the L-clauses. |
| G7 exemption consistency | **Subsumed** into G9 (with the loop-based exemption, the tension is exactly the bridge magnitude). |
| G8 target-anchored numbers | **Stands, refined (2026-07-06).** The July pass adds real row-status discipline (source vs endpoint vs backend-gated rows; quarks "withheld from public prediction table"). But the code trace settles P: the genuine zero-input solver outputs P_root = 1.6309721 (α⁻¹ = 136.9948, ~300 ppm off), and the published P = 1.6309682… is *by definition* φ + √π/CODATA-α — so every downstream use of the famous digits silently consumes measured α. The papers' own no-go theorem and source-input rules concede this in the fine print. Immaterial for this experiment (Δχ_can ~ 1.6×10⁻⁷); decisive for the corpus's "zero fitted parameters" rhetoric. Full trace: `proof_chain/AUDIT_RESPONSE_REVIEW.md` §P. |
| G9 ΔS-estimator bridge | **OPEN** — Part 2 below. |
| G10 energy ledger | **OPEN (new, 2026-07-05)** — Part 2 below. |

## Part 2 — The two open questions (shared, not adversarial)

### G9 — The ΔS-estimator bridge

- **Status:** open; stated openly by the OPH side ("a null bounds χ_ν·ΔS, or
  χ_ν alone only if the ΔS estimator is accepted", `ANS:/answer` §4; reaffirmed
  in `proof_chain/AUDIT_RESPONSE.md`). **Definition side closed (July pass) — and
  machine-checked (proof-chain v4, 2026-07-07):** the chi-nu paper carries the
  finite coherent-matter source generator — the self-reading subfederation,
  its quotient-visible scalar-slot footprint, and the source generator
  (`OPH:/extra/chi_nu_susceptibility_bounds.tex:625–746`) — and that generator
  now exists as a *formal object*, with the paper's Theorem B.7 proved in Lean:
  `(𝓛 𝒩)(q) = S·avail(q) > 0`
  (`proof_chain/formal/OPHProofChain/DeltaSBridge.lean`). What remains open is
  exactly the **numerical map** from an apparatus record contrast to the
  gravitational scalar.
- **The question:** why should the coherence contrast computed from the
  coupon's *port records* be the same scalar that sources the *gravitational*
  force law — and at what scale? A healthy self-reading device naturally
  produces record contrasts of order 10⁻²–1; the force law then predicts
  10⁷–10⁸ N on an 80×60 mm coupon (F ≈ 5.14×10⁸·ΔS). So the bridge, if it
  exists, carries a large unspecified suppression.
- **Consequence for the test (already built into A §3.2/§4.4):** the
  experiment measures sign, scaling and branch, and yields a clean bound on
  the product χ_ν·ΔS regardless; χ_ν alone only if the bridge is granted.
- **What would close it:** derive or independently constrain the map from
  record-ΔS to gravitational ΔS. This is the highest-leverage theory item.
  Since v4 the target is precise: a proposed bridge must calibrate the
  formally-defined record-side increment `S·avail(q)` (`DeltaSBridge.lean`)
  against the gravitational scalar — no ambiguity remains about *what* is
  being mapped, only the map itself.

### G10 — The energy ledger (conservation-law constraint)

- **Status:** open physics obligation on any completed χ_ν theory; disclosed
  pre-lock in A §1.9; full derivation in `proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md` §5
  — **theorem-form since proof-chain v3**
  (`proof_chain/formal/OPHProofChain/EnergyCage.lean`: the ABBA cycle
  identity, `no_free_toggle`, the ledger lower bound, and the numbers below
  as machine-checked intervals — σ_ph ∈ (11.6, 11.8) kg m⁻², toggle
  ∈ (3.49, 3.52) MJ).
- **The constraint:** a switchable force must satisfy F = −∇E_state. Either
  toggle costs are height-independent (⇒ a work-extracting cycle: perpetual
  motion), or the toggle costs carry the position-dependence — the cycle
  theorems force ledger entries at the scale of *realized cycle work*
  (ΔM·g·Δh; ≈ 0 at fixed height). Under the **named G10-convention**
  (infinity-referenced interaction pricing — a hypothesis of the decision
  layer, per the 2026-07-07 adversarial audit F15, not a consequence of the
  theorems), every ACTIVE toggle is priced as a |ΔM·Φ_N| ≈ 3.5 MJ
  transaction at the 56 gf design point — and a battery coupon can source
  at most χ·ΔS ≲ 1.1×10⁻¹¹ per toggle (erratum-corrected value, A §1.9).
- **Why it is shared, not a gotcha:** it protects the OPH side too. Any
  claimed detection that has not measured its energy flows will not survive
  review; logging the toggle-energy budget (Document C Part 7) makes a
  candidate defensible — and makes the expected NULL quantitative.
- **What would close it:** a force-law derivation from local dynamics **with
  an explicit energy ledger** (where does F·h per cycle come from?). Until
  then the force law is a search protocol, not a prediction — which the
  pre-registration structure already treats correctly. The OPH response accepts
  this as valid ("a completed force law needs local energy bookkeeping for
  switchable force cycles"). Note: the new source-lift falsifiers
  (`:1696–1719`) are *operational identity* tests, not energy-flow accounting —
  the C Part 7 battery-energy logging remains our addition.

## Part 3 — What the experiment adds to each outcome

- **On NULL:** G9 becomes a measured bound — with the R-pre receipt's ΔS and
  the Document C floor, χ_ν·ΔS ≤ 9.1×10⁻¹⁷, and (bridge granted)
  χ_can ≤ ~10⁻⁷ for a reported ΔS ~ 10⁻⁹: seven orders below the Tier-C floor,
  on OPH's own blessed device class with the active/dummy distinction fixed
  *before* the run. G10's magnitude analysis becomes an empirical statement
  about a receipt-passing device.
- **On DETECT:** G9 and G10 are exactly what a write-up must overturn or
  reconcile — the ledger doubles as the reviewer-anticipation checklist.
- **On UNDEFINED (R-pre fails):** the open problem is G9 by construction;
  nothing was weighed and nothing about χ_ν was tested.

## Part 4 — What stands regardless of any outcome

None of the following depends on the lift claim, and none is touched by a
null. This is the part to lead with in any writeup.

- **V1 — The arithmetic-chain note** (`OPH:/contributions/background/…`):
  correct classical mathematics, explicitly marked `oph_dependency: false`.
- **V2 — The Poisson→MOND activation derivation**
  (`OPH:/cosmology/oph_dark_matter_paper.tex:594–830`): a compact,
  self-contained route to ν = [1−exp(−λ√(g_b/a₀))]⁻¹ — a known-good MOND
  interpolating function — with the baryonic Tully–Fisher limit and a claimed
  a₀ within ~1.75 % of empirical (`:2095–2110`). The one continuation with genuine
  phenomenological content; worth developing on its own merits. *v4: its
  mathematics is machine-checked* (`proof_chain/formal/OPHProofChain/DarkSector.lean`:
  well-definedness, Newtonian + deep-MOND limits with the exact √(a_eff·g_b)
  scaling, BTFR, the rare-event exponential); the Poisson-counting premises
  remain the paper's named hypotheses.
- **V3 — The collar-survival inequality**: e^(−P/24) via Jensen on a convex
  survival integral (`OPH:/extra/chi_nu_susceptibility_bounds.tex:1174–1186`)
  is clean mathematics; only the physical identification of the register is
  conditional (A §1.4). *v4: now literally theorems* — `jensen_band` and
  `uniform_gate` in `proof_chain/formal/OPHProofChain/CollarGate.lean`, with
  the (P/4)/6 = P/24 bookkeeping and the twelve-port count grounded in
  combinatorial Gauss–Bonnet.
- **V4 — The methodological hygiene**: falsifiability ladder with kill
  conditions and blind-relabeling discipline
  (`OPH:/extra/OPH_falsifiability.md:610–630`), matched-dummy control matrix
  (`HOVER:/docs/acceptance.md`), and the tier language in the papers
  themselves.
- **V5 — The OPH-side response practice** (2026-06-03): confirmed the
  concerns, chose case (ii), converted the undefined scalar into a measured
  receipt, and labeled the work "not an experimental claim". That practice is
  what closed most of this ledger.
- **V6 — The Lean corpus (2026-07-05 finding; grown through proof-chain
  v3/v4, 2026-07-06/07).** The machine-checked, sorry-free results remain the
  strongest scientific asset in the corpus — and the asset has grown well past
  the original `OPH:/LEAN/` core (consensus termination + completeness; the
  **non-confluence counterexample** — a unique "objective reality" is *not*
  automatic; the width-3 Rule-90 toy). Since v4 the whole chain's mathematics
  lives in **one in-repo tree**, `proof_chain/formal/` (29 modules as of v7, 1480 environment-swept
  axiom-audited declarations, 0 `sorry`, standard axioms only), including an
  attributed copy of `OPH:/LEAN/` with its three declared `sorry`s
  **discharged** (the canonical frustration-free repair; the gauge congruence
  proved). Highlights beyond the original core: the **sharp** Rule-90 screen
  theorem (width-2 timelike tube is an information set ⟺ n ≤ 2(t+1) — real
  holography-as-erasure-correction at the information bound); **boost
  invariance** of screen capacity at the two extreme slopes (intermediate
  rational slopes conjectural — chain §7 item 6) and the **parity
  obstruction** for gapped screens; the SM hypercharge lattice forced by anomalies + Yukawa closure
  and the ℤ₆ kernel computed exactly; the Einstein-branch algebra with the
  cosmological constant as the proven residual freedom; and the hexacode
  `[6,3,4]₄` MDS toy (every 3-subset reconstructs). Map:
  `proof_chain/formal/README.md`; statement-by-statement audit:
  `proof_chain/formal/RESULTS.md`; summary:
  `proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md` §1.

## Part 5 — Remaining repairs (by leverage)

1. **Close G9** — derive/constrain the record-ΔS → gravity-ΔS map (the
   record side is now a formal object — see Part 2).
2. **Close G10** — a force-law derivation with an explicit energy ledger
   (or accept "search protocol" status permanently).
3. ~~**Grow the Lean core** (V6): close the three declared `sorry`s and prove
   a joint HB ∧ Hfib carrier beyond one edge (multi-cell Rule 90 is the
   natural target).~~ **Executed** (proof-chain v3 + v4, 2026-07-06/07): the
   three `sorry`s are discharged
   (`proof_chain/formal/OPHProofChain/Core/Primitives.lean`) and the
   multi-edge carrier exists at full strength — the sharp n×t Rule-90
   cylinder theorem with the `Hfib` discharge in the core's own binder form
   (`Rule90Cylinder.lean`, `CarrierBridge.lean`). Successor targets in the
   same spirit (publishable mathematics independent of every physics
   continuation): ~~the odd-n gapped-screen threshold~~ (closed — T20 in
   v5, subsumed by T25's coprimality classification in v6) and the full
   weight-distribution classification of arbitrary cell subsets (still
   open, decidable framework in place; plus, since v7, the two named
   routine leftovers: async-schedule termination for T27's decode
   dynamics and Skolem–Noether for T28), and upstreaming `formal/Core/`
   into `OPH:/LEAN/` (a file move; the OPH side's call).

## How to use this document

Freely — there is no firewall anymore. Cite Part 1 for what is settled,
Part 2 for what any interpretation must confront, Part 4 for what deserves
credit and continued work regardless of the balance's verdict.

- Prepared by: _______________________  date: __________
