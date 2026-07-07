import Mathlib

/-!
# P4 (form half) — unique scalar linear response under SEE (Lean port)

Port of the *linear-algebra core* of
`observer-patch-holography/paper/screen_microphysics_and_observer_synchronization.tex`,
Theorems `thm:coherent-matter-same-channel-forcing` and
`thm:unique-scalar-linear-response` (lines 817–864).

## What the paper proves, and what this file checks

The paper's argument has two parts:

1. **Physics (stays a hypothesis here):** Scalar Edge-Center Exhaustion
   (SEE) — every quotient-local scalar perturbation that can affect a
   collar record factors through the unique scalar edge-center register
   `𝓔_{r,C}`. The proof chain carries SEE as *the* named hypothesis of the
   χ_ν form derivation (Tier B0); it is physical input, not mathematics,
   and is **not** discharged here.
2. **Mathematics (checked here):** once every admissible source is valued
   in a one-generator register, *any* linear response has the unique form
   `δν = χ·⟨η, S⟩ + O(S²)` and *no independent scalar susceptibility can
   be added*. That is a two-line linear-algebra fact — but it is exactly
   the step that turns "the χ_ν law has the right shape" from prose into
   a theorem, so it is worth machine-checking.

* `unique_scalar_linear_response` — under SEE (`register`), every linear
  response is `S = c·η ↦ χ·c` with `χ := δν(η)`: the *form* of the χ_ν law,
  with the conditionality concentrated in the SEE hypothesis, exactly as
  the paper states it.
* `no_second_susceptibility` — two linear responses agreeing on the
  register generator agree on every admissible source: "no independent
  local scalar susceptibility can be added without violating SEE".

Axioms: standard; no `sorry`.
-/

namespace OPHProofChain.ScalarResponse

variable {V : Type*} [AddCommGroup V] [Module ℝ V]

/-- **Unique scalar linear response** (`thm:unique-scalar-linear-response`,
    linear-algebra core). If — SEE — every admissible source is valued in
    the one-generator register spanned by the edge-center test functional's
    dual vector `η`, then every linear frequency response `δν` acts as
    `S = c·η ↦ χ·c` for the single susceptibility `χ = δν(η)`. -/
theorem unique_scalar_linear_response (η : V) (δν : V →ₗ[ℝ] ℝ) :
    ∃ χ : ℝ, ∀ (S : V) (c : ℝ), S = c • η → δν S = χ * c := by
  refine ⟨δν η, fun S c hS => ?_⟩
  rw [hS, map_smul, smul_eq_mul, mul_comm]

/-- **No second susceptibility** ("an additional scalar susceptibility
    would define another quotient-local scalar carrier on the same collar,
    contradicting SEE"): under SEE, two linear responses that agree on the
    register generator agree on every admissible source — there is no room
    for an independent local scalar response channel. -/
theorem no_second_susceptibility (η : V)
    (register : ∀ S : V, ∃ c : ℝ, S = c • η)
    (δν₁ δν₂ : V →ₗ[ℝ] ℝ) (h : δν₁ η = δν₂ η) :
    ∀ S : V, δν₁ S = δν₂ S := by
  intro S
  obtain ⟨c, rfl⟩ := register S
  rw [map_smul, map_smul, h]

/-! ### Axiom audit -/
#print axioms unique_scalar_linear_response
#print axioms no_second_susceptibility

end OPHProofChain.ScalarResponse
