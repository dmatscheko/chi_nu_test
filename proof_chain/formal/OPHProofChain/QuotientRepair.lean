import Mathlib
import OPHProofChain.Rewriting

/-!
# P1 — The quotient repair operator package (Lean port)

Port of `observer-patch-holography/paper/reality_as_consensus_protocol.tex`:

* Definition `def:finite-quotient-repair-presentation` (lines 439–485),
* Definition `def:local-quotient-repair-operator` (487–501),
* Proposition `prop:local-quotient-repair` (503–520),
* Definition `def:global-quotient-repair-operator` (539–556),
* Theorem `thm:quotient-repair-normal-form` (558–610),
* Corollary `cor:repair-respects-gauge` (1143–1170).

This module also discharges, in the quotient setting the paper works in, the
content of the three `sorry`s of
`observer-patch-holography/LEAN/ObserverPatchHolography/Primitives.lean`
(`localRepair`, `Repair`, `repair_respects_gauge`) and the open rows of
`LEAN/PROOF_INDEX.md` Definition 4.1 / Proposition 4.2:

| PROOF_INDEX row | here |
|---|---|
| `OPH.Repair` (global repair operator) | `globalRepair` (total, constructed) |
| `OPH.localRepair` (one accepted move) | `locRep` (canonical least-enabled transaction) |
| `OPH.NF` (terminal state of accepted repair) | `globalRepair` + `globalRepair_normalForm` |
| `OPH.World` | `World` |
| `OPH.world_is_fixedPt` (`Repair(World)=World`) | `world_is_fixedPt` |
| `OPH.schedule_independence` | `schedule_independence` |
| `OPH.repair_respects_gauge` | `repair_respects_gauge` (+ action form) |
| `OPH.Termination` | `stepRel_terminating` |
| `OPH.Completeness` (NF ⟺ consistent) | `normalForm_iff_CQ` |
| `OPH.Confluence` | `stepRel_confluent` |
| `OPH.LyapunovDescent` | field `Hdown` (+ `locRep_desc`) |

**Route B, made explicit.** The Lean core's load-bearing negative result
(`demoCarrier_not_confluent`) shows asynchronous local repair is not
confluent in general. The paper's answer — machine-checked here — is that
objectivity is *bought* with declared structure: a fixed total order on
transactions (the canonical scheduler) **plus** the four admissibility
hypotheses `H_B`, `H_↓`, `H_◇`, `H_comp`. Under exactly those, the global
repair operator exists, is total, idempotent, boundary-preserving, valued in
the consistent set, and — via Newman — **schedule-independent**. Nothing is
smuggled: the demo below (`demoPresentation`) is a real instance, and
`symmetricPair_not_locallyConfluent` shows the *symmetric* two-transaction
variant of the same carrier violates `H_◇` (it is the Lean core's
non-confluence counterexample in presentation form), so `H_◇` is doing real
work and is not implied by the other hypotheses.

**Faithfulness notes.** (i) The paper's redundancy groupoid `Γ` enters as the
kernel of the quotient map `q` (two presentations are gauge-equivalent iff
they have the same physical quotient), exactly as in the Lean core, where
`gaugeEquiv = Setoid.ker obsMap`. An arbitrary-gauge-move form
(`repair_respects_gauge_action`) is also provided. (ii) The paper asks that
the descent measure have well-founded target *and finite image on Q*;
well-foundedness alone already gives every statement below, so the finite-
image clause is not imposed (instances may of course satisfy it — the demo
does). (iii) Transactions are partial maps `(Dom, act)`; decidability of
`Dom` is the computational content of "a least *enabled* transaction can be
selected" and is carried as an instance field.

Axioms: standard (`propext`, `Classical.choice`, `Quot.sound`); no `sorry`.
-/

namespace OPHProofChain

open Relation

/-- The accepted one-step relation `x →_P y ⟺ ∃ a ∈ A, x ∈ D_a, y = a(x)`
    induced by a family of partial transactions. -/
def StepRel {Q A : Type} (Dom : A → Q → Prop) (act : A → Q → Q) :
    Q → Q → Prop :=
  fun x y => ∃ a : A, Dom a x ∧ y = act a x

