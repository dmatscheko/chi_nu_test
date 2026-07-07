import Mathlib

/-!
# The exact-coefficient collar gate, skeleton (L2.6)

Machine-checks the **mathematical skeleton** of the OPH collar gate — the
conditional theorem that prices proof-chain link L2.6. Paper anchors:

* `observer-patch-holography/paper/screen_microphysics_and_observer_synchronization.tex`
  — Definition *Uniform product-thickening branch* (lines 1300–1355; clause
  5 is slice-wise scalar-reserve unbiasedness), Assumption *Local Poisson
  reserve survival* (lines 1186–1197), Theorem *Exact uniform
  product-thickening coefficient* (lines 1357–1396), the finite-thickness
  Jensen band (lines 1242–1298), the `P/24` bookkeeping (lines 904–970:
  shared cut entropy density `P/4` split over the six protected `ℤ₆`
  classes; twelve-port screen × write/check orientation = 24 oriented
  slots), and the icosahedral port count (lines 1800–1846).
* `observer-patch-holography/extra/chi_nu_susceptibility_bounds.tex`
  — the L1–L7 assumption stack and the forced-susceptibility theorem
  `χ_can = λ_collar` with its band and exact corollaries (lines 1024–1206).

## What is proven

With a finite-slice collar model (`SliceModel`: normalized nonnegative
slice weights `w`, nonnegative per-slice reserve means `ε`) and
`λ_collar := ∑ y, w y · e^(−ε y)` — the finite counterpart of the paper's
`∫ dy · w(y) · e^(−ε_{ℤ₆}(y))`:

* `poisson_zero_count` — the per-slice survival factor is the Poisson
  zero-count probability: `poissonPMFReal ε 0 = e^(−ε)`. (Mathlib's
  `ProbabilityTheory.poissonPMFReal`; the rare-events derivation the dark
  paper spells out at its lines 692–713 is Mathlib's
  `binomial_tendsto_poissonPMFReal_atTop`, and its `k = 0` real form is
  `DarkSector.rare_event_zero_count`.)
