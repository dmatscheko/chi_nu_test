import OPHProofChain.Core.AbstractRewriting
import OPHProofChain.Core.Primitives
import OPHProofChain.Core.Rule90
import OPHProofChain.RepairHypotheses
import OPHProofChain.Rewriting
import OPHProofChain.QuotientRepair
import OPHProofChain.NotEinsteinComplete
import OPHProofChain.LayeredCarrier
import OPHProofChain.Rule90Cylinder
import OPHProofChain.CarrierBridge
import OPHProofChain.EnergyCage
import OPHProofChain.PBranches
import OPHProofChain.ScalarResponse
import OPHProofChain.Hypercharge
import OPHProofChain.CenterZ6
import OPHProofChain.EinsteinBranch
import OPHProofChain.LambdaConstancy
import OPHProofChain.DarkSector
import OPHProofChain.CollarGate
import OPHProofChain.SimplicialSurface
import OPHProofChain.DeltaSBridge
import OPHProofChain.HexacodePort
import OPHProofChain.Rule90Decoding
import OPHProofChain.Rule90Stride
import OPHProofChain.Rule90Readout
import OPHProofChain.Rule90Propagation
import OPHProofChain.Rule90Slope
import OPHProofChain.Rule90Lipschitz
import OPHProofChain.Rule90Crawl
import OPHProofChain.Rule90Parity
import OPHProofChain.Rule90TwoPower
import OPHProofChain.Rule90Diagonal
import OPHProofChain.ModularCore
import OPHProofChain.LedgerNumerics
import OPHProofChain.ConsensusSafety
import OPHProofChain.RouteA
import OPHProofChain.ModularFlow
import OPHProofChain.ChannelBridge

/-!
# OPHProofChain — machine-checked closure work for the OPH minimal proof chain

Standalone Lean 4 + Mathlib project (toolchain and Mathlib pinned to the same
revisions as `observer-patch-holography/LEAN`, so every result transfers 1:1).

