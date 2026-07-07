import Mathlib
import OPHProofChain.Rule90Cylinder

/-!
# Carrier bridge: the n×t Rule-90 cylinder as an OPH carrier, `H_fib` discharged

This module packages `Rule90Cylinder.lean`'s information-set theorems in the
**exact vocabulary of the OPH Lean core**
(`observer-patch-holography/LEAN/ObserverPatchHolography/Primitives.lean`):
the `OPHCarrier` structure, `Records`, `obsMap`, `gaugeEquiv`, `Φ`,
`Consistent`, and the `H_fib` binder of `boundary_fiber_observer_unique` /
`rule90_Hfib_good`.

The definitions below are **verbatim-compatible copies** of the core's
(same fields, same statements), re-declared here so this project stays
standalone; upstreaming into the OPH repo is a file move plus a namespace
change.

## What this discharges

The core's `Rule90.lean` proves `Hfib` on a **width-3, one-step** carrier
(one edge) and names the multi-edge, proper-subset, redundancy-driven version
as the open modeling task (proof-chain review R1: "the QECC-strength
multi-edge theorem — proper-subset boundaries on carriers with code
redundancy — remains the open jewel"). Here:

* `rule90Cylinder n t` — the **(t+1)-patch, t-edge** carrier: patch `i` holds
  row `i` of the spacetime block; edge `i → i+1` exposes
  `(evolve rowᵢ, rowᵢ₊₁)`; consistency = "the block is a valid Rule-90
  trajectory". Genuinely multi-edge for `t ≥ 2` (`rule90Cylinder_multi_edge`).
* `tubeBoundary j₀` — the width-2 timelike screen readout: **2 of n cells
  per patch** — a proper, arbitrarily sparse subset of each interface for
  `n ≥ 3` (and provably coarser than `obsMap`:
  `tubeBoundary_strictly_coarser`).
* `rule90Cylinder_Hfib_tube` — **`H_fib` holds** for the tube boundary
  whenever `n ≤ 2(t+1)`, in the core's exact binder form (in fact with the
  stronger conclusion `x = y`, from which `gaugeEquiv` follows). This is the
  jewel in carrier form.
* `rule90Cylinder_Hfib_tube_sharp` — the threshold is sharp: for
  `2(t+1) < n` the same boundary **fails** `H_fib` (two consistent records,
  equal tube, different seeds — by counting).
* `rule90Cylinder_Hfib_column_fails` — the width-1 screen fails `H_fib` at
  every horizon (`n = 3` blinker witness, `t` arbitrary).

Axioms: standard; no `sorry`, no `native_decide`.
-/

namespace OPHProofChain

open Rule90

/-- Verbatim-compatible copy of the OPH Lean core's carrier structure
    (`Primitives.lean:69–101`): finite patch graph, per-edge interface
    projections, weights, per-edge distances. -/
structure OPHCarrier where
  Patch : Type
  patchFintype : Fintype Patch
  patchDecEq : DecidableEq Patch
  State : Patch → Type
  Edge : Type
  edgeFintype : Fintype Edge
  src : Edge → Patch
  tgt : Edge → Patch
  Iface : Edge → Type
  projSrc : (e : Edge) → State (src e) → Iface e
  projTgt : (e : Edge) → State (tgt e) → Iface e
  weight : Edge → NNReal
  dist : (e : Edge) → Iface e → Iface e → NNReal
  weight_pos : ∀ e : Edge, 0 < weight e
  dist_eq_zero : ∀ (e : Edge) (a b : Iface e), dist e a b = 0 ↔ a = b

attribute [instance] OPHCarrier.patchFintype OPHCarrier.patchDecEq
  OPHCarrier.edgeFintype

namespace OPHCarrier

variable (C : OPHCarrier)

/-- Global states (`Primitives.lean:109`). -/
def Records : Type := (i : C.Patch) → C.State i

/-- Declared observable overlap data (`Primitives.lean:113–120`). -/
def obsMap (x : C.Records) : (e : C.Edge) → C.Iface e × C.Iface e :=
  fun e => (C.projSrc e (x (C.src e)), C.projTgt e (x (C.tgt e)))

/-- Gauge equivalence = same declared observable overlap data
    (`Primitives.lean:198`). -/
def gaugeEquiv (x y : C.Records) : Prop := C.obsMap x = C.obsMap y

