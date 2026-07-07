import Mathlib

/-!
# Abstract rewriting prerequisites (self-contained)

Newman's lemma and uniqueness of normal forms, stated over an arbitrary
relation. This mirrors (and is intercompatible with) the definitions in
`observer-patch-holography/LEAN/ObserverPatchHolography/AbstractRewriting.lean`,
re-proved here from scratch so this project is standalone. Used by
`QuotientRepair.lean` for the schedule-independence half of the global repair
theorem.

Axioms: standard; no `sorry`.
-/

namespace OPHProofChain.Rewriting

open Relation

variable {X : Type*}

/-- Termination: no infinite forward chain (well-foundedness of the flipped
    relation). -/
def Terminating (r : X → X → Prop) : Prop := WellFounded (fun y x => r x y)

/-- Local confluence (weak Church–Rosser): one-step peaks join. -/
def LocallyConfluent (r : X → X → Prop) : Prop :=
  ∀ x y z, r x y → r x z → ∃ w, ReflTransGen r y w ∧ ReflTransGen r z w

/-- Confluence (Church–Rosser): multi-step peaks join. -/
def Confluent (r : X → X → Prop) : Prop :=
  ∀ x y z, ReflTransGen r x y → ReflTransGen r x z →
    ∃ w, ReflTransGen r y w ∧ ReflTransGen r z w

/-- A normal form: no successor. -/
def NormalForm (r : X → X → Prop) (x : X) : Prop := ∀ y, ¬ r x y

/-- A well-founded relation is irreflexive (helper; proved from scratch to
    stay independent of Mathlib lemma naming). -/
theorem wf_irrefl {r : X → X → Prop} (wf : WellFounded r) (x : X) :
    ¬ r x x := by
  induction x using wf.induction with
  | _ x ih => exact fun h => ih x h h

/-- A normal form only reduces to itself. -/
theorem normalForm_reflTransGen_eq {r : X → X → Prop} {x y : X}
    (hx : NormalForm r x) (h : ReflTransGen r x y) : x = y := by
  induction h with
  | refl => rfl
  | tail hab hbc ih => exact absurd hbc (ih ▸ hx _)

/-- **Newman's lemma**: terminating + locally confluent ⇒ confluent. -/
theorem newman {r : X → X → Prop}
    (hterm : Terminating r) (hlc : LocallyConfluent r) : Confluent r := by
  intro x
  induction x using hterm.induction with
  | _ x ih =>
    intro y z hxy hxz
    rcases hxy.cases_head with rfl | ⟨y', hxy', hy'y⟩
    · exact ⟨z, hxz, ReflTransGen.refl⟩
    rcases hxz.cases_head with rfl | ⟨z', hxz', hz'z⟩
    · exact ⟨y, ReflTransGen.refl, hxy⟩
    obtain ⟨w, hy'w, hz'w⟩ := hlc x y' z' hxy' hxz'
    obtain ⟨u, hyu, hwu⟩ := ih y' hxy' y w hy'y hy'w
    obtain ⟨v, hzv, huv⟩ := ih z' hxz' z u hz'z (hz'w.trans hwu)
    exact ⟨v, hyu.trans huv, hzv⟩

/-- Confluence forces uniqueness of reachable normal forms. -/
theorem confluent_unique_nf {r : X → X → Prop} (hc : Confluent r)
    {x y z : X} (hxy : ReflTransGen r x y) (hy : NormalForm r y)
    (hxz : ReflTransGen r x z) (hz : NormalForm r z) : y = z := by
  obtain ⟨w, hyw, hzw⟩ := hc x y z hxy hxz
  exact (normalForm_reflTransGen_eq hy hyw).trans
    (normalForm_reflTransGen_eq hz hzw).symm

/-- Newman + uniqueness packaged: schedule independence on a generic ARS. -/
theorem newman_unique_nf {r : X → X → Prop}
    (hterm : Terminating r) (hlc : LocallyConfluent r)
    {x y z : X} (hxy : ReflTransGen r x y) (hy : NormalForm r y)
    (hxz : ReflTransGen r x z) (hz : NormalForm r z) : y = z :=
  confluent_unique_nf (newman hterm hlc) hxy hy hxz hz

end OPHProofChain.Rewriting
