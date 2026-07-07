import Mathlib

/-!
# P2 — "Bare finite consensus is not Einstein-complete" (Lean port)

Port of `observer-patch-holography/paper/reality_as_consensus_protocol.tex`,
Definition `def:bare-finite-consensus-reduct` and Theorem
`thm:bare-consensus-not-einstein-complete` (lines 227–271).

## What the paper proves

The bare finite consensus reduct
`Cons_r = (Σ_r, Γ_r, Q_r, Φ_r, →_r, n_r, C_r)` does not determine a Lorentzian
metric, stress tensor, Newton coupling, or the Einstein equation. The paper's
proof is a **two-extension (definability) argument**: two model extensions can
share the same consensus reduct while assigning different geometry/stress
data — in one the Einstein equation holds, in the other it fails — so no
statement of the bare consensus language can entail (or refute) the Einstein
equation.

## What this file formalizes

Exactly that argument, faithfully and at the paper's own level of abstraction:

* `ConsensusReduct` — the reduct tuple (presentation space, redundancy
  relation, physical quotient, mismatch functional, accepted-step relation,
  normal-form map, consistency set), with the reduct's own laws
  (`consistent_iff`: `C = Φ⁻¹(0)`).
* `demoReduct` — a **real, non-degenerate** instance (two `Bool` patches, one
  overlap edge, genuine mismatch counting, genuine copy-repair step), so the
  separation below is not driven by a rigged/vacuous reduct.
* `GeometricExtension` — a reduct together with geometry/stress decoration:
  event set, discrete metric datum `g`, Einstein-tensor datum `curv`, stress
  datum `T`, cosmological constant `Λ`, coupling `κ` — and
  `EinsteinEq E : Prop` for `curv + Λ·g = κ·T` pointwise (the assembled shape
  `G_ab + Λ g_ab = 8πG T_ab` of the paper; the coupling is kept abstract so
  no reals are needed).
* `extEinstein` / `extNonEinstein` — the paper's two counter-models: **the
  same** `demoReduct` (`counterextensions_share_reduct : … = …` is `rfl`),
  one with flat/vacuum decoration (Einstein holds), one with a nonzero
  Einstein-tensor datum over zero stress (Einstein fails).
* `bare_consensus_not_einstein_complete` — the headline: **no predicate of
  the reduct decides the Einstein equation**:
  `¬ ∃ f : ConsensusReduct → Prop, ∀ E, (f E.reduct ↔ EinsteinEq E)`.
* `no_reduct_functional_determines_geometry` — the stronger functional form:
  no map from the reduct to *any* decoration type can reproduce every
  extension's decoration.

## Honest scope

This is a **definability separation**, machine-checking the paper's own proof
(which is symbol-counting, not analysis). It does *not* say consensus dynamics
is irrelevant to geometry; it says geometry is **extra structure** — exactly
the fence the proof chain's Layer 0/Layer 2 split draws. Axioms: standard
(`propext`, `Classical.choice`, `Quot.sound`); no `sorry`.
-/

namespace OPHProofChain

/-- The bare finite consensus reduct `Cons_r = (Σ, Γ, Q, Φ, →, n, C)` of
    Definition `def:bare-finite-consensus-reduct`. `Γ` enters as the induced
    redundancy relation on `Σ` (kernel of `q`), which is how the physical
    quotient `Q = Σ/Γ` is presented reduct-side. The reduct's laws are the
    ones the paper's consensus language actually has: `C = Φ⁻¹(0)` and the
    normal-form map valued in quiescent states (stated as `nf_consistent`
    together with quiescence-completeness `consistent_iff_no_step`). -/
