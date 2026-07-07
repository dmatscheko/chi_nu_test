import Mathlib
import OPHProofChain.CarrierBridge
import OPHProofChain.QuotientRepair
import OPHProofChain.Core.Primitives
import OPHProofChain.Rule90Readout

/-!
# T27 — Route A assembled: local transactional decode-repair on the Rule-90 cylinder

**The audit hole this closes (F2 of `chi_nu_test/OPH_PROOF_CHAIN_HOLES.md`).**
Route A's advertised composition is: repair dynamics + boundary preservation
(`H_B`) + gauge-singleton boundary fibers (`H_fib`) ⟹ all observers settle to
one world pinned by the boundary. Before this module the three premises were
never discharged **on one carrier**: the sharp `H_fib` lives on the Rule-90
cylinder (`CarrierBridge.rule90Cylinder_Hfib_tube`, T9′), where no
`H1 ∧ H2 ∧ H3` single-patch repair can exist, and the canonical operator of
T12 stalls on inconsistent records. This module supplies the honest completion
**and** machine-checks both negatives:

* **The dynamics** (`DecodeStep`): a family of *local decode transactions* —
  each writes ONE cell of one patch, reading only that patch and one
  edge-adjacent patch (a bounded window: exactly the two endpoints of a
  carrier edge). The trigger is *formula mismatch* (a relaxed `H2`, exactly
  the escape hatch `Core/Rule90.lean`'s impossibility theorem names). The
  assignment of a formula to a cell (right-sweep / left-sweep / downward, with
  budgets `R = min t (n−2)`, `L = (n−2) − R`) is **declared structure**, billed
  like Route B's declared order: it is a responsibility roster, and different
  rosters give different (equally valid) repairs.
* **`H_B`** (`decodeStep_tube`): every transaction targets a non-tube cell, so
  the width-2 tube boundary reading is preserved — *by value and by cell*.
* **Termination + liveness** (`pass_spec`): the declared rank schedule reaches
  a normal form from every record in one finite pass; normal forms are exactly
  the decode-quiescent records (`normalForm_iff_quiescent`).
* **Observer uniqueness — Route A's conclusion, on this carrier**
  (`routeA_observer_uniqueness`): for `n ≤ 2(t+1)`, any two records with equal
  tube reading settle — under ANY schedules, to ANY normal forms — to the
  **same** record (literal equality, stronger than `gaugeEquiv`). No
  realizability hypothesis: the boundary pins the settled world outright.
* **Completeness on realizable fibers** (`routeA_world_consistent_iff`): the
  settled world is *consistent* **iff** the tube reading is realizable (some
  consistent record carries it); when it is, the world is THE record the
  `H_fib` jewel promises (`rule90Cylinder_Hfib_tube`), and when it is not,
  **no** boundary-preserving repair could reach consistency because the fiber
  contains no consistent record at all
  (`no_consistent_completion_of_unrealizable`) — the stall is forced by logic,
  not by weakness of the operator.
* **The negatives, machine-checked** (previously "checkable by hand" in the
  audit): `rule90CylinderOPH_no_frustrationFree_repair` — on the cylinder
  carrier no operator satisfies `H1 ∧ H2 ∧ H3`, for every `n ≥ 1, t ≥ 1`; and
  `canonical_repair_stalls` — the canonical operator of T12 on the
  `n = 3, t = 2` cylinder, started from the audit's record `(0, δ₀, δ₁)`,
  terminates in exactly one step at `(0, δ₀, evolve δ₀)` with edge 0 broken
  forever. The audit's stall record has an **unrealizable tube**
  (`stallRecord_tube_unrealizable`): even the ideal tube-preserving decoder
  must stall there, because its fiber is empty of consistent records.

**What is declared (billed structure).** The responsibility roster: the split
`R + L = n − 2` of the non-tube columns into right-sweep and left-sweep
territory (`budgetR`, `budgetL`), the per-cell formula, and the rank schedule.
Such a roster with both budgets `≤ t` exists **iff** `n ≤ 2(t+1)` — the same
sharp threshold as the `H_fib` jewel, which is not a coincidence: the roster
IS the decoding strategy whose existence the information-set theorem
certifies.

**Namespace note.** The positive dynamics is stated on
`OPHProofChain.rule90Cylinder` (the carrier of T9′); the two negatives are
stated on `rule90CylinderOPH`, the *same carrier re-declared as an
`OPH.OPHCarrier`* so they can speak the Core's canonical-operator vocabulary
(`OPH.Repair`, `OPH.ShouldFire`, …) verbatim. The two structures have
identical fields; records of both are literally `Fin (t+1) → Row n`.

Axioms: standard (`propext`, `Classical.choice`, `Quot.sound`); no `sorry`,
no `native_decide`.
-/

namespace OPHProofChain.RouteA

open Rule90 Relation

/-- Reduction helper for offsets that overflow once: if `n ≤ a < 2n` then
    `a % n = a − n`. -/
theorem mod_eq_sub_of_lt_two_mul {n a : ℕ} (h1 : n ≤ a) (h2 : a < 2 * n) :
    a % n = a - n := by
  rw [Nat.mod_eq_sub_mod h1, Nat.mod_eq_of_lt (by omega)]

/-! ## Cell geometry: the tube-offset coordinate

A cell is a pair `(i, c) : Fin (t+1) × ZMod n` — patch (row) `i`, column `c`.
All column bookkeeping runs through the offset `u = (c − j₀ − 1) mod n`:
`u = 0` is the tube column `j₀+1`, `u = n−1` is the tube column `j₀`, and the
non-tube columns are exactly `1 ≤ u ≤ n−2`. -/

section CellGeometry

variable {n : ℕ} [NeZero n]

/-- Offset coordinate of a column relative to the tube `{j₀, j₀+1}`:
    `u = (c − j₀ − 1) mod n`. -/
def uOf (j₀ c : ZMod n) : ℕ := (c - j₀ - 1).val

theorem uOf_lt (j₀ c : ZMod n) : uOf j₀ c < n := ZMod.val_lt _

theorem natCast_uOf (j₀ c : ZMod n) : ((uOf j₀ c : ℕ) : ZMod n) = c - j₀ - 1 := by
  unfold uOf
  rw [ZMod.natCast_val, ZMod.cast_id]

/-- `(n − 1 : ℕ)` casts to `−1` in `ZMod n`. -/
theorem natCast_n_sub_one : ((n - 1 : ℕ) : ZMod n) = -1 := by
  have h1 : (1 : ℕ) ≤ n := Nat.one_le_iff_ne_zero.mpr (NeZero.ne n)
  rw [Nat.cast_sub h1, ZMod.natCast_self, Nat.cast_one, zero_sub]

/-- `(−1 : ZMod n)` has value `n − 1`. -/
theorem val_neg_one' : (-1 : ZMod n).val = n - 1 := by
  obtain ⟨m, rfl⟩ := Nat.exists_eq_succ_of_ne_zero (NeZero.ne n)
  rw [Nat.succ_sub_one]
  exact ZMod.val_neg_one m

/-- The two tube columns. -/
def IsTube (j₀ c : ZMod n) : Prop := c = j₀ ∨ c = j₀ + 1

instance (j₀ c : ZMod n) : Decidable (IsTube j₀ c) := by
  unfold IsTube; infer_instance

/-- Tube membership in offset coordinates: `u = 0` (column `j₀+1`) or
    `u = n−1` (column `j₀`). -/
theorem isTube_iff (j₀ c : ZMod n) :
    IsTube j₀ c ↔ uOf j₀ c = 0 ∨ uOf j₀ c = n - 1 := by
  constructor
  · rintro (rfl | rfl)
    · right
      show (c - c - 1).val = n - 1
      rw [sub_self, zero_sub, val_neg_one']
    · left
      show (j₀ + 1 - j₀ - 1).val = 0
      rw [show j₀ + 1 - j₀ - 1 = 0 from by ring, ZMod.val_zero]
  · rintro (h | h)
    · right
      have h0 : c - j₀ - 1 = 0 := by rwa [← ZMod.val_eq_zero]
      have h1 : c = j₀ + 1 := by linear_combination h0
      rw [h1]
    · left
      have h0 : c - j₀ - 1 = -1 := by
        rw [← natCast_uOf j₀ c, h, natCast_n_sub_one]
      have h1 : c = j₀ := by linear_combination h0
      rw [h1]

/-- The offset workhorse: shifting a column by `+k` shifts the offset by `+k`
    mod `n`. -/
theorem uOf_add_natCast (j₀ c : ZMod n) (k : ℕ) :
    uOf j₀ (c + (k : ZMod n)) = (uOf j₀ c + k) % n := by
  have h1 : c + (k : ZMod n) - j₀ - 1 = ((uOf j₀ c + k : ℕ) : ZMod n) := by
    push_cast
    rw [natCast_uOf]
    ring
  show (c + (k : ZMod n) - j₀ - 1).val = _
  rw [h1, ZMod.val_natCast]

/-- Column shift `−1` as `+(n−1)`. -/
theorem sub_one_eq (c : ZMod n) : c - 1 = c + ((n - 1 : ℕ) : ZMod n) := by
  rw [natCast_n_sub_one]; ring

omit [NeZero n] in
/-- Column shift `−2` as `+(n−2)` (needs `2 ≤ n`). -/
theorem sub_two_eq (hn : 2 ≤ n) (c : ZMod n) :
    c - 2 = c + ((n - 2 : ℕ) : ZMod n) := by
  have h : ((n - 2 : ℕ) : ZMod n) = -2 := by
    rw [Nat.cast_sub hn, ZMod.natCast_self, zero_sub]
    norm_num
  rw [h]; ring

omit [NeZero n] in
/-- Column shift `+1` as a `ℕ`-cast shift. -/
theorem add_one_eq (c : ZMod n) : c + 1 = c + ((1 : ℕ) : ZMod n) := by norm_num

omit [NeZero n] in
/-- Column shift `+2` as a `ℕ`-cast shift. -/
theorem add_two_eq (c : ZMod n) : c + 2 = c + ((2 : ℕ) : ZMod n) := by norm_num

end CellGeometry

/-! ## The declared responsibility roster

The non-tube columns `u ∈ [1, n−2]` are split into **right-sweep territory**
(`u ≤ R`) and **left-sweep territory** (`u ≥ R+1`, equivalently
`l := n−1−u ≤ L`), with the declared budgets `R = min t (n−2)` and
`L = (n−2) − R`. A sweep owns a cell only down to its light-cone depth
(`i + distance ≤ t`); everything deeper is **downward territory** (rows
`i ≥ 1`, formula = the plain CA step from the row above). This roster is
declared structure — the Route-B lesson, billed. -/

/-- Right-sweep budget `R = min t (n−2)` — declared structure. -/
def budgetR (n t : ℕ) : ℕ := min t (n - 2)

/-- Left-sweep budget `L = (n−2) − R` — declared structure. -/
def budgetL (n t : ℕ) : ℕ := n - 2 - budgetR n t

theorem budgetR_le_t {n t : ℕ} : budgetR n t ≤ t := min_le_left _ _

theorem budgetR_le {n t : ℕ} : budgetR n t ≤ n - 2 := min_le_right _ _

/-- Under the sharp threshold `n ≤ 2(t+1)`, the left budget also fits its
    sweep: `L ≤ t`. (This is exactly where the threshold enters.) -/
theorem budgetL_le_t {n t : ℕ} (hn : n ≤ 2 * (t + 1)) : budgetL n t ≤ t := by
  unfold budgetL budgetR
  omega

theorem budgetR_add_budgetL {n t : ℕ} : budgetR n t + budgetL n t = n - 2 := by
  have := budgetR_le (n := n) (t := t)
  unfold budgetL
  omega

section Roster

variable {n : ℕ} [NeZero n] {t : ℕ}

/-- Cell `(i, c)` is owned by the **right sweep**: offset in right territory,
    within the sweep's light cone. Its formula reads the edge-window
    `{i, i+1}` at offsets `u−1` (row `i+1`) and `u−2` (row `i`). -/
def OwnedR (j₀ : ZMod n) (i : Fin (t + 1)) (c : ZMod n) : Prop :=
  1 ≤ uOf j₀ c ∧ uOf j₀ c ≤ budgetR n t ∧ i.val + uOf j₀ c ≤ t

/-- Cell `(i, c)` is owned by the **left sweep**: offset in left territory
    (`l = n−1−u` is the leftward distance), within the sweep's light cone. -/
def OwnedL (j₀ : ZMod n) (i : Fin (t + 1)) (c : ZMod n) : Prop :=
  budgetR n t + 1 ≤ uOf j₀ c ∧ uOf j₀ c ≤ n - 2 ∧
    i.val + (n - 1 - uOf j₀ c) ≤ t

/-- Cell `(i, c)` is owned by the **downward step**: non-tube, not reachable
    by either sweep, on a row `i ≥ 1`; its formula is the plain CA step read
    from row `i−1`. -/
def OwnedD (j₀ : ZMod n) (i : Fin (t + 1)) (c : ZMod n) : Prop :=
  1 ≤ uOf j₀ c ∧ uOf j₀ c ≤ n - 2 ∧ 1 ≤ i.val ∧
    ¬ OwnedR j₀ i c ∧ ¬ OwnedL j₀ i c

/-- Cell ownership: some declared formula is responsible for the cell. -/
def Owned (j₀ : ZMod n) (i : Fin (t + 1)) (c : ZMod n) : Prop :=
  OwnedR j₀ i c ∨ OwnedL j₀ i c ∨ OwnedD j₀ i c

instance (j₀ : ZMod n) (i : Fin (t + 1)) (c : ZMod n) :
    Decidable (OwnedR j₀ i c) := by unfold OwnedR; infer_instance

instance (j₀ : ZMod n) (i : Fin (t + 1)) (c : ZMod n) :
    Decidable (OwnedL j₀ i c) := by unfold OwnedL; infer_instance

instance (j₀ : ZMod n) (i : Fin (t + 1)) (c : ZMod n) :
    Decidable (OwnedD j₀ i c) := by unfold OwnedD; infer_instance

instance (j₀ : ZMod n) (i : Fin (t + 1)) (c : ZMod n) :
    Decidable (Owned j₀ i c) := by unfold Owned; infer_instance

omit [NeZero n] in
theorem OwnedR.not_ownedL {j₀ : ZMod n} {i : Fin (t + 1)} {c : ZMod n}
    (h : OwnedR j₀ i c) : ¬ OwnedL j₀ i c := by
  intro h'
  have h2 := h.2.1
  have h1' := h'.1
  omega

omit [NeZero n] in
/-- Owned cells have offsets in the non-tube band `[1, n−2]`. -/
theorem Owned.u_band {j₀ : ZMod n} {i : Fin (t + 1)} {c : ZMod n}
    (h : Owned j₀ i c) : 1 ≤ uOf j₀ c ∧ uOf j₀ c ≤ n - 2 := by
  rcases h with h | h | h
  · exact ⟨h.1, le_trans h.2.1 budgetR_le⟩
  · have h1 := h.1
    exact ⟨by omega, h.2.1⟩
  · exact ⟨h.1, h.2.1⟩

/-- An owned cell is never a tube cell. -/
theorem Owned.not_isTube {j₀ : ZMod n} {i : Fin (t + 1)} {c : ZMod n}
    (h : Owned j₀ i c) : ¬ IsTube j₀ c := by
  have hu := h.u_band
  intro htube
  rcases (isTube_iff j₀ c).mp htube with h0 | h0 <;> omega

/-- **Coverage**: under the sharp threshold, every cell is tube or owned.
    (Row 0 is covered by the two sweeps — this is where `n ≤ 2(t+1)` does its
    work; rows `i ≥ 1` are always covered because the downward formula catches
    everything the sweeps miss.) -/
theorem coverage (hn : n ≤ 2 * (t + 1)) (j₀ : ZMod n) (i : Fin (t + 1))
    (c : ZMod n) : IsTube j₀ c ∨ Owned j₀ i c := by
  rcases Nat.eq_zero_or_pos (uOf j₀ c) with h0 | h1
  · exact Or.inl ((isTube_iff j₀ c).mpr (Or.inl h0))
  rcases Nat.lt_or_ge (uOf j₀ c) (n - 1) with hlt | hge
  swap
  · -- `u ≥ n−1` and `u < n` force `u = n−1`: the tube column `j₀`
    exact Or.inl ((isTube_iff j₀ c).mpr (Or.inr (by have := uOf_lt j₀ c; omega)))
  -- now `1 ≤ u ≤ n−2`: non-tube
  right
  by_cases hR : OwnedR j₀ i c
  · exact Or.inl hR
  by_cases hL : OwnedL j₀ i c
  · exact Or.inr (Or.inl hL)
  -- neither sweep owns it; show the downward formula does, i.e. `i ≥ 1`
  refine Or.inr (Or.inr ⟨h1, by omega, ?_, hR, hL⟩)
  -- row 0 is always sweep-covered (this needs the threshold)
  by_contra hi0
  have hi : i.val = 0 := by omega
  simp only [OwnedR, not_and] at hR
  simp only [OwnedL, not_and] at hL
  have hRle := budgetR_le_t (n := n) (t := t)
  have hRle' := budgetR_le (n := n) (t := t)
  have hLt := budgetL_le_t (n := n) (t := t) hn
  have hRL := budgetR_add_budgetL (n := n) (t := t)
  -- if `u ≤ R` then row-0 right ownership holds (`0 + u ≤ t`); contradiction
  -- with `hR`. Otherwise `u ≥ R+1`, so `l = n−1−u ≤ L ≤ t` gives row-0 left
  -- ownership; contradiction with `hL`.
  rcases le_or_gt (uOf j₀ c) (budgetR n t) with hcase | hcase
  · have := hR h1 hcase
    omega
  · have := hL hcase (by omega)
    omega

/-- The declared **rank** of a cell: the schedule stratum it sits in.
    Tube cells (and, off-threshold, orphan cells) rank 0; sweep cells rank by
    their distance from the tube; downward cells rank `t + 1 + i` — strictly
    above every sweep rank. The load-bearing fact is stratification
    (`formulaValue_congr`): every formula reads strictly below its own rank. -/
def rank (j₀ : ZMod n) (i : Fin (t + 1)) (c : ZMod n) : ℕ :=
  if OwnedR j₀ i c then uOf j₀ c
  else if OwnedL j₀ i c then n - 1 - uOf j₀ c
  else if OwnedD j₀ i c then t + 1 + i.val
  else 0

omit [NeZero n] in
theorem rank_of_ownedR {j₀ : ZMod n} {i : Fin (t + 1)} {c : ZMod n}
    (h : OwnedR j₀ i c) : rank j₀ i c = uOf j₀ c := by
  unfold rank
  rw [if_pos h]

omit [NeZero n] in
theorem rank_of_ownedL {j₀ : ZMod n} {i : Fin (t + 1)} {c : ZMod n}
    (h : OwnedL j₀ i c) : rank j₀ i c = n - 1 - uOf j₀ c := by
  unfold rank
  rw [if_neg (fun h' => (OwnedR.not_ownedL h') h), if_pos h]

omit [NeZero n] in
theorem rank_of_ownedD {j₀ : ZMod n} {i : Fin (t + 1)} {c : ZMod n}
    (h : OwnedD j₀ i c) : rank j₀ i c = t + 1 + i.val := by
  unfold rank
  rw [if_neg h.2.2.2.1, if_neg h.2.2.2.2, if_pos h]

omit [NeZero n] in
theorem rank_of_not_owned {j₀ : ZMod n} {i : Fin (t + 1)} {c : ZMod n}
    (h : ¬ Owned j₀ i c) : rank j₀ i c = 0 := by
  have h1 : ¬ OwnedR j₀ i c := fun h' => h (Or.inl h')
  have h2 : ¬ OwnedL j₀ i c := fun h' => h (Or.inr (Or.inl h'))
  have h3 : ¬ OwnedD j₀ i c := fun h' => h (Or.inr (Or.inr h'))
  unfold rank
  rw [if_neg h1, if_neg h2, if_neg h3]

