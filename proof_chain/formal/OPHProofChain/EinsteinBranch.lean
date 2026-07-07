import Mathlib

/-!
# The Einstein-branch linear-algebra core (L2.3 / D5)

Machine-checks the **algebraic heart** of the compact paper's D5 chain
(`observer-patch-holography/paper/recovering_relativity_and_standard_model_structure_from_observer_overlap_consistency_compact.tex`,
Theorem `thm:einstein` lines 4518–4569 and Theorem `cor:einstein` lines
4572–4631), in the same division of labor `ScalarResponse.lean` applies to
SEE: the *variational identities* (entropy stationarity, the small-ball
bridge, the fixed-volume area variation) enter as **named hypotheses** —
they are the physics of the D3–D5 conditional tex chain — and everything
downstream of them is proved.

## Results

* `rest_frame_relation` — the arithmetic of Theorem `thm:einstein` (lines
  4531–4570): from `0 = δS_bulk + δA/(4G)` (stationarity),
  `δS_bulk = (8π²ℓ⁴/15)·X` (small-ball bridge) and
  `δA = −(4πℓ⁴/15)·Z` (area variation) follows `Z = 8πG·X` — the
  rest-frame Einstein relation, exactly as printed.
* `unit_timelike_determines` — the paper's **polynomial upgrade step**
  (`cor:einstein` lines 4604–4620): a symmetric bilinear form vanishing on
  **all future unit timelike directions** of Minkowski space vanishes
  identically. Proved by finitely many witness vectors (`e₀`,
  `e₀ ± ½eᵢ`, `e₀ + ⅓eᵢ`, `e₀ + ½(eᵢ+eⱼ)` — all timelike), with the
  scaling step through the open cone; no analysis, no open-ball argument.
* `tensor_upgrade` — the packaged conditional (`cor:einstein`): if the
  rest-frame relation holds for **every** local rest frame (all future
  unit timelike `u`), the full tensor equation
  `G_ab + Λg_ab = 8πG·T_ab` holds entrywise.
* `null_cone_determines` / `jacobson_step` — the **classic Jacobson step**
  (the algebraic core of "δQ = TδS on all local Rindler horizons ⇒
  equation of state", Jacobson 1995, the shape proof-chain Layer 1 cites):
  a symmetric form vanishing on the **null cone** equals `λ·η`, so
  `F(k,k) = κT(k,k)` on all null `k` forces `F = κT + λη` — the
  cosmological constant is exactly the residual freedom, machine-checked.

## Honest scope

This module does **not** derive the Einstein equation from consensus
dynamics. It machine-checks that *given* the three variational identities
(named physics: Theorem `thm:equilibrium`, Lemma `lem:smallball`, Theorem
`thm:fixed-volume-small-ball-area` — none of them formalized, all of them
the conditional D3–D5 chain), the passage to the tensor equation is pure
linear algebra, and that the only pointwise freedom the null-cone route
leaves is the metric term `λ·η` (the branch constant `Λ`). The matching
negative fence is `NotEinsteinComplete.lean`: bare consensus cannot decide
these hypotheses. Proof-chain link: L2.3.

Conventions: Minkowski `ℝ^{1,n}` with `η = diag(−1, 1, …, 1)`; bilinear
forms as plain matrices-as-functions `Fin (n+1) → Fin (n+1) → ℝ` with an
explicit symmetry hypothesis.

No `sorry`, no new axioms, no `native_decide`.
-/

namespace OPHProofChain.EinsteinBranch

variable {n : ℕ}

/-- Vectors of Minkowski `ℝ^{1,n}`. -/
abbrev V (n : ℕ) : Type := Fin (n + 1) → ℝ

/-- Bilinear forms as matrices-as-functions. -/
abbrev Mat (n : ℕ) : Type := Fin (n + 1) → Fin (n + 1) → ℝ

/-- The associated bilinear map `Σᵢⱼ Bᵢⱼ xᵢ yⱼ`. -/
def bilinOf (B : Mat n) (x y : V n) : ℝ := ∑ i, ∑ j, B i j * x i * y j

/-- The quadratic form `B(u,u)`. -/
def quadOf (B : Mat n) (u : V n) : ℝ := bilinOf B u u

/-- The Minkowski metric `η = diag(−1, 1, …, 1)`. -/
def eta (n : ℕ) : Mat n := fun i j => if i = j then (if i = 0 then -1 else 1) else 0

/-- Standard basis vector. -/
def e (i : Fin (n + 1)) : V n := Pi.single i 1

/-! ### Bilinearity toolbox -/

theorem bilinOf_add_left (B : Mat n) (x x' y : V n) :
    bilinOf B (x + x') y = bilinOf B x y + bilinOf B x' y := by
  unfold bilinOf
  rw [← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun j _ => ?_
  simp only [Pi.add_apply]
  ring

theorem bilinOf_add_right (B : Mat n) (x y y' : V n) :
    bilinOf B x (y + y') = bilinOf B x y + bilinOf B x y' := by
  unfold bilinOf
  rw [← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun j _ => ?_
  simp only [Pi.add_apply]
  ring

theorem bilinOf_smul_left (B : Mat n) (c : ℝ) (x y : V n) :
    bilinOf B (c • x) y = c * bilinOf B x y := by
  unfold bilinOf
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl fun j _ => ?_
  simp only [Pi.smul_apply, smul_eq_mul]
  ring

theorem bilinOf_smul_right (B : Mat n) (c : ℝ) (x y : V n) :
    bilinOf B x (c • y) = c * bilinOf B x y := by
  unfold bilinOf
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl fun j _ => ?_
  simp only [Pi.smul_apply, smul_eq_mul]
  ring

theorem bilinOf_single_single (B : Mat n) (p q : Fin (n + 1)) :
    bilinOf B (e p) (e q) = B p q := by
  unfold bilinOf e
  rw [Finset.sum_eq_single p]
  · rw [Finset.sum_eq_single q]
    · simp
    · intro l _ hl
      simp [Pi.single_eq_of_ne hl]
    · intro h
      exact absurd (Finset.mem_univ q) h
  · intro k _ hk
    apply Finset.sum_eq_zero
    intro l _
    simp [Pi.single_eq_of_ne hk]
  · intro h
    exact absurd (Finset.mem_univ p) h

/-- Additivity in the matrix argument (with a scalar on the second term). -/
theorem quadOf_sub_smul (A C : Mat n) (c : ℝ) (u : V n) :
    quadOf (fun i j => A i j - c * C i j) u = quadOf A u - c * quadOf C u := by
  unfold quadOf bilinOf
  rw [Finset.mul_sum, ← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [Finset.mul_sum, ← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl fun j _ => ?_
  ring

theorem quadOf_smul (B : Mat n) (c : ℝ) (x : V n) :
    quadOf B (c • x) = c ^ 2 * quadOf B x := by
  unfold quadOf
  rw [bilinOf_smul_left, bilinOf_smul_right]
  ring

/-- Evaluation on a two-vector combination (no distinctness needed — the
    identity is bilinearity-blind). -/
theorem quadOf_double (B : Mat n) (hsymm : ∀ i j, B i j = B j i)
    (a b : ℝ) (i : Fin (n + 1)) :
    quadOf B (a • e 0 + b • e i) =
      a ^ 2 * B 0 0 + 2 * a * b * B 0 i + b ^ 2 * B i i := by
  unfold quadOf
  simp only [bilinOf_add_left, bilinOf_add_right, bilinOf_smul_left,
    bilinOf_smul_right, bilinOf_single_single]
  rw [hsymm i 0]
  ring

/-- Evaluation on a three-vector combination. -/
theorem quadOf_triple (B : Mat n) (hsymm : ∀ i j, B i j = B j i)
    (a b c : ℝ) (i j : Fin (n + 1)) :
    quadOf B (a • e 0 + b • e i + c • e j) =
      a ^ 2 * B 0 0 + b ^ 2 * B i i + c ^ 2 * B j j
        + 2 * a * b * B 0 i + 2 * a * c * B 0 j + 2 * b * c * B i j := by
  unfold quadOf
  simp only [bilinOf_add_left, bilinOf_add_right, bilinOf_smul_left,
    bilinOf_smul_right, bilinOf_single_single]
  rw [hsymm i 0, hsymm j 0, hsymm j i]
  ring

/-! ### Minkowski values and witness vectors -/

theorem eta_symm : ∀ i j : Fin (n + 1), eta n i j = eta n j i := by
  intro i j
  unfold eta
  by_cases h : i = j
  · subst h
    rfl
  · rw [if_neg h, if_neg (Ne.symm h)]

@[simp] theorem eta_zero_zero : eta n 0 0 = -1 := by
  unfold eta
  simp

theorem eta_diag_spatial {i : Fin (n + 1)} (hi : i ≠ 0) : eta n i i = 1 := by
  unfold eta
  simp [hi]

theorem eta_off_diag {i j : Fin (n + 1)} (hij : i ≠ j) : eta n i j = 0 := by
  unfold eta
  simp [hij]

theorem e_zero_at_zero : (e (0 : Fin (n + 1))) 0 = 1 := Pi.single_eq_same 0 1

theorem double_at_zero (a b : ℝ) {i : Fin (n + 1)} (hi : i ≠ 0) :
    (a • e 0 + b • e i : V n) 0 = a := by
  simp only [Pi.add_apply, Pi.smul_apply, smul_eq_mul, e]
  rw [Pi.single_eq_same, Pi.single_eq_of_ne (Ne.symm hi)]
  ring

theorem triple_at_zero (a b c : ℝ) {i j : Fin (n + 1)} (hi : i ≠ 0) (hj : j ≠ 0) :
    (a • e 0 + b • e i + c • e j : V n) 0 = a := by
  simp only [Pi.add_apply, Pi.smul_apply, smul_eq_mul, e]
  rw [Pi.single_eq_same, Pi.single_eq_of_ne (Ne.symm hi), Pi.single_eq_of_ne (Ne.symm hj)]
  ring

/-! ### The timelike polynomial upgrade (the paper's `cor:einstein` step) -/

/-- **The polynomial upgrade step** (compact tex lines 4604–4620): a
    symmetric bilinear form whose quadratic form vanishes on **every future
    unit timelike direction** vanishes identically. The paper argues via a
    quadratic polynomial vanishing on an open ball; here the same
    conclusion comes from finitely many explicit timelike witnesses,
    through scaling on the open cone. -/
theorem unit_timelike_determines (B : Mat n) (hsymm : ∀ i j, B i j = B j i)
    (h : ∀ u : V n, quadOf (eta n) u = -1 → 0 < u 0 → quadOf B u = 0) :
    ∀ i j, B i j = 0 := by
  -- Step 1: `quadOf B` vanishes on the whole open future cone, by scaling.
  have cone : ∀ w : V n, quadOf (eta n) w < 0 → 0 < w 0 → quadOf B w = 0 := by
    intro w hw hw0
    set c : ℝ := Real.sqrt (-(quadOf (eta n) w)) with hc
    have hcpos : 0 < c := Real.sqrt_pos.mpr (by linarith)
    have hc2 : c ^ 2 = -(quadOf (eta n) w) := Real.sq_sqrt (by linarith)
    have hqu : quadOf (eta n) (c⁻¹ • w) = -1 := by
      rw [quadOf_smul]
      have hdiv : (c⁻¹) ^ 2 * quadOf (eta n) w = (quadOf (eta n) w) / c ^ 2 := by
        field_simp
      rw [hdiv, hc2, div_neg, div_self (ne_of_lt hw)]
    have hu0 : 0 < (c⁻¹ • w) 0 := by
      simp only [Pi.smul_apply, smul_eq_mul]
      positivity
    have hzero := h (c⁻¹ • w) hqu hu0
    have hw_eq : w = c • (c⁻¹ • w) := by
      rw [smul_smul, mul_inv_cancel₀ hcpos.ne', one_smul]
    calc quadOf B w = quadOf B (c • (c⁻¹ • w)) := by rw [← hw_eq]
      _ = c ^ 2 * quadOf B (c⁻¹ • w) := quadOf_smul B c _
      _ = 0 := by rw [hzero, mul_zero]
  -- Step 2: `B 0 0 = 0` from the witness `e 0`.
  have h00 : B 0 0 = 0 := by
    have he0 : quadOf B (e 0) = B 0 0 := bilinOf_single_single B 0 0
    have heta : quadOf (eta n) (e (0 : Fin (n + 1))) = -1 := by
      have := bilinOf_single_single (eta n) (0 : Fin (n + 1)) 0
      unfold quadOf
      rw [this, eta_zero_zero]
    rw [← he0]
    exact h (e 0) heta (by rw [e_zero_at_zero]; norm_num)
  -- Step 3: spatial diagonal and time-space entries, from `e₀ + s·eᵢ`,
  -- `s ∈ {1/2, 1/3}`.
  have hspace : ∀ i : Fin (n + 1), i ≠ 0 → B 0 i = 0 ∧ B i i = 0 := by
    intro i hi
    have hval : ∀ s : ℝ, s ^ 2 < 1 →
        B 0 0 + 2 * s * B 0 i + s ^ 2 * B i i = 0 := by
      intro s hs
      have heta : quadOf (eta n) ((1 : ℝ) • e 0 + s • e i) = -1 + s ^ 2 := by
        rw [quadOf_double (eta n) eta_symm]
        rw [eta_zero_zero, eta_diag_spatial hi, eta_off_diag (Ne.symm hi)]
        ring
      have hcone := cone ((1 : ℝ) • e 0 + s • e i)
        (by rw [heta]; linarith)
        (by rw [double_at_zero 1 s hi]; norm_num)
      rw [quadOf_double B hsymm] at hcone
      linarith [hcone]
    have h12 := hval (1 / 2) (by norm_num)
    have h13 := hval (1 / 3) (by norm_num)
    constructor
    · linarith [h12, h13, h00]
    · linarith [h12, h13, h00]
  -- Step 4: distinct spatial off-diagonal entries, from `e₀ + ½(eᵢ+eⱼ)`.
  have hmixed : ∀ i j : Fin (n + 1), i ≠ 0 → j ≠ 0 → i ≠ j → B i j = 0 := by
    intro i j hi hj hij
    have heta : quadOf (eta n) ((1 : ℝ) • e 0 + (1 / 2 : ℝ) • e i + (1 / 2 : ℝ) • e j)
        = -(1 / 2) := by
      rw [quadOf_triple (eta n) eta_symm]
      rw [eta_zero_zero, eta_diag_spatial hi, eta_diag_spatial hj,
        eta_off_diag (Ne.symm hi), eta_off_diag (Ne.symm hj), eta_off_diag hij]
      ring
    have hcone := cone ((1 : ℝ) • e 0 + (1 / 2 : ℝ) • e i + (1 / 2 : ℝ) • e j)
      (by rw [heta]; norm_num)
      (by rw [triple_at_zero 1 (1 / 2) (1 / 2) hi hj]; norm_num)
    rw [quadOf_triple B hsymm] at hcone
    have hii := (hspace i hi).2
    have hjj := (hspace j hj).2
    have h0i := (hspace i hi).1
    have h0j := (hspace j hj).1
    linarith [hcone]
  -- Assemble.
  intro i j
  by_cases hi : i = 0
  · by_cases hj : j = 0
    · rw [hi, hj]
      exact h00
    · rw [hi]
      exact (hspace j hj).1
  · by_cases hj : j = 0
    · rw [hj, hsymm i 0]
      exact (hspace i hi).1
    · by_cases hij : i = j
      · rw [hij]
        exact (hspace j hj).2
      · exact hmixed i j hi hj hij

/-! ### The classic null-cone step (Jacobson's equation-of-state algebra) -/

/-- **The null-cone lemma**: a symmetric form whose quadratic form vanishes
    on the whole null cone is a multiple of the metric — entrywise,
    `B = (−B₀₀)·η`. The witnesses are `e₀ ± eᵢ` and `√2·e₀ + eᵢ + eⱼ`. -/
theorem null_cone_determines (B : Mat n) (hsymm : ∀ i j, B i j = B j i)
    (h : ∀ k : V n, quadOf (eta n) k = 0 → quadOf B k = 0) :
    ∀ i j, B i j = -(B 0 0) * eta n i j := by
  -- time-space and spatial diagonal from `e₀ ± eᵢ`
  have hpm : ∀ i : Fin (n + 1), i ≠ 0 → B 0 i = 0 ∧ B i i = -(B 0 0) := by
    intro i hi
    have hval : ∀ s : ℝ, s ^ 2 = 1 →
        B 0 0 + 2 * s * B 0 i + s ^ 2 * B i i = 0 := by
      intro s hs
      have heta : quadOf (eta n) ((1 : ℝ) • e 0 + s • e i) = 0 := by
        rw [quadOf_double (eta n) eta_symm]
        rw [eta_zero_zero, eta_diag_spatial hi, eta_off_diag (Ne.symm hi)]
        linarith [hs]
      have hcone := h ((1 : ℝ) • e 0 + s • e i) heta
      rw [quadOf_double B hsymm] at hcone
      linarith [hcone]
    have hp := hval 1 (by norm_num)
    have hm := hval (-1) (by norm_num)
    constructor
    · linarith [hp, hm]
    · linarith [hp, hm]
  -- distinct spatial off-diagonal from `√2·e₀ + eᵢ + eⱼ`
  have hmixed : ∀ i j : Fin (n + 1), i ≠ 0 → j ≠ 0 → i ≠ j → B i j = 0 := by
    intro i j hi hj hij
    set a : ℝ := Real.sqrt 2 with ha
    have ha2 : a ^ 2 = 2 := Real.sq_sqrt (by norm_num)
    have heta : quadOf (eta n) (a • e 0 + (1 : ℝ) • e i + (1 : ℝ) • e j) = 0 := by
      rw [quadOf_triple (eta n) eta_symm]
      rw [eta_zero_zero, eta_diag_spatial hi, eta_diag_spatial hj,
        eta_off_diag (Ne.symm hi), eta_off_diag (Ne.symm hj), eta_off_diag hij]
      linarith [ha2]
    have hcone := h (a • e 0 + (1 : ℝ) • e i + (1 : ℝ) • e j) heta
    rw [quadOf_triple B hsymm] at hcone
    have h0i := (hpm i hi).1
    have h0j := (hpm j hj).1
    have hii := (hpm i hi).2
    have hjj := (hpm j hj).2
    rw [h0i, h0j, hii, hjj, ha2] at hcone
    linarith [hcone]
  intro i j
  by_cases hi : i = 0
  · subst hi
    by_cases hj : j = 0
    · subst hj
      rw [eta_zero_zero]
      ring
    · rw [eta_off_diag (Ne.symm hj), (hpm j hj).1]
      ring
  · by_cases hj : j = 0
    · subst hj
      rw [eta_off_diag hi, hsymm i 0, (hpm i hi).1]
      ring
    · by_cases hij : i = j
      · subst hij
        rw [eta_diag_spatial hi, (hpm i hi).2]
        ring
      · rw [eta_off_diag hij, hmixed i j hi hj hij]
        ring

/-- **The Jacobson equation-of-state step**: if `F(k,k) = κ·T(k,k)` for all
    null `k` (the algebraic residue of "δQ = TδS on all local Rindler
    horizons"), then `F = κT + λη` for some constant `λ` — the entire
    pointwise freedom is the cosmological-constant term. -/
theorem jacobson_step (F T : Mat n)
    (hF : ∀ i j, F i j = F j i) (hT : ∀ i j, T i j = T j i) (κ : ℝ)
    (h : ∀ k : V n, quadOf (eta n) k = 0 → quadOf F k = κ * quadOf T k) :
    ∃ lam : ℝ, ∀ i j, F i j = κ * T i j + lam * eta n i j := by
  set B : Mat n := fun i j => F i j - κ * T i j with hB
  have hBsymm : ∀ i j, B i j = B j i := by
    intro i j
    rw [hB]
    simp only
    rw [hF i j, hT i j]
  have hBnull : ∀ k : V n, quadOf (eta n) k = 0 → quadOf B k = 0 := by
    intro k hk
    rw [hB, quadOf_sub_smul, h k hk, sub_self]
  have := null_cone_determines B hBsymm hBnull
  refine ⟨-(B 0 0), fun i j => ?_⟩
  have hij := this i j
  rw [hB] at hij
  simp only at hij
  linarith [hij]

/-! ### The D5 skeleton: named physics in, Einstein equation out -/

/-- **The rest-frame arithmetic of Theorem `thm:einstein`** (compact tex
    lines 4531–4570). The three hypotheses are the named physics:
    `h_stationarity` = fixed-cap generalized-entropy stationarity (Theorem
    `thm:equilibrium`), `h_smallball` = the small-ball bridge (Lemma
    `lem:smallball`, `X = u^a u^b δ⟨T_ab⟩`), `h_area` = the fixed-volume
    area variation (`Z = δ[(G_ab + Λg_ab)u^a u^b]`). Conclusion: the
    rest-frame Einstein relation. -/
theorem rest_frame_relation (G ℓ X Z δS δA : ℝ) (hG : 0 < G) (hℓ : 0 < ℓ)
    (h_stationarity : δS + δA / (4 * G) = 0)
    (h_smallball : δS = (8 * Real.pi ^ 2 * ℓ ^ 4 / 15) * X)
    (h_area : δA = -(4 * Real.pi * ℓ ^ 4 / 15) * Z) :
    Z = 8 * Real.pi * G * X := by
  have hπ := Real.pi_pos
  have h4 : δA = -δS * (4 * G) := by
    have h5 : δA / (4 * G) = -δS := by linarith
    have h6 := (div_eq_iff (by positivity : (4 : ℝ) * G ≠ 0)).mp h5
    linarith [h6]
  rw [h_smallball, h_area] at h4
  have hne : (4 * Real.pi * ℓ ^ 4 / 15 : ℝ) ≠ 0 := by positivity
  apply mul_left_cancel₀ hne
  linear_combination -h4

/-- **The tensor upgrade, packaged** (Theorem `cor:einstein`): if the
    rest-frame relation `(G + Λg)(u,u) = κ·T(u,u)` holds in **every** local
    rest frame (all future unit timelike `u` — supplied, in the paper, by
    the D3 Lorentz branch and overlap consistency across observers), then
    the full tensor Einstein equation holds entrywise:
    `G_ij + Λ·g_ij = κ·T_ij`. -/
theorem tensor_upgrade (Gm gm T : Mat n) (Λ κ : ℝ)
    (hsymm : ∀ i j, Gm i j + Λ * gm i j - κ * T i j
      = Gm j i + Λ * gm j i - κ * T j i)
    (hall : ∀ u : V n, quadOf (eta n) u = -1 → 0 < u 0 →
      quadOf (fun i j => Gm i j + Λ * gm i j) u = κ * quadOf T u) :
    ∀ i j, Gm i j + Λ * gm i j = κ * T i j := by
  set Y : Mat n := fun i j => (Gm i j + Λ * gm i j) - κ * T i j with hY
  have hYsymm : ∀ i j, Y i j = Y j i := by
    intro i j
    rw [hY]
    simpa using hsymm i j
  have hYvan : ∀ u : V n, quadOf (eta n) u = -1 → 0 < u 0 → quadOf Y u = 0 := by
    intro u h1 h2
    rw [hY, quadOf_sub_smul, hall u h1 h2, sub_self]
  have := unit_timelike_determines Y hYsymm hYvan
  intro i j
  have hij := this i j
  rw [hY] at hij
  simp only at hij
  linarith [hij]

/-! ### Axiom audit -/
#print axioms unit_timelike_determines
#print axioms null_cone_determines
#print axioms jacobson_step
#print axioms rest_frame_relation
#print axioms tensor_upgrade

end OPHProofChain.EinsteinBranch