* `uniform_gate` — **the gate theorem**: slice-wise unbiasedness
  (`∀ y, ε y = P/24` — the paper's boxed clause 5) forces
  `λ_collar = e^(−P/24)` *exactly*. The proof is the paper's own
  (substitute, use `∑ w = 1`).
* `jensen_band` — **the non-uniform band**: if only the *weighted mean*
  reserve is `P/24`, then `e^(−P/24) ≤ λ_collar ≤ 1` (Jensen for the
  convex exponential; upper bound from `ε ≥ 0`). This is the theorem-level
  band `0.9343… ≤ χ_can ≤ 1` of the chi_nu paper.
* `chi_forced` — the forced-susceptibility identity: if the surviving
  coherent fraction is written both as `λ·S` and as `χ·S` with `S ≠ 0`,
  then `χ = λ` (the chi_nu paper's Theorem *Forced canonical
  susceptibility*, whose proof is exactly this cancellation).
* `reserve_split`, `six_is_card_z6`, `twentyfour_is_oriented_ports` — the
  `24` bookkeeping: `(P/4)/6 = P/24`, the `6` is `#(ZMod 6)` (the kernel
  computed in `CenterZ6.lean`), and `24 = #(Fin 12 × Bool)` (twelve ports
  × write/check orientation).
* `sphere_defect_count` / `twelve_unit_defects` — **where the 12 comes
  from**: for any all-triangle combinatorial closed surface with Euler
  characteristic 2 (Euler's relation as the named topological input), the
  total combinatorial defect `∑(6 − deg v)` is exactly `12`; if every
  defect is a unit defect (degrees 5 or 6 only, the icosahedral
  screen-sieve situation), there are **exactly twelve** defect vertices —
  the paper's "twelve indistinguishable ports".

## Honest scope

The gate *clauses* — product collar algebra, product quotient trace,
reserve pullback, scalar activation disintegration, slice-wise
unbiasedness, local Poisson reserve survival (the paper's
`UNIFORM_PRODUCT_THICKENING_EXACT` conjunction / the chi_nu L1–L7 stack) —
are **named physical hypotheses** here, exactly as the papers treat them:
`uniform_gate` consumes unbiasedness as a hypothesis and does not derive
it. Nothing here derives `P` (see `PBranches.lean` for the two-`P`
digit-checks and for `e^(−P/24) = 0.9343006…` to 9 digits). Proof-chain
grading: the L2.6 *consequence structure* is now theorem-form; the gate
clauses and the receipts discipline stay physics.

No `sorry`, no new axioms, no `native_decide`.
-/

namespace OPHProofChain.CollarGate

open scoped BigOperators

/-- A finite-slice collar: transverse slices with a normalized nonnegative
    weight profile and nonnegative per-slice protected-reserve means. -/
structure SliceModel where
  /-- transverse slice index -/
  ι : Type
  /-- finitely many slices -/
  [fin : Fintype ι]
  /-- slice weights `w(y)` -/
  w : ι → ℝ
  /-- per-slice protected-reserve mean `ε_{ℤ₆}(y)` -/
  ε : ι → ℝ
  w_nonneg : ∀ y, 0 ≤ w y
  w_sum_one : ∑ y, w y = 1
  ε_nonneg : ∀ y, 0 ≤ ε y

attribute [instance] SliceModel.fin

/-- The finite-thickness collar survival coefficient
    `λ_collar = ∑ y, w(y)·e^(−ε(y))` (the finite counterpart of the paper's
    `∫ dy w(y) e^(−ε_{ℤ₆}(y))`, screen tex lines 1199–1240). -/
noncomputable def lambdaCollar (M : SliceModel) : ℝ :=
  ∑ y, M.w y * Real.exp (-(M.ε y))

/-- The per-slice survival factor is the Poisson zero-count probability —
    the content of the paper's Assumption *Local Poisson reserve survival*
    (screen tex lines 1186–1197), with the Poisson law itself available in
    Mathlib (`binomial_tendsto_poissonPMFReal_atTop` is the rare-events
    limit the dark paper derives). -/
theorem poisson_zero_count (r : NNReal) :
    ProbabilityTheory.poissonPMFReal r 0 = Real.exp (-r) := by
  unfold ProbabilityTheory.poissonPMFReal
  simp

/-- **The gate theorem** (screen tex, Theorem *Exact uniform
    product-thickening coefficient*, lines 1357–1396): slice-wise
    scalar-reserve unbiasedness — every scalar-active slice carries reserve
    mean exactly `P/24` (the boxed clause 5) — forces
    `λ_collar = e^(−P/24)` **exactly**. The proof is the paper's:
    substitute, and use the normalization `∑ w = 1`. -/
theorem uniform_gate (M : SliceModel) (P : ℝ)
    (h_unbiased : ∀ y, M.ε y = P / 24) :
    lambdaCollar M = Real.exp (-(P / 24)) := by
  unfold lambdaCollar
  have h : ∀ y ∈ Finset.univ, M.w y * Real.exp (-(M.ε y))
      = M.w y * Real.exp (-(P / 24)) := by
    intro y _
    rw [h_unbiased y]
  rw [Finset.sum_congr rfl h, ← Finset.sum_mul, M.w_sum_one, one_mul]

/-- **The Jensen band** (screen tex lines 1242–1298; chi_nu tex corollary,
    lines 1160–1187): if only the *scalar-weighted mean* reserve equals
    `P/24`, then `e^(−P/24) ≤ λ_collar ≤ 1`. Lower bound: Jensen's
    inequality for the convex exponential; upper bound: reserve means are
    nonnegative, so each survival factor is `≤ 1`. -/
theorem jensen_band (M : SliceModel) (P : ℝ)
    (h_mean : ∑ y, M.w y * M.ε y = P / 24) :
    Real.exp (-(P / 24)) ≤ lambdaCollar M ∧ lambdaCollar M ≤ 1 := by
  constructor
  · -- Jensen: exp(∑ w·(−ε)) ≤ ∑ w·exp(−ε)
    have hjen := convexOn_exp.map_sum_le
      (t := (Finset.univ : Finset M.ι))
      (w := M.w) (p := fun y => -(M.ε y))
      (fun y _ => M.w_nonneg y)
      M.w_sum_one
      (fun y _ => Set.mem_univ _)
    have harg : ∑ y, M.w y • (-(M.ε y)) = -(P / 24) := by
      rw [← h_mean, ← Finset.sum_neg_distrib]
      refine Finset.sum_congr rfl fun y _ => ?_
      rw [smul_eq_mul]
      ring
    rw [harg] at hjen
    calc Real.exp (-(P / 24)) ≤ ∑ y, M.w y • Real.exp (-(M.ε y)) := hjen
      _ = lambdaCollar M := by
          unfold lambdaCollar
          refine Finset.sum_congr rfl fun y _ => ?_
          rw [smul_eq_mul]
  · -- each factor ≤ 1
    unfold lambdaCollar
    calc ∑ y, M.w y * Real.exp (-(M.ε y)) ≤ ∑ y, M.w y * 1 := by
          refine Finset.sum_le_sum fun y _ => ?_
          refine mul_le_mul_of_nonneg_left ?_ (M.w_nonneg y)
          rw [Real.exp_le_one_iff]
          linarith [M.ε_nonneg y]
      _ = 1 := by
          simp only [mul_one]
          exact M.w_sum_one

/-- **The forced-susceptibility identity** (chi_nu tex, Theorem *Forced
    canonical susceptibility on the co-registered branch*, lines
    1127–1158): the collar writes the surviving coherent fraction as
    `λ_collar·S`, the continuation law writes it as `χ_can·S`; for any
    nonzero canonical coherent fraction the coefficients coincide. The
    paper's proof is exactly this cancellation. -/
theorem chi_forced (lam chi S : ℝ) (hS : S ≠ 0)
    (h_two_writings : lam * S = chi * S) :
    chi = lam :=
  (mul_right_cancel₀ hS h_two_writings).symm

/-! ### The 24 bookkeeping (screen tex lines 904–970) -/

/-- The shared cut entropy density `P/4`, split over the six protected
    center classes, gives the reserve mean `P/24` per class. -/
theorem reserve_split (P : ℝ) : (P / 4) / 6 = P / 24 := by ring

/-- The six classes are the ℤ₆ of `CenterZ6.lean`. -/
theorem six_is_card_z6 : (6 : ℕ) = Fintype.card (ZMod 6) := by simp

/-- The oriented register: twelve central ports × write/check orientation
    = the 24 oriented slots (the local accounting surface for the same
    shared-edge reserve). -/
theorem twentyfour_is_oriented_ports : (24 : ℕ) = Fintype.card (Fin 12 × Bool) := by
  simp

/-! ### The twelve from the sphere (screen tex lines 1800–1846)

The icosahedral screen-sieve's "exactly twelve indistinguishable ports" is
combinatorial Gauss–Bonnet: on any all-triangle combinatorial closed
surface of Euler characteristic 2, the total defect `∑ (6 − deg v)` is
`12`; unit defects ⇒ exactly twelve defect vertices. Euler's relation is
the named topological input. -/

/-- **Combinatorial Gauss–Bonnet on the sphere**: vertex/edge/face counts
    with Euler's relation, all faces triangles (`3F = 2E`), and the
    handshake identity give total defect 12. -/
theorem sphere_defect_count (V E F : ℕ) (deg : Fin V → ℕ)
    (euler : (V : ℤ) - E + F = 2)
    (triangles : 3 * F = 2 * E)
    (degree_sum : ∑ v, deg v = 2 * E) :
    ∑ v, ((6 : ℤ) - deg v) = 12 := by
  have h1 : ∑ v, ((6 : ℤ) - (deg v : ℤ)) = 6 * V - 2 * E := by
    rw [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ,
      Fintype.card_fin, nsmul_eq_mul]
    have hcast : (∑ v, (deg v : ℤ)) = ((∑ v, deg v : ℕ) : ℤ) := by
      push_cast
      rfl
    rw [hcast, degree_sum]
    push_cast
    ring
  rw [h1]
  have h2 : (3 : ℤ) * F = 2 * E := by exact_mod_cast triangles
  linarith [euler, h2]

/-- **Exactly twelve ports**: if every vertex is a unit defect or flat
    (degree 5 or 6 — the icosahedral screen-sieve situation), there are
    exactly twelve defect vertices. -/
theorem twelve_unit_defects (V E F : ℕ) (deg : Fin V → ℕ)
    (euler : (V : ℤ) - E + F = 2)
    (triangles : 3 * F = 2 * E)
    (degree_sum : ∑ v, deg v = 2 * E)
    (hdeg : ∀ v, deg v = 5 ∨ deg v = 6) :
    (Finset.univ.filter fun v => deg v = 5).card = 12 := by
  have h := sphere_defect_count V E F deg euler triangles degree_sum
  rw [← Finset.sum_filter_add_sum_filter_not Finset.univ (fun v => deg v = 5)] at h
  have h5 : ∑ v ∈ Finset.univ.filter (fun v => deg v = 5), ((6 : ℤ) - deg v)
      = (Finset.univ.filter fun v => deg v = 5).card := by
    have hterm : ∀ v ∈ Finset.univ.filter (fun v => deg v = 5),
        ((6 : ℤ) - deg v) = 1 := by
      intro v hv
      rw [(Finset.mem_filter.mp hv).2]
      norm_num
    rw [Finset.sum_congr rfl hterm, Finset.sum_const, nsmul_eq_mul, mul_one]
  have h6 : ∑ v ∈ Finset.univ.filter (fun v => ¬ deg v = 5), ((6 : ℤ) - deg v) = 0 := by
    apply Finset.sum_eq_zero
    intro v hv
    have hnot := (Finset.mem_filter.mp hv).2
    rcases hdeg v with h' | h'
    · exact absurd h' hnot
    · rw [h']
      norm_num
  rw [h5, h6, add_zero] at h
  exact_mod_cast h

/-! ### Axiom audit -/
#print axioms poisson_zero_count
#print axioms uniform_gate
#print axioms jensen_band
#print axioms chi_forced
#print axioms reserve_split
#print axioms sphere_defect_count
#print axioms twelve_unit_defects

end OPHProofChain.CollarGate
