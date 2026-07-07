import Mathlib
import OPHProofChain.ModularCore

/-!
# T28 — The real-time modular flow, finite-dimensional (closing holes-audit F9)

**The audit hole this closes.** `ModularCore.lean` (T21) pins the
*imaginary-time* modular step: `kms_unique` shows the algebraic KMS identity
`ω(A·D(B)) = ω(B·A)` forces `D = Δ_ρ = ρ·ρ⁻¹`. The audit (F9) correctly
observed that calling that map a *clock* imports real-time content that was
not formalized: "the real-time statement — in matrix algebras `ρ^{it}` is
elementary via diagonalization — is a well-scoped finite-dimensional
theorem." This module supplies it:

* **The modular Hamiltonian exists** (`exists_modularHamiltonian`): every
  positive-definite `ρ` has a Hermitian `H` with `exp(−H) = ρ` — the spectral
  construction `H = −log ρ`, machine-checked through the diagonalization.
* **The real-time flow** (`flow`): `σ_z(A) = e^{izH}·A·e^{−izH}`, defined for
  every **complex** `z` — the entire analytic extension; real `z = t` is the
  physical one-parameter flow `ρ^{it}·A·ρ^{−it}`.
* **One-parameter group of ⋆-automorphisms**: `flow_add` (group law, for all
  complex parameters), `flow_mul`/`flow_one` (algebra automorphism),
  `flow_star_real` (⋆-preservation at real times, via unitarity of the
  propagator, `flowU_conjTranspose`), `flowU_continuous` (norm-continuity in
  the parameter — the finite-dimensional stand-in for σ-weak continuity).
* **State invariance** (`state_flow`): `ω ∘ σ_z = ω` for every complex `z`.
* **The analytic anchor** (`flow_I_eq_modular`): `σ_i = Δ_ρ` — the
  imaginary-time step of T21 IS the value of the real-time flow's analytic
  extension at `z = i`.
* **The KMS boundary condition** (`kms_boundary`):
  `ω(A · σ_{t+i}(B)) = ω(σ_t(B) · A)` for ALL complex `t` — the textbook KMS
  condition at inverse temperature `β = 1`, with genuine (real) time inside;
  one line from the group law + T21's `kms`.
* **Uniqueness** (`hamiltonian_kms_unique`): if a Hamiltonian-implemented
  flow `τ_z(A) = e^{izK}·A·e^{−izK}` (any Hermitian `K`) satisfies the KMS
  identity against `ω = tr(ρ·)`, then its Gibbs weight is pinned:
  `e^{−K} = c·ρ` with `c` real `> 0` — i.e. `K = −log ρ` up to the additive
  constant that conjugation cannot see — and its imaginary-time step IS the
  modular map. (`kms_conjugation_eq` is the normalization-free engine: any
  KMS-satisfying conjugation `V·B·V⁻¹` has `V = c•ρ`.)