/-- The weighted mismatch potential (`Primitives.lean:144`). -/
noncomputable def Φ (x : C.Records) : NNReal :=
  ∑ e : C.Edge,
    C.weight e * C.dist e (C.projSrc e (x (C.src e))) (C.projTgt e (x (C.tgt e)))

/-- Consistency = zero mismatch (`Primitives.lean:153`). -/
def Consistent (x : C.Records) : Prop := C.Φ x = 0

/-- Edge consistency (`Primitives.lean:158`). -/
def EdgeConsistent (x : C.Records) : Prop :=
  ∀ e : C.Edge, C.projSrc e (x (C.src e)) = C.projTgt e (x (C.tgt e))

/-- `Φ = 0 ⟺` edge-by-edge agreement (`Primitives.lean:165`, same proof). -/
theorem consistent_iff_edgeConsistent (x : C.Records) :
    C.Consistent x ↔ C.EdgeConsistent x := by
  unfold Consistent EdgeConsistent Φ
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

end OPHCarrier

/-! ### The n×t Rule-90 cylinder carrier -/

/-- The **(t+1)-patch, t-edge** Rule-90 spacetime carrier on the `n`-cylinder:
    patch `i` holds row `i`; the edge `i → i+1` exposes
    `(evolve rowᵢ, rowᵢ₊₁)` on its interface, so edge-consistency says
    exactly "row `i+1` is the Rule-90 image of row `i`". Discrete interface
    metric, unit weights. Generalizes the core's one-edge `rule90Carrier`. -/
def rule90Cylinder (n t : ℕ) [NeZero n] : OPHCarrier where
  Patch := Fin (t + 1)
  patchFintype := inferInstance
  patchDecEq := inferInstance
  State := fun _ => Row n
  Edge := Fin t
  edgeFintype := inferInstance
  src := Fin.castSucc
  tgt := Fin.succ
  Iface := fun _ => Row n
  projSrc := fun _ s => evolve s
  projTgt := fun _ s => s
  weight := fun _ => 1
  dist := fun _ a b => if a = b then 0 else 1
  weight_pos := fun _ => one_pos
  dist_eq_zero := by
    intro _ a b
    by_cases h : a = b
    · rw [if_pos h]
      exact ⟨fun _ => h, fun _ => rfl⟩
    · rw [if_neg h]
      exact ⟨fun h1 => absurd h1 one_ne_zero, fun h2 => absurd h2 h⟩

variable {n t : ℕ} [NeZero n]

