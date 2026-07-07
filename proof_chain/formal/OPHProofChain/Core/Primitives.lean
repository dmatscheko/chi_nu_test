/-
ATTRIBUTION: copied on 2026-07-06 from the OPH team's repository
  observer-patch-holography/LEAN/ObserverPatchHolography/Primitives.lean
  (same pinned toolchain/Mathlib revision), then MODIFIED in this tree:
  the source file's three documented `sorry`s (`localRepair`, `Repair`,
  `repair_respects_gauge`) are DISCHARGED here by the canonical
  frustration-free repair construction. Every modification is marked with
  a `[formal-v4]` tag; unmarked content is the OPH team's, verbatim
  (except this header and the import path).
-/
import Mathlib
import OPHProofChain.Core.AbstractRewriting

/-!
# OPH Primitives — concrete carrier model (full discharge) `[formal-v4]`

These are the primitives Proposition 4.2 depends on. Where the companion
paper *Reality as a Consensus Protocol* (`OPHConsensus`) pins down concrete
structural content, this file gives it: the patch-net carrier, the global state
type `Records`, the declared-overlap observation map, gauge equivalence as
the kernel of that map, and the weighted mismatch potential `Φ`.

**`[formal-v4]` — the three `sorry`s of the source file are discharged.**
The source file left `localRepair`, `Repair`, and `repair_respects_gauge`
`sorry`-bearing on purpose ("paper-incomplete asynchronous machinery"),
with the stated obstruction that the only *free* instances are degenerate
(`Repair := id`). This copy replaces them with genuine, non-degenerate
content — the **canonical frustration-free repair**:

* `localRepair C i x` fires **iff** some edge incident to `i` is broken
  *and* patch `i` can satisfy all its incident interfaces at once
  (`ShouldFire`); when it fires it snaps patch `i` to such a satisfying
  state (`Classical.choose` — one fixed choice per satisfying-state
  predicate, and the predicate depends only on the overlap data).
* `Repair C` iterates `localRepair` at the **least firing site** in a
  declared enumeration order of the patches (`Fintype.equivFin`) until
  quiescence — the companion paper's Route-B lesson (the declared order
  `≺_𝖠` of the quotient presentation), realized on the original carrier;
  totality by well-founded descent on the broken-edge count.
* `repair_respects_gauge` is then **provable**, because the fire condition,
  the satisfying-state predicate, the least firing site, and the descent
  measure are all functions of the declared overlap data `obsMap` only.

Consequences proved in the `[formal-v4]` section at the end of the file:
the file's own `Termination C` and `LyapunovDescent C` hold **for every
carrier**; `Completeness C` holds under the named local hypothesis
`EdgeRepairable C` (strictly weaker than `FrustrationFree C`); on
`demoCarrier` the canonical operator **is** the neighbour-copy repair
`demoLR`, so the file's own `Confluence demoCarrier` is **refuted** (T3 in
the file's own vocabulary) while `demoCarrier` is frustration-free. The
non-confluence lesson is unchanged: the canonical `Repair` buys schedule
independence by *declared order*, not for free.

## Concrete content from the paper

* `OPHCarrier` — *Reality* Def 1.1 (finite patch graph `G=(V,E)`; per-patch
  finite state spaces `S_i`; per-edge interface alphabet `I_e` and
  projections `π_{i,e}, π_{j,e}`) + Def 2 (edge weights `w_e > 0` and a
  per-edge distance `d_e` with `d_e(a,b)=0 ↔ a=b`).
* `Records C := (i : C.Patch) → C.State i` — *Reality* Def 1.1 global state
  space `Σ := ∏_{i∈V} S_i`.
* `Obs C` / `obsMap C` — *Paradise* line 311 declared observable overlap
  data: the per-edge exposed projection pair `e ↦ (π_{i,e}(x_i), π_{j,e}(x_j))`.
* `Φ C` — *Reality* Def 2 / *Paradise* line 300:
  `Φ(x) = Σ_e w_e · d_e(π_{i,e}(x_i), π_{j,e}(x_j))`.
* `gaugeEquiv C` — *Paradise* line 311: the kernel `Setoid.ker (obsMap C)`
  (same declared observable overlap data).
* `gaugeEquiv_equivalence` — `∼_gauge` is an equivalence relation (the kernel
  of any map is an equivalence); discharged by the from-first-principles term
  `⟨fun _ => rfl, Eq.symm, Eq.trans⟩` since `gaugeEquiv` unfolds to an `Eq`.
* `consistent_iff_edgeConsistent` — *Reality* Prop 1: `C = Φ⁻¹(0)`, the
  faithfulness witness keeping the `Φ` model from vacuously falsifying
  `Completeness`.
* `Site C` — *Reality* repair-site index (a local move fires at a patch).
* `demoCarrier` / `obsMap_demoCarrier_nonconstant` — an explicit two-patch
  carrier and a proof that its `obsMap` separates two records. This makes the
  non-vacuity of `gaugeEquiv`/`consistent_iff_edgeConsistent` an in-file fact
  (gaugeEquiv is strictly finer than the total relation), not merely an
  argued universal claim. Adds no `sorry`.

## What stayed `sorry` in the source file, and how it is discharged here `[formal-v4]`

* `localRepair`, `Repair` — the source file: "built from local recovery
  moves (line 297), composed under asynchronous schedules in `OPHConsensus`;
  not pinned to a constructive operator with a discharged
  Lyapunov+confluence proof." Here they are pinned: the canonical
  frustration-free snap operator and its declared-order iterate. The
  operator is *not* degenerate (`localRepair demoCarrier = demoLR`,
  proved below), the Lyapunov proof is discharged (`canonical_lyapunov`),
  and no confluence claim is smuggled in — `Repair`'s schedule
  independence is by declared order, and async `Confluence demoCarrier`
  is refuted outright.
* `repair_respects_gauge` — the source file: "explicitly unprovable while
  `Repair` itself is undefined." Here `Repair` is defined and the
  congruence is proved (`repair_respects_gauge`), the point being that
  every ingredient of the canonical operator factors through `obsMap`.
-/

namespace OPH

open Relation  -- `ReflTransGen` lives in the `Relation` namespace (cf. AbstractRewriting.lean)

/-- A finite OPH carrier: the patch graph `G=(V,E)` with per-patch state
    spaces, per-edge interface alphabets and projections, edge weights, and
    per-edge distances. Faithful encoding of *Reality* Def 1.1 + Def 2.

    Paper edges are unordered `{i,j}`; here each edge carries a fixed
    representative orientation `(src e, tgt e)`. This is sound: edge
    consistency `π_{i,e}(s_i) = π_{j,e}(s_j)` is symmetric and `Φ` is
    orientation-independent, so no further quotient on edges is needed. -/
structure OPHCarrier where
  /-- Observer patches `V` (vertices of the finite graph `G`). -/
  Patch : Type
  /-- `V` is finite. -/
  [patchFintype : Fintype Patch]
  /-- Patches have decidable equality (needed for, e.g., discrete metrics). -/
  [patchDecEq : DecidableEq Patch]
  /-- Per-patch local state space `S_i`. A genuine `Patch`-indexed family,
      NOT one shared type — faithful to projections out of *different*
      state spaces. -/
  State : Patch → Type
  /-- Interface edges `E` of the finite graph. -/
  Edge : Type
  /-- `E` is finite (so `Φ` is a finite sum). -/
  [edgeFintype : Fintype Edge]
  /-- Chosen source endpoint `i` of edge `e = {i,j}`. -/
  src : Edge → Patch
  /-- Chosen target endpoint `j` of edge `e = {i,j}`. -/
  tgt : Edge → Patch
  /-- Interface alphabet `I_e`. -/
  Iface : Edge → Type
  /-- Interface projection `π_{i,e} : S_i → I_e`. -/
  projSrc : (e : Edge) → State (src e) → Iface e
  /-- Interface projection `π_{j,e} : S_j → I_e`. -/
  projTgt : (e : Edge) → State (tgt e) → Iface e
  /-- Edge weight `w_e`. -/
  weight : Edge → NNReal
  /-- Per-edge distance `d_e` on the interface alphabet. -/
  dist : (e : Edge) → Iface e → Iface e → NNReal
  /-- *Reality* Def 2: weights are strictly positive. -/
  weight_pos : ∀ e : Edge, 0 < weight e
  /-- *Reality* Def 2: `d_e` separates points (`d_e(a,b)=0 ↔ a=b`). -/
  dist_eq_zero : ∀ (e : Edge) (a b : Iface e), dist e a b = 0 ↔ a = b

attribute [instance] OPHCarrier.patchFintype OPHCarrier.patchDecEq OPHCarrier.edgeFintype

variable (C : OPHCarrier)

/-- *Reality* Def 1.1: the global state space `Σ := ∏_{i∈V} S_i` — an
    assignment of a local state to every patch. (`Paradise` macro `\Records`.) -/
def Records : Type := (i : C.Patch) → C.State i

/-- *Paradise* line 311: the type of declared observable overlap data — the
    per-edge exposed projection-pair family. (`Paradise` macro `\Obs`.) -/
def Obs : Type := (e : C.Edge) → C.Iface e × C.Iface e

/-- The declared observable overlap data of a record: on every edge, the
    pair of interface projections it exposes,
    `e ↦ (π_{i,e}(x_i), π_{j,e}(x_j))` (*Paradise* line 311). This is a
    real, generally-non-constant map; `gaugeEquiv` is its kernel. -/
def obsMap (x : Records C) : Obs C :=
  fun e => (C.projSrc e (x (C.src e)), C.projTgt e (x (C.tgt e)))

/-- *Reality* repair-site index: a local accepted repair step fires at a
    patch. A faithful, non-vacuous index type. (`[formal-v4]`: the source
    file's parenthetical "it does NOT trivialise `localRepair`, which remains
    a genuine `sorry`" is obsolete — `localRepair` is now a genuine operator
    below, and it is non-trivial: `localRepair_demoCarrier` at the end of the
    file identifies it with the neighbour-copy repair on the demo carrier.) -/
def Site : Type := C.Patch

/-! ### `[formal-v4]` The canonical frustration-free repair

This block discharges the source file's first two `sorry`s.

**Design.** A patch `i` *should fire* at `x` when (a) some edge incident to
`i` is broken and (b) patch `i` can satisfy **all** its incident interfaces
at once — frustration-freeness *at* `(i,x)`. When it fires, it snaps patch
`i` to a satisfying state, obtained by `Classical.choose` from the
satisfying-state predicate. Two facts make this canonical rather than
arbitrary:

1. the satisfying-state predicate `IsLocalFix i x` is determined by the
   declared overlap data `obsMap C x` (the far endpoint of an incident edge
   enters only through its interface projection), and
2. `Classical.choose` picks **one fixed witness per predicate**
   (`choose_eq_of_pred_eq`), so gauge-equivalent records fire identically
   and snap to the *same* local state.

The composite `Repair` iterates the move at the **least firing site** in a
declared enumeration order of the patches — the companion paper's Route-B
declared order `≺_𝖠`, realized on the original carrier — and terminates by
well-founded descent on the broken-edge count.

The definitions `edgeConsistentAt` … `mem_brokenSet_iff_not_consistent`
below are the source file's own, moved up verbatim from its
`LocalRepairDynamics` section (a pointer remains there) so the operator can
use them. -/

variable {C}

/-- An edge is consistent at `x` when its two interface projections agree.
    A `Prop` (no `DecidableEq (Iface e)` needed). By `dist_eq_zero` this is
    equivalent to the edge's per-edge distance vanishing
    (`edgeConsistentAt_iff_dist`). Definitionally, `EdgeConsistent C x` is
    `∀ e, edgeConsistentAt e x`. -/
def edgeConsistentAt (e : C.Edge) (x : Records C) : Prop :=
  C.projSrc e (x (C.src e)) = C.projTgt e (x (C.tgt e))

/-- Bridge to the decidable surrogate used by `mismatchCount`: an edge is
    consistent iff its per-edge distance is `0` (uses `dist_eq_zero`). -/
theorem edgeConsistentAt_iff_dist (e : C.Edge) (x : Records C) :
    edgeConsistentAt e x ↔
      C.dist e (C.projSrc e (x (C.src e))) (C.projTgt e (x (C.tgt e))) = 0 :=
  (C.dist_eq_zero e _ _).symm

/-- The set of broken edges of `x`: those whose per-edge distance is nonzero.
    This is decidable *without* `DecidableEq (Iface e)`, because `ℝ≥0` has
    `DecidableEq` (from its `LinearOrder`), so `(· ≠ 0)` is a `DecidablePred`. -/
noncomputable def brokenSet (x : Records C) : Finset C.Edge :=
  Finset.univ.filter
    (fun e => C.dist e (C.projSrc e (x (C.src e))) (C.projTgt e (x (C.tgt e))) ≠ 0)

/-- The well-founded `ℕ` surrogate for `Φ`: the number of broken edges.
    (`Φ : ℝ≥0` is not `<`-well-founded; this `ℕ` shadow is.) -/
noncomputable def mismatchCount (x : Records C) : Nat := (brokenSet x).card

theorem mem_brokenSet {x : Records C} {e : C.Edge} :
    e ∈ brokenSet x ↔
      C.dist e (C.projSrc e (x (C.src e))) (C.projTgt e (x (C.tgt e))) ≠ 0 := by
  unfold brokenSet
  rw [Finset.mem_filter]
  exact ⟨fun h => h.2, fun h => ⟨Finset.mem_univ e, h⟩⟩

/-- An edge is broken at `x` exactly when it is *not* consistent there.
    (`mem_brokenSet` composed with the `dist`-bridge `edgeConsistentAt_iff_dist`,
    using `Ne` `=` `¬ (· = ·)` definitionally.) -/
theorem mem_brokenSet_iff_not_consistent {x : Records C} {e : C.Edge} :
    e ∈ brokenSet x ↔ ¬ edgeConsistentAt e x :=
  mem_brokenSet.trans (not_congr (edgeConsistentAt_iff_dist e x)).symm

/-- `[formal-v4]` Edge `e` is incident to patch `i`. -/
def Incident (i : C.Patch) (e : C.Edge) : Prop := C.src e = i ∨ C.tgt e = i

/-- `[formal-v4]` `s` is a *local fix* for patch `i` at `x`: updating patch
    `i` to state `s` makes every edge incident to `i` consistent. -/
def IsLocalFix (i : C.Patch) (x : Records C) (s : C.State i) : Prop :=
  ∀ e : C.Edge, Incident i e → edgeConsistentAt e (Function.update x i s)

/-- `[formal-v4]` Patch `i` can satisfy all its incident interfaces at `x`
    simultaneously (frustration-freeness at `(i,x)`). -/
def CanFix (i : C.Patch) (x : Records C) : Prop := ∃ s : C.State i, IsLocalFix i x s

/-- `[formal-v4]` Some edge incident to `i` is broken at `x`. -/
def HasBrokenIncident (i : C.Patch) (x : Records C) : Prop :=
  ∃ e : C.Edge, Incident i e ∧ ¬ edgeConsistentAt e x

/-- `[formal-v4]` The canonical fire condition at `(i,x)`: a broken incident
    edge exists AND the patch can satisfy all its interfaces at once. -/
def ShouldFire (i : C.Patch) (x : Records C) : Prop :=
  HasBrokenIncident i x ∧ CanFix i x

theorem ShouldFire.hasBroken {i : C.Patch} {x : Records C} (h : ShouldFire i x) :
    HasBrokenIncident i x :=
  And.left (show HasBrokenIncident i x ∧ CanFix i x from h)

theorem ShouldFire.canFix {i : C.Patch} {x : Records C} (h : ShouldFire i x) :
    CanFix i x :=
  And.right (show HasBrokenIncident i x ∧ CanFix i x from h)

/-- `[formal-v4]` `Classical.choose` is a function of the *predicate*: equal
    predicates give equal chosen witnesses (definitional proof irrelevance).
    This is what makes the canonical repair gauge-functorial. -/
theorem choose_eq_of_pred_eq {α : Sort*} {p q : α → Prop} (h : p = q)
    (hp : ∃ a, p a) (hq : ∃ a, q a) :
    hp.choose = hq.choose := by
  subst h
  rfl

open Classical in
/-- `[formal-v4]` The sites whose canonical move fires at `x`. -/
noncomputable def firingSites (x : Records C) : Finset C.Patch :=
  Finset.univ.filter (fun i => ShouldFire i x)

open Classical in
theorem mem_firingSites {i : C.Patch} {x : Records C} :
    i ∈ firingSites x ↔ ShouldFire i x := by
  unfold firingSites
  rw [Finset.mem_filter]
  exact ⟨fun h => h.2, fun h => ⟨Finset.mem_univ i, h⟩⟩

/-- `[formal-v4]` The declared patch order: the enumeration underlying the
    carrier's `Fintype` instance. Any fixed order would do; what matters is
    that one is *declared* (the paper's `≺_𝖠`). -/
noncomputable def siteOrder : C.Patch ≃ Fin (Fintype.card C.Patch) :=
  Fintype.equivFin C.Patch

/-- `[formal-v4]` The least firing site of `x` in the declared order. -/
noncomputable def leastFiringSite (x : Records C) (h : (firingSites x).Nonempty) :
    C.Patch :=
  siteOrder.symm (((firingSites x).image siteOrder).min' (h.image _))

theorem leastFiringSite_shouldFire (x : Records C) (h : (firingSites x).Nonempty) :
    ShouldFire (leastFiringSite x h) x := by
  have hm := Finset.min'_mem ((firingSites x).image siteOrder) (h.image _)
  obtain ⟨i, hi, hie⟩ := Finset.mem_image.mp hm
  have hls : leastFiringSite x h = i := by
    unfold leastFiringSite
    rw [← hie, Equiv.symm_apply_apply]
  rw [hls]
  exact mem_firingSites.mp hi

variable (C)

open Classical in
/-- One transactional/local recovery move at a repair site.
    **`[formal-v4]` — was the source file's first `sorry`; now the canonical
    frustration-free snap operator.** Fires iff `ShouldFire i x`; when it
    fires it updates patch `i` to a chosen state satisfying all incident
    interfaces. -/
noncomputable def localRepair : Site C → Records C → Records C := fun i x =>
  if h : ShouldFire i x then Function.update x i h.canFix.choose else x

/-- `[formal-v4]` The firing equation of `localRepair`. -/
theorem localRepair_of_shouldFire {i : Site C} {x : Records C}
    (h : ShouldFire i x) :
    localRepair C i x = Function.update x i h.canFix.choose := by
  unfold localRepair
  rw [dif_pos h]

/-- `[formal-v4]` The chosen state of a firing move is a local fix. -/
theorem localRepair_choose_isLocalFix {i : Site C} {x : Records C}
    (h : ShouldFire i x) :
    IsLocalFix i x h.canFix.choose :=
  h.canFix.choose_spec

/-- `[formal-v4]` The quiescence equation of `localRepair`. -/
theorem localRepair_of_not_shouldFire {i : Site C} {x : Records C}
    (h : ¬ ShouldFire i x) :
    localRepair C i x = x := by
  unfold localRepair
  rw [dif_neg h]

/-- `[formal-v4]` `localRepair` moves iff the canonical fire condition holds:
    it can never silently fix a broken edge without registering as a step,
    and it never fires on quiescent input. -/
theorem localRepair_ne_iff {i : Site C} {x : Records C} :
    localRepair C i x ≠ x ↔ ShouldFire i x := by
  constructor
  · intro hne
    by_contra h
    exact hne (localRepair_of_not_shouldFire C h)
  · intro h
    rw [localRepair_of_shouldFire C h]
    intro heq
    obtain ⟨e₀, hinc₀, hbrk₀⟩ := h.hasBroken
    have hfix := localRepair_choose_isLocalFix C h e₀ hinc₀
    rw [heq] at hfix
    exact hbrk₀ hfix

/-- `[formal-v4]` H1 for the canonical operator, unconditionally: firing at
    `i` changes patch `i` only. -/
theorem localRepair_apply_of_ne {i : Site C} {x : Records C} {j : C.Patch}
    (hj : j ≠ i) :
    localRepair C i x j = x j := by
  by_cases h : ShouldFire i x
  · rw [localRepair_of_shouldFire C h]
    exact Function.update_of_ne hj _ _
  · rw [localRepair_of_not_shouldFire C h]

/-- `[formal-v4]` H3 for the canonical operator, unconditionally: when the
    move at `i` fires, all edges incident to `i` come out consistent. -/
theorem localRepair_fixes_incident {i : Site C} {x : Records C}
    (hf : localRepair C i x ≠ x) {e : C.Edge} (he : Incident i e) :
    edgeConsistentAt e (localRepair C i x) := by
  have h := (localRepair_ne_iff C).mp hf
  rw [localRepair_of_shouldFire C h]
  exact localRepair_choose_isLocalFix C h e he

/-- `[formal-v4]` Half of H2, unconditionally: a firing move witnesses a
    broken incident edge. -/
theorem localRepair_hasBroken {i : Site C} {x : Records C}
    (hf : localRepair C i x ≠ x) :
    HasBrokenIncident i x :=
  ((localRepair_ne_iff C).mp hf).hasBroken

/-- `[formal-v4]` **Lyapunov descent on the `ℕ` surrogate, unconditionally.**
    Every genuine canonical move strictly shrinks the broken-edge set: the
    incident edges (including the broken witness) come out consistent, and
    no other edge changes. -/
theorem mismatchCount_localRepair_lt {i : Site C} {x : Records C}
    (hf : localRepair C i x ≠ x) :
    mismatchCount (localRepair C i x) < mismatchCount x := by
  have hsub : brokenSet (localRepair C i x) ⊆ brokenSet x := by
    intro e he
    by_cases hinc : Incident i e
    · exact absurd (localRepair_fixes_incident C hf hinc)
        (mem_brokenSet_iff_not_consistent.1 he)
    · have hs : C.src e ≠ i := fun h => hinc (Or.inl h)
      have ht : C.tgt e ≠ i := fun h => hinc (Or.inr h)
      have h1 : localRepair C i x (C.src e) = x (C.src e) :=
        localRepair_apply_of_ne C hs
      have h2 : localRepair C i x (C.tgt e) = x (C.tgt e) :=
        localRepair_apply_of_ne C ht
      rw [mem_brokenSet, h1, h2] at he
      exact mem_brokenSet.mpr he
  obtain ⟨e₀, hinc₀, hbrk₀⟩ := localRepair_hasBroken C hf
  have hmem : e₀ ∈ brokenSet x := mem_brokenSet_iff_not_consistent.2 hbrk₀
  have hnot : e₀ ∉ brokenSet (localRepair C i x) := fun hm =>
    mem_brokenSet_iff_not_consistent.1 hm (localRepair_fixes_incident C hf hinc₀)
  exact Finset.card_lt_card ((Finset.ssubset_iff_of_subset hsub).2 ⟨e₀, hmem, hnot⟩)

open Classical in
/-- The composite repair operator reaching a normal form.
    **`[formal-v4]` — was the source file's second `sorry`; now the
    declared-order iterate**: fire the least firing site in the declared
    patch order, repeat until quiescent. Total by well-founded descent on
    the broken-edge count. This is the companion paper's Route B (declared
    schedule) realized on the original carrier — schedule independence is
    *purchased by the declared order*, not assumed. -/
noncomputable def Repair (x : Records C) : Records C :=
  if h : (firingSites x).Nonempty then
    Repair (localRepair C (leastFiringSite x h) x)
  else x
termination_by mismatchCount x
decreasing_by
  exact mismatchCount_localRepair_lt C
    ((localRepair_ne_iff C).mpr (leastFiringSite_shouldFire x h))

/-- `[formal-v4]` `Repair` on quiescent input. -/
theorem Repair_of_no_fire {x : Records C} (h : ¬ (firingSites x).Nonempty) :
    Repair C x = x := by
  rw [Repair]
  exact dif_neg h

/-- `[formal-v4]` `Repair` unfolding on firing input. -/
theorem Repair_of_fire {x : Records C} (h : (firingSites x).Nonempty) :
    Repair C x = Repair C (localRepair C (leastFiringSite x h) x) := by
  conv_lhs => rw [Repair]
  exact dif_pos h

/-- `[formal-v4]` `Repair` lands on records where no site fires. -/
theorem Repair_no_fire (x : Records C) : ¬ (firingSites (Repair C x)).Nonempty := by
  suffices H : ∀ (n : ℕ) (x : Records C), mismatchCount x ≤ n →
      ¬ (firingSites (Repair C x)).Nonempty from
    H (mismatchCount x) x le_rfl
  intro n
  induction n with
  | zero =>
    intro x hx
    by_cases h : (firingSites x).Nonempty
    · have hlt := mismatchCount_localRepair_lt C
        ((localRepair_ne_iff C).mpr (leastFiringSite_shouldFire x h))
      omega
    · rw [Repair_of_no_fire C h]
      exact h
  | succ n ih =>
    intro x hx
    by_cases h : (firingSites x).Nonempty
    · rw [Repair_of_fire C h]
      apply ih
      have hlt := mismatchCount_localRepair_lt C
        ((localRepair_ne_iff C).mpr (leastFiringSite_shouldFire x h))
      omega
    · rw [Repair_of_no_fire C h]
      exact h

/-- `[formal-v4]` Every site is quiescent at `Repair C x`. -/
theorem localRepair_Repair (x : Records C) (i : Site C) :
    localRepair C i (Repair C x) = Repair C x := by
  by_contra hne
  exact Repair_no_fire C x
    ⟨i, mem_firingSites.mpr ((localRepair_ne_iff C).mp hne)⟩

/-- `[formal-v4]` `Repair` is idempotent. -/
theorem Repair_idem (x : Records C) : Repair C (Repair C x) = Repair C x :=
  Repair_of_no_fire C (Repair_no_fire C x)

/-- One accepted asynchronous repair step: some site's local move changes
    the record. This is the relation the generic abstract-rewriting
    skeleton instantiates after the concrete repair layer is supplied. -/
def acceptedStep (x y : Records C) : Prop :=
  ∃ i : Site C, y = localRepair C i x ∧ localRepair C i x ≠ x

/-- *Reality* Def 2 / *Paradise* line 300: the weighted edge-mismatch
    potential `Φ(x) = Σ_e w_e · d_e(π_{i,e}(x_i), π_{j,e}(x_j))`. A finite
    `Finset.sum` over the (finite) edge set, valued in `ℝ≥0`. -/
noncomputable def Φ (x : Records C) : NNReal :=
  ∑ e : C.Edge, C.weight e * C.dist e (C.projSrc e (x (C.src e))) (C.projTgt e (x (C.tgt e)))

/-- A normal form: no accepted repair step applies. -/
def NormalForm (x : Records C) : Prop :=
  ∀ y : Records C, ¬ acceptedStep C x y

/-- Consistency: zero mismatch potential. By `consistent_iff_edgeConsistent`
    this coincides with the paper's `C = Φ⁻¹(0)` (edge-by-edge agreement). -/
def Consistent (x : Records C) : Prop :=
  Φ C x = 0

/-- Edge-consistency (*Reality* Def 1.1): every edge's two projections agree.
    `C := {s : ∀ e, π_{src e}(s) = π_{tgt e}(s)}`. -/
def EdgeConsistent (x : Records C) : Prop :=
  ∀ e : C.Edge, C.projSrc e (x (C.src e)) = C.projTgt e (x (C.tgt e))

/-- *Reality* Prop 1: the model satisfies `C = Φ⁻¹(0)` — `Φ x = 0` holds iff
    `x` is edge-consistent. This is the faithfulness witness for the `Φ`
    model (it is what stops `Φ` from vacuously falsifying `Completeness`);
    it uses both carrier hypotheses `weight_pos` and `dist_eq_zero`. -/
theorem consistent_iff_edgeConsistent (x : Records C) :
    Consistent C x ↔ EdgeConsistent C x := by
  unfold Consistent EdgeConsistent Φ
  -- Use the nonneg-codomain form `sum_eq_zero_iff_of_nonneg`: it needs only
  -- `AddCommMonoid + PartialOrder + AddLeftMono` (all held by `ℝ≥0`) and takes
  -- the pointwise `0 ≤ ·` proof explicitly, so it avoids the `Subsingleton
  -- (AddUnits ·)` instance search that the bare `Finset.sum_eq_zero_iff`
  -- relies on. (`zero_le _` is the canonical `0 ≤ x` on `ℝ≥0`.)
  rw [Finset.sum_eq_zero_iff_of_nonneg (fun i _ => zero_le _)]
  constructor
  · intro h e
    have he := h e (Finset.mem_univ e)
    rcases mul_eq_zero.mp he with hw | hd
    · exact absurd hw (C.weight_pos e).ne'
    · exact (C.dist_eq_zero e _ _).mp hd
  · intro h e _
    have hd : C.dist e (C.projSrc e (x (C.src e))) (C.projTgt e (x (C.tgt e))) = 0 :=
      (C.dist_eq_zero e _ _).mpr (h e)
    rw [hd, mul_zero]

/-- The Lyapunov-descent obligation: every accepted step strictly lowers `Φ`. -/
def LyapunovDescent : Prop :=
  ∀ x y : Records C, acceptedStep C x y → Φ C y < Φ C x

/-- Termination of the accepted-step relation. -/
def Termination : Prop :=
  WellFounded (fun y x : Records C => acceptedStep C x y)

/-- *Paradise* line 311: two records are gauge-equivalent iff they expose the
    same declared observable overlap data. Idiomatically, this is the
    **kernel setoid** `Setoid.ker (obsMap C)`: `gaugeEquiv C x y` unfolds to
    `obsMap C x = obsMap C y`. It is non-vacuous — strictly finer than the
    total relation whenever `obsMap` is non-constant. -/
def gaugeEquiv (x y : Records C) : Prop :=
  (Setoid.ker (obsMap C)).r x y

/-- `∼_gauge` is an equivalence relation. True for the structural reason that
    `gaugeEquiv` is the kernel of `obsMap`: `gaugeEquiv C x y` unfolds (through
    `Setoid.ker` and `Function.onFun`) to the genuine equality
    `obsMap C x = obsMap C y`, whose reflexivity/symmetry/transitivity are
    `rfl`/`Eq.symm`/`Eq.trans`. We discharge it with this from-first-principles
    term rather than `(Setoid.ker (obsMap C)).iseqv` to avoid relying on the
    `.r`-vs-η defeq between `Equivalence (gaugeEquiv C)` and
    `Equivalence ⇑(Setoid.ker (obsMap C))`. -/
theorem gaugeEquiv_equivalence : Equivalence (gaugeEquiv C) :=
  ⟨fun _ => rfl, Eq.symm, Eq.trans⟩

/-! ### `[formal-v4]` Everything the canonical repair reads factors through `obsMap`

The lemma chain behind `repair_respects_gauge`: edge-consistency, the
satisfying-state predicate, the fire condition, the firing set, the least
firing site, the chosen snap state, and the descent measure are each
determined by the declared overlap data. This is exactly the content Prop 4.2
sentence 2 demands of the real repair — here it is machine-checked for the
canonical operator. -/

theorem edgeConsistentAt_congr {x y : Records C} (h : obsMap C x = obsMap C y)
    (e : C.Edge) :
    edgeConsistentAt e x ↔ edgeConsistentAt e y := by
  have h1 : C.projSrc e (x (C.src e)) = C.projSrc e (y (C.src e)) :=
    congrArg Prod.fst (congrFun h e)
  have h2 : C.projTgt e (x (C.tgt e)) = C.projTgt e (y (C.tgt e)) :=
    congrArg Prod.snd (congrFun h e)
  unfold edgeConsistentAt
  rw [h1, h2]

theorem obsMap_update_congr {x y : Records C} (h : obsMap C x = obsMap C y)
    (i : C.Patch) (s : C.State i) :
    obsMap C (Function.update x i s) = obsMap C (Function.update y i s) := by
  funext e
  have hx := congrFun h e
  unfold obsMap at hx ⊢
  congr 1
  · by_cases hs : C.src e = i
    · subst hs
      rw [Function.update_self, Function.update_self]
    · rw [Function.update_of_ne hs, Function.update_of_ne hs]
      exact congrArg Prod.fst hx
  · by_cases ht : C.tgt e = i
    · subst ht
      rw [Function.update_self, Function.update_self]
    · rw [Function.update_of_ne ht, Function.update_of_ne ht]
      exact congrArg Prod.snd hx

theorem isLocalFix_congr {x y : Records C} (h : obsMap C x = obsMap C y)
    (i : C.Patch) :
    IsLocalFix i x = IsLocalFix i y := by
  funext s
  refine propext ⟨fun hf e he => ?_, fun hf e he => ?_⟩
  · exact (edgeConsistentAt_congr C (obsMap_update_congr C h i s) e).mp (hf e he)
  · exact (edgeConsistentAt_congr C (obsMap_update_congr C h i s) e).mpr (hf e he)

theorem canFix_congr {x y : Records C} (h : obsMap C x = obsMap C y)
    (i : C.Patch) :
    CanFix i x = CanFix i y := by
  unfold CanFix
  rw [isLocalFix_congr C h i]

theorem hasBrokenIncident_congr {x y : Records C} (h : obsMap C x = obsMap C y)
    (i : C.Patch) :
    HasBrokenIncident i x = HasBrokenIncident i y := by
  unfold HasBrokenIncident
  refine propext
    ⟨fun ⟨e, he, hb⟩ => ⟨e, he, fun hc => hb ((edgeConsistentAt_congr C h e).mpr hc)⟩,
     fun ⟨e, he, hb⟩ => ⟨e, he, fun hc => hb ((edgeConsistentAt_congr C h e).mp hc)⟩⟩

theorem shouldFire_congr {x y : Records C} (h : obsMap C x = obsMap C y)
    (i : C.Patch) :
    ShouldFire i x = ShouldFire i y := by
  unfold ShouldFire
  rw [hasBrokenIncident_congr C h i, canFix_congr C h i]

theorem localRepair_obs_congr {x y : Records C} (h : obsMap C x = obsMap C y)
    (i : Site C) :
    obsMap C (localRepair C i x) = obsMap C (localRepair C i y) := by
  by_cases hf : ShouldFire i x
  · have hfy : ShouldFire i y := (shouldFire_congr C h i).mp hf
    rw [localRepair_of_shouldFire C hf, localRepair_of_shouldFire C hfy]
    have hcheq : hf.canFix.choose = hfy.canFix.choose :=
      choose_eq_of_pred_eq (isLocalFix_congr C h i) hf.canFix hfy.canFix
    rw [← hcheq]
    exact obsMap_update_congr C h i hf.canFix.choose
  · have hfy : ¬ ShouldFire i y := fun hy => hf ((shouldFire_congr C h i).mpr hy)
    rw [localRepair_of_not_shouldFire C hf, localRepair_of_not_shouldFire C hfy]
    exact h

theorem brokenSet_congr {x y : Records C} (h : obsMap C x = obsMap C y) :
    brokenSet x = brokenSet y := by
  ext e
  rw [mem_brokenSet_iff_not_consistent, mem_brokenSet_iff_not_consistent]
  exact not_congr (edgeConsistentAt_congr C h e)

theorem mismatchCount_congr {x y : Records C} (h : obsMap C x = obsMap C y) :
    mismatchCount x = mismatchCount y := by
  unfold mismatchCount
  rw [brokenSet_congr C h]

theorem firingSites_congr {x y : Records C} (h : obsMap C x = obsMap C y) :
    firingSites x = firingSites y := by
  ext i
  rw [mem_firingSites, mem_firingSites, shouldFire_congr C h i]

/-- `[formal-v4]` Auxiliary congruence: the least element of the ordered
    image depends only on the set (proofs are irrelevant). -/
theorem leastFiringSite_congr_aux {s t : Finset C.Patch} (hst : s = t)
    (hs : s.Nonempty) (ht : t.Nonempty) :
    siteOrder.symm ((s.image siteOrder).min' (hs.image _)) =
      siteOrder.symm ((t.image siteOrder).min' (ht.image _)) := by
  subst hst
  rfl

theorem leastFiringSite_congr {x y : Records C} (h : obsMap C x = obsMap C y)
    (hx : (firingSites x).Nonempty) (hy : (firingSites y).Nonempty) :
    leastFiringSite x hx = leastFiringSite y hy :=
  leastFiringSite_congr_aux C (firingSites_congr C h) hx hy

/-- `[formal-v4]` The composite `Repair` factors through `obsMap`: the whole
    iterated schedule (which site fires, in which order, snapping to which
    state) is a function of the declared overlap data. -/
theorem obsMap_Repair_congr {x y : Records C} (h : obsMap C x = obsMap C y) :
    obsMap C (Repair C x) = obsMap C (Repair C y) := by
  suffices H : ∀ (n : ℕ) (x y : Records C), mismatchCount x ≤ n →
      obsMap C x = obsMap C y →
      obsMap C (Repair C x) = obsMap C (Repair C y) from
    H (mismatchCount x) x y le_rfl h
  intro n
  induction n with
  | zero =>
    intro x y hx h
    by_cases hf : (firingSites x).Nonempty
    · have hlt := mismatchCount_localRepair_lt C
        ((localRepair_ne_iff C).mpr (leastFiringSite_shouldFire x hf))
      omega
    · have hfy : ¬ (firingSites y).Nonempty := by
        rw [← firingSites_congr C h]
        exact hf
      rw [Repair_of_no_fire C hf, Repair_of_no_fire C hfy]
      exact h
  | succ n ih =>
    intro x y hx h
    by_cases hf : (firingSites x).Nonempty
    · have hfy : (firingSites y).Nonempty := by
        rw [← firingSites_congr C h]
        exact hf
      rw [Repair_of_fire C hf, Repair_of_fire C hfy]
      have hls : leastFiringSite x hf = leastFiringSite y hfy :=
        leastFiringSite_congr C h hf hfy
      have hstep : obsMap C (localRepair C (leastFiringSite x hf) x)
          = obsMap C (localRepair C (leastFiringSite y hfy) y) := by
        rw [← hls]
        exact localRepair_obs_congr C h (leastFiringSite x hf)
      refine ih _ _ ?_ hstep
      have hlt := mismatchCount_localRepair_lt C
        ((localRepair_ne_iff C).mpr (leastFiringSite_shouldFire x hf))
      omega
    · have hfy : ¬ (firingSites y).Nonempty := by
        rw [← firingSites_congr C h]
        exact hf
      rw [Repair_of_no_fire C hf, Repair_of_no_fire C hfy]
      exact h

/-- `∼_gauge` is a `Repair`-congruence. Required by Prop 4.2 sentence 2
    (independence on the physical quotient).

    **`[formal-v4]` — was the source file's third `sorry`; now proved.** The
    source file's obstruction ("cannot be soundly proved while `Repair`
    itself is a `sorry`; the only free instances are degenerate") is
    resolved the non-degenerate way: `Repair` is now the genuine canonical
    consensus operator, it provably factors through `obsMap`
    (`obsMap_Repair_congr`), and none of `Termination`/`Completeness`/
    `LyapunovDescent` became vacuous — see the `[formal-v4]` dynamical
    obligations section below and `localRepair_demoCarrier` at the end of
    the file. -/
theorem repair_respects_gauge :
    ∀ x y : Records C, gaugeEquiv C x y → gaugeEquiv C (Repair C x) (Repair C y) :=
  fun _ _ h => obsMap_Repair_congr C h

/-- OPH confluence condition for accepted asynchronous repair steps
    (Prop 4.2 hypothesis; defined per OPHConsensus). -/
def Confluence : Prop :=
  ∀ x y z : Records C, ReflTransGen (acceptedStep C) x y → ReflTransGen (acceptedStep C) x z →
    ∃ w : Records C, ReflTransGen (acceptedStep C) y w ∧ ReflTransGen (acceptedStep C) z w

/-- OPH repair completeness: normal forms are exactly consistent states.
    Termination is a separate Lyapunov/finite-state obligation. -/
def Completeness : Prop :=
  ∀ x : Records C, NormalForm C x ↔ Consistent C x

/-! ### `[formal-v4]` The file's own dynamical obligations, discharged

With `localRepair`/`Repair` genuine, the file's own `def`s become theorems:
`LyapunovDescent C` and `Termination C` hold for **every** carrier;
`Completeness C` holds under the named local hypothesis `EdgeRepairable C`
(every broken edge has an endpoint that can satisfy all its interfaces —
implied by full frustration-freeness). `Confluence C` is deliberately NOT
provided: it is **refuted** on `demoCarrier` at the end of the file — the
source file's non-confluence lesson, restated for the canonical operator.

H2 fine print: the canonical operator satisfies the `LocalRepairDynamics`
law `H2` ("fires iff a broken incident edge exists") exactly on
frustration-free carriers (`canonical_H2` below). On a carrier with a
frustrated patch it fires strictly less often — which is what keeps it
total on every carrier, while `Rule90.lean`'s
`rule90_no_frustrationFree_repair` proves that nothing can satisfy
`H1 ∧ H2 ∧ H3` there. The two results are two sides of the same coin. -/

/-- `[formal-v4]` Every patch can always satisfy all its incident interfaces
    simultaneously: a frustration-free carrier. -/
def FrustrationFree : Prop :=
  ∀ (i : C.Patch) (x : Records C), CanFix i x

/-- `[formal-v4]` Every broken edge has at least one endpoint patch that can
    satisfy all its incident interfaces (strictly weaker than
    `FrustrationFree`). -/
def EdgeRepairable : Prop :=
  ∀ (e : C.Edge) (x : Records C), ¬ edgeConsistentAt e x →
    ∃ i : C.Patch, Incident i e ∧ CanFix i x

theorem edgeRepairable_of_frustrationFree (h : FrustrationFree C) :
    EdgeRepairable C :=
  fun e x _ => ⟨C.src e, Or.inl rfl, h (C.src e) x⟩

/-- `[formal-v4]` **The file's own `LyapunovDescent`, discharged
    unconditionally**: every accepted canonical step strictly lowers `Φ`
    (incident edges — including the broken witness — come out consistent;
    nothing else moves). -/
theorem canonical_lyapunov : LyapunovDescent C := by
  rintro x y ⟨i, rfl, hfire⟩
  unfold Φ
  refine Finset.sum_lt_sum (fun e _ => ?_) ?_
  · by_cases hinc : Incident i e
    · have hd : C.dist e (C.projSrc e (localRepair C i x (C.src e)))
          (C.projTgt e (localRepair C i x (C.tgt e))) = 0 :=
        (edgeConsistentAt_iff_dist e _).mp (localRepair_fixes_incident C hfire hinc)
      rw [hd, mul_zero]
      exact zero_le _
    · have hs : C.src e ≠ i := fun h => hinc (Or.inl h)
      have ht : C.tgt e ≠ i := fun h => hinc (Or.inr h)
      rw [localRepair_apply_of_ne C hs, localRepair_apply_of_ne C ht]
  · obtain ⟨e₀, hinc₀, hbrk₀⟩ := localRepair_hasBroken C hfire
    refine ⟨e₀, Finset.mem_univ e₀, ?_⟩
    have hafter : C.dist e₀ (C.projSrc e₀ (localRepair C i x (C.src e₀)))
        (C.projTgt e₀ (localRepair C i x (C.tgt e₀))) = 0 :=
      (edgeConsistentAt_iff_dist e₀ _).mp (localRepair_fixes_incident C hfire hinc₀)
    have hbefore : C.dist e₀ (C.projSrc e₀ (x (C.src e₀)))
        (C.projTgt e₀ (x (C.tgt e₀))) ≠ 0 := by
      intro h0
      exact hbrk₀ ((edgeConsistentAt_iff_dist e₀ x).mpr h0)
    rw [hafter, mul_zero]
    exact mul_pos (C.weight_pos e₀) (pos_iff_ne_zero.mpr hbefore)

/-- `[formal-v4]` **The file's own `Termination`, discharged
    unconditionally**: the canonical accepted-step relation is well-founded
    on every carrier. -/
theorem canonical_termination : Termination C := by
  have H : Subrelation (fun y x : Records C => acceptedStep C x y)
      (InvImage (· < ·) mismatchCount) := by
    intro y x hxy
    obtain ⟨i, rfl, hfire⟩ := hxy
    exact mismatchCount_localRepair_lt C hfire
  exact Subrelation.wf H (InvImage.wf _ wellFounded_lt)

/-- `[formal-v4]` Consistent records are normal forms of the canonical
    accepted-step relation, unconditionally. -/
theorem normalForm_of_consistent {x : Records C} (hc : Consistent C x) :
    NormalForm C x := by
  rw [consistent_iff_edgeConsistent] at hc
  rintro y ⟨i, rfl, hfire⟩
  obtain ⟨e, _, hbrk⟩ := localRepair_hasBroken C hfire
  exact hbrk (hc e)

/-- `[formal-v4]` **The file's own `Completeness`, discharged under
    `EdgeRepairable`** (in particular under `FrustrationFree`): normal forms
    are exactly the consistent records. -/
theorem canonical_completeness (hER : EdgeRepairable C) : Completeness C := by
  intro x
  constructor
  · intro hnf
    rw [consistent_iff_edgeConsistent]
    intro e
    by_contra hbrk
    obtain ⟨i, hinc, hcf⟩ := hER e x hbrk
    have hfire : localRepair C i x ≠ x :=
      (localRepair_ne_iff C).mpr ⟨⟨e, hinc, hbrk⟩, hcf⟩
    exact hnf (localRepair C i x) ⟨i, rfl, hfire⟩
  · exact normalForm_of_consistent C

/-- `[formal-v4]` `H2` of the `LocalRepairDynamics` section holds for the
    canonical operator on frustration-free carriers (`H1`/`H3` hold
    unconditionally: `localRepair_apply_of_ne`, `localRepair_fixes_incident`).
    So on a frustration-free carrier the whole generic section — including
    `boundary_fiber_observer_unique` — applies to the canonical operator. -/
theorem canonical_H2 (hFF : FrustrationFree C) (i : C.Patch) (x : Records C) :
    localRepair C i x ≠ x ↔
      ∃ e : C.Edge, (C.src e = i ∨ C.tgt e = i) ∧ ¬ edgeConsistentAt e x := by
  rw [localRepair_ne_iff C]
  constructor
  · intro h
    exact h.hasBroken
  · intro h
    exact ⟨h, hFF i x⟩

/-- `[formal-v4]` If the input is already consistent, `Repair` does not move. -/
theorem Repair_of_consistent {x : Records C} (hc : Consistent C x) :
    Repair C x = x := by
  apply Repair_of_no_fire
  rintro ⟨i, hi⟩
  obtain ⟨e, _, hbrk⟩ := (mem_firingSites.mp hi).hasBroken
  rw [consistent_iff_edgeConsistent] at hc
  exact hbrk (hc e)

/-- `[formal-v4]` `Repair C x` is reached from `x` by accepted asynchronous
    steps — the composite operator is one particular accepted schedule (the
    declared one), not a new primitive. -/
theorem Repair_reduction (x : Records C) :
    ReflTransGen (acceptedStep C) x (Repair C x) := by
  suffices H : ∀ (n : ℕ) (x : Records C), mismatchCount x ≤ n →
      ReflTransGen (acceptedStep C) x (Repair C x) from
    H (mismatchCount x) x le_rfl
  intro n
  induction n with
  | zero =>
    intro x hx
    by_cases h : (firingSites x).Nonempty
    · have hlt := mismatchCount_localRepair_lt C
        ((localRepair_ne_iff C).mpr (leastFiringSite_shouldFire x h))
      omega
    · rw [Repair_of_no_fire C h]
  | succ n ih =>
    intro x hx
    by_cases h : (firingSites x).Nonempty
    · rw [Repair_of_fire C h]
      have hfire := (localRepair_ne_iff C).mpr (leastFiringSite_shouldFire x h)
      refine ReflTransGen.head ⟨leastFiringSite x h, rfl, hfire⟩ (ih _ ?_)
      have hlt := mismatchCount_localRepair_lt C hfire
      omega
    · rw [Repair_of_no_fire C h]

/-- `[formal-v4]` `Repair C x` is a normal form of the accepted-step
    relation. -/
theorem Repair_normalForm (x : Records C) : NormalForm C (Repair C x) := by
  rintro y ⟨i, _, hfire⟩
  exact hfire (localRepair_Repair C x i)

/-- `[formal-v4]` On an edge-repairable carrier `Repair` lands on the
    consensus manifold: its output is consistent. -/
theorem Repair_consistent (hER : EdgeRepairable C) (x : Records C) :
    Consistent C (Repair C x) :=
  (canonical_completeness C hER (Repair C x)).mp (Repair_normalForm C x)

/-! ## Non-vacuity witness

A concrete two-patch / one-edge carrier exhibiting that `obsMap` is genuinely
non-constant, so `gaugeEquiv` is strictly finer than the total relation and
`consistent_iff_edgeConsistent` is a statement about a model that actually
exists. This is the explicit anti-degeneracy witness (no `sorry`,
`weight_pos`/`dist_eq_zero` discharged for a real instance). -/

/-- A concrete carrier: two patches `Bool`, one edge `()`, interface `Bool`,
    identity projections, unit weight, and the discrete `{0,1}` distance. -/
def demoCarrier : OPHCarrier where
  Patch := Bool
  State := fun _ => Bool
  Edge := Unit
  src := fun _ => false
  tgt := fun _ => true
  Iface := fun _ => Bool
  projSrc := fun _ s => s
  projTgt := fun _ s => s
  weight := fun _ => 1
  dist := fun _ a b => if a = b then 0 else 1
  weight_pos := fun _ => one_pos
  dist_eq_zero := by
    intro _ a b
    by_cases h : a = b
    · rw [if_pos h]; exact ⟨fun _ => h, fun _ => rfl⟩
    · rw [if_neg h]; exact ⟨fun h1 => absurd h1 one_ne_zero, fun h2 => absurd h2 h⟩

/-- The observation map of `demoCarrier` is non-constant: the all-`false`
    record and the identity record expose different declared overlap data on
    the single edge (they disagree on the target projection). Hence
    `gaugeEquiv demoCarrier` is strictly finer than the total relation. -/
theorem obsMap_demoCarrier_nonconstant :
    obsMap demoCarrier (fun _ => false) ≠ obsMap demoCarrier (fun b => b) := by
  -- Reduce to the single edge `()` and read off the target component:
  -- it is `false` on the all-`false` record and `true` on the identity record.
  -- We extract a *concrete* `Bool` equality (`false = true`) before deciding,
  -- rather than asking for `Decidable` of the function-typed `obsMap` equality.
  intro h
  have hpt : ((false : Bool), (false : Bool)) = ((false : Bool), (true : Bool)) :=
    congrFun h ()
  exact absurd (congrArg Prod.snd hpt) (by decide)

end OPH

/-! ## Global termination & completeness from LOCAL repair laws

This section proves the mathematical content of two of OPH's open *dynamical*
obligations — **Termination** and **Completeness** (cf. the `Termination`/
`Completeness` `def`s above) — **conditionally, for any local repair move
satisfying the local laws `H1`/`H2`/`H3` below**, derived from those explicit,
faithful, single-site properties. (`[formal-v4]` note: the source file's
caveat "it does **not** close the file's own `Termination`/`Completeness`
`def`s, stated over the placeholder `sorry`-defined `localRepair`" is now
obsolete — those `def`s ARE discharged for the genuine canonical operator in
the `[formal-v4]` section above: `canonical_termination`,
`canonical_completeness`. This section keeps its original, strictly more
general shape: theorems for an *abstract* move `lr`.) The laws are
satisfiable by a genuine repair (e.g. a two-`Bool`-patch carrier with one
edge, each patch copying its neighbour to snap the edge consistent), so the
result is conditional, not vacuous — and that satisfiability is itself
machine-checked below as `demoCarrier_terminates` (a concrete `(carrier, repair)`
instance discharging `H1`/`H2`/`H3` with a real, non-empty repair step).

It is deliberately **self-contained and axiom-clean**: it does *not* reference
`localRepair`/`Repair`. The repair move and its laws enter as `section
variable`s (`lr`, `H1`, `H2`, `H3`), so each theorem here closes with
`#print axioms` reporting only `[propext, Classical.choice, Quot.sound]`
(no `sorryAx`, no new `axiom`). (`[formal-v4]`: in the source file this
phrasing was forced — the file's own `acceptedStep` was `sorry`-defined.
Here it is a feature, not a workaround: the statements over the
hypothesis-bearing move `lr` (`acceptedStepLR`, `NormalFormLR`) are the
*general* theorems, and the canonical operator instantiates them — `H1`/`H3`
unconditionally (`localRepair_apply_of_ne`, `localRepair_fixes_incident`),
`H2` on frustration-free carriers (`canonical_H2`).)

### Hypotheses are LOCAL; conclusions are GLOBAL (no assume-the-conclusion)

The hypotheses are genuine **single-site** statements:
* `H1` (`lr` changes only site `i`): firing at `i` touches patch `i` only.
* `H2` (`lr` fires iff a local edge is broken): the move at `i` changes `x`
  *iff* some edge incident to `i` is locally inconsistent — a purely local
  trigger.
* `H3` (local satisfiability / frustration-freeness): when the move at `i`
  fires it makes *all* of `i`'s own incident edges consistent. This explicitly
  restricts to carriers where a single patch *can* satisfy all its overlaps at
  once (frustration-free); it is a local property, **not** the global claim.

The conclusions are **global** dynamical facts about all of `Records C`:
* `termination`: the asynchronous accepted-step relation is `WellFounded`.
* `completeness`: a record is a global normal form *iff* it is globally
  `Consistent` (`Φ = 0`).

None of the forbidden shortcuts is assumed: we never assume `mismatchCount`
decreases, nor `WellFounded`, nor `Termination`, nor `NormalForm ↔ Consistent`.
Those are *proved* from the three local laws (plus the discharged
`consistent_iff_edgeConsistent`).

### The Lyapunov / Inter-Basin termination pattern

The proof is the well-founded-measure pattern: every accepted repair strictly
lowers a **structural `ℕ` surrogate** `mismatchCount` (the number of broken
edges), exactly as every SKI reduction strictly lowers `basin_size` in the
Inter-Basin termination theorem. A `ℕ` surrogate is *needed* because the
carrier potential `Φ : ℝ≥0` is **not** `<`-well-founded; `mismatchCount` is the
well-founded shadow of `Φ` that makes asynchronous descent terminate.

### What remains open (explicit scoping; no `sorry`)

`Confluence`/`LocallyConfluent` is **not** provided: asynchronous repairs at
different sites need not commute (`lr i (lr j x)` and `lr j (lr i x)` can
differ), so a frustration-free carrier may reach distinct normal forms
under distinct schedules — schedule independence / unique normal forms is out
of scope for these hypotheses. There is no `sorry`, `admit`, or new `axiom`
anywhere in this section. -/

namespace OPH

open Relation  -- `ReflTransGen` (used by the confluence theorems below)

section LocalRepairDynamics

variable {C : OPHCarrier}

-- `[formal-v4]` The definitions `edgeConsistentAt`, `edgeConsistentAt_iff_dist`,
-- `brokenSet`, `mismatchCount`, `mem_brokenSet`, and
-- `mem_brokenSet_iff_not_consistent` originally lived here; they were moved
-- verbatim to the canonical-repair block earlier in the file (the canonical
-- operator needs them). Everything below uses them unchanged.

-- The abstract local-repair move under study (a section variable):
-- `lr i x` applies the recovery move at site `i` to record `x`.
variable (lr : C.Patch → Records C → Records C)

/-- One accepted asynchronous repair step *for the abstract move `lr`*: some
    site's local move changes the record. Self-contained analogue of the file's
    `acceptedStep`, but over the hypothesis-bearing `lr`, so this section never
    touches the `sorry`-defined `localRepair`. -/
def acceptedStepLR (x y : Records C) : Prop :=
  ∃ i : C.Patch, y = lr i x ∧ lr i x ≠ x

/-- A normal form for `lr`: no accepted `lr`-step applies. -/
def NormalFormLR (x : Records C) : Prop :=
  ∀ y : Records C, ¬ acceptedStepLR lr x y

-- H1 (local: changes only site i): firing the move at site i alters the state
-- of patch i only; every other patch keeps its state.
-- H2 (local trigger: fires iff a local edge is broken): the move at i changes x
-- iff some edge incident to i is locally inconsistent.
-- H3 (local satisfiability / frustration-freeness): when the move at i fires it
-- makes all of i's incident edges consistent (restricts to carriers where a
-- single patch can satisfy all its overlaps at once).
variable
  (H1 : ∀ (i : C.Patch) (x : Records C) (j : C.Patch), j ≠ i → (lr i x) j = x j)
  (H2 : ∀ (i : C.Patch) (x : Records C),
      lr i x ≠ x ↔
        ∃ e : C.Edge, (C.src e = i ∨ C.tgt e = i) ∧ ¬ edgeConsistentAt e x)
  (H3 : ∀ (i : C.Patch) (x : Records C),
      lr i x ≠ x →
        ∀ e : C.Edge, (C.src e = i ∨ C.tgt e = i) → edgeConsistentAt e (lr i x))

-- Thread `lr`, `H1`, `H2`, `H3` uniformly through every theorem below, in this
-- fixed order, so cross-references are unambiguous. (Some lemmas don't use all
-- four; the extra hypotheses are harmless and keep call sites uniform.)
include lr H1 H2 H3

/-- A non-incident edge keeps both its endpoint states, hence its broken-ness,
    when site `i` fires (immediate from `H1`). -/
theorem brokenSet_eq_of_not_incident
    {i : C.Patch} {x : Records C} {e : C.Edge}
    (hs : C.src e ≠ i) (ht : C.tgt e ≠ i) :
    (e ∈ brokenSet (lr i x) ↔ e ∈ brokenSet x) := by
  have hsrc : (lr i x) (C.src e) = x (C.src e) := H1 i x (C.src e) hs
  have htgt : (lr i x) (C.tgt e) = x (C.tgt e) := H1 i x (C.tgt e) ht
  rw [mem_brokenSet, mem_brokenSet, hsrc, htgt]

/-- **Key lemma — Lyapunov descent on the `ℕ` surrogate.** Every accepted step
    strictly lowers `mismatchCount`: the broken-edge set strictly shrinks. This
    is the Inter-Basin `basin_size`-strictly-decreases analogue. -/
theorem mismatchCount_lt {x y : Records C}
    (h : acceptedStepLR lr x y) : mismatchCount y < mismatchCount x := by
  obtain ⟨i, rfl, hfire⟩ := h
  -- It suffices to show `brokenSet (lr i x) ⊂ brokenSet x`; then `card_lt_card`.
  -- (1) Subset: an edge broken in `lr i x` cannot be incident to `i` (those are
  -- made consistent by `H3`), and on non-incident edges broken-ness transfers
  -- back to `x` (`brokenSet_eq_of_not_incident`).
  have hsub : brokenSet (lr i x) ⊆ brokenSet x := by
    intro e he
    by_cases hinc : C.src e = i ∨ C.tgt e = i
    · have hcon : edgeConsistentAt e (lr i x) := H3 i x hfire e hinc
      exact absurd hcon (mem_brokenSet_iff_not_consistent.1 he)
    · have hs : C.src e ≠ i := fun h => hinc (Or.inl h)
      have ht : C.tgt e ≠ i := fun h => hinc (Or.inr h)
      exact (brokenSet_eq_of_not_incident lr H1 H2 H3 hs ht).1 he
  -- (2) Strictness: `H2` exhibits an incident broken edge of `x`; it lies in
  -- `brokenSet x` but not in `brokenSet (lr i x)` (incident → consistent there).
  obtain ⟨e₀, hinc₀, hbroken₀⟩ := (H2 i x).1 hfire
  have hmem_x : e₀ ∈ brokenSet x := mem_brokenSet_iff_not_consistent.2 hbroken₀
  have hcon₀ : edgeConsistentAt e₀ (lr i x) := H3 i x hfire e₀ hinc₀
  have hnot_mem : e₀ ∉ brokenSet (lr i x) :=
    fun hm => mem_brokenSet_iff_not_consistent.1 hm hcon₀
  have hssub : brokenSet (lr i x) ⊂ brokenSet x :=
    (Finset.ssubset_iff_of_subset hsub).2 ⟨e₀, hmem_x, hnot_mem⟩
  exact Finset.card_lt_card hssub

/-- **THEOREM — Termination (global).** The accepted asynchronous-repair
    relation is well-founded. Derived purely from the local laws via the `ℕ`
    measure `mismatchCount`, as the inverse image of `<` on `ℕ` and a
    sub-relation thereof. -/
theorem termination :
    WellFounded (fun y x : Records C => acceptedStepLR lr x y) :=
  -- Same idiom as `Finset.lt_wf`: the step relation is a sub-relation of the
  -- inverse image of `<` on `ℕ` under `mismatchCount`, which is well-founded.
  have H : Subrelation (fun y x : Records C => acceptedStepLR lr x y)
      (InvImage (· < ·) mismatchCount) :=
    fun {_ _} hxy => mismatchCount_lt lr H1 H2 H3 hxy
  Subrelation.wf H <| InvImage.wf _ wellFounded_lt

/-- Local characterisation behind completeness: site `i` is quiescent
    (`lr i x = x`) iff every edge incident to `i` is consistent
    (`H2`, contrapositive). -/
theorem lr_fixed_iff_incident_consistent (i : C.Patch) (x : Records C) :
    lr i x = x ↔ ∀ e : C.Edge, (C.src e = i ∨ C.tgt e = i) → edgeConsistentAt e x := by
  constructor
  · intro hfix e hinc
    by_contra hcon
    exact (H2 i x).mpr ⟨e, hinc, hcon⟩ hfix
  · intro hall
    by_contra hfire
    obtain ⟨e, hinc, hcon⟩ := (H2 i x).mp hfire
    exact hcon (hall e hinc)

/-- A record is a normal form iff *no* site fires (`lr i x = x` for all `i`).
    Unfolds `acceptedStepLR`/`NormalFormLR`. -/
theorem normalForm_iff_all_quiescent (x : Records C) :
    NormalFormLR lr x ↔ ∀ i : C.Patch, lr i x = x := by
  constructor
  · intro hnf i
    by_contra hfire
    exact hnf (lr i x) ⟨i, rfl, hfire⟩
  · intro hquiet y hstep
    obtain ⟨i, _, hfire⟩ := hstep
    exact hfire (hquiet i)

/-- **THEOREM — Completeness (global).** A record is a normal form of the
    accepted-step relation iff it is globally `Consistent` (`Φ = 0`). The
    bridge: no site fires ↔ every incident edge of every site is consistent ↔
    every edge is consistent (each edge is incident to its own `src`) ↔
    `EdgeConsistent` ↔ (`consistent_iff_edgeConsistent`) `Consistent`. -/
theorem completeness (x : Records C) :
    NormalFormLR lr x ↔ Consistent C x := by
  rw [normalForm_iff_all_quiescent lr H1 H2 H3 x, consistent_iff_edgeConsistent C x]
  constructor
  · intro hquiet e
    exact (lr_fixed_iff_incident_consistent lr H1 H2 H3 (C.src e) x).1
      (hquiet (C.src e)) e (Or.inl rfl)
  · intro hcons i
    exact (lr_fixed_iff_incident_consistent lr H1 H2 H3 i x).2 (fun e _ => hcons e)

-- ── Boundary-fiber observer-uniqueness (issue #304) ──────────────────────────
-- The boundary / sector map `B` (#304): a coarse invariant the repair PRESERVES.
-- `HB` = repair preserves `B`; `Hfib` = within a fixed boundary fiber, consistent
-- states are a gauge-singleton. These are #304's STATED hypotheses, not proven here.
variable {β : Type} (B : Records C → β)
  (HB : ∀ (i : C.Patch) (x : Records C), B (lr i x) = B x)
  (Hfib : ∀ x y : Records C, B x = B y → Consistent C x → Consistent C y → gaugeEquiv C x y)

include HB in
/-- The boundary map is invariant along an entire accepted-repair reduction. -/
theorem boundary_preserved_reduction {a b : Records C}
    (h : ReflTransGen (acceptedStepLR lr) a b) : B b = B a := by
  induction h with
  | refl => rfl
  | tail _ hstep ih =>
      obtain ⟨i, hc, _⟩ := hstep
      rw [hc, HB]; exact ih

include H1 H2 H3 HB Hfib in
/-- **THEOREM — Boundary-fiber observer-uniqueness (issue #304, observer-facing half).**
    Any two records with the SAME boundary value settle to the same observer-facing
    normal form (`gaugeEquiv`). It needs only `completeness` (normal form ⟹ consistent)
    + boundary preservation (`HB`) + the singleton-consistent-fiber hypothesis (`Hfib`)
    — confluence does NOT enter. Conditional on H1–H3 + HB + Hfib (exactly #304's stated
    hypotheses). A non-vacuous witness needs a boundary-PINNING (directional) repair:
    a single shared edge has two consistent states `(0,0)`/`(1,1)` and the symmetric
    copy-move reaches either, so the singleton fiber fails for it
    (cf. `demoCarrier_not_confluent`).
    SCOPE (explicit): `HB` and `Hfib` are jointly satisfiable in principle, but NO single carrier in this
    file instantiates BOTH — `demoBoundary` has `HB` (`demoBoundary_HB`) but fails `Hfib`
    (`demoCarrier_Hfib_fails`); `obsMap`/`demoSeedBoundary` give `Hfib` but are not `demoLR`-preserved.
    The two premises are exhibited on separate carriers; a joint witness on a richer multi-edge carrier
    is open modeling task. So this is an explicitly-scoped conditional, not vacuous. -/
theorem boundary_fiber_observer_unique {x y nfx nfy : Records C}
    (hB : B x = B y)
    (hx : ReflTransGen (acceptedStepLR lr) x nfx) (hxn : NormalFormLR lr nfx)
    (hy : ReflTransGen (acceptedStepLR lr) y nfy) (hyn : NormalFormLR lr nfy) :
    gaugeEquiv C nfx nfy := by
  have hBx : B nfx = B x := boundary_preserved_reduction lr H1 H2 H3 B HB hx
  have hBy : B nfy = B y := boundary_preserved_reduction lr H1 H2 H3 B HB hy
  have hCx : Consistent C nfx := (completeness lr H1 H2 H3 nfx).1 hxn
  have hCy : Consistent C nfy := (completeness lr H1 H2 H3 nfy).1 hyn
  have hBB : B nfx = B nfy := by rw [hBx, hB, ← hBy]
  exact Hfib nfx nfy hBB hCx hCy

-- H4 (GLOBAL commutation): EVERY ordered pair of sites `i, j` commutes on every
-- record (the classical *diamond* condition, stated globally). This is a STRONG
-- hypothesis: it demands even adjacent, edge-sharing sites commute, which the
-- natural copy-repair does NOT satisfy (`demoCarrier_repairs_dont_commute`). So
-- H4 is a SUFFICIENT extra law for global Confluence, not a necessary one, and it
-- has no non-trivial witness in this file — the only carrier, `demoCarrier`,
-- violates it (and is in fact non-confluent, `demoCarrier_not_confluent`). The
-- explicit weaker hypothesis would restrict commutation to NON-INCIDENT pairs
-- (sites sharing no edge, expressible via the incidence predicate used in
-- H2/H3), but that alone does not close the diamond when incident repairs
-- genuinely diverge. H4 is NOT implied by H1–H3.
variable
  (H4 : ∀ (i j : C.Patch) (x : Records C), lr i (lr j x) = lr j (lr i x))

-- H4 is used only inside the proofs below (the statements quantify over the
-- abstract relation `acceptedStepLR lr`), so force its inclusion explicitly.
include H4

-- H1/H2/H3 are unused by the diamond argument (it needs only `H4`); drop them
-- from THIS lemma so its type explicitly reads "commuting moves are locally
-- confluent". `confluence_of_commute` below carries them (for `termination`).
omit H1 H2 H3 in
/-- **Local confluence from single-step commutation** (the diamond condition).
    From two accepted steps at sites `i`, `j`, the common join is
    `lr j (lr i x) = lr i (lr j x)` (by `H4`); each side reaches it in ≤ 1 step
    (zero if that site is quiescent there). -/
theorem locallyConfluent_of_commute :
    AbstractRewriting.LocallyConfluent (acceptedStepLR lr) := by
  rintro x _ _ ⟨i, rfl, _⟩ ⟨j, rfl, _⟩
  refine ⟨lr j (lr i x), ?_, ?_⟩
  · rcases eq_or_ne (lr j (lr i x)) (lr i x) with h | h
    · rw [h]
    · exact ReflTransGen.single ⟨j, rfl, h⟩
  · rw [← H4 i j x]
    rcases eq_or_ne (lr i (lr j x)) (lr j x) with h | h
    · rw [h]
    · exact ReflTransGen.single ⟨i, rfl, h⟩

/-- **THEOREM — Confluence (Church–Rosser) under commutation.** Termination
    (H1–H3, via `termination`) together with local confluence (H4, via
    `locallyConfluent_of_commute`) yields global confluence, through Newman's
    lemma. With `termination` this further gives UNIQUE normal forms (the repo's
    `AbstractRewriting.newman_unique_nf`) — a schedule-independent "objective
    public reality" — but only the join property `Confluent` is concluded here.
    CAVEAT (read with `demoCarrier_not_confluent`): this is the SUFFICIENT
    direction, conditional on the strong, GLOBAL law `H4`, which has no
    non-trivial witness in this file — the only carrier, `demoCarrier`, provably
    violates `H4` and is in fact non-confluent. So this theorem says precisely
    "IF every pair of repairs commutes, schedules agree"; the witnessed,
    load-bearing fact is the negative one. -/
theorem confluence_of_commute :
    AbstractRewriting.Confluent (acceptedStepLR lr) :=
  AbstractRewriting.newman_lemma (acceptedStepLR lr)
    (termination lr H1 H2 H3) (locallyConfluent_of_commute lr H4)

end LocalRepairDynamics

/-! ## Non-vacuity witness: the local laws are satisfiable by a real repair

`demoCarrier` (two `Bool` patches, one edge) with the neighbour-copy repair
`demoLR` satisfies `H1`/`H2`/`H3` and has a non-empty accepted-step relation, so
`demoCarrier_terminates` is a genuine, non-vacuous instance of `termination` —
not a claim about an unsatisfiable hypothesis set. -/

/-- A genuine local repair on `demoCarrier`: patch `i` copies its neighbour `!i`,
    snapping the single edge consistent. Changes only patch `i`. -/
def demoLR : demoCarrier.Patch → Records demoCarrier → Records demoCarrier :=
  fun i x => Function.update x i (x (!i))

/-- `demoLR` fires (changes the record) exactly when patch `i` disagrees with its
    neighbour. -/
theorem demoLR_eq_self_iff (i : demoCarrier.Patch) (x : Records demoCarrier) :
    demoLR i x = x ↔ x (!i) = x i := by
  constructor
  · intro h
    have hi := congrFun h i
    simp only [demoLR, Function.update_self] at hi
    exact hi
  · intro h
    funext k
    rcases eq_or_ne k i with hk | hk
    · subst hk; simpa only [demoLR, Function.update_self] using h
    · simp only [demoLR, Function.update_of_ne hk]

theorem demoLR_H1 :
    ∀ (i : demoCarrier.Patch) (x : Records demoCarrier) (j : demoCarrier.Patch),
      j ≠ i → (demoLR i x) j = x j := by
  intro i x j hj
  simp only [demoLR, Function.update_of_ne hj]

theorem demoLR_H3 :
    ∀ (i : demoCarrier.Patch) (x : Records demoCarrier),
      demoLR i x ≠ x →
        ∀ e : demoCarrier.Edge,
          (demoCarrier.src e = i ∨ demoCarrier.tgt e = i) →
            edgeConsistentAt e (demoLR i x) := by
  intro i x _ e _
  show (demoLR i x) false = (demoLR i x) true
  cases i <;> rfl

theorem demoLR_H2 :
    ∀ (i : demoCarrier.Patch) (x : Records demoCarrier),
      demoLR i x ≠ x ↔
        ∃ e : demoCarrier.Edge,
          (demoCarrier.src e = i ∨ demoCarrier.tgt e = i) ∧ ¬ edgeConsistentAt e x := by
  intro i x
  rw [ne_eq, demoLR_eq_self_iff]
  have hiff : (x (!i) ≠ x i) ↔ (x false ≠ x true) := by
    cases i
    · exact ne_comm
    · exact Iff.rfl
  constructor
  · intro h
    refine ⟨(), ?_, hiff.mp h⟩
    cases i
    · exact Or.inl rfl
    · exact Or.inr rfl
  · rintro ⟨_, _, hnc⟩
    exact hiff.mpr hnc

/-- The accepted-step relation for `demoLR` is non-empty: the identity record has
    a broken edge (`false ≠ true`), so `demoLR false` fires. -/
theorem demoLR_has_step :
    ∃ x y : Records demoCarrier, acceptedStepLR demoLR x y := by
  refine ⟨(fun b => b), demoLR false (fun b => b), false, rfl, ?_⟩
  rw [ne_eq, demoLR_eq_self_iff]
  show (!false : Bool) ≠ false
  decide

/-- **Non-vacuity payoff.** `termination` instantiated on the real, non-trivial
    witness `(demoCarrier, demoLR)`. -/
theorem demoCarrier_terminates :
    WellFounded (fun y x : Records demoCarrier => acceptedStepLR demoLR x y) :=
  termination demoLR demoLR_H1 demoLR_H2 demoLR_H3

/-- **H4 fails for the natural repair.** On `demoCarrier` the two patches share
    one edge, so their copy-moves can fail to commute. Concretely, from the
    identity record `id = (fun b => b)`, repairing `false` then `true` gives the
    constant `true`, whereas `true` then `false` gives the constant `false` — a
    single record witnessing `lr i (lr j ·) ≠ lr j (lr i ·)`. Hence `demoLR`
    violates `H4`, so `confluence_of_commute` does not apply to it. This is not
    merely a failed sufficient condition — `demoLR` is in fact NON-CONFLUENT
    (`demoCarrier_not_confluent` below): the two firing orders reach two distinct
    normal forms, so on this carrier there is genuinely no unique objective public
    reality. -/
theorem demoCarrier_repairs_dont_commute :
    ∃ x : Records demoCarrier,
      demoLR true (demoLR false x) ≠ demoLR false (demoLR true x) := by
  refine ⟨(fun b => b), fun h => ?_⟩
  have h2 : (true : Bool) = false := congrFun h false
  exact absurd h2 (by decide)

/-- **THE WITNESSED PAYOFF — `demoLR` is genuinely NON-CONFLUENT.** From the
    identity record `id = (fun b => b)`, firing patch `false` reaches the constant
    `true` and firing patch `true` reaches the constant `false`; both are normal
    forms (no patch fires on a constant record) and they differ. So a single
    record has two distinct normal forms — `¬ Confluent (acceptedStepLR demoLR)` —
    the concrete failure of a unique "objective public reality" that `H4` (and
    hence `confluence_of_commute`) rules out by hypothesis. Unlike
    `confluence_of_commute` (conditional on the witness-less global `H4`), THIS
    result holds outright on the concrete `demoCarrier`. Together the three
    theorems give a self-contained picture *on this carrier*: the async copy-repair
    `demoLR` is non-confluent (here); commutation `H4` is a SUFFICIENT condition for
    confluence (`confluence_of_commute`, abstract); and `demoLR` fails it
    (`demoCarrier_repairs_dont_commute`). No claim is made that *every* async repair
    is non-confluent — only this one is exhibited.
    Proof: `AbstractRewriting.unique_normal_form` forces any two normal forms
    reached from one record to coincide; the two we exhibit do not. -/
theorem demoCarrier_not_confluent :
    ¬ AbstractRewriting.Confluent (acceptedStepLR demoLR) := by
  intro hc
  have hfire_f : demoLR false (fun b => b) ≠ (fun b => b) := by
    rw [ne_eq, demoLR_eq_self_iff]; show (!false : Bool) ≠ false; decide
  have hfire_t : demoLR true (fun b => b) ≠ (fun b => b) := by
    rw [ne_eq, demoLR_eq_self_iff]; show (!true : Bool) ≠ true; decide
  -- both single-step results are normal forms: no patch fires on a constant record
  have hnf_y : AbstractRewriting.IsNormalForm (acceptedStepLR demoLR)
      (demoLR false (fun b => b)) := by
    rintro w ⟨i, _, hne⟩; apply hne; rw [demoLR_eq_self_iff]; cases i <;> rfl
  have hnf_z : AbstractRewriting.IsNormalForm (acceptedStepLR demoLR)
      (demoLR true (fun b => b)) := by
    rintro w ⟨i, _, hne⟩; apply hne; rw [demoLR_eq_self_iff]; cases i <;> rfl
  have hy : AbstractRewriting.ReducesToNF (acceptedStepLR demoLR)
      (fun b => b) (demoLR false (fun b => b)) :=
    ⟨ReflTransGen.single ⟨false, rfl, hfire_f⟩, hnf_y⟩
  have hz : AbstractRewriting.ReducesToNF (acceptedStepLR demoLR)
      (fun b => b) (demoLR true (fun b => b)) :=
    ⟨ReflTransGen.single ⟨true, rfl, hfire_t⟩, hnf_z⟩
  -- if confluent, the two normal forms would be equal — but const true ≠ const false
  have heq := AbstractRewriting.unique_normal_form (acceptedStepLR demoLR) hc hy hz
  have h2 : (true : Bool) = false := congrFun heq false
  exact absurd h2 (by decide)

/-! ### The SYMMETRIC half of the #304 dichotomy — `demoCarrier` witnesses `Hfib` failing

`boundary_fiber_observer_unique` shows: IF the repair pins each boundary-fiber to a
single gauge class (`Hfib`), the observer reconstructs a unique public branch — and it
does so WITHOUT confluence. The theorems below exhibit the complementary countermodel:
the symmetric copy-repair `demoLR` makes `Hfib` FALSE, so the same inputs that
`boundary_fiber_observer_unique` consumes hold while its conclusion fails. The witness is
the SAME two normal forms `demoCarrier_not_confluent` exhibits: `(1,1)` and `(0,0)`.

EXPLICIT SCOPE: this is the FORWARD direction (`Hfib` ⟹ unique; symmetric ⟹ countermodel),
NOT a biconditional — observer-uniqueness is keyed to `Hfib` (a static fiber hypothesis),
which is logically independent of confluence. And `demoBoundary` is the trivial boundary,
legitimate as the COARSEST `B` (the fairest test of whether symmetric repair can pin its
fiber) but carrying no interior/boundary split. -/

/-- The trivial (constant) boundary on `demoCarrier` records — the concrete instance of the
    abstract `B : Records C → β` from `boundary_fiber_observer_unique`. On a single-edge
    carrier the only repair-invariant boundary is the trivial one (the coarsest `B`). -/
def demoBoundary : Records demoCarrier → Unit := fun _ => ()

/-- `demoLR` preserves `demoBoundary` (the `HB` premise of #304), trivially. -/
theorem demoBoundary_HB (i : demoCarrier.Patch) (x : Records demoCarrier) :
    demoBoundary (demoLR i x) = demoBoundary x := rfl

/-- Every constant record is `Consistent` (`Φ = 0`): the single edge's two identity
    projections agree on a constant record. -/
theorem demoCarrier_const_consistent (v : Bool) :
    Consistent demoCarrier (fun _ => v) := by
  rw [consistent_iff_edgeConsistent]; intro e; rfl

/-- The two constant normal forms are NOT gauge-equivalent: their `obsMap`s differ on the
    single edge's source projection. Mirrors `obsMap_demoCarrier_nonconstant`, read on
    `Prod.fst`. (`h` is `gaugeEquiv` = `obsMap _ = obsMap _` definitionally.) -/
theorem demoCarrier_consts_not_gaugeEquiv :
    ¬ gaugeEquiv demoCarrier (fun _ => true) (fun _ => false) := by
  intro h
  have h' : obsMap demoCarrier (fun _ => true) = obsMap demoCarrier (fun _ => false) := h
  have hpt : ((true : Bool), (true : Bool)) = ((false : Bool), (false : Bool)) :=
    congrFun h' ()
  exact absurd (congrArg Prod.fst hpt) (by decide)

/-- **COMPLEMENT THEOREM — `demoCarrier` WITNESSES `Hfib` FAILING (static form).**
    The literal negation, in #304's own vocabulary, of the singleton-consistent-fiber
    hypothesis `Hfib` of `boundary_fiber_observer_unique`, at `B := demoBoundary`:
    two `Consistent` records with equal boundary that are NOT `gaugeEquiv`. -/
theorem demoCarrier_Hfib_fails :
    ¬ (∀ x y : Records demoCarrier,
          demoBoundary x = demoBoundary y →
          Consistent demoCarrier x → Consistent demoCarrier y →
          gaugeEquiv demoCarrier x y) := by
  intro Hfib
  exact demoCarrier_consts_not_gaugeEquiv
    (Hfib (fun _ => true) (fun _ => false) rfl
      (demoCarrier_const_consistent true) (demoCarrier_const_consistent false))

/-- **COMPLEMENT THEOREM (reachability-explicit) — the SYMMETRIC half of the dichotomy.**
    From ONE start (`id`), `demoLR` reaches two normal forms with the SAME boundary that are
    NOT `gaugeEquiv`. The inputs match exactly what `boundary_fiber_observer_unique` consumes
    (reductions + `NormalFormLR` + equal boundary), yet the conclusion `gaugeEquiv` is FALSE —
    because the symmetric repair makes the one premise it does not supply, `Hfib`, fail. -/
theorem demoCarrier_boundary_fiber_not_unique :
    ∃ start nf₁ nf₂ : Records demoCarrier,
      Relation.ReflTransGen (acceptedStepLR demoLR) start nf₁ ∧ NormalFormLR demoLR nf₁ ∧
      Relation.ReflTransGen (acceptedStepLR demoLR) start nf₂ ∧ NormalFormLR demoLR nf₂ ∧
      demoBoundary nf₁ = demoBoundary nf₂ ∧
      Consistent demoCarrier nf₁ ∧ Consistent demoCarrier nf₂ ∧
      ¬ gaugeEquiv demoCarrier nf₁ nf₂ := by
  have hfire_f : demoLR false (fun b => b) ≠ (fun b => b) := by
    rw [ne_eq, demoLR_eq_self_iff]; show (!false : Bool) ≠ false; decide
  have hfire_t : demoLR true (fun b => b) ≠ (fun b => b) := by
    rw [ne_eq, demoLR_eq_self_iff]; show (!true : Bool) ≠ true; decide
  have hnf₁ : NormalFormLR demoLR (demoLR false (fun b => b)) := by
    rw [normalForm_iff_all_quiescent demoLR demoLR_H1 demoLR_H2 demoLR_H3]
    intro i; rw [demoLR_eq_self_iff]; cases i <;> rfl
  have hnf₂ : NormalFormLR demoLR (demoLR true (fun b => b)) := by
    rw [normalForm_iff_all_quiescent demoLR demoLR_H1 demoLR_H2 demoLR_H3]
    intro i; rw [demoLR_eq_self_iff]; cases i <;> rfl
  have heq₁ : demoLR false (fun b => b) = (fun _ => true) := by funext k; cases k <;> rfl
  have heq₂ : demoLR true (fun b => b) = (fun _ => false) := by funext k; cases k <;> rfl
  refine ⟨(fun b => b), demoLR false (fun b => b), demoLR true (fun b => b),
    Relation.ReflTransGen.single ⟨false, rfl, hfire_f⟩, hnf₁,
    Relation.ReflTransGen.single ⟨true, rfl, hfire_t⟩, hnf₂, rfl, ?_, ?_, ?_⟩
  · rw [heq₁]; exact demoCarrier_const_consistent true
  · rw [heq₂]; exact demoCarrier_const_consistent false
  · rw [heq₁, heq₂]; exact demoCarrier_consts_not_gaugeEquiv

/-! ### Two DIFFERENT uniqueness notions, two DIFFERENT levers (the corrected #304 cut)

`demoCarrier_Hfib_fails` shows the symmetric repair + trivial boundary breaks OBSERVER-uniqueness
("same boundary → same normal form"). Two levers act, on two DIFFERENT notions — do not conflate them:
  ROUTE A — refine the BOUNDARY so the consistent fiber is a gauge-singleton (`Hfib` holds). This buys
            OBSERVER-uniqueness directly; a property of B, repair-free (`demoCarrier_Hfib_holds_seed`).
  ROUTE B — use a SELECTING (deterministic) repair: it is CONFLUENT — a unique normal form per INPUT,
            schedule-independent (Church-Rosser; last-writer-wins / strong-eventual-consistency). This
            is per-INPUT uniqueness, a property of the repair dynamics — and it is NOT observer-
            uniqueness: under a coarse boundary the SAME confluent repair fails it
            (`demoCarrier_dir_not_observer_unique`). Observer-uniqueness returns only once the boundary
            is also refined (`demoCarrier_dir_observer_unique_under_seed`) — i.e. via Route A. -/

/-- **ROUTE A (DEFINITIONAL endpoint) — at the finest boundary `Hfib` holds verbatim.** With
    `B := obsMap`, `Hfib`'s conclusion `gaugeEquiv x y` IS its hypothesis `obsMap x = obsMap y`
    (`gaugeEquiv` unfolds definitionally to `obsMap`-equality), so the proof is `fun _ _ h _ _ => h`
    and discards BOTH `Consistent` premises. This endpoint therefore CANNOT fail and is NOT independent
    evidence — it is the trivial top of the boundary lattice, recorded only for completeness. The
    load-bearing positive result is `demoCarrier_Hfib_holds_seed` (a strictly coarser boundary that
    genuinely uses consistency). `Hfib` is a property of B, not of the repair (which is why "selecting
    repair proves Hfib" was a category error). -/
theorem demoCarrier_Hfib_holds_finerB :
    ∀ x y : Records demoCarrier, obsMap demoCarrier x = obsMap demoCarrier y →
      Consistent demoCarrier x → Consistent demoCarrier y → gaugeEquiv demoCarrier x y :=
  fun _ _ h _ _ => h

/-- The SEED boundary: read a SINGLE cell (patch `false`). A coarse boundary — strictly between
    the trivial `demoBoundary` (reads nothing) and the full `obsMap` (reads the whole overlap). -/
def demoSeedBoundary : Records demoCarrier → Bool := fun x => x false

/-- **SEED base case (issue #304, Boundary-Fiber Confluence).** `Hfib` holds for the one-cell seed
    boundary: reading patch `false` PLUS the consistency premise pins the whole record, because
    edge-agreement (`consistent_iff_edgeConsistent`) forces the unread cell to follow the read one. So
    `Hfib` does NOT require the full observable — a single seed cell suffices. The proof genuinely
    consumes both `Consistent` hypotheses (unlike `demoCarrier_Hfib_holds_finerB`, which is
    definitional), so this is real singleton-consistent-fiber content. SCOPE (explicit): on this 1-edge
    carrier every `Consistent` record is constant, so the "bulk" is just the one other cell, and on the
    consistent fiber `demoSeedBoundary` has the SAME separating power as the full `obsMap` — genuine
    seed-determines-record, but the multi-edge *propagation* the name evokes is open modeling task, not
    exhibited here. (`demoSeedBoundary` is the boundary-fineness criterion only; it is NOT preserved by
    the symmetric `demoLR` — pairing it with a boundary-preserving repair, the `HB` premise, is a
    separate modeling step. It IS preserved by the selecting `demoDirT`, which is how
    `demoCarrier_dir_observer_unique_under_seed` uses it.) -/
theorem demoCarrier_Hfib_holds_seed :
    ∀ x y : Records demoCarrier, demoSeedBoundary x = demoSeedBoundary y →
      Consistent demoCarrier x → Consistent demoCarrier y → gaugeEquiv demoCarrier x y := by
  intro x y hseed hcx hcy
  simp only [demoSeedBoundary] at hseed
  rw [consistent_iff_edgeConsistent] at hcx hcy
  have hx : x false = x true := hcx ()
  have hy : y false = y true := hcy ()
  have hxy : x = y := by
    funext k
    cases k
    · exact hseed
    · rw [← hx, hseed, hy]
  subst hxy
  rfl

/-- A SELECTING (directional) repair on `demoCarrier`: deterministically snap the edge to
    patch-`false`'s value. Unlike the symmetric `demoLR`, this is a single-valued operator (a
    last-writer-wins style resolver), so its induced rewriting is deterministic. -/
def demoDirT : Records demoCarrier → Records demoCarrier := fun x => fun _ => x false

/-- Descent potential for `demoDirT`: 1 if the edge is broken (the two patches differ),
    else 0. Phrased with `Bool.xor`/`toNat` to stay first-order — no `Decidable` synthesis
    through the dependent (semireducible) `Records demoCarrier` type. -/
def demoDirΦ : Records demoCarrier → ℕ := fun x => (Bool.xor (x true) (x false)).toNat

theorem demoDirΦ_desc (x : Records demoCarrier) :
    demoDirT x ≠ x → demoDirΦ (demoDirT x) < demoDirΦ x := by
  intro hne
  have hb : x true ≠ x false := fun h => hne (by funext k; cases k <;> simp [demoDirT, h])
  have key : Bool.xor (x true) (x false) = true := by
    cases hxt : x true <;> cases hxf : x false <;> simp_all
  simp only [demoDirΦ, demoDirT]
  rw [key]
  cases hxf : x false <;> decide

/-- **ROUTE B — the SELECTING repair is CONFLUENT (positive twin of `demoCarrier_not_confluent`).**
    `demoDirT` is deterministic, so its induced rewriting reaches a UNIQUE normal form per input,
    schedule-independent (Newman's lemma via the `DeterministicRepair` route). This is CONFLUENCE —
    the lever a directional/selecting repair actually buys — and a DIFFERENT theorem from the `Hfib`
    boundary route above. The symmetric `demoLR` provably fails it (`demoCarrier_not_confluent`). -/
theorem demoCarrier_dir_confluent :
    AbstractRewriting.Confluent (AbstractRewriting.stepRel demoDirT) :=
  AbstractRewriting.newman_lemma (AbstractRewriting.stepRel demoDirT)
    (AbstractRewriting.descent_terminating demoDirT demoDirΦ demoDirΦ_desc)
    (AbstractRewriting.deterministic_locally_confluent demoDirT)

/-- **THE CRUX — confluence ALONE is not observer-uniqueness.** `demoDirT` is confluent
    (`demoCarrier_dir_confluent`: same input → one normal form). But that is a property of the REPAIR,
    not of the boundary. Here are TWO inputs with the SAME *trivial* boundary (`demoBoundary : … → Unit`,
    which reads nothing, so equality holds for ALL inputs by `rfl`) that reach DIFFERENT normal forms
    `(1,1)` and `(0,0)` under that very confluent repair — so confluence ("same input → same NF") does
    NOT by itself give observer-facing uniqueness ("same boundary → same NF"). This is a separation,
    exhibited against the COARSEST boundary; it does NOT claim the repair's directionality is irrelevant
    in general. The controlled converse is machine-checked next: hold THIS SAME confluent repair fixed
    and REFINE the boundary to the one-cell `demoSeedBoundary`, and observer-uniqueness is RESTORED
    (`demoCarrier_dir_observer_unique_under_seed`). So the lever that flips reconstructability — with the
    repair held constant — is the boundary's fineness. -/
theorem demoCarrier_dir_not_observer_unique :
    ∃ x y nfx nfy : Records demoCarrier,
      Relation.ReflTransGen (AbstractRewriting.stepRel demoDirT) x nfx ∧
      AbstractRewriting.IsNormalForm (AbstractRewriting.stepRel demoDirT) nfx ∧
      Relation.ReflTransGen (AbstractRewriting.stepRel demoDirT) y nfy ∧
      AbstractRewriting.IsNormalForm (AbstractRewriting.stepRel demoDirT) nfy ∧
      demoBoundary x = demoBoundary y ∧
      ¬ gaugeEquiv demoCarrier nfx nfy := by
  have hx : demoDirT (fun b => !b) = (fun _ => true) := by funext k; rfl
  have hy : demoDirT (fun b => b) = (fun _ => false) := by funext k; rfl
  have hfpT : demoDirT (fun _ => true) = (fun _ => true) := by funext k; rfl
  have hfpF : demoDirT (fun _ => false) = (fun _ => false) := by funext k; rfl
  have hstepx : AbstractRewriting.stepRel demoDirT (fun b => !b) (fun _ => true) := by
    refine ⟨hx.symm, ?_⟩
    rw [hx]; intro h; simpa using congrFun h true
  have hstepy : AbstractRewriting.stepRel demoDirT (fun b => b) (fun _ => false) := by
    refine ⟨hy.symm, ?_⟩
    rw [hy]; intro h; simpa using congrFun h true
  have hnfT : AbstractRewriting.IsNormalForm (AbstractRewriting.stepRel demoDirT) (fun _ => true) := by
    rintro z ⟨_, hne⟩; exact hne hfpT
  have hnfF : AbstractRewriting.IsNormalForm (AbstractRewriting.stepRel demoDirT) (fun _ => false) := by
    rintro z ⟨_, hne⟩; exact hne hfpF
  exact ⟨fun b => !b, fun b => b, fun _ => true, fun _ => false,
    Relation.ReflTransGen.single hstepx, hnfT,
    Relation.ReflTransGen.single hstepy, hnfF,
    rfl, demoCarrier_consts_not_gaugeEquiv⟩

/-- **POSITIVE COMPANION TO THE CRUX — the boundary is the controlling lever, machine-checked.**
    Hold the SAME confluent repair `demoDirT` fixed and REFINE the boundary from the trivial
    `demoBoundary` (under which `demoCarrier_dir_not_observer_unique` shows observer-uniqueness FAILS)
    to the one-cell `demoSeedBoundary`: observer-uniqueness is RESTORED — any two inputs with equal
    seed-boundary reach `gaugeEquiv` normal forms under that very confluent repair. So with the repair
    held constant, varying ONLY the boundary flips reconstructability; the lever is the boundary's
    fineness, not the repair's directionality. Proof: `demoDirT` snaps every record to `(x false, x false)`,
    so it (i) preserves `demoSeedBoundary` along every reduction and (ii) has only `Consistent`
    (edge-constant) normal forms; then equal-seed-boundary consistent records are `gaugeEquiv` by
    `demoCarrier_Hfib_holds_seed`. -/
theorem demoCarrier_dir_observer_unique_under_seed :
    ∀ x y nfx nfy : Records demoCarrier,
      Relation.ReflTransGen (AbstractRewriting.stepRel demoDirT) x nfx →
      AbstractRewriting.IsNormalForm (AbstractRewriting.stepRel demoDirT) nfx →
      Relation.ReflTransGen (AbstractRewriting.stepRel demoDirT) y nfy →
      AbstractRewriting.IsNormalForm (AbstractRewriting.stepRel demoDirT) nfy →
      demoSeedBoundary x = demoSeedBoundary y →
      gaugeEquiv demoCarrier nfx nfy := by
  -- `demoSeedBoundary` is invariant along every `demoDirT` reduction.
  have seed_inv : ∀ z w : Records demoCarrier,
      Relation.ReflTransGen (AbstractRewriting.stepRel demoDirT) z w →
      demoSeedBoundary w = demoSeedBoundary z := by
    intro z w h
    induction h with
    | refl => rfl
    | tail _ hstep ih =>
        obtain ⟨hw, _⟩ := hstep
        rw [hw]
        simpa only [demoSeedBoundary, demoDirT] using ih
  -- A `demoDirT` normal form is a fixed point, hence edge-constant, hence `Consistent`.
  have nf_consistent : ∀ nf : Records demoCarrier,
      AbstractRewriting.IsNormalForm (AbstractRewriting.stepRel demoDirT) nf →
      Consistent demoCarrier nf := by
    intro nf hnf
    have hfix : demoDirT nf = nf := by
      by_contra hne
      exact hnf (demoDirT nf) ⟨rfl, hne⟩
    have hcell : nf false = nf true := by
      have h2 := congrFun hfix true
      simpa only [demoDirT] using h2
    rw [consistent_iff_edgeConsistent]
    intro _; exact hcell
  intro x y nfx nfy hx hxn hy hyn hseed
  have hcx : Consistent demoCarrier nfx := nf_consistent nfx hxn
  have hcy : Consistent demoCarrier nfy := nf_consistent nfy hyn
  have hbb : demoSeedBoundary nfx = demoSeedBoundary nfy := by
    rw [seed_inv x nfx hx, hseed, ← seed_inv y nfy hy]
  exact demoCarrier_Hfib_holds_seed nfx nfy hbb hcx hcy

/-! ### `[formal-v4]` The canonical operator on the demo carrier

Non-degeneracy of the discharge, machine-checked: on `demoCarrier` the
canonical `localRepair` **is** the source file's neighbour-copy repair
`demoLR`; hence the canonical accepted-step relation is `acceptedStepLR
demoLR`, the file's own `Confluence demoCarrier` is **refuted** (the
source file's T3, now about the real operator), and the composite `Repair`
genuinely moves broken records. -/

/-- `[formal-v4]` The demo carrier is frustration-free: each patch can
    always copy its neighbour. -/
theorem demoCarrier_frustrationFree : FrustrationFree demoCarrier := by
  intro i x
  cases i
  -- Everything reduces definitionally on the concrete carrier: updating patch
  -- `i` to its neighbour's value makes both endpoint reads equal.
  · exact ⟨x true, fun e _ => rfl⟩
  · exact ⟨x false, fun e _ => rfl⟩

/-- `[formal-v4]` On the demo carrier the local fix at a broken edge is
    unique: it must copy the neighbour. -/
theorem demoCarrier_isLocalFix_unique {i : demoCarrier.Patch}
    {x : Records demoCarrier} {s : Bool}
    (hs : IsLocalFix (C := demoCarrier) i x s) : s = x (!i) := by
  have h := hs () (by
    cases i
    · exact Or.inl rfl
    · exact Or.inr rfl)
  have h' : (Function.update x i s) false = (Function.update x i s) true := h
  cases i
  -- Definitional reduction of `Function.update` on the concrete carrier:
  -- for `i = false`, `h'` reads `s = x true`; for `i = true`, `x false = s`.
  · exact h'
  · exact h'.symm

/-- `[formal-v4]` **The canonical operator is not degenerate: on the demo
    carrier it IS the source file's neighbour-copy repair `demoLR`.** (This
    is the anti-degeneracy witness the source file's `sorry` documentation
    demanded — the discharge did not sneak in `Repair := id`.) -/
theorem localRepair_demoCarrier (i : demoCarrier.Patch) (x : Records demoCarrier) :
    localRepair demoCarrier i x = demoLR i x := by
  by_cases hb : x false = x true
  · have hnot : ¬ ShouldFire (C := demoCarrier) i x := by
      rintro ⟨⟨⟨⟩, -, hbrk⟩, -⟩
      exact hbrk hb
    rw [localRepair_of_not_shouldFire demoCarrier hnot]
    refine ((demoLR_eq_self_iff i x).mpr ?_).symm
    cases i
    · exact hb.symm
    · exact hb
  · have hsf : ShouldFire (C := demoCarrier) i x := by
      refine ⟨⟨(), ?_, hb⟩, demoCarrier_frustrationFree i x⟩
      cases i
      · exact Or.inl rfl
      · exact Or.inr rfl
    rw [localRepair_of_shouldFire demoCarrier hsf,
      demoCarrier_isLocalFix_unique (localRepair_choose_isLocalFix demoCarrier hsf)]
    rfl

/-- `[formal-v4]` The canonical accepted-step relation on the demo carrier
    is the source file's `acceptedStepLR demoLR`. -/
theorem acceptedStep_demoCarrier :
    acceptedStep demoCarrier = acceptedStepLR demoLR := by
  funext x y
  refine propext ⟨?_, ?_⟩
  · rintro ⟨i, hy, hne⟩
    rw [localRepair_demoCarrier i x] at hy hne
    exact ⟨i, hy, hne⟩
  · rintro ⟨i, hy, hne⟩
    rw [← localRepair_demoCarrier i x] at hy hne
    exact ⟨i, hy, hne⟩

/-- `[formal-v4]` **The file's own `Confluence`, REFUTED on the demo
    carrier** — the source file's non-confluence lesson (T3), restated for
    the genuine canonical operator: asynchronous schedules of the real
    `localRepair` reach two different worlds from one start. This is why
    `Repair` must (and does) buy schedule independence by declared order. -/
theorem canonical_not_confluent : ¬ Confluence demoCarrier := by
  intro hc
  apply demoCarrier_not_confluent
  intro x y z hxy hxz
  rw [← acceptedStep_demoCarrier] at hxy hxz
  obtain ⟨w, hw1, hw2⟩ := hc x y z hxy hxz
  rw [acceptedStep_demoCarrier] at hw1 hw2
  exact ⟨w, hw1, hw2⟩

/-- `[formal-v4]` The composite `Repair` genuinely acts: the broken identity
    record is not a fixed point. -/
theorem Repair_demoCarrier_ne :
    Repair demoCarrier (fun b => b) ≠ (fun b => b) := by
  intro h
  have hnf : NormalForm demoCarrier (fun b => b) := by
    rw [← h]
    exact Repair_normalForm demoCarrier (fun b => b)
  have hcons : Consistent demoCarrier (fun b => b) :=
    (canonical_completeness demoCarrier
      (edgeRepairable_of_frustrationFree demoCarrier demoCarrier_frustrationFree)
      (fun b => b)).mp hnf
  rw [consistent_iff_edgeConsistent] at hcons
  exact Bool.noConfusion (hcons ())

/-! ### Axiom audit — the reconstruction layer depends only on standard axioms.
The `#print axioms` outputs below confirm that the boundary-fiber reconstruction theorem
and all its concrete witnesses depend ONLY on the standard Lean/Mathlib axioms
(`propext`, `Classical.choice`, `Quot.sound`). `[formal-v4]`: the source file's
clause "and NOT on any of the file's three explicit `sorry`s" is upgraded — there
are **no** `sorry`s left anywhere in this file; the discharged operator layer
(`repair_respects_gauge`, `canonical_termination`, `canonical_completeness`,
`canonical_lyapunov`, `canonical_not_confluent`, and the demo identifications)
is audited below alongside the original list. -/
#print axioms boundary_fiber_observer_unique
#print axioms boundary_preserved_reduction
#print axioms demoCarrier_Hfib_fails
#print axioms demoCarrier_Hfib_holds_finerB
#print axioms demoCarrier_Hfib_holds_seed
#print axioms demoCarrier_dir_confluent
#print axioms demoCarrier_dir_not_observer_unique
#print axioms demoCarrier_dir_observer_unique_under_seed
#print axioms termination
#print axioms completeness
-- `[formal-v4]` the discharged layer:
#print axioms repair_respects_gauge
#print axioms obsMap_Repair_congr
#print axioms canonical_lyapunov
#print axioms canonical_termination
#print axioms canonical_completeness
#print axioms canonical_H2
#print axioms Repair_reduction
#print axioms Repair_normalForm
#print axioms Repair_consistent
#print axioms Repair_idem
#print axioms localRepair_demoCarrier
#print axioms canonical_not_confluent
#print axioms Repair_demoCarrier_ne

end OPH
