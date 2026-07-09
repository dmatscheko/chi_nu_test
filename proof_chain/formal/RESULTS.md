# RESULTS — statement-by-statement audit

Every entry: the Lean name, what it literally says, and the honest reading
(what it does and does not establish). All results sorry-free on standard
axioms (`propext, Classical.choice, Quot.sound` at most). Line anchors are to
this project's files; paper anchors to `observer-patch-holography/`.

Sections 1–7 are the v3 campaign (unchanged). Sections 8–16 are the **v4
campaign**: the OPH Lean core imported into this tree with its three `sorry`s
discharged, plus seven new modules. Sections 17–19 are the **v5 campaign**
(2026-07-07): the odd-cylinder gap-2 classification (§13 update), the
hexacode weight distribution (§12 update), the D3 finite modular core, the
run-matrix numerics (with one ledger erratum), and the QBFT safety core with
a boundary finding. Sections 20–21 are the **v6 campaign** (2026-07-07, second
pass): the coprimality classification of two-column screens (T25 — the §7
stride conjecture, proven sharp), the completion of the separation
statement's clauses in §1 (`symmetricPair_descends`,
`symmetricPair_normalForm_iff`), and the strictness witness for T12's
completeness hypothesis (§21). Section 22 is the **v6.1 response** to the
adversarial audit `../../OPH_PROOF_CHAIN_HOLES.md` (2026-07-07): T26, the
cosmological-constant step — the audit's F8. Sections 23–26 are the **v7
campaign** (T27/T28/T29 + the small closures). Sections 27–32 are the **v8
campaign** (2026-07-07, after an independent verification pass over the v7
modules): T31 (readout trichotomy, `Rule90Readout.lean` + RouteA
corollaries), T30 (local-decodability phase boundary,
`Rule90Propagation.lean`), T32 (universal termination, RouteA
`[formal-v8]`), T33 (Skolem–Noether, ModularFlow `[formal-v8]`), T35
(the twelve-port surface, `SimplicialSurface.lean`), and T34-lite
(sloped screens pinned down, `Rule90Slope.lean`). Sections 34–35 are the **v9
campaign** (2026-07-09): T36 (`Rule90Lipschitz.lean`) — the Lipschitz
worldline theorem, closing the slope conjecture (holes-audit F6, the last
named open mathematics item of v8) sharp at every rational slope `≤ 1`,
plus the machine-checked delimitation of the non-Lipschitz regime — and
T37 (`Rule90Crawl.lean`) — the gap-2 crawl classified, closing T30's named
leftover; §36 is the v9 sweep note.

## 1. `QuotientRepair.lean` — P1 (tex `reality_as_consensus_protocol.tex:433–610, 1143–1170`)

| Lean name | Statement (informal) | Reading |
|---|---|---|
| `QuotientRepairPresentation` | the tuple `(Σ,Γ,q,Q,C_Q,B,μ,𝖠,≺_𝖠)` + `H_B, H_↓, H_◇, H_comp` as structure fields | the paper's Definition, verbatim; `Γ = ker q`; decidable enabledness = "a least enabled transaction is selectable" |
| `locRep` / `locRep_boundary` / `locRep_desc` / `locRep_eq_self_iff` | the least-enabled-transaction operator is total, boundary-preserving, strictly descending off `C_Q`, fixed exactly on `C_Q` | Proposition `prop:local-quotient-repair`, all four claims |
| `globalRepair` | iterate `locRep` to its fixed point (well-founded recursion on `μ`) | Definition `def:global-quotient-repair-operator`; **this is the object the Lean core's `Repair` sorry stood for**, in quotient form |
| `globalRepair_mem_CQ`, `globalRepair_boundary`, `globalRepair_idem`, `globalRepair_eq_self_iff` | `Rep_λ(x) ∈ C_Q`, `B∘Rep_λ = B`, `Rep_λ² = Rep_λ`, `Rep_λ(x)=x ↔ x∈C_Q` | Theorem `thm:quotient-repair-normal-form`, parts 1–4 |
| `stepRel_terminating`, `stepRel_confluent`, `normalForm_iff_CQ` | termination (from `H_↓`), confluence (Newman from `H_↓ + H_◇`), NF ⟺ consistent (from `H_comp`) | the PROOF_INDEX rows `OPH.Termination`, `OPH.Confluence`, `OPH.Completeness`, at presentation level |
| `schedule_independence` | any terminal state of any accepted execution from `x` **equals** `Rep_λ(x)` | Theorem, part 5 — Route B's payoff: objectivity purchased by the declared order + `H_◇`, not free |
| `World`, `world_is_fixedPt`, `world_mem_CQ` | `World s := Rep_λ(q s)`; `Rep_λ(World s) = World s` | *Paradise* Def 4.1 / Prop 4.2 sentence 1 (PROOF_INDEX rows `OPH.World`, `OPH.world_is_fixedPt`) |
| `repair_respects_gauge` (+ `_action`, `observable_respects_gauge`) | `q s = q s' ⟹ World s = World s'`; gauge moves below `q` never change the repaired world or any observable of it | Corollary `cor:repair-respects-gauge` — the content of the Lean core's third `sorry` |
| `demoPresentation`, `demoPresentation_settles` | a real two-cell instance; `globalRepair (true,false) = (true,true)` computed | non-vacuity: all hypotheses jointly satisfiable, with a genuinely firing repair |
| `symmetricPair_not_locallyConfluent` | the symmetric two-transaction variant is **not** locally confluent | the Lean core's `demoCarrier_not_confluent` in presentation form: `H_◇` is not implied by `H_B ∧ H_↓ ∧ H_comp`; the declared order is load-bearing (axiom-free proof) |
| `symmetricPair_descends`, `symmetricPair_normalForm_iff` (`[formal-v6]`) | the symmetric witness strictly descends the broken-edge count, and its normal forms are exactly the consistent states | the separation statement's remaining clauses (`H_↓`, `H_comp`), machine-checked — the witness satisfies the other hypotheses *honestly* (not vacuously); `H_B` is vacuous on the boundary-free two-cell carrier. `normalForm_iff` is axiom-free |

**Does not establish:** that any *physical* system satisfies `H_B…H_comp`; the hypotheses are the interface. That is exactly the paper's own position (Route B as explicit axiom).

## 2. `NotEinsteinComplete.lean` — P2 (tex `:227–271`)

| Lean name | Statement | Reading |
|---|---|---|
| `demoReduct`, `demoReduct_nondegenerate` | a real consensus reduct (two patches, genuine mismatch/step/nf laws) with both consistent and inconsistent states | the separation below is not driven by a rigged reduct |
| `extEinstein`, `extNonEinstein`, `counterextensions_share_reduct` | two geometric extensions, *definitionally* the same reduct; Einstein holds in one (`einsteinEq_extEinstein`), fails in the other | the paper's two counter-models |
| `bare_consensus_not_einstein_complete` | `¬∃ f : ConsensusReduct → Prop, ∀ E, f E.reduct ↔ EinsteinEq E` | **no predicate of the bare consensus reduct decides the Einstein equation**; also in `Bool`-decision form (`no_reduct_functional_determines_geometry`) |

**Does not establish:** anything about consensus + *extra* structure (that is the D3–D5 branch stack); this is the fence, machine-checked — geometry is extra structure.

## 3. `LayeredCarrier.lean` — P3 (tex `:1225–1364`)

