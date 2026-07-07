import Mathlib
import OPHProofChain.EinsteinBranch

/-!
# The cosmological-constant step (T26, `[formal-v6.1]`)

`EinsteinBranch.lean` (T14) ends with `jacobson_step`: at **one point**,
null-cone matching forces `F = κT + λη` — for some number `λ` *at that
point*. Over a region this yields a scalar **field** `λ(x)`, and calling
it "the cosmological constant" is exactly one mathematical step early:
Jacobson's own derivation closes with the contracted Bianchi identity
`∇·G ≡ 0` and local stress conservation `∇·T = 0`, which force `∇λ = 0` —
only then is `λ` a single constant. The adversarial audit
(`OPH_PROOF_CHAIN_HOLES.md`, F8) correctly flagged that this closing step
was written mathematics consumed by the chain but neither formalized nor
named. This module formalizes it, in the chain's own finite-algebra style.

**The discrete rendering.** Spacetime points form a chart `P` with a
successor map `step i : P → P` in each of the `n+1` coordinate directions
(a discrete chart; e.g. `ℕ^{n+1}` with coordinate increments). Fields are
matrix-valued functions on `P`; the discrete divergence contracts the
first index against forward differences,

```
ddiv M p j  =  ∑ i, (M (step i p) i j − M p i j),
```

the first-order shadow of `(∇·M)_j = ∂_i M^{i}{}_j`. Then:

* `ddiv_lam_eta` — for the pure-trace field `p ↦ λ(p)·η` the divergence
  is the η-contracted discrete gradient of `λ` (the continuum Leibniz
  step, exact here because `η` is constant);
* `row_eta_cancel` — `η` is diagonal with unit entries, so a vanishing
  η-contracted gradient vanishes componentwise;
* `step_invariant_of_divergence_free` — **the constancy mechanism**: if
  `F = κT + λ·η` pointwise and both `F` and `T` are divergence-free, the
  discrete gradient of `λ` vanishes: `λ(step i p) = λ(p)` for every
  direction at every point;
* `lambda_constant` — on a chart whose points are all step-reachable from
  a base point, `λ` is a single constant `Λ`;
* **`einstein_equation_with_constant` (T26)** — the composition with
  T14c: null-cone matching **at every point** + divergence-freeness of
  both sides *(the two named inputs: the contracted Bianchi identity for
  the geometric side, local stress conservation for the matter side)* +
  chart connectivity ⟹ `F = κT + Λη` with **one** constant `Λ` across
  all points. The Einstein equation ends with a constant, not a field.
* `lambda_not_constant_without_connectivity` — the connectivity
  hypothesis is load-bearing: on a disconnected two-point chart the same
  pointwise + divergence hypotheses admit a genuinely non-constant `λ`.

## Honest scope

The Bianchi identity and stress conservation are consumed as **named
hypotheses** (`hdivF`, `hdivT`) — they are the geometry/physics inputs,
exactly as the variational identities are in T14; what is machine-checked
is the *argument* that they force constancy, which was the missing
mathematics. The discrete chart is the first-order shadow of the
continuum statement (forward differences for `∂`); the continuum PDE
version belongs to the D-branch physics with the rest of the analysis.
Nothing here derives the null-cone matching itself (that is T14's
variational package upstream).

Axioms: standard; no `sorry`, no `native_decide`.
-/

namespace OPHProofChain.EinsteinBranch

variable {n : ℕ}

/-! ### The discrete chart and divergence -/

/-- The discrete partial difference of a scalar field in direction `i`. -/
def dpar {P : Type} (step : Fin (n + 1) → P → P) (f : P → ℝ)
    (i : Fin (n + 1)) (p : P) : ℝ :=
  f (step i p) - f p

/-- The discrete divergence of a matrix field: forward differences of the
    first index, contracted. -/
def ddiv {P : Type} (step : Fin (n + 1) → P → P) (M : P → Mat n)
    (p : P) (j : Fin (n + 1)) : ℝ :=
  ∑ i, (M (step i p) i j - M p i j)

/-- One point is step-reachable from another. -/
def Reachable {P : Type} (step : Fin (n + 1) → P → P) : P → P → Prop :=
  Relation.ReflTransGen (fun p q => ∃ i, q = step i p)

/-! ### The Leibniz step and the η-cancellation -/

/-- The divergence of the pure-trace field `p ↦ λ(p)·η` is the
    η-contracted discrete gradient of `λ`. -/
theorem ddiv_lam_eta {P : Type} (step : Fin (n + 1) → P → P) (lam : P → ℝ)
    (p : P) (j : Fin (n + 1)) :
    ddiv step (fun q => fun i j' => lam q * eta n i j') p j
      = ∑ i, dpar step lam i p * eta n i j := by
  unfold ddiv dpar
  apply Finset.sum_congr rfl
  intro i _
  ring

/-- `η` is diagonal with unit entries: a row vector whose η-contraction
    vanishes at every column vanishes componentwise. -/