omit [NeZero n] in
/-- Owned cells have positive rank. -/
theorem rank_pos {j₀ : ZMod n} {i : Fin (t + 1)} {c : ZMod n}
    (h : Owned j₀ i c) : 1 ≤ rank j₀ i c := by
  rcases h with h | h | h
  · rw [rank_of_ownedR h]; exact h.1
  · rw [rank_of_ownedL h]
    have h1 := h.1
    have h2 := h.2.1
    omega
  · rw [rank_of_ownedD h]; omega

omit [NeZero n] in
/-- All ranks are `< 2t + 2` (the schedule length). -/
theorem rank_lt (j₀ : ZMod n) (i : Fin (t + 1)) (c : ZMod n) :
    rank j₀ i c < 2 * t + 2 := by
  unfold rank
  split_ifs with hR hL hD
  · have h2 := hR.2.2
    omega
  · have h2 := hL.2.2
    omega
  · have := i.isLt
    omega
  · omega

end Roster

/-! ## The formula layer

Each owned cell's declared repair formula, its window, and the stratification
lemma (`formulaValue_congr`): a formula's value depends only on cells of
strictly smaller rank. -/

section Formula

variable {n : ℕ} [NeZero n] {t : ℕ}

omit [NeZero n] in
theorem OwnedR.succ_lt {j₀ : ZMod n} {i : Fin (t + 1)} {c : ZMod n}
    (h : OwnedR j₀ i c) : i.val + 1 < t + 1 := by
  have h1 := h.1
  have h2 := h.2.2
  omega

omit [NeZero n] in
theorem OwnedL.succ_lt {j₀ : ZMod n} {i : Fin (t + 1)} {c : ZMod n}
    (h : OwnedL j₀ i c) : i.val + 1 < t + 1 := by
  have h1 := h.1
  have h2 := h.2.1
  have h3 := h.2.2
  omega

omit [NeZero n] in
theorem OwnedD.pred_lt {j₀ : ZMod n} {i : Fin (t + 1)} {c : ZMod n}
    (_h : OwnedD j₀ i c) : i.val - 1 < t + 1 := by
  have := i.isLt
  omega

/-- The declared decode formula of a cell. Right-sweep cells solve the CA
    constraint sideways-right (`x_i(c) = x_{i+1}(c−1) + x_i(c−2)`), left-sweep
    cells sideways-left (`x_i(c) = x_{i+1}(c+1) + x_i(c+2)`), downward cells
    take the plain CA step from the row above
    (`x_i(c) = x_{i−1}(c−1) + x_{i−1}(c+1)`). Unowned cells: the current value
    (no formula, never fires). Every branch reads only the cell's row and ONE
    edge-adjacent row — a bounded window, the two endpoints of a carrier
    edge. -/
def formulaValue (j₀ : ZMod n) (x : Fin (t + 1) → Row n) (i : Fin (t + 1))
    (c : ZMod n) : ZMod 2 :=
  if hR : OwnedR j₀ i c then
    x ⟨i.val + 1, hR.succ_lt⟩ (c - 1) + x i (c - 2)
  else if hL : OwnedL j₀ i c then
    x ⟨i.val + 1, hL.succ_lt⟩ (c + 1) + x i (c + 2)
  else if hD : OwnedD j₀ i c then
    x ⟨i.val - 1, hD.pred_lt⟩ (c - 1) + x ⟨i.val - 1, hD.pred_lt⟩ (c + 1)
  else x i c

omit [NeZero n] in
theorem formulaValue_of_ownedR {j₀ : ZMod n} {i : Fin (t + 1)} {c : ZMod n}
    (h : OwnedR j₀ i c) (x : Fin (t + 1) → Row n) :
    formulaValue j₀ x i c = x ⟨i.val + 1, h.succ_lt⟩ (c - 1) + x i (c - 2) := by
  unfold formulaValue
  rw [dif_pos h]

omit [NeZero n] in
theorem formulaValue_of_ownedL {j₀ : ZMod n} {i : Fin (t + 1)} {c : ZMod n}
    (h : OwnedL j₀ i c) (x : Fin (t + 1) → Row n) :
    formulaValue j₀ x i c = x ⟨i.val + 1, h.succ_lt⟩ (c + 1) + x i (c + 2) := by
  unfold formulaValue
  rw [dif_neg (fun h' => (OwnedR.not_ownedL h') h), dif_pos h]

omit [NeZero n] in
theorem formulaValue_of_ownedD {j₀ : ZMod n} {i : Fin (t + 1)} {c : ZMod n}
    (h : OwnedD j₀ i c) (x : Fin (t + 1) → Row n) :
    formulaValue j₀ x i c
      = x ⟨i.val - 1, h.pred_lt⟩ (c - 1) + x ⟨i.val - 1, h.pred_lt⟩ (c + 1) := by
  unfold formulaValue
  rw [dif_neg h.2.2.2.1, dif_neg h.2.2.2.2, dif_pos h]

omit [NeZero n] in
theorem formulaValue_of_not_owned {j₀ : ZMod n} {i : Fin (t + 1)} {c : ZMod n}
    (h : ¬ Owned j₀ i c) (x : Fin (t + 1) → Row n) :
    formulaValue j₀ x i c = x i c := by
  have h1 : ¬ OwnedR j₀ i c := fun h' => h (Or.inl h')
  have h2 : ¬ OwnedL j₀ i c := fun h' => h (Or.inr (Or.inl h'))
  have h3 : ¬ OwnedD j₀ i c := fun h' => h (Or.inr (Or.inr h'))
  unfold formulaValue
  rw [dif_neg h1, dif_neg h2, dif_neg h3]

