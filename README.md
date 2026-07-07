# χ_ν coherent-matter lift test

A pre-registered, falsifiable test of the OPH **χ_ν "coherent-matter lift"** claim —
the mechanism behind the OPH hoverboard concept — together with the audit work
that maps what the OPH corpus actually proves. The aim is to fix exactly what the
theory predicts **before** any data is taken, build the minimal self-reading device
the prediction requires, and let a pre-agreed decision rule — not either side's
prior — settle the outcome (detect / null / mundane / undefined).

Path shortcuts used throughout (`OPH:/`, `HOVER:/`, `ANS:/`) are defined in
Document A; `ANS:/` now points at this repo's own [`communication/`](communication/)
directory.

## Layout

| Directory | What lives there |
|---|---|
| [`OPH_PROOF_CHAIN_HOLES.md`](OPH_PROOF_CHAIN_HOLES.md) | **The adversarial audit companion, two passes** — an independent hole inventory of the chain's interpretation layer (first pass F1–F19 against v5; second pass F20–F29 + per-finding disposition audits against v6.1; both passes independently *confirm* the formal layer by environment-level axiom sweeps). v6.1 adopted the first pass; **v7 closed both passes' mathematics by theorem** (T27/T28/T29 + F20/F25/F26 closures) and swept the second pass's residue ledger; disposition tables in the proof chain's §11. |
| [`OPH_PROOF_CHAIN_PAPER.md`](OPH_PROOF_CHAIN_PAPER.md) | **The expository paper** — the whole machine-checked proof chain written as ordinary mathematics: statement, proof, "why", and a plain-language paragraph per result. Adds nothing to the Lean tree (the tree is the authority); exists so a physicist can read the chain end-to-end without opening a `.lean` file. |
| [`test/`](test/) | **The physics test** — the pre-registration ledgers that govern the experiment. |
| [`proof_chain/`](proof_chain/) | **The minimal-proof-chain work** — what the OPH corpus proves (incl. the `formal/` Lean project that machine-checks it), the audit exchange with the OPH side, and the satellite-repo audits. |
| [`build/`](build/README.md) | **The hardware** — Milestone-1 self-reading piezo PoC (build plan, rev-2 electronics + schematics, jig, firmware) and the Stage-0 calibration results. |
| [`communication/`](communication/) | **The Q&A with the OPH side** (`ANS:/`) — questions, replies, and the OPH-side PDFs. Absorbed from the former sibling repo on 2026-07-06. |

## The physics test (`test/`)

| File | Role |
|---|---|
| [`DOCUMENT_A_prediction_ledger.md`](test/DOCUMENT_A_prediction_ledger.md) | **Start here.** Imports the OPH math with verified provenance, records the agreed OPH-side inputs, discloses the conservation-law priors, and derives the falsifiable predictions + decision rule. Governs the outcome on its own. |
| [`DOCUMENT_C_run_matrix_and_error_budget.md`](test/DOCUMENT_C_run_matrix_and_error_budget.md) | The instrument, the run matrix (R-pre, ABBA, ACTIVE±/SHAM, blind controls), the error budget that fixes the detection floor, and the energy-budget logging. |
| [`DOCUMENT_B_critique_ledger.md`](test/DOCUMENT_B_critique_ledger.md) | Open-questions & credit ledger. Two live items — the ΔS-estimator bridge (G9) and the energy ledger (G10) — plus the disposition of the original critique (mostly closed) and what stands regardless of any outcome. |

## The minimal proof chain (`proof_chain/`)

| File | Role |
|---|---|
| [`OPH_CORE_MINIMAL_PROOF_CHAIN.md`](proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md) | **v7.** The minimal proof chain for the core OPH idea: machine-checked (Lean) → paper-side theorems → conditional → asserted/calibrated — with the conservation-law bounds on the χ_ν chain. Background for all three ledgers. |
| [`formal/`](proof_chain/formal/) | **The Lean 4 project that machine-checks the chain** — 29 modules; 1480 theorem/def declarations swept at the environment level, 0 `sorry`, 0 custom axioms (incl. an attributed copy of the OPH core with its three `sorry`s discharged, and the v7 modules closing the adversarial audit's mathematics: Route A assembled, the real-time modular flow, the channel bridge). See its [`README`](proof_chain/formal/README.md) and the statement-by-statement audit in [`RESULTS.md`](proof_chain/formal/RESULTS.md). |
| [`AUDIT_RESPONSE.md`](proof_chain/AUDIT_RESPONSE.md) | The OPH side's 2026-07-06 response to our audit: validity grading per gap + the July paper pass that answers it. |
| [`AUDIT_RESPONSE_REVIEW.md`](proof_chain/AUDIT_RESPONSE_REVIEW.md) | Our verification of that response: all pin-cites checked, the P-derivation code executed (two-P finding), three refinements (R1 feed-forward carrier, R2 falsifiers ≠ energy ledger, §P). |
| [`formal_audits/`](proof_chain/formal_audits/) | Raw audits of the `dula/` satellite repos (verdict: not proof-chain-relevant; one reusable artifact, since ported). |

## How it fits together

**test/A** — what the theory predicts and how the result is decided ·
**test/C** — how it is measured · **test/B** — what stays open and what stands ·
**proof_chain/** — the standing of every imported claim and the audit exchange ·
**build/** — the device that produces the self-read receipt A requires ·
**communication/** — the primary-source Q&A the ledgers cite as `ANS:/`.

Version history lives in git: v0.1 ledgers (2026-06-02/03), the correction
pass ("corrections pass 1"), the v0.2 rewrite (2026-07-05), the audit exchange
and proof-chain v2 (2026-07-06), the v3/v4 `formal/` campaigns — the whole
chain machine-proven in one tree (2026-07-06) — the v5 campaign closing
the remaining open mathematics, incl. the D3 finite modular core and one
ledger erratum (2026-07-07) — and the v6 campaign settling the stride
conjecture (T25, the coprimality classification of two-column screens,
with the mirror lemma and the quotient lift as new tools) plus the
expository paper `OPH_PROOF_CHAIN_PAPER.md`, audited against the Lean tree,
and the v6.1 response to the adversarial audit `OPH_PROOF_CHAIN_HOLES.md`
(T26 — the cosmological-constant step; the G10 pricing convention named;
the F18 erratum table applied; disposition in the proof chain's §11)
(2026-07-07) — and the v7 campaign closing both audit passes' mathematics
by theorem (T27 Route A assembled; T28 the real-time modular flow; T29 the
channel bridge; the F20/F25/F26 closures; the ℤ₆ group isomorphism; the
theorem-grade energy anchors; the F22 evidence artifacts; the F21 residue
sweep) (2026-07-07). The former
`communication/` sibling repo's own history remains at
https://github.com/dmatscheko/hoverboard-experimental-precursor.