theorem row_eta_cancel (r : Fin (n + 1) → ℝ)
    (h : ∀ j, ∑ i, r i * eta n i j = 0) : ∀ i, r i = 0 := by
  intro j
  have hsum := h j
  have hsingle : ∑ i, r i * eta n i j = r j * eta n j j := by
    apply Finset.sum_eq_single j
    · intro b _ hb
      rw [eta_off_diag hb, mul_zero]
    · intro habs
      exact absurd (Finset.mem_univ j) habs
  rw [hsingle] at hsum
  by_cases hj : j = 0
  · subst hj
    rw [eta_zero_zero] at hsum
    linarith
  · rw [eta_diag_spatial hj] at hsum
    linarith

/-! ### The constancy mechanism -/

/-- **The discrete gradient of `λ` vanishes.** If `F = κT + λ·η`
    pointwise and both `F` and `T` are divergence-free (the named Bianchi
    and conservation inputs), then `λ` is invariant along every
    coordinate step. -/
theorem step_invariant_of_divergence_free {P : Type}
    (step : Fin (n + 1) → P → P) (F T : P → Mat n) (lam : P → ℝ) (κ : ℝ)
    (hpoint : ∀ p, ∀ i j, F p i j = κ * T p i j + lam p * eta n i j)
    (hdivF : ∀ p j, ddiv step F p j = 0)
    (hdivT : ∀ p j, ddiv step T p j = 0) :
    ∀ (i : Fin (n + 1)) (p : P), lam (step i p) = lam p := by
  intro i p
  -- the divergence of the trace part vanishes by linearity
  have htrace : ∀ j, ∑ i', dpar step lam i' p * eta n i' j = 0 := by
    intro j
    have hlin : ∑ i', dpar step lam i' p * eta n i' j
        = ddiv step F p j - κ * ddiv step T p j := by
      rw [← ddiv_lam_eta step lam p j]
      unfold ddiv
      rw [Finset.mul_sum, ← Finset.sum_sub_distrib]
      apply Finset.sum_congr rfl
      intro i' _
      rw [hpoint (step i' p) i' j, hpoint p i' j]
      ring
    rw [hlin, hdivF, hdivT, mul_zero, sub_zero]
  have := row_eta_cancel _ htrace i
  unfold dpar at this
  linarith

/-- `λ` is constant along step-reachability. -/
theorem lam_eq_of_reachable {P : Type}
    (step : Fin (n + 1) → P → P) (lam : P → ℝ)
    (hstep : ∀ (i : Fin (n + 1)) (p : P), lam (step i p) = lam p)
    {p q : P} (h : Reachable step p q) : lam q = lam p := by
  induction h with
  | refl => rfl
  | tail _ hbc ih =>
    obtain ⟨i, rfl⟩ := hbc
    rw [hstep, ih]

/-- **The constancy theorem.** On a chart whose points are all reachable
    from a base point, the pointwise `λ` of a divergence-free
    decomposition is a single constant. -/
theorem lambda_constant {P : Type}
    (step : Fin (n + 1) → P → P) (p₀ : P)
    (hconn : ∀ q : P, Reachable step p₀ q)
    (F T : P → Mat n) (lam : P → ℝ) (κ : ℝ)
    (hpoint : ∀ p, ∀ i j, F p i j = κ * T p i j + lam p * eta n i j)
    (hdivF : ∀ p j, ddiv step F p j = 0)
    (hdivT : ∀ p j, ddiv step T p j = 0) :
    ∃ Λ : ℝ, ∀ p, lam p = Λ := by
  refine ⟨lam p₀, fun p => ?_⟩
  exact lam_eq_of_reachable step lam
    (step_invariant_of_divergence_free step F T lam κ hpoint hdivF hdivT)
    (hconn p)

/-! ### `[formal-v7]` Symmetric reachability (holes-audit F23, item 3)

The second audit pass observed that `Reachable` is *forward* root-reachability
— a ℤⁿ-style chart with forward successor maps is connected but not
root-reachable, so `lambda_constant` as stated does not cover it — and noted
the fix is trivial because step-invariance is an *equality*, which transports
both ways. Here is that fix: connectivity in the **symmetric** closure
(steps forward or backward) suffices. -/

/-- One point is connected to another by steps in either direction. -/
def SymmReachable {P : Type} (step : Fin (n + 1) → P → P) : P → P → Prop :=
  Relation.ReflTransGen (fun p q => (∃ i, q = step i p) ∨ (∃ i, p = step i q))

/-- `λ` is constant along symmetric reachability: the step-invariance
    equality transports both ways. -/
theorem lam_eq_of_symmReachable {P : Type}
    (step : Fin (n + 1) → P → P) (lam : P → ℝ)
    (hstep : ∀ (i : Fin (n + 1)) (p : P), lam (step i p) = lam p)
    {p q : P} (h : SymmReachable step p q) : lam q = lam p := by
  induction h with
  | refl => rfl
  | @tail b c _ hbc ih =>
    rcases hbc with ⟨i, rfl⟩ | ⟨i, hb⟩
    · rw [hstep, ih]
    · have h1 : lam b = lam c := by rw [hb, hstep]
      rw [← h1]
      exact ih

/-- **`lambda_constant`, symmetric-connectivity form**: on a chart whose
    points are all connected to a base point by steps in either direction
    (e.g. any ℤⁿ-style chart), the pointwise `λ` is a single constant. -/
theorem lambda_constant_symm {P : Type}
    (step : Fin (n + 1) → P → P) (p₀ : P)
    (hconn : ∀ q : P, SymmReachable step p₀ q)
    (F T : P → Mat n) (lam : P → ℝ) (κ : ℝ)
    (hpoint : ∀ p, ∀ i j, F p i j = κ * T p i j + lam p * eta n i j)
    (hdivF : ∀ p j, ddiv step F p j = 0)
    (hdivT : ∀ p j, ddiv step T p j = 0) :
    ∃ Λ : ℝ, ∀ p, lam p = Λ := by
  refine ⟨lam p₀, fun p => ?_⟩
  exact lam_eq_of_symmReachable step lam
    (step_invariant_of_divergence_free step F T lam κ hpoint hdivF hdivT)
    (hconn p)

/-! ### T26 — the composition with T14c -/

/-- **T26 — THE EINSTEIN EQUATION ENDS WITH A CONSTANT.** Null-cone
    matching at every point of a connected discrete chart (T14c's
    hypothesis, pointwise), plus the two named divergence inputs — the
    contracted Bianchi identity for `F` and local stress conservation for
    `T` — force `F = κT + Λη` with **one** constant `Λ` across the whole
    chart: the pointwise residual freedom of `jacobson_step` is promoted
    to the cosmological constant, and the promotion is now a theorem
    rather than a naming. -/
theorem einstein_equation_with_constant {P : Type}
    (step : Fin (n + 1) → P → P) (p₀ : P)
    (hconn : ∀ q : P, Reachable step p₀ q)
    (F T : P → Mat n) (κ : ℝ)
    (hFsymm : ∀ p, ∀ i j, F p i j = F p j i)
    (hTsymm : ∀ p, ∀ i j, T p i j = T p j i)
    (hnull : ∀ p, ∀ k : V n, quadOf (eta n) k = 0 →
      quadOf (F p) k = κ * quadOf (T p) k)
    (hdivF : ∀ p j, ddiv step F p j = 0)
    (hdivT : ∀ p j, ddiv step T p j = 0) :
    ∃ Λ : ℝ, ∀ p, ∀ i j, F p i j = κ * T p i j + Λ * eta n i j := by
  -- T14c at every point yields the pointwise field λ(p) …
  choose lam hlam using fun p =>
    jacobson_step (F p) (T p) (hFsymm p) (hTsymm p) κ (hnull p)
  -- … and the constancy theorem promotes it to a constant
  obtain ⟨Λ, hΛ⟩ := lambda_constant step p₀ hconn F T lam κ
    (fun p i j => hlam p i j) hdivF hdivT
  exact ⟨Λ, fun p i j => by rw [hlam p i j, hΛ p]⟩

/-! ### The connectivity hypothesis is load-bearing -/

/-- Without chart connectivity the conclusion genuinely fails: on the
    two-point chart with self-loop steps, `F(b) = λ(b)·η` with
    `λ = (0, 1)` satisfies every pointwise and divergence hypothesis, yet
    no single constant works. -/
theorem lambda_not_constant_without_connectivity :
    ∃ (F T : Bool → Mat n) (lam : Bool → ℝ),
      (∀ p, ∀ i j, F p i j = 1 * T p i j + lam p * eta n i j) ∧
      (∀ p j, ddiv (fun _ p => p) F p j = 0) ∧
      (∀ p j, ddiv (fun _ p => p) T p j = 0) ∧
      ¬ ∃ Λ : ℝ, ∀ p, lam p = Λ := by
  refine ⟨fun b => fun i j => (if b then 1 else 0) * eta n i j,
    fun _ => fun _ _ => 0, fun b => if b then 1 else 0,
    ?_, ?_, ?_, ?_⟩
  · intro p i j
    ring
  · intro p j
    unfold ddiv
    simp
  · intro p j
    unfold ddiv
    simp
  · rintro ⟨Λ, hΛ⟩
    have h0 := hΛ false
    have h1 := hΛ true
    norm_num at h0 h1
    linarith

/-! ### Axiom audit -/
#print axioms ddiv_lam_eta
#print axioms row_eta_cancel
#print axioms step_invariant_of_divergence_free
#print axioms lam_eq_of_reachable
#print axioms lambda_constant
#print axioms einstein_equation_with_constant
#print axioms lambda_not_constant_without_connectivity

end OPHProofChain.EinsteinBranch