omit [NeZero n] in
/-- The formula layer is linear: it commutes with record subtraction. -/
theorem formulaValue_sub (j₀ : ZMod n) (x y : Fin (t + 1) → Row n)
    (i : Fin (t + 1)) (c : ZMod n) :
    formulaValue j₀ (x - y) i c
      = formulaValue j₀ x i c - formulaValue j₀ y i c := by
  unfold formulaValue
  split_ifs <;> simp only [Pi.sub_apply] <;> ring

/-! ### Read ranks: every formula reads strictly below its own rank -/

/-- Right read 1: the cell `(i+1, c−1)` sits strictly below rank `u`. -/
theorem rank_read1_R {j₀ : ZMod n} {i : Fin (t + 1)} {c : ZMod n}
    (h : OwnedR j₀ i c) {i' : Fin (t + 1)} (hi' : i'.val = i.val + 1) :
    rank j₀ i' (c - 1) < rank j₀ i c := by
  have h1 := h.1
  have h2 := h.2.1
  have h3 := h.2.2
  have hn3 : 3 ≤ n := by
    have := budgetR_le (n := n) (t := t)
    omega
  have hu : uOf j₀ (c - 1) = uOf j₀ c - 1 := by
    rw [sub_one_eq, uOf_add_natCast,
      mod_eq_sub_of_lt_two_mul (by omega) (by have := uOf_lt j₀ c; omega)]
    omega
  rw [rank_of_ownedR h]
  rcases Nat.eq_or_lt_of_le h1 with h1' | h1'
  · -- `u = 1`: the read column is the tube column `j₀+1` (offset 0): rank 0
    have hnot : ¬ Owned j₀ i' (c - 1) := by
      intro hO
      have hband := hO.u_band
      omega
    rw [rank_of_not_owned hnot]
    omega
  · -- `u ≥ 2`: the read cell is right-owned at offset `u−1`
    have hR' : OwnedR j₀ i' (c - 1) := by
      refine ⟨by omega, by omega, ?_⟩
      rw [hi', hu]
      omega
    rw [rank_of_ownedR hR', hu]
    omega

/-- Right read 2: the cell `(i, c−2)` sits strictly below rank `u`. -/
theorem rank_read2_R {j₀ : ZMod n} {i : Fin (t + 1)} {c : ZMod n}
    (h : OwnedR j₀ i c) : rank j₀ i (c - 2) < rank j₀ i c := by
  have h1 := h.1
  have h2 := h.2.1
  have h3 := h.2.2
  have hn3 : 3 ≤ n := by
    have := budgetR_le (n := n) (t := t)
    omega
  have hu : uOf j₀ (c - 2) = (uOf j₀ c + (n - 2)) % n := by
    rw [sub_two_eq (by omega), uOf_add_natCast]
  rw [rank_of_ownedR h]
  rcases Nat.lt_or_ge (uOf j₀ c) 3 with hu3 | hu3
  · -- `u ∈ {1, 2}`: the read column is a tube column (offset `n−1` or `0`)
    have hval : uOf j₀ (c - 2) = 0 ∨ uOf j₀ (c - 2) = n - 1 := by
      rw [hu]
      rcases Nat.eq_or_lt_of_le h1 with h1' | h1'
      · -- `u = 1`: offset `n−1` (no overflow)
        right
        rw [Nat.mod_eq_of_lt (by omega)]
        omega
      · -- `u = 2`: offset `n` reduces to 0
        left
        have hu2 : uOf j₀ c = 2 := by omega
        rw [hu2, mod_eq_sub_of_lt_two_mul (by omega) (by omega)]
        omega
    have hnot : ¬ Owned j₀ i (c - 2) := by
      intro hO
      have hband := hO.u_band
      omega
    rw [rank_of_not_owned hnot]
    omega
  · -- `u ≥ 3`: the read cell is right-owned at offset `u−2`
    have hu' : uOf j₀ (c - 2) = uOf j₀ c - 2 := by
      rw [hu, mod_eq_sub_of_lt_two_mul (by omega)
        (by have := uOf_lt j₀ c; omega)]
      omega
    have hR' : OwnedR j₀ i (c - 2) := ⟨by omega, by omega, by omega⟩
    rw [rank_of_ownedR hR', hu']
    omega

/-- Left read 1: the cell `(i+1, c+1)` sits strictly below rank `l`. -/
theorem rank_read1_L {j₀ : ZMod n} {i : Fin (t + 1)} {c : ZMod n}
    (h : OwnedL j₀ i c) {i' : Fin (t + 1)} (hi' : i'.val = i.val + 1) :
    rank j₀ i' (c + 1) < rank j₀ i c := by
  have h1 := h.1
  have h2 := h.2.1
  have h3 := h.2.2
  have hn3 : 3 ≤ n := by omega
  have hu : uOf j₀ (c + 1) = uOf j₀ c + 1 := by
    rw [add_one_eq, uOf_add_natCast, Nat.mod_eq_of_lt (by omega)]
  rw [rank_of_ownedL h]
  rcases Nat.eq_or_lt_of_le h2 with h2' | h2'
  · -- `u = n−2`: the read column has offset `n−1`: the tube column `j₀`
    have hnot : ¬ Owned j₀ i' (c + 1) := by
      intro hO
      have hband := hO.u_band
      omega
    rw [rank_of_not_owned hnot]
    omega
  · -- `u ≤ n−3`: the read cell is left-owned at offset `u+1`
    have hL' : OwnedL j₀ i' (c + 1) := by
      refine ⟨by omega, by omega, ?_⟩
      rw [hi', hu]
      omega
    rw [rank_of_ownedL hL', hu]
    omega

/-- Left read 2: the cell `(i, c+2)` sits strictly below rank `l`. -/
theorem rank_read2_L {j₀ : ZMod n} {i : Fin (t + 1)} {c : ZMod n}
    (h : OwnedL j₀ i c) : rank j₀ i (c + 2) < rank j₀ i c := by
  have h1 := h.1
  have h2 := h.2.1
  have h3 := h.2.2
  have hn3 : 3 ≤ n := by omega
  have hu : uOf j₀ (c + 2) = (uOf j₀ c + 2) % n := by
    rw [add_two_eq, uOf_add_natCast]
  rw [rank_of_ownedL h]
  rcases Nat.lt_or_ge (uOf j₀ c) (n - 3) with hu3 | hu3
  · -- `u ≤ n−4`: the read cell is left-owned at offset `u+2`
    have hu' : uOf j₀ (c + 2) = uOf j₀ c + 2 := by
      rw [hu, Nat.mod_eq_of_lt (by omega)]
    have hL' : OwnedL j₀ i (c + 2) := ⟨by omega, by omega, by omega⟩
    rw [rank_of_ownedL hL', hu']
    omega
  · -- `u ∈ {n−3, n−2}`: the read column is a tube column (offset `n−1` or 0)
    have hval : uOf j₀ (c + 2) = 0 ∨ uOf j₀ (c + 2) = n - 1 := by
      rw [hu]
      rcases Nat.eq_or_lt_of_le hu3 with hu3' | hu3'
      · -- `u = n−3`: offset `n−1` (no overflow)
        right
        rw [Nat.mod_eq_of_lt (by omega)]
        omega
      · -- `u = n−2`: offset `n` reduces to 0
        left
        have hu2 : uOf j₀ c = n - 2 := by omega
        rw [hu2, mod_eq_sub_of_lt_two_mul (by omega) (by omega)]
        omega
    have hnot : ¬ Owned j₀ i (c + 2) := by
      intro hO
      have hband := hO.u_band
      omega
    rw [rank_of_not_owned hnot]
    omega

omit [NeZero n] in
/-- Downward reads: any cell of the row above sits strictly below rank
    `t+1+i` — sweep ranks are `≤ t`, lower downward ranks are `t+i`, tube and
    orphan ranks are 0. -/
theorem rank_read_D {j₀ : ZMod n} {i : Fin (t + 1)} {c : ZMod n}
    (h : OwnedD j₀ i c) {i' : Fin (t + 1)} (hi' : i'.val = i.val - 1)
    (c' : ZMod n) : rank j₀ i' c' < rank j₀ i c := by
  have hi1 := h.2.2.1
  rw [rank_of_ownedD h]
  by_cases hR : OwnedR j₀ i' c'
  · rw [rank_of_ownedR hR]
    have h2 := hR.2.1
    have := budgetR_le_t (n := n) (t := t)
    omega
  by_cases hL : OwnedL j₀ i' c'
  · rw [rank_of_ownedL hL]
    have h3 := hL.2.2
    omega
  by_cases hD : OwnedD j₀ i' c'
  · rw [rank_of_ownedD hD, hi']
    omega
  · rw [rank_of_not_owned (by unfold Owned; tauto)]
    omega

/-- **Stratification.** A formula's value depends only on cells of strictly
    smaller rank: if two records agree below `rank (i, c)`, their formulas at
    `(i, c)` agree. (Stated for owned cells; unowned cells have no formula.) -/
theorem formulaValue_congr {j₀ : ZMod n} {i : Fin (t + 1)} {c : ZMod n}
    (hO : Owned j₀ i c) {x y : Fin (t + 1) → Row n}
    (h : ∀ (i' : Fin (t + 1)) (c' : ZMod n),
      rank j₀ i' c' < rank j₀ i c → x i' c' = y i' c') :
    formulaValue j₀ x i c = formulaValue j₀ y i c := by
  rcases hO with hR | hL | hD
  · rw [formulaValue_of_ownedR hR, formulaValue_of_ownedR hR,
      h _ _ (rank_read1_R hR rfl), h _ _ (rank_read2_R hR)]
  · rw [formulaValue_of_ownedL hL, formulaValue_of_ownedL hL,
      h _ _ (rank_read1_L hL rfl), h _ _ (rank_read2_L hL)]
  · rw [formulaValue_of_ownedD hD, formulaValue_of_ownedD hD,
      h _ _ (rank_read_D hD rfl _), h _ _ (rank_read_D hD rfl _)]

end Formula

/-! ## The decode dynamics

Each transaction writes ONE cell to its declared formula value; it is enabled
exactly when the formula disagrees with the cell. The step relation is the
`StepRel` of the T6 vocabulary (`QuotientRepair.lean`). -/

section Dynamics

variable {n : ℕ} [NeZero n] {t : ℕ}

/-- Write a single cell of a record. -/
def writeCell (x : Fin (t + 1) → Row n) (p : Fin (t + 1) × ZMod n)
    (v : ZMod 2) : Fin (t + 1) → Row n :=
  Function.update x p.1 (Function.update (x p.1) p.2 v)

omit [NeZero n] in
theorem writeCell_self (x : Fin (t + 1) → Row n) (p : Fin (t + 1) × ZMod n)
    (v : ZMod 2) : writeCell x p v p.1 p.2 = v := by
  unfold writeCell
  rw [Function.update_self, Function.update_self]

omit [NeZero n] in
theorem writeCell_of_ne (x : Fin (t + 1) → Row n)
    {p q : Fin (t + 1) × ZMod n} (v : ZMod 2) (hne : q ≠ p) :
    writeCell x p v q.1 q.2 = x q.1 q.2 := by
  unfold writeCell
  by_cases h1 : q.1 = p.1
  · have h2 : q.2 ≠ p.2 := by
      intro h2
      exact hne (Prod.ext h1 h2)
    rw [h1, Function.update_self, Function.update_of_ne h2]
  · rw [Function.update_of_ne h1]

/-- One local decode transaction: write the declared formula value into its
    cell. The window is the cell's patch and one edge-adjacent patch. -/
def act (j₀ : ZMod n) (p : Fin (t + 1) × ZMod n)
    (x : Fin (t + 1) → Row n) : Fin (t + 1) → Row n :=
  writeCell x p (formulaValue j₀ x p.1 p.2)

/-- Enabledness: the declared formula disagrees with the cell. (The relaxed
    `H2`: a formula-mismatch trigger rather than an any-broken-edge
    trigger.) -/
def Dom (j₀ : ZMod n) (p : Fin (t + 1) × ZMod n)
    (x : Fin (t + 1) → Row n) : Prop :=
  formulaValue j₀ x p.1 p.2 ≠ x p.1 p.2

instance (j₀ : ZMod n) (p : Fin (t + 1) × ZMod n)
    (x : Fin (t + 1) → Row n) : Decidable (Dom j₀ p x) := by
  unfold Dom; infer_instance

omit [NeZero n] in
/-- Only owned cells can fire. -/
theorem Dom.owned {j₀ : ZMod n} {p : Fin (t + 1) × ZMod n}
    {x : Fin (t + 1) → Row n} (h : Dom j₀ p x) : Owned j₀ p.1 p.2 := by
  by_contra hno
  exact h (formulaValue_of_not_owned hno x)

/-- The decode step relation — the accepted one-step relation `StepRel` of the
    T6 (quotient-repair) vocabulary, instantiated with the decode
    transactions. -/
def DecodeStep (j₀ : ZMod n) :
    (Fin (t + 1) → Row n) → (Fin (t + 1) → Row n) → Prop :=
  StepRel (Dom j₀) (act j₀)

/-- Decode-quiescence: every declared formula is satisfied. -/
def Quiescent (j₀ : ZMod n) (x : Fin (t + 1) → Row n) : Prop :=
  ∀ (i : Fin (t + 1)) (c : ZMod n), formulaValue j₀ x i c = x i c

omit [NeZero n] in
/-- Normal forms of the decode dynamics are exactly the quiescent records. -/
theorem normalForm_iff_quiescent (j₀ : ZMod n) (x : Fin (t + 1) → Row n) :
    Rewriting.NormalForm (DecodeStep j₀) x ↔ Quiescent j₀ x := by
  constructor
  · intro hnf i c
    by_contra hne
    exact hnf (act j₀ (i, c) x) ⟨(i, c), hne, rfl⟩
  · rintro hq y ⟨p, hdom, rfl⟩
    exact hdom (hq p.1 p.2)

/-! ### `H_B`: the tube boundary is preserved by every accepted transaction -/

/-- A firing transaction targets an owned — hence non-tube — cell, so both
    tube columns of every patch are untouched. -/
theorem act_tube {j₀ : ZMod n} {p : Fin (t + 1) × ZMod n}
    {x : Fin (t + 1) → Row n} (hdom : Dom j₀ p x) :
    tubeBoundary (t := t) j₀ (act j₀ p x) = tubeBoundary (t := t) j₀ x := by
  have hnt := hdom.owned.not_isTube
  funext i
  show (act j₀ p x i j₀, act j₀ p x i (j₀ + 1)) = (x i j₀, x i (j₀ + 1))
  have h1 : act j₀ p x i j₀ = x i j₀ := by
    refine writeCell_of_ne (q := (i, j₀)) x _ (fun he => hnt ?_)
    have h2 : j₀ = p.2 := congrArg Prod.snd he
    rw [← h2]
    exact Or.inl rfl
  have h2 : act j₀ p x i (j₀ + 1) = x i (j₀ + 1) := by
    refine writeCell_of_ne (q := (i, j₀ + 1)) x _ (fun he => hnt ?_)
    have h2 : j₀ + 1 = p.2 := congrArg Prod.snd he
    rw [← h2]
    exact Or.inr rfl
  rw [h1, h2]

/-- `H_B`, step form. -/
theorem decodeStep_tube {j₀ : ZMod n} {x y : Fin (t + 1) → Row n}
    (h : DecodeStep j₀ x y) :
    tubeBoundary (t := t) j₀ y = tubeBoundary (t := t) j₀ x := by
  obtain ⟨p, hdom, rfl⟩ := h
  exact act_tube hdom

/-- `H_B`, reduction form. -/
theorem reflTransGen_tube {j₀ : ZMod n} {x y : Fin (t + 1) → Row n}
    (h : Relation.ReflTransGen (DecodeStep j₀) x y) :
    tubeBoundary (t := t) j₀ y = tubeBoundary (t := t) j₀ x := by
  induction h with
  | refl => rfl
  | tail _ hstep ih => rw [decodeStep_tube hstep, ih]

end Dynamics

/-! ## Uniqueness: quiescent records are pinned by their tube reading

The linear trick: formulas commute with subtraction, so the difference of two
quiescent records with equal tube readings is a formula-quiescent record with
zero tube reading, and the stratification kills it rank stratum by rank
stratum. -/

section Uniqueness

variable {n : ℕ} [NeZero n] {t : ℕ}

omit [NeZero n] in
/-- The formulas evaluate to `0` on the zero record. -/
theorem formulaValue_zero (j₀ : ZMod n) (i : Fin (t + 1)) (c : ZMod n) :
    formulaValue j₀ (0 : Fin (t + 1) → Row n) i c = 0 := by
  unfold formulaValue
  split_ifs <;> simp

/-- **Zero-fiber collapse.** A record satisfying all its formulas whose tube
    reading vanishes is the zero record. Strong induction on the rank
    stratification. This is where the threshold `n ≤ 2(t+1)` does its work
    (through `coverage`). -/
theorem quiescentDiff_eq_zero (hn : n ≤ 2 * (t + 1)) {j₀ : ZMod n}
    {d : Fin (t + 1) → Row n}
    (hq : ∀ (i : Fin (t + 1)) (c : ZMod n), Owned j₀ i c →
      d i c = formulaValue j₀ d i c)
    (htube : ∀ i : Fin (t + 1), d i j₀ = 0 ∧ d i (j₀ + 1) = 0) :
    d = 0 := by
  have main : ∀ (r : ℕ) (i : Fin (t + 1)) (c : ZMod n),
      rank j₀ i c = r → d i c = 0 := by
    intro r
    induction r using Nat.strong_induction_on with
    | _ r ih =>
      intro i c hr
      rcases coverage hn j₀ i c with htc | hO
      · rcases htc with rfl | rfl
        · exact (htube i).1
        · exact (htube i).2
      · rw [hq i c hO]
        have hzero : ∀ (i' : Fin (t + 1)) (c' : ZMod n),
            rank j₀ i' c' < rank j₀ i c →
              d i' c' = (0 : Fin (t + 1) → Row n) i' c' := by
          intro i' c' hlt
          have := ih (rank j₀ i' c') (hr ▸ hlt) i' c' rfl
          simpa using this
        rw [formulaValue_congr hO hzero, formulaValue_zero]
  funext i c
  exact main (rank j₀ i c) i c rfl

/-- **Uniqueness of settled worlds per tube fiber**: two quiescent records
    with the same tube reading are equal. -/
theorem quiescent_ext (hn : n ≤ 2 * (t + 1)) {j₀ : ZMod n}
    {x y : Fin (t + 1) → Row n} (hqx : Quiescent j₀ x) (hqy : Quiescent j₀ y)
    (htube : tubeBoundary (t := t) j₀ x = tubeBoundary (t := t) j₀ y) :
    x = y := by
  have hq : ∀ (i : Fin (t + 1)) (c : ZMod n), Owned j₀ i c →
      (x - y) i c = formulaValue j₀ (x - y) i c := by
    intro i c _
    rw [formulaValue_sub]
    show x i c - y i c = _
    rw [hqx i c, hqy i c]
  have htube' : ∀ i : Fin (t + 1), (x - y) i j₀ = 0 ∧ (x - y) i (j₀ + 1) = 0 := by
    intro i
    have hpair := congrFun htube i
    have h1 : x i j₀ = y i j₀ := congrArg Prod.fst hpair
    have h2 : x i (j₀ + 1) = y i (j₀ + 1) := congrArg Prod.snd hpair
    constructor
    · show x i j₀ - y i j₀ = 0
      rw [h1, sub_self]
    · show x i (j₀ + 1) - y i (j₀ + 1) = 0
      rw [h2, sub_self]
  exact sub_eq_zero.mp (quiescentDiff_eq_zero hn hq htube')

end Uniqueness

/-! ## Consistency: the settled world is consistent exactly on realizable
fibers -/

section Consistency

variable {n : ℕ} [NeZero n] {t : ℕ}

/-- Consistent records are quiescent: every declared formula is a rearranged
    CA edge constraint (the sweeps solve it sideways in characteristic 2; the
    downward formula IS the constraint). -/
theorem quiescent_of_consistent {j₀ : ZMod n}
    {x : (rule90Cylinder n t).Records}
    (hx : (rule90Cylinder n t).Consistent x) : Quiescent j₀ x := by
  have hedge : ∀ e : Fin t, evolve (x e.castSucc) = x e.succ :=
    ((rule90Cylinder n t).consistent_iff_edgeConsistent x).mp hx
  intro i c
  by_cases hO : Owned j₀ i c
  swap
  · exact formulaValue_of_not_owned hO x
  have hrow : ∀ (hi : i.val < t),
      x ⟨i.val + 1, by omega⟩ = evolve (x i) := by
    intro hi
    have h := hedge ⟨i.val, hi⟩
    have hcast : (⟨i.val, hi⟩ : Fin t).castSucc = i := by
      apply Fin.ext
      rfl
    have hsucc : (⟨i.val, hi⟩ : Fin t).succ = ⟨i.val + 1, by omega⟩ := by
      apply Fin.ext
      rfl
    rw [hcast, hsucc] at h
    exact h.symm
  rcases hO with hR | hL | hD
  · -- right sweep: `x_{i+1}(c−1) = x_i(c−2) + x_i(c)`, solved for `x_i(c)`
    have h1 := hR.1
    have h3 := hR.2.2
    rw [formulaValue_of_ownedR hR, hrow (by omega)]
    show (x i (c - 1 - 1) + x i (c - 1 + 1)) + x i (c - 2) = x i c
    rw [show c - 1 - 1 = c - 2 from by ring, show c - 1 + 1 = c from by ring]
    exact (by decide : ∀ a b : ZMod 2, (a + b) + a = b) _ _
  · -- left sweep: `x_{i+1}(c+1) = x_i(c) + x_i(c+2)`, solved for `x_i(c)`
    have h1 := hL.1
    have h2 := hL.2.1
    have h3 := hL.2.2
    rw [formulaValue_of_ownedL hL, hrow (by omega)]
    show (x i (c + 1 - 1) + x i (c + 1 + 1)) + x i (c + 2) = x i c
    rw [show c + 1 - 1 = c from by ring, show c + 1 + 1 = c + 2 from by ring]
    exact (by decide : ∀ a b : ZMod 2, (b + a) + a = b) _ _
  · -- downward: the CA constraint verbatim
    have hi1 := hD.2.2.1
    have hit := i.isLt
    have h := hedge ⟨i.val - 1, by omega⟩
    have hsucc : (⟨i.val - 1, by omega⟩ : Fin t).succ = i := by
      apply Fin.ext
      show i.val - 1 + 1 = i.val
      omega
    have hcast : (⟨i.val - 1, by omega⟩ : Fin t).castSucc
        = ⟨i.val - 1, hD.pred_lt⟩ := by
      apply Fin.ext
      rfl
    rw [hsucc, hcast] at h
    rw [formulaValue_of_ownedD hD, ← h]
    rfl

/-- A tube reading is realizable when some consistent record carries it. -/
def RealizableTube (j₀ : ZMod n) (τ : Fin (t + 1) → ZMod 2 × ZMod 2) : Prop :=
  ∃ z : (rule90Cylinder n t).Records,
    (rule90Cylinder n t).Consistent z ∧ tubeBoundary j₀ z = τ

/-- **The stall is logic, not weakness**: on an unrealizable fiber no record
    is consistent, so ANY tube-preserving repair must settle inconsistent
    there — there is nothing consistent to reach. -/
theorem no_consistent_completion_of_unrealizable {j₀ : ZMod n}
    {τ : Fin (t + 1) → ZMod 2 × ZMod 2} (h : ¬ RealizableTube j₀ τ) :
    ∀ z : (rule90Cylinder n t).Records, tubeBoundary j₀ z = τ →
      ¬ (rule90Cylinder n t).Consistent z :=
  fun z hz hc => h ⟨z, hc, hz⟩

end Consistency

/-! ## The pass: the declared schedule reaches a normal form in one sweep

Cells are processed rank stratum by rank stratum. Because every formula reads
strictly below its own rank, once a stratum is written it stays matched
forever — one pass suffices. -/

section Pass

variable {n : ℕ} [NeZero n] {t : ℕ}

/-- Fire a cell's transaction if enabled; else do nothing. -/
def condWrite (j₀ : ZMod n) (x : Fin (t + 1) → Row n)
    (p : Fin (t + 1) × ZMod n) : Fin (t + 1) → Row n :=
  if Dom j₀ p x then act j₀ p x else x

/-- A cell is matched when its formula agrees with it (the negation of
    enabled). -/
def Matched (j₀ : ZMod n) (p : Fin (t + 1) × ZMod n)
    (x : Fin (t + 1) → Row n) : Prop :=
  formulaValue j₀ x p.1 p.2 = x p.1 p.2

omit [NeZero n] in
theorem quiescent_iff_matched (j₀ : ZMod n) (x : Fin (t + 1) → Row n) :
    Quiescent j₀ x ↔ ∀ p : Fin (t + 1) × ZMod n, Matched j₀ p x :=
  ⟨fun h p => h p.1 p.2, fun h i c => h (i, c)⟩

/-- Firing a cell leaves that cell matched: its reads are strictly below its
    rank, so the write does not disturb its own formula. -/
theorem matched_condWrite_self (j₀ : ZMod n) (x : Fin (t + 1) → Row n)
    (p : Fin (t + 1) × ZMod n) : Matched j₀ p (condWrite j₀ x p) := by
  unfold condWrite
  by_cases hdom : Dom j₀ p x
  · rw [if_pos hdom]
    have hO := hdom.owned
    unfold Matched
    have hcongr : formulaValue j₀ (act j₀ p x) p.1 p.2
        = formulaValue j₀ x p.1 p.2 := by
      apply formulaValue_congr hO
      intro i' c' hlt
      refine writeCell_of_ne (q := (i', c')) x _ (fun he => ?_)
      have h1 : i' = p.1 := congrArg Prod.fst he
      have h2 : c' = p.2 := congrArg Prod.snd he
      rw [h1, h2] at hlt
      exact lt_irrefl _ hlt
    rw [hcongr]
    show formulaValue j₀ x p.1 p.2 = act j₀ p x p.1 p.2
    exact (writeCell_self x p _).symm
  · rw [if_neg hdom]
    exact not_ne_iff.mp hdom

/-- Firing a cell preserves matched-ness of every OTHER cell of rank at most
    the fired rank (their reads sit strictly below their own rank, hence
    strictly below the fired cell's rank, hence are untouched). -/
theorem matched_condWrite_of_le (j₀ : ZMod n)
    {q p : Fin (t + 1) × ZMod n} {x : Fin (t + 1) → Row n}
    (hm : Matched j₀ q x) (hle : rank j₀ q.1 q.2 ≤ rank j₀ p.1 p.2)
    (hne : q ≠ p) : Matched j₀ q (condWrite j₀ x p) := by
  unfold condWrite
  by_cases hdom : Dom j₀ p x
  swap
  · rw [if_neg hdom]; exact hm
  rw [if_pos hdom]
  unfold Matched at hm ⊢
  have hval : act j₀ p x q.1 q.2 = x q.1 q.2 :=
    writeCell_of_ne (q := q) x _ hne
  by_cases hO : Owned j₀ q.1 q.2
  · have hcongr : formulaValue j₀ (act j₀ p x) q.1 q.2
        = formulaValue j₀ x q.1 q.2 := by
      apply formulaValue_congr hO
      intro i' c' hlt
      refine writeCell_of_ne (q := (i', c')) x _ (fun he => ?_)
      have h1 : i' = p.1 := congrArg Prod.fst he
      have h2 : c' = p.2 := congrArg Prod.snd he
      rw [h1, h2] at hlt
      omega
    rw [hcongr, hval]
    exact hm
  · rw [formulaValue_of_not_owned hO]

/-- Folding one rank stratum: everything at-or-below the stratum that was
    matched stays matched, everything in the stratum's list becomes
    matched. -/
theorem foldl_level_matched (j₀ : ZMod n) (r : ℕ) :
    ∀ (l : List (Fin (t + 1) × ZMod n)) (x : Fin (t + 1) → Row n),
      (∀ p ∈ l, rank j₀ p.1 p.2 = r) → l.Nodup →
      (∀ q, rank j₀ q.1 q.2 < r → Matched j₀ q x) →
      (∀ q, rank j₀ q.1 q.2 = r → q ∉ l → Matched j₀ q x) →
      ∀ q, rank j₀ q.1 q.2 ≤ r → Matched j₀ q (l.foldl (condWrite j₀) x)
  | [], x, _, _, hlow, hproc, q, hq => by
    rcases Nat.eq_or_lt_of_le hq with he | hl
    · exact hproc q he (List.not_mem_nil)
    · exact hlow q hl
  | p :: tl, x, hranks, hnd, hlow, hproc, q, hq => by
    rw [List.foldl_cons]
    have hrp : rank j₀ p.1 p.2 = r := hranks p List.mem_cons_self
    refine foldl_level_matched j₀ r tl (condWrite j₀ x p)
      (fun p' hp' => hranks p' (List.mem_cons_of_mem p hp'))
      (List.nodup_cons.mp hnd).2 ?_ ?_ q hq
    · intro q' hq'
      refine matched_condWrite_of_le j₀ (hlow q' hq') (by omega)
        (fun he => ?_)
      rw [he] at hq'
      omega
    · intro q' hq' hq'tl
      by_cases heq : q' = p
      · rw [heq]
        exact matched_condWrite_self j₀ x p
      · have hnotl : q' ∉ p :: tl := by
          intro hmem
          rcases List.mem_cons.mp hmem with h | h
          · exact heq h
          · exact hq'tl h
        exact matched_condWrite_of_le j₀ (hproc q' hq' hnotl) (by omega) heq

/-- The declared stratum list: all cells of a given rank. -/
noncomputable def levelList (j₀ : ZMod n) (t : ℕ) (r : ℕ) :
    List (Fin (t + 1) × ZMod n) :=
  (Finset.univ.filter
    (fun p : Fin (t + 1) × ZMod n => rank j₀ p.1 p.2 = r)).toList

theorem mem_levelList {j₀ : ZMod n} {r : ℕ} {p : Fin (t + 1) × ZMod n} :
    p ∈ levelList j₀ t r ↔ rank j₀ p.1 p.2 = r := by
  unfold levelList
  rw [Finset.mem_toList, Finset.mem_filter]
  exact ⟨fun h => h.2, fun h => ⟨Finset.mem_univ p, h⟩⟩

theorem levelList_nodup (j₀ : ZMod n) (r : ℕ) :
    (levelList j₀ t r).Nodup := Finset.nodup_toList _

/-- **The pass**: process every rank stratum in the declared order. This is
    the whole declared schedule — a single finite sweep. -/
noncomputable def pass (j₀ : ZMod n) (x : Fin (t + 1) → Row n) :
    Fin (t + 1) → Row n :=
  (List.range (2 * t + 2)).foldl
    (fun y r => (levelList j₀ t r).foldl (condWrite j₀) y) x

/-- After the pass, every cell is matched. -/
theorem pass_matched (j₀ : ZMod n) (x : Fin (t + 1) → Row n) :
    ∀ q : Fin (t + 1) × ZMod n, Matched j₀ q (pass j₀ x) := by
  suffices H : ∀ (K : ℕ) (x : Fin (t + 1) → Row n)
      (q : Fin (t + 1) × ZMod n), rank j₀ q.1 q.2 < K →
      Matched j₀ q ((List.range K).foldl
        (fun y r => (levelList j₀ t r).foldl (condWrite j₀) y) x) by
    intro q
    exact H (2 * t + 2) x q (rank_lt j₀ q.1 q.2)
  intro K
  induction K with
  | zero =>
    intro x q hq
    omega
  | succ K ih =>
    intro x q hq
    rw [List.range_succ, List.foldl_append, List.foldl_cons, List.foldl_nil]
    rcases Nat.lt_or_ge (rank j₀ q.1 q.2) K with hlt | hge
    · -- already matched before stratum `K`; stays matched through it
      refine foldl_level_matched j₀ K (levelList j₀ t K) _
        (fun p hp => mem_levelList.mp hp) (levelList_nodup j₀ K)
        (fun q' hq' => ih _ q' hq') ?_ q (by omega)
      intro q' hq' hnotin
      exact absurd (mem_levelList.mpr hq') hnotin
    · -- rank exactly `K`: becomes matched during stratum `K`
      have hqK : rank j₀ q.1 q.2 = K := by omega
      refine foldl_level_matched j₀ K (levelList j₀ t K) _
        (fun p hp => mem_levelList.mp hp) (levelList_nodup j₀ K)
        (fun q' hq' => ih _ q' hq') ?_ q (by omega)
      intro q' hq' hnotin
      exact absurd (mem_levelList.mpr hq') hnotin

/-- After the pass, the record is quiescent — a normal form. -/
theorem pass_quiescent (j₀ : ZMod n) (x : Fin (t + 1) → Row n) :
    Quiescent j₀ (pass j₀ x) :=
  (quiescent_iff_matched j₀ _).mpr (pass_matched j₀ x)

omit [NeZero n] in
theorem reflTransGen_condWrite (j₀ : ZMod n) (x : Fin (t + 1) → Row n)
    (p : Fin (t + 1) × ZMod n) :
    Relation.ReflTransGen (DecodeStep j₀) x (condWrite j₀ x p) := by
  unfold condWrite
  by_cases hdom : Dom j₀ p x
  · rw [if_pos hdom]
    exact Relation.ReflTransGen.single ⟨p, hdom, rfl⟩
  · rw [if_neg hdom]

omit [NeZero n] in
theorem reflTransGen_foldl (j₀ : ZMod n) :
    ∀ (l : List (Fin (t + 1) × ZMod n)) (x : Fin (t + 1) → Row n),
      Relation.ReflTransGen (DecodeStep j₀) x (l.foldl (condWrite j₀) x)
  | [], _ => Relation.ReflTransGen.refl
  | p :: tl, x => by
    rw [List.foldl_cons]
    exact (reflTransGen_condWrite j₀ x p).trans (reflTransGen_foldl j₀ tl _)

/-- The pass is an accepted reduction: a particular finite schedule of decode
    transactions. -/
theorem pass_reachable (j₀ : ZMod n) (x : Fin (t + 1) → Row n) :
    Relation.ReflTransGen (DecodeStep j₀) x (pass j₀ x) := by
  unfold pass
  generalize 2 * t + 2 = K
  induction K with
  | zero => exact Relation.ReflTransGen.refl
  | succ K ih =>
    rw [List.range_succ, List.foldl_append, List.foldl_cons, List.foldl_nil]
    exact ih.trans (reflTransGen_foldl j₀ _ _)

/-- **Liveness**: the declared pass reaches a normal form from every
    record. -/
theorem pass_spec (j₀ : ZMod n) (x : Fin (t + 1) → Row n) :
    Relation.ReflTransGen (DecodeStep j₀) x (pass j₀ x) ∧
      Rewriting.NormalForm (DecodeStep j₀) (pass j₀ x) :=
  ⟨pass_reachable j₀ x,
   (normalForm_iff_quiescent j₀ _).mpr (pass_quiescent j₀ x)⟩

end Pass

/-! ## The headline: Route A assembled on one carrier -/

section RouteATheorems

variable {n : ℕ} [NeZero n] {t : ℕ}

/-- **T27a — ROUTE A OBSERVER UNIQUENESS.** On the Rule-90 cylinder at the
    sharp threshold `n ≤ 2(t+1)`: any two records with equal width-2 tube
    reading settle — under ANY decode schedules, to ANY normal forms — to the
    **same** record. Literal equality: stronger than the `gaugeEquiv`
    conclusion of the core's `boundary_fiber_observer_unique`, with no
    realizability hypothesis. The tube pins the settled world outright. -/
theorem routeA_observer_uniqueness (hn : n ≤ 2 * (t + 1)) {j₀ : ZMod n}
    {x y nfx nfy : Fin (t + 1) → Row n}
    (hB : tubeBoundary (t := t) j₀ x = tubeBoundary (t := t) j₀ y)
    (hx : Relation.ReflTransGen (DecodeStep j₀) x nfx)
    (hnfx : Rewriting.NormalForm (DecodeStep j₀) nfx)
    (hy : Relation.ReflTransGen (DecodeStep j₀) y nfy)
    (hnfy : Rewriting.NormalForm (DecodeStep j₀) nfy) :
    nfx = nfy := by
  apply quiescent_ext hn ((normalForm_iff_quiescent j₀ _).mp hnfx)
    ((normalForm_iff_quiescent j₀ _).mp hnfy)
  rw [reflTransGen_tube hx, hB, ← reflTransGen_tube hy]

/-- **T27b — every record settles to a unique world.** Existence by the
    declared pass, uniqueness by the tube pinning. -/
theorem routeA_world_exists_unique (hn : n ≤ 2 * (t + 1)) (j₀ : ZMod n)
    (x : Fin (t + 1) → Row n) :
    ∃! w, Relation.ReflTransGen (DecodeStep j₀) x w ∧
      Rewriting.NormalForm (DecodeStep j₀) w := by
  refine ⟨pass j₀ x, pass_spec j₀ x, ?_⟩
  rintro w ⟨hw, hnw⟩
  exact routeA_observer_uniqueness hn rfl hw hnw
    (pass_spec j₀ x).1 (pass_spec j₀ x).2

/-- **T27c — completeness exactly on realizable fibers.** The settled world
    is consistent **iff** the starting tube reading is realizable. With
    `rule90Cylinder_Hfib_tube` (T9′) the consistent world is THE unique
    consistent record of the fiber. -/
theorem routeA_world_consistent_iff (hn : n ≤ 2 * (t + 1)) {j₀ : ZMod n}
    {x w : Fin (t + 1) → Row n}
    (hw : Relation.ReflTransGen (DecodeStep j₀) x w)
    (hnw : Rewriting.NormalForm (DecodeStep j₀) w) :
    (rule90Cylinder n t).Consistent w
      ↔ RealizableTube j₀ (tubeBoundary (t := t) j₀ x) := by
  constructor
  · intro hc
    exact ⟨w, hc, reflTransGen_tube hw⟩
  · rintro ⟨z, hzc, hz⟩
    have hqz : Quiescent j₀ z := quiescent_of_consistent hzc
    have hqw : Quiescent j₀ w := (normalForm_iff_quiescent j₀ w).mp hnw
    have hwz : w = z :=
      quiescent_ext hn hqw hqz (by rw [reflTransGen_tube hw, ← hz])
    rw [hwz]
    exact hzc

/-- **T27 — ROUTE A ASSEMBLED (the bundle).** On ONE carrier — the Rule-90
    `n`-cylinder with horizon `t`, at the sharp threshold `n ≤ 2(t+1)` — the
    decode dynamics, the boundary preservation, and the sharp redundancy
    boundary hold **jointly**:

    1. liveness — every record settles to a normal form;
    2. `H_B` — every accepted transaction preserves the tube reading;
    3. observer uniqueness — equal tube reading forces the SAME settled world
       under any schedules (Route A's conclusion, in equality form);
    4. completeness on realizable fibers — the settled world is consistent
       iff the fiber is realizable (and stalling elsewhere is forced by
       logic: such fibers contain no consistent record at all);
    5. `H_fib` sharp (T9′, same carrier) — the consistent fiber is a
       singleton.

    The price list: the responsibility roster (budgets, formulas, rank
    schedule) is declared structure, billed exactly like Route B's declared
    order. -/
theorem routeA_assembled (hn : n ≤ 2 * (t + 1)) (j₀ : ZMod n) :
    (∀ x : Fin (t + 1) → Row n,
      ∃ w, Relation.ReflTransGen (DecodeStep j₀) x w ∧
        Rewriting.NormalForm (DecodeStep j₀) w) ∧
    (∀ x y : Fin (t + 1) → Row n, DecodeStep j₀ x y →
      tubeBoundary (t := t) j₀ y = tubeBoundary (t := t) j₀ x) ∧
    (∀ x y nfx nfy : Fin (t + 1) → Row n,
      tubeBoundary (t := t) j₀ x = tubeBoundary (t := t) j₀ y →
      Relation.ReflTransGen (DecodeStep j₀) x nfx →
      Rewriting.NormalForm (DecodeStep j₀) nfx →
      Relation.ReflTransGen (DecodeStep j₀) y nfy →
      Rewriting.NormalForm (DecodeStep j₀) nfy → nfx = nfy) ∧
    (∀ x w : Fin (t + 1) → Row n,
      Relation.ReflTransGen (DecodeStep j₀) x w →
      Rewriting.NormalForm (DecodeStep j₀) w →
      ((rule90Cylinder n t).Consistent w
        ↔ RealizableTube j₀ (tubeBoundary (t := t) j₀ x))) ∧
    (∀ x y : (rule90Cylinder n t).Records,
      tubeBoundary j₀ x = tubeBoundary j₀ y →
      (rule90Cylinder n t).Consistent x → (rule90Cylinder n t).Consistent y →
      x = y) :=
  ⟨fun x => ⟨pass j₀ x, pass_spec j₀ x⟩,
   fun _ _ h => decodeStep_tube h,
   fun _ _ _ _ hB hx hnx hy hny =>
     routeA_observer_uniqueness hn hB hx hnx hy hny,
   fun _ _ hw hnw => routeA_world_consistent_iff hn hw hnw,
   fun x y hB hcx hcy => rule90Cylinder_Hfib_tube j₀ hn x y hB hcx hcy⟩

end RouteATheorems

/-! ## The negatives, machine-checked

The audit (F2) exhibited these "by hand": (i) no `H1 ∧ H2 ∧ H3` single-patch
repair exists on the cylinder carrier, and (ii) the canonical operator of T12
stalls on an inconsistent record of the very carrier whose screen theorem the
chain crowns. Both are now theorems. They are stated on `rule90CylinderOPH`,
the same carrier re-declared as an `OPH.OPHCarrier`, so the Core's
canonical-operator vocabulary applies verbatim. -/

section Negatives

/-- The cylinder carrier as an `OPH.OPHCarrier` (fields identical to
    `OPHProofChain.rule90Cylinder`; records of both are literally
    `Fin (t+1) → Row n`). Reducible so that numerals and instances on
    `Patch`/`State` resolve through the projections. -/
@[reducible] def rule90CylinderOPH (n t : ℕ) [NeZero n] : OPH.OPHCarrier where
  Patch := Fin (t + 1)
  State := fun _ => Row n
  Edge := Fin t
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

variable {n : ℕ} [NeZero n]

/-- Every Rule-90 image row has even weight: its cells sum to zero (each seed
    cell is counted twice, and we are in characteristic 2). -/
theorem sum_evolve (x : Row n) : (∑ j : ZMod n, evolve x j) = 0 := by
  have h1 : (∑ j : ZMod n, x (j - 1)) = ∑ j : ZMod n, x j :=
    Fintype.sum_equiv (Equiv.subRight 1) _ _ (fun j => rfl)
  have h2 : (∑ j : ZMod n, x (j + 1)) = ∑ j : ZMod n, x j :=
    Fintype.sum_equiv (Equiv.addRight 1) _ _ (fun j => rfl)
  calc (∑ j : ZMod n, evolve x j)
      = ∑ j : ZMod n, (x (j - 1) + x (j + 1)) := rfl
    _ = (∑ j : ZMod n, x (j - 1)) + ∑ j : ZMod n, x (j + 1) :=
        Finset.sum_add_distrib
    _ = (∑ j : ZMod n, x j) + ∑ j : ZMod n, x j := by rw [h1, h2]
    _ = 0 := CharTwo.add_self_eq_zero _

/-- `δ₀` has odd weight, hence is not a Rule-90 image — on EVERY cylinder. -/
theorem delta_not_evolve (s : Row n) : evolve s ≠ delta 0 := by
  intro h
  have hone : (∑ j : ZMod n, delta (0 : ZMod n) j) = 1 := by
    show (∑ j : ZMod n, if j = (0 : ZMod n) then (1 : ZMod 2) else 0) = 1
    rw [Finset.sum_ite_eq' Finset.univ (0 : ZMod n) (fun _ => (1 : ZMod 2)),
      if_pos (Finset.mem_univ _)]
  rw [← h, sum_evolve] at hone
  exact zero_ne_one hone

/-- **No frustration-free local repair exists on the cylinder carrier**, for
    every `n ≥ 1` and every horizon `t ≥ 1` — the `H1 ∧ H2 ∧ H3` binder forms
    of the Core's `LocalRepairDynamics`, refuted. (The audit's
    "checkable by hand" general claim, machine-checked.) A record whose row 1
    is `δ₀` has its first edge broken for EVERY seed row (`δ₀` is outside the
    image of `evolve`); `H2` then forces the seed patch to fire, `H1` pins
    row 1, and `H3` demands the impossible preimage. -/
theorem rule90CylinderOPH_no_frustrationFree_repair (n t : ℕ) [NeZero n]
    (ht : 1 ≤ t) :
    ¬ ∃ lr : (rule90CylinderOPH n t).Patch →
        OPH.Records (rule90CylinderOPH n t) →
        OPH.Records (rule90CylinderOPH n t),
      (∀ (i : (rule90CylinderOPH n t).Patch)
          (x : OPH.Records (rule90CylinderOPH n t))
          (j : (rule90CylinderOPH n t).Patch), j ≠ i → (lr i x) j = x j) ∧
      (∀ (i : (rule90CylinderOPH n t).Patch)
          (x : OPH.Records (rule90CylinderOPH n t)),
          lr i x ≠ x ↔
            ∃ e : (rule90CylinderOPH n t).Edge,
              ((rule90CylinderOPH n t).src e = i ∨
                (rule90CylinderOPH n t).tgt e = i) ∧
                ¬ OPH.edgeConsistentAt e x) ∧
      (∀ (i : (rule90CylinderOPH n t).Patch)
          (x : OPH.Records (rule90CylinderOPH n t)),
          lr i x ≠ x →
            ∀ e : (rule90CylinderOPH n t).Edge,
              ((rule90CylinderOPH n t).src e = i ∨
                (rule90CylinderOPH n t).tgt e = i) →
                OPH.edgeConsistentAt e (lr i x)) := by
  rintro ⟨lr, H1, H2, H3⟩
  -- the record: row 1 = δ₀, every other row 0
  set x : OPH.Records (rule90CylinderOPH n t) :=
    (fun i => if i.val = 1 then delta 0 else 0) with hx
  have he0 : (0 : ℕ) < t := ht
  set e0 : (rule90CylinderOPH n t).Edge := ⟨0, he0⟩ with he0def
  set p0 : (rule90CylinderOPH n t).Patch := ⟨0, Nat.succ_pos t⟩ with hp0
  have hsrc : (rule90CylinderOPH n t).src e0 = p0 := by
    apply Fin.ext
    rfl
  -- row 1 of `x` is `δ₀`
  have hx1 : x ((rule90CylinderOPH n t).tgt e0) = delta 0 := by
    show (if ((rule90CylinderOPH n t).tgt e0).val = 1 then delta 0 else 0)
      = delta 0
    rw [if_pos (show ((rule90CylinderOPH n t).tgt e0).val = 1 from rfl)]
  -- the first edge is broken at every record whose row 1 is `δ₀`
  have hbroken : ∀ y : OPH.Records (rule90CylinderOPH n t),
      y ((rule90CylinderOPH n t).tgt e0) = delta 0 →
      ¬ OPH.edgeConsistentAt e0 y := by
    intro y hy1 hcons
    have h : evolve (y ((rule90CylinderOPH n t).src e0)) = delta 0 := by
      have h' : evolve (y ((rule90CylinderOPH n t).src e0))
          = y ((rule90CylinderOPH n t).tgt e0) := hcons
      rw [hy1] at h'
      exact h'
    exact delta_not_evolve _ h
  -- H2 forces the seed patch to fire
  have hfire : lr p0 x ≠ x :=
    (H2 p0 x).mpr ⟨e0, Or.inl hsrc, hbroken x hx1⟩
  -- H1 pins row 1 of the repaired record (`tgt e0 ≠ p0` since `1 ≠ 0`)
  have hpin : (lr p0 x) ((rule90CylinderOPH n t).tgt e0) = delta 0 := by
    rw [H1 p0 x _ (fun h => by
      have := congrArg Fin.val h
      exact absurd this one_ne_zero), hx1]
  -- H3 demands the first edge consistent after firing — impossible
  exact hbroken _ hpin (H3 p0 x hfire e0 (Or.inl hsrc))

/-! ### The canonical operator's stall — the audit's `n = 3, t = 2` witness -/

/-- The audit's record: rows `(0, δ₀, δ₁)` on the `3`-cylinder with horizon
    `t = 2`. -/
def stallRecord : OPH.Records (rule90CylinderOPH 3 2) :=
  fun i => if i.val = 1 then delta 0 else if i.val = 2 then delta 1 else 0

/-- Where the canonical repair stalls: rows `(0, δ₀, evolve δ₀)` — edge 1
    fixed, edge 0 broken forever. -/
def stalledRecord : OPH.Records (rule90CylinderOPH 3 2) :=
  fun i => if i.val = 1 then delta 0
    else if i.val = 2 then evolve (delta 0) else 0

/-- Patch 0 can never satisfy its interface at a record whose row 1 is `δ₀`:
    a local fix would be a Rule-90 preimage of `δ₀`. -/
theorem not_canFix_zero (y : OPH.Records (rule90CylinderOPH 3 2))
    (hy : y 1 = delta 0) :
    ¬ OPH.CanFix (C := rule90CylinderOPH 3 2) 0 y := by
  rintro ⟨s, hs⟩
  have h := hs (0 : Fin 2) (Or.inl rfl)
  have h' : evolve ((Function.update y 0 s) 0) = (Function.update y 0 s) 1 :=
    h
  rw [Function.update_self, Function.update_of_ne (by decide), hy] at h'
  exact delta_not_evolve s h'

/-- The only local fix of patch 2 is the CA image of row 1. -/
theorem isLocalFix_two_unique (y : OPH.Records (rule90CylinderOPH 3 2))
    (s : Row 3) (hs : OPH.IsLocalFix (C := rule90CylinderOPH 3 2) 2 y s) :
    s = evolve (y 1) := by
  have h := hs (1 : Fin 2) (Or.inr rfl)
  have h' : evolve ((Function.update y 2 s) 1) = (Function.update y 2 s) 2 :=
    h
  rw [Function.update_self, Function.update_of_ne (by decide)] at h'
  exact h'.symm

/-- Patch 1 cannot fix both its interfaces at either the stall record or the
    stalled record: edge 0 forces `s = evolve(row 0) = 0`, and edge 1 then
    demands `row 2 = evolve 0 = 0`, but row 2 is nonzero in both records. -/
theorem not_canFix_one (y : OPH.Records (rule90CylinderOPH 3 2))
    (hy0 : y 0 = 0) (hy2 : y 2 ≠ 0) :
    ¬ OPH.CanFix (C := rule90CylinderOPH 3 2) 1 y := by
  rintro ⟨s, hs⟩
  have h0 := hs (0 : Fin 2) (Or.inr rfl)
  have h0' : evolve ((Function.update y 1 s) 0) = (Function.update y 1 s) 1 :=
    h0
  rw [Function.update_self, Function.update_of_ne (by decide), hy0,
    evolve_zero] at h0'
  have h1 := hs (1 : Fin 2) (Or.inl rfl)
  have h1' : evolve ((Function.update y 1 s) 1) = (Function.update y 1 s) 2 :=
    h1
  rw [Function.update_self, Function.update_of_ne (by decide), ← h0',
    evolve_zero] at h1'
  exact hy2 h1'.symm

/-- Patch 2 SHOULD fire at the stall record: its edge is broken
    (`evolve δ₀ ≠ δ₁`) and it can satisfy its single interface. -/
theorem shouldFire_two_stall :
    OPH.ShouldFire (C := rule90CylinderOPH 3 2) 2 stallRecord := by
  constructor
  · refine ⟨(1 : Fin 2), Or.inr rfl, ?_⟩
    intro hcons
    have h : evolve (stallRecord 1) = stallRecord 2 := hcons
    have h' : evolve (delta 0) = delta 1 := h
    exact absurd h' (by decide)
  · refine ⟨evolve (delta 0), ?_⟩
    intro e he
    rcases e with ⟨ev, hev⟩
    interval_cases ev
    · -- edge 0 is not incident to patch 2
      rcases he with h | h
      · exact absurd (show (0 : ℕ) = 2 from congrArg Fin.val h) (by omega)
      · exact absurd (show (1 : ℕ) = 2 from congrArg Fin.val h) (by omega)
    · -- edge 1: consistent after the update
      show evolve ((Function.update stallRecord 2 (evolve (delta 0))) 1)
        = (Function.update stallRecord 2 (evolve (delta 0))) 2
      rw [Function.update_self, Function.update_of_ne (by decide)]
      rfl

/-- Nothing should fire at either record on patches 0/1, and at the stalled
    record nothing fires anywhere: it is quiescent with edge 0 broken. -/
theorem stalled_no_fire :
    ¬ (OPH.firingSites (C := rule90CylinderOPH 3 2) stalledRecord).Nonempty := by
  rintro ⟨i, hi⟩
  rw [OPH.mem_firingSites] at hi
  rcases i with ⟨iv, hiv⟩
  interval_cases iv
  · exact not_canFix_zero stalledRecord (by rw [show stalledRecord 1 = delta 0 from rfl]) hi.canFix
  · refine not_canFix_one stalledRecord rfl ?_ hi.canFix
    intro h
    have h' : evolve (delta 0) = (0 : Row 3) := h
    exact absurd h' (by decide)
  · obtain ⟨e, he, hbrk⟩ := hi.hasBroken
    rcases e with ⟨ev, hev⟩
    interval_cases ev
    · rcases he with h | h
      · exact absurd (show (0 : ℕ) = 2 from congrArg Fin.val h) (by omega)
      · exact absurd (show (1 : ℕ) = 2 from congrArg Fin.val h) (by omega)
    · exact hbrk rfl

/-- **THE STALL, MACHINE-CHECKED (the audit's F2 witness).** On the
    `n = 3, t = 2` cylinder — the flagship carrier's smallest instance — the
    canonical operator of T12, started from the audit's record `(0, δ₀, δ₁)`,
    terminates after exactly one accepted move at `(0, δ₀, evolve δ₀)`:
    a normal form that is NOT consistent. Repair terminates in disagreement;
    edge 0 is broken forever. (See `stallRecord_tube_unrealizable` for why no
    tube-preserving repair could have done better on this fiber.) -/
theorem canonical_repair_stalls :
    OPH.Repair (rule90CylinderOPH 3 2) stallRecord = stalledRecord ∧
    OPH.NormalForm (rule90CylinderOPH 3 2) stalledRecord ∧
    ¬ OPH.Consistent (rule90CylinderOPH 3 2) stalledRecord := by
  -- only patch 2 fires at the stall record
  have honly : ∀ i : (rule90CylinderOPH 3 2).Patch,
      OPH.ShouldFire (C := rule90CylinderOPH 3 2) i stallRecord → i = 2 := by
    intro i hsf
    rcases i with ⟨iv, hiv⟩
    interval_cases iv
    · exact absurd hsf.canFix (not_canFix_zero stallRecord rfl)
    · refine absurd hsf.canFix (not_canFix_one stallRecord rfl ?_)
      intro h
      have h' : delta (1 : ZMod 3) = (0 : Row 3) := h
      exact absurd h' (by decide)
    · rfl
  have hne : (OPH.firingSites (C := rule90CylinderOPH 3 2)
      stallRecord).Nonempty :=
    ⟨2, OPH.mem_firingSites.mpr shouldFire_two_stall⟩
  have hleast : OPH.leastFiringSite stallRecord hne = 2 :=
    honly _ (OPH.leastFiringSite_shouldFire stallRecord hne)
  -- the accepted move: patch 2 snaps to the unique local fix `evolve δ₀`
  have hstep : OPH.localRepair (rule90CylinderOPH 3 2) (2 : Fin 3) stallRecord
      = stalledRecord := by
    rw [OPH.localRepair_of_shouldFire (rule90CylinderOPH 3 2)
      shouldFire_two_stall]
    have hch : shouldFire_two_stall.canFix.choose = evolve (delta 0) := by
      have := OPH.localRepair_choose_isLocalFix (rule90CylinderOPH 3 2)
        shouldFire_two_stall
      have h := isLocalFix_two_unique stallRecord _ this
      rw [h]
      rfl
    rw [hch]
    funext i
    by_cases h2 : i = (2 : Fin 3)
    · rw [h2, Function.update_self]
      rfl
    · rw [Function.update_of_ne h2]
      have hv2 : i.val ≠ 2 := fun hv => h2 (Fin.ext hv)
      show (if i.val = 1 then delta 0 else if i.val = 2 then delta 1 else 0)
        = (if i.val = 1 then delta 0
            else if i.val = 2 then evolve (delta 0) else 0)
      by_cases hv1 : i.val = 1
      · rw [if_pos hv1, if_pos hv1]
      · rw [if_neg hv1, if_neg hv1, if_neg hv2, if_neg hv2]
  have hrep : OPH.Repair (rule90CylinderOPH 3 2) stallRecord
      = stalledRecord := by
    rw [OPH.Repair_of_fire (rule90CylinderOPH 3 2) hne, hleast, hstep,
      OPH.Repair_of_no_fire (rule90CylinderOPH 3 2) stalled_no_fire]
  refine ⟨hrep, ?_, ?_⟩
  · have := OPH.Repair_normalForm (rule90CylinderOPH 3 2) stallRecord
    rwa [hrep] at this
  · intro hc
    have hedge := ((OPH.consistent_iff_edgeConsistent
      (rule90CylinderOPH 3 2) stalledRecord).mp hc) (0 : Fin 2)
    have h : evolve (stalledRecord 0) = stalledRecord 1 := hedge
    have h' : evolve (0 : Row 3) = delta 0 := h
    exact delta_not_evolve _ (by rwa [evolve_zero] at h')

/-- **The stall was forced by logic**: the audit record's tube reading
    (columns `{0, 1}` of `(0, δ₀, δ₁)`) is carried by NO consistent record —
    the fiber is empty, so ANY tube-preserving repair must settle inconsistent
    there. (The tube forces `s₂ = 1` through row 1 cell 0 and `s₂ = 0` through
    row 1 cell 1.) -/
theorem stallRecord_tube_unrealizable :
    ¬ RealizableTube (n := 3) (t := 2) (0 : ZMod 3)
      (tubeBoundary (t := 2) (0 : ZMod 3) stallRecord) := by
  rintro ⟨z, hzc, hz⟩
  have hcontra : ∀ s : Row 3,
      ¬ (s 0 = 0 ∧ s 1 = 0 ∧ evolve s 0 = 1 ∧ evolve s 1 = 0) := by decide
  have htraj := consistent_record_is_traj (n := 3) (t := 2) hzc
  set s : Row 3 := z ⟨0, by omega⟩ with hs
  have h0 := congrFun hz ⟨0, by omega⟩
  have h1 := congrFun hz ⟨1, by omega⟩
  have h00 : z ⟨0, by omega⟩ (0 : ZMod 3) = 0 := congrArg Prod.fst h0
  have h01 : z ⟨0, by omega⟩ (1 : ZMod 3) = 0 := congrArg Prod.snd h0
  have h10 : z ⟨1, by omega⟩ (0 : ZMod 3) = 1 := congrArg Prod.fst h1
  have h11 : z ⟨1, by omega⟩ (1 : ZMod 3) = 0 := congrArg Prod.snd h1
  have hrow1 : z ⟨1, by omega⟩ = evolve s := htraj ⟨1, by omega⟩
  refine hcontra s ⟨h00, h01, ?_, ?_⟩
  · rw [← hrow1]
    exact h10
  · rw [← hrow1]
    exact h11

end Negatives

/-! ## [formal-v8] T31 corollaries — the fiber trichotomy in Route-A
vocabulary

`Rule90Readout.lean` proves the seed-level trichotomy (surjective ⟺
`2(t+1) ≤ n`, bijective ⟺ `n = 2(t+1)`). Here it lands on `RealizableTube`:
unrealizable tube readings — the fibers where T27's stall dichotomy has
content — exist **exactly** below the sharp threshold, and at the threshold
itself every settled world is consistent (nothing to stall on: the screen
reading carries zero redundancy, so every reading names a world). -/

section FiberTrichotomy

variable {n : ℕ} [NeZero n] {t : ℕ}

/-- The trajectory record of any seed is consistent. -/
theorem traj_record_consistent (z : Row n) :
    (rule90Cylinder n t).Consistent (fun i : Fin (t + 1) => traj z i.val) := by
  rw [(rule90Cylinder n t).consistent_iff_edgeConsistent]
  intro e
  show evolve (traj z e.castSucc.val) = traj z e.succ.val
  rw [Fin.val_castSucc, Fin.val_succ]
  exact (traj_succ z e.val).symm

/-- A tube reading is realizable iff it lies in the range of the seed
    readout `tubeData`. -/
theorem realizableTube_iff_range {j₀ : ZMod n}
    {τ : Fin (t + 1) → ZMod 2 × ZMod 2} :
    RealizableTube j₀ τ ↔ ∃ z : Row n, tubeData j₀ t z = τ := by
  constructor
  · rintro ⟨x, hxc, hxt⟩
    refine ⟨x ⟨0, Nat.succ_pos t⟩, ?_⟩
    have htraj := consistent_record_is_traj hxc
    funext i
    have hτ : tubeBoundary (t := t) j₀ x i = τ i := congrFun hxt i
    rw [← hτ]
    show (traj (x ⟨0, Nat.succ_pos t⟩) i.val j₀,
          traj (x ⟨0, Nat.succ_pos t⟩) i.val (j₀ + 1)) = (x i j₀, x i (j₀ + 1))
    rw [← htraj i]
  · rintro ⟨z, hz⟩
    refine ⟨fun i => traj z i.val, traj_record_consistent z, ?_⟩
    funext i
    rw [← hz]
    rfl

/-- Above and at the screen width every tube reading is realizable: the
    ghost regime has no empty fibers. -/
theorem all_tubes_realizable (hn : 2 * (t + 1) ≤ n) (j₀ : ZMod n)
    (τ : Fin (t + 1) → ZMod 2 × ZMod 2) : RealizableTube j₀ τ :=
  realizableTube_iff_range.mpr (tubeData_surjective_of_le hn τ)

/-- **Unrealizable tube readings exist ⟺ `n < 2(t+1)`** — T27.4's stall
    regime is exactly the strict-inequality side of the jewel's threshold.
    (The audit's stall witness `n = 3, t = 2` sits here: `2⁶ − 2³` of its
    64 readings are carried by no world.) -/
theorem exists_unrealizable_tube_iff (j₀ : ZMod n) :
    (∃ τ : Fin (t + 1) → ZMod 2 × ZMod 2, ¬ RealizableTube j₀ τ)
      ↔ n < 2 * (t + 1) := by
  constructor
  · rintro ⟨τ, hτ⟩
    by_contra hn
    rw [not_lt] at hn
    exact hτ (all_tubes_realizable hn j₀ τ)
  · intro hn
    have h3 := (readout_trichotomy (n := n) j₀ t).2.2 hn
    obtain ⟨_, τ, hτ⟩ := h3
    refine ⟨τ, fun hr => ?_⟩
    obtain ⟨z, hz⟩ := realizableTube_iff_range.mp hr
    exact hτ z hz

/-- **The bijective corner: no stall at the exact threshold.** When
    `n = 2(t+1)` the readout is a bijection, every fiber is realizable, and
    every settled world of the decode dynamics is consistent — the stall
    dichotomy of T27.4 is vacuous there, because the screen reading has zero
    redundancy left to be wrong with. -/
theorem no_stall_at_threshold (hn : n = 2 * (t + 1)) {j₀ : ZMod n}
    {x w : Fin (t + 1) → Row n}
    (hw : Relation.ReflTransGen (DecodeStep j₀) x w)
    (hnw : Rewriting.NormalForm (DecodeStep j₀) w) :
    (rule90Cylinder n t).Consistent w := by
  rw [routeA_world_consistent_iff (by omega) hw hnw]
  exact all_tubes_realizable (by omega) j₀ _

end FiberTrichotomy

/-! ## [formal-v8] T32 — EVERY decode schedule terminates

T27 proved liveness for the declared rank schedule (`pass_spec`) and
uniqueness for every *terminating* schedule; arbitrary-schedule termination
was the module's named honest leftover. It closes here: the decode dynamics
is **strongly normalizing** — no infinite run exists under any scheduler,
fair or adversarial.

The potential is the stratification itself, read as a measure: count the
mismatched cells in each rank stratum and order the count vectors
lexicographically (lower strata more significant). A transaction at rank
`ρ` (i) satisfies its own cell — the formula reads strictly below `ρ` and
the write does not touch those reads; (ii) leaves every stratum `≤ ρ`
untouched elsewhere — values and formula reads there never see the written
cell; (iii) may break only strata `> ρ`. So every accepted transaction
strictly decreases the vector in lex order, and `Lex (Fin (2t+2) → ℕ)` is
well-founded. With `routeA_observer_uniqueness`, every schedule now
terminates *and* lands on the one record the tube pins — the roster is
needed to *name* a repair, not to make repair terminate. -/

section UniversalTermination

variable {n : ℕ} [NeZero n] {t : ℕ}

/-- Mismatch count of a rank stratum. -/
def misCount (j₀ : ZMod n) (x : Fin (t + 1) → Row n) (ρ : ℕ) : ℕ :=
  (Finset.univ.filter fun p : Fin (t + 1) × ZMod n =>
    rank j₀ p.1 p.2 = ρ ∧ Dom j₀ p x).card

/-- A transaction fixes its own cell: after `act` at `p`, the formula at
    `p` is satisfied. -/
theorem not_dom_act_self {j₀ : ZMod n} {p : Fin (t + 1) × ZMod n}
    {x : Fin (t + 1) → Row n} (hdom : Dom j₀ p x) :
    ¬ Dom j₀ p (act j₀ p x) := by
  have hO := hdom.owned
  have hval : act j₀ p x p.1 p.2 = formulaValue j₀ x p.1 p.2 :=
    writeCell_self x p _
  have hfv : formulaValue j₀ (act j₀ p x) p.1 p.2
      = formulaValue j₀ x p.1 p.2 := by
    refine formulaValue_congr hO ?_
    intro i' c' hlt
    refine writeCell_of_ne (q := (i', c')) x _ ?_
    intro he
    rw [← he] at hlt
    exact lt_irrefl _ hlt
  unfold Dom
  rw [hfv, hval]
  exact fun h => h rfl

/-- Strata at or below the firing rank are untouched away from the firing
    cell: mismatch status is preserved. -/
theorem dom_act_iff_of_rank_le {j₀ : ZMod n} {p q : Fin (t + 1) × ZMod n}
    {x : Fin (t + 1) → Row n} (hne : q ≠ p)
    (hrk : rank j₀ q.1 q.2 ≤ rank j₀ p.1 p.2) :
    Dom j₀ q (act j₀ p x) ↔ Dom j₀ q x := by
  by_cases hO : Owned j₀ q.1 q.2
  · have hval : act j₀ p x q.1 q.2 = x q.1 q.2 := writeCell_of_ne x _ hne
    have hfv : formulaValue j₀ (act j₀ p x) q.1 q.2
        = formulaValue j₀ x q.1 q.2 := by
      refine formulaValue_congr hO ?_
      intro i' c' hlt
      refine writeCell_of_ne (q := (i', c')) x _ ?_
      intro he
      rw [← he] at hrk
      exact absurd (lt_of_lt_of_le hlt hrk) (lt_irrefl _)
    unfold Dom
    rw [hfv, hval]
  · constructor
    · intro hd
      exact absurd hd.owned hO
    · intro hd
      exact absurd hd.owned hO

/-- Strictly lower strata have exactly the same mismatch count after a
    transaction. -/
theorem misCount_act_of_lt {j₀ : ZMod n} {p : Fin (t + 1) × ZMod n}
    {x : Fin (t + 1) → Row n} {σ : ℕ}
    (hσ : σ < rank j₀ p.1 p.2) :
    misCount j₀ (act j₀ p x) σ = misCount j₀ x σ := by
  unfold misCount
  congr 1
  refine Finset.filter_congr ?_
  intro q _
  by_cases hq : rank j₀ q.1 q.2 = σ
  · have hne : q ≠ p := by
      intro he
      rw [he] at hq
      omega
    rw [dom_act_iff_of_rank_le hne (by omega)]
  · constructor
    · rintro ⟨h, _⟩
      exact absurd h hq
    · rintro ⟨h, _⟩
      exact absurd h hq

/-- The firing stratum strictly shrinks. -/
theorem misCount_act_lt {j₀ : ZMod n} {p : Fin (t + 1) × ZMod n}
    {x : Fin (t + 1) → Row n} (hdom : Dom j₀ p x) :
    misCount j₀ (act j₀ p x) (rank j₀ p.1 p.2)
      < misCount j₀ x (rank j₀ p.1 p.2) := by
  apply Finset.card_lt_card
  rw [Finset.ssubset_def]
  constructor
  · intro q hq
    rw [Finset.mem_filter] at hq ⊢
    obtain ⟨hu, hrk, hdy⟩ := hq
    have hne : q ≠ p := by
      intro he
      rw [he] at hdy
      exact not_dom_act_self hdom hdy
    exact ⟨hu, hrk, (dom_act_iff_of_rank_le hne (le_of_eq hrk)).mp hdy⟩
  · intro hsub
    have hpx : p ∈ Finset.univ.filter fun q : Fin (t + 1) × ZMod n =>
        rank j₀ q.1 q.2 = rank j₀ p.1 p.2 ∧ Dom j₀ q x :=
      Finset.mem_filter.mpr ⟨Finset.mem_univ _, rfl, hdom⟩
    have hpy := hsub hpx
    rw [Finset.mem_filter] at hpy
    exact not_dom_act_self hdom hpy.2.2

/-- The lexicographic stratum-count measure. -/
def misMeasure (j₀ : ZMod n) (x : Fin (t + 1) → Row n) :
    Lex (Fin (2 * t + 2) → ℕ) :=
  toLex fun ρ : Fin (2 * t + 2) => misCount j₀ x ρ.val

/-- Every accepted transaction strictly decreases the measure. -/
theorem misMeasure_decreases {j₀ : ZMod n} {x y : Fin (t + 1) → Row n}
    (h : DecodeStep j₀ x y) : misMeasure j₀ y < misMeasure j₀ x := by
  obtain ⟨p, hdom, rfl⟩ := h
  have hrk := rank_lt j₀ p.1 p.2
  refine ⟨⟨rank j₀ p.1 p.2, hrk⟩, ?_, ?_⟩
  · intro j hj
    exact misCount_act_of_lt hj
  · exact misCount_act_lt hdom

/-- **T32 — STRONG NORMALIZATION.** The decode dynamics terminates from
    every record under EVERY schedule: the step relation (read backwards)
    is well-founded. -/
theorem decodeStep_wellFounded (j₀ : ZMod n) :
    WellFounded (fun y x : Fin (t + 1) → Row n => DecodeStep j₀ x y) := by
  have hwf : WellFounded
      ((· < ·) : Lex (Fin (2 * t + 2) → ℕ) → Lex (Fin (2 * t + 2) → ℕ) → Prop) :=
    IsWellFounded.wf
  refine Subrelation.wf ?_ (InvImage.wf (misMeasure j₀) hwf)
  intro y x h
  exact misMeasure_decreases h

/-- No infinite decode run exists — the schedule-shaped reading of T32. -/
theorem no_infinite_decode_run (j₀ : ZMod n)
    (f : ℕ → Fin (t + 1) → Row n)
    (hf : ∀ k, DecodeStep j₀ (f k) (f (k + 1))) : False := by
  suffices H : ∀ x, Acc (fun y x => DecodeStep j₀ x y) x → ∀ k, f k ≠ x by
    exact H (f 0) ((decodeStep_wellFounded j₀).apply (f 0)) 0 rfl
  intro x hacc
  induction hacc with
  | intro x _ ih =>
    intro k hk
    exact ih (f (k + 1)) (hk ▸ hf k) (k + 1) rfl

/-- Every partial run extends to a normal form — no schedule can strand a
    record short of settlement. -/
theorem exists_normalForm_extension (j₀ : ZMod n)
    (x : Fin (t + 1) → Row n) :
    ∃ w, Relation.ReflTransGen (DecodeStep j₀) x w ∧
      Rewriting.NormalForm (DecodeStep j₀) w := by
  induction x using WellFounded.induction (decodeStep_wellFounded j₀) with
  | _ x ih =>
    by_cases h : ∃ y, DecodeStep j₀ x y
    · obtain ⟨y, hy⟩ := h
      obtain ⟨w, hw, hnw⟩ := ih y hy
      exact ⟨w, .head hy hw, hnw⟩
    · exact ⟨x, .refl, fun y hy => h ⟨y, hy⟩⟩

/-- **T32 + T27a — universal settlement.** At the sharp threshold: every
    schedule terminates, every maximal run from `x` ends in a normal form,
    and ALL of them end at the SAME record — the one the tube pins. The
    responsibility roster is needed to *name* a canonical repair, not to
    make repair terminate. -/
theorem routeA_universal_settlement (hn : n ≤ 2 * (t + 1)) (j₀ : ZMod n)
    (x : Fin (t + 1) → Row n) :
    (∀ f : ℕ → Fin (t + 1) → Row n,
      ¬ ∀ k, DecodeStep j₀ (f k) (f (k + 1))) ∧
    ∃! w, Relation.ReflTransGen (DecodeStep j₀) x w ∧
      Rewriting.NormalForm (DecodeStep j₀) w :=
  ⟨fun f hf => no_infinite_decode_run j₀ f hf,
   routeA_world_exists_unique hn j₀ x⟩

end UniversalTermination

/-! ### Axiom audit — every theorem depends only on the standard axioms -/
#print axioms routeA_assembled
#print axioms routeA_observer_uniqueness
#print axioms routeA_world_exists_unique
#print axioms routeA_world_consistent_iff
#print axioms pass_spec
#print axioms quiescent_ext
#print axioms quiescent_of_consistent
#print axioms no_consistent_completion_of_unrealizable
#print axioms coverage
#print axioms rule90CylinderOPH_no_frustrationFree_repair
#print axioms canonical_repair_stalls
#print axioms stallRecord_tube_unrealizable
#print axioms realizableTube_iff_range
#print axioms all_tubes_realizable
#print axioms exists_unrealizable_tube_iff
#print axioms no_stall_at_threshold
#print axioms decodeStep_wellFounded
#print axioms no_infinite_decode_run
#print axioms exists_normalForm_extension
#print axioms routeA_universal_settlement

end OPHProofChain.RouteA
