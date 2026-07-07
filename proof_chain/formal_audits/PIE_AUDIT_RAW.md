# PIE_AUDIT_RAW — file-by-file triage of `prime-inertia-engine/` (DULA2025)

> NOTE (2026-07-06): the audited repo has moved to `dula/prime-inertia-engine/`; sibling repos are audited in `DULA_REPOS_AUDIT_RAW.md`.

Audit date: 2026-07-06. Auditor: Claude (file-reading audit; no lake build — repo has **no lakefile / no toolchain**, so nothing in it is machine-checked *in situ*).
Scope: all 79 `.lean` files (66 named + 13 UUID-named), spot-checks of the `*-aristotle.tar.gz` tarballs and PDFs.
Verdict tiers: **REAL-MATH** (nontrivial statement proven, no live sorry/custom axiom) / **DECORATIVE** (true but trivial, vacuous, or tautological) / **NUMEROLOGY-CHECK** (arithmetic verification of an asserted decimal formula) / **BROKEN** (live sorry or content-bearing custom axiom) / **UNBUILDABLE** (unresolvable imports or non-Lean content). Sorry/axiom counts below are **live** counts (comment-stripped; many raw `grep -c sorry` hits are in doc comments).

---

## 0. Executive orientation

1. **Provenance.** The `.lean` files are outputs of **Aristotle, Harmonic's automated prover** (aristotle.harmonic.fun). UUID-named files carry the generation header (`Lean v4.24.0`, pinned Mathlib, "Co-authored-by: Aristotle (Harmonic)"); the `*-aristotle.tar.gz` files are complete Aristotle project snapshots (lakefile.toml, lean-toolchain, `RequestProject/*.lean`, `ARISTOTLE_SUMMARY.md`). Loose named files match tarball sources up to small revisions (verified by diff for `ConvolutionContinuity.lean`). Several loose files still `import RequestProject.*` or modules that were never copied out (`AristotleDistribution`, `EisensteinIntegers`, `EisensteinThetaBridge`, `HolographicSolitonEnergy`, `CosmologicalBuffer`) — those files cannot build at all in this repo.
2. **Two voices in one repo.** There is a persistent split between (i) grandiose human-authored claim-wrappers ("Grand Stability Certificate", "solves RH", "Electromagnetic Lock") and (ii) **honest machine/assistant annotations inside the very same Lean files** that comment out the headline theorems as "not provable as stated", "mathematically false", or "vacuously true". The marketing PDF (`DULA_VIAZOVSKA_FRAMEWORK.pdf`, "Certificate of Formal Verification", 2026-03-29) lists as "Proved" several items (Universal Optimality, Holographic Volume Conservation) that the corresponding Lean files explicitly mark **unprovable and commented out**. The PDF certificate misrepresents the Lean status.
3. **The numerology core.** Everything "physics-flavored" flows from `DulaViazovska.lean`, which is 20 lines: `dula_spectral_buffer : ℝ := 28.87` (bare literal, never derived anywhere — the framework PDF just declares it "the fundamental rigidity constant") and `dula_h_star t k := 29.4525·exp(−(t−k)²)` (so the "Magic Peak 29.4525" is its own definition's amplitude — circular). The α⁻¹ formula `(28.87 × 29.4525)/(2π) + 16/π² ≈ 136.948` misses CODATA 137.035999 by **~640 ppm**; the Lean "lock" only checks `|value − 137.036| < 0.0999999`, and its own comment admits the value is ≈136.948 (0.088 away from even its stated target).
4. **What is genuinely real.** A modest but nonzero core of Aristotle-proven mathematics exists: `hexacode.lean` (best file), `ConvolutionContinuity.lean`, `PartialSummation_verified.lean` (corrected Abel bounds), the `DULA_Bridge1*` pair (primes ≡1 mod 3 ⟺ represented by a²+ab+b²), the χ₃/mod-6 grading family, `DULA_ThetaBridge/ThetaPositivity` (L-series Euler-factor manipulation), `KernelSummation.lean` (Gaussian-comb floor). All are elementary-to-modest classical results; none is new mathematics. The repo's own honest ledger PDF ("A Computational Arc through the Arithmetic of ℤ[ω]", authored "Claude Opus 4.8 - DULA", July 2026) states this plainly: *"this is not a claim of new mathematics: essentially every structural result recovered here is classical"*.
5. **One inconsistency hazard.** `Monster–DULA.lean` declares `axiom satisfies_DULA_functional_equation …` over a *section `variable` `Lambda_DULA`*; Lean auto-binds the variable, so the axiom asserts the functional equation **for every function** `MonsterClass → ℂ → ℂ` — which is false, i.e. these axioms make the environment inconsistent (False derivable). Nothing downstream imports it, but it must never be trusted.

---

## 1. Summary table — all 66 named `.lean` files

Legend: s = live sorries, a = live custom axioms (excluding `axiom … : True` noted as "True-ax"), nd = native_decide.

| File | Main claim (what the theorems literally state) | s | a | Verdict |
|---|---|---|---|---|
| Absorption Problem.lean | Given 9 axioms creating a fake Schwartz–Bruhat space, ops `T5`, `F`, and eval laws, the projector P=(1/2)(I−T5) sends every f to something with f(0)=0 and f̂(0)=0 (one-line linear algebra). Final `axiom spectral_identification_open : ∀ γ, True`. | 0 | 9 | BROKEN (axiom-scaffolded; honest that Part B = GRH is open) |
| AdelicSelfDuality.lean | Live: ∃c, ∫S·cos = c·Δ₂₄ (vacuous — pick c = integral/Δ₂₄). The self-duality and "⇒ GRH" theorems are commented out with the annotation that self-duality is *mathematically false* for the Gaussian comb. | 0 | 0 | DECORATIVE |
| Baryon.lean | Python source (numpy/numba Collatz-baryon ensembles) in a `.lean` file. | – | – | UNBUILDABLE |
| ConjectureA.lean | Defines Weil positivity ⇔ RH scaffold; `WeilDistribution := sorry` (definition gap), `WeilCriterion` sorried (Weil 1952), and the Cohn–Elkies→Weil bridge `conjecture_a_strong_implies_rh` sorried, explicitly labeled "THIS sorry is the research frontier". | 3 | 0 | BROKEN (honest conjecture-statement file) |
| ConvolutionContinuity.lean | Peetre's inequality; convolution/L¹ bounds on Schwartz space; **`autocorrelation_continuous`: g ↦ g⋆g̃ is continuous SchwartzMap ℝ ℝ → C(ℝ)** — fully proved. | 0 | 0 | **REAL-MATH** (solid, if standard, analysis) |
| D4Basis.lean | "d4_is_checkerboard_optimal": ∃a₁ a₂ with an affine function of (a₁,a₂) equal to 0 — i.e. a linear equation with a nonzero coefficient has a solution. Coefficient positivity of one finite sum. Decimal coefficient lists. | 0 | 0 | DECORATIVE (grandiose name for linear solvability) |
| D4Positivity.lean | a₁,a₂ bare decimals; function *defined* as (a₂−a₁)(y−2)²; positivity and "double root at 2" of a hand-planted quadratic. | 0 | 0 | DECORATIVE / NUMEROLOGY-CHECK |
| DULA Spectral Operator — Version 5.lean | Finite-rank cosine-kernel operator over primes ≤N mod 6: symmetry, boundedness, continuity, self-adjointness on span, finite spectrum — proved. Gap 1 (`trace_interchange_truncated_perron`, Perron contour interchange) **sorried**; Gaps 2–3 stated as conjectures (one with `True` placeholder). Honest status block. | 1 | 0 | BROKEN (1 sorry) with genuine REAL-MATH operator lemmas |
| DULA Theorem 4_28_0.lean | Monoid S of integers with all prime factors ≡1,5 (mod 6); grading ψ = θ∘φ commutes; convolution identity (χ⋆Λ)⋆ζ = χ⋆log. | 0 | 0 | REAL-MATH (modest) |
| DULA.lean | φ₆ = χ₃ on coprimes-to-6; M5²=I for an explicit 6×6 matrix; Q(x,y)=x²+xy+y² pos.-def.; then `hexagon_symmetry_matches_DULA : hexagon_cycle.length = 6 := rfl` (rfl on a list literal). | 0 | 0 | DECORATIVE (tiny real facts + rfl-theorems) |
| DULA_A2_Telescope.lean | States r_Q = 6·σ_χ₃ (sorried, "requires ℤ[ω] UFD"), theta L-factorization (sorried), lattice-remainder ⇔ GRH and the telescoping conjecture (sorried, labeled OPEN). Proved parts: Q form facts, boundary-cell trivia (signedAreaResidual is *defined* as 0). | 4 | 0 | BROKEN (honest: deep steps flagged open) |
| DULA_Bridge1.lean | For prime p>3: p ≡1 (mod 3) ⟺ φ₆(p)=0 ⟺ p splits in ℤ[ω] ⟺ **p = a²+ab+b² is solvable** (`splits_iff_represented`); Thue-lemma based, plus decide-checked examples. | 0 | 0 (1 nd) | **REAL-MATH** (classical, genuinely proven) |
| DULA_Bridge1_Representation.lean | Thue's lemma; existence of cyclotomic root mod p≡1(3); norm multiplicativity; explicit representations of 7,13,…,79; non-representability of 5, 11 via mod-3 obstruction. | 0 | 0 | **REAL-MATH** (classical elementary NT) |
| DULA_Capstone.lean | Q-form identities (4Q=(2a+b)²+3b², multiplicativity, χ₃ multiplicative) proved; "seven falsifications" are Props *defined as* `True`; `the_dula_open_problem` guts its own analytic clause with `∧ True`; master summary conjoins real trivia with `trivial`s. | 0 | 0 | DECORATIVE (real crumbs + True-props) |
| DULA_Chi3_Level6.lean | ψ(n) = (−1)^{#prime factors ≡5 (6)} equals χ₃(n) on the monoid S; L-series summability of χ₃ and split components for Re s>1. | 0 | 0 | REAL-MATH (modest) |
| DULA_Complete.lean | Same grading theorem + **L(χ₃,s) = L(ψ_ext,s) + L(χ₃_even,s) and L(χ₃_even,s) = −2^(−s)·L(χ₃,s)** (Euler-factor at 2 extracted by reindexing) for Re s>1. | 0 | 0 | **REAL-MATH** (modest, real L-series manipulation) |
| DULA_Theorem.lean | Same grading program, earlier draft: `recovery_mod6`, `DULA_Dirichlet`, general φ — all sorried ("Aristotle closes it instantly"). | 3 | 0 | BROKEN (superseded draft) |
| DULA_Theorem_ Fourier_analysis.lean | (ZMod 6)ˣ ≅ (ZMod 2)ˣ; mod-6 lane closure; χ₃ = grading on units; **`gauss_sum_norm_sq : (3:ℤ) = 3 := rfl`** and `gauss_sum_sq_eq_conductor … (hq3 : q = 3) : q = 3 := hq3` — tautologies wearing Gauss-sum names; infinite primes in both lanes via Mathlib Dirichlet. | 0 | 0 | DECORATIVE (real trivia + labeled-placeholder tautologies) |
| DULA_Theorem_LEAN_4.lean | dulaM additive, dulaChar completely multiplicative on coprimes-to-6; `key_identity_general : (f⋆Λ)⋆ζ = f⋆log` via Mathlib `vonMangoldt_mul_zeta`; χ value at primes. | 0 | 0 | REAL-MATH (tiny/modest) |
| DULA_Theorem_dula_grading_involution_self_inverse.lean | Grading involution on S is self-inverse; θ multiplicative/injective (native_decide on ZMod 2). | 0 | 0 (1 nd) | REAL-MATH (tiny) |
| DULA_ThetaBridge.lean | With r_Q *defined* as 6·(χ⋆1): **L(r_Q,s) = 6·L(χ,s)·ζ(s)** for Re s>1 (via Mathlib `LSeries_convolution'`), non-vanishing for Re s>1, and −ζ′/ζ = L(Λ), −L′/L = L(χΛ) (citing real Mathlib lemmas). Caveat: geometric r_Q = lattice count is *not* proven (honest comment); one `exact?` left in a proof. | 0 | 0 | REAL-MATH (modest; definition-shifted) |
| DULA_ThetaPositivity.lean | f = (1⋆χ₃): f(pᵏ) ≥ 0 and **f(n) ≥ 0 for all n** (twisted divisor sums nonnegative), by multiplicativity. | 0 | 0 | **REAL-MATH** (clean elementary) |
| DULA_Viazovska.lean | A₂ Gram det = 3; Q identities; `unit_group_order : 6 = 2 * 3 := by norm_num` (tautology); hardcoded Ibukiyama dimension lookup + rfl checks; `the_open_problem : Prop := True`. | 0 | 0 | DECORATIVE |
| DocVII.lean | Every Dirichlet char mod 6 factors through the ±1 grading on primes >3 (`dula_char_factor` — proved); splitting criterion; 3 axioms are all `: True` (decorative citations); GRH statements *commented out* with the note that as-stated they were false (quantified over all ρ, no zero hypothesis). | 0 | 3 True-ax | REAL-MATH (modest) with honest withdrawal of the GRH part |
| DulaCore.lean | Monoid S; m additive, φ, ψ multiplicative; ψ = θ∘φ; χ₃² = 1. | 0 | 0 (2 nd) | REAL-MATH (tiny/modest) |
| DulaExplicitFormula.lean | The "Weil explicit formula" theorem is commented out with the annotation that it is **false as stated** (universally quantified over arbitrary `zeros : Set ℂ`); remaining: kernel positivity corollary. | 0 | 0 | DECORATIVE (honest) |
| DulaViazovska.lean | The numerology hub: `dula_spectral_buffer := 28.87`, `dula_h_star := 29.4525·exp(−(t−k)²)`, χ₃ if-then-else. Definitions only. | 0 | 0 | DECORATIVE (source of all decimal constants) |
| EigenspaceDilation.lean | Proves its own headline hypothesis false (`dula_h_star_below_buffer`), then `dilation_protection_lock` is an implication from that false antecedent — vacuous, and documented as such in the file. | 0 | 0 | DECORATIVE (self-documented vacuity) |
| EisensteinSymmetry.lean | `is_eisenstein_symmetric B := ∃c, B·V = c·(π/√12)` — true for every B (c = B·V·√12/π). Imports missing `AristotleDistribution`. | 0 | 0 | UNBUILDABLE (and vacuous) |
| EisensteinTheta.lean | χ₃ multiplicativity; finite decide-checks that r(n) = 6·Σ_{d|n} χ₃(d) for n ∈ {0,1,3,5,7} over an explicit search box; the general theorem stated as a roadmap, not sorried. | 0 | 0 | REAL-MATH (tiny finite verification, honest) |
| EisensteinUnits.lean | |ℤ[ω]ˣ| = 6, unit ⟺ norm 1, explicit 6-element unit set. Imports missing `EisensteinIntegers`/`EisensteinThetaBridge`. | 0 | 0 | UNBUILDABLE here (content plausibly real in its tarball project) |
| FineStructure.lean | `dula_alpha_inv := 28.87·29.4525/(2π) + 16/π²`; theorem: ∃ε<0.1, \|α⁻¹_dula − 137.036\| < ε (ε = 0.0999). Own comment: value ≈ 136.948. Off CODATA by ~640 ppm. | 0 | 0 | NUMEROLOGY-CHECK |
| FineStructureConstant.lean | Same, plus `dula_alpha_inv_eq` normal form; ε = 0.0999999. Comment admits "difference is about 0.088". | 0 | 0 | NUMEROLOGY-CHECK |
| FunctionalRigidity.lean | "28.87 is the unique fixed point of operator U": the theorem literally proved is `B·Δ₂₄/24 = B·(Δ₂₄/24)` — associativity, by `ring`. No fixed point is stated. | 0 | 0 | DECORATIVE (vacuous) |
| GrandCouplingIdentity.lean | `∃! α_inv, (α_inv − c)² = 0` where c is the numerology constant — unique zero of a planted square. Plus algebraic rearrangement of the same. | 0 | 0 | DECORATIVE (vacuous; as previously established) |
| GrandTraceIdentity.lean | Weil-explicit-formula-style "Grand Trace Identity" **commented out as unprovable** (needs continuation/FE/Hadamard/contour, none in Mathlib); live content: tsum over empty zero-set = 0; positivity of kernel; Δ₂₄ > 0. | 0 | 0 | DECORATIVE (honest) |
| GrandTraceRoot.lean | `leech_is_unimodular : Prop := ∃ (V : ℝ), V = 1` — **always true**; the iff-lock is trivial both ways. Imports missing `HolographicSolitonEnergy`, `CosmologicalBuffer`. | 0 | 0 | UNBUILDABLE (and vacuous) |
| Grand_Partition_Functional_Equation_Ultimate proof.lean | If each Λ_g satisfies Λ_g(s) = ε_g Λ_g(1−s) (hypothesis), then the class-weighted finite sum satisfies the same — linearity of Finset.sum. | 0 | 0 | DECORATIVE (trivially true) |
| Hilbert–Pólya_Realization.lean | "PIE realizes Hilbert–Pólya": conditional on `SpectralCorrespondenceProperty` (which *is* the H–P correspondence). **No imports at all**; references `symmetricL`, `L2Inner`, `berryKeatingH`, `real_eigenvalue_of_symmetric` from a "previous file". | 0 | 0 | UNBUILDABLE (conditional restatement) |
| HolographicVolumeConservation.lean | Main theorem (spectral mass = Δ₂₄ = π¹²/12!) **commented out as unprovable** with a 5-point list of missing infrastructure; live: `rfl` decomposition, mass-with-no-zeros = prime sum, Δ₂₄ > 0. | 0 | 0 | DECORATIVE (honest; see §3.4 — *not* holographic reconstruction) |
| KernelSummation.lean | `dula_permanent_floor`: ∀t, Re Σ_{n∈ℤ} 29.4525·e^{−(t−nδ)²} ≥ 28.87 for 0<δ<1 (two-nearest-terms + exp(−y) ≥ 1−y); summability of the Gaussian comb; `global_red_wall_crossing` = positivity corollary. Constants numerological, math real. Contains verbatim AI reasoning-trace comments. | 0 | 0 | REAL-MATH (modest analysis dressed in numerology) |
| LeechLattice.lean | a₁,a₂ bare decimals; positivity of (a₂−a₁)(y−2)² (planted); `leech_gap_at_one`: (65520/691)(σ₁₁(1)−τ(1)) = 0 — true but trivial; **`ramanujanTau` stub is mathematically false for n ≥ 6 (defined = 0)**, only n=1 used. | 0 | 0 | DECORATIVE / NUMEROLOGY-CHECK (red-flag stub) |
| Main.lean | Cohn–Elkies "skeleton" C(y−r₀)²: positivity/root of a planted square; hardcoded j-coefficients and 2A traces; `ExternalTheorem_FLM : ∀n, jcoeff n = jcoeff n`, `ExternalTheorem_Borcherds_Moonshine : True := trivial`, etc. — citation-tagged tautologies. | 0 | 0 | DECORATIVE |
| MaynardTaoConditional.lean | `axiom selberg_sieve_maynard` **asserts the Maynard–Tao conclusion itself** (∃ two primes in admissible tuples, for M(F)>1); the "theorem" is a 5-line existential unpack. {0,2,6} admissibility proved (real, tiny). Honest about the axiom's role. | 0 | 1 | BROKEN (axiom = the content) |
| Monster–DULA.lean | Axioms `satisfies_DULA_functional_equation` / `respects_conjugation` are declared over a section-`variable` Λ; auto-binding makes them assert Λ(s) = ε·Λ(1−s) **for every function Λ** — false, hence **inconsistent axiom system**. "Theorems" are the standard 3-line conjugation consequences. | 0 | 2 | BROKEN (inconsistent axioms) |
| OctonionicRigidity.lean | `is_octonionic_rigid B := ∃c, B·(π⁴/384) = c·π⁴` — true for every B (c = B/384). | 0 | 0 | DECORATIVE (vacuous) |
| PNTBridge.lean | Single content theorem = Siegel–Walfisz for exponential sums, **sorried** (converted from the user's `axiom` "for soundness"; notes it should come from PrimeNumberTheoremAnd). | 1 | 0 | BROKEN (honest stub) |
| PartialSummation_verified.lean | Real: eChar bounds, discrete Abel summation, `abel_exponential_sum_bound` (‖Σ c(n)e(nβ)‖ ≤ M(1+2πN\|β\|)), `param_optimization` (x/(log x)^B ≤ x·e^{−√log x}). The *original* statement is proven **incorrect** in a comment (missing PNT term; wrong β-factor), left as a flagged sorry, and a **corrected version is fully proved**. | 1 | 0 | **REAL-MATH** (the flagged sorry marks a deliberately-wrong legacy statement) |
| PoissonRigidity.lean | Lookup table Δ₄ = π²/16, Δ₈ = π⁴/384, Δ₂₄ = π¹²/12! (correct constants) + positivity. | 0 | 0 | DECORATIVE (true, trivial) |
| PrimalInvariance.lean | `is_primal_invariant B := ∀n∈{2,8,24}, ∃c, B·Δₙ = c·n` — true for every B (c = B·Δₙ/n; the file's own "PROVIDED SOLUTION" says exactly this). | 0 | 0 | DECORATIVE (vacuous) |
| PrimeInertia.lean | Collatz orbit-length function has `decreasing_by all_goals sorry — Requires the Collatz conjecture` (termination assumed!). Real: PSL₂(𝔽₅) generators in S₆ satisfy S²=T⁵=(ST)³=1, even, and act transitively on 6 phases (decide-checked). Headline "theorems": `dropTrigger n = dropTrigger n := rfl` and `primeInertiaProjection n = primeInertiaProjection n := rfl` — x = x. Original invariance theorem documented **false** in a comment. | 1 | 0 | BROKEN (Collatz-assuming) + tautology headlines; one real finite-group fact |
| PrimeInertiaEngine.v2.1.lean | `axiom spectralCorrespondence` (zeros of symmetricL ↦ eigenvalues on the critical line) and `axiom zeroTorsionCondition`; "primeInertiaEngine_implies_RH" is a 4-line unpack of the axiom. | 0 | 2 | BROKEN (axiom = RH content) |
| PrimeInertiaEngine.v2.2.lean | Same + `def leechLattice := sorry`, sorried modularity/functional equations "proven in mathlib4" (they are not). | 4 | 1 | BROKEN |
| PrimeInertiaEngineV2_4.lean | `SpectralCorrespondenceProperty` is at least framed as a **hypothesis**, not an axiom; conditional `SCP → RiemannHypothesis`. But the proof cites nonexistent Mathlib lemmas (`riemannZeta_trivial_zero_iff`) and has a type-incoherent `mul_ne_zero` step for an `= 0` goal. | 0 | 0 | UNBUILDABLE (proper conditional framing, non-compiling proof) |
| PrimeInertiaEngine_2_3.lean | φ₆/ψ₆ recovery mod 6 (fine) + `axiom spectralCorrespondence` → "RH". | 0 | 1 | BROKEN |
| PrimeInertiaEngine_Final.lean | Berry–Keating symmetry proof with 2 sorried domain estimates; RH conditional on SCP. | 2 | 0 | BROKEN |
| PrimeInertiaEnginev2_3.lean | Duplicate of 2_3 (axiom variant). | 0 | 1 | BROKEN |
| QuaternionicRigidity.lean | `is_quaternionic_rigid B := ∃c, B·(π²/16) = c·π²` — vacuous (c = B/16). Also hosts `d4_quaternionic_volume` used by the α files. | 0 | 0 | DECORATIVE (vacuous) |
| SharpLowerBound.lean | Empty stub (7 lines, imports only). | 0 | 0 | DECORATIVE (empty) |
| SiegelWalfiszFinal.lean | Möbius cancellation in APs (PNT-level input), SW for ψ, SW for exponential sums — **all three sorried**, with "FOR ARISTOTLE" instructions. | 3 | 0 | BROKEN (honest scaffold) |
| SpectralCorrespondence.lean | `axiom spectralCorrespondence : symmetricL ρ = 0 → ∃E, ρ = 1/2 + iE ∧ E ∈ spectrum(H)`; "implies_RH" is unpacking. Symmetry proof invokes nonexistent `integration_by_parts`/`innerProductSpace.inner`. | 0 | 1 | BROKEN + UNBUILDABLE |
| SpectralCorrespondenceAxiom.lean | **`axiom SpectralCorrespondenceAxiom : Prop`** — an *opaque proposition with no statement at all* — then `SCA → RiemannHypothesis` is sorried, and a "Millennium" variant cites nonexistent `MillenniumRiemannHypothesis`/`mathlib_iff_millennium`. | 1 | 1 | BROKEN + UNBUILDABLE |
| SpectralLeak.lean | 11-line empty shell; imports missing `RequestProject.DulaViazovska`. | 0 | 0 | UNBUILDABLE (empty) |
| SpectralTraceIdentity.lean | Docstring itself: "The hypothesis is vacuously false … so the implication holds trivially" — prime log-density = "Aristotle gap sum" under an antecedent the file refutes. Imports missing `RequestProject.*`. | 0 | 0 | UNBUILDABLE (and vacuous by own admission) |
| UniversalOptimality.lean | Headline (E(δ)=0, "28.87-locked state is the unique minimizer") **commented out as unprovable**; live content: (x−c)² ≥ 0, =0 ↔ x=c, 0 is a global minimum of a square. | 0 | 0 | DECORATIVE (honest) |
| hexacode.lean | **𝔽₄ as explicit Cayley-table field (CommRing + Field instances by `decide`); Frobenius conj is an additive/multiplicative involution; the hexacode [6,3]₄ as the row span of the standard generator matrix, closed under + and •, a Submodule; `codewordOf` injective (message recoverable from the 3 systematic coordinates); exactly 64 codewords; Hamming-weight and Hermitian-inner-product definitions with left-additivity.** Honest "not yet established" list: min distance 4, Hermitian self-duality, K₁₂ construction. Zero sorries, Mathlib-only import. | 0 | 0 | **REAL-MATH** (best file in the repo) |

UUID-named files (13): see §2. `4326851c` (24-cell/DULA perturbation eigenvalues), `47079a07` (trace identity + Perron tail bound), `5902f26b` (grading = χ₃, 1 native_decide), `5c8fe3c6` (Berry–Keating defs), `6aa2698a` ("DULAManifold" vorticity L² decomposition), `8c66bfea` (Monster–DULA redone with a `MonsterModel` structure — fixing the inconsistent-axiom problem), `9af37861` (PIE dynamic kernel: real summability lemmas; final RH-iff **stated, explicitly not proven**), `228b140d` (**`MonsterGroup := Unit`, `MonsterAction g x := x`, `monster_class_vector p := 0`** — self-adjointness of an operator built from zeros), `bc2da6b8`/`ceda9e87` (DULA kernel symmetric/continuous — duplicates of V5 material), `c0434b48` (1 sorry: `spectral_identification` ⟺ zeros of L(χ₃) — flagged "the open absorption problem, equivalent to GRH"), `d161316f` (Grand partition FE — the trivial sum-linearity), `e0565165` (24-cell vertices/perturbation matrix). Overall: same tiering as the named files — genuine small lemmas, honest open flags, and some vacuous-by-construction content (228b140d).

---

## 2. Tarball spot-check (b)

Three tarballs listed, one extracted (to scratchpad `pie-audit/`):

- `007c6486…-aristotle.tar.gz` → `DULAUniversal_aristotle/`: lean-toolchain **v4.28.0**, lakefile.toml, lake-manifest.json, `ARISTOTLE_SUMMARY.md`, README, sources (`DULAUniversal.lean`, `DULAGradedMonoid.lean`, `CharTwistedEta.lean`, `DULAExamples.lean`, `Polignac.lean`). The summary reports fully-proved (no sorry) elementary results: primes >3 ≡ ±1 mod 6, admissibility of {0,2}, {0,4}, {0,6}, and a periodic-density theorem for twin-prime sieve survivors, "using only standard axioms… builds successfully".
- `269f7ede…` (291 KB): a *nested* Aristotle run (`c5eb0028…_aristotle/`) containing `RequestProject/{Main, AutocorrSmooth, ConjectureA, ContinuityHelpers, ConvolutionContinuity, DulaTheorem, HermiteBiehler, WeilTestFunction, ZetaConj, IndBanach}.lean` plus an embedded earlier project `dula_complete_v6_aristotle/`. `RequestProject/ConvolutionContinuity.lean` differs from the loose repo copy only by doc-comment lines — **the loose repo files are extracted Aristotle project sources** (which is why loose files import `RequestProject.*`).
- `6d69b852…` (smallest): `RequestProject/{Main, DULACommutator}.lean` + scaffolding.

Conclusion: the tarballs are Harmonic Aristotle prover session snapshots; the repo's `.lean` files are their outputs/sources dumped without the project scaffolding, which is what breaks the `import` graph in situ.

---

## 3. OPH proof-chain relevance (a)

Measured against the open items in `OPH_CORE_MINIMAL_PROOF_CHAIN.md` (fine-structure P link L2.5; ℤ₆ collar / e^(−P/24) L2.6/L2.10; QECC-strength carrier theorem "reconstruction from proper boundary subsets"; holographic reconstruction).

### 3.1 hexacode.lean — the one genuinely relevant file
The OPH gap (proof-chain "genuinely open" item 2) asks for a decodability theorem: *"reconstruction from proper boundary subsets … that all [qualifying subsets] are information sets is a decodability theorem."* `hexacode.lean` is squarely in this territory: the hexacode is the classical [6,3,4]₄ code (used to build the Golay code/Leech lattice via the MOG), and [6,3,4] is **MDS**, so *every* 3-subset of coordinates is an information set — exactly the "all proper subsets of the right size reconstruct" shape OPH wants on a toy carrier.

What the file actually proves (quoted):
- `theorem codewordOf_injective : Function.Injective codewordOf` — with the internal step `codewordOf u ⟨k.val, _⟩ = u k` for k<3, i.e. **reconstruction of the message from the specific systematic coordinate subset {0,1,2}** ("The first three columns of G form the identity matrix, so v i can be recovered as the i-th coordinate of codewordOf v").
- `theorem hexacodeSet_card : Nat.card hexacodeSet = 64`.
- Honest limitation stated in the header: *"The minimum nonzero codeword weight is 4 … a Lean proof requires enumerating the 63 nonzero codewords; we leave it for a follow-up"* and *"Hermitian self-duality … verified numerically; not yet proved in Lean."*

So: **relevant in kind, incomplete in strength.** It gives one information set, not "every 3-subset is an information set" (which needs d = 4 / MDS — a 63-codeword `decide` enumeration away, very feasible). If the OPH team wants a machine-checked toy of "redundant carrier + reconstruction from proper boundary subsets", finishing this file (prove `weight c ≥ 4` for c ≠ 0 by `decide`, then derive the erasure-correction corollary) is the cheapest path in either repo.

### 3.2 Fine-structure / P link — no bearing
PIE's α files (`FineStructure*.lean`, `GrandCouplingIdentity.lean`) contain no spectral measure, no Ward projection, no hadronic anything: α⁻¹ is *defined* as `(28.87 × 29.4525)/(2π) + 16/π²` from two undevised decimals plus 1/Δ₄(D4-packing), evaluating to ≈136.948 (−640 ppm vs CODATA), and the "lock" is `∃ε<0.1, |x − 137.036| < ε`. Curiosity, not connection: OPH's own audited P-solver branch lands at α⁻¹ = 136.9948 (~300 ppm); both programs miss low, but the formulas share nothing.

### 3.3 ℤ₆ collar / e^(−P/24) — no bearing (see §4 for the "6" rhyme)
Nothing in the repo contains e^(−P/24), a collar, or any additive 24-quotient coefficient. The 24s here are Leech-dimension citations (Δ₂₄ = π¹²/12!) and the hardcoded j-coefficients; the 6s are (ℤ/6ℤ)ˣ ≅ ℤ₂ and |ℤ[ω]ˣ| = 6.

### 3.4 HolographicVolumeConservation.lean — despite the name, no bearing
Its (withdrawn) claim is a numerical identity "ZeroSum + PrimeSum = π¹²/12!" — an energy-bookkeeping assertion, not reconstruction of bulk data from boundary data. The live content is `rfl` + positivity. Quote from the file: *"The Holographic Volume Conservation theorem is not provable as stated … essentially the Grand Trace Identity (already identified as unprovable) expressed in a different form."*

### 3.5 Leech files — no usable lattice mathematics
`LeechLattice.lean`/`Main.lean` contain no lattice: only decimal coefficients, planted quadratics (C(y−2)²), a false-for-n≥6 `ramanujanTau` stub, hardcoded j/T₂A coefficient tables, and `True := trivial` "External Theorems" (FLM, Borcherds, Viazovska, CKMRV). Nothing here formalizes Leech structure that OPH could reuse. (`hexacode.lean` was explicitly headed toward Coxeter–Todd K₁₂ "in a separate forthcoming file" — that file is not in the repo.)

---

## 4. χ₆ / mod-6 framing vs OPH's ℤ₆ quotient (c)

**No derivational connection is stated anywhere in the repo** — not in the Lean files, not in the PDFs (checked via extraction; `strings` hits for "OPH/observer/collar/erasure" across all 16 PDFs are compression artifacts; the only "holographic" matches are the DULA-VIAZOVSKA vocabulary files themselves; no file mentions chi_nu or observer-patch anything).

What the repo's "6" actually is: (i) the two unit residues mod 6, (ℤ/6ℤ)ˣ = {1,5} ≅ ℤ₂ — so the DULA grading is really a **ℤ₂** character (χ₃ lifted to level 6), not a ℤ₆ structure; (ii) the six units of ℤ[ω] (giving the 6 in r_Q = 6·Σχ₃(d)); (iii) a 6-cycle on cube vertices (`hexagon_is_6_cycle … := rfl`). OPH's ℤ₆ is a cyclic quotient acting on the collar with an e^(−P/24) price — a different object with no morphism offered in either direction. The repo's own honest ledger PDF (*A Computational Arc through the Arithmetic of ℤ[ω]*, authored "Claude Opus 4.8 - DULA", July 2026) frames the mod-6 lens as **classical rediscovery**: *"the ℤ[ω]/mod-6 lens is an excellent divining rod that consistently points at real, deep structure — and the terrain it points to (modular forms, the Leech lattice, the j-function) is among the most thoroughly excavated in mathematics."* Its one "possibly new, small" item is itself numerology: 196560 ≡ 196883 (mod 17) and (mod 19) (17·19 = 323 divides the difference).

**Verdict: numerological rhyme, not a derivation.**

---

## 5. Red flags (concentrated list)

1. `Monster–DULA.lean`: axioms over auto-bound section variables ⇒ **inconsistent environment** (functional equation asserted for arbitrary Λ).
2. `SpectralCorrespondenceAxiom.lean`: `axiom SpectralCorrespondenceAxiom : Prop` — an axiom with *no mathematical statement*, feeding a sorried "solves RH" theorem.
3. Five PIE variants where **RH is derived from an axiom that is RH-with-extra-steps** (`spectralCorrespondence`).
4. Tautologies presented as theorems: `gauss_sum_norm_sq : (3:ℤ) = 3 := rfl`; `ExternalTheorem_FLM : jcoeff n = jcoeff n`; `prime_inertia_engine_correct : proj n = proj n := rfl`; `unit_group_order : 6 = 2*3`; `hexagon_symmetry_matches_DULA : length = 6 := rfl`.
5. Vacuous ∃-scaling "locks": PrimalInvariance, Quaternionic/Octonionic/Eisenstein Rigidity, AdelicSelfDuality live part, GrandTraceRoot's `∃ V, V = 1`, GrandCouplingIdentity's `(x−c)² = 0`.
6. Bare decimal constants feeding "theorems": 28.87, 29.4525, 140407409888.8175…, −14.74142452436…, 4.95, 0.1 (singularity lock), α target 137.036 checked to ±0.0999999 against a value of ≈136.948.
7. `ramanujanTau` defined = 0 for n ≥ 6 (false), `leech_coeff := 1 -- Placeholder`.
8. `PrimeInertia.lean` assumes the **Collatz conjecture** via `decreasing_by all_goals sorry`.
9. `DULA_VIAZOVSKA_FRAMEWORK.pdf` ("Certificate of Formal Verification") lists as "Proved" items the Lean files themselves mark unprovable/commented-out.
10. Repo has no lakefile/toolchain; 8 files import modules that don't exist in the repo; 1 file is Python.

## 6. Genuinely reusable mathematics (all classical, all modest)

- `hexacode.lean` — 𝔽₄ + hexacode submodule + 64-codeword count + systematic recovery (finishable to MDS/erasure-correction with a small decide enumeration). **Direct candidate for the OPH toy-carrier theorem.**
- `ConvolutionContinuity.lean` — continuity of Schwartz autocorrelation (real analysis, sorry-free).
- `PartialSummation_verified.lean` — discrete Abel summation and exponential-sum bounds, incl. an honest correction of a wrong statement.
- `DULA_Bridge1.lean` + `DULA_Bridge1_Representation.lean` — p ≡ 1 (mod 3) ⟺ p = a²+ab+b² for primes > 3 (Thue-lemma proof).
- `DULA_Complete.lean` / `DULA_Chi3_Level6.lean` / `DulaCore.lean` / `DULA Theorem 4_28_0.lean` / `DULA_Theorem_LEAN_4.lean` — the ℤ₂ grading = χ₃ theorem family and (f⋆Λ)⋆ζ = f⋆log.
- `DULA_ThetaBridge.lean` — L(6(χ⋆1), s) = 6·L(χ,s)·ζ(s) with non-vanishing (Mathlib LSeries API); `DULA_ThetaPositivity.lean` — (1⋆χ₃)(n) ≥ 0.
- `KernelSummation.lean` — uniform lower bound for periodized Gaussians (useful lemma shape, numerological constants).
- `DULA Spectral Operator — Version 5.lean` — finite-rank kernel operator basics (symmetric, bounded, finite spectrum), with the analytic gaps honestly sorried/flagged.

None of these touches the OPH proof-chain items except hexacode.lean (§3.1).