/-- **Definition (`def:finite-quotient-repair-presentation`).** A finite
    quotient repair presentation `𝒫 = (Σ, Γ, q, Q, C_Q, B, μ, 𝖠, ≺_𝖠)`,
    OPH-admissible: boundary preservation `H_B`, strict well-founded descent
    `H_↓`, local confluence `H_◇`, and quiescence-completeness `H_comp`.
    `Γ` is the kernel of `q` (see module docstring, faithfulness note (i)). -/
structure QuotientRepairPresentation where
  /-- Presentation space `Σ` (hidden representative data included). -/
  Pres : Type
  /-- Physical quotient `Q = Σ/Γ`. -/
  Q : Type
  /-- Quotient map `q : Σ → Q`; the redundancy groupoid `Γ` is its kernel. -/
  q : Pres → Q
  /-- Every physical state has a presentation. -/
  q_surj : Function.Surjective q
  /-- Quotient-level consistency set `C_Q`. -/
  CQ : Q → Prop
  /-- Value sort `𝓑` of the protected boundary/sector/charge map. -/
  BSort : Type
  /-- The protected boundary map `B : Q → 𝓑`. -/
  B : Q → BSort
  /-- Value sort `W` of the descent measure. -/
  W : Type
  /-- The strict order `≺` on `W`. -/
  wlt : W → W → Prop
  /-- `≺` is well-founded (subsumes the paper's "well-founded with finite
      image on Q"; see faithfulness note (ii)). -/
  wlt_wf : WellFounded wlt
  /-- The exact descent measure `μ : Q → (W, ≺)`. -/
  μ : Q → W
  /-- The finite set `𝖠` of accepted aggregate repair transactions. -/
  A : Type
  /-- `𝖠` is finite. -/
  aFintype : Fintype A
  /-- The fixed total order `≺_𝖠` on transactions — the canonical scheduler
      (Route B's declared structure). -/
  aLinearOrder : LinearOrder A
  /-- Transaction domains `D_a ⊆ Q`. -/
  Dom : A → Q → Prop
  /-- Enabledness is decidable (so the least enabled transaction can be
      selected). -/
  domDec : ∀ a : A, DecidablePred (Dom a)
  /-- Transaction maps `a : D_a → Q` (total function, read on `D_a`). -/
  act : A → Q → Q
  /-- `(H_B)` boundary preservation. -/
  HB : ∀ (a : A) (x : Q), Dom a x → B (act a x) = B x
  /-- `(H_↓)` strict exact descent. -/
  Hdown : ∀ (a : A) (x : Q), Dom a x → wlt (μ (act a x)) (μ x)
  /-- `(H_◇)` local confluence of the accepted one-step relation on `Q`. -/
  Hdiamond : Rewriting.LocallyConfluent (StepRel Dom act)
  /-- `(H_comp)` consistent ⟺ quiescent (no transaction enabled). -/
  Hcomp : ∀ x : Q, CQ x ↔ ∀ a : A, ¬ Dom a x

attribute [instance] QuotientRepairPresentation.aFintype
attribute [instance] QuotientRepairPresentation.aLinearOrder
attribute [instance] QuotientRepairPresentation.domDec

namespace QuotientRepairPresentation

variable (P : QuotientRepairPresentation)

/-- The accepted one-step relation of the presentation. -/
abbrev Step : P.Q → P.Q → Prop := StepRel P.Dom P.act

/-- The enabled-transaction set `𝖠(x)`. -/
def enabled (x : P.Q) : Finset P.A :=
  Finset.univ.filter (fun a => P.Dom a x)

theorem mem_enabled {x : P.Q} {a : P.A} : a ∈ P.enabled x ↔ P.Dom a x := by
  unfold enabled
  simp

/-- **Definition (`def:local-quotient-repair-operator`).** Apply the
    `≺_𝖠`-least enabled transaction; fix quiescent states. -/
def locRep (x : P.Q) : P.Q :=
  if h : (P.enabled x).Nonempty then P.act ((P.enabled x).min' h) x else x

/-- If some transaction is enabled, `locRep` applies the least one. -/
theorem locRep_of_nonempty {x : P.Q} (h : (P.enabled x).Nonempty) :
    P.locRep x = P.act ((P.enabled x).min' h) x := dif_pos h

/-- If no transaction is enabled, `locRep` fixes the state. -/
theorem locRep_of_empty {x : P.Q} (h : ¬ (P.enabled x).Nonempty) :
    P.locRep x = x := dif_neg h

/-- Quiescence in terms of `C_Q` (`H_comp` in `Finset` form). -/
theorem enabled_empty_iff_CQ (x : P.Q) :
    ¬ (P.enabled x).Nonempty ↔ P.CQ x := by
  rw [Finset.nonempty_iff_ne_empty, not_not, Finset.eq_empty_iff_forall_notMem,
    P.Hcomp x]
  constructor
  · intro h a ha
    exact (h a) (P.mem_enabled.mpr ha)
  · intro h a ha
    exact h a (P.mem_enabled.mp ha)

/-- **Proposition (`prop:local-quotient-repair`), part 1**: `locRep` is
    boundary-preserving. -/
theorem locRep_boundary (x : P.Q) : P.B (P.locRep x) = P.B x := by
  by_cases h : (P.enabled x).Nonempty
  · rw [P.locRep_of_nonempty h]
    exact P.HB _ x (P.mem_enabled.mp ((P.enabled x).min'_mem h))
  · rw [P.locRep_of_empty h]

/-- **Proposition, part 2**: on non-quiescent states, `locRep` strictly
    descends. -/
theorem locRep_desc {x : P.Q} (h : P.locRep x ≠ x) :
    P.wlt (P.μ (P.locRep x)) (P.μ x) := by
  by_cases hne : (P.enabled x).Nonempty
  · rw [P.locRep_of_nonempty hne]
    exact P.Hdown _ x (P.mem_enabled.mp ((P.enabled x).min'_mem hne))
  · exact absurd (P.locRep_of_empty hne) h

/-- **Proposition, part 3**: `locRep` fixes exactly the consistent states.
    (Strict descent excludes `a_min(x) = x`, via irreflexivity of a
    well-founded relation.) -/
theorem locRep_eq_self_iff (x : P.Q) : P.locRep x = x ↔ P.CQ x := by
  constructor
  · intro hfix
    by_contra hcq
    have hne : (P.enabled x).Nonempty := by
      by_contra hne
      exact hcq ((P.enabled_empty_iff_CQ x).mp hne)
    have hdesc := P.Hdown _ x (P.mem_enabled.mp ((P.enabled x).min'_mem hne))
    rw [← P.locRep_of_nonempty hne, hfix] at hdesc
    exact Rewriting.wf_irrefl P.wlt_wf _ hdesc
  · intro hcq
    exact P.locRep_of_empty ((P.enabled_empty_iff_CQ x).mpr hcq)

/-- On a state with an enabled transaction, `locRep` strictly descends
    (nonempty-enabled form of Proposition part 2, used by the recursion). -/
theorem locRep_desc_of_nonempty {x : P.Q} (h : (P.enabled x).Nonempty) :
    P.wlt (P.μ (P.locRep x)) (P.μ x) := by
  rw [P.locRep_of_nonempty h]
  exact P.Hdown _ x (P.mem_enabled.mp ((P.enabled x).min'_mem h))

/-- On a state with an enabled transaction, `locRep` is an accepted step of
    the presentation. -/
theorem step_locRep {x : P.Q} (h : (P.enabled x).Nonempty) :
    P.Step x (P.locRep x) :=
  ⟨(P.enabled x).min' h, P.mem_enabled.mp ((P.enabled x).min'_mem h),
    P.locRep_of_nonempty h⟩

/-- The accepted-step relation strictly descends along `μ` (`H_↓` in
    relation form). -/
theorem step_desc {x y : P.Q} (h : P.Step x y) : P.wlt (P.μ y) (P.μ x) := by
  obtain ⟨a, ha, rfl⟩ := h
  exact P.Hdown a x ha

/-- **Termination** of the accepted-step relation (PROOF_INDEX row
    `OPH.Termination`): `H_↓` pulls well-foundedness back along `μ`. -/
theorem stepRel_terminating : Rewriting.Terminating P.Step :=
  Subrelation.wf (fun {y x} h => P.step_desc h)
    (InvImage.wf P.μ P.wlt_wf)

/-- **Completeness** (PROOF_INDEX row `OPH.Completeness`): normal forms of
    the accepted-step relation are exactly the consistent states. -/
theorem normalForm_iff_CQ (x : P.Q) :
    Rewriting.NormalForm P.Step x ↔ P.CQ x := by
  rw [P.Hcomp x]
  constructor
  · intro hnf a ha
    exact hnf (P.act a x) ⟨a, ha, rfl⟩
  · rintro h y ⟨a, ha, rfl⟩
    exact h a ha

/-- **Confluence** of the accepted-step relation (PROOF_INDEX row
    `OPH.Confluence`): Newman's lemma from `H_↓` + `H_◇`. -/
theorem stepRel_confluent : Rewriting.Confluent P.Step :=
  Rewriting.newman P.stepRel_terminating P.Hdiamond

/-- **Definition (`def:global-quotient-repair-operator`).** Iterate the
    canonical local repair to its fixed point; total by well-founded descent.
    (The recursion branches on the decidable enabledness test, exactly the
    paper's "either stops or strictly descends".) -/
def globalRepair : P.Q → P.Q :=
  (InvImage.wf P.μ P.wlt_wf).fix
    (fun x rec =>
      if h : (P.enabled x).Nonempty then
        rec (P.locRep x) (P.locRep_desc_of_nonempty h)
      else x)

/-- Unfolding equation for `globalRepair`. -/
theorem globalRepair_eq (x : P.Q) :
    P.globalRepair x =
      if (P.enabled x).Nonempty then P.globalRepair (P.locRep x) else x := by
  unfold globalRepair
  rw [WellFounded.fix_eq]
  by_cases h : (P.enabled x).Nonempty
  · rw [dif_pos h, if_pos h]
  · rw [dif_neg h, if_neg h]

/-- The canonical iteration reaches a `locRep`-fixed point. -/
theorem locRep_globalRepair (x : P.Q) :
    P.locRep (P.globalRepair x) = P.globalRepair x := by
  refine (InvImage.wf P.μ P.wlt_wf).induction
    (C := fun x => P.locRep (P.globalRepair x) = P.globalRepair x) x ?_
  intro x ih
  rw [P.globalRepair_eq x]
  by_cases h : (P.enabled x).Nonempty
  · rw [if_pos h]
    exact ih (P.locRep x) (P.locRep_desc_of_nonempty h)
  · rw [if_neg h]
    exact P.locRep_of_empty h

/-- **Theorem (`thm:quotient-repair-normal-form`), part 1**: global repair
    lands in the consistent set, `Rep_λ(x) ∈ C_Q`. -/
theorem globalRepair_mem_CQ (x : P.Q) : P.CQ (P.globalRepair x) :=
  (P.locRep_eq_self_iff _).mp (P.locRep_globalRepair x)

/-- **Theorem, part 2**: global repair is boundary-preserving,
    `B(Rep_λ(x)) = B(x)`. -/
theorem globalRepair_boundary (x : P.Q) :
    P.B (P.globalRepair x) = P.B x := by
  refine (InvImage.wf P.μ P.wlt_wf).induction
    (C := fun x => P.B (P.globalRepair x) = P.B x) x ?_
  intro x ih
  rw [P.globalRepair_eq x]
  by_cases h : (P.enabled x).Nonempty
  · rw [if_pos h, ih (P.locRep x) (P.locRep_desc_of_nonempty h),
      P.locRep_boundary x]
  · rw [if_neg h]

/-- Consistent states are fixed by global repair. -/
theorem globalRepair_eq_self_of_CQ {x : P.Q} (h : P.CQ x) :
    P.globalRepair x = x := by
  rw [P.globalRepair_eq x, if_neg ((P.enabled_empty_iff_CQ x).mpr h)]

/-- **Theorem, part 3**: global repair is idempotent,
    `Rep_λ(Rep_λ(x)) = Rep_λ(x)`. -/
theorem globalRepair_idem (x : P.Q) :
    P.globalRepair (P.globalRepair x) = P.globalRepair x :=
  P.globalRepair_eq_self_of_CQ (P.globalRepair_mem_CQ x)

/-- **Theorem, part 4**: `Rep_λ(x) = x ⟺ x ∈ C_Q`. -/
theorem globalRepair_eq_self_iff (x : P.Q) :
    P.globalRepair x = x ↔ P.CQ x := by
  constructor
  · intro h
    have := P.globalRepair_mem_CQ x
    rwa [h] at this
  · exact P.globalRepair_eq_self_of_CQ

/-- The canonical iteration is one accepted repair execution:
    `x →_P^* Rep_λ(x)`. -/
theorem reflTransGen_globalRepair (x : P.Q) :
    ReflTransGen P.Step x (P.globalRepair x) := by
  refine (InvImage.wf P.μ P.wlt_wf).induction
    (C := fun x => ReflTransGen P.Step x (P.globalRepair x)) x ?_
  intro x ih
  rw [P.globalRepair_eq x]
  by_cases h : (P.enabled x).Nonempty
  · rw [if_pos h]
    exact ReflTransGen.head (P.step_locRep h)
      (ih (P.locRep x) (P.locRep_desc_of_nonempty h))
  · rw [if_neg h]

/-- `Rep_λ(x)` is a normal form of the accepted-step relation. -/
theorem globalRepair_normalForm (x : P.Q) :
    Rewriting.NormalForm P.Step (P.globalRepair x) :=
  (P.normalForm_iff_CQ _).mpr (P.globalRepair_mem_CQ x)

/-- **Theorem, part 5 (schedule independence)**: every terminal state of an
    accepted repair execution from `x` equals `Rep_λ(x)` — the global repair
    operator is independent of the accepted asynchronous repair schedule.
    (PROOF_INDEX row `OPH.schedule_independence`.) -/
theorem schedule_independence {x y : P.Q}
    (hxy : ReflTransGen P.Step x y) (hy : Rewriting.NormalForm P.Step y) :
    y = P.globalRepair x :=
  Rewriting.confluent_unique_nf P.stepRel_confluent
    hxy hy (P.reflTransGen_globalRepair x) (P.globalRepair_normalForm x)

/-! ### The World construction and the fixed-point reading (Prop 4.2)

*Paradise as Fixed-Point Consensus* Definition 4.1 reads
`World = NF(x)/∼_gauge`; on the physical quotient `Q = Σ/Γ` this is the
normal form of the quotient state. Proposition 4.2 reads
`World ∈ Fix(Repair)` with schedule independence on the physical quotient. -/

/-- **Definition 4.1 (`World`)**: the observer-facing public world of a
    presentation state — the quotient normal form of its physical class.
    (PROOF_INDEX row `OPH.World`.) -/
def World (s : P.Pres) : P.Q := P.globalRepair (P.q s)

/-- **Proposition 4.2, sentence 1** (PROOF_INDEX row `OPH.world_is_fixedPt`):
    the public world is a fixed point of repair, `Repair(World) = World`. -/
theorem world_is_fixedPt (s : P.Pres) :
    P.globalRepair (P.World s) = P.World s :=
  P.globalRepair_idem (P.q s)

/-- The public world is consistent. -/
theorem world_mem_CQ (s : P.Pres) : P.CQ (P.World s) :=
  P.globalRepair_mem_CQ (P.q s)

/-- **Corollary (`cor:repair-respects-gauge`)**: the quotient-valued physical
    repair of a representative, `Rep^Σ_λ := Rep_λ ∘ q`, is gauge-invariant:
    presentations with the same physical quotient have the same repaired
    world. This is the (previously `sorry`) `repair_respects_gauge` of the
    Lean core, in the quotient setting the paper works in. -/
theorem repair_respects_gauge {s s' : P.Pres} (h : P.q s = P.q s') :
    P.World s = P.World s' := by
  unfold World
  rw [h]

/-- **Corollary, gauge-action form**: for any gauge move `γ : Σ → Σ` below
    the quotient (`q ∘ γ = q`, i.e. `γ ∈ Γ`), `Rep^Σ_λ(γ·s) = Rep^Σ_λ(s)`. -/
theorem repair_respects_gauge_action (γ : P.Pres → P.Pres)
    (hγ : ∀ s, P.q (γ s) = P.q s) (s : P.Pres) :
    P.World (γ s) = P.World s :=
  P.repair_respects_gauge (hγ s)

/-- **Corollary, observable form**: every physical observable `M : Q → Y`
    of the repaired world is gauge-invariant. -/
theorem observable_respects_gauge {Y : Type} (M : P.Q → Y)
    (γ : P.Pres → P.Pres) (hγ : ∀ s, P.q (γ s) = P.q s) (s : P.Pres) :
    M (P.World (γ s)) = M (P.World s) := by
  rw [P.repair_respects_gauge_action γ hγ s]

end QuotientRepairPresentation

/-! ### Non-vacuity witness and the `H_◇` separation

`demoPresentation` — the two-cell carrier of the Lean core
(`demoCarrier` in `Primitives.lean`), presented Route-B style: **one**
directional transaction ("second cell copies the first", the declared
canonical order on a singleton transaction set), protected boundary = first
cell. All four admissibility hypotheses hold, and `globalRepair` computably
settles `(t, f) ↦ (t, t)`.

`symmetricPair_not_locallyConfluent` — the *symmetric* two-transaction
variant (copy-left-to-right AND copy-right-to-left, both enabled on broken
states) violates `H_◇`: it is exactly the Lean core's
`demoCarrier_not_confluent` in presentation form. So `H_◇` is a genuine
hypothesis, not implied by `H_B ∧ H_↓ ∧ H_comp`. -/

/-- Route-B demo: one directional copy transaction on a two-cell state. -/
def demoPresentation : QuotientRepairPresentation where
  Pres := Bool × Bool
  Q := Bool × Bool
  q := id
  q_surj := Function.surjective_id
  CQ := fun x => x.1 = x.2
  BSort := Bool
  B := fun x => x.1
  W := ℕ
  wlt := (· < ·)
  wlt_wf := Nat.lt_wfRel.wf
  μ := fun x => if x.1 = x.2 then 0 else 1
  A := Unit
  aFintype := inferInstance
  aLinearOrder := inferInstance
  Dom := fun _ x => x.1 ≠ x.2
  domDec := fun _ _ => instDecidableNot
  act := fun _ x => (x.1, x.1)
  HB := fun _ _ _ => rfl
  Hdown := fun _ x hx => by
    show (if x.1 = x.1 then (0 : ℕ) else 1) < (if x.1 = x.2 then (0 : ℕ) else 1)
    rw [if_pos rfl, if_neg hx]
    exact Nat.zero_lt_one
  Hdiamond := by
    rintro x y z ⟨a, hax, rfl⟩ ⟨b, hbx, rfl⟩
    exact ⟨(x.1, x.1), ReflTransGen.refl, ReflTransGen.refl⟩
  Hcomp := fun x => by
    constructor
    · intro h _ hd
      exact hd h
    · intro h
      by_contra hne
      exact h () hne

/-- The demo's global repair settles the broken state `(true, false)` to the
    boundary-selected consensus `(true, true)` — a concrete, computable run
    of the canonical scheduler. -/
theorem demoPresentation_settles :
    demoPresentation.globalRepair (true, false) = (true, true) := by
  have hne : (demoPresentation.enabled (true, false)).Nonempty :=
    ⟨(), (demoPresentation.mem_enabled).mpr
      (show (true : Bool) ≠ false by decide)⟩
  have h1 : demoPresentation.locRep (true, false) = (true, true) := by
    rw [demoPresentation.locRep_of_nonempty hne]
    rfl
  have h2 : demoPresentation.globalRepair (true, true) = (true, true) :=
    demoPresentation.globalRepair_eq_self_of_CQ rfl
  rw [QuotientRepairPresentation.globalRepair_eq, if_pos hne, h1, h2]

/-- The symmetric two-transaction system on the same carrier: `left` snaps
    the pair to the first cell, `right` snaps it to the second; both are
    enabled exactly on broken states. -/
def symmetricDom : Bool → (Bool × Bool) → Prop := fun _ x => x.1 ≠ x.2

/-- The two symmetric copy transactions. -/
def symmetricAct : Bool → (Bool × Bool) → (Bool × Bool) :=
  fun a x => if a then (x.1, x.1) else (x.2, x.2)

/-- **`H_◇` is a real hypothesis**: the symmetric pair is *not* locally
    confluent — from `(true, false)` the two transactions reach the two
    distinct terminal states `(true, true)` and `(false, false)`. This is
    the Lean core's non-confluence counterexample
    (`demoCarrier_not_confluent`) in quotient-presentation form; it is
    excluded from OPH-admissibility precisely by `H_◇`. -/
theorem symmetricPair_not_locallyConfluent :
    ¬ Rewriting.LocallyConfluent (StepRel symmetricDom symmetricAct) := by
  intro hlc
  have htf : ((true, false) : Bool × Bool).1 ≠ ((true, false) : Bool × Bool).2 :=
    show (true : Bool) ≠ false by decide
  have hstep1 : StepRel symmetricDom symmetricAct (true, false) (true, true) :=
    ⟨true, htf, rfl⟩
  have hstep2 : StepRel symmetricDom symmetricAct (true, false) (false, false) :=
    ⟨false, htf, rfl⟩
  obtain ⟨w, hw1, hw2⟩ := hlc _ _ _ hstep1 hstep2
  -- both targets are terminal (consistent states enable nothing)
  have hnf : ∀ v : Bool, Rewriting.NormalForm (StepRel symmetricDom symmetricAct) (v, v) := by
    rintro v y ⟨a, ha, rfl⟩
    exact ha rfl
  have e1 := Rewriting.normalForm_reflTransGen_eq (hnf true) hw1
  have e2 := Rewriting.normalForm_reflTransGen_eq (hnf false) hw2
  rw [← e2] at e1
  exact absurd (congrArg Prod.fst e1) (by decide)

/-- The broken-edge count of the two-cell state (the `μ` of the separation
    statement). -/
def symmetricMeasure : Bool × Bool → ℕ := fun x => if x.1 = x.2 then 0 else 1

/-- **The symmetric pair descends** (the `H_↓` clause of the separation
    statement; `[formal-v6]`): every enabled step strictly lowers the
    broken-edge count into a well-founded target. So the separation
    witness satisfies the descent hypothesis honestly, not vacuously. -/
theorem symmetricPair_descends :
    ∀ x y, StepRel symmetricDom symmetricAct x y →
      symmetricMeasure y < symmetricMeasure x := by
  rintro x y ⟨a, ha, rfl⟩
  have hx : symmetricMeasure x = 1 := if_neg ha
  have hy : symmetricMeasure (symmetricAct a x) = 0 := by
    cases a <;> exact if_pos rfl
  omega

/-- **The symmetric pair is quiescence-complete** (the `H_comp` clause of
    the separation statement; `[formal-v6]`): its normal forms are exactly
    the consistent states. (The boundary clause `H_B` has no content on
    this boundary-free two-cell carrier — note it is genuinely vacuous,
    not merely unproven: with a nontrivial boundary map such as `fst`,
    the symmetric pair would *violate* `H_B`.) With
    `symmetricPair_descends` and `symmetricPair_not_locallyConfluent`,
    every non-vacuous clause of the separation statement is
    machine-checked: `H_↓ ∧ H_comp` (with `H_B` vacuous) do **not**
    imply `H_◇` — the declared order is provably load-bearing. -/
theorem symmetricPair_normalForm_iff (x : Bool × Bool) :
    Rewriting.NormalForm (StepRel symmetricDom symmetricAct) x ↔ x.1 = x.2 := by
  constructor
  · intro hnf
    by_contra hne
    exact hnf (symmetricAct true x) ⟨true, hne, rfl⟩
  · rintro heq y ⟨a, ha, rfl⟩
    exact ha heq

/-! ### Axiom audit -/
#print axioms QuotientRepairPresentation.globalRepair_mem_CQ
#print axioms QuotientRepairPresentation.globalRepair_boundary
#print axioms QuotientRepairPresentation.globalRepair_idem
#print axioms QuotientRepairPresentation.globalRepair_eq_self_iff
#print axioms QuotientRepairPresentation.schedule_independence
#print axioms QuotientRepairPresentation.world_is_fixedPt
#print axioms QuotientRepairPresentation.repair_respects_gauge
#print axioms QuotientRepairPresentation.stepRel_confluent
#print axioms demoPresentation_settles
#print axioms symmetricPair_not_locallyConfluent
#print axioms symmetricPair_descends
#print axioms symmetricPair_normalForm_iff

end OPHProofChain
