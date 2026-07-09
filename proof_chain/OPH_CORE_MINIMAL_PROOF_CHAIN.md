# The OPH core, minimally

**What is actually proven, what it plausibly connects to, what is conjecture —
and the exact assumption at every link.**

| | |
|---|---|
| Version | **v9** (2026-07-09, sixth pass) — **the slope conjecture is CLOSED** (holes-audit F6 — the last named open mathematics item of v8): **T36, the Lipschitz worldline theorem** (`Rule90Lipschitz.lean`) — every adjacent-pair screen along a 1-Lipschitz column path (any observer at or below the lattice light speed: all slopes, zigzags, negative slopes) is *completely locally decodable* at the sharp threshold (its propagation closure is the whole block — T30b extended from the static tube to every causal worldline) and is an information set **iff** `n ≤ 2(t+1)`, uniformly in the path; corollary `slopeTube_isInformationSet_iff`: sharp at every rational slope `0 ≤ p/q ≤ 1`, every `n, t`, every base point — the v8 sheared-CA attack dissolved into a direct two-chain fan induction. Beyond Lipschitz the landscape is machine-checked to be genuinely wild — complete order-sensitive classification at `(6,2)` (`pairScreen_class_6_2`: decodes ⟺ the LAST step is Lipschitz); ALL `8^4` paths decode at `(8,3)`; the superluminal slope-2 line and late jumps FAIL at exact capacity at `(10,4)` — which is the precise delimitation of the one remaining open mathematics item (arbitrary subsets). And **T37 — the gap-2 crawl classified** (`Rule90Crawl.lean`): T30's named leftover closed — at the sharp threshold the distance-2 screen's propagation closure is complete **iff the ring is odd** (`gapTwo_closure_complete_iff_odd`; the odd half is the simulation's crawl made into a proof through T36's general fan with inferred anchors, and T25's odd `g = 2` half re-derives through the closure — the crawl IS a decoder); with T30, local decodability of two-column screens is classified at every ring distance. §13 has the campaign log. **v8** (2026-07-07, fifth pass) — the v7 modules **independently re-verified** (read + fresh build + a two-namespace environment sweep, the discipline the second audit pass demanded), and the named mathematical leftovers closed: **T32** — arbitrary-schedule termination of T27's decode dynamics (`decodeStep_wellFounded`: the rank stratification itself is a lexicographic potential — every accepted transaction fixes its own stratum and can break only higher ones, so NO schedule, fair or adversarial, runs forever; with T27a, every schedule terminates *and* lands on the one record the tube pins: `routeA_universal_settlement`). **T33** — Skolem–Noether for the matrix algebra (`algEquiv_matrix_inner`: every `ℂ`-algebra automorphism is inner, classical intertwiner construction; `kms_algEquiv_structure`: any KMS-satisfying automorphism IS the modular map with conjugator `c·ρ` — T28's Hamiltonian-form hypothesis is provably generic). **T35** — the twelve-port surface (`TriangulatedSphere`: `sphere_defect_count`'s three assumed equations are now *theorems* of an actual closed triangulated surface — `3F = 2E` and the handshake by double counting, Euler staying the named topological input — with a kernel-checked icosahedron instance; closes the F24 residue). Plus two theorems the **simulation companion surfaced** (`oph_sim/FINDINGS.md`): **T31** — the readout trichotomy (above the sharp threshold EVERY tube reading is realizable (ghosts, no empty fibers), at it the readout is a bijection (zero redundancy), below it unrealizable readings exist ⟺ `n < 2(t+1)` — T27.4's stall regime is exactly the strict side of the jewel's threshold; `no_stall_at_threshold` at the bijective corner), and **T30** — the local-decodability phase boundary (screens with column ring-distance ≥ 3 admit ZERO local constraint-propagation inferences at any horizon, while the adjacent tube's propagation closure is the whole block — determination and local derivability provably split; the sim's flagship `n=8, g=3, t=3` "violet" configuration is machine-checked: full rank, zero locally derivable cells). **T34-lite** — sloped screens pinned down (`slopeTube` formal definition matching the committed sweep artifacts; failure half proven at every slope; kernel-checked threshold instances at slopes 1/2, 1/3, 2/3). §12 has the campaign log. **v7** (2026-07-07, fourth pass) — the audit's remaining *mathematics* is closed by theorem. **T27, Route A assembled** (`RouteA.lean`, holes-audit F2): on the Rule-90 cylinder — T9′'s own carrier — a genuinely **local, tube-preserving transactional decode-repair** exists (single-cell writes, edge-bounded windows, formula-mismatch trigger, a declared responsibility roster billed like Route B's order): it settles every record (liveness by the declared rank schedule), preserves the width-2 tube (`H_B`), and any two records with equal tube reading settle to the **same** record under **any** schedules — with consistency of the settled world ⟺ realizability of the tube fiber, and jointly with the sharp `H_fib`; plus both negatives machine-checked (no `H1∧H2∧H3` repair on any cylinder, ∀n ≥ 1, t ≥ 1; the canonical T12 operator's one-step stall at `(0,δ₀,δ₁)` on `n=3,t=2`, whose fiber provably contains **no** consistent record). **T28, the real-time modular flow** (`ModularFlow.lean`, holes-audit F9): `H = −log ρ` exists (spectral construction), `σ_z = e^{izH}(·)e^{−izH}` is a one-parameter group of ⋆-automorphisms (entire in `z`, norm-continuous, state-invariant), its analytic value at `z = i` **is** T21's modular map, the **textbook KMS boundary condition** `ω(A·σ_{t+i}(B)) = ω(σ_t(B)·A)` holds, and uniqueness: any Hamiltonian-implemented KMS flow has `e^{−K} = c·ρ` with real `c > 0` — the clock is now a clock, finite-dimensionally. **T29, the channel bridge** (`ChannelBridge.lean`, holes-audit F11): ONE structure whose single indexed family carries the record panel and the collar panel; the T17 register and T16 slice model are derived from it, the slot=slice identification is `rfl`, and the composite Tier-B1 law `λ_collar·(𝓛𝒩)(q) = e^{−P/24}·S·A(q)` is a theorem about the structure — "the same counter" de-prosed, residues exactly the named channel identification + G9. Plus: the ℤ₆ kernel packaged as a **group isomorphism** (`kernelAddEquiv : ZMod 6 ≃+ ker`, F10c), and the two theorem-grade energy anchors machine-checked next to the G10-convention (`bench_cycle_work_value`, `mass_energy_value`, `anchor_ordering`: the convention prices strictly inside the corridor `0.55 J < 3.5 MJ < 5.0×10¹⁵ J`, F15). **v6/v6.1** (same day, earlier passes): T25 stride classification; T26 λ-constancy; the audit adopted, G10-convention named, F18 errata applied; disposition table in §11 (updated for v7). v1–v6.1 in git |
| Sources audited | `observer-patch-holography/` (LEAN + papers + `code/P_derivation/`, executed; v5 added the previously-unaudited directories: `claims/`, `physics-problems/`, `cosmology/`, `book/`, `tracking/`, `contributions/`, `tools/`, `extra/` full sweep — see §10; v6 delta-check 2026-07-07: new commits are book edits + an audit-results import, **nothing bearing on any open item**), the `../test/` ledgers, `hoverboard/`, `../communication/`, `dula/` (all four repos, re-checked 2026-07-07: unchanged) |
| New in v7 | **`formal/`** grows to **29 modules; the full environment sweep now covers 1480 theorem/def declarations in the OPH namespaces — 0 sorry, 0 custom axioms, no `native_decide`** (fresh `lake build`, 8278 jobs, clean). The open-mathematics list of §7 shrinks to: intermediate-slope screens (F6 — still conjectural beyond the two extreme slopes; empirics unchanged), the arbitrary-subset weight-distribution classification, and two new honest leftovers created by the v7 theorems themselves (arbitrary-schedule termination of the T27 decode dynamics — uniqueness already covers every schedule that terminates; and Skolem–Noether to extend T28's uniqueness beyond Hamiltonian-implemented flows). Everything else open is physics |
| New in v8 | **`formal/`** grows to **33 modules**; the environment sweep now reports **1199 non-internal theorem/def declarations in BOTH namespaces (`OPH.*` + `OPHProofChain.*`) — 0 sorry, 0 custom axioms, no `native_decide`** (fresh `lake build`, 8282 jobs, clean; the count filter is now stated in `formal/RESULTS.md` §33 so sweep-count bookkeeping is reproducible — earlier versions' counts used a wider filter and are not comparable). The §7 open-mathematics list shrinks to TWO items: **intermediate-slope screens** (the positive half for general `n`; the definition, the failure half, and sample threshold positives are now in-tree — `Rule90Slope.lean`) and the **arbitrary-subset weight-distribution classification** (plus the T30-created leftover: gap-2 propagation-completeness classification). Async-schedule termination and Skolem–Noether are **closed by theorem**. Everything else open is physics — and that sentence has now survived its own adversarial audit twice |
| New in v9 | **`formal/`** grows to **35 modules**; the environment sweep now reports **1235 non-internal theorem/def declarations in BOTH namespaces — 0 sorry, 0 custom axioms, no `native_decide`** (fresh `lake build`, 8284 jobs, clean; `formal/RESULTS.md` §36). The §7 open-mathematics list shrinks to **ONE** item: the **arbitrary-subset weight-distribution classification**, full stop (the T30-created gap-2 crawl characterization is **closed by theorem** — T37, complete iff the ring is odd) — now with machine-checked walls: no coarse invariant (step multiset, last step, cardinality) can classify it (`pairScreen_class_6_2` order sensitivity; `(8,3)` all-decode vs `(10,4)` capacity-failures). The intermediate-slope conjecture is **closed by theorem** (T36) — and strictly stronger than conjectured: the threshold is **Lipschitz-class-invariant**, not merely slope-invariant. Everything else open is physics — the banner survives its third cycle |
| Path convention | sibling-repo paths are relative to the directory that contains `observer-patch-holography/`, `chi_nu_test/`, and `dula/`; bare `DOCUMENT_…` names live in `../test/`; the audit files sit next to this one |
| Method | every claim carries a file:line anchor; "proven" means *machine-checked in Lean, sorry-free, standard axioms only*; "paper-side theorem" means *a written proof verified by inspection, not yet formalized* |

---

## 0. The core idea in one paragraph

Take seriously that physics is only ever done by **finitely many observers with
partial views**. Model an observer as a *patch*: a finite system with a local
state, a **record**, and **interfaces** where its view overlaps its neighbours'.
Postulate exactly two things: overlapping views must **agree on shared
observables**, and dynamics is **local repair** that reduces disagreement. Then
ask what follows. The honest answers, in increasing order of speculation:
(1) consensus dynamics has terminal states, exactly the consistent ones —
*machine-checked*; (2) a unique "objective reality" is **not** automatic —
asynchronous repair can settle into different worlds — *machine-checked
counterexample*; (3) objectivity can be *earned* two ways — a declared
canonical repair order, or boundary data that determines the bulk up to gauge —
**since v3 both routes are machine-checked at full strength**: the quotient
repair operator with schedule independence (Route B), and a **sharp
holographic-screen theorem** (Route A/H_fib) — a width-2 timelike screen on the
Rule-90 n-cylinder reconstructs the bulk *iff* its cell count meets the code
dimension; (4) continuing outward: gravity as thermodynamics of interface
information (Jacobson-shaped), a dark sector as imperfect-repair remainder, and
the χ_ν "coherent-matter lift" — a tower of explicitly conditional
continuations, none proven, the last one bounded by conservation laws (now in
theorem form) before any experiment runs.

The interesting physics is (1)–(3), and as of v3 it is essentially all
machine-checked. **As of v4 the checking is total on the mathematics side**:
the OPH Lean core itself now lives in `formal/` with its three `sorry`s
discharged (the canonical frustration-free repair — Route B realized on the
original carrier), and every link of the conditional tower that *has* a
mathematical sub-claim now has that sub-claim in Lean — including the
Einstein-branch algebra, the SM hypercharge/ℤ₆ package, the dark-sector
activation mathematics, the collar-gate skeleton, and the ΔS-bridge
definition side. The corpus's older habit of projecting the repair/consensus
template onto everything remains disciplined by tier labels, named
hypotheses, and receipts; the hard open problems are now exactly two physics
gaps (G9, G10-ledger) plus the physical hypotheses (SEE, MAR, the L0–L7
collar clauses, P's source branch).

---

## 1. Layer 0 — proven (Lean 4, sorry-free, standard axioms only)

**As of v4, one directory tree carries the whole layer** (v7: 29 modules,
198 axiom-audited declarations, 0 `sorry`): **`formal/`** in this
directory (`OPHProofChain`). It contains an attributed copy of the OPH core
(`OPHProofChain/Core/`, from `observer-patch-holography/LEAN/`, same pinned
toolchain + Mathlib) **with the three documented `sorry`s discharged** —
`localRepair` is now the canonical frustration-free snap operator, `Repair`
its declared-order iterate, and `repair_respects_gauge` a theorem (see T12).
The OPH team's own repo is unchanged (still carries its three `sorry`s;
upstreaming from `formal/Core/` is a file move — their call).

**The carrier** (`Primitives.lean:69–159`): finite patch graph, per-edge
interface projections, weighted mismatch functional

```
Φ(x) = Σ_e  w_e · d_e( π_{src(e)}(x), π_{tgt(e)}(x) )      (Primitives.lean:144)
```

**T0 — Consistency ⇔ edge agreement** (`consistent_iff_edgeConsistent`, `:165`).

**T1 — Termination** of any frustration-free local repair (H1–H3)
(`termination`, `:476`). **T2 — Completeness**: terminal states = consistent
states (`completeness`, `:516`).

**T3 — Non-uniqueness (the load-bearing negative result)**: asynchronous local
repair is **not confluent** (`demoCarrier_not_confluent`, `:739`). "One
objective public reality" is not free.

**T4 — The two levers that restore objectivity**: commuting repairs → Newman →
confluence (`confluence_of_commute`, `:621`); or boundary determination —
preserved boundary (HB) + gauge-singleton consistent fibers (Hfib)
(`boundary_fiber_observer_unique`, `:559`).

**T5 — Rule 90 (width-3 toy)** (`Rule90.lean`): proper-subset information-set
boundary, deficient-subset failure, nontrivial gauge, no frustration-free
repair.

**New in v3 — the `formal/` extension of Layer 0** (anchors are Lean names;
map in `formal/RESULTS.md`):

**T6 — The quotient repair operator package (P1 ported; Route B closed).**
`QuotientRepairPresentation` = the paper's `(Σ,Γ,q,Q,C_Q,B,μ,𝖠,≺_𝖠)` with
`H_B, H_↓, H_◇, H_comp`; `globalRepair` is total, valued in `C_Q`,
boundary-preserving, idempotent, fixed exactly on `C_Q`, and
**schedule-independent** (`schedule_independence`, via a self-contained
Newman); `World`, `world_is_fixedPt`, and `repair_respects_gauge` (three
forms) discharge the *Paradise* Def 4.1 / Prop 4.2 reading. The content of
the Lean core's three `sorry`s is herewith proven in the quotient setting the
paper works in (upstreaming is mechanical); `PROOF_INDEX.md`'s "0 % of
Prop 4.2" is obsolete modulo that file move. Non-vacuity: a real instance
computes; and `symmetricPair_not_locallyConfluent` shows `H_◇` is *not*
implied by the other hypotheses — T3 in presentation form, so the declared
order is provably load-bearing.

**T7 — Bare consensus is not Einstein-complete (P2 ported).**
`bare_consensus_not_einstein_complete`: two geometric extensions of the *same*
non-degenerate consensus reduct with opposite Einstein truth values ⇒ no
predicate of the reduct decides the Einstein equation. The Layer-0/Layer-2
fence is now first-party *and* machine-checked.

**T8 — The layered functional boundary carrier (P3 ported).** `extend`,
staged sweep, `H_B` (`sweep_restrictB`), reconstruction from any start
(`sweep_eq_extend`), singleton consistent fiber (`hfib_singleton`), and the
presentation-free reconstruction corollary. Honest strength unchanged
(feed-forward class — review R1); the erasure-correction strength is T9.

**T9 — THE JEWEL, proven sharp (was §7.2 / R1 "the open problem").** On the
Rule-90 `n`-cylinder run for `t` steps (`Rule90Cylinder.lean`):

```
tube_information_set_iff :  the width-2 timelike tube {j₀, j₀+1} × [0,t]
                            determines the whole spacetime block
                            ⟺  n ≤ 2(t+1)
```

— the sideways-lightcone bound and the raw counting bound **coincide exactly**
(both parities), so the timelike screen *saturates the information bound*: a
perfect holographic screen, reading 2 of n cells per row, reconstructing the
bulk through the CA constraint redundancy. Sharpness on all sides:
width-1 columns fail **at every horizon** (mirror-kernel seeds, `n ≥ 3`;
nilpotency, `n = 2`), and **no proper spacelike subset** of the initial row
ever works — reconstruction-from-a-part is a strictly *timelike* phenomenon on
the cylinder (the width-3 toy's spacelike proper subset worked only because
its fixed boundary cut the code dimension). `CarrierBridge.lean` packages this
as an `H_fib` discharge in the Lean core's exact
`boundary_fiber_observer_unique` binder form, on a genuinely multi-edge
`(t+1)`-patch carrier (`rule90Cylinder_Hfib_tube`, `…_sharp`,
`…_column_fails`, `tubeBoundary_strictly_coarser`).

**T10 — The conservation cage in theorem form** (see §5) and **T11 — the
P/χ numerics** (see §4, L2.5/L2.10) round out the v3 layer.

**New in v4** (anchors are Lean names; statement-by-statement audit in
`formal/RESULTS.md` §§8–16):

**T12 — The core's three `sorry`s, discharged** (`Core/Primitives.lean`).
`localRepair` := the canonical frustration-free snap (fires iff a broken
incident edge exists *and* the patch can satisfy all its interfaces at once;
`Classical.choose` state); `Repair` := the least-firing-site iterate in a
declared patch order (Route B on the original carrier, totality by
well-founded descent on the broken-edge count); `repair_respects_gauge`
**proved** — the fire condition, the chosen state, the firing order, and the
descent measure all factor through `obsMap`. Payoff: the file's own
`Termination` and `LyapunovDescent` are theorems **for every carrier**;
`Completeness` holds under the named `EdgeRepairable C` (strictly weaker
than frustration-free — and honest: `Core/Rule90.lean` proves no operator
can satisfy H1∧H2∧H3 on the Rule-90 carrier); the file's own `Confluence`
is **refuted** on `demoCarrier`, where the canonical operator provably *is*
the neighbour-copy repair (`localRepair_demoCarrier` — the anti-degeneracy
witness the source `sorry` documentation demanded).

**T13 — The L2.4 algebra, both halves** (`Hypercharge.lean`,
`CenterZ6.lean`). Yukawa closure + the two linear anomalies force the
hypercharge ratios for any `N` (the `[SU(N)]²` anomaly is implied, the cubic
cancels *identically*); `Q(ν_L)=0` pins `Y_Q = 1/(2N)`; `N=3` gives the SM
lattice uniquely. Downstream, in `ℤ₃×ℤ₂×ℝ/ℤ`: the subgroup acting trivially
on all six multiplets is **exactly** `⟨(ω₃, −1, e^{iπ/3})⟩ ≅ ℤ₆`
(`actsTrivially_iff`, `kernel_bijection`, `addOrderOf_g0 = 6`). MAR — the
*selection* of the package — remains the named hypothesis.

**T14 — The Einstein-branch algebra** (`EinsteinBranch.lean`). The
rest-frame arithmetic of the paper's `thm:einstein` (three named variational
hypotheses in, `Z = 8πG·X` out); the polynomial upgrade (symmetric form
vanishing on all future unit timelike directions ⇒ 0 — finite witnesses, no
analysis) packaging to the full tensor equation; and the classic null-cone
step (`F(k,k) = κT(k,k)` on the cone ⇒ `F = κT + λη` — the cosmological
constant is exactly the residual freedom).

**T15 — The dark-sector mathematics** (`DarkSector.lean`). Activation-law
well-definedness/monotonicity, the Newtonian and deep-MOND limits (exact
`√(a_eff g_b)` scaling), BTFR, the rare-event `(1−μ/m)^m → e^{−μ}`; the
phantom-density identity as zero-content bookkeeping over any linear
divergence (L2.7 as graded); the exact point-source profile
(`M_A′ = 4πr²ρ_A`, positive, monotone); and the thin-device FTC step
deriving the planar force law from the lab response input (L2.11's
derivation half).

**T16 — The collar-gate skeleton** (`CollarGate.lean`). Slice-wise
unbiasedness ⇒ `λ_collar = e^(−P/24)` exactly; the Jensen band
`e^(−P/24) ≤ λ_collar ≤ 1` under the mean condition; `χ_can = λ_collar`
forcing; the `(P/4)/6 = P/24` and `24 = 2×12` bookkeeping; and combinatorial
Gauss–Bonnet — any all-triangle Euler-characteristic-2 surface has total
defect 12, so unit defects ⇒ **exactly twelve ports**.

**T17 — The ΔS-bridge definition side** (`DeltaSBridge.lean`). The finite
coherent-source generator now *exists as a formal object* (register,
footprint, `q⊕e` activation, availability), and Theorem B.7 is a Lean
theorem: `(𝓛 𝒩)(q) = S·avail(q) > 0` — coherent matter perturbs the *same*
counter the collar prices. G9 (the numeric map) stays open.

**T18 — Decodability beyond the screen families** (`Rule90Decoding.lean`,
the §7.6 stretch item). A general `IsInformationSet` framework (vanishing
form, decidability, the universal `n ≤ |S|` counting bound, monotonicity);
T9 restated inside it; and two new theorems: **boost invariance** — the
*lightlike* width-2 screen is an information set iff `n ≤ 2(t+1)`, the same
sharp threshold, so tilting the screen to the lightcone leaves its capacity
at the information bound (the sweep becomes one-sided but double-speed) —
and **the parity obstruction** — the gap-2 screen on *even* cylinders fails
at every horizon (explicit alternating-seed kernel): adjacency (seeing both
checkerboard classes) is what T9's screen actually uses, not the tilt.

**T19 — The hexacode toy** (`HexacodePort.lean`, ported from `dula/`,
attributed — the §9 suggestion executed). Minimum distance 4 in Lean
(⇒ `[6,3,4]₄`, MDS; the source had a Python check), Hermitian self-duality,
and **every 3-subset of coordinates is an information set** (from `d = 4` by
support counting) — the geometry-blind extreme next to Rule-90's
geometry-sensitive screens.

**New in v5** (audit in `formal/RESULTS.md` §§12–13, 17–19):

**T20 — The complete parity classification of the gapped screen**
(`Rule90Decoding.lean`, `[formal-v5]` section — closes the odd-`n` question
T18 stated as open). For every cylinder:

```
gapTwoTube_isInformationSet_iff_parity :
    the gap-2 width-2 screen {j₀, j₀+2} × [0,t] is an information set
    ⟺  n is odd  ∧  n ≤ 2(t+1)
```

On odd cylinders the gapped screen recovers the **full adjacent capacity at
the same sharp threshold** — and by a genuinely different decoding: the two
read columns *enclose* the middle column and determine it one step later,
two fans sweep row 1 to zero around the cylinder, and the descent to the
seed is *algebraic* — a row killed by one step is constant along the
distance-2 walk, which is transitive exactly when the cycle is odd (the
even case's checkerboard obstruction is the *same walk* with two orbits).
With T18's boost invariance, the width-2 story closes: **tilt is
irrelevant; separation matters exactly through cycle parity.**

**T21 — The D3 finite (type-I) modular core** (`ModularCore.lean`, native —
retires v4's "the one Layer-2 link with no isolable finite-mathematics
core"). For a faithful state `ω = tr(ρ·)` (`ρ` positive definite) on a
finite matrix algebra — exactly the paper's own "finite type-I regulator
class" where D3's scaling-limit theorem starts:

```
kms        :  ω(A·Δ_ρ(B)) = ω(B·A)          (existence — the KMS identity)
kms_unique :  any D with ω(A·D(B)) = ω(B·A) for all A,B equals Δ_ρ
              (uniqueness — no linearity assumed: the state pins its dynamics;
               real-time flow + KMS boundary condition since v7: T28)
```

plus the full automorphism/flow structure (`modular_iterate`: the `k`-fold
iterate is conjugation by `ρᵏ`), state invariance, **triviality ⟺
traciality** (`modular_eq_id_iff_tracial` — every non-tracial state ticks;
both directions are one-liners from existence + uniqueness), the
faithful-state axioms discharged (unit, reality, positivity, faithfulness),
and a ticking-qubit witness (`Δ_ρ(E₀₁) = ½E₀₁` for `ρ ∝ diag(1,2)`). This
is the finite core of "thermal time". **What stays physics is exactly
Bisognano–Wichmann** — the identification of the state-generated flow with
geometric boosts in the scaling limit — plus the limit itself; D3 is now
graded like every other Layer-2 link.

**T22 — The hexacode weight distribution** (`HexacodePort.lean`,
`[formal-v5]` section). `A₀ = 1, A₄ = 45, A₆ = 18` — the enumerator
`x⁶ + 45x²y⁴ + 18y⁶` — kernel-checked; with it, **every** hexacode claim of
the `dula/` source file is closed in Lean (its `K₁₂` goal is out of scope).

**T23 — The QBFT safety core, with a boundary finding**
(`ConsensusSafety.lean`, formalizing the corpus appendix
`paper/appendix_B_bft_qecc_extensions.tex:66–97`, attributed — an
*extension*, not a chain link; formalized so the corpus's written finite
mathematics stays fully covered). The safety counting argument is a
theorem (`qbft_safety`); liveness/optimality stay external citations, as in
the appendix itself. **New finding:** the appendix's claim that the overlap
bound A6 is "guaranteed by (A3)" (`n ≥ 3f+1`) is **false for `n > 3f+1`**
at fixed quorum size `2f+1` (`quorum_overlap_gap`: at `n = 3f+2` two
quorums can overlap in a single, possibly Byzantine, node); the theorem
stands at `n = 3f+1` exactly, and `quorum_intersection_general` gives the
correct general-`n` sizing.

**T24 — Run-matrix conversion constants, theorem-form**
(`LedgerNumerics.lean`, native; extends the §5 cage arithmetic to
DOCUMENT C). `C_geom = g²/(4πG)` pinned to seven digits (the printed
`1.146637×10¹¹` is exact), the one-zone conversion `5.50×10⁸ N`, the
headline null-bound `Δν_min ∈ (9.084, 9.085)×10⁻¹⁷` (the printed `9.1`
rounds up — the *safe* direction), the design point (`0.550 N`, `56.12 gf`,
SNR `1.10×10⁷`), the lock-in floor **exactly** `10⁻⁶/30` (because
`√(2/1800) = 1/30` — no numerics at all), and the battery-coupon ceiling
`∈ (1.02, 1.03)×10⁻¹¹` — **an erratum**: DOCUMENT A §1.9 printed
"`≲ 1×10⁻¹¹ (≈ 0.5 gf)`", understating the ceiling ≈ 2.5 % in the unsafe
direction for a discrimination bound; the ledger now prints
`≲ 1.1×10⁻¹¹ (≈ 0.58 gf)` with an erratum note.

**New in v6** (audit in `formal/RESULTS.md` §20 and §1):

**T25 — The coprimality classification of two-column screens**
(`Rule90Stride.lean`, native — settles the §7 item-6 stride conjecture,
in sharper form than conjectured). For every cylinder size, stride, base
column and horizon:

```
gapTube_isInformationSet_iff :
    the two-column screen {j₀, j₀+g} × [0,t] is an information set
    ⟺  gcd(g, n) = 1  ∧  n ≤ 2(t+1)
```

The conjecture asked only about *eventual* capacity; the theorem says
coprime strides lose **nothing** — full adjacent capacity at the sharp T9
threshold — while non-coprime strides fail at **every** horizon. T9's
sufficiency (`g = 1`), T20's parity classification (`g = 2`:
`gcd(2,n) = 1 ⟺ n` odd) and the width-1 negatives (`g ≡ 0`: `gcd = n`)
are corollaries, re-derived in-file as consistency checks. Two new
mechanisms carry the proof. **The mirror lemma** (`mirror_of_column_dark`):
a *single* dark column of depth `t` forces mirror symmetry about itself
whenever `n ≤ 2(t+1)` — the mirror defect is itself a Rule-90 trajectory
in displacement space, dark on an *adjacent pair*, so it dies by a
one-sided sweep; the width-1 screen thus pins **the whole antisymmetric
sector** plus its own centre cell, and its failure kernel is exactly the
symmetric seeds with dark centre — v3's mirror-kernel seeds: the failure
theorem and the mirror lemma are two halves of one fact. Success
then composes: symmetric about both columns ⇒ `2g`-periodic ⇒ coprimality
+ the two time-0 readings kill everything. **The quotient lift**
(`traj_comap`): reduction mod `d = gcd ≥ 2` is a graph covering under
which *both* read columns land on a single quotient column, and the
mirror-pair seed `δ_{+1} + δ_{−1}` of the `d`-cylinder — dark on that
column forever, by symmetry — lifts to a kernel seed at every horizon
(v4's alternating checkerboard seed is the `d = 2` case). Boundary
instances are kernel-`decide`d at the exact thresholds
(`(8,3,3)` ✓, `(8,3,2)` ✗ counting, `(9,3,4)` ✗ gcd). *Slogan: tilt is
irrelevant (T18), and separation matters exactly through coprimality
(T25) — parity (T20) was the shadow of the gcd.*

**T12 addendum — the hypothesis lattice, closed** (`RepairHypotheses.lean`,
native): `EdgeRepairable` — T12's completeness hypothesis — is now
**provably strictly weaker** than `FrustrationFree`
(`edgeRepairable_strictly_weaker`): the width-3 Rule-90 carrier is
Edge-Repairable (the next-row patch always fixes by copying the CA image)
but not frustration-free (the seed patch cannot hit targets outside the CA
image) — the same carrier on which no frustration-free operator exists at
all, so canonical completeness provably covers carriers beyond the
frustration-free class. Three documents asserted this strictness in prose;
it is now a theorem.

**T26 — the cosmological-constant step** (`LambdaConstancy.lean`, native,
`[formal-v6.1]` — closes holes-audit **F8**). `jacobson_step` (T14c) is
pointwise: over a region it yields a scalar *field* λ(x), and calling that
field "the cosmological constant" was one (written, previously
unformalized) step early. Now machine-checked
(`einstein_equation_with_constant`): on a connected discrete chart,
null-cone matching at every point **plus the two named divergence
inputs** — the contracted Bianchi identity for the geometric side and
local stress conservation for matter — force `F = κT + Λη` with **one**
constant `Λ`; a disconnected counterexample shows the connectivity clause
is load-bearing. The chain's Einstein branch now *ends at the Einstein
equation*, with its remaining inputs named — exactly like T14's
variational identities.

**T6 addendum — the separation statement, completed in all clauses**
(`QuotientRepair.lean`): the symmetric two-transaction witness now has
`symmetricPair_descends` (`H_↓` — strict broken-count descent) and
`symmetricPair_normalForm_iff` (`H_comp` — normal forms are exactly the
consistent states; axiom-free), alongside the existing
`symmetricPair_not_locallyConfluent`. So "the other hypotheses do not
imply `H_◇`" is machine-checked with the witness satisfying those
hypotheses *honestly* (`H_B` vacuous on the boundary-free two-cell
carrier), not vacuously.

**T27 — ROUTE A ASSEMBLED** (`RouteA.lean`, native, `[formal-v7]` — closes
holes-audit **F2**, the audit's #2 finding and the Lean core's own "open
modeling task"). On the Rule-90 `n`-cylinder with horizon `t` — the very
carrier of the T9′ jewel — at the sharp threshold `n ≤ 2(t+1)`:

* **the dynamics exists and is genuinely local**: decode transactions that
  write ONE cell each, reading only that patch and one edge-adjacent patch,
  triggered by formula mismatch (the "relaxed `H2`" escape hatch the
  impossibility theorems name). The responsibility roster — which formula
  owns which cell (right-sweep/left-sweep budgets `R = min t (n−2)`,
  `L = (n−2)−R`, downward territory below the light cones) — is **declared
  structure, billed** exactly like Route B's order; such a roster with both
  budgets `≤ t` exists **iff** `n ≤ 2(t+1)`, the same sharp threshold as
  the jewel — the roster IS the decoding strategy the information-set
  theorem certifies;
* **liveness** (`pass_spec`): the declared rank schedule reaches a normal
  form from every record in one finite pass; normal forms ⟺ decode
  quiescence;
* **`H_B`** (`decodeStep_tube`): every accepted transaction preserves the
  width-2 tube reading;
* **observer uniqueness** (`routeA_observer_uniqueness`): any two records
  with equal tube reading settle to the **same** record — literal equality,
  under ANY schedules, with NO realizability hypothesis;
* **completeness ⟺ realizability** (`routeA_world_consistent_iff`): the
  settled world is consistent **iff** some consistent record carries the
  starting tube reading; on unrealizable fibers *no* record is consistent
  (`no_consistent_completion_of_unrealizable`) — any tube-preserving repair
  must stall there, by logic, not weakness;
* **jointly with the sharp `H_fib`** (T9′, same carrier, quoted in the
  bundle `routeA_assembled`): the consistent fiber is a singleton.

And the two negatives the audit checked by hand are now theorems:
`rule90CylinderOPH_no_frustrationFree_repair` (**no** `H1∧H2∧H3` operator
exists on the cylinder, for every `n ≥ 1, t ≥ 1` — `δ₀` has odd weight,
Rule-90 images have even weight), and `canonical_repair_stalls` (the
canonical T12 operator, started at the audit's `(0, δ₀, δ₁)` on
`n = 3, t = 2`, fires exactly once and terminates at `(0, δ₀, evolve δ₀)`
with edge 0 broken forever) — together with
`stallRecord_tube_unrealizable`: that record's tube fiber contains **no**
consistent record, so the stall is the forced case, an instance of the
positive theory's own dichotomy. *Route A's story — "run the consensus,
the window pins the world" — now runs, in one room, machine-checked.*

**T28 — the real-time modular flow** (`ModularFlow.lean`, native,
`[formal-v7]` — closes holes-audit **F9** at the finite-dimensional
level). T21 pinned the *imaginary-time* modular step; the audit rightly
said calling it a "clock" imports unformalized real-time content. Now:
`exists_modularHamiltonian` (every PosDef `ρ` has Hermitian `H` with
`e^{−H} = ρ` — the spectral construction of `−log ρ`);
`flow H z A = e^{izH}·A·e^{−izH}` is a one-parameter **group**
(`flow_add`, over all complex `z` — the entire analytic extension) of
**⋆-automorphisms** (`flow_mul`, `flow_star_real`, unitary propagators at
real times), norm-continuous in the parameter (`flowU_continuous`),
state-invariant (`state_flow`); its analytic value at `z = i` **is** T21's
modular map (`flow_I_eq_modular`); the **textbook KMS boundary condition**
holds with real time inside (`kms_boundary`:
`ω(A·σ_{t+i}(B)) = ω(σ_t(B)·A)`, one line from the group law + T21's
`kms`); and **uniqueness** (`hamiltonian_kms_unique`): any
Hamiltonian-implemented flow satisfying the KMS identity has its Gibbs
weight pinned, `e^{−K} = c·ρ` with real `c > 0` — `K = −log ρ` up to the
additive constant conjugation cannot see — and its imaginary-time step IS
the modular map. Named leftover: Skolem–Noether (every automorphism of a
matrix algebra is inner), which would extend uniqueness to arbitrary
automorphism groups; still physics: the Bisognano–Wichmann identification
and the scaling limit (item 5 of §7).

**T29 — the channel bridge** (`ChannelBridge.lean`, native, `[formal-v7]`
— closes holes-audit **F11**). "Coherent matter perturbs the same counter
the collar prices" was prose about two disjoint modules. Now `Channel` is
one structure whose SINGLE finite indexed family carries both panels;
`toRegister`/`toSlices` derive T17's register and T16's slice model from
it; the identification is definitional (`same_family : … := rfl`); and the
composite Tier-B1 law is a theorem about the structure
(`channel_composite`):
`λ_collar · (𝓛^coh 𝒩)(q) = e^{−P/24} · S · A(q)` under the gate clauses —
with a non-vacuity instance where everything fires jointly. The physical
residue is now exactly two named items: the **channel identification**
(nature instantiates `Channel`) and **G9** (the numerical `S`).

**T13 addendum — the kernel as a group** (`CenterZ6.lean`,
`[formal-v7]`, holes-audit F10c): the trivially-acting central elements
form an additive subgroup (`kernelSubgroup`, via the new additivity lemmas
`phase_add`/`phase_zero`/`phase_neg`), and
`kernelAddEquiv : ZMod 6 ≃+ kernelSubgroup` — the set bijection and the
order-6 computation upgraded to the group isomorphism the chain documents
quote. (Which quotient `Γ` nature realizes stays the named empirical
hypothesis — unchanged.)

**T10/T24 addendum — the anchors beside the convention** (`EnergyCage.lean`,
`[formal-v7]`, holes-audit F15): `cycleWork_self` (fixed-position toggling
closes a zero-work cycle — the theorems force NO entry for the balance
protocol), `bench_cycle_work_value` (`ΔM·g·Δh ∈ (0.549, 0.550) J` per metre
of stroke), `mass_energy_value` (`ΔM·c² ∈ (5.03, 5.04)×10¹⁵ J`), and
`anchor_ordering` — the G10-convention figure sits **strictly between**
the theorem-forced floor and the relativistic ceiling. The audit's
"seven orders above, nine below" sentence is now interval arithmetic.

Layer 0 still contains no spacetime, no gravity, no χ_ν, no derivation of P —
by design (T7 is the fence; T14 consumes its variational hypotheses as named
physics and NotEinsteinComplete keeps bare consensus from deciding them).

---

## 2. Layer 0.5 — paper-side theorem surface (July 2026; now mostly ported)

The July-2026 tier (`AUDIT_RESPONSE_REVIEW.md` for the full verification).
v3 status per item:

**P1 — quotient repair operator package** (`reality_as_consensus_protocol.tex:433–610, 1143–1170`)
→ **ported, sorry-free** (T6). Reading unchanged: the non-confluence lesson is
answered by declared structure — now with the machine checking that each
declared piece is necessary.

**P2 — "Bare finite consensus is not Einstein-complete"** (`:244–271`)
→ **ported, sorry-free** (T7).

**P3 — layered functional boundary carrier** (`:1225–1364`)
→ **ported, sorry-free** (T8), same honest strength (feed-forward class);
the QECC-strength question it left open is **closed by T9** — and sharply.

**P4 — the scalar-channel stack under SEE**
(`screen_microphysics_and_observer_synchronization.tex:817–864, 1300–1411, 1475–1492`):
the *linear-algebra core* of same-channel forcing + unique linear response is
ported (`ScalarResponse.lean`: one-generator register ⇒ response `= χ·⟨η,S⟩`,
no second susceptibility). **SEE itself remains the named physical
hypothesis** — deliberately not "discharged". **v4:** the exact-coefficient
gate's *consequence structure* is now also machine-checked
(`CollarGate.lean`, T16: unbiasedness ⇒ `e^(−P/24)` exactly, the Jensen
band, the forcing, the 24-bookkeeping); the gate *clauses* and the receipt
discipline remain paper-side physics. The χ_can *number* has been
machine-checked since v3 (L2.10).

**P5 — finite coherent-matter source generator**
(`extra/chi_nu_susceptibility_bounds.tex:625–746`) → **v4: the definition
side is now machine-checked** (T17, `DeltaSBridge.lean` — the generator
exists as a formal object and Theorem B.7 is a Lean theorem). The numerical
bridge (G9) remains open, and is now *sharply* posed: what physics must
supply is the calibration of that formally-defined record-side increment
against gravity-side ΔS.

**P6 — honest misfit and selection surfaces** (dark paper) — unchanged.

*The bottleneck after v4:* formalization is **exhausted as a bottleneck** —
every written mathematical sub-claim in the corpus that the audits identified
now has a sorry-free Lean counterpart in this tree. What remains is physics,
exactly: G9 (numeric bridge), the G10 *ledger* (the cage is a theorem; the
ledger is an experiment), and the named hypotheses (SEE = Scalar Edge-Center
Exhaustion, MAR, the L0–L7 collar clauses — L0 the named shape postulate — P's source branch).

*v5 stress-tested that sentence twice.* First, a full sweep of the
previously-unaudited corpus directories (§10) looking for hidden derivations
of the open physics: none exist — the physics gaps are as open as the
grading says. Second, the two places where v4's "exactly physics" was
slightly *too generous to physics* are now reclaimed for mathematics: D3's
"no isolable finite core" is retired (T21 — the finite type-I modular core
is mathematics, and it is now machine-checked), and the odd-`n` gapped
screen (T20) plus the corpus appendix's QBFT safety theorem (T23) close the
written-mathematics remainder. One written *number* also failed
verification and was fixed (T24's battery-coupon erratum).

---

## 3. Layer 1 — established external physics the core hooks into

Unchanged, and none of it is OPH's result: area laws (Bekenstein–Hawking;
't Hooft–Susskind); **Jacobson 1995** (Einstein equations as an equation of
state) — the shape the OPH "Einstein branch" re-derives on declared branches
(D3–D5, compact paper `:1060–1068`); **holography as erasure correction**
(Almheiri–Dong–Harlow 2015) — whose classical sharp toy is now T9: a
machine-checked instance where "boundary reconstructs bulk" holds *exactly at*
the information-theoretic threshold.

---

## 4. Layer 2 — the conditional tower (each link with its exact assumption)

Re-graded after the v4 campaign. Labels L2.x as in `AUDIT_RESPONSE.md`.

| # | Link | Status (v4–v7) | Anchor |
|---|---|---|---|
| L2.1 | **MAR** selects the sector package | unchanged: axiom, explicitly labeled | compact `:1008–1033` |
| L2.2 | Modular flow → Lorentz | conditional tex chain (D3) — **its finite type-I core now machine-checked** (T21): KMS existence + uniqueness (the state pins its **imaginary-time modular step** — the distinguished algebra automorphism; the *real-time* one-parameter group `ρ^{it}·ρ^{−it}` and its KMS-boundary-condition uniqueness are a separate, formalizable finite statement, open — holes-audit F9), iterate structure, triviality ⟺ traciality, faithful-state axioms — in exactly the "finite type-I regulator class" the D3 row starts from. What stays physics: the **Bisognano–Wichmann identification** (modular flow = boosts) + the scaling limit (weak-*/GNS, possible type-III exit) | compact `:1062`; `formal/…/ModularCore.lean` |
| L2.3 | Entropy stationarity → Einstein branch | conditional tex chain (D4–D5), **its algebra now machine-checked** (T14): rest-frame arithmetic + polynomial upgrade + null-cone step, with the variational identities as named hypotheses; **v6.1: the closing constancy step is also machine-checked** (T26: Bianchi + conservation, named, promote the pointwise λ to a single constant — the branch ends at the Einstein equation); the negative floor guard (P2/T7) machine-checked since v3 | compact `:1063–1064, 4518–4631`; `formal/…/EinsteinBranch.lean`, `NotEinsteinComplete.lean` |
| L2.4 | ℤ₆ quotient of SU(3)×SU(2)×U(1) | **algebra fully machine-checked** (T13): anomalies+Yukawa ⇒ SM hypercharge lattice (uniquely, cubic cancels identically); kernel exactly ℤ₆ with the paper's generator; *selection* still rests on MAR | compact `:5628–5654, 5753–5775`; `formal/…/Hypercharge.lean`, `CenterZ6.lean` |
| L2.5 | **P = 1.630968209403959…** | **the two published numerals and their gap, machine-checked** (the numerals enter as literals; the solver's root is tied to its function only by the reproduced execution — holes-audit F17): `Ppub_bounds` proves the published digits are *by definition* `φ + √π/α⁻¹_CODATA` (bracketed from scratch); `Proot_gap` proves the executed solver's root differs by `3.8–4.0×10⁻⁶` (the ~300 ppm α miss, in P-space). Fine print honest; headline ("zero fitted parameters") still not. The solver's own derivation remains unformalized (its spectral function is physics input) | `formal/…/PBranches.lean`; `AUDIT_RESPONSE_REVIEW.md` §P; `extra/fine_structure_constant_derivation.tex:355–366, 699–744, 1015–1094`; `code/P_derivation/` |
| L2.6 | ℤ₆ reserve, **e^(−P/24)** | conditional theorem with explicit gate (L0–L7; L0 the named icosahedral-shape clause) + receipts — **its skeleton is now machine-checked** (T16): unbiasedness ⇒ `λ_collar = e^(−P/24)` exactly, Jensen band `[e^(−P/24), 1]`, `χ_can = λ_collar` forcing, the 24-bookkeeping and the twelve-port Gauss–Bonnet count; the gate *clauses* stay physics. Branch sensitivity a theorem since v3 (`chi_branch_gap` ∈ (1.4, 1.6)×10⁻⁷) | screen `:1186–1396, 1800–1846`; `formal/…/CollarGate.lean`, `PBranches.lean` |
| L2.7 | ρ_A phantom-density identity | **machine-checked as graded** (T15): an exact rewriting with zero physical content, over any linear divergence operator; plus the exact point-source profile with positivity | dark `:835–899`; chi_nu `:353–362`; `formal/…/DarkSector.lean` |
| L2.8 | Activation law ν = [1−e^(−λ√(g_b/a₀))]⁻¹ | conditional derivation + honest Correction Audit (unchanged as physics); **all its mathematics machine-checked** (T15): well-definedness, monotonicity, both limits (exact deep-MOND scaling), BTFR, the rare-event exponential | dark `:594–830, 2260–2338`; `formal/…/DarkSector.lean` |
| L2.9 | χ_ν continuation law | *form* derived under SEE (Tier B0) — LA core machine-checked since v3; **v4 adds the generator composition** (T17: `response_form`) | chi_nu `:319–351`; screen `:817–864`; `formal/…/ScalarResponse.lean`, `DeltaSBridge.lean` |
| L2.10 | χ_can = e^(−P/24) = 0.9343… | conditional on L0–L7 (unchanged) — the number machine-checked to 9 digits since v3; **the conditional theorem's own derivation now theorem-form** (T16) | `formal/…/PBranches.lean`, `CollarGate.lean`; chi_nu `:1021–1210` |
| L2.11 | Device force law F = C_geom·A·χ·ΔS | the response *input* is still declared (their words: "search and response branch") — **but its derivation half is now machine-checked** (T15: the planar force law is one FTC step from the lab anomaly law); falsifiers are identity tests; the cage that prices it is theorem-form (§5) | chi_nu `:1311–1345, 1412–1424, 1696–1719`; `formal/…/DarkSector.lean`, `EnergyCage.lean` |
| L2.12 | Record-ΔS = gravity-ΔS | **definition side machine-checked** (T17: the generator exists formally; Theorem B.7 in Lean — its counter is *of the same form as* the one the collar prices; the **identification** of the two is part of the named channel physics, not a theorem — holes-audit F11); **numerical bridge open (G9)** — a null bounds χ·ΔS only | chi_nu `:625–967`; `formal/…/DeltaSBridge.lean` |

Four links in series still separate the proven core from the lift claim
(L2.9 form ✓✓ → L2.10 value conditional → L2.11 attribution open → L2.12
bridge open). v4 changes none of the *physics* grades — deliberately; it
finishes the v3 program: **no mathematical sub-claim with a written proof
anywhere in the chain remains unformalized**, and each link's residual
openness is now nameable in one line (its physical hypothesis or its
experiment).

---

## 5. Conservation-law bounds that cage the χ_ν chain — now theorem-form (G10 cage)

`F = −∇E_state` for any internal switchable state ⇒ a work-extraction cycle
unless toggle costs carry the position-dependence. **Machine-checked in
`formal/…/EnergyCage.lean`:** the ABBA cycle identity
(`cycleWork_eq_toggleCost_diff` — first law as an identity),
`no_free_toggle` (a zero toggle ledger extracts zero work; anything else is a
perpetual-motion machine), `toggle_ledger_lower_bound` (a detect must log
≥ W/2 somewhere), and the §5 arithmetic with π-bounds:
σ_ph = Δν·g/(4πG) ∈ **(11.6, 11.8) kg m⁻²** per 10⁻⁹, and
|ΔM·Φ_N| ∈ **(3.49, 3.52) MJ** per ACTIVE toggle at the 56 gf design point.

**What the theorems force vs what the convention prices (v6.1, after
holes-audit F15).** The cycle theorems constrain only toggle-cost
*differences*: for a realized cycle of stroke Δh they force a ledger entry
of order `ΔM·g·Δh` (≈ 0.55 J per metre at the design point — joules, not
megajoules; for a balance protocol at fixed height they force ≈ 0). The
headline **3.5 MJ figure is `ΔM·Φ_N`: the infinity-referenced interaction
energy — a named pricing convention** *(G10-convention: toggling transacts
the full Earth-potential interaction energy against a locally-audited
ledger)*, **not a consequence of T10**; and pricing genuine source
*creation* relativistically would give `ΔM·c² ≈ 5×10¹⁵ J` instead. The
theorem-grade DETECT rule is therefore: a DETECT with genuine transport
cycles must log at least the realized cycle work (T10); a DETECT claiming
created source strength owes an energy account at whichever scale its
completion declares — and the G10-convention's 3.5 MJ is the *declared*
default pricing of the ledgers, carried as a hypothesis, not sold as a
theorem.
`AUDIT_RESPONSE.md` graded this "valid as an external physics obligation";
it is now an obligation *with a theorem attached*. Consequences for the
experiment: NULL is the expected outcome; a genuine DETECT must arrive with
the Document C Part 7 energy log — the theorems say the *minimum* (realized
cycle work), the named G10-convention says the default *pricing* (3.5 MJ
per toggle at the design point).

---

## 6. The minimal proof chain, drawn (v4; annotations through v7)

```
             [PROVEN — Lean, sorry-free, ONE tree: formal/]
  finite patches + overlap consistency + local repair
      ├─ T1/T2  repair terminates ⇔ exactly at consensus states
      ├─ T3     objectivity NOT automatic (non-confluence counterexample)
      ├─ T12    the core's 3 sorries DISCHARGED: canonical frustration-free
      │         localRepair + declared-order Repair (Route B on the carrier);
      │         repair_respects_gauge PROVED; Termination/Lyapunov theorems
      │         for EVERY carrier; Completeness under EdgeRepairable;
      │         Confluence REFUTED on the demo (T3 for the real operator)
      ├─ T6     Route B in quotient form: schedule-independent Rep;
      │         World = Fix(Rep); H_◇ provably not free
      ├─ T7     bare consensus ⇏ Einstein (the fence)
      ├─ T8     layered carrier: HB∧Hfib + reconstruction (feed-forward class)
      ├─ T9     THE JEWEL: n×t Rule-90 cylinder — width-2 timelike screen
      │         is an information set ⟺ n ≤ 2(t+1) (saturates the bound)
      ├─ T18    …and BEYOND the families: general decidable framework;
      │         BOOST INVARIANCE (lightlike screen: same sharp threshold);
      │         PARITY OBSTRUCTION (gap-2 fails forever on even cylinders)
      ├─ T20    …CLASSIFIED COMPLETELY (v5): gap-2 screen decodes ⟺
      │         n ODD ∧ n ≤ 2(t+1) — full adjacent capacity on odd
      │         cylinders (algebraic seed-descent); tilt irrelevant,
      │         separation matters exactly through cycle parity
      ├─ T25    …AND AT EVERY STRIDE (v6): {j₀, j₀+g} decodes ⟺
      │         gcd(g,n) = 1 ∧ n ≤ 2(t+1) — the complete two-column
      │         classification (T9/T20/width-1 are the g = 1/2/0 cases);
      │         MIRROR LEMMA: a dark column pins the whole
      │         antisymmetric sector; QUOTIENT LIFT: gcd ≥ 2 folds both
      │         columns onto one dark quotient column — parity was the
      │         shadow of the gcd
      └─ T19+T22 hexacode [6,3,4]₄: EVERY 3-subset reconstructs (MDS
                extreme); full weight enumerator x⁶+45x²y⁴+18y⁶ (v5)
                          │
                          ▼
        [PAPER-SIDE PHYSICS, HYPOTHESES NAMED — CONSEQUENCES NOW IN LEAN]
  P4 SEE ⇒ same-channel forcing ⇒ unique response FORM (LA core ✓ v3)
  L0–L7 collar gate ⇒ λ_collar = e^(−P/24) EXACTLY + Jensen band
     + χ_can = λ_collar forcing + 24 = (P/4)/6 = 2×12 bookkeeping
     + twelve ports by defect arithmetic (surface = L0)  (T16 — clauses open)
  P5 source generator: FORMAL OBJECT + (𝓛𝒩)(q) = S·avail(q) > 0  (T17)
                          │
                          ▼
              [CONDITIONAL TEX CHAINS — ALGEBRAIC CORES NOW IN LEAN]
  BW scaling → Lorentz (D3): finite type-I modular core NOW IN LEAN —
     KMS existence + UNIQUENESS (the state pins its dynamics), flow
     (real-time one-parameter group since v7 — T28),
     trivial ⟺ tracial (T21) — the BW identification (flow = boosts)
     and the scaling limit stay the named physics
  entropy stationarity → Einstein (D4–D5): rest-frame arithmetic +
     timelike polynomial upgrade + null-cone λη-freedom  (T14 — the
     variational identities stay named physics)
  ℤ₆ kernel: hypercharges FORCED (anomalies+Yukawa, cubic auto) and
     kernel EXACTLY ℤ₆  (T13 — MAR still selects the package)
  activation law: Poisson/limits/BTFR mathematics  (T15 — premises open)
                          │
                          ▼
                  [ASSERTED / CALIBRATED INPUTS — digit-checked since v3]
  P_pub = φ + √π/α_CODATA = 1.630968209403959… (consumes measured α BY
     DEFINITION)  vs  P_root = 1.63097209569 — gap 3.8–4.0×10⁻⁶ checked
  SEE (named)   L0–L7 collar clauses (named; L0 = shape)   MAR (named)
                          │
                          ▼
                  [DECLARED / POSTULATED / OPEN]
  χ value = e^(−P/24) on the gated branch — 0.9343006…, Δχ immaterial
  F = C_geom·A·χ·ΔS: response INPUT declared (its planar-law derivation
     is now one machine-checked FTC step — T15); ledger open — G10
  record-ΔS → gravity-ΔS numerical map (open — G9; the record side is
     now a formal object, so G9 is sharply posed)
                          │
                          ▼
                     [EXPERIMENT]
  this experiment: self-read receipt → ABBA balance → bound or candidate
  (conservation cage of §5 — theorem-form: expect NULL; a real DETECT
   must arrive with the Document C Part 7 energy ledger — minimum set by
   T10 (realized cycle work), scale set by the named G10-convention)
```

---

## 7. What would promote each link (updated after the v6 campaign)

Done since v3: ~~discharge the core's three `sorry`s~~ (**done** — T12, in
this tree; upstreaming to their repo is a file move); ~~formalize the L2.4
algebra~~ (**done** — T13); ~~the D5 algebraic core~~ (**done** — T14);
~~the dark-sector mathematics~~ (**done** — T15); ~~the collar-gate
skeleton~~ (**done** — T16); ~~a formal object for the ΔS bridge~~
(**done** — T17); ~~the §7.6 stretch item, screen families and beyond~~
(**done for width-2 geometry** — T18, with boost invariance and the parity
obstruction as new theorems); ~~the §9 hexacode suggestion~~ (**done** —
T19). Done since v4: ~~the general odd-`n` gapped-screen threshold~~
(**done** — T20, the complete parity classification); ~~a finite core for
D3~~ (**done** — T21, KMS existence + uniqueness in the type-I regulator
class; item 5 below is rewritten accordingly); ~~the hexacode weight
distribution~~ (**done** — T22); ~~the QBFT appendix's safety proof~~
(**done, with a boundary caveat the prose missed** — T23); ~~the
run-matrix conversion arithmetic~~ (**done, one erratum fixed** — T24).
Done since v5: ~~the general-stride gapped-screen conjecture
(`gcd(g,n) = 1`)~~ (**done, sharper than conjectured** — T25, the complete
coprimality classification at the sharp threshold, with the mirror lemma
and the quotient lift as new tools); ~~the λ-constancy step of the
Einstein branch~~ (**done** — T26, closing holes-audit F8: Bianchi +
conservation, named, force one constant). Done since v6.1: ~~the Route-A
joint model~~ (**done** — T27, closing holes-audit F2: local transactional
decode-repair + `H_B` + the sharp `H_fib` jointly on the T9′ carrier, with
both impossibility negatives machine-checked and the stall fiber proven
empty of consistent records); ~~the real-time KMS statement~~ (**done at
the finite-dimensional level** — T28, closing holes-audit F9: the flow
exists, is a ⋆-automorphism group, satisfies the textbook KMS boundary
condition, anchors at T21's map, and is unique among Hamiltonian-implemented
flows up to normalization); ~~the record-counter/collar-counter
identification~~ (**done as a structure theorem** — T29, closing
holes-audit F11: one indexed family, both panels, composite law); ~~the
ℤ₆ kernel as a group isomorphism~~ (**done** — `kernelAddEquiv`, F10c);
~~the two theorem-grade energy anchors beside the G10-convention~~
(**done** — `anchor_ordering` and friends, F15).

1. **G9 (numerical bridge)** — the #1 physics gap, now *maximally* sharply
   posed: calibrate the formally-defined record-side increment (T17's
   generator) against gravity-side ΔS. Since v7 the T29 channel bridge
   splits the residue cleanly in two: (a) the **channel identification** —
   that nature's record channel and collar channel instantiate one
   `Channel` (previously hidden inside the words "the same counter"; now a
   named hypothesis about instantiating a formal structure), and (b) the
   **numerical size of `S`** for a buildable coupon — G9 proper. Without
   them a null bounds only χ·ΔS. (The v5 corpus sweep confirms: no draft
   of this calibration exists anywhere in the corpus — §10.)
2. **G10 (toggle-energy ledger)** — the cage is theorem-form; the *ledger*
   is an experiment (Document C Part 7 logging). A DETECT with transport
   cycles and no ledger entry ≥ the realized cycle work is self-refuting
   by T10; the 3.5 MJ scale is the named **G10-convention** pricing
   (infinity-referenced interaction energy), a hypothesis of the decision
   rule, not a consequence of T10 (holes-audit F15). Since v7 the two
   theorem-grade anchors are themselves machine-checked arithmetic
   (`EnergyCage.lean [formal-v7]`): the forced bench floor
   `ΔM·g·Δh ∈ (0.549, 0.550) J` per metre (and exactly **zero** at fixed
   height, `cycleWork_self`), the creation ceiling
   `ΔM·c² ∈ (5.03, 5.04)×10¹⁵ J`, and the strict ordering
   floor < convention < ceiling (`anchor_ordering`) — the convention is
   visibly a pricing choice inside the theorem corridor.
3. **The named hypotheses** — SEE, MAR, the L0–L7 collar clauses (L0 the icosahedral-shape postulate). Every one
   of them now sits directly upstream of a machine-checked consequence
   theorem, so discharging any one (or exhibiting a certified branch
   instance with receipts) immediately propagates through Lean-checked
   mathematics. This is the remaining theory-side physics.
4. **P** — unchanged: either move the *source branch* forward (the named
   Ward-projected hadronic spectral measure, turning 136.9948 → 137.0360
   into a prediction) or finish demoting the published digits to
   "calibration" everywhere downstream. (Nothing in `dula/` bears on this —
   see §9; the corpus's own `HADRON.md` states the gap plainly — §10.)
5. **D3 (modular flow → Lorentz)** — *regraded in v5, upgraded in v7.*
   The finite type-I core is a theorem (T21), and since v7 the **real-time
   half is too** (T28: the flow `σ_t = ρ^{it}(·)ρ^{−it}` exists as a
   genuine one-parameter ⋆-automorphism group with the textbook KMS
   boundary condition, and the state pins its Hamiltonian's Gibbs weight
   up to the additive constant conjugation cannot see). What promotion
   still requires is exactly the **physics identification**:
   Bisognano–Wichmann for the consensus screen states (modular transport
   on the cap net = geometric boosts) plus the scaling limit; and one
   piece of standard mathematics deliberately not formalized
   (Skolem–Noether, to extend T28's uniqueness from Hamiltonian-implemented
   flows to all automorphism groups). The *clock* is no longer open;
   whether the clock is *boost* is.
6. *(stretch, mathematics — sharpened by T18 + T20, halved by T25)* the
   full weight-distribution classification of arbitrary cell subsets of
   the Rule-90 spacetime code (still a decidable predicate, so conjectures
   are machine-testable — the one §7.6 item that remains; the two-column
   chapter is now closed by T25), wider screens (3+ columns at general
   strides — T25's mirror-lemma method should bite), ~~**intermediate-slope
   screens**~~ (holes-audit F6 — **CLOSED in v9 by T36**,
   `Rule90Lipschitz.lean`: the sharp threshold is not merely
   slope-invariant but **Lipschitz-class-invariant** — every
   adjacent-pair screen along ANY 1-Lipschitz column path (all rational
   slopes `0 ≤ p/q ≤ 1`, zigzags, negative slopes — every observer at
   or below the lattice light speed) is *completely locally decodable*
   at `n ≤ 2(t+1)` (`pathScreen_closure_complete`) and an information
   set **iff** `n ≤ 2(t+1)` (`pathScreen_isInformationSet_iff`,
   `slopeTube_isInformationSet_iff` — sharp for every `p ≤ q`); the v8
   sheared-CA attack was not needed — a direct two-chain fan induction
   closes it, and `Rule90Slope.lean` remains as the definition layer +
   kernel sample points; **what the closure revealed** (v9 sweep,
   `formal/evidence/path_screen_sweep.txt`): beyond Lipschitz the
   pair-screen landscape is provably wild — at `(6,2)` decodability is
   exactly "last step Lipschitz" (order-sensitive,
   `pairScreen_class_6_2`), at `(8,3)` ALL `8^4` paths decode, at
   `(10,4)` the slope-2 line fails at exact capacity — so the residual
   arbitrary-subset question now has machine-checked walls), and other
   linear CA
   (Rule 150; general symmetric stencils, where the mirror-defect argument
   goes through verbatim).
7. *(mathematics, from the holes audit — CLOSED in v7)* ~~the **Route-A
   joint model**~~ (**done** — T27: exactly the predicted shape,
   transactional repair with a declared local sweep roster on the
   cylinder; the composition holds jointly with the sharp `H_fib`, the
   impossibility of the H1–H3 route is now itself a theorem for every
   cylinder, and the audit's stall witness is machine-checked together
   with the fact that its fiber contains no consistent record at all —
   the stall was forced by logic), and ~~the **real-time KMS
   statement**~~ (**done, finite-dimensional** — T28; uniqueness within
   the Hamiltonian-implemented class, the Skolem–Noether extension to
   arbitrary automorphism groups left as the one named leftover). The two
   honest leftovers these proofs *created* — arbitrary-schedule
   termination for T27 and the Skolem–Noether step for T28 — were both
   **closed in v8** (T32 `decodeStep_wellFounded`: the stratified-measure
   argument, carried out — the rank strata ordered lexicographically;
   T33 `algEquiv_matrix_inner` + `kms_algEquiv_structure`). Route A now
   terminates under every scheduler at the tube-pinned record, and the
   KMS clock is unique among ALL automorphism implementations, not just
   Hamiltonian ones.

---

## 8. Verdict (v6)

Strip the corpus to what survives scrutiny now and you keep **five** things:

1. **The machine-checked consensus core, complete and self-contained.**
   T1–T5 (theirs) plus T6–T9 (v3) plus T12 (v4): the core's own repair
   operator now *exists* — canonical, non-degenerate, gauge-respecting —
   and both objectivity routes are theorems about it: Route B with the
   machine check that the declared order is load-bearing (async confluence
   refuted for the *real* operator, and since v6 the separation witness
   satisfies the *other* hypotheses honestly — T6 addendum), Route A with
   a sharp holographic screen that is **boost-invariant** (T18) and now
   **completely classified at every stride** (T25: two-column capacity ⟺
   coprimality ∧ the sharp threshold — T20's parity was the `g = 2`
   shadow of the gcd; the mirror lemma says a lone column pins the whole
   antisymmetric sector), with the geometry-blind MDS hexacode as the
   opposite extreme (T19+T22) — and since v7 the two routes finally *meet*:
   T27 runs a genuinely local, tube-preserving repair on the jewel's own
   carrier and proves every schedule settles to the one world the tube
   pins. One tree, 29 modules, 0 sorry, 1480 environment-swept
   declarations, standard axioms only (v9: **35 modules, 1235 swept
   declarations** under the documented filter — and the screen theorem
   now covers every causal worldline, T36, with two-column local
   decodability classified at every ring distance, T37).
2. **A fully-formalized boundary between mathematics and physics — now
   swept four times** (v5 corpus sweep; the v6 statement audit; the v6.1
   adversarial holes audit; the v7 campaign that closed the audit's
   mathematics: F8 → T26, F2 → T27, F9 → T28, F11 → T29 — so the "what
   remains open is physics" banner has *re-earned* most of its asterisk:
   the residual mathematics is — after v8 closed the two routine
   leftovers (T32/T33) and v9 closed the intermediate-slope question
   (T36) — the arbitrary-subset classification alone, §7 items 6–7). As of v4 no mathematical sub-claim with a written proof
   anywhere in the chain remained unformalized; v5 extended that from "the
   chain" to the corpus's remaining written finite mathematics (T23) and
   reclaimed D3's finite core (T21); v7 reclaimed D3's *real-time* half
   (T28: the clock is a clock) and the Route-A composition (T27). What
   remains unproven is *exactly* the physics — SEE, MAR, the L0–L7 collar
   clauses, G9 with the now-separated channel identification, the G10
   ledger and its named convention, P's source branch, D3's BW
   identification and scaling limit, the realized gauge-group form Γ —
   and every named hypothesis feeds a machine-checked consequence theorem,
   so the boundary is not just drawn but load-tested from the mathematics
   side.
3. **The falsification methodology** — receipts, Correction Audit, the
   pre-registered cage — with the cage's theorems and numbers
   machine-checked, the force law's derivation step (T15) and the
   record-side ΔS object (T17) formal, **and, since v5, the run matrix's
   own conversion constants theorem-form (T24)** — including one erratum
   caught and fixed in the unsafe direction (the battery-coupon ceiling).
   A DETECT/NULL adjudicates named physics, not mathematics or arithmetic
   — with the v6.1 caveat stated plainly (holes-audit F16): until G9
   supplies the record→gravity calibration, a NULL bounds the *product*
   χ·ΔS (no graded claim of the chain is excluded by it), and the DETECT
   filters price against the named G10-convention; the experiment is a
   bound-setting instrument and an engineering rehearsal of the receipt
   discipline — the decisive instrument for the tower is whatever supplies
   G9.
4. **The two-P finding, beyond dispute** (unchanged since v3): the
   published constant is the CODATA-calibrated definition (digit-checked);
   the genuine solver output is a different number (gap machine-checked);
   the χ consequence is priced at (1.4–1.6)×10⁻⁷ — immaterial here,
   decisive for "zero fitted parameters" rhetoric. (The v5 corpus sweep
   adds: `HADRON.md` states the 2.9×10⁻⁷ relative gap plainly — the
   source branch is open by the corpus's own admission, §10.)
5. **A map of what is still open — physical up to four named residual
   mathematics items** (§7): two gaps (G9 — now split into channel
   identification + calibration proper — and the G10 ledger with its named
   convention), the named hypothesis families (SEE, MAR, L0–L7, Γ), one
   source branch (P), one physics identification (D3's Bisognano–Wichmann
   step — its finite mathematics, imaginary AND real time, is closed), and
   on the mathematics side only — since v9 just ONE item: the
   arbitrary-subset classification, now provably wild on its
   pair-screen slice (T36's beyond-Lipschitz walls; the gap-2 crawl
   characterization: **closed by theorem**, T37). The intermediate-slope
   positive half: **closed by theorem** (T36, v9 —
   Lipschitz-class-invariant, strictly stronger than conjectured);
   async-schedule termination and Skolem–Noether: closed (T32/T33,
   v8); the F24 surface residue: closed (T35, v8).

The dark-sector activation law remains the one continuation with genuine
phenomenological content — and its mathematics is now theorem-form on both
sides (T15 downstream of the premises, T16 for the coefficient's gate). The
χ_ν lift chain still ends in the conservation cage — a theorem — and the
experiment in this directory remains the right *first* instrument — as a bound-setter and receipt rehearsal (the decisive instrument for the tower is whatever supplies G9): it prices
the last two links no matter whose prior is right.

*The real new perspective stands, sharpened a fifth time: "objectivity" is
a theorem with hypotheses — and as of v5 the theorem part is machine-checked
end-to-end in a single tree, the hypotheses are named one by one, the first
thing each hypothesis would buy, if discharged, is already proven — and even
"dynamics" turns out to be a theorem with a hypothesis: a patch state
already carries its unique KMS clock — the imaginary-time step (T21) and, since v7, the genuine real-time flow with its KMS boundary condition (T28); what physics must supply is
only which geometric flow that clock is. v6 adds the screen-side coda: what
a holographic screen needs from its geometry is now a one-line arithmetic
condition (T25) — keep the stride coprime to the circumference and meet the
counting bound — and a screen that fails does so for an exactly-nameable
reason: its columns fold onto a single blind column of a smaller world.*

---

## 9. The `dula/` satellite repos (audited 2026-07-06; raw reports in `formal_audits/`)

Four repos by an OPH-team member ("DULA2025") were audited for anything that
could close proof-chain gaps (`PIE_AUDIT_RAW.md`, `DULA_REPOS_AUDIT_RAW.md`).
Bottom line: **nothing in them bears on any open link** (G9, G10, P's spectral
measure, the ℤ₆ collar, or the carrier theorems). Specifics, kept factual:

- **`dula/prime-inertia-engine`** — Aristotle-prover session dumps; a thin
  layer of real-but-classical elementary results; "α-lock" theorems that only
  verify `|28.87·29.4525/(2π) + 16/π² − 137.036| < 0.1` with both constants
  bare decimals (the formula's value, ≈ 136.948, misses CODATA α⁻¹ by
  ~640 ppm); vacuous uniqueness locks (`(x−c)² = 0 ⟺ x = c`); five files
  deriving "RH" from an axiom that *is* the spectral correspondence; one
  **inconsistent axiom set** (`Monster–DULA.lean` quantifies a functional
  equation over every function); and a PDF "Certificate of Formal
  Verification" whose claims are contradicted by the honest AI annotations
  inside the Lean files themselves. One genuinely reusable artifact: a
  sorry-free hexacode `[6,3,4]₄` formalization (systematic-coordinate
  reconstruction — same *shape* as the information-set question, no OPH
  connection made).
- **`dula/DULA-THEOREM---LEAN`** — claimed Lean proofs of BSD, Navier–Stokes,
  Collatz, Goldbach: none proves the named conjecture (axioms asserting the
  conclusions, `smooth := True` stand-ins, sorried headlines, pasted chat
  transcripts); the flagship "rank-5 BSD at conductor 990" sets the analytic
  rank by fiat over a dummy `L ≡ 0` — and rank 5 at that conductor is
  arithmetically impossible.
- **`dula/Riemann-Hypothesis-Proof`** — RH appears verbatim as an `axiom`;
  the one honest file is Aristotle *disproving* the repo's own
  functional-equation claim; the "computational proof" PDF is spline-fitting
  eigenvalues to 500 known zeros.
- **`dula/Geometric-Propulsion-Hardware`** — ⚠ **safety-relevant**: an
  LLM-guided **Biefeld–Brown lifter** build (needle/mesh corona device,
  20–50 kV from ignition-coil/flyback drivers pulsed at "28.87 Hz" — the
  numerology constant silently given units), claiming propellantless thrust /
  "gravitational anomaly". Any real force would be ion wind. Its documented
  "safety systems" are fictional (monitors that compare hardcoded constants
  and always report safe; a shutdown protocol addressing black holes, not
  electricity). Real hazards: HV shock, stored charge after power-off,
  unsnubbered inductive switching, ozone/NOx indoors, EMI into the χ_ν
  electronics. **Recommendation: do not build or power as documented; treat
  as electrically unreviewed.** No connection to the OPH chain beyond the
  reused numerology.

Consequence for this proof chain: none of the four repos changes any grade in
§4. The ℤ₆-vs-mod-6 rhyme is numerological (their own ledger PDF concedes it).
**v4 update:** the hexacode artifact *has* been upstreamed as the second
information-set toy (`formal/OPHProofChain/HexacodePort.lean`, attributed) —
and the v3 estimate ("one `decide` lemma away") turned out modest: the port
closes the source file's own open list (minimum distance 4, hermitian
self-duality) and proves the full MDS statement — every 3-subset is an
information set — from the minimum distance rather than by enumeration (T19).
**v5 update:** the four repos were delta-checked (2026-07-07): no changes
since the audit. The hexacode source file's one remaining numeric claim —
the Python-checked weight distribution — is now also kernel-checked (T22),
closing everything the source file says about the hexacode itself.

---

## 10. The v5 corpus sweep (previously-unaudited directories; 2026-07-07)

The v4 audits covered `LEAN/`, the three main papers, the two `extra/`
tex sources the chain consumes, and `code/P_derivation/`. v5 swept the
**rest** of `observer-patch-holography/` — `claims/`, `physics-problems/`,
`cosmology/`, `book/`, `tracking/`, `contributions/`, `tools/`,
`pdg_data/`, the remaining `extra/` papers, and the remaining `paper/`
files — hunting specifically for anything that closes an open item.
Bottom line: **nothing closes any open link; the open-physics grading of
§7 survives contact with the full corpus.** Specifics:

- **G9**: the D6 "cosmic record-capacity fixed point" material *identifies*
  record capacity with de Sitter entropy as an input, and
  `extra/thinking_as_patch_net_fixed_point_search.tex:1664` defines record
  entropy dimensionally — no numeric record-ΔS → gravity-ΔS calibration
  exists anywhere. G9 stays the #1 gap, by the corpus's own structure.
- **SEE / L0–L7** (L0 named in v6.1): `extra/chi_nu_susceptibility_bounds.tex:1107–1167`
  states the clauses as `Assumption ass:dark-collar-lemmas`, importing
  them from the (already-audited) microphysics paper. No independent
  derivation elsewhere.
- **MAR**: asserted as `Axiom ax:mar` wherever it appears (including
  `extra/OPH_falsifiability.md:110`); no selection derivation.
- **P's source branch**: `HADRON.md` states the gap plainly — solver
  `136.9948…` vs source-side no-hadron endpoint `137.03596…` vs CODATA
  `137.035999…`, with the missing piece named as a non-perturbative
  Ward-projected hadronic spectral computation "emitted without looking at
  the Thomson target". Open by the corpus's own admission.
- **D3**: all BW material lives in the already-audited papers; nothing
  new. (v5's T21 closes the *finite core* from this side instead.)
- **Written mathematics found and dealt with**: the QBFT safety proof
  (`paper/appendix_B_bft_qecc_extensions.tex:66–97`) → formalized, T23,
  with a boundary caveat. The remaining unformalized papers are honestly
  *conditional or out-of-scope physics*, not finite mathematics: the
  Yang–Mills-gap paper (gated on a continuum certificate: Schwinger
  convergence, reflection positivity, transfer/intertwiner — the paper
  says so itself), the photonic proof-of-work paper (gated on a hardware
  fidelity threshold), the string-vacuum-selector framework, the
  patch-net-cognition and theological continuations (speculative
  extensions by their own labels), and the cosmology directory (Phase-III
  phenomenology downstream of the dark-sector premises already graded in
  L2.8).
- **Errata/contradictions**: none found — but note the ledger-side erratum
  T24 *did* find in this repo's own DOCUMENT A (§1.9, battery-coupon
  ceiling), now fixed.
- **Numeric spot-checks**: the sweep's five checkable constants
  (hadronic-gap subtraction, `P/24`, `24/P`, `χ_can`, the fixed-point
  readback) all verify; the chain-relevant ones were already theorem-form
  (T11/T16), and T24 added the run-matrix set.

---

## 11. The adversarial audit and its disposition (v6.1, 2026-07-07)

`../OPH_PROOF_CHAIN_HOLES.md` ("The Hypotheses Have Hypotheses") audited
proof-chain v5 at commit `b8a31c7`: it independently **confirmed the formal
layer** (from-scratch rebuild; an environment-level axiom sweep over **838**
declarations — strictly stronger than this tree's self-audit; zero
non-standard axioms anywhere) and filed 19 findings against the
*interpretation layer*. Disposition:

| Finding | Grade | Disposition (v6.1) |
|---|---|---|
| F1 rung-1 misstatement | ■ | **fixed** — paper §1.3/§1.5 reworded to what T12 proves (termination unconditional; completeness under `EdgeRepairable`; repair can terminate in disagreement) |
| F2 Route A never assembled | ▲ | **CLOSED BY THEOREM — T27 (v7)** (`RouteA.lean`): the predicted transactional repair with a declared local sweep roster exists on the T9′ carrier; dynamics + `H_B` + sharp `H_fib` jointly; observer uniqueness in equality form; completeness ⟺ fiber realizability; both negatives (no-H1H2H3, the stall witness) machine-checked, and the stall fiber proven empty of consistent records |
| F3 hidden choice function | ▲ | **fixed** — the declared fix-selector is now billed alongside the declared order (paper §6) |
| F4 declared-order regress | ● | **acknowledged** — one paragraph added (paper §7): establishing the shared order among partial-view observers is itself a consensus problem; the theorems are conditional on it being given |
| F5 fence scope | ● | **fixed** — the fence is presented as bookkeeping discipline (the geometric decoration is unconstrained), not a discovered obstruction |
| F6 "boost invariance" = 2 slopes | ● | **fixed wording** ("both extreme slopes; intermediate slopes open") + empirical evidence added (5 rational slopes, n ≤ 20, all at the adjacent threshold) + open-list row (§7 item 6); **v9: closed by theorem** — T36 `slopeTube_isInformationSet_iff` (sharp at every rational slope ≤ 1, subsumed by the Lipschitz worldline theorem) |
| F7 prior art / bibliography | ● | **fixed** — related-work paragraph + references added to the paper (Hedlund; Boyle–Lind; Kůrka; MDS/hexacode standards; anomaly-uniqueness literature; finite-dimensional modular theory; PBFT/quorum intersection); the sweep-is-classical point conceded, the finite sharp thresholds/classifications stated as the delta |
| F8 λ-constancy missing | ■ | **CLOSED BY THEOREM — T26** (`LambdaConstancy.lean`): Bianchi + conservation (named) force one constant Λ; connectivity load-bearing (counterexample); T14 now ends at the Einstein equation |
| F9 imaginary-time "clock" | ▲ | **CLOSED BY THEOREM at the finite-dimensional level — T28 (v7)** (`ModularFlow.lean`): the real-time flow exists as a ⋆-automorphism group, satisfies the textbook KMS boundary condition, anchors at T21's map (`σ_i = Δ_ρ`), and is unique among Hamiltonian-implemented flows (`e^{−K} = c·ρ`, `c > 0`); named leftover: Skolem–Noether for arbitrary automorphism groups; BW identification stays physics |
| F10 24-bookkeeping | ▲ | **fixed** — the icosahedral collar postulate is now the named clause **L0** wherever the twelve ports are consumed; the global-gauge-group identification (Γ = ℤ₆ realized in nature) named as a hypothesis where the "6" is consumed; "not numerology" demoted to "numerology with its postulates named". **v7:** the audit's repair item (c) also done — the kernel is packaged as a **group isomorphism** (`kernelAddEquiv : ZMod 6 ≃+ kernelSubgroup`, `CenterZ6.lean [formal-v7]`) |
| F11 "the same counter" | ▲ | **CLOSED BY STRUCTURE — T29 (v7)** (`ChannelBridge.lean`): the audit's own repair option (a) — one indexed family, both counters derived, identification `rfl`, composite Tier-B1 law a theorem; residues = the named channel identification + G9, and nothing else |
| F12 SEE flatness | ● | **fixed** — payoff-type grading added to the named-hypothesis ledger (forcing / band / restatement), SEE's payoff graded "restatement" |
| F13 hypercharge inputs | ● | **fixed** — T13 scope now names the empirical normalization (`Q(ν_L) = 0`) and the package-relative caveat (ν mass requires amending the cast) |
| F14 dark-sector fitting function | ● | **fixed** — the activation law identified as the published RAR fitting function (mechanism proposed for a known fit); the curl/sphericity caveat and the Correction-Audit misfit numbers carried into the paper |
| F15 MJ convention | ■ | **fixed** — the G10-convention named (§5 rewrite here; paper §23; DOCUMENT A §1.9; DOCUMENT C Part 7); theorem-grade anchors stated (realized cycle work; `ΔM·c²` for source creation); the DETECT rule re-worded to consume the convention *as a named hypothesis*. **v7:** the anchors are now machine-checked interval arithmetic with the strict ordering floor < convention < ceiling (`EnergyCage.lean [formal-v7]`: `cycleWork_self`, `bench_cycle_work_value`, `mass_energy_value`, `anchor_ordering`) |
| F16 experiment yield | ● | **fixed** — the honest sentence added to both verdicts (§8 item 3 here; paper §27) |
| F17 two-P residue | ● | **fixed** — L2.5 row reworded ("the two published numerals and their gap"); the composition sentence added to the paper (a χ_can match would confirm an α-calibration, not a derivation, until P's source branch closes) |
| F18 exposition errata (9 rows) | ■ | **all nine applied** to the paper (each row's fix as specified) |
| F19 "everything open is physics" | ● | **fixed, and in v7 mostly re-earned** — the banner carried the asterisk (§8 item 2); of the four mathematics rows the audit added, **three are now theorems** (F8 → T26, F2 → T27, F9 → T28); what remains mathematics-side is the intermediate-slope question (F6), the arbitrary-subset classification, and the two v7-created leftovers (async-schedule termination; Skolem–Noether) — see §7 items 6–7; **v8 closed the two leftovers (T32/T33), v9 closed F6 (T36): mathematics-side residue is the arbitrary-subset classification alone** |

**The second audit pass (v6.1 → v7).** The audit returned for a second pass
(HOLES Part VI, F20–F29) and its verdict is accepted in full: the v6.1
adoption had been *anchor-deep* — the quoted lines were fixed while the same
claims survived at unquoted sites, and five disposition rows overstated the
sweep (F21). The v7 pass answers with grep-driven completion plus theorems:

| Second-pass finding | Disposition (v7) |
|---|---|
| F20 false "exactly" (H_fib ⟺ information set) | **CLOSED BY THEOREM** — the audit's compiled counterexample is now in-tree (`hfib_strictly_weaker_than_informationSet`, `CarrierBridge.lean [formal-v7]`); the paper's front-door sentence rewritten to the true direction |
| F21 anchor-deep fixes; five rows overstated | **residue ledger swept** (this pass, grep-driven): the F9/F10/F11/F15/F16/F19/F1/F8/F6 survivals edited at every listed site — most now *cite the v7 theorems* that make the surviving words legitimate rather than merely deleting them; the five overstated rows replaced by the precise claims in this table and the one above |
| F22 evidence with no artifact | **artifact committed** — `formal/evidence/decodability_checker.py` + output tables (stride `n ≤ 28`, slope `n ≤ 20`), with the floor-convention slope screen *defined*; both claims re-verified by the committed checker |
| F23 T26's rendering imports | **wording fixed** (assumptions-vs-identity, flat-η shadow, reachable-vs-connected) **+ the trivial generalization proven** (`lambda_constant_symm`: symmetric-closure connectivity — ℤⁿ-style charts covered) |
| F24 Gauss–Bonnet clause has no surface | **wording fixed** at all three sites (the Lean sees three numbers and a degree list; the surface structure is consumed informally and is part of L0); the `SimplicialSurface` formalization remains a named optional target |
| F25 cage slogan proven for one schedule | **CLOSED BY THEOREM** — `no_schedule_beats_the_ledger` (`EnergyCage.lean [formal-v7]`): for every closed schedule of moves and toggles, work = net ledger, bounded by (toggles)·ε |
| F26 disposition embeds unformalized mathematics | **CLOSED BY THEOREM** — both embedded facts are now theorems, in stronger form: `rule90CylinderOPH_no_frustrationFree_repair` (every cylinder, every size) and `canonical_repair_stalls` + `stallRecord_tube_unrealizable` (`RouteA.lean`) |
| F27 three v6 prose slips | **all three fixed** (kaleidoscope dichotomy → the two-class mechanism; hexacode reduction reason → encoder-image-by-definition; "closes the open list" → the two hexacode-internal items) |
| F28 version bookkeeping | **swept**: DOCUMENT A changelog gains v0.2.3 (G10-convention naming + the erratum, disclosed on the cover as the pre-registration discipline demands); DOCUMENT B → 0.3.1, DOCUMENT C → 0.2.1; stale counts/labels updated across CORE/paper/READMEs |
| F29 statement-precision nanos | (i) `[NeZero n]` noted at the statement sites; (ii) mirror-kernel "exactly" → forward inclusion (converse assemblable, unformalized — named); (iii) inline-vs-named noted; (iv) `mirrorPair` = union indicator noted; (v) **packaged** (`frustrationFree_properly_within_edgeRepairable`); (vi) noted; (vii) gf parenthetical scoped, ~3 % → ≈ 2.5 %; (viii) 8th digit → 7th decimal place; (ix) ℕ-iterate wording fixed, T28 cited |

The audit's verdict — "the theorems are fine; the hypotheses have
hypotheses, and now they are written down too" — is adopted as the v6.1
standard: the newly named items (G10-convention, collar clause L0, the
global-gauge-group identification, the channel identification of L2.12)
join SEE, MAR, L0–L7, and P's source branch in the named-hypothesis
ledger, each still sitting directly upstream of machine-checked
consequence theorems.

---

## 12. The v8 campaign (2026-07-07, fifth pass): verification + the simulation's feedback + the leftovers

**The verification half (the discipline §11 demanded).** The second audit
pass closed with: *"if a next pass arrives, verify the v7 modules the way
the second pass verified T26."* Done first, before any new mathematics:

- `RouteA.lean` / `ModularFlow.lean` / `ChannelBridge.lean` read
  end-to-end against their claims: every docstring matches its statement;
  `routeA_assembled` genuinely composes all five clauses on ONE carrier
  with the same `j₀` (F2's exact complaint); the negatives carry the full
  `H1∧H2∧H3` binders for every `n ≥ 1, t ≥ 1`; the stall proof
  circumvents `Classical.choose` through a unique-local-fix lemma;
  `same_family := rfl` is honest (the structure makes it so, and the
  residue — whether NATURE instantiates `Channel` — is named in the same
  docstring). The v7 small closures (`kernelAddEquiv`, `anchor_ordering`,
  `hfib_strictly_weaker_than_informationSet`,
  `no_schedule_beats_the_ledger`, `lambda_constant_symm`,
  `frustrationFree_properly_within_edgeRepairable`) all present.
- Fresh `lake build` (8278 → 8282 jobs across the campaign, clean) + a
  **two-namespace** environment `collectAxioms` sweep (the trap §11 warned
  about — `OPH.*` is invisible to root-filtered sweeps): 0 `sorryAx`,
  0 non-standard axioms. Count-filter now documented (`RESULTS.md` §33).

**The new theorems.** Two were surfaced by the simulation companion
(`oph_sim/FINDINGS.md` — a satellite artifact feeding the corpus, exactly
as intended), three close named leftovers, one pins down the remaining
conjecture:

| # | Theorem | Closes / advances |
|---|---|---|
| T30 | `Rule90Propagation.lean` — the local-decodability **phase boundary**: `Inferable` (sound local constraint propagation); column ring-distance ≥ 3 ⟹ closure = screen (zero inferences, unconditionally); adjacent tube at threshold ⟹ closure = everything; T9 re-derived through the closure; `violet_exhibit` (`n=8, g=3, t=3`: T25-certified information set with zero locally derivable bulk cells) | FINDINGS items 1–3 ("would formalize in an afternoon" — it did); the *decoding-complexity* classification under T25's *information* classification; leftover: the `d = 2` crawl — **closed in v9 (T37, §13)** |
| T31 | `Rule90Readout.lean` + RouteA corollaries — the **readout trichotomy**: surjective ⟺ `2(t+1) ≤ n` (kernel count through the first isomorphism theorem; the sweeps' fan columns bound the kernel), bijective ⟺ `n = 2(t+1)`, unrealizable readings ⟺ `n < 2(t+1)`; `all_tubes_realizable` above threshold; `no_stall_at_threshold` at it | FINDINGS item 10, **sharpened** (the sim's table left the `n > B` realizability row open); locates T27.4's stall regime exactly: empty fibers live strictly below the jewel's threshold and nowhere else |
| T32 | RouteA `[formal-v8]` — **universal termination**: `misMeasure` (lex-ordered per-rank mismatch counts) strictly decreases under every accepted transaction ⟹ `decodeStep_wellFounded`, `no_infinite_decode_run`, `exists_normalForm_extension`, `routeA_universal_settlement` | the v7-created leftover, closed — the roster *names* the repair; termination needs no roster at all |
| T33 | ModularFlow `[formal-v8]` — **Skolem–Noether** (`algEquiv_matrix_inner`, classical intertwiner construction) + `kms_algEquiv_structure` (KMS automorphism ⟹ IS the modular map, inner, conjugator `c·ρ`) | the v7-created leftover, closed — T28's Hamiltonian-form restriction is generic; what remains for D3 is exactly BW + scaling limit (physics) |
| T35 | `SimplicialSurface.lean` — **the twelve-port surface**: `TriangulatedSphere` with `3F = 2E` and `∑deg = 2E` *proven* (double counting), Euler the named topological input, `edges_eq_biUnion` (edge data adds no freedom), v5's `sphere_defect_count`/`twelve_unit_defects` consumed unchanged, kernel-checked `icosahedron` (12/20/30, all degree 5, `icosahedron_ports`) | the F24 residue, closed — the "assumed equations" are now facts OF a surface; L0 unchanged as physics |
| T34-lite | `Rule90Slope.lean` — `slopeTube` (the conjecture's formal definition, floor convention = the evidence artifacts' convention = the sim's independently-guessed one), slope-0 = T9's tube (theorem), the failure half at every slope (theorem), threshold positives at slopes 1/2, 1/3, 2/3 kernel-checked (`n = 7, 8, 10`) | F6 pinned down; the general positive half is now the chain's sharpest-posed open mathematics (sheared-CA attack recorded in §7 item 6)— **closed in v9: T36, §13** |

**The satellite-repo re-sweep (fresh eyes, same verdict).** The
2026-07-06 OPH commits (anti-gravity book + amorphous-solids article) were
swept against every open item: **no closers**. Two notes worth keeping:
(1) the new amorphous-solids article consumes `P_src = 1.630972095694329…`
— the **solver-root branch** — while the new book chapter consumes
`χ_can = 0.9343006394893864…` — the **published/CODATA branch**: the
corpus now uses BOTH P branches in different documents, an inconsistency
`PBranches.lean` already prices exactly (`Δχ ∈ (1.4, 1.6)×10⁻⁷`,
immaterial for the experiment, real in the 7th decimal); (2) upstream's
LEAN repo gained its own `Rule90.lean` witness (their issue #304),
paralleling `CarrierBridge.lean` — convergent, not new. The
`code/P_derivation/` gate is unchanged: hadronic spectral payload absent
by the corpus's own admission. `dula/`, `hoverboard/`,
`anti-gravity-experiments/`: heads unchanged.

**What the v8 pass did NOT change.** The physics ledger is untouched —
SEE, MAR, L0–L7, G9 (channel identification + numeric S), the G10 ledger
+ convention, P's source branch, BW + scaling limit, Γ. The experiment's
epistemic position is exactly §8.3's: a NULL bounds the product χ·ΔS
(F16), a DETECT prices against the named G10-convention, and the device
docs remain READY at Milestone 1 (v6 experiment-arm audit; nothing
hardware-touching changed in v8).

---

## 13. The v9 campaign (2026-07-09, sixth pass): the slope conjecture falls

**The verification half.** The v8 modules were re-read against their
claims before anything new was attempted (`Inferable`'s three constructors
are exactly the three directed readings of the Rule-90 constraint, sound by
`inferable_sound`; `slopeTube`'s floor convention matches the committed
evidence artifacts; the v8 instances kernel-check). Fresh `lake build`:
**8284 jobs, clean**. Two-namespace environment sweep: **1235**
non-internal theorem/def declarations, **0 `sorryAx`, 0 non-standard
axioms** (`formal/RESULTS.md` §36).

**The reconnaissance that shaped the theorem.** Before proving anything,
the *non*-Lipschitz regime was swept computationally
(`formal/evidence/path_screen_sweep.txt`): at `(n,t) = (8,3)` **all**
`8^4` pair screens decode — even teleports; at `(6,2)` exactly half fail,
classified by a *last-step* condition; at `(10,4)` the `(8,3)`
universality dies (the slope-2 line fails at exact capacity). Conclusion:
the uniform theorem lives exactly on the Lipschitz class, and nothing
coarser classifies the rest — which told us both what to prove and what
walls to enshrine.

**The theorem (T36, `Rule90Lipschitz.lean`).**

| Piece | Statement | Weight |
|---|---|---|
| `pathScreen_fan` | for a 1-Lipschitz column path `c`, at level `k` below the top row the propagation closure of the worldline screen covers the column interval `[c t − k, c t + 1 + k]` | the engine — a downward two-chain fan induction; the 1-Lipschitz bound `natAbs (c t − c i) ≤ t − i` is *exactly* what keeps each level's screen pair inside the previous level's interval, so both chains always find their upper premise. The v8 sheared-CA attack was never needed |
| **`pathScreen_closure_complete`** | at `n ≤ 2(t+1)`: the closure of a 1-Lipschitz worldline screen is the **whole block** | T30b extended from the static observer to **every causal observer** — full local decodability along any worldline of speed ≤ 1, zigzags and reversals included |
| **`pathScreen_isInformationSet_iff`** | 1-Lipschitz worldline screen is an information set ⟺ `n ≤ 2(t+1)` | sharp, **uniformly in the path** — capacity does not see the worldline, only its Lipschitz class |
| **`slopeTube_isInformationSet_iff`** | for every `p ≤ q`: the slope-`p/q` screen decodes ⟺ `n ≤ 2(t+1)` | **the slope conjecture (holes-audit F6), CLOSED** — T9 and T18a become its two corollary extremes; the v8 instances its sample points |
| `pairScreen_class_6_2` | at `(6,2)`: `![a,b,c]` decodes ⟺ `ringDist b c ≤ 1` (216 cases, kernel) | the first complete classification beyond Lipschitz — order-sensitive (`![0,0,2]` fails, `![0,2,2]` decodes: same step multiset) |
| `pairScreen_slope2_8_3` / `pairScreen_teleport_8_3` / `pairScreen_slope2_fails_10_4` / `pairScreen_late_jump_fails_10_4` / `pairScreen_early_jump_10_4` | slope-2 decodes at `(8,3)` but **fails at exact capacity** at `(10,4)`; late 2-jump fails at `(10,4)` while the same jump one step earlier decodes | the machine-checked walls around the one remaining open item: Lipschitz is sufficient everywhere, necessary nowhere fixed, and the general classification is invariant-resistant |
| **`gapTwo_closure_complete_iff_odd`** (+ `gapTwoTube_closure_complete_odd`, `gapTwo_row1`, `gapTwo_crawl`, `gapTwo_information_set_via_propagation`, `gapTwoTube_closure_incomplete_even` — `Rule90Crawl.lean`, **T37**) | at the sharp threshold the gap-2 screen's propagation closure is complete **iff the ring is odd**: the middle column is enclosed (one down-rule per cell), the two inferred pairs fan row 1 full at `n ≤ 2t+1` (T36's engine with *inferred* anchors — exactly why the fan was stated for arbitrary screens), the crawl wraps row 0 because `2(m+1) ≡ 1 (mod 2m+1)`; even rings stall by parity + soundness | **T30's named leftover, closed** — `oph_sim/FINDINGS.md` item 1 ("the crawl completes on odd rings at threshold") is now a theorem, and the crawl is a *decoder*: T25's odd `g = 2` half re-derives through propagation; two-column local decodability is classified at every ring distance (`d = 1` complete, `d = 2` iff odd, `d ≥ 3` nothing) |

**Route-A significance.** The jewel's holographic screen was a *static*
width-2 tube (T9), then a boosted one (T18a), then any stride (T25 —
different columns, same times). T36 is the missing frame-freedom in the
*worldline* direction: **any** observer trajectory that respects the
lattice light cone reads the full bulk at the same sharp capacity, by
local constraint propagation alone — no global linear algebra needed. The
holographic reading ("a causal observer's two-cell-wide record suffices at
threshold") is now a theorem about every causal observer, not two special
frames.

**What the v9 pass did NOT change.** The physics ledger is untouched —
SEE, MAR, L0–L7, G9 (channel identification + numeric S), the G10 ledger
+ convention, P's source branch, BW + scaling limit, Γ. The experiment's
epistemic position is exactly §8.3's: a NULL bounds the product χ·ΔS
(F16), a DETECT prices against the named G10-convention, and the device
docs remain READY at Milestone 1 (nothing hardware-touching changed in
v9). Open mathematics after v9: **the arbitrary-subset classification**
(now with T36's walls) — nothing else; the gap-2 crawl characterization
inside T30 is closed (T37), so the two-column story is finished at every
ring distance.
