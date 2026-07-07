import Mathlib

/-!
# The finite (type-I) modular core of D3 — state-determined dynamics

**Status of this module: native to `chi_nu_test/` (no ported source text —
the theorems below are the standard finite-dimensional Tomita–Takesaki
facts, stated and proved from scratch for this tree).**

## What this is

Proof-chain link **L2.2 / D3** ("modular flow → Lorentz", compact paper
`:1062`) was graded through v4 as *"the one Layer-2 link with no isolable
finite-mathematics core"* — its tex chain runs through Bisognano–Wichmann
modular geometry, conformal classification on `S²`, and weak-*/GNS
extraction. This module corrects that grading: the D3 row itself says the
scaling-limit theorem starts from a **finite type-I regulator class**
("the scaling-limit observer algebra may leave the finite type-I regulator
class … `K_C = 2πB_C` is only the special type-I limit form"), and in that
finite class modular theory *is* isolable finite mathematics. Here it is,
machine-checked:

* **Existence** (`kms`): for a faithful state `ω(A) = tr(ρA)` (`ρ`
  positive definite) on a finite matrix algebra, the modular map
  `Δ_ρ(A) = ρAρ⁻¹` satisfies the algebraic KMS identity at imaginary unit
  time, `ω(A · Δ_ρ(B)) = ω(B · A)` — the state's twisted trace property.
* **Uniqueness** (`kms_unique`): *any* map `D` with
  `ω(A · D(B)) = ω(B·A)` for all `A, B` **equals** `Δ_ρ` — no linearity,
  continuity, or automorphism structure assumed. The KMS demand alone pins
  the dynamics.
* **Automorphism structure** (`modular_mul`, `modular_one`, `modular_add`,
  `modular_smul`, `modular_left_inverse`, `modular_iterate`): `Δ_ρ` is a
  unital algebra automorphism whose `k`-fold iterate is conjugation by
  `ρᵏ` — the integer-step imaginary-time iterate. (The genuine real-time
  one-parameter group `σ_t = ρ^{it}(·)ρ^{−it}`, entire in the parameter, is
  `ModularFlow.lean` — `[formal-v7]`, closing holes-audit F9.)
* **State invariance** (`state_modular`): `ω ∘ Δ_ρ = ω`.
* **Triviality ⟺ traciality** (`modular_eq_id_iff_tracial`): the modular
  flow is trivial exactly when `ω` is a trace. *Every non-tracial state
  ticks.* Both directions fall out of existence + uniqueness in one line
  each — the point of having both.
* **`ω` is a faithful state** (`state_one`, `state_star`, `state_nonneg`,
  `state_faithful`): unit, reality, positivity, faithfulness — the
  standing hypotheses of modular theory, discharged rather than assumed.
* **Non-vacuity** (`qubitState_modular_ne_id`): the qubit state
  `ρ ∝ diag(1,2)` has `Δ_ρ(E₀₁) = ½·E₀₁ ≠ E₀₁` — a concrete faithful
  state whose modular clock genuinely ticks. (Scaling `ρ ↦ cρ` does not
  change `Δ_ρ` — `modular_smul_rho` — so normalization is immaterial to
  the flow.)

## The physics reading (and the honest fence)

An OPH patch is a *finite* system; its record algebra is a finite matrix
algebra, i.e. exactly the type-I regulator class of the D3 row. The
theorems above say: **a faithful patch state does not need dynamics as
extra structure — it already carries a unique KMS-consistent flow, and
that flow is trivial only for the maximally-mixed (tracial) kind of
state.** This is the finite core of "thermal time".

What this module deliberately does **not** establish — the actual D3
physics, which stays fully open and named:

* the **Bisognano–Wichmann identification** of the modular flow of a
  wedge/cap state with *geometric boosts* (Theorem `thm:bw`) — this needs
  the supports, the cap net, and the scaling limit;
* the **scaling limit** itself (weak-*/GNS extraction, possible exit from
  type I, `K_C = 2πB_C` as the type-I limit form);
* **real-time** modular flow `Δ^{it}` (needs functional calculus /
  spectral theory; the flow here is the imaginary-time / algebraic
  skeleton, which is what the KMS identity constrains in finite
  dimensions);
* everything downstream (Lorentz branch, `H³` charts — D3's corollaries).

Consequence for the proof chain: §7's "D3 has no isolable
finite-mathematics core" is **retired**; D3 now sits exactly where the
other Layer-2 links sit — a machine-checked finite core consuming a named
physical identification.

Axioms: standard (`propext`, `Classical.choice`, `Quot.sound`); no
`sorry`, no `native_decide`.
-/

namespace OPHProofChain.Modular

open Matrix
open scoped ComplexOrder

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The state defined by a density matrix: `ω(A) = tr(ρA)`. -/
noncomputable def state (ρ A : Matrix ι ι ℂ) : ℂ := (ρ * A).trace

/-- The (imaginary-time) modular map of `ρ`: `Δ_ρ(A) = ρ A ρ⁻¹`. -/
noncomputable def modular (ρ A : Matrix ι ι ℂ) : Matrix ι ι ℂ := ρ * A * ρ⁻¹

/-! ### Trace nondegeneracy — the workhorse -/

/-- The trace pairing is nondegenerate: a matrix orthogonal to every `B`
    under `(B, X) ↦ tr(BX)` vanishes. (Test against the matrix units.) -/
theorem eq_zero_of_forall_mul_trace_eq_zero {X : Matrix ι ι ℂ}
    (h : ∀ B : Matrix ι ι ℂ, (B * X).trace = 0) : X = 0 := by
  ext i j
  have hone := h (single j i 1)
  have hsum : (single j i (1 : ℂ) * X).trace = X i j := by
    have h0 : ∀ k ∈ Finset.univ, k ≠ j → (single j i (1 : ℂ) * X).diag k = 0 := by
      intro k _ hk
      rw [Matrix.diag_apply, Matrix.single_mul_apply_of_ne (h := hk)]
    calc (single j i (1 : ℂ) * X).trace
        = (single j i (1 : ℂ) * X).diag j :=
          Finset.sum_eq_single j h0 (fun hmem => absurd (Finset.mem_univ j) hmem)
      _ = X i j := by
          rw [Matrix.diag_apply, Matrix.single_mul_apply_same, one_mul]
  rw [hsum] at hone
  simpa using hone

/-! ### The modular map is a unital algebra automorphism -/

theorem modular_one (ρ : Matrix ι ι ℂ) (hρ : ρ.PosDef) :
    modular ρ 1 = 1 := by
  unfold modular
  rw [mul_one, Matrix.mul_nonsing_inv _ ((Matrix.isUnit_iff_isUnit_det ρ).mp hρ.isUnit)]

theorem modular_mul (ρ : Matrix ι ι ℂ) (hρ : ρ.PosDef) (A B : Matrix ι ι ℂ) :
    modular ρ (A * B) = modular ρ A * modular ρ B := by
  unfold modular
  have hinv : ρ⁻¹ * ρ = 1 :=
    Matrix.nonsing_inv_mul _ ((Matrix.isUnit_iff_isUnit_det ρ).mp hρ.isUnit)
  calc ρ * (A * B) * ρ⁻¹ = ρ * A * (ρ⁻¹ * ρ) * B * ρ⁻¹ := by
        rw [hinv]
        noncomm_ring
    _ = ρ * A * ρ⁻¹ * (ρ * B * ρ⁻¹) := by noncomm_ring

theorem modular_add (ρ A B : Matrix ι ι ℂ) :
    modular ρ (A + B) = modular ρ A + modular ρ B := by
  unfold modular
  noncomm_ring

theorem modular_smul (ρ : Matrix ι ι ℂ) (c : ℂ) (A : Matrix ι ι ℂ) :
    modular ρ (c • A) = c • modular ρ A := by
  unfold modular
  rw [Matrix.mul_smul, Matrix.smul_mul]

/-- The modular map is invertible (conjugation back by `ρ`): the flow is a
    genuine automorphism, not merely an endomorphism. -/
theorem modular_left_inverse (ρ : Matrix ι ι ℂ) (hρ : ρ.PosDef)
    (A : Matrix ι ι ℂ) : ρ⁻¹ * modular ρ A * ρ = A := by
  unfold modular
  have hdet := (Matrix.isUnit_iff_isUnit_det ρ).mp hρ.isUnit
  calc ρ⁻¹ * (ρ * A * ρ⁻¹) * ρ = (ρ⁻¹ * ρ) * A * (ρ⁻¹ * ρ) := by noncomm_ring
    _ = A := by rw [Matrix.nonsing_inv_mul _ hdet, one_mul, mul_one]

/-- The `k`-fold iterate of the modular map is conjugation by `ρᵏ`: the
    integer-step imaginary-time iterate (ℕ-indexed; the genuine
    one-parameter group is `ModularFlow.lean`, v7). -/
theorem modular_iterate (ρ : Matrix ι ι ℂ) (k : ℕ) (A : Matrix ι ι ℂ) :
    (modular ρ)^[k] A = ρ ^ k * A * ρ⁻¹ ^ k := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [Function.iterate_succ_apply', ih]
    unfold modular
    rw [pow_succ' ρ k, pow_succ ρ⁻¹ k]
    noncomm_ring

/-- Scale invariance `Δ_{cρ} = Δ_ρ` (`c ≠ 0`): the modular flow depends on
    the state's *shape*, not its normalization — un-normalized density
    matrices compute the same flow. -/
theorem modular_smul_rho (ρ : Matrix ι ι ℂ) {c : ℂ} (hc : c ≠ 0)
    (hρ : IsUnit ρ.det) (A : Matrix ι ι ℂ) :
    modular (c • ρ) A = modular ρ A := by
  unfold modular
  have hinv : (c • ρ)⁻¹ = c⁻¹ • ρ⁻¹ := by
    apply Matrix.inv_eq_right_inv
    rw [Matrix.smul_mul, Matrix.mul_smul, smul_smul, mul_inv_cancel₀ hc,
      Matrix.mul_nonsing_inv _ hρ, one_smul]
  rw [hinv, Matrix.smul_mul, Matrix.smul_mul, Matrix.mul_smul, smul_smul,
    mul_inv_cancel₀ hc, one_smul]

/-! ### Existence: the KMS identity -/

/-- **EXISTENCE (the KMS identity at imaginary unit time).** The modular
    map of `ρ` satisfies `ω(A · Δ_ρ(B)) = ω(B · A)`: two trace cyclings.
    This is the finite-dimensional shadow of the KMS boundary condition
    `ω(A σ_i(B)) = ω(BA)`. -/
theorem kms (ρ : Matrix ι ι ℂ) (hρ : ρ.PosDef) (A B : Matrix ι ι ℂ) :
    state ρ (A * modular ρ B) = state ρ (B * A) := by
  unfold state modular
  have hdet := (Matrix.isUnit_iff_isUnit_det ρ).mp hρ.isUnit
  calc (ρ * (A * (ρ * B * ρ⁻¹))).trace
      = ((ρ * A * ρ * B) * ρ⁻¹).trace := by
        rw [show ρ * (A * (ρ * B * ρ⁻¹)) = (ρ * A * ρ * B) * ρ⁻¹ from by
          noncomm_ring]
    _ = (ρ⁻¹ * (ρ * A * ρ * B)).trace := Matrix.trace_mul_comm _ _
    _ = ((A * ρ * B) : Matrix ι ι ℂ).trace := by
        rw [show ρ⁻¹ * (ρ * A * ρ * B) = (ρ⁻¹ * ρ) * (A * ρ * B) from by
          noncomm_ring, Matrix.nonsing_inv_mul _ hdet, one_mul]
    _ = ((ρ * B) * A).trace := by rw [Matrix.mul_assoc, Matrix.trace_mul_comm]
    _ = (ρ * (B * A)).trace := by rw [Matrix.mul_assoc]

/-- The state is invariant under its own modular flow (`A := 1` in KMS). -/
theorem state_modular (ρ : Matrix ι ι ℂ) (hρ : ρ.PosDef) (B : Matrix ι ι ℂ) :
    state ρ (modular ρ B) = state ρ B := by
  have := kms ρ hρ 1 B
  simpa using this

/-! ### Uniqueness: the KMS demand pins the dynamics -/

/-- **UNIQUENESS.** Any map `D` (not assumed linear, continuous, or
    multiplicative) satisfying the KMS identity against the faithful state
    `ω = tr(ρ·)` **is** the modular map. The state alone determines its
    dynamics — the finite core of "thermal time". -/
theorem kms_unique (ρ : Matrix ι ι ℂ) (hρ : ρ.PosDef)
    (D : Matrix ι ι ℂ → Matrix ι ι ℂ)
    (hD : ∀ A B, state ρ (A * D B) = state ρ (B * A)) :
    ∀ B, D B = modular ρ B := by
  intro B
  have hdet := (Matrix.isUnit_iff_isUnit_det ρ).mp hρ.isUnit
  -- testing against `A := ρ⁻¹C` turns the state into the bare trace pairing
  have hred : ∀ C X : Matrix ι ι ℂ, state ρ ((ρ⁻¹ * C) * X) = (C * X).trace := by
    intro C X
    unfold state
    rw [show ρ * (ρ⁻¹ * C * X) = (ρ * ρ⁻¹) * (C * X) from by noncomm_ring,
      Matrix.mul_nonsing_inv _ hdet, one_mul]
  have key : ∀ C : Matrix ι ι ℂ, (C * (D B - modular ρ B)).trace = 0 := by
    intro C
    have h3 : state ρ ((ρ⁻¹ * C) * D B) = state ρ ((ρ⁻¹ * C) * modular ρ B) := by
      rw [hD (ρ⁻¹ * C) B, kms ρ hρ (ρ⁻¹ * C) B]
    rw [hred, hred] at h3
    rw [Matrix.mul_sub, Matrix.trace_sub, h3, sub_self]
  exact sub_eq_zero.mp (eq_zero_of_forall_mul_trace_eq_zero key)

/-! ### Triviality ⟺ traciality — both directions from existence + uniqueness -/

/-- **The modular flow is trivial exactly for tracial states.** Forward:
    if `Δ_ρ = id` then KMS *is* traciality. Backward: if `ω` is tracial
    then `id` satisfies the KMS identity, so uniqueness forces `Δ_ρ = id`.
    Every non-tracial state ticks; the maximally mixed kind of state (and
    only that kind) is dynamically silent. -/
theorem modular_eq_id_iff_tracial (ρ : Matrix ι ι ℂ) (hρ : ρ.PosDef) :
    (∀ A, modular ρ A = A) ↔ (∀ A B, state ρ (A * B) = state ρ (B * A)) := by
  constructor
  · intro h A B
    conv_lhs => rw [← h B]
    exact kms ρ hρ A B
  · intro h B
    exact (kms_unique ρ hρ id (fun A B => h A B) B).symm

/-! ### `ω` is a faithful state — the standing hypotheses, discharged -/

/-- Unit: `ω(1) = 1` for a normalized density matrix. -/
theorem state_one (ρ : Matrix ι ι ℂ) (htr : ρ.trace = 1) : state ρ 1 = 1 := by
  unfold state
  rw [mul_one, htr]

/-- Reality: `ω(Aᴴ) = ω(A)*` (uses only hermiticity of `ρ`). -/
theorem state_star (ρ : Matrix ι ι ℂ) (hρ : ρ.IsHermitian) (A : Matrix ι ι ℂ) :
    state ρ Aᴴ = star (state ρ A) := by
  unfold state
  rw [← Matrix.trace_conjTranspose, Matrix.conjTranspose_mul, hρ.eq,
    Matrix.trace_mul_comm]

/-- The diagonal entries of `A ρ Aᴴ` are the `ρ`-quadratic forms of the
    starred rows of `A` — the bridge from traces to positivity. -/
private theorem diag_conj_eq_form (ρ A : Matrix ι ι ℂ) (k : ι) :
    (A * ρ * Aᴴ) k k = star (star (A k)) ⬝ᵥ ρ.mulVec (star (A k)) := by
  simp only [Matrix.mul_apply, Matrix.conjTranspose_apply, dotProduct,
    Matrix.mulVec, star_star, Pi.star_apply, Finset.mul_sum, Finset.sum_mul]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => by ring

/-- Cycling `ω(AᴴA)` into the conjugated form `tr(A ρ Aᴴ)`. -/
private theorem state_conj_trace (ρ A : Matrix ι ι ℂ) :
    state ρ (Aᴴ * A) = (A * ρ * Aᴴ).trace := by
  unfold state
  calc (ρ * (Aᴴ * A)).trace
      = ((ρ * Aᴴ) * A).trace := by rw [Matrix.mul_assoc]
    _ = (A * (ρ * Aᴴ)).trace := Matrix.trace_mul_comm _ _
    _ = (A * ρ * Aᴴ).trace := by rw [Matrix.mul_assoc]

/-- Positivity: `0 ≤ ω(AᴴA)` (in the star order of `ℂ`). -/
theorem state_nonneg (ρ : Matrix ι ι ℂ) (hρ : ρ.PosDef) (A : Matrix ι ι ℂ) :
    0 ≤ state ρ (Aᴴ * A) := by
  rw [state_conj_trace]
  unfold Matrix.trace
  refine Finset.sum_nonneg fun k _ => ?_
  rw [Matrix.diag_apply, diag_conj_eq_form]
  exact hρ.posSemidef.dotProduct_mulVec_nonneg _

/-- **Faithfulness**: `ω(AᴴA) = 0` forces `A = 0`. With `state_one`,
    `state_star`, and `state_nonneg` this discharges the standing
    "faithful state" hypotheses of modular theory for `ω = tr(ρ·)`, from
    positive definiteness alone. -/
theorem state_faithful (ρ : Matrix ι ι ℂ) (hρ : ρ.PosDef) (A : Matrix ι ι ℂ)
    (h : state ρ (Aᴴ * A) = 0) : A = 0 := by
  rw [state_conj_trace] at h
  unfold Matrix.trace at h
  have hzero : ∀ k : ι, (A * ρ * Aᴴ).diag k = 0 := by
    have hnneg : ∀ k : ι, k ∈ Finset.univ → 0 ≤ (A * ρ * Aᴴ).diag k := by
      intro k _
      rw [Matrix.diag_apply, diag_conj_eq_form]
      exact hρ.posSemidef.dotProduct_mulVec_nonneg _
    intro k
    exact (Finset.sum_eq_zero_iff_of_nonneg hnneg).mp h k (Finset.mem_univ k)
  have hrow : ∀ k, star (A k) = 0 := by
    intro k
    by_contra hx
    have hpos := hρ.dotProduct_mulVec_pos hx
    have hzero' : (A * ρ * Aᴴ) k k = 0 := by
      have := hzero k
      rwa [Matrix.diag_apply] at this
    rw [← diag_conj_eq_form ρ A k, hzero'] at hpos
    exact lt_irrefl 0 hpos
  ext k j
  have := congrFun (hrow k) j
  simpa using this

/-! ### Non-vacuity: the qubit's modular clock ticks -/

/-- The (un-normalized) qubit density matrix `diag(1, 2)`. -/
noncomputable def qubitRho : Matrix (Fin 2) (Fin 2) ℂ := Matrix.diagonal ![1, 2]

theorem qubitRho_posDef : qubitRho.PosDef := by
  unfold qubitRho
  rw [Matrix.posDef_diagonal_iff]
  intro i
  fin_cases i
  · simpa using (zero_lt_one : (0 : ℂ) < 1)
  · simpa using (zero_lt_two : (0 : ℂ) < 2)

/-- Its inverse is `diag(1, ½)` (verified by multiplication). -/
theorem qubitRho_inv : qubitRho⁻¹ = Matrix.diagonal ![1, (2 : ℂ)⁻¹] := by
  apply Matrix.inv_eq_right_inv
  unfold qubitRho
  rw [Matrix.diagonal_mul_diagonal]
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [Matrix.diagonal_apply, Matrix.one_apply] <;> norm_num

/-- **The qubit's modular flow is nontrivial**: on the off-diagonal matrix
    unit, `Δ_ρ(E₀₁) = ½ • E₀₁ ≠ E₀₁`. A concrete faithful state whose KMS
    dynamics genuinely ticks — the modular clock of the simplest
    unequal-weights record. -/
theorem qubitState_modular_ne_id :
    modular qubitRho (Matrix.single 0 1 1) = (2 : ℂ)⁻¹ • Matrix.single 0 1 1 ∧
    modular qubitRho (Matrix.single 0 1 1) ≠ Matrix.single 0 1 1 := by
  have hmod : modular qubitRho (Matrix.single 0 1 1)
      = (2 : ℂ)⁻¹ • Matrix.single 0 1 1 := by
    unfold modular
    rw [qubitRho_inv]
    unfold qubitRho
    ext i j
    fin_cases i <;> fin_cases j <;>
      simp [Matrix.mul_apply, Matrix.diagonal_apply, Matrix.single_apply,
        Matrix.smul_apply, Fin.sum_univ_two, smul_eq_mul] <;> norm_num
  refine ⟨hmod, ?_⟩
  rw [hmod]
  intro hcontra
  have h01 := congrFun (congrFun hcontra 0) 1
  rw [Matrix.smul_apply, Matrix.single_apply_same, smul_eq_mul, mul_one] at h01
  exact (by norm_num : ((2 : ℂ)⁻¹ ≠ 1)) h01

/-! ### Axiom audit -/
#print axioms eq_zero_of_forall_mul_trace_eq_zero
#print axioms modular_one
#print axioms modular_mul
#print axioms modular_add
#print axioms modular_smul
#print axioms modular_left_inverse
#print axioms modular_iterate
#print axioms modular_smul_rho
#print axioms kms
#print axioms state_modular
#print axioms kms_unique
#print axioms modular_eq_id_iff_tracial
#print axioms state_one
#print axioms state_star
#print axioms state_nonneg
#print axioms state_faithful
#print axioms qubitRho_posDef
#print axioms qubitState_modular_ne_id

end OPHProofChain.Modular