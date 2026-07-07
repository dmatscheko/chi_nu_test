import Mathlib
import OPHProofChain.Core.Primitives
import OPHProofChain.Core.Rule90

/-!
# The hypothesis lattice of the canonical repair (`[formal-v6]`)

`Core/Primitives.lean` (T12) proves canonical completeness under the named
hypothesis `EdgeRepairable C`, and its docstrings — echoed by the proof-chain
document and the expository paper — call that hypothesis *strictly* weaker
than `FrustrationFree C`. The implication half is machine-checked there
(`edgeRepairable_of_frustrationFree`); the **strictness** half was asserted
prose until now. This module closes it with the natural witness: the very
width-3 Rule-90 carrier that `Core/Rule90.lean` uses to prove that no
frustration-free repair operator exists.

* `rule90_edgeRepairable` — the carrier **is** `EdgeRepairable`: the single
  interface can always be satisfied from its next-row endpoint, whose
  projection is the identity (copy the CA image of the seed row).
* `rule90_not_frustrationFree` — the carrier is **not** `FrustrationFree`:
  the seed patch cannot fix a record whose next row has unequal outer cells
  (every Rule-90 image has equal outer cells — `rule90t_outer_eq`), so
  `CanFix false` fails there.
* `edgeRepairable_strictly_weaker` — the two packaged: the inclusion
  `FrustrationFree ⊆ EdgeRepairable` of carriers is **proper**.

Payoff for the chain: T12's `canonical_completeness` genuinely covers
carriers outside the frustration-free class — this one included, so the
width-3 toy now witnesses *both* sides of the T12 grading (no operator can
satisfy H1∧H2∧H3 on it, yet the canonical operator's completeness theorem
still applies to it). This is a native module (own namespace section, no
edits to the attributed `Core/` copies).

Axioms: standard; no `sorry`, no `native_decide`.
-/

namespace OPH

/-- `[formal-v6]` The width-3 Rule-90 carrier is `EdgeRepairable`: for any
    record, the next-row patch (identity projection) satisfies the single
    interface by copying the CA image of the seed row. -/
theorem rule90_edgeRepairable : EdgeRepairable rule90Carrier := by
  intro e x _
  refine ⟨true, Or.inr rfl, rule90t (x false), fun e' _ => ?_⟩
  show rule90t (Function.update x true (rule90t (x false)) false)
      = Function.update x true (rule90t (x false)) true
  simp [Function.update]

/-- `[formal-v6]` The width-3 Rule-90 carrier is **not** `FrustrationFree`:
    the seed patch cannot fix a record whose next row is `(0,0,1)` — outside
    the CA image, whose outer cells always coincide. -/
theorem rule90_not_frustrationFree : ¬ FrustrationFree rule90Carrier := by
  intro h
  obtain ⟨s, hs⟩ :=
    h false (fun i => bif i then (false, false, true) else (false, false, false))
  have hcons := hs () (Or.inl rfl)
  have hred : rule90t s = (false, false, true) := by
    have : rule90t (Function.update
        (fun i => bif i then (false, false, true) else (false, false, false))
        false s false)
        = Function.update
            (fun i => bif i then (false, false, true) else (false, false, false))
            false s true := hcons
    simpa [Function.update] using this
  have houter := rule90t_outer_eq s
  rw [hred] at houter
  exact absurd houter (by decide)

/-- `[formal-v6]` **`EdgeRepairable` is STRICTLY weaker than
    `FrustrationFree`.** With `edgeRepairable_of_frustrationFree` (the
    implication), this witness makes the inclusion of carrier classes proper
    — and it is exactly the carrier on which `Core/Rule90.lean` proves that
    no frustration-free repair operator exists, so T12's completeness
    theorem provably covers carriers beyond the frustration-free class. -/
theorem edgeRepairable_strictly_weaker :
    EdgeRepairable rule90Carrier ∧ ¬ FrustrationFree rule90Carrier :=
  ⟨rule90_edgeRepairable, rule90_not_frustrationFree⟩

/-- `[formal-v7]` **The class inclusion, packaged as the proper inclusion it
    is** (holes-audit F29(v): the docs' "the inclusion of carrier classes is
    proper" was a one-meta-step gloss over the conjunction above; here is the
    packaged statement): every frustration-free carrier is edge-repairable,
    and some edge-repairable carrier is not frustration-free. -/
theorem frustrationFree_properly_within_edgeRepairable :
    (∀ C : OPHCarrier, FrustrationFree C → EdgeRepairable C) ∧
      ∃ C : OPHCarrier, EdgeRepairable C ∧ ¬ FrustrationFree C :=
  ⟨fun C => edgeRepairable_of_frustrationFree C,
   ⟨rule90Carrier, rule90_edgeRepairable, rule90_not_frustrationFree⟩⟩

/-! ### Axiom audit -/
#print axioms rule90_edgeRepairable
#print axioms rule90_not_frustrationFree
#print axioms edgeRepairable_strictly_weaker
#print axioms frustrationFree_properly_within_edgeRepairable

end OPH