/-- Genuinely multi-edge: for `t ≥ 2` the carrier has at least two edges
    (the core's width-3 toy has exactly one). -/
theorem rule90Cylinder_multi_edge (ht : 2 ≤ t) :
    2 ≤ Fintype.card (rule90Cylinder n t).Edge := by
  show 2 ≤ Fintype.card (Fin t)
  rw [Fintype.card_fin]
  exact ht

/-- A consistent record of the cylinder carrier is a genuine Rule-90
    trajectory of its seed row. -/
theorem consistent_record_is_traj
    {x : (rule90Cylinder n t).Records}
    (hx : (rule90Cylinder n t).Consistent x) :
    ∀ i : Fin (t + 1), x i = traj (x (⟨0, Nat.succ_pos t⟩ : Fin (t + 1))) i.val := by
  have hedge := ((rule90Cylinder n t).consistent_iff_edgeConsistent x).mp hx
  intro i
  obtain ⟨iv, hiv⟩ := i
  induction iv with
  | zero => rfl
  | succ k ih =>
    have hk : k < t + 1 := by omega
    have hkt : k < t := by omega
    have he' : evolve (x (⟨k, hk⟩ : Fin (t + 1))) = x (⟨k + 1, hiv⟩ : Fin (t + 1)) :=
      hedge (⟨k, hkt⟩ : Fin t)
    rw [← he', ih hk]
    rfl

/-- The width-2 timelike tube boundary of the cylinder carrier: cells
    `j₀, j₀+1` of every patch — 2 of `n` cells per interface. -/
def tubeBoundary (j₀ : ZMod n)
    (x : (rule90Cylinder n t).Records) : Fin (t + 1) → ZMod 2 × ZMod 2 :=
  fun i => (x i j₀, x i (j₀ + 1))

/-- **`H_fib` FOR THE TUBE BOUNDARY — the jewel in carrier form.** On the
    `n`-cylinder with horizon `t`, `n ≤ 2(t+1)`: any two consistent records
    with equal width-2 tube boundary are **equal** (hence `gaugeEquiv`) —
    the exact hypothesis binder of the core's
    `boundary_fiber_observer_unique` / `rule90_Hfib_good`, discharged on a
    genuinely multi-edge carrier from a proper-subset boundary through the
    CA constraint redundancy. -/
theorem rule90Cylinder_Hfib_tube (j₀ : ZMod n) (hn : n ≤ 2 * (t + 1)) :
    ∀ x y : (rule90Cylinder n t).Records,
      tubeBoundary j₀ x = tubeBoundary j₀ y →
      (rule90Cylinder n t).Consistent x →
      (rule90Cylinder n t).Consistent y →
      x = y := by
  intro x y hB hcx hcy
  have hx := consistent_record_is_traj hcx
  have hy := consistent_record_is_traj hcy
  have hseed : x (⟨0, Nat.succ_pos t⟩ : Fin (t + 1)) =
      y (⟨0, Nat.succ_pos t⟩ : Fin (t + 1)) := by
    apply tube_information_set j₀ t hn
    funext i
    have hBi : (x i j₀, x i (j₀ + 1)) = (y i j₀, y i (j₀ + 1)) := congrFun hB i
    show (traj (x (⟨0, Nat.succ_pos t⟩ : Fin (t + 1))) i.val j₀,
          traj (x (⟨0, Nat.succ_pos t⟩ : Fin (t + 1))) i.val (j₀ + 1)) =
         (traj (y (⟨0, Nat.succ_pos t⟩ : Fin (t + 1))) i.val j₀,
          traj (y (⟨0, Nat.succ_pos t⟩ : Fin (t + 1))) i.val (j₀ + 1))
    rw [← hx i, ← hy i]
    exact hBi
  funext i
  rw [hx i, hy i, hseed]

/-- `H_fib` for the tube in the core's literal `gaugeEquiv` conclusion form. -/
theorem rule90Cylinder_Hfib_tube_gauge (j₀ : ZMod n) (hn : n ≤ 2 * (t + 1)) :
    ∀ x y : (rule90Cylinder n t).Records,
      tubeBoundary j₀ x = tubeBoundary j₀ y →
      (rule90Cylinder n t).Consistent x →
      (rule90Cylinder n t).Consistent y →
      (rule90Cylinder n t).gaugeEquiv x y := by
  intro x y hB hcx hcy
  rw [rule90Cylinder_Hfib_tube j₀ hn x y hB hcx hcy]
  rfl

/-- **Sharpness in carrier form**: for `2(t+1) < n` the tube boundary fails
    `H_fib` — two *consistent* records with equal tube boundary that are not
    equal (indeed with different seeds). -/
theorem rule90Cylinder_Hfib_tube_sharp (j₀ : ZMod n) (hn : 2 * (t + 1) < n) :
    ∃ x y : (rule90Cylinder n t).Records,
      tubeBoundary j₀ x = tubeBoundary j₀ y ∧
      (rule90Cylinder n t).Consistent x ∧
      (rule90Cylinder n t).Consistent y ∧
      x ≠ y := by
  obtain ⟨x0, y0, htube, hne⟩ :
      ∃ x0 y0 : Row n, tubeData j₀ t x0 = tubeData j₀ t y0 ∧ x0 ≠ y0 := by
    have := tube_not_information_set_of_lt j₀ t hn
    rw [Function.not_injective_iff] at this
    obtain ⟨a, b, hab, hne⟩ := this
    exact ⟨a, b, hab, hne⟩
  refine ⟨fun i => traj x0 i.val, fun i => traj y0 i.val, ?_, ?_, ?_, ?_⟩
  · funext i
    exact congrFun htube i
  · rw [(rule90Cylinder n t).consistent_iff_edgeConsistent]
    intro e
    rfl
  · rw [(rule90Cylinder n t).consistent_iff_edgeConsistent]
    intro e
    rfl
  · intro h
    exact hne (congrFun h (⟨0, Nat.succ_pos t⟩ : Fin (t + 1)))

/-- The width-1 column boundary: cell `j₀` of every patch. -/
def columnBoundary (j₀ : ZMod n)
    (x : (rule90Cylinder n t).Records) : Fin (t + 1) → ZMod 2 :=
  fun i => x i j₀

/-- **Width 1 fails `H_fib` at every horizon** (`n = 3` blinker witness,
    any `t`): two distinct consistent records with equal column boundary.
    The mirror-symmetric seed `δ₁ + δ₂` is a fixed point of `evolve` on the
    3-cylinder whose observed column is identically zero. -/
theorem rule90Cylinder_Hfib_column_fails (t : ℕ) :
    ∃ x y : (rule90Cylinder 3 t).Records,
      columnBoundary (0 : ZMod 3) x = columnBoundary (0 : ZMod 3) y ∧
      (rule90Cylinder 3 t).Consistent x ∧
      (rule90Cylinder 3 t).Consistent y ∧
      x ≠ y := by
  have hfix : evolve (delta 1 + delta 2 : Row 3) = delta 1 + delta 2 := by decide
  have hz0 : (delta 1 + delta 2 : Row 3) 0 = 0 := by decide
  have hzne : (delta 1 + delta 2 : Row 3) ≠ (0 : Row 3) := by decide
  refine ⟨fun _ => (delta 1 + delta 2 : Row 3), fun _ => (0 : Row 3), ?_, ?_, ?_, ?_⟩
  · funext i
    show (delta 1 + delta 2 : Row 3) 0 = (0 : Row 3) 0
    rw [hz0]
    rfl
  · rw [(rule90Cylinder 3 t).consistent_iff_edgeConsistent]
    intro e
    exact hfix
  · rw [(rule90Cylinder 3 t).consistent_iff_edgeConsistent]
    intro e
    show evolve (0 : Row 3) = (0 : Row 3)
    exact evolve_zero
  · intro h
    exact hzne (congrFun h (⟨0, Nat.succ_pos t⟩ : Fin (t + 1)))

/-- The tube boundary is **strictly coarser** than the full observable for
    the cylinder (witnessed at `n = 3, t = 1`): records exist with equal
    tube readout but different `obsMap` (so the tube genuinely reads a
    proper subset of the interface data, and the `H_fib` theorems above are
    not definitional endpoints). -/
theorem tubeBoundary_strictly_coarser :
    ∃ x y : (rule90Cylinder 3 1).Records,
      tubeBoundary (0 : ZMod 3) x = tubeBoundary (0 : ZMod 3) y ∧
      ¬ (rule90Cylinder 3 1).gaugeEquiv x y := by
  -- x: rows (0, δ₂); y: rows (0, 0). The tube reads cells {0, 1}; they
  -- differ only in cell 2 of row 1 — invisible to the tube, visible to
  -- obsMap (via the target projection of the single edge).
  refine ⟨fun i => if i.val = 0 then (0 : Row 3) else delta 2,
          fun _ => (0 : Row 3), ?_, ?_⟩
  · decide
  · intro hg
    have h22 : delta (2 : ZMod 3) (2 : ZMod 3) = (0 : Row 3) (2 : ZMod 3) := by
      have h2 := congrArg Prod.snd (congrFun hg (⟨0, Nat.one_pos⟩ : Fin 1))
      exact congrFun h2 (2 : ZMod 3)
    rw [delta_apply_self] at h22
    exact one_ne_zero h22

/-! ### `[formal-v7]` `H_fib` is strictly weaker than the information-set
property (holes-audit F20)

The second audit pass caught a false "exactly" at the paper's Part-II front
door: "an information set is *exactly* a boundary satisfying `H_fib`". Only
one direction is true. `H_fib` concludes **gauge-equivalence**, and on the
cylinder carrier the seed row is observed only through `evolve`, whose
kernel is nontrivial — so a boundary can pin the gauge class without
pinning the record. The audit compiled the counterexample against the tree;
here it IS in the tree: on `rule90Cylinder 3 1`, the full row-1 readout
satisfies the `H_fib` binder verbatim, yet two distinct consistent records
(seeds `0` and `(1,1,1)`, whose entire futures coincide) share it. -/

/-- The row-1 readout of the `n = 3, t = 1` cylinder: the whole second row. -/
def rowOneBoundary (x : (rule90Cylinder 3 1).Records) : Row 3 :=
  x (⟨1, by omega⟩ : Fin 2)

/-- The row-1 readout satisfies the `H_fib` binder verbatim: consistent
    records with equal row 1 are gauge-equivalent (their whole observable
    coincides — on this carrier the observable IS the row-1 data, read
    twice). -/
theorem rowOneBoundary_Hfib :
    ∀ x y : (rule90Cylinder 3 1).Records,
      rowOneBoundary x = rowOneBoundary y →
      (rule90Cylinder 3 1).Consistent x →
      (rule90Cylinder 3 1).Consistent y →
      (rule90Cylinder 3 1).gaugeEquiv x y := by
  intro x y hB hcx hcy
  have hx := ((rule90Cylinder 3 1).consistent_iff_edgeConsistent x).mp hcx
  have hy := ((rule90Cylinder 3 1).consistent_iff_edgeConsistent y).mp hcy
  have hex : evolve (x ⟨0, by omega⟩) = x ⟨1, by omega⟩ := hx (0 : Fin 1)
  have hey : evolve (y ⟨0, by omega⟩) = y ⟨1, by omega⟩ := hy (0 : Fin 1)
  funext e
  obtain ⟨ev, hev⟩ := e
  interval_cases ev
  show (evolve (x ⟨0, by omega⟩), x ⟨1, by omega⟩)
    = (evolve (y ⟨0, by omega⟩), y ⟨1, by omega⟩)
  rw [hex, hey]
  have h1 : x (⟨1, by omega⟩ : Fin 2) = y ⟨1, by omega⟩ := hB
  rw [h1]

/-- …but it is NOT an information set: two **distinct** consistent records
    share the row-1 readout — the seeds `0` and `(1,1,1)` differ, while
    `evolve (1,1,1) = 0` on the 3-cylinder, so their futures coincide. The
    audit's compiled counterexample, now in-tree. -/
theorem rowOneBoundary_not_informationSet :
    ∃ x y : (rule90Cylinder 3 1).Records,
      (rule90Cylinder 3 1).Consistent x ∧
      (rule90Cylinder 3 1).Consistent y ∧
      rowOneBoundary x = rowOneBoundary y ∧ x ≠ y := by
  refine ⟨fun i => (if i.val = 0 then (fun _ => (1 : ZMod 2)) else 0 : Row 3),
    fun _ => (0 : Row 3), ?_, ?_, ?_, ?_⟩
  · rw [(rule90Cylinder 3 1).consistent_iff_edgeConsistent]
    intro e
    obtain ⟨ev, hev⟩ := e
    interval_cases ev
    show evolve (fun _ => (1 : ZMod 2)) = (0 : Row 3)
    decide
  · rw [(rule90Cylinder 3 1).consistent_iff_edgeConsistent]
    intro e
    show evolve (0 : Row 3) = (0 : Row 3)
    exact evolve_zero
  · rfl
  · intro h
    have h0 := congrFun (congrFun h (⟨0, by omega⟩ : Fin 2)) (0 : ZMod 3)
    exact one_ne_zero h0

/-- **`H_fib` ⊊ information set (F20, the honest direction and its
    converse's failure, packaged).** The row-1 boundary satisfies `H_fib`
    while failing the information-set (equality) conclusion — so
    "boundary satisfying `H_fib`" is strictly weaker than "information
    set", and the paper's front-door "exactly" was false in the direction
    that would matter. (The true direction — information set ⟹ `H_fib`
    with the stronger `x = y` conclusion — is `rule90Cylinder_Hfib_tube`.) -/
theorem hfib_strictly_weaker_than_informationSet :
    (∀ x y : (rule90Cylinder 3 1).Records,
      rowOneBoundary x = rowOneBoundary y →
      (rule90Cylinder 3 1).Consistent x →
      (rule90Cylinder 3 1).Consistent y →
      (rule90Cylinder 3 1).gaugeEquiv x y) ∧
    ¬ (∀ x y : (rule90Cylinder 3 1).Records,
      rowOneBoundary x = rowOneBoundary y →
      (rule90Cylinder 3 1).Consistent x →
      (rule90Cylinder 3 1).Consistent y → x = y) := by
  refine ⟨rowOneBoundary_Hfib, fun hall => ?_⟩
  obtain ⟨x, y, hcx, hcy, hB, hne⟩ := rowOneBoundary_not_informationSet
  exact hne (hall x y hB hcx hcy)

/-! ### Axiom audit -/
#print axioms rule90Cylinder_Hfib_tube
#print axioms rule90Cylinder_Hfib_tube_gauge
#print axioms rule90Cylinder_Hfib_tube_sharp
#print axioms rule90Cylinder_Hfib_column_fails
#print axioms tubeBoundary_strictly_coarser
#print axioms rowOneBoundary_Hfib
#print axioms rowOneBoundary_not_informationSet
#print axioms hfib_strictly_weaker_than_informationSet

end OPHProofChain