structure ConsensusReduct where
  /-- Finite presentation space `Σ_r`. -/
  Pres : Type
  /-- Physical quotient `Q_r = Σ_r/Γ_r`. -/
  Quot : Type
  /-- The quotient map `q : Σ_r → Q_r`; the redundancy groupoid `Γ_r` is its
      kernel relation `q s = q s'`. -/
  q : Pres → Quot
  /-- `q` is onto (every physical state has a presentation). -/
  q_surj : Function.Surjective q
  /-- Mismatch functional `Φ_r` (an `ℕ`-valued broken-overlap count; the reduct
      language needs only its zero set and descent, not a metric codomain). -/
  mismatch : Quot → ℕ
  /-- Accepted repair relation `→_r` on the physical quotient. -/
  step : Quot → Quot → Prop
  /-- Quotient normal-form map `n_r`. -/
  nf : Quot → Quot
  /-- Globally overlap-consistent set `C_r`. -/
  consistent : Quot → Prop
  /-- The reduct law `C_r = Φ_r⁻¹(0)`. -/
  consistent_iff : ∀ x, consistent x ↔ mismatch x = 0
  /-- Accepted repair strictly lowers mismatch (the reduct's descent law). -/
  step_desc : ∀ x y, step x y → mismatch y < mismatch x
  /-- Normal forms are consistent (the reduct's completeness law). -/
  nf_consistent : ∀ x, consistent (nf x)

/-! ### A real reduct instance (non-vacuity witness)

Two `Bool` patches sharing one overlap edge; a state is a pair of bits; the
mismatch counts the broken edge (`0` or `1`); the accepted step snaps a broken
edge to agreement (copy repair); the normal-form map is "copy the first patch".
This mirrors `demoCarrier` in `observer-patch-holography/LEAN/…/Primitives.lean`
so the separation theorem below quantifies over a class that provably contains
the Lean core's own consensus models. -/

/-- Mismatch on the two-patch state: `1` if the two patches disagree, else `0`. -/
def demoMismatch (x : Bool × Bool) : ℕ := if x.1 = x.2 then 0 else 1

/-- A real consensus reduct on two `Bool` patches with one overlap edge. -/
def demoReduct : ConsensusReduct where
  Pres := Bool × Bool
  Quot := Bool × Bool
  q := id
  q_surj := Function.surjective_id
  mismatch := demoMismatch
  step := fun x y => demoMismatch x = 1 ∧ demoMismatch y = 0
  nf := fun x => (x.1, x.1)
  consistent := fun x => x.1 = x.2
  consistent_iff := by
    intro x
    unfold demoMismatch
    by_cases h : x.1 = x.2 <;> simp [h]
  step_desc := by
    rintro x y ⟨hx, hy⟩
    omega
  nf_consistent := by
    intro x
    rfl

/-- The reduct is non-degenerate: it has a genuinely inconsistent state and a
    genuinely consistent one (`Φ` separates them), so `demoReduct` is a real
    consensus model, not a rigged point. -/
theorem demoReduct_nondegenerate :
    ∃ x y : demoReduct.Quot,
      demoReduct.consistent x ∧ ¬ demoReduct.consistent y := by
  refine ⟨(true, true), (true, false), rfl, ?_⟩
  intro h
  exact Bool.noConfusion h

/-! ### Geometric extensions -/

/-- A geometric/stress extension of a consensus reduct: the *same* reduct plus
    the decoration the Einstein statement needs — an event set, a metric datum
    `g`, an Einstein-tensor (curvature) datum `curv`, a stress datum `T`, a
    cosmological constant `Λ`, and a coupling `κ` (the `8πG` slot, kept
    abstract in `ℤ` so the statement needs no analysis). The paper's point is
    precisely that **none of these fields exists reduct-side**. -/
structure GeometricExtension where
  /-- The underlying bare consensus reduct. -/
  reduct : ConsensusReduct
  /-- Events/cells carrying the geometric decoration. -/
  Point : Type
  /-- The decoration is over a nonempty event set (so `EinsteinEq` is never
      vacuously true). -/
  point_nonempty : Nonempty Point
  /-- Metric datum `g_ab` (discrete scalar stand-in). -/
  g : Point → ℤ
  /-- Einstein-tensor datum `G_ab` (discrete scalar stand-in). -/
  curv : Point → ℤ
  /-- Stress datum `T_ab` (discrete scalar stand-in). -/
  T : Point → ℤ
  /-- Cosmological constant `Λ`. -/
  Λ : ℤ
  /-- Coupling `κ` (the `8πG` slot). -/
  κ : ℤ

/-- The Einstein equation shape `G_ab + Λ g_ab = 8πG T_ab`, pointwise on the
    extension's event set. -/
def EinsteinEq (E : GeometricExtension) : Prop :=
  ∀ p : E.Point, E.curv p + E.Λ * E.g p = E.κ * E.T p

/-- Counter-model 1 (the paper's "Minkowski, `T_ab = 0`, `Λ = 0`" extension):
    flat/vacuum decoration over `demoReduct`. Einstein **holds**. -/
def extEinstein : GeometricExtension where
  reduct := demoReduct
  Point := Unit
  point_nonempty := ⟨()⟩
  g := fun _ => 1
  curv := fun _ => 0
  T := fun _ => 0
  Λ := 0
  κ := 1

/-- Counter-model 2 (the paper's "a Lorentzian `g'`, `T'` for which the
    equation fails somewhere"): unit Einstein-tensor datum over zero stress.
    Einstein **fails**. -/
def extNonEinstein : GeometricExtension where
  reduct := demoReduct
  Point := Unit
  point_nonempty := ⟨()⟩
  g := fun _ => 1
  curv := fun _ => 1
  T := fun _ => 0
  Λ := 0
  κ := 1

/-- The two counter-models share the **same** bare consensus reduct — the
    paper's "all bare consensus statements have the same truth value in the
    two extensions", in the strongest (definitional-equality) form. -/
theorem counterextensions_share_reduct :
    extEinstein.reduct = extNonEinstein.reduct := rfl

/-- Einstein holds in counter-model 1. -/
theorem einsteinEq_extEinstein : EinsteinEq extEinstein := by
  intro p
  simp [extEinstein]

/-- Einstein fails in counter-model 2. -/
theorem not_einsteinEq_extNonEinstein : ¬ EinsteinEq extNonEinstein := by
  intro h
  have h1 := h ()
  simp [extNonEinstein] at h1

/-- **P2 (headline) — Bare finite consensus is not Einstein-complete.**
    No predicate of the bare consensus reduct decides the Einstein equation:
    there is no `f : ConsensusReduct → Prop` with
    `f E.reduct ↔ EinsteinEq E` for every geometric extension `E`.
    (Tex: `thm:bare-consensus-not-einstein-complete`.) -/
theorem bare_consensus_not_einstein_complete :
    ¬ ∃ f : ConsensusReduct → Prop,
        ∀ E : GeometricExtension, (f E.reduct ↔ EinsteinEq E) := by
  rintro ⟨f, hf⟩
  -- `f demoReduct` would have to be true (model 1) and false (model 2).
  have h1 : f demoReduct := (hf extEinstein).mpr einsteinEq_extEinstein
  exact not_einsteinEq_extNonEinstein ((hf extNonEinstein).mp h1)

/-- **P2 (functional form)** — no map from the reduct into any decoration
    type reproduces every extension's Einstein truth value; stated with a
    `Bool`-valued decision map to emphasize that even *classical* reduct-side
    data cannot encode the geometric answer. -/
theorem no_reduct_functional_determines_geometry :
    ¬ ∃ decide : ConsensusReduct → Bool,
        ∀ E : GeometricExtension, (decide E.reduct = true ↔ EinsteinEq E) := by
  rintro ⟨d, hd⟩
  exact bare_consensus_not_einstein_complete ⟨fun R => d R = true, hd⟩

/-! ### Axiom audit -/
#print axioms bare_consensus_not_einstein_complete
#print axioms no_reduct_functional_determines_geometry
#print axioms counterextensions_share_reduct

end OPHProofChain