| Lean name | Statement | Reading |
|---|---|---|
| `extend` | `E(b)` by well-founded recursion on layers | the functional extension |
| `sweepUpTo_boundary` / `sweep_restrictB` | no stage writes layer 0 | **H_B** for the staged sweep |
| `sweep_eq_extend` | `R_sweep(a) = E(B(a))` from *any* initial state | reconstruction; unconditional (membership in `C_Q` is exactly admissibility: `sweep_consistent_of_admissible`, `consistent_iff_extend_admissible`) |
| `functionalEq_eq_extend` / `hfib_singleton` | a consistent state *is* the extension of its boundary; `C_Q ∩ B⁻¹(b)` is a singleton | **H_fib** |
| `reconstruction_of_boundary_preserving_repair` | any `R` with `B(R a) = B(a)` and `R a ∈ C_Q` outputs `E(B(a))` | Corollary `cor:layered-carrier-reconstruction`, presentation-free (compose with `globalRepair_boundary` + `globalRepair_mem_CQ` for the paper's exact form) |
| `demoLayered`, `demoLayered_two_consistent_states` | XOR-vertex instance, ≥ 2 dependency edges, populated consistent set | the paper's "genuinely multi-edge" clause, witnessed |

**Honest strength (review R1, preserved):** feed-forward class — boundary = complete input layer. The erasure-correction-strength statement is §4 below, *not* this.

## 4. `Rule90Cylinder.lean` + `CarrierBridge.lean` — the QECC jewel (§7.2 / R1)

Setting: Rule 90 on `ZMod n` over `𝔽₂`; `traj x0` the spacetime block of seed
`x0`; code dimension `n`.

| Lean name | Statement | Reading |
|---|---|---|
| `right_sweep` / `left_sweep` | two adjacent zero columns propagate sideways, losing one step per column (left = right ∘ reflection, `traj_reflect`) | the sideways light-cone: the CA constraint solved for a *neighbour* instead of the future |
| `seed_eq_zero_of_tube_zero` | `n ≤ 2(t+1)` + tube `{j₀,j₀+1}×[0,t]` zero ⟹ seed zero | the vanishing theorem (linearity reduces reconstruction to this) |
| `tube_information_set` | `n ≤ 2(t+1)` ⟹ tube readout **injective** on seeds | **timelike holography**: a width-2 timelike screen determines the bulk |
| `tube_not_information_set_of_lt` | `2(t+1) < n` ⟹ not injective | counting: `2^n` seeds, `2^{2(t+1)}` readouts |
| **`tube_information_set_iff`** | **injective ⟺ `n ≤ 2(t+1)`** | **the sharp threshold: the screen is an information set exactly when its raw cell count reaches the code dimension — it saturates the information bound.** The lightcone bound and the counting bound coincide (both parities: for odd `n`, `n = 2(t+1)` is impossible, and `n ≤ 2t+1` is what the sweep needs) |
| `single_column_not_information_set` (`n ≥ 3`), `single_column_fails_two` (`n = 2`) | a nonzero (mirror-symmetric / nilpotent) seed with the observed column ≡ 0 **for all time** | width 1 fails at every horizon: minimal screen width is exactly 2 |
| `spacelike_proper_subset_fails` | no proper subset of the initial row determines the seed | the timelike/spacelike asymmetry is sharp on the cylinder (the width-3 toy's proper-subset *row* worked only because fixed boundaries cut the code dimension) |
| `rule90Cylinder` + `rule90Cylinder_Hfib_tube(_gauge)` | the `(t+1)`-patch, `t`-edge OPH carrier; `H_fib` for the tube boundary in the core's exact binder form (conclusion even `x = y`) | the jewel in the Lean core's own vocabulary — a proper-subset boundary (2 of `n` cells per interface; `tubeBoundary_strictly_coarser`) discharging `H_fib` through constraint redundancy on a genuinely multi-edge carrier (`rule90Cylinder_multi_edge`) |
| `rule90Cylinder_Hfib_tube_sharp`, `rule90Cylinder_Hfib_column_fails` | `H_fib` fails for the tube when `2(t+1) < n`, and for width-1 columns always (blinker witness, `n = 3`) | the failure surfaces, also in carrier form |

**Does not establish:** the general decodability classification for *arbitrary*
cell subsets (that is a full weight-distribution question); the sharp
characterization here is for the natural screen families (width-2 tubes,
width-1 columns, spacelike rows) — which is what the physics reading uses.

## 5. `EnergyCage.lean` — G10 theorem side + §5 arithmetic

| Lean name | Statement | Reading |
|---|---|---|
| `cycleWork_eq_toggleCost_diff` | ABBA cycle work `=` toggle-cost difference, identically | first law in identity form for a switchable conservative sector |
| `no_free_toggle` | toggle ledger ≤ ε everywhere ⟹ every cycle ≤ 2ε | "switchable force + no toggle energy = perpetual motion", contrapositive; **the G10 obligation as a theorem** |
| `toggle_ledger_lower_bound` | extracting `W`/cycle forces a `≥ W/2` ledger entry somewhere | what a DETECT must log |
| `sigma_ph_value` | `Δν·g/(4πG) ∈ (11.6, 11.8)` kg/m² at `Δν = 10⁻⁹` | §5's `σ_ph ≈ 11.7`, `π`-bounds included |
| `phi_N_value`, `toggle_energy_value` | `Φ_N ∈ (6.24, 6.26)×10⁷` J/kg; `0.056·Φ_N ∈ (3.49, 3.52)` MJ | arithmetic on the **named G10-convention pricing** (infinity-referenced interaction energy) — the cycle theorems force only toggle-cost *differences*; see the v7 anchors (`anchor_ordering`) for the theorem-grade corridor |
| `phantom_mass_cap` | `ΔM·Φ ≤ B ⟹ ΔM ≤ B/Φ` | the budget cap shape used by the battery-coupon argument |

**Does not establish:** the force law (L2.11) or its refutation; non-conservative
completions are outside the model (they are what the energy *ledger* would have
to document).

## 6. `PBranches.lean` — L2.5 §P + L2.10 numerics

| Lean name | Statement | Reading |
|---|---|---|
| `Ppub_bounds` | `φ + √π/137.035999177 ∈ (1.630968209403959, 1.630968209403960)` | **the published digits are the CODATA-calibrated definition** — machine-checked from scratch (`√5` bounds by squaring, 20-digit `π` bounds). Consumes measured α *by definition*; derives nothing about α |
| `Proot_gap` | solver root − `Ppub` `∈ (3.8, 4.0)×10⁻⁶` | the two P's are distinct numbers (the ~300 ppm finding, in P-space); the root enters as the executed solver's published numeral |
| `chiCanPub_bounds` | `e^(−Ppub/24) ∈ (0.934300639, 0.93430064)` | the L2.10 falsification target to 9 digits, by 6-term Taylor sandwich with explicit remainder (no `native_decide`) |
| `chiCanRoot_bounds` | `e^(−Proot/24) ∈ (0.934300487, 0.934300489)` | the other branch |
| `chi_branch_gap` | `χ^pub − χ^root ∈ (1.4, 1.6)×10⁻⁷` | the branch discrepancy is *real* (8th digit, sign fixed) and *immaterial* (inside every A/C tolerance) — review §P's conclusion, machine-checked |

## 7. `ScalarResponse.lean` — P4 form half (screen tex `:817–864`)

| Lean name | Statement | Reading |
|---|---|---|
| `unique_scalar_linear_response` | register one-generator ⟹ every linear response is `c·η ↦ χ·c`, `χ = δν(η)` | the *form* `δν = χ⟨η,S⟩`; conditionality concentrated in SEE, exactly as the paper states it |
| `no_second_susceptibility` | two responses equal on `η` are equal on all admissible sources | "no independent local scalar susceptibility" |

**Does not establish:** SEE. It is physics input and stays a hypothesis — that
is the honest division of labor the papers themselves adopted.

---

## 8. `Core/` — the OPH Lean core, imported and DISCHARGED (v4)

`Core/AbstractRewriting.lean` and `Core/Rule90.lean` are verbatim attributed
copies of `observer-patch-holography/LEAN/ObserverPatchHolography/` (headers
say exactly what changed: nothing but the import path). `Core/Primitives.lean`
is the attributed copy **with the source file's three documented `sorry`s
discharged**; every modification carries a `[formal-v4]` tag.

| Lean name | Statement (informal) | Reading |
|---|---|---|
| `localRepair` | **(was `sorry` #1)** the canonical frustration-free snap: fires iff a broken incident edge exists AND the patch can satisfy all its incident interfaces at once; snaps to a `Classical.choose`-selected satisfying state | a genuine, non-degenerate repair operator, definable for *every* carrier; the fire condition and chosen state are functions of the declared overlap data |
| `Repair` | **(was `sorry` #2)** iterate `localRepair` at the least firing site in a declared patch order until quiescent; total by well-founded descent on the broken-edge count | the paper's Route B (declared order `≺_𝖠`) realized on the original carrier — schedule independence is *purchased*, not assumed |
| `repair_respects_gauge` | **(was `sorry` #3, now a theorem)** `gaugeEquiv x y → gaugeEquiv (Repair x) (Repair y)` | Prop 4.2 sentence 2: the whole iterated schedule factors through `obsMap` (`obsMap_Repair_congr` + the congruence chain `edgeConsistentAt_congr` … `leastFiringSite_congr`) |
| `canonical_lyapunov` | the file's own `LyapunovDescent C` def, proved for **every** carrier | every accepted canonical step strictly lowers `Φ` |
| `canonical_termination` | the file's own `Termination C` def, proved for **every** carrier | asynchronous accepted steps are well-founded |
| `canonical_completeness` | the file's own `Completeness C` def, under the named local hypothesis `EdgeRepairable C` (weaker than `FrustrationFree C`) | normal forms = consistent records; the hypothesis is honest — `Core/Rule90.lean`'s `rule90_no_frustrationFree_repair` shows unconditional H2 is impossible |
| `canonical_H2` | on frustration-free carriers the canonical operator satisfies the generic section's `H2` (H1/H3 hold unconditionally) | the whole `LocalRepairDynamics` section, incl. `boundary_fiber_observer_unique`, applies to the canonical operator there |
| `Repair_reduction`, `Repair_normalForm`, `Repair_consistent`, `Repair_idem`, `Repair_of_consistent` | `Repair` is one accepted schedule; lands on a normal form; consistent output under `EdgeRepairable`; idempotent; fixes consistent inputs | the *Reality*/*Paradise* normal-form package on the original carrier |
| `localRepair_demoCarrier` | on `demoCarrier` the canonical operator **is** the file's neighbour-copy `demoLR` | the anti-degeneracy witness the source file's `sorry` documentation demanded — no `Repair := id` smuggling |
| `canonical_not_confluent` | the file's own `Confluence demoCarrier` is **refuted** | T3 restated for the genuine operator: asynchronous schedules of the real repair reach different worlds |
| `Repair_demoCarrier_ne` | `Repair` genuinely moves the broken identity record | the composite operator does real work |

**Does not establish:** which carriers are `EdgeRepairable` (physics/modeling,
per carrier); confluence (false in general — that is the point); anything the
source file's generic `lr`-section did not already claim. 25 axiom-audited
declarations, all standard.

## 9. `Hypercharge.lean` — L2.4 algebra, half 1 (compact tex `:5628–5654`)

| Lean name | Statement | Reading |
|---|---|---|
| `hypercharge_ratios` | Yukawa closure + `[SU(2)]²U(1)` + gravitational anomaly ⇒ `Y_L = −N·Y_Q`, `Y_H = N·Y_Q`, `Y_u = −(N+1)·Y_Q`, `Y_d = (N−1)·Y_Q`, `Y_e = 2N·Y_Q` (over `ℚ`, any `N`) | the paper's Theorem `thm:hypercharge`, ratio half — the solution space is exactly the SM ray |
| `su3_anomaly_of_yukawa` | `[SU(N)]²U(1)` anomaly follows from Yukawa closure alone | one anomaly is not an independent condition |
| `cubic_anomaly_auto` | `[U(1)]³` cancels **identically** on the solution ray (polynomial identity in `N, Y_Q`) | the cubic gives no extra constraint — why normalization must come from `Q = T₃+Y` |
| `YQ_of_normalization` | `Q(ν_L) = 0` (i.e. `Y_L = −1/2`) ⇒ `Y_Q = 1/(2N)` | the electroweak normalization step |
| `smAssignment_valid`, `hypercharges_unique` | at `N = 3` the SM lattice `(1/6, −2/3, 1/3, −1/2, 1, 1/2)` satisfies everything and is the **unique** solution | the exact SM hypercharges, forced |

**Does not establish:** the matter package, `N = 3`, or the Yukawa structure —
that selection is **MAR**, the named physical hypothesis of L2.4.

## 10. `CenterZ6.lean` — L2.4 algebra, half 2 (compact tex `:5753–5775`)

| Lean name | Statement | Reading |
|---|---|---|
| `charges_match_hypercharges` | the module's integer charges `q` are `6Y` for `Hypercharge.smAssignment` | the two halves describe one package |
| `g0k_actsTrivially` | every `g0k k = (k mod 3, k mod 2, k/6)` acts trivially on all six SM multiplets | the paper's six phase checks `2t+3d+q ≡ 0 (mod 6)` |
| `actsTrivially_iff` | a central element `(a,b,θ) ∈ ℤ₃×ℤ₂×ℝ/ℤ` acts trivially on the package **iff** it is some `g0k k` | Proposition `prop:z6`, both directions; forward uses exactly the paper's two multiplets (`e^c` pins `U(1)` to sixth roots, `Q` pins `ℤ₃×ℤ₂`) |
| `g0k_eq_iff` | `g0k k = g0k k' ↔ k ≡ k' (mod 6)` | the parameterization is faithfully `ZMod 6` |
| `kernel_bijection` / `kernelEquivZMod6` | the trivially-acting subgroup is in bijection with `ZMod 6` | **the kernel is exactly ℤ₆** — `G_phys = SU(3)×SU(2)×U(1)/ℤ₆` |
| `addOrderOf_g0` | the paper's generator `g₀ = (ω₃, −1, e^{iπ/3})` has additive order 6 | `g₀` generates the full kernel |

**Does not establish:** MAR (selection of the package). With §9 this makes the
"real algebra" of proof-chain link L2.4 fully machine-checked.

## 11. `DarkSector.lean` — L2.8 + L2.7 mathematics (dark tex `:681–899`; chi_nu tex `:353–362, 1311–1345`)

| Lean name | Statement | Reading |
|---|---|---|
| `activation_pos/lt_one`, `one_lt_nuOPH`, `nuOPH_antitone` | `0 < p(x) < 1`, `ν > 1`, `ν` strictly decreasing on `(0,∞)` | well-definedness of the activation law `ν = (1−e^{−λ√x})⁻¹` |
| `flux_closure_inversion` | `g_b = p·g_obs ∧ p ≠ 0 ⇒ g_obs = ν·g_b` | eq:fluxrecovery → eq:ophrar |
| `nuOPH_tendsto_one` | `ν(x) → 1` as `x → ∞` | the Newtonian limit |
| `deepMOND_limit`, `deepMOND_gobs` | `p(x)/(λ√x) → 1` as `x → 0⁺`; hence `g_obs/√(a_eff·g_b) → 1` with `a_eff = a₀/λ²` | the deep-MOND square-root scaling, exactly |
| `btfr` | `g = √(a_eff·GM/r²) ∧ v² = gr ⇒ v⁴ = GM·a_eff` | the paper's BTFR theorem |
| `rare_event_zero_count` | `(1−μ/m)^m → e^{−μ}` | the Poisson zero-count limit inside eq:poissonlaw |
| `phantom_bookkeeping` | over any linear `div`: `div g_b = −4πG·ρ_b ⇒ div(g_b+g_A) = −4πG(ρ_b + ρ_A)`, `ρ_A := −(4πG)⁻¹ div g_A` | **L2.7 as claimed: an exact rewriting with zero physical content** |
| `MA_pos`, `MA_strictMonoOn`, `hasDerivAt_MA`, `rhoA_pos` | the point-source phantom profile `M_A(r) = M_b/(e^{λr_M/r}−1)`: positive, strictly increasing, `M_A′ = 4πr²·ρ_A` with the paper's displayed `ρ_A`, shell-positive | the printed density is exactly the shell-mass bookkeeping; positivity criterion holds for the point source |
| `thin_device_force` | `∫₀ʰ (gχ/(4πG)·S′)·g·A = g²/(4πG)·A·χ·ΔS` | the Planar Response Law is one FTC step from the lab anomaly law; **the response law itself stays the L2.11 input** |

**Does not establish:** the Poisson-counting premises (codimension-one collar
support, independent increments, rare events) or the flux-recovery closure —
the paper's own named hypotheses of Conditional Theorem 2; and not `λ`'s value
(CollarGate/PBranches).

## 12. `HexacodePort.lean` — the second information-set toy (§9 of the proof chain; ported from `dula/`, attributed)

| Lean name | Statement | Reading |
|---|---|---|
| (ported) `hexacodeSet_card` | the hexacode has `64 = 4³` codewords | dimension 3, in counting form (port compiled unmodified) |
| `hexacode_min_weight`, `hexacode_weight_four_attained` | every nonzero message encodes with weight ≥ 4; 4 attained | **the `[6,3,4]₄` parameter claim, closed in Lean** (source file had only a Python check); `d = n−k+1` ⇒ MDS |
| `three_subset_information_set` | any two messages agreeing on ANY 3 of the 6 coordinates are equal | **every 3-subset is an information set** — proved from min weight by support counting, not enumeration |
| `two_subset_not_information_set` | an explicit 2-subset with two distinct agreeing codewords | sharpness |
| `hexacode_self_dual` | `⟨u,w⟩_H = 0` on the whole code | Hermitian self-duality (source file's other open item) |

**Reading:** the geometry-blind MDS extreme — *any* 3 coordinates reconstruct —
against the Rule-90 carrier's geometry-sensitive screens (timelike tubes work,
spacelike subsets never). Both toys now live in one tree.

**v5 addition — the full weight distribution:**

| Lean name | Statement | Reading |
|---|---|---|
| `hexacode_weights_only` | every codeword has weight 0, 4, or 6 | the support of the weight enumerator |
| `hexacode_weight_distribution` | `A₀ = 1, A₄ = 45, A₆ = 18` (message-level counts; the encoder is injective) | the weight enumerator `x⁶ + 45x²y⁴ + 18y⁶` — the numeric half of the source file's Python check, kernel-checked. Every hexacode claim of the `dula/` source file is now closed in Lean (its `K₁₂` lattice goal is out of scope) |

## 13. `Rule90Decoding.lean` — the §7.6 stretch item (general decodability)

| Lean name | Statement | Reading |
|---|---|---|
| `isInformationSet_iff_vanishing` | readout injectivity ⟺ trivial kernel | the linearity reduction, for arbitrary finite cell sets |
| `Decidable (IsInformationSet S)` instance | information-set status is decidable through the vanishing form | concrete instances are one `decide` away |
| `card_lt_not_informationSet` | fewer than `n` cells never determine the seed | the universal counting bound |
| `isInformationSet_mono` | supersets of information sets are information sets | monotonicity |
| `tubeSet_isInformationSet_iff` | the adjacent width-2 tube: information set **iff `n ≤ 2(t+1)`** | T9 restated in the framework (failure half now from the general counting bound) |
| `light_sweep`, `seed_eq_zero_of_lightTube_zero`, **`lightTube_isInformationSet_iff`** | the **lightlike** width-2 tube `{(i,j₀+i),(i,j₀+i+1)}`: information set **iff `n ≤ 2(t+1)`** | **NEW — boost invariance of screen capacity**: tilting the screen onto the lightcone makes the decoding sweep one-sided but double-speed; the sharp threshold is unchanged, and the boosted screen still saturates the information bound |
| `gapTwoTube_fails_even` | on **even** cylinders the gap-2 screen `{j₀, j₀+2}` is never an information set, at any horizon (explicit alternating-seed kernel; `evolve` kills it in one step) | **NEW — adjacency is load-bearing**: the gapped screen reads only one class of the spacetime checkerboard. What T9's screen uses is adjacency (both classes), not the tilt |
| `gapTwo_five_two`, `lightTube_six_two` | decided instances: gap-2 works on the odd 5-cylinder at `t=2`; the lightlike screen works at the exact counting boundary `(n,t) = (6,2)` | kept as machine-checked cross-checks of the v5 theorem below |

**v5 addition — the complete parity classification (closes the "odd-`n`
gap-2 threshold" this section left open in v4):**

| Lean name | Statement | Reading |
|---|---|---|
| `gap_mid_col` | the two screen columns determine the enclosed middle column at times `[1, t+1]` | the constraint at the middle cell has *both* inputs on the screen — the decoding really is different from the adjacent sweep |
| `gap_right_fan` / `gap_left_fan` | from the recovered middle column the two fans sweep the cylinder on windows starting at time 1, losing one step per column (left = right ∘ reflection) | row 1 is zeroed everywhere once `n ≤ 2t+1`; row 0 is *not* reachable by sweeping — the middle column's seed cell is invisible |
| `parity_const_of_evolve_zero`, `exists_two_mul_step`, `eq_zero_of_evolve_zero_odd` | a row killed by one step is constant along the distance-2 walk; on odd `n` that walk is transitive; one zero reading kills the constant | **the algebraic descent to the seed** — exactly the step whose failure on even cylinders *is* the checkerboard obstruction |
| `seed_eq_zero_of_gapTwoTube_zero` | odd `n ≤ 2(t+1)` + gapped screen zero ⟹ seed zero | the vanishing theorem |
| **`gapTwoTube_isInformationSet_iff_odd`** | odd `n`: information set **⟺ `n ≤ 2(t+1)`** | **the gapped screen has full adjacent capacity at the same sharp threshold** — stretching the screen apart costs nothing on odd cylinders |
| `gapTwoTube_fails_two` | `n = 2`: the "gapped" screen degenerates to one column and fails | the last even case, closed |
| **`gapTwoTube_isInformationSet_iff_parity`** | for every `n`: information set **⟺ `Odd n ∧ n ≤ 2(t+1)`** | **the complete width-2 story**: tilt (boost) is irrelevant, separation matters exactly through cycle parity |

**Does not establish:** the full weight-distribution classification of
arbitrary subsets (open; still a decidable predicate — the remaining §7
stretch item). **v6 note:** the general-stride question this section's
theorems raised (capacity for `{j₀, j₀+g}`) is **closed** — see §20: the
parity classification above is the `g = 2` case of the coprimality
classification.

## 14. `EinsteinBranch.lean` — L2.3 linear-algebra core (compact tex `:4518–4631`)

| Lean name | Statement | Reading |
|---|---|---|
| `rest_frame_relation` | `0 = δS + δA/(4G)` ∧ `δS = (8π²ℓ⁴/15)X` ∧ `δA = −(4πℓ⁴/15)Z` ⇒ `Z = 8πG·X` | the arithmetic of Theorem `thm:einstein`, with the three variational identities as **named physics hypotheses** (entropy stationarity, small-ball bridge, area variation) |
| `unit_timelike_determines` | a symmetric form vanishing on all future **unit timelike** directions vanishes identically | the paper's polynomial upgrade step (`cor:einstein`), by finite timelike witnesses + cone scaling — no analysis |
| `tensor_upgrade` | rest-frame relation in **every** local rest frame ⇒ `G_ij + Λg_ij = κT_ij` entrywise | Theorem `cor:einstein`, packaged |
| `null_cone_determines` | a symmetric form vanishing on the **null cone** equals `(−B₀₀)·η` | the classic algebraic step under Jacobson-shaped derivations |
| `jacobson_step` | `F(k,k) = κT(k,k)` on all null `k` ⇒ `∃λ, F = κT + λη` | the equation-of-state step: the pointwise freedom is exactly the cosmological constant |

**Does not establish:** the variational identities themselves (D3–D5's
conditional tex chain — the physics); nothing here derives geometry from
consensus (the fence is `NotEinsteinComplete.lean`).

## 15. `CollarGate.lean` — L2.6 skeleton (screen tex `:1186–1396, 1800–1846`; chi_nu tex `:1024–1206`)

| Lean name | Statement | Reading |
|---|---|---|
| `poisson_zero_count` | `poissonPMFReal ε 0 = e^(−ε)` | the per-slice survival factor is the Poisson zero-count (Assumption *Local Poisson reserve survival*); the rare-events law itself is Mathlib's `binomial_tendsto_poissonPMFReal_atTop` |
| `uniform_gate` | slice-wise unbiasedness (`∀y, ε y = P/24`) ⇒ `λ_collar = e^(−P/24)` exactly | **the gate theorem** — the paper's own proof (substitute + `∑w = 1`), with the gate clauses as named hypotheses |
| `jensen_band` | weighted mean reserve `= P/24` ⇒ `e^(−P/24) ≤ λ_collar ≤ 1` | the theorem-level band (`0.9343… ≤ χ_can ≤ 1`), by Jensen for `exp` |
| `chi_forced` | `λS = χS ∧ S ≠ 0 ⇒ χ = λ` | the *Forced canonical susceptibility* theorem — its proof is literally this cancellation |
| `reserve_split`, `six_is_card_z6`, `twentyfour_is_oriented_ports` | `(P/4)/6 = P/24`; `6 = #(ZMod 6)`; `24 = #(Fin 12 × Bool)` | the 24 bookkeeping, tied to `CenterZ6.lean`'s ℤ₆ and the 12-port × write/check register |
| `sphere_defect_count`, `twelve_unit_defects` | all-triangle surface with Euler characteristic 2 ⇒ total defect `∑(6−deg) = 12`; degrees ∈ {5,6} ⇒ **exactly 12** defect vertices | combinatorial Gauss–Bonnet: where the icosahedral screen-sieve's "twelve ports" comes from (Euler's relation = the named topological input) |

**Does not establish:** the gate clauses L1–L7 (product algebra/trace,
reserve pullback, disintegration, unbiasedness, Poisson survival) — the
operator-algebra physics; and not `P` (see `PBranches.lean` for the digits).

## 16. `DeltaSBridge.lean` — P5 / L2.12 definition side (chi_nu tex `:625–967`)

| Lean name | Statement | Reading |
|---|---|---|
| `SlotRegister`, `CoherentSource`, `count`, `gen`, `avail` | the finite scalar-slot register, the footprint (Def B.4), the opportunity count `𝒩`, the unit-normalized generator `𝓛` (Def B.5), the availability factor | **the formal object the proof chain said did not exist yet** |
| `count_activate` | `count(q⊕e) − count(q) = a_e·[1 − p_e(q)]` | the exact increment computation |
| `gen_count` | `(𝓛 count)(q) = S·avail(q)` | **Theorem B.7 machine-checked**: coherent matter perturbs the *same* counter the collar prices — the ΔS-bridge definition side, closed in Lean |
| `gen_count_pos`, `avail_pos_iff` | positivity for `S > 0`, `A > 0`; non-saturation ⟺ some weighted inactive slot | B.7's positivity clause; Def B.4's non-saturation, as an iff |
| `response_form` | `χ·(𝓛 count)(q) = (χS)·avail(q)` | Corollary B.11's shape, composing with `ScalarResponse.lean`'s forced linear response |
| `demoR`/`demo_gen_value`/`demo_gen_pos` | a concrete 2-slot register where the generator fires with value 1 | non-vacuity: all hypotheses jointly satisfiable |

**Does not establish:** **G9** — the *numerical* record-ΔS → gravity-ΔS
calibration stays open (a null experiment bounds only `χ·ΔS`); and the
observer-side receipts defining `S_coh` (self-reading, durable records,
prediction) remain the paper's named operational tests.

---

## 17. `ModularCore.lean` — the D3 finite (type-I) core (v5; compact tex `:1062`)

Native module (no ported text). Setting: a faithful state `ω(A) = tr(ρA)`,
`ρ` positive definite, on the matrix algebra `Matrix ι ι ℂ` — exactly the
"finite type-I regulator class" the compact paper's D3 row starts from.

| Lean name | Statement | Reading |
|---|---|---|
| `eq_zero_of_forall_mul_trace_eq_zero` | the trace pairing is nondegenerate | the workhorse (matrix units) |
| `modular_one/mul/add/smul`, `modular_left_inverse`, `modular_iterate` | `Δ_ρ(A) = ρAρ⁻¹` is a unital algebra automorphism; its `k`-fold iterate is conjugation by `ρᵏ` | the integer-step imaginary-time iterate (the genuine real-time one-parameter group is §24, `ModularFlow.lean`, v7) |
| `modular_smul_rho` | `Δ_{cρ} = Δ_ρ` (`c ≠ 0`) | the flow sees the state's shape, not its normalization |
| **`kms`** | `ω(A · Δ_ρ(B)) = ω(B · A)` | **existence**: the algebraic KMS identity at imaginary unit time (two trace cyclings) |
| **`kms_unique`** | any map `D` with `ω(A · D(B)) = ω(BA)` for all `A, B` equals `Δ_ρ` — *no linearity assumed* | **uniqueness**: the KMS demand alone pins the dynamics — the finite core of "thermal time" |
| `state_modular` | `ω ∘ Δ_ρ = ω` | state invariance |
| `modular_eq_id_iff_tracial` | flow trivial ⟺ `ω` tracial | *every non-tracial state ticks*; both directions are one-liners from existence + uniqueness |
| `state_one`, `state_star`, `state_nonneg`, `state_faithful` | `ω(1) = 1`, `ω(Aᴴ) = ω(A)*`, `0 ≤ ω(AᴴA)`, `ω(AᴴA) = 0 → A = 0` | the standing "faithful state" hypotheses of modular theory, discharged from positive definiteness |
| `qubitRho_posDef`, `qubitState_modular_ne_id` | `ρ ∝ diag(1,2)`: `Δ_ρ(E₀₁) = ½·E₀₁ ≠ E₀₁` | non-vacuity: a concrete faithful state whose modular clock genuinely ticks |

**Does not establish:** Bisognano–Wichmann (modular flow = geometric
boosts) — the actual D3 physics; the scaling limit / weak-* extraction /
type-III exit; real-time flow `Δ^{it}` (functional calculus); the Lorentz
branch and `H³` charts downstream. **Consequence for the proof chain:** the
§7 line "D3 has no isolable finite-mathematics core" is retired — D3 now has
a machine-checked finite core consuming a named physical identification,
exactly like the other Layer-2 links.

## 18. `LedgerNumerics.lean` — run-matrix conversion constants (v5; test ledgers)

Native module. Inputs are the ledgers' declared constants (`g = 9.80665`,
`G = 6.67430e-11`, `A = 4.8e-3 m²`, `F_min = 5e-8 N`, `E_batt = 3.6e4 J`);
π enters through Mathlib's `pi_gt_d6`/`pi_lt_d6` as in `EnergyCage.lean`.

| Lean name | Statement | Reading |
|---|---|---|
| `Cgeom_bounds` | `g²/(4πG) ∈ (1.146636, 1.146638)×10¹¹` | DOCUMENT A §1.1's `1.146637×10¹¹ N m⁻²` is exact to its last printed digit |
| `CgeomA_bounds` | `C_geom·A ∈ (5.5038, 5.5039)×10⁸` | the one-zone force-per-Δν (printed `5.50×10⁸`) |
| `dnu_min_bounds` | `F_min/(C_geom·A) ∈ (9.084, 9.085)×10⁻¹⁷` | **the headline null-bound conversion** — the printed `9.1×10⁻¹⁷` rounds *up*, the safe direction for a null bound |
| `design_force_bounds`, `design_gf_bounds`, `design_snr_bounds` | `0.550 N`, `56.12 gf`, SNR `1.10×10⁷` at `Δν = 10⁻⁹` | the design-point row of the run matrix |
| `lockin_stat_exact` | `10⁻⁶·√(2/1800) = 10⁻⁶/30` **exactly** | the lock-in statistical floor is `3.3̅×10⁻⁸ N` with *no* numerics — `√(2/1800) = 1/30` |
| `battery_coupon_bounds` | battery coupon ceiling `∈ (1.02, 1.03)×10⁻¹¹` (`0.575–0.578` gf) | **ERRATUM found and fixed**: DOCUMENT A §1.9 printed "≲ 1×10⁻¹¹ (≈ 0.5 gf)" — ~3 % *below* the true ceiling, the unsafe direction for a discrimination bound; the ledger now prints `≲ 1.1×10⁻¹¹ (≈ 0.58 gf)` with an erratum note pointing here |

**Does not establish:** anything about the force law itself (L2.11) — these
are unit conversions the decision rules consume; the remaining run-matrix
rows are the same three operations and are stated, not duplicated.

## 19. `ConsensusSafety.lean` — the QBFT safety core + boundary finding (v5; corpus appendix, attributed)

Formalizes the *Safety* half of Theorem `thm:qbft-safety` of
`observer-patch-holography/paper/appendix_B_bft_qecc_extensions.tex:66–97`
(a corpus *extension*, not a chain link — formalized for completeness of the
corpus's written finite mathematics).

| Lean name | Statement | Reading |
|---|---|---|
| `qbft_safety_core` | overlap `> |F|` + unique signed votes ⟹ two certificates agree | the appendix's counting argument, exactly as sketched (P1 + A5 modeled as `vote : V → Option α`) |
| `quorum_intersection_exact` | `n = 3f+1`, quorums `≥ 2f+1` ⟹ overlap `≥ f+1` | A6 derived from A3 **at the classical sizing** |
| `quorum_intersection_general` | `f + 1 + n ≤ 2q` ⟹ overlap `≥ f+1` | the correct general-`n` quorum sizing |
| `qbft_safety` | the composed safety theorem at `n = 3f+1` | Theorem `thm:qbft-safety` (i) |
| **`quorum_overlap_gap`** | on 5 observers (`f = 1`) two 3-quorums overlap in **one** node | **boundary finding (new)**: the appendix's "A6 is guaranteed by A3" is false for `n > 3f+1` at fixed quorum size `2f+1` — already at `n = 3f+2` the overlap can be all-Byzantine. The theorem stands at `n = 3f+1`; for general `n` the quorum must scale |

**Does not establish:** liveness and optimality (the appendix itself cites
DLS 1988 / Lamport–Shostak–Pease 1982 — external named results); the A4
connectivity clause (feeds liveness); any connection to the χ_ν chain
(none exists).

---

## 20. `Rule90Stride.lean` — the coprimality classification, T25 (v6; the §7 stride conjecture)

Native module. The proof chain's §7 item 6 conjectured (from T20's
mechanism): *gapped screens of general stride `g` have capacity iff
`gcd(g, n) = 1`*. This module proves the conjecture **in sharp form** —
coprime strides have the *full adjacent capacity at the same sharp
threshold*, and non-coprime strides fail at *every* horizon.

| Lean name | Statement | Reading |
|---|---|---|
| `gapTube` / `mem_gapTube` / `gapTube_card_le` | the stride-`g` screen `{j₀, j₀+g} × [0,t]` as a cell set; `≤ 2(t+1)` cells | `g = 1` is T9's tube, `g = 2` is T20's gapped tube, `g ≡ 0` the width-1 column |
| `mirror_sweep` | column `j₀` dark on `[0,t]` ⟹ the values at displacements `±u` agree at time `i` whenever `i + u ≤ t` | **the defect sweep**: the mirror defect `D_i(u) = x_i(j₀+u) + x_i(j₀−u)` is itself a Rule-90 trajectory in displacement space, dark on the *adjacent pair* `{0,1}` — so it dies by a one-sided sideways sweep |
| **`mirror_of_column_dark`** | column `j₀` dark on `[0,t]` and `n ≤ 2(t+1)` ⟹ `z x = z (2j₀ − x)` for every `x` | **THE MIRROR LEMMA (new)**: a single dark column forces mirror symmetry about itself — it pins *the whole antisymmetric sector* (plus its own centre cell, read at time 0), and its failure kernel consists of the symmetric seeds with dark centre — v3's mirror-kernel seeds (forward inclusion is the lemma; the converse assembles from `evolve_symmetric(_center)` but is not a named theorem — audit F29). The even-`n` antipode is out of sweep range but identically zero (it compares the antipodal cell with itself) |
| `periodic_of_double_mirror`, `walk_of_periodic` | symmetry about both read columns ⟹ invariance under translation by `2g`, iterated | the composition of the two reflections is the translation — the dihedral step |
| `exists_nat_mul_step` | `(m : ZMod n)` a unit ⟹ every cell is `m·k` | the coprimality workhorse |
| `seed_eq_zero_of_gapTube_zero` | `gcd(g,n) = 1`, `n ≤ 2(t+1)`, both columns dark ⟹ seed zero | the vanishing theorem: odd `n` — `2g` is a unit and one reading kills the constant; even `n` — `g` odd, the parity homomorphism `ZMod n →+* ZMod 2` splits the cells, and the two time-0 readings kill both classes |
| `evolve_comap` / `traj_comap` | reduction mod `d ∣ n` is a graph covering: trajectories of pulled-back seeds are pulled-back trajectories | **the quotient lift** |
| `mirrorPair`, `mirrorPair_symmetric`, `evolve_symmetric(_center)`, `mirrorPair_dark` | the mirror-pair seed (the *union indicator* of `{m+1, m−1}` — not the literal 𝔽₂ sum, which dies at `d = 2`) on `ZMod d` is mirror-symmetric with trajectory dark on column `m` forever (`d ≥ 2`; nonzero-ness is proved inline in the quotient lift, not a named lemma — audit F29) | symmetry is dynamics-invariant and a symmetric row reads zero at its centre; at `d = 2` the pair degenerates to `δ_1` — v4's alternating checkerboard seed is the `d = 2` lift |
| `gapTube_not_informationSet_of_dvd` / `…_of_gcd_ne_one` | any common divisor `d ≥ 2` of `(g, n)` kills the screen at every horizon | both read columns land on the *same* dark column of the quotient `d`-cylinder |
| **`gapTube_isInformationSet_iff`** | **information set ⟺ `gcd(g, n) = 1 ∧ n ≤ 2(t+1)`** | **T25 — the complete two-column classification**: separation matters exactly through coprimality; coprime strides lose nothing |
| `tubeSet_iff_via_stride`, `gapTwoTube_parity_via_stride`, `gapTube_zero_iff` | T9's iff, T20's parity iff, and the width-1 negatives re-derived as the `g = 1, 2, 0` special cases | consistency corollaries — two independent proofs of T20 now agree; the originals stand untouched |
| `gapThree_eight_three/two`, `gapThree_nine_four` | kernel-`decide` cross-checks at the exact boundaries: `(n,g,t) = (8,3,3)` decodes, `(8,3,2)` fails (counting), `(9,3,4)` fails (gcd) with time to spare | empirical anchors for both halves at the tight thresholds |

**Does not establish:** the full weight-distribution classification of
*arbitrary* cell subsets (still the one remaining §7.6 stretch item, still a
decidable predicate); wider screens (3+ columns); other linear CA rules.

**Empirical note** (artifact: `evidence/decodability_checker.py` + committed output tables — v7, audit F22)**.** The classification was confirmed computationally for all
`n ≤ 28` and all strides before formalization (minimal decoding horizon
`t* = ⌈n/2⌉ − 1` exactly at every coprime stride; no decoding up to `t = 80`
at every non-coprime stride).

## 21. `RepairHypotheses.lean` — the T12 hypothesis lattice, closed (v6)

Native module (the `Core/` attributed copies stay verbatim). T12's
completeness theorem is stated under `EdgeRepairable C`, which three
documents called "strictly weaker than `FrustrationFree C`" — with only the
implication half (`edgeRepairable_of_frustrationFree`) machine-checked. This
module closes the strictness half with the natural witness.

| Lean name | Statement | Reading |
|---|---|---|
| `rule90_edgeRepairable` | the width-3 Rule-90 carrier is `EdgeRepairable` | the next-row patch (identity projection) always satisfies the single interface by copying the CA image of the seed row |
| `rule90_not_frustrationFree` | the same carrier is **not** `FrustrationFree` | the seed patch cannot fix a record whose next row is `(0,0,1)` — outside the CA image (whose outer cells always coincide, `rule90t_outer_eq`) |
| `edgeRepairable_strictly_weaker`, `frustrationFree_properly_within_edgeRepairable` (`[formal-v7]`) | both packaged; the class-inclusion properness is now itself a packaged theorem (audit F29(v)) | **the inclusion `FrustrationFree ⊆ EdgeRepairable` of carriers is proper** — and the witness is exactly the carrier on which `Core/Rule90.lean` proves no frustration-free repair operator exists, so T12's completeness theorem provably covers carriers beyond the frustration-free class |

**Does not establish:** anything new about *which* physical carriers are
`EdgeRepairable` (still per-carrier modeling, as T12's grading says).

## 22. `LambdaConstancy.lean` — the cosmological-constant step, T26 (v6.1; holes-audit F8)

Native module, same vocabulary as `EinsteinBranch.lean` (§14). The audit
(`OPH_PROOF_CHAIN_HOLES.md` F8) correctly observed that `jacobson_step`
produces a pointwise λ — a scalar *field* over any region — and that the
classical closing step (Bianchi + conservation ⟹ ∇λ = 0 ⟹ λ constant) was
written mathematics the chain consumed without formalizing or naming. This
module formalizes it in discrete-chart form.

| Lean name | Statement | Reading |
|---|---|---|
| `dpar` / `ddiv` / `Reachable` | forward-difference partials; divergence of the first index; step-reachability | the discrete chart (first-order shadow of the continuum operators) |
| `ddiv_lam_eta` | `ddiv (λ·η) = Σᵢ (∂ᵢλ)·η i ·` | the Leibniz step — exact because `η` is constant |
| `row_eta_cancel` | vanishing η-contraction ⟹ vanishing row | `η` is diagonal with unit entries |
| `step_invariant_of_divergence_free` | `F = κT + λη` pointwise + `ddiv F = ddiv T = 0` ⟹ `λ(step i p) = λ(p)` | **the constancy mechanism** — the discrete gradient of λ dies |
| `lambda_constant` | + connectivity ⟹ `∃ Λ, ∀ p, λ p = Λ` | one constant across the chart |
| **`einstein_equation_with_constant`** | null-cone matching at every point + **named** Bianchi/conservation inputs + connectivity ⟹ `F = κT + Λη`, one `Λ` | **T26 — T14 now ends at the Einstein equation with a genuine constant**, not a scalar field; the promotion "λ → the cosmological constant" is a theorem, not a naming |
| `lambda_not_constant_without_connectivity` | a disconnected two-point chart with non-constant λ satisfying all other hypotheses | the connectivity hypothesis is load-bearing |

**Does not establish:** the Bianchi identity or stress conservation
themselves (named hypotheses — the geometry/physics, exactly like T14's
variational identities); the continuum PDE version (the discrete chart is
the first-order shadow); the null-cone matching (that is T14's package
upstream).

## 23. `RouteA.lean` — Route A assembled, T27 (v7; holes-audit F2)

Native module on the T9′ carrier (`rule90Cylinder n t`), at the sharp
threshold `n ≤ 2(t+1)`, tube `{j₀, j₀+1}`. The audit's F2: dynamics,
boundary preservation, and the redundancy-boundary `H_fib` had never been
discharged on one carrier — and provably could not be, in the H1–H3
local-repair reading. This module assembles the composition with
**transactional decode-repair** (single-cell writes, edge-bounded read
windows, formula-mismatch trigger) under a **declared responsibility
roster** (right/left sweep budgets `R = min t (n−2)`, `L = (n−2)−R`,
downward territory) — billed as declared structure, Route-B style. A roster
with both budgets `≤ t` exists **iff** `n ≤ 2(t+1)`.

| Lean name | Statement | Reading |
|---|---|---|
| `uOf` / `IsTube` / `budgetR` / `budgetL` | tube-offset coordinate; the declared split | the roster's coordinate system |
| `OwnedR/L/D`, `Owned`, `coverage` | ownership cases; **every cell is tube or owned** (needs the threshold) | the roster is total exactly at the jewel's threshold |
| `rank`, `rank_read1_R` … `rank_read_D` | the schedule strata; **every formula reads strictly below its own rank** | stratification — the load-bearing structure |
| `formulaValue`, `formulaValue_congr`, `formulaValue_sub` | the declared formulas; congruence below rank; linearity | sideways-solved CA constraints (char 2) |
| `DecodeStep`, `Dom`, `act` | the accepted one-step relation (T6's `StepRel`) | one cell per transaction; window = one carrier edge |
| `normalForm_iff_quiescent` | normal forms ⟺ decode quiescence | the dynamics' terminal states characterized |
| `decodeStep_tube`, `reflTransGen_tube` | `H_B`: every accepted step preserves the tube reading | the boundary survives every schedule |
| `pass`, `pass_spec` | the declared rank schedule reaches a normal form in one pass | **liveness** |
| `quiescentDiff_eq_zero`, `quiescent_ext` | zero-tube quiescent record = 0; equal-tube quiescent records are equal | **the tube pins the settled world** (strong induction on rank; the linear difference trick) |
| `quiescent_of_consistent` | consistent ⟹ quiescent | trajectories satisfy every declared formula identically |
| `RealizableTube`, `no_consistent_completion_of_unrealizable` | fiber realizability; empty fibers have no consistent records | **the stall is logic, not weakness** |
| **`routeA_observer_uniqueness`** | equal tube ⟹ same settled world, any schedules, equality form | Route A's conclusion — stronger than `gaugeEquiv`, no realizability needed |
| **`routeA_world_exists_unique`** | every record settles to a unique world | existence + uniqueness packaged |
| **`routeA_world_consistent_iff`** | settled world consistent ⟺ starting fiber realizable | completeness exactly on realizable fibers |
| **`routeA_assembled`** | the quotable bundle: liveness ∧ `H_B` ∧ uniqueness ∧ completeness-iff ∧ sharp `H_fib` (T9′, same carrier) | **F2 closed** |
| `sum_evolve`, `delta_not_evolve` | Rule-90 images have even weight; `δ₀` is no image | the impossibility engine |
| **`rule90CylinderOPH_no_frustrationFree_repair`** | no `H1∧H2∧H3` operator on the cylinder, ∀ `n ≥ 1, t ≥ 1` | the audit's "checkable by hand" general claim, checked |
| **`canonical_repair_stalls`** | the canonical T12 operator fires once from `(0,δ₀,δ₁)` (`n=3,t=2`) and stalls at `(0,δ₀,ev δ₀)`, a non-consistent normal form | the audit's stall witness, machine-checked |
| **`stallRecord_tube_unrealizable`** | that record's tube fiber contains **no** consistent record | the stall is the forced case of the dichotomy |

**Does not establish:** termination of *arbitrary* (non-pass) schedules —
uniqueness already covers every schedule that terminates; the missing piece
is only that no schedule dithers forever (routine via a stratified
exponential measure; named leftover). The roster itself is declared
structure, billed — different rosters give different, equally valid repairs.

## 24. `ModularFlow.lean` — the real-time modular flow, T28 (v7; holes-audit F9)

Native module extending `ModularCore.lean` (§17). The audit's F9: T21 pins
the imaginary-time modular *map*; calling it a clock imported unformalized
real-time content. Now formalized, finite-dimensionally.

| Lean name | Statement | Reading |
|---|---|---|
| `IsModularHamiltonian`, `exists_modularHamiltonian` | Hermitian `H` with `exp(−H) = ρ` exists for every PosDef `ρ` | the spectral construction of `−log ρ` |
| `flowU`, `flow` | `σ_z(A) = e^{izH}·A·e^{−izH}`, all complex `z` | the flow and its entire analytic extension in one object |
| `flowU_add`, `flow_add`, `flow_zero` | one-parameter group laws | a genuine flow, not an integer iterate |
| `flow_mul`, `flow_one`, `flow_star_real`, `flowU_conjTranspose` | algebra automorphisms; ⋆-preservation and unitary propagators at real times | the automorphism-group structure |
| `flowU_continuous` | norm-continuity in the parameter | the finite stand-in for σ-weak continuity |
| `rho_commute_flowU`, `state_flow` | `ω ∘ σ_z = ω` | state invariance, all complex parameters |
| **`flow_I_eq_modular`** | `σ_i = Δ_ρ` | the analytic anchor: T21's map IS the flow at `z = i` |
| **`kms_boundary`** | `ω(A·σ_{t+i}(B)) = ω(σ_t(B)·A)`, all complex `t` | **the textbook KMS boundary condition, real time inside** — one line from the group law + T21's `kms` |
| `eq_smul_one_of_commute_all` | the center of the matrix algebra is scalars | the uniqueness engine's second half |
| **`kms_conjugation_eq`** | any invertible KMS-satisfying conjugation has `V = c•ρ` | normalization-free uniqueness |
| `posDef_exp_neg` | `exp(−K)` is PosDef for Hermitian `K` | `MᴴM` with invertible `M` |
| **`hamiltonian_kms_unique`** | a Hamiltonian-implemented KMS flow has `e^{−K} = c·ρ`, real `c > 0`, and its imaginary step is the modular map | **the state pins its clock** up to the constant conjugation cannot see |

**Does not establish:** uniqueness beyond the Hamiltonian-implemented class
(needs Skolem–Noether — named leftover); the Bisognano–Wichmann
identification and the scaling limit (named physics, unchanged).

## 25. `ChannelBridge.lean` — the channel bridge, T29 (v7; holes-audit F11)

Native module importing `DeltaSBridge.lean` (§13) and `CollarGate.lean`
(§12). The audit's F11: "the same counter the collar prices" had no formal
counterpart — two disjoint modules, prose identification. This module is
the audit's own repair option (a): one structure, both counters derived.

| Lean name | Statement | Reading |
|---|---|---|
| `Channel` | ONE finite indexed family with both panels (record: activity/weights/activation; collar: slice weights/reserve means) | the bridge structure |
| `toRegister`, `toSlices` | a genuine `SlotRegister` and a genuine `SliceModel`, derived | both T17's and T16's objects from one source |
| **`same_family`** | `(toRegister C).E = (toSlices C).ι` — by `rfl` | the identification is definitional inside the structure |
| `count_eq`, `lambdaCollar_eq` | both counters are sums over the same family | "the same counter", literally |
| `bridge_gate` | unbiasedness at `P/24` ⟹ `λ_collar = e^{−P/24}` on the derived slices | T16 consumed through the bridge |
| **`channel_composite`** | `λ_collar · (𝓛𝒩)(q) = e^{−P/24}·S·A(q)` | **the composite Tier-B1 law inside one structure** |
| `demoChannel`, `demoChannel_composite_pos` | a two-slot instance where everything fires jointly, strictly positively | non-vacuity |

**Does not establish:** that nature instantiates `Channel` (the named
**channel identification** — the physics that used to hide inside the word
"same"), or the numerical `S` (G9 proper). Those two, and only those, are
the residue.

## 26. v7 addenda in existing modules

* **`CenterZ6.lean` `[formal-v7]`** (holes-audit F10c): `phase_add` /
  `phase_zero` / `phase_neg` (the phase map is an additive character in the
  central element), `kernelSubgroup` (the trivially-acting elements form an
  additive subgroup), and **`kernelAddEquiv : ZMod 6 ≃+ kernelSubgroup`** —
  the set bijection and `addOrderOf g0 = 6` upgraded to the group
  isomorphism the chain documents quote.
* **`CarrierBridge.lean` `[formal-v7]`** (holes-audit F20): `rowOneBoundary_Hfib`,
  `rowOneBoundary_not_informationSet`, and the package
  **`hfib_strictly_weaker_than_informationSet`** — the audit's compiled
  counterexample, in-tree: on `rule90Cylinder 3 1` the full row-1 readout
  satisfies the `H_fib` binder verbatim (gauge conclusion) while two distinct
  consistent records share it (seeds `0` and `(1,1,1)`), so "boundary
  satisfying `H_fib`" is strictly weaker than "information set". The paper's
  front-door "exactly" was false in exactly this direction; now the failure
  is a theorem and the sentence states the true direction.
* **`EnergyCage.lean` `[formal-v7]`** (holes-audit F25): schedules as lists
  of legs (`Leg`, `runSchedule`, `totalWork`, `totalLedger`,
  `toggleCount`); **`work_sub_ledger_eq_energy_drop`** (the first law along
  any schedule); **`closed_schedule_work_eq_ledger`**; and
  **`no_schedule_beats_the_ledger`** — the cage slogan at its advertised
  generality: any closed schedule with per-toggle ledger ≤ ε extracts at
  most (number of toggles)·ε. The ABBA theorems are the two-toggle case.
* **`LambdaConstancy.lean` `[formal-v7]`** (holes-audit F23):
  `SymmReachable`, `lam_eq_of_symmReachable`, **`lambda_constant_symm`** —
  constancy under symmetric-closure connectivity (steps forward or
  backward), covering ℤⁿ-style charts that forward root-reachability does
  not.
* **`RepairHypotheses.lean` `[formal-v7]`** (holes-audit F29(v)):
  **`frustrationFree_properly_within_edgeRepairable`** — the class inclusion
  packaged: every frustration-free carrier is edge-repairable, and some
  edge-repairable carrier is not frustration-free.
* **`EnergyCage.lean` `[formal-v7]`** (holes-audit F15): `cycleWork_self`
  (fixed-position cycles have zero work — the theorems force NO ledger
  entry for the balance protocol), `bench_cycle_work_value`
  (`ΔM·g·Δh ∈ (0.549, 0.550) J` per metre), `mass_energy_value`
  (`ΔM·c² ∈ (5.03, 5.04)×10¹⁵ J`), and **`anchor_ordering`** — the
  G10-convention figure sits strictly between the theorem-forced floor and
  the relativistic ceiling. The audit's "seven orders above, nine below"
  is now interval arithmetic.

## 27. `Rule90Readout.lean` — T31, the readout trichotomy (v8; surfaced by `oph_sim/FINDINGS.md` item 10)

| Lean name | Statement (informal) | Reading |
|---|---|---|
| `tubeDataHom` | the width-2 tube readout as an additive group hom `(ZMod 2)ⁿ →+ (ZMod 2 × ZMod 2)^(t+1)` | linearity made structural (`evolve_add`/`traj_add` new) |
| `dark_tube_zero_on_fan` | a seed dark on the tube vanishes on all `2(t+1)` fan columns | the v3 sweeps (`right_sweep`/`left_sweep`) read at row 0 — **no threshold hypothesis** |
| `card_ker_tubeDataHom_le` | for `2(t+1) ≤ n` the kernel has ≤ `2^(n−2(t+1))` elements | kernel elements are pinned on the fans, free only off them |
| `tubeData_surjective_of_le` / `tubeData_surjective_iff` | the readout is onto **iff** `2(t+1) ≤ n` | first isomorphism theorem + the kernel bound: `2ⁿ = \|ker\|·\|range\|` forces full range; converse by counting |
| `readout_ghost` | above threshold a nonzero dark seed exists | the T9-converse counting argument, packaged |
| `readout_trichotomy` | `n > B`: surjective ∧ ghosts; `n = B`: bijective; `n < B`: injective ∧ unrealizable readings exist (`B = 2(t+1)`) | the simulation's bits/unknowns table, **sharpened**: the `n > B` row now says every reading is realizable (the sim only claimed ghosts) |
| `tubeData_bijective_iff` | bijective ⟺ `n = 2(t+1)` | the sharp threshold is a *double* extreme: saturates the information bound AND carries zero redundancy |

RouteA corollaries (`[formal-v8]` section of `RouteA.lean`):

| Lean name | Statement (informal) | Reading |
|---|---|---|
| `traj_record_consistent` | trajectory records are consistent | the converse of `consistent_record_is_traj`, previously missing |
| `realizableTube_iff_range` | `RealizableTube j₀ τ ↔ τ ∈ range (tubeData j₀ t)` | fibers of T27.4 = fibers of the seed readout |
| `all_tubes_realizable` | `2(t+1) ≤ n` ⟹ every tube reading realizable | in the ghost regime there are NO empty fibers |
| `exists_unrealizable_tube_iff` | unrealizable readings exist ⟺ `n < 2(t+1)` | **T27.4's stall regime is exactly the strict-inequality side of the jewel's threshold** (the audit's `n=3, t=2` witness lives there: `2⁶−2³` empty fibers) |
| `no_stall_at_threshold` | at `n = 2(t+1)` every settled world is consistent | the bijective corner: nothing to stall on |

## 28. `Rule90Propagation.lean` — T30, the local-decodability phase boundary (v8; surfaced by `oph_sim/FINDINGS.md` items 1–3)

| Lean name | Statement (informal) | Reading |
|---|---|---|
| `Inferable` | the closure of a cell set under the three directed readings of the Rule-90 constraint | exactly the simulation's local-constraint-propagation decoder, as an inductive predicate |
| `inferable_sound` | trajectories agreeing on `S` agree on every `Inferable S` cell | the closure never invents information — the phase boundary is about decoding power |
| `ringDist` / `ringDist_le_of_eq_add` | ring distance; `b = a + k ⟹ dist ≤ k` | the constraint's three cells sit in three consecutive columns |
| `spread_screen_inferable_iff` | columns pairwise ≥ 3 apart (any number of columns, `n ≥ 3`) ⟹ closure = the screen itself | **no local foothold**: no single constraint touches two screen columns — stronger than the sim's two-column observation (works for arbitrary spread column sets, all horizons, unconditionally) |
| `gapTube_inferable_iff` | the two-column special case | the sim's `d ≥ 3` regime |
| `right_fan_inferable` / `left_fan_inferable` / `adjacent_closure_complete` | at `n ≤ 2(t+1)` the tube's closure is the **entire block** | T9's sweeps are single-constraint inferences; downward rule finishes |
| `tube_information_set_via_propagation` | T9 sufficiency re-derived through the closure | the sweep *is* local propagation |
| `violet_exhibit` | `n=8, g=3, t=3`: `IsInformationSet` (via T25) ∧ closure = screen | **determination without local derivability, machine-checked** — the simulation's flagship violet configuration |

Named leftover: the `d = 2` (gap) completeness — the sim's crawl — is not classified here.

## 29. `RouteA.lean` `[formal-v8]` — T32, universal termination (closes T27's named leftover)

| Lean name | Statement (informal) | Reading |
|---|---|---|
| `misCount` / `misMeasure` | per-rank mismatch counts, ordered lexicographically (`Lex (Fin (2t+2) → ℕ)`) | the responsibility roster's stratification, read as a potential |
| `not_dom_act_self` | a transaction satisfies its own cell | the formula reads strictly below its own rank; the write is at its rank |
| `dom_act_iff_of_rank_le` | strata ≤ the firing rank are untouched elsewhere | reads and values there never see the written cell |
| `misCount_act_of_lt` / `misCount_act_lt` | lower strata counts equal; the firing stratum strictly shrinks | the lex decrease, componentwise |
| `misMeasure_decreases` | every accepted transaction strictly decreases the measure | firing can only break strata *above* its rank |
| **`decodeStep_wellFounded`** | the decode dynamics is strongly normalizing | **no schedule — fair or adversarial — runs forever** |
| `no_infinite_decode_run` / `exists_normalForm_extension` | schedule-shaped readings | any run terminates; any partial run extends to a normal form |
| `routeA_universal_settlement` | T32 + T27a bundled | every schedule terminates AND ends at the ONE record the tube pins; the roster is needed to *name* a repair, not to make repair terminate |

## 30. `ModularFlow.lean` `[formal-v8]` — T33, Skolem–Noether (closes T28's named leftover)

| Lean name | Statement (informal) | Reading |
|---|---|---|
| **`algEquiv_matrix_inner`** | every `ℂ`-algebra automorphism of `Matrix ι ι ℂ` is inner (`∃ U, IsUnit U.det ∧ φ = U·U⁻¹`) | the classical intertwiner construction, fully finite-dimensional: matrix units transport, `U·e_j := φ(E_{j i₀})·w`, injectivity from `F_{i₀k}·U·x = (x k)•w` |
| `kms_algEquiv_structure` | any automorphism satisfying KMS against `ω_ρ` (i) IS the modular map and (ii) is inner with conjugator `c•ρ`, `c ≠ 0` | T33 + T21's `kms_unique` + T28's `kms_conjugation_eq` composed; **nothing about the implementing form is assumed anymore** |

Reading: T28's "uniqueness within the Hamiltonian-implemented class" is now generic at the algebra level — there is no non-inner automorphism a rival clock could use. What stays physics: Bisognano–Wichmann and the scaling limit (unchanged).

## 31. `SimplicialSurface.lean` — T35, a surface for the twelve ports (v8; closes the holes-audit F24 residue)

| Lean name | Statement (informal) | Reading |
|---|---|---|
| `TriangulatedSphere` | vertices + triangular faces + edges, every edge in exactly two faces, every face carrying exactly three edges, Euler = 2 | the structure F24 found absent; Euler stays the *named topological input* (as the v5 docstring always billed it) |
| `edges_eq_biUnion` | the edge set provably equals all 2-subsets of faces | listing edges as data adds no freedom |
| **`three_faces_eq_two_edges`** / **`degree_sum_eq_two_edges`** | `3F = 2E` and `∑ deg = 2E` | **the audit's assumed equations, now proven** (double counting) |
| `defect_count` / `twelve_ports` | total defect 12; unit defects ⟹ exactly twelve | the v5 theorems `sphere_defect_count` / `twelve_unit_defects` consumed **unchanged**, their hypotheses discharged |
| `TriangulatedSphere.ofFn` | indexed constructor (`Fin nF → Finset V`, `Fin nE → Finset V`) with index-level side conditions | kernel-friendly instance path (`Finset`-of-`Finset` reduction is catastrophically deep; index-level filters are cheap) |
| `icosahedron` / `icosahedron_deg` / `icosahedron_counts` / `icosahedron_ports` | 12 vertices, 20 faces, 30 edges, all degrees 5, twelve ports | the concrete surface, all side conditions kernel-`decide`d |

L0 — that the collar's transverse structure IS such a complex — is unchanged as the named physics.

## 32. `Rule90Slope.lean` — T34-lite, sloped screens pinned down (v8)

| Lean name | Statement (informal) | Reading |
|---|---|---|
| `slopeTube` | the slope-`p/q` screen: cells `(i, j₀+⌊i·p/q⌋)` + right neighbour | **the conjecture finally has an in-tree definition** (floor convention — the same the committed sweep artifacts check; the simulation's independently-guessed definition matches) |
| `slopeTube_zero_eq_tubeSet` | slope 0 = T9's tube | the proven extreme anchors the definition |
| `slopeTube_not_informationSet` | beyond the threshold NO slope works | the failure half of the conjecture is a theorem at every slope (counting is slope-blind) |
| `slope_half_8_3` / `slope_third_8_3` / `slope_twoThirds_8_3` / `slope_half_7_3` / `slope_half_10_4` | slopes 1/2, 1/3, 2/3 decode at the exact threshold (`n = 7, 8, 10`) | kernel-checked sample points of the conjecture's positive half |

**The named open item** (v8): the positive half for general `n` (slope-invariance). Recorded attack: shear `y_i(j) = x_i(j+⌊s·i⌋)` ⟹ time-inhomogeneous alternation of rule-90 and shifted-double steps, parity-staggered sweep depths. **Closed in v9 — §34.**

## 33. The v8 sweep (count-filter note)

Environment-level `collectAxioms` over **1199** theorem/def declarations
(`.thmInfo`/`.defnInfo`, `isInternal` excluded) in **both** namespaces
(`OPH.*` + `OPHProofChain.*`), 33 modules, build 8282 jobs clean:
**0 `sorryAx`, 0 non-standard axioms.** Earlier campaigns quoted counts
under a wider constant filter (e.g. v7's "1480"), so counts are not
comparable across versions; the invariant that matters — CLEAN — is
filter-independent. This note exists so version bookkeeping (holes-audit
F28's genre) cannot recur on sweep counts.

## 34. `Rule90Lipschitz.lean` — T36, the Lipschitz worldline theorem (v9; **the slope conjecture, closed** — holes-audit F6)

| Lean name | Statement (informal) | Reading |
|---|---|---|
| `pairScreen` / `pathScreen` | the adjacent-pair screen along an arbitrary column function / along an integer column path `c : ℕ → ℤ` based at `j₀` | `tubeSet`, `lightTube`, `slopeTube` are all instances (`slopeTube_eq_pathScreen`, `pathScreen_eq_pairScreen`) |
| `pathScreen_fan` | for 1-Lipschitz `c`, at level `k` below the top the closure of the screen covers the integer column interval `[c t − k, c t + 1 + k]` | the engine: downward two-chain fan induction; the 1-Lipschitz bound `|c t − c i| ≤ t − i` is exactly what keeps the level-`i` screen pair inside the level-`(i+1)` interval — the v8 sheared-CA attack dissolves into this |
| **`pathScreen_closure_complete`** | at `n ≤ 2(t+1)` the propagation closure of a 1-Lipschitz worldline screen is the **entire block** | T30b extended from the static observer to *every* causal worldline (zigzags, negative slopes, any speed ≤ 1): full local decodability, not merely determination |
| **`pathScreen_isInformationSet_iff`** | a 1-Lipschitz worldline screen is an information set ⟺ `n ≤ 2(t+1)` | sharp, **uniformly in the path** — the threshold does not see the worldline, only its Lipschitz class |
| **`slopeTube_isInformationSet_iff`** | for `p ≤ q`: the slope-`p/q` screen is an information set ⟺ `n ≤ 2(t+1)` | **the slope conjecture (F6), closed** — every rational slope `0 ≤ p/q ≤ 1`, every `n, t`, every base point; T9 (slope 0) and T18a (slope 1) become corollaries; the v8 instances are sample points |
| `isInformationSet_of_seedRow_inferable` | any screen whose closure reaches the seed row is an information set | the soundness bridge, factored for arbitrary screens |
| **`pairScreen_class_6_2`** | at `(n,t) = (6,2)`, `![a,b,c]` decodes ⟺ `ringDist b c ≤ 1` (216 cases, kernel) | **the complete classification at the first nontrivial size**: only the LAST step matters — order-sensitive (`![0,0,2]` fails, `![0,2,2]` decodes, same step multiset) |
| `pairScreen_slope2_8_3` / `pairScreen_teleport_8_3` | at `(8,3)` the slope-2 line and a teleporting path decode at capacity | Lipschitz is sufficient, **not necessary**: at `(8,3)` ALL `8^4` pair screens decode (sweep: `evidence/path_screen_sweep.txt`) |
| `pairScreen_slope2_fails_10_4` / `pairScreen_late_jump_fails_10_4` / `pairScreen_early_jump_10_4` | at `(10,4)` the slope-2 line and the late 2-jump **fail at exact capacity**; the same jump one step earlier decodes | the `(8,3)` universality is a small-size accident; superluminal screens can drop below capacity; order sensitivity persists at larger sizes |

**What this changes**: v8's "open mathematics" list was {slope positive
half, arbitrary subsets, gap-2 crawl}. The slope item is **closed** — and
strengthened to the full causal-worldline class. What remains is exactly
the arbitrary-subset classification (now with machine-checked walls: no
coarse invariant — step multiset, last step, cardinality — can classify
it) — the gap-2 crawl characterization inside T30 is closed by T37 (§35).

## 35. `Rule90Crawl.lean` — T37, the gap-2 crawl classified (v9; closes T30's named leftover)

| Lean name | Statement (informal) | Reading |
|---|---|---|
| `gapTwo_middle_inferable` | the middle column is inferable at every time ≥ 1 | the screen's columns *enclose* it — one downward rule per cell; the crawl's fuel |
| `gapTwo_left_pair` / `gapTwo_right_pair` | the columns `{j₀, j₀+1}` and `{j₀+1, j₀+2}` are inferable adjacent pairs on `[1, t]` | the anchors for T36's general fan — *inferred* anchors, not screen cells: exactly why `inferable_fan_of_pairs` was stated for arbitrary screens |
| `gapTwo_row1` | at `n ≤ 2t + 1` **row 1 is fully inferable** | union of the two pair-fans, width `2t + 1`; **no parity hypothesis** — the parity obstruction lives strictly in row 0 |
| `gapTwo_crawl` | row-0 columns at even offsets are inferable, unboundedly | the simulation's crawl verbatim: two columns per step, one row-1 cell consumed per step, seeded by the screen's own row-0 cells |
| **`gapTwoTube_closure_complete_odd`** | odd `n ≤ 2(t+1)`: the closure of the gap-2 screen is the **entire block** | `2·(m+1) ≡ 1 (mod 2m+1)` wraps the crawl around the ring; `oph_sim/FINDINGS.md` item 1, now a theorem |
| `gapTwo_information_set_via_propagation` | odd rings at threshold: the gap-2 screen is an information set, through the closure | T25's odd `g = 2` half re-derived by propagation — the crawl IS a decoder (the same upgrade T30b gave T9) |
| **`gapTwoTube_closure_incomplete_even`** | even `n`: the closure never reaches the whole seed row, at any horizon | T25's parity negative + soundness; the crawl stalls exactly where decoding fails |
| **`gapTwo_closure_complete_iff_odd`** | at the sharp threshold: closure complete ⟺ `n` odd | **the distance-2 classification.** With T30 (`d = 1` complete, `d ≥ 3` nothing), local decodability of two-column screens is classified at every ring distance |

## 36. The v9 sweep

Environment-level `collectAxioms` over **1235** theorem/def declarations
(same filter as §33) in **both** namespaces, **35 modules**, fresh
`lake build` 8284 jobs clean: **0 `sorryAx`, 0 non-standard axioms.**