| Module | Closes / prices | Proof-chain link |
|---|---|---|
| `Core/AbstractRewriting` | attributed copy of the OPH core (verbatim) | Layer 0 carrier |
| `Core/Primitives` | attributed copy **with the three `sorry`s discharged**: canonical frustration-free `localRepair`, declared-order `Repair`, `repair_respects_gauge` proved; `Termination`/`LyapunovDescent` for every carrier; `Completeness` under `EdgeRepairable`; `Confluence` refuted on the demo | T12 — the whole chain in one tree |
| `Core/Rule90` | attributed copy (verbatim): the width-3 toy, `Hfib` half, no-frustration-free-repair theorem | T5 |
| `RepairHypotheses` | `[formal-v6]` `EdgeRepairable` is **strictly** weaker than `FrustrationFree` — witnessed by the width-3 carrier itself (native module; the `Core/` copies stay verbatim) | T12 grading, strictness half |
| `Rewriting` | self-contained Newman + unique normal forms | infrastructure |
| `QuotientRepair` | P1 — quotient repair operator package (Route B) | Layer 0.5 → 0; Def 4.1 / Prop 4.2 rows |
| `NotEinsteinComplete` | P2 — bare consensus is not Einstein-complete | Layer 0.5 → 0 |
| `LayeredCarrier` | P3 — layered boundary carrier (H_B ∧ H_fib + reconstruction) | Layer 0.5 → 0 |
| `Rule90Cylinder` | The QECC-strength carrier theorem (sharp) | §7.2 "open jewel" (T9) |
| `CarrierBridge` | The jewel in the Lean core's own `H_fib` binder form | R1 |
| `EnergyCage` | G10 cage: cycle theorem + design-point arithmetic | §5, L2.11 pricing |
| `PBranches` | The two-P finding + χ_can value, machine-checked | L2.5 §P, L2.10 |
| `ScalarResponse` | P4 form half: unique response under SEE (LA core) | L2.9 (Tier B0) |
| `Hypercharge` | anomalies + Yukawa ⇒ SM hypercharge lattice, uniquely | L2.4 algebra (T13) |
| `CenterZ6` | the trivially-acting central subgroup is exactly ℤ₆ | L2.4 algebra (T13) |
| `EinsteinBranch` | D5 algebra: rest-frame arithmetic, timelike upgrade, null-cone λη-freedom | L2.3 core (T14) |
| `LambdaConstancy` | `[formal-v6.1]` **the cosmological-constant step (T26)**: pointwise null-cone matching + the two named divergence inputs (contracted Bianchi, stress conservation) + chart connectivity ⟹ `F = κT + Λη` with **one** constant `Λ` — the λ-field of `jacobson_step` promoted to a theorem, closing holes-audit F8; connectivity counterexample included | L2.3 completion (T26) |
| `DarkSector` | activation-law mathematics, phantom-density identity, point-source profile, thin-device FTC step | L2.7/L2.8 + L2.11 half (T15) |
| `CollarGate` | gate skeleton: unbiasedness ⇒ e^(−P/24), Jensen band, χ forcing, 24-bookkeeping, twelve ports via Gauss–Bonnet | L2.6 (T16) |
| `DeltaSBridge` | the finite source generator as a formal object; Theorem B.7 in Lean | P5 / L2.12 definition side (T17) |
| `Rule90Decoding` | general decodability framework; boost invariance; parity obstruction; **complete gap-2 parity classification** (`[formal-v5]`) | §7.6 stretch (T18 + T20) |
| `Rule90Stride` | `[formal-v6]` **the coprimality classification of two-column screens**: decodes ⟺ `gcd(g,n) = 1 ∧ n ≤ 2(t+1)` — the §7 stride conjecture proven sharp; the mirror lemma (a dark column forces mirror symmetry); the quotient-lift kernel construction | §7 item 6 conjecture (T25) |
| `HexacodePort` | [6,3,4]₄ closed (d = 4, self-dual); every 3-subset reconstructs; **full weight distribution** (`[formal-v5]`) | §9 (T19 + T22; ported, attributed) |
| `ModularCore` | `[formal-v5]` the finite type-I modular core: KMS existence + **uniqueness**, flow structure, triviality ⟺ traciality, faithful-state axioms discharged, qubit non-vacuity | L2.2 / D3 finite core (T21) |
| `LedgerNumerics` | `[formal-v5]` run-matrix conversion constants: C_geom to 7 digits, Δν_min, design force/gf/SNR, exact lock-in floor, battery-coupon ceiling (**with erratum**) | test ledgers (T24) |
| `ConsensusSafety` | `[formal-v5]` QBFT safety core (appendix B) + the `n = 3f+1` boundary finding | corpus extension (T23; attributed) |
| `Rule90Lipschitz` | `[formal-v9]` **the Lipschitz worldline theorem (T36): the slope conjecture, closed** — every 1-Lipschitz worldline screen is completely locally decodable at the sharp threshold (`pathScreen_closure_complete`), hence an information set iff `n ≤ 2(t+1)`; corollary `slopeTube_isInformationSet_iff` closes holes-audit F6 for every rational slope `0 ≤ p/q ≤ 1`, every `n, t`, base and slope; plus the machine-checked delimitation of the wild non-Lipschitz regime (`pairScreen_class_6_2` order-sensitive classification at `(6,2)`; slope-2 decodes at `(8,3)` but fails at capacity at `(10,4)`) | §7 item 6 conjecture — CLOSED (T36) |
| `Rule90Crawl` | `[formal-v9]` **the gap-2 crawl classified (T37)** — T30's named leftover closed: on odd rings at the sharp threshold the distance-2 screen's propagation closure is the ENTIRE block (`gapTwoTube_closure_complete_odd` — the simulation's crawl, made into a proof via T36's general fan with inferred anchors), on even rings it never reaches the seed row (`gapTwoTube_closure_incomplete_even`); packaged as `gapTwo_closure_complete_iff_odd` — with T30, local decodability of two-column screens is classified at every ring distance | T30 leftover — CLOSED (T37) |
| `Rule90Parity` | `[formal-v10]` **the parity splitting (T38 / R1)** — on even cylinders the spacetime block is two non-interacting parity sectors (`traj_parityProj`), an arbitrary cell set fails ⟺ a nonzero **single-parity** ghost is dark on it (`not_isInformationSet_iff_single_parity_shadow` — the containment half of the shadow-atlas conjecture C1, unconditional in `n, t, S`); the Rule-60 bridge `traj x i j = rule60^[2i] x (j−i)`; and the half-ring conjugacy (`sectorTrace_succ`): each sector *is* Rule 60 on `ZMod (n/2)` | oph_sim finding R1 — FORMALIZED (T38) |
| `Rule90TwoPower` | `[formal-v10]` **two-power universality (T39)** — on `n = 2^k` **every** worldline pair screen decodes iff `n ≤ 2(t+1)`, teleports included (`pairScreen_isInformationSet_iff_two_pow`, `pathScreen_isInformationSet_iff_two_pow`): the doubling lemma makes Rule 60 nilpotent, the last nonzero iterate is the all-ones row, and one adjacent pair per row kills it; T36's beyond-Lipschitz wildness vanishes on two-power rings | oph_sim conjecture C3 — CLOSED (T39) |
| `Rule90Diagonal` | `[formal-v10]` **the lone diagonal observer (T40/T41)** — a single lightlike diagonal (ONE cell per row) is an information set on odd cylinders iff `n ≤ t+1`, meeting the universal counting bound *exactly* (`diagScreen_isInformationSet_iff_odd`; the timelike single column never decodes — boosting the one-cell observer onto the light cone flips it to counting-optimal); on even cylinders it never decodes, and two diagonals decode iff their bases have opposite parity, at the sharp `n ≤ 2(t+1)`, **at any offset** (`diagScreen_pair_isInformationSet_iff_even`) | new (probe F4) — T40/T41 |
| `RouteA` | `[formal-v7]` **Route A assembled (T27)**: local tube-preserving decode transactions on the Rule-90 cylinder — liveness, `H_B`, observer uniqueness (equality form), completeness ⟺ fiber realizability, jointly with the sharp `H_fib` on ONE carrier; plus the machine-checked negatives (no `H1∧H2∧H3` repair on any cylinder; the canonical operator's stall witness at `n=3, t=2`, whose fiber is provably unrealizable) | holes-audit F2 (T27) |
| `ModularFlow` | `[formal-v7]` **the real-time modular flow (T28)**: `H = −log ρ` exists (spectral construction), `σ_z = e^{izH}(·)e^{−izH}` is a one-parameter group of ⋆-automorphisms (entire in `z`, norm-continuous, state-invariant), `σ_i = Δ_ρ`, the textbook KMS boundary condition `ω(A·σ_{t+i}(B)) = ω(σ_t(B)·A)`, and uniqueness: a Hamiltonian-implemented KMS flow has `e^{−K} = c·ρ`, `c > 0` real | holes-audit F9 (T28) |
| `ChannelBridge` | `[formal-v7]` **the channel bridge (T29)**: ONE structure whose single indexed family carries both the record panel (slots) and the collar panel (slices); `toRegister`/`toSlices` derive the T17 register and T16 slice model, the identification is `rfl`, and the composite Tier-B1 law `λ_collar·(𝓛𝒩)(q) = e^{−P/24}·S·A(q)` is a theorem about the structure — "the same counter" de-prosed; residues = the named channel identification + G9 | holes-audit F11 (T29) |

See `README.md` for anchors and the statement-by-statement audit in
`RESULTS.md`.
-/