**Honest scope.** Uniqueness is proven within the Hamiltonian-implemented
class (`τ_z = e^{izK}(·)e^{−izK}`) — and since the formal-v8 campaign that
class is provably generic: `algEquiv_matrix_inner` (T33, below) is
Skolem–Noether for the full matrix algebra, so every `ℂ`-algebra
automorphism is a conjugation, and `kms_algEquiv_structure` pins any
KMS-satisfying automorphism to the modular map with conjugator `c • ρ`.
What this module does NOT touch stays as named physics: the
Bisognano–Wichmann identification of the modular flow of a *wedge* state
with geometric boosts, and the scaling limit (D3's remaining content).

Axioms: standard (`propext`, `Classical.choice`, `Quot.sound`); no `sorry`,
no `native_decide`.
-/

namespace OPHProofChain.Modular

open Matrix NormedSpace
open scoped ComplexOrder

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ## The modular Hamiltonian -/

/-- A **modular Hamiltonian** for a state `ρ`: a Hermitian generator whose
    Gibbs weight is the state, `exp(−H) = ρ`. (`H = −log ρ`.) -/
def IsModularHamiltonian (ρ H : Matrix ι ι ℂ) : Prop :=
  H.IsHermitian ∧ exp (-H) = ρ

/-- **Existence**: every positive-definite density matrix has a modular
    Hamiltonian — the spectral construction `H = −log ρ`, assembled from the
    diagonalization `ρ = U·diag(λ)·U⋆` with `λᵢ > 0`. -/
theorem exists_modularHamiltonian (ρ : Matrix ι ι ℂ) (hρ : ρ.PosDef) :
    ∃ H : Matrix ι ι ℂ, IsModularHamiltonian ρ H := by
  have hherm : ρ.IsHermitian := hρ.1
  set U : Matrix ι ι ℂ := (hherm.eigenvectorUnitary : Matrix ι ι ℂ) with hU
  have hsUU : star U * U = 1 :=
    Unitary.star_mul_self_of_mem hherm.eigenvectorUnitary.prop
  have hUsU : U * star U = 1 :=
    Unitary.mul_star_self_of_mem hherm.eigenvectorUnitary.prop
  have hunit : IsUnit U := ⟨⟨U, star U, hUsU, hsUU⟩, rfl⟩
  have hinv : U⁻¹ = star U := Matrix.inv_eq_left_inv hsUU
  set D : Matrix ι ι ℂ :=
    diagonal (fun i => (Real.log (hherm.eigenvalues i) : ℂ)) with hD
  have hDstar : star D = D := by
    rw [hD, Matrix.star_eq_conjTranspose, diagonal_conjTranspose]
    congr 1
    funext i
    rw [Pi.star_apply, RCLike.star_def, Complex.conj_ofReal]
  refine ⟨U * (-D) * star U, ?_, ?_⟩
  · -- Hermitian: conjugation of a real diagonal by a unitary
    show (U * (-D) * star U)ᴴ = U * (-D) * star U
    rw [← Matrix.star_eq_conjTranspose, StarMul.star_mul, StarMul.star_mul,
      star_star, star_neg, hDstar]
    noncomm_ring
  · -- `exp(−H) = U·exp(D)·U⋆ = U·diag(λ)·U⋆ = ρ`
    have hneg : -(U * (-D) * star U) = U * D * U⁻¹ := by
      rw [hinv]
      noncomm_ring
    rw [hneg, Matrix.exp_conj U D hunit]
    have hexpD : exp D = diagonal (RCLike.ofReal ∘ hherm.eigenvalues) := by
      rw [hD, Matrix.exp_diagonal]
      congr 1
      funext i
      rw [Pi.coe_exp, ← Complex.exp_eq_exp_ℂ, ← Complex.ofReal_exp,
        Real.exp_log (hρ.eigenvalues_pos i)]
      rfl
    rw [hexpD, hinv]
    have hspec := hherm.spectral_theorem
    rw [Unitary.conjStarAlgAut_apply] at hspec
    exact hspec.symm

/-! ## The flow -/

/-- The flow's propagator at complex parameter `z`: `U(z) = e^{izH}`. -/
noncomputable def flowU (H : Matrix ι ι ℂ) (z : ℂ) : Matrix ι ι ℂ :=
  exp ((Complex.I * z) • H)

/-- **The modular flow** at complex parameter `z`:
    `σ_z(A) = e^{izH}·A·e^{−izH}`. At real `z = t` this is the physical
    one-parameter flow `ρ^{it}·A·ρ^{−it}`; over all of `ℂ` it is the entire
    analytic extension whose value at `z = i` is the modular map of T21. -/
noncomputable def flow (H : Matrix ι ι ℂ) (z : ℂ) (A : Matrix ι ι ℂ) :
    Matrix ι ι ℂ :=
  flowU H z * A * flowU H (-z)

theorem flowU_zero (H : Matrix ι ι ℂ) : flowU H 0 = 1 := by
  unfold flowU
  rw [mul_zero, zero_smul, exp_zero]

/-- The propagator is a one-parameter group. -/
theorem flowU_add (H : Matrix ι ι ℂ) (z w : ℂ) :
    flowU H (z + w) = flowU H z * flowU H w := by
  unfold flowU
  rw [show (Complex.I * (z + w)) • H
      = (Complex.I * z) • H + (Complex.I * w) • H from by
    rw [← add_smul]; ring_nf]
  exact Matrix.exp_add_of_commute _ _
    (((Commute.refl H).smul_left _).smul_right _)

theorem flowU_mul_neg (H : Matrix ι ι ℂ) (z : ℂ) :
    flowU H z * flowU H (-z) = 1 := by
  rw [← flowU_add, add_neg_cancel, flowU_zero]

theorem flowU_neg_mul (H : Matrix ι ι ℂ) (z : ℂ) :
    flowU H (-z) * flowU H z = 1 := by
  rw [← flowU_add, neg_add_cancel, flowU_zero]

/-- The propagator is norm-continuous in the parameter — the
    finite-dimensional stand-in for the σ-weak continuity clause of the
    KMS-flow characterization. -/
theorem flowU_continuous (H : Matrix ι ι ℂ) : Continuous (flowU H) := by
  open scoped Matrix.Norms.Frobenius in
  exact exp_continuous.comp
    (Continuous.smul (continuous_const.mul continuous_id) continuous_const)

/-- The flow at parameter `0` is the identity. -/
theorem flow_zero (H A : Matrix ι ι ℂ) : flow H 0 A = A := by
  unfold flow
  rw [neg_zero, flowU_zero, one_mul, mul_one]

/-- **Group law**: `σ_{z+w} = σ_z ∘ σ_w`, for all complex parameters. -/
theorem flow_add (H : Matrix ι ι ℂ) (z w : ℂ) (A : Matrix ι ι ℂ) :
    flow H (z + w) A = flow H z (flow H w A) := by
  unfold flow
  rw [flowU_add, show -(z + w) = -w + -z from by ring, flowU_add]
  noncomm_ring

/-- The flow is multiplicative: each `σ_z` is an algebra endomorphism (an
    automorphism, by the group law). -/
theorem flow_mul (H : Matrix ι ι ℂ) (z : ℂ) (A B : Matrix ι ι ℂ) :
    flow H z (A * B) = flow H z A * flow H z B := by
  unfold flow
  calc flowU H z * (A * B) * flowU H (-z)
      = flowU H z * A * (flowU H (-z) * flowU H z) * B * flowU H (-z) := by
        rw [flowU_neg_mul]
        noncomm_ring
    _ = flowU H z * A * flowU H (-z) * (flowU H z * B * flowU H (-z)) := by
        noncomm_ring

theorem flow_one (H : Matrix ι ι ℂ) (z : ℂ) : flow H z 1 = 1 := by
  unfold flow
  rw [mul_one, flowU_mul_neg]

/-- For **conjugation-real** parameters (in particular all real times) the
    propagator is unitary: `U(z)ᴴ = U(−z) = U(z)⁻¹`. -/
theorem flowU_conjTranspose {H : Matrix ι ι ℂ} (hH : H.IsHermitian) {z : ℂ}
    (hz : (starRingEnd ℂ) z = z) : (flowU H z)ᴴ = flowU H (-z) := by
  unfold flowU
  rw [← Matrix.exp_conjTranspose]
  congr 1
  rw [conjTranspose_smul, hH.eq]
  congr 1
  rw [RCLike.star_def, map_mul, Complex.conj_I, hz]
  ring

/-- At **real** times the flow is a ⋆-automorphism: `σ_t(Aᴴ) = σ_t(A)ᴴ`. -/
theorem flow_star_real {H : Matrix ι ι ℂ} (hH : H.IsHermitian) (t : ℝ)
    (A : Matrix ι ι ℂ) : flow H (t : ℂ) Aᴴ = (flow H (t : ℂ) A)ᴴ := by
  have hz : (starRingEnd ℂ) (t : ℂ) = (t : ℂ) := Complex.conj_ofReal t
  have hz' : (starRingEnd ℂ) (-(t : ℂ)) = -(t : ℂ) := by
    rw [map_neg, hz]
  unfold flow
  rw [conjTranspose_mul, conjTranspose_mul, flowU_conjTranspose hH hz,
    flowU_conjTranspose hH hz', neg_neg, Matrix.mul_assoc]

/-! ## State invariance and the analytic anchor -/

section Anchored

variable {ρ H : Matrix ι ι ℂ}

/-- The state commutes with its own propagators (`ρ` is a function of `H`). -/
theorem rho_commute_flowU (hH : IsModularHamiltonian ρ H) (z : ℂ) :
    ρ * flowU H z = flowU H z * ρ := by
  rw [← hH.2]
  unfold flowU
  rw [show (-H : Matrix ι ι ℂ) = (-1 : ℂ) • H from (neg_one_smul ℂ H).symm,
    ← Matrix.exp_add_of_commute _ _
      (((Commute.refl H).smul_left _).smul_right _),
    ← Matrix.exp_add_of_commute _ _
      (((Commute.refl H).smul_left _).smul_right _),
    add_comm]

/-- **State invariance**: `ω ∘ σ_z = ω`, for every complex `z`. -/
theorem state_flow (hH : IsModularHamiltonian ρ H) (z : ℂ)
    (A : Matrix ι ι ℂ) : state ρ (flow H z A) = state ρ A := by
  unfold state flow
  rw [show ρ * (flowU H z * A * flowU H (-z))
      = (ρ * flowU H z) * (A * flowU H (-z)) from by noncomm_ring,
    rho_commute_flowU hH z,
    show flowU H z * ρ * (A * flowU H (-z))
      = flowU H z * (ρ * A * flowU H (-z)) from by noncomm_ring,
    Matrix.trace_mul_comm,
    show ρ * A * flowU H (-z) * flowU H z
      = ρ * A * (flowU H (-z) * flowU H z) from by noncomm_ring,
    flowU_neg_mul, mul_one]

/-- The propagator at `z = i` is the Gibbs weight itself. -/
theorem flowU_I (hH : IsModularHamiltonian ρ H) : flowU H Complex.I = ρ := by
  unfold flowU
  rw [Complex.I_mul_I, neg_one_smul]
  exact hH.2

/-- The propagator at `z = −i` is its inverse. -/
theorem flowU_neg_I (hH : IsModularHamiltonian ρ H) :
    flowU H (-Complex.I) = ρ⁻¹ := by
  have h := flowU_mul_neg H Complex.I
  rw [flowU_I hH] at h
  exact (Matrix.inv_eq_right_inv h).symm

/-- **The analytic anchor: `σ_i = Δ_ρ`.** The value of the flow's entire
    extension at `z = i` is exactly the imaginary-time modular map of T21 —
    the machine-checked bridge between the real-time clock and the algebraic
    KMS step. -/
theorem flow_I_eq_modular (hH : IsModularHamiltonian ρ H)
    (A : Matrix ι ι ℂ) : flow H Complex.I A = modular ρ A := by
  unfold flow modular
  rw [flowU_I hH, flowU_neg_I hH]

/-- **THE KMS BOUNDARY CONDITION** — the textbook form at `β = 1`, with time
    inside: `ω(A·σ_{t+i}(B)) = ω(σ_t(B)·A)`, for ALL complex `t` (in
    particular all real times). One line: the group law moves `σ_i = Δ_ρ`
    out, and T21's `kms` finishes. -/
theorem kms_boundary (hρ : ρ.PosDef) (hH : IsModularHamiltonian ρ H)
    (t : ℂ) (A B : Matrix ι ι ℂ) :
    state ρ (A * flow H (t + Complex.I) B)
      = state ρ (flow H t B * A) := by
  rw [show t + Complex.I = Complex.I + t from by ring, flow_add,
    flow_I_eq_modular hH]
  exact kms ρ hρ A (flow H t B)

end Anchored

/-! ## Uniqueness: KMS pins the Gibbs weight -/

/-- A matrix commuting with every matrix is a scalar (the center of the full
    matrix algebra). -/
theorem eq_smul_one_of_commute_all [Nonempty ι] {X : Matrix ι ι ℂ}
    (h : ∀ B : Matrix ι ι ℂ, X * B = B * X) :
    ∃ c : ℂ, X = c • 1 := by
  obtain ⟨i₀⟩ := (inferInstance : Nonempty ι)
  refine ⟨X i₀ i₀, ?_⟩
  ext i j
  have hij := congrFun (congrFun (h (single j i₀ 1)) i) i₀
  rw [Matrix.mul_single_apply_same, mul_one] at hij
  rw [Matrix.smul_apply, Matrix.one_apply, smul_eq_mul]
  by_cases hij' : i = j
  · subst hij'
    rw [Matrix.single_mul_apply_same, one_mul] at hij
    rw [hij, if_pos rfl, mul_one]
  · rw [Matrix.single_mul_apply_of_ne (h := hij')] at hij
    rw [hij, if_neg hij', mul_zero]

/-- **KMS pins the propagator up to normalization.** Any invertible `V` whose
    conjugation satisfies the algebraic KMS identity against `ω = tr(ρ·)` is
    a scalar multiple of `ρ`. (Engine: T21's `kms_unique` + the center of the
    matrix algebra.) -/
theorem kms_conjugation_eq [Nonempty ι] {ρ V : Matrix ι ι ℂ}
    (hρ : ρ.PosDef) (hV : IsUnit V.det)
    (hkms : ∀ A B, state ρ (A * (V * B * V⁻¹)) = state ρ (B * A)) :
    ∃ c : ℂ, c ≠ 0 ∧ V = c • ρ := by
  have hρdet : IsUnit ρ.det := (Matrix.isUnit_iff_isUnit_det ρ).mp hρ.isUnit
  -- kms_unique: the conjugation IS the modular map
  have hmod : ∀ B, V * B * V⁻¹ = modular ρ B :=
    kms_unique ρ hρ (fun B => V * B * V⁻¹) hkms
  -- hence `ρ⁻¹ V` is central
  have hcomm : ∀ B, (ρ⁻¹ * V) * B = B * (ρ⁻¹ * V) := by
    intro B
    have h := hmod B
    unfold modular at h
    have h1 : ρ⁻¹ * (V * B * V⁻¹) * V = ρ⁻¹ * (ρ * B * ρ⁻¹) * V := by rw [h]
    calc (ρ⁻¹ * V) * B
        = ρ⁻¹ * (V * B * V⁻¹) * V := by
          rw [show ρ⁻¹ * (V * B * V⁻¹) * V
              = ρ⁻¹ * (V * B) * (V⁻¹ * V) from by noncomm_ring,
            Matrix.nonsing_inv_mul V hV, mul_one]
          noncomm_ring
      _ = ρ⁻¹ * (ρ * B * ρ⁻¹) * V := h1
      _ = B * (ρ⁻¹ * V) := by
          rw [show ρ⁻¹ * (ρ * B * ρ⁻¹) * V
              = (ρ⁻¹ * ρ) * (B * (ρ⁻¹ * V)) from by noncomm_ring,
            Matrix.nonsing_inv_mul ρ hρdet, one_mul]
  obtain ⟨c, hc⟩ := eq_smul_one_of_commute_all hcomm
  have hVc : V = c • ρ := by
    have h1 : ρ * (ρ⁻¹ * V) = ρ * (c • 1) := by rw [hc]
    rw [← Matrix.mul_assoc, Matrix.mul_nonsing_inv ρ hρdet, one_mul,
      Matrix.mul_smul, mul_one] at h1
    exact h1
  refine ⟨c, ?_, hVc⟩
  -- `c ≠ 0` since `V` is invertible
  intro hc0
  rw [hc0, zero_smul] at hVc
  rw [hVc, Matrix.det_zero (inferInstance)] at hV
  exact hV.ne_zero rfl

/-- `exp(−K)` is positive definite for Hermitian `K`: it is
    `exp(−K/2)ᴴ·exp(−K/2)` with `exp(−K/2)` invertible. -/
theorem posDef_exp_neg {K : Matrix ι ι ℂ} (hK : K.IsHermitian) :
    (exp (-K) : Matrix ι ι ℂ).PosDef := by
  set M : Matrix ι ι ℂ := exp ((-(1 / 2) : ℂ) • K) with hM
  have hMh : Mᴴ = M := by
    rw [hM, ← Matrix.exp_conjTranspose]
    congr 1
    rw [conjTranspose_smul, hK.eq]
    congr 1
    rw [RCLike.star_def]
    simp [Complex.ext_iff]
  have hMM : exp (-K) = Mᴴ * M := by
    rw [hMh, hM, ← Matrix.exp_add_of_commute _ _
      (((Commute.refl K).smul_left _).smul_right _), ← add_smul]
    norm_num
  have hMunit : M * exp ((1 / 2 : ℂ) • K) = 1 := by
    rw [hM, ← Matrix.exp_add_of_commute _ _
      (((Commute.refl K).smul_left _).smul_right _), ← add_smul]
    rw [show (-(1 / 2 : ℂ)) + 1 / 2 = 0 from by ring, zero_smul, exp_zero]
  have hMinj : Function.Injective M.mulVec :=
    Matrix.mulVec_injective_of_isUnit ⟨⟨M, exp ((1 / 2 : ℂ) • K), hMunit, by
      rw [hM, ← Matrix.exp_add_of_commute _ _
        (((Commute.refl K).smul_left _).smul_right _), ← add_smul]
      rw [show (1 / 2 : ℂ) + -(1 / 2) = 0 from by ring, zero_smul, exp_zero]⟩,
      rfl⟩
  rw [hMM, show Mᴴ * M = Mᴴ * 1 * M from by rw [mul_one]]
  exact Matrix.PosDef.conjTranspose_mul_mul_same Matrix.PosDef.one hMinj

/-- **UNIQUENESS — the Gibbs form of the generator is forced.** If a
    Hamiltonian-implemented flow `τ_z = e^{izK}·(·)·e^{−izK}` (any Hermitian
    `K`) satisfies the algebraic KMS identity at `z = i` against
    `ω = tr(ρ·)`, then

    * its Gibbs weight is the state: `exp(−K) = c·ρ` with `c` REAL and
      positive — `K` is `−log ρ` up to the additive constant that
      conjugation cannot see; and
    * its imaginary-time step IS the modular map of T21.

    So among Hamiltonian flows, the state admits exactly one KMS clock, up to
    the normalization freedom that does not move the flow. -/
theorem hamiltonian_kms_unique [Nonempty ι] {ρ K : Matrix ι ι ℂ}
    (hρ : ρ.PosDef) (hK : K.IsHermitian)
    (hkms : ∀ A B, state ρ (A * flow K Complex.I B) = state ρ (B * A)) :
    (∃ c : ℝ, 0 < c ∧ exp (-K) = (c : ℂ) • ρ) ∧
      (∀ B, flow K Complex.I B = modular ρ B) := by
  -- the imaginary-time propagator is `exp(−K)`
  have hUI : flowU K Complex.I = exp (-K) := by
    unfold flowU
    rw [Complex.I_mul_I, neg_one_smul]
  have hposdef : (exp (-K) : Matrix ι ι ℂ).PosDef := posDef_exp_neg hK
  have hdet : IsUnit (exp (-K) : Matrix ι ι ℂ).det :=
    (Matrix.isUnit_iff_isUnit_det _).mp hposdef.isUnit
  have hUnegI : flowU K (-Complex.I) = (exp (-K) : Matrix ι ι ℂ)⁻¹ := by
    have h := flowU_mul_neg K Complex.I
    rw [hUI] at h
    exact (Matrix.inv_eq_right_inv h).symm
  -- rewrite the flow hypothesis in conjugation form and apply the engine
  have hkms' : ∀ A B, state ρ (A * (exp (-K) * B * (exp (-K))⁻¹))
      = state ρ (B * A) := by
    intro A B
    have h := hkms A B
    unfold flow at h
    rw [hUI, hUnegI] at h
    exact h
  obtain ⟨c, hc0, hceq⟩ := kms_conjugation_eq hρ hdet hkms'
  -- `c` is real and positive: test the quadratic form on a basis vector
  obtain ⟨i₀⟩ := (inferInstance : Nonempty ι)
  have hvne : (Pi.single i₀ 1 : ι → ℂ) ≠ 0 := by
    intro h0
    have := congrFun h0 i₀
    rw [Pi.single_eq_same] at this
    exact one_ne_zero this
  have hEpos : 0 < star (Pi.single i₀ 1 : ι → ℂ) ⬝ᵥ
      (exp (-K) : Matrix ι ι ℂ).mulVec (Pi.single i₀ 1) :=
    hposdef.dotProduct_mulVec_pos hvne
  have hρpos : 0 < star (Pi.single i₀ 1 : ι → ℂ) ⬝ᵥ
      ρ.mulVec (Pi.single i₀ 1) :=
    hρ.dotProduct_mulVec_pos hvne
  have hlink : star (Pi.single i₀ 1 : ι → ℂ) ⬝ᵥ
        (exp (-K) : Matrix ι ι ℂ).mulVec (Pi.single i₀ 1)
      = c * (star (Pi.single i₀ 1 : ι → ℂ) ⬝ᵥ ρ.mulVec (Pi.single i₀ 1)) := by
    rw [hceq, Matrix.smul_mulVec, dotProduct_smul, smul_eq_mul]
  set p : ℂ := star (Pi.single i₀ 1 : ι → ℂ) ⬝ᵥ ρ.mulVec (Pi.single i₀ 1)
    with hp
  set q : ℂ := star (Pi.single i₀ 1 : ι → ℂ) ⬝ᵥ
    (exp (-K) : Matrix ι ι ℂ).mulVec (Pi.single i₀ 1) with hq
  have hpre : 0 < p.re ∧ p.im = 0 := by
    rw [Complex.lt_def] at hρpos
    exact ⟨by simpa using hρpos.1, by simpa using hρpos.2.symm⟩
  have hqre : 0 < q.re ∧ q.im = 0 := by
    rw [Complex.lt_def] at hEpos
    exact ⟨by simpa using hEpos.1, by simpa using hEpos.2.symm⟩
  have hcim : c.im = 0 := by
    have h2 := congrArg Complex.im hlink
    rw [Complex.mul_im, hpre.2, mul_zero, zero_add, hqre.2] at h2
    rcases mul_eq_zero.mp h2.symm with h | h
    · exact h
    · exact absurd h (ne_of_gt hpre.1)
  have hcre : 0 < c.re := by
    have h1 := congrArg Complex.re hlink
    rw [Complex.mul_re, hpre.2, mul_zero, sub_zero] at h1
    have hq1 := hqre.1
    rw [h1] at hq1
    rcases mul_pos_iff.mp hq1 with h | h
    · exact h.1
    · exact absurd hpre.1 (not_lt.mpr (le_of_lt h.2))
  constructor
  · refine ⟨c.re, hcre, ?_⟩
    rw [show ((c.re : ℝ) : ℂ) = c from Complex.ext rfl hcim.symm]
    exact hceq
  · -- the imaginary-time step is the modular map
    intro B
    have h := kms_unique ρ hρ (fun B => flow K Complex.I B) hkms B
    rw [h]

/-! ## [formal-v8] T33 — Skolem–Noether for the matrix algebra

The module's named leftover, closed: **every `ℂ`-algebra automorphism of a
full matrix algebra is inner** (`algEquiv_matrix_inner`). The proof is the
classical intertwiner construction, fully finite-dimensional: the images
`F i j := φ(E i j)` of the matrix units satisfy the matrix-unit relations;
fixing `i₀` and a vector `w ≠ 0` in the range of `F i₀ i₀`, the matrix `U`
with columns `U·e_j = F j i₀ · w` intertwines (`U · E_{jk} = F_{jk} · U`),
hence `U·A = φ(A)·U` for all `A` by linearity; `U` is injective because
`F i₀ k · U · x = (x k) • w`, so `IsUnit U` and `φ(A) = U·A·U⁻¹`.

Consequence for the chain: T28's restriction to Hamiltonian-implemented
flows is *generic at the algebra level* — there are no non-inner
automorphisms a rival "clock" could use. Combined with `kms_conjugation_eq`,
any KMS-satisfying automorphism has conjugator `c • ρ` and *is* the modular
map (`kms_algEquiv_structure`). What remains physics is unchanged: BW
(wedge-boost identification) and the scaling limit. -/

section SkolemNoether

variable [Nonempty ι]

/-- **T33 — SKOLEM–NOETHER (matrix algebra, finite dimension).** Every
    `ℂ`-algebra automorphism of `Matrix ι ι ℂ` is inner. -/
theorem algEquiv_matrix_inner (φ : Matrix ι ι ℂ ≃ₐ[ℂ] Matrix ι ι ℂ) :
    ∃ U : Matrix ι ι ℂ, IsUnit U.det ∧ ∀ A, φ A = U * A * U⁻¹ := by
  classical
  set F : ι → ι → Matrix ι ι ℂ := fun i j => φ (single i j 1) with hF
  -- matrix-unit relations transport through φ
  have hFmul_same : ∀ i j k, F i j * F j k = F i k := by
    intro i j k
    rw [hF]
    simp only
    rw [← map_mul, single_mul_single_same, one_mul]
  have hFmul_ne : ∀ (i j k l : ι), j ≠ k → F i j * F k l = 0 := by
    intro i j k l hjk
    rw [hF]
    simp only
    rw [← map_mul,
      show (single i j (1 : ℂ) : Matrix ι ι ℂ) * single k l 1 = 0 from by
        simp [hjk],
      map_zero]
  obtain ⟨i₀⟩ := (inferInstance : Nonempty ι)
  -- a nonzero vector in the range of `F i₀ i₀`
  have hFne : F i₀ i₀ ≠ 0 := by
    intro h0
    have h1 : φ (single i₀ i₀ (1 : ℂ)) = φ 0 := by
      rw [map_zero]
      exact h0
    have h2 := φ.injective h1
    have h3 := congrFun (congrFun h2 i₀) i₀
    simp [Matrix.single, Matrix.of_apply] at h3
  obtain ⟨a, b, hab⟩ : ∃ a b, F i₀ i₀ a b ≠ 0 := by
    by_contra hall
    push_neg at hall
    exact hFne (by ext a b; rw [hall a b, Matrix.zero_apply])
  set w : ι → ℂ := (F i₀ i₀) *ᵥ Pi.single b 1 with hwdef
  have hw : w ≠ 0 := by
    intro h0
    have h1 := congrFun h0 a
    rw [hwdef, mulVec_single_one] at h1
    exact hab h1
  have hFw : (F i₀ i₀) *ᵥ w = w := by
    rw [hwdef, mulVec_mulVec, hFmul_same]
  -- the intertwiner: column `j` of `U` is `F j i₀ · w`
  set U : Matrix ι ι ℂ := Matrix.of fun a j => ((F j i₀) *ᵥ w) a with hU
  have hUcol : ∀ j, U.col j = (F j i₀) *ᵥ w := fun j => rfl
  have hupdate : ∀ (a : ι) (v : ℂ),
      Function.update (0 : ι → ℂ) a v = Pi.single a v := by
    intro a v
    ext c
    simp [Function.update_apply, Pi.single_apply]
  -- `U` intertwines the matrix units
  have hUE : ∀ j k, U * single j k 1 = F j k * U := by
    intro j k
    apply ext_of_mulVec_single
    intro c
    rw [← mulVec_mulVec, ← mulVec_mulVec, single_mulVec]
    rw [mulVec_single_one, hUcol, mulVec_mulVec]
    by_cases hc : c = k
    · subst hc
      rw [Pi.single_eq_same, mul_one, hupdate j 1, mulVec_single_one, hUcol,
        hFmul_same]
    · rw [Pi.single_eq_of_ne (Ne.symm hc), mul_zero, hupdate j 0,
        Pi.single_zero, mulVec_zero, hFmul_ne j k c i₀ (Ne.symm hc),
        zero_mulVec]
  -- hence `U` intertwines everything, by linearity
  have hUA : ∀ A : Matrix ι ι ℂ, U * A = φ A * U := by
    intro A
    conv_lhs => rw [matrix_eq_sum_single A]
    conv_rhs => rw [matrix_eq_sum_single A]
    rw [map_sum, Finset.mul_sum, Finset.sum_mul]
    refine Finset.sum_congr rfl fun j _ => ?_
    rw [map_sum, Finset.mul_sum, Finset.sum_mul]
    refine Finset.sum_congr rfl fun k _ => ?_
    have hsm : single j k (A j k) = (A j k) • single j k (1 : ℂ) := by
      rw [smul_single, smul_eq_mul, mul_one]
    rw [hsm, mul_smul_comm, hUE, map_smul, smul_mul_assoc]
  -- `U` is injective, hence invertible
  have hUinj : Function.Injective (U.mulVec) := by
    have hker : ∀ x : ι → ℂ, U *ᵥ x = 0 → x = 0 := by
      intro x hx
      funext k
      show x k = 0
      have h1 : F i₀ k *ᵥ (U *ᵥ x) = 0 := by
        rw [hx, mulVec_zero]
      rw [mulVec_mulVec, ← hUE, ← mulVec_mulVec, single_mulVec, one_mul,
        hupdate i₀ (x k)] at h1
      have hsingle : (Pi.single i₀ (x k) : ι → ℂ)
          = x k • (Pi.single i₀ 1 : ι → ℂ) := by
        ext j'
        simp [Pi.single_apply]
      rw [hsingle, mulVec_smul, mulVec_single_one, hUcol, hFw] at h1
      rcases smul_eq_zero.mp h1 with h | h
      · exact h
      · exact absurd h hw
    intro x y hxy
    have hsub : U *ᵥ (x - y) = 0 := by
      rw [mulVec_sub, hxy, sub_self]
    exact sub_eq_zero.mp (hker _ hsub)
  have hdet : IsUnit U.det :=
    (Matrix.isUnit_iff_isUnit_det U).mp (mulVec_injective_iff_isUnit.mp hUinj)
  refine ⟨U, hdet, fun A => ?_⟩
  calc φ A = φ A * (U * U⁻¹) := by
        rw [Matrix.mul_nonsing_inv U hdet, mul_one]
    _ = (φ A * U) * U⁻¹ := by rw [mul_assoc]
    _ = (U * A) * U⁻¹ := by rw [← hUA]

/-- **T33 + T21 + T28 — the KMS automorphism structure theorem.** Any
    `ℂ`-algebra automorphism satisfying the KMS identity against
    `ω = tr(ρ·)` (i) IS the modular map, and (ii) is inner with conjugator
    a positive multiple of `ρ` itself. Nothing about the implementing form
    was assumed: Skolem–Noether makes the Hamiltonian/conjugation form
    generic, and the KMS condition then pins the conjugator to the state. -/
theorem kms_algEquiv_structure {ρ : Matrix ι ι ℂ} (hρ : ρ.PosDef)
    (φ : Matrix ι ι ℂ ≃ₐ[ℂ] Matrix ι ι ℂ)
    (hkms : ∀ A B, state ρ (A * φ B) = state ρ (B * A)) :
    (∀ B, φ B = modular ρ B) ∧
      ∃ U : Matrix ι ι ℂ, IsUnit U.det ∧ (∀ A, φ A = U * A * U⁻¹) ∧
        ∃ c : ℂ, c ≠ 0 ∧ U = c • ρ := by
  obtain ⟨U, hdet, hconj⟩ := algEquiv_matrix_inner φ
  have hkms' : ∀ A B, state ρ (A * (U * B * U⁻¹)) = state ρ (B * A) := by
    intro A B
    rw [← hconj B]
    exact hkms A B
  obtain ⟨c, hc0, hcρ⟩ := kms_conjugation_eq hρ hdet hkms'
  exact ⟨kms_unique ρ hρ (fun B => φ B) hkms, U, hdet, hconj, c, hc0, hcρ⟩

end SkolemNoether

/-! ### Axiom audit -/
#print axioms exists_modularHamiltonian
#print axioms flow_add
#print axioms flow_mul
#print axioms flowU_continuous
#print axioms flow_star_real
#print axioms state_flow
#print axioms flow_I_eq_modular
#print axioms kms_boundary
#print axioms kms_conjugation_eq
#print axioms posDef_exp_neg
#print axioms hamiltonian_kms_unique
#print axioms algEquiv_matrix_inner
#print axioms kms_algEquiv_structure

end OPHProofChain.Modular
