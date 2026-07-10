import Mathlib
import OPHProofChain.Rule90Parity

/-!
# T40/T41 [formal-v10] — the lone diagonal observer

**Provenance.** chi_nu_test original (formal-v10 campaign). Discovered by the
v10 probes (F4): the Rule-60 bridge of `Rule90Parity` turns a *lightlike
diagonal* readout into an evaluation of even Rule-60 iterates at a **fixed
point** — `traj z i (j₀ + i) = rule60^[2i] z j₀` — and that question has an
elementary triangular answer.

## The theorems

* **T40 (odd rings): the perfect screen.** A single lightlike diagonal
  `{(i, j₀ + i) : i ≤ t}` — **one cell per row**, `t + 1` cells in total — is
  an information set on an odd cylinder **iff `n ≤ t + 1`**
  (`diagScreen_isInformationSet_iff_odd`). At `t + 1 = n` this meets the
  universal counting bound *exactly*: every known information-set family in
  the tree reads two cells per row and needs `2(t+1) ≥ n`; the lone diagonal
  needs only `t + 1 ≥ n` cells and wastes none of them. Contrast
  `single_column_not_information_set`: the *timelike* single column never
  decodes, at any horizon — tilting the one-cell-per-row observer onto the
  light cone flips it from never-decoding to counting-optimal.

* **T40 (even rings): sector blindness.** On an even cylinder the lone
  diagonal reads only its own parity sector and **never** decodes, at any
  horizon (`diagScreen_not_isInformationSet_even`): the opposite-class delta
  ghost of T38 is permanently dark.

* **T41 (even rings): two diagonals of opposite parity.** Two lightlike
  diagonals whose base columns differ in parity decode **iff `n ≤ 2(t+1)`**
  (`diagScreen_pair_isInformationSet_iff_even`) — at *any* relative offset:
  each diagonal reconstructs its own parity class through the Rule-60
  conjugacy, independently of the other. This generalizes the lightlike tube
  (T18a), whose two diagonals are adjacent, to arbitrary opposite-parity
  separations, at the same sharp threshold. Same-parity pairs never decode
  (`diagScreen_pair_same_parity_not_isInformationSet`).

## The proof

Two elementary pieces, both probe-verified before formalization:

* **the prefix kill** (`rule60_prefix_kill`): if the Rule-60 iterates of `w`
  vanish at one site `u₀` for `i ≤ t`, then `w` vanishes on the interval
  `u₀ .. u₀ + t` — a triangular double induction using only
  `rule60^[i] w (u+1) = rule60^[i] w u + rule60^[i+1] w u`;
* **the doubling reindex** (`rule60_iterate_double_reindex`):
  `w := v ↦ z (j₀ + 2v)` satisfies `rule60^[i] w v = rule60^[2i] z (j₀ + 2v)`,
  so diagonal readouts of `z` are exactly the fixed-site iterates of `w`.

On an odd ring `2` is invertible (explicitly: `2 · (n+1)/2 = 1`), so the
interval `j₀ + 2·{0..t}` with `t + 1 ≥ n` is the whole cylinder and `z = 0`.
On an even ring the same interval with `t + 1 ≥ n/2` is the whole parity
class of `j₀` — one class per diagonal.

The probes also pinned two neighbouring laws that remain numerical for now:
on odd rings a *pair* of diagonals below the single-diagonal horizon decodes
iff the reindexed offset `2⁻¹(j₁−j₀)` lies in the window
`[n−t−1, t+1]` (exact for `n = 7..13`, all offsets and horizons — the
prefix-kill covering analysis gives sufficiency; necessity is unformalized),
and single-cell Rule-60 readers with steps in `{0,−1}` always decode (the
R1b-image of T36; exhaustive for `m = 3,5,7`).

No `sorry`, no new axioms, no `native_decide`.
-/

namespace OPHProofChain.Rule90

variable {n : ℕ}

/-! ## The diagonal screen -/

/-- The lightlike diagonal based at `j₀`: one cell per row, drifting with the
    light cone — `{(i, j₀ + i) : i ≤ t}`. -/
def diagScreen [NeZero n] (t : ℕ) (j₀ : ZMod n) : Finset (Cell n t) :=
  Finset.univ.image fun i : Fin (t + 1) => (i, j₀ + ((i : ℕ) : ZMod n))

theorem mem_diagScreen [NeZero n] {t : ℕ} {j₀ : ZMod n} {p : Cell n t} :
    p ∈ diagScreen t j₀ ↔ p.2 = j₀ + ((p.1 : ℕ) : ZMod n) := by
  constructor
  · intro hp
    obtain ⟨i, -, hi⟩ := Finset.mem_image.mp hp
    rw [← hi]
  · intro hp
    exact Finset.mem_image.mpr ⟨p.1, Finset.mem_univ _, Prod.ext_iff.mpr ⟨rfl, hp.symm⟩⟩

theorem diagScreen_card_le [NeZero n] (t : ℕ) (j₀ : ZMod n) :
    (diagScreen t j₀).card ≤ t + 1 := by
  refine le_trans Finset.card_image_le ?_
  simp

/-! ## The two engine lemmas -/

/-- **The prefix kill.** Rule-60 iterates vanishing at a single site for all
    `i ≤ t` force the row itself to vanish on the whole interval
    `u₀ .. u₀ + t`: the triangular structure of the one-sided stencil. -/
theorem rule60_prefix_kill {t : ℕ} {w : Row n} {u₀ : ZMod n}
    (h : ∀ i, i ≤ t → rule60^[i] w u₀ = 0) :
    ∀ r i, i + r ≤ t → rule60^[i] w (u₀ + (r : ℕ)) = 0 := by
  intro r
  induction r with
  | zero =>
    intro i hi
    simpa using h i (by omega)
  | succ r ih =>
    intro i hi
    have h1 : rule60^[i] w (u₀ + (r : ℕ)) = 0 := ih i (by omega)
    have h2 : rule60^[i + 1] w (u₀ + (r : ℕ)) = 0 := ih (i + 1) (by omega)
    have hrec := rule60_iterate_succ_apply w i (u₀ + (r : ℕ))
    rw [h1, h2] at hrec
    have hC : rule60^[i] w (u₀ + (r : ℕ) + 1) = 0 := by simpa using hrec.symm
    rw [show u₀ + ((r + 1 : ℕ) : ZMod n) = u₀ + (r : ℕ) + 1 by push_cast; ring]
    exact hC

/-- **The doubling reindex.** Sampling the ring at even distances conjugates
    double Rule-60 steps into single ones: the diagonal readouts of `z` are
    the fixed-site iterates of `w := v ↦ z (j₀ + 2v)`. -/
theorem rule60_iterate_double_reindex (z : Row n) (j₀ : ZMod n) (i : ℕ) (v : ZMod n) :
    rule60^[i] (fun v' => z (j₀ + 2 * v')) v = rule60^[2 * i] z (j₀ + 2 * v) := by
  induction i generalizing v with
  | zero => simp
  | succ i ih =>
    rw [rule60_iterate_succ_apply, ih v, ih (v + 1),
      show 2 * (i + 1) = 2 + 2 * i by ring,
      Function.iterate_add_apply, rule60_iterate_two_apply,
      show j₀ + 2 * (v + 1) = j₀ + 2 * v + 2 by ring]

/-- A dark seed's diagonal readouts are fixed-site Rule-60 iterates. -/
private theorem diag_readouts [NeZero n] {t : ℕ} {b : ZMod n} {z : Row n}
    (hzb : VanishesOn (diagScreen t b) z) :
    ∀ i, i ≤ t → rule60^[2 * i] z b = 0 := by
  intro i hi
  have hp : ((⟨i, by omega⟩ : Fin (t + 1)), b + ((i : ℕ) : ZMod n)) ∈ diagScreen t b :=
    mem_diagScreen.mpr rfl
  have h0 : traj z i (b + ((i : ℕ) : ZMod n)) = 0 := hzb _ hp
  rw [traj_eq_rule60_iterate,
    show b + ((i : ℕ) : ZMod n) - ((i : ℕ) : ZMod n) = b by ring] at h0
  exact h0

/-- The interval kill, packaged: a seed dark on the diagonal at `b` vanishes
    on `b + 2·{0..t}`. -/
private theorem diag_kill [NeZero n] {t : ℕ} {b : ZMod n} {z : Row n}
    (hzb : VanishesOn (diagScreen t b) z) :
    ∀ r : ℕ, r ≤ t → z (b + 2 * ((r : ℕ) : ZMod n)) = 0 := by
  intro r hr
  have hw0 : ∀ i, i ≤ t → rule60^[i] (fun v : ZMod n => z (b + 2 * v)) 0 = 0 := by
    intro i hi
    rw [rule60_iterate_double_reindex, show b + 2 * (0 : ZMod n) = b by ring]
    exact diag_readouts hzb i hi
  have hw := rule60_prefix_kill hw0 r 0 (by omega)
  simpa using hw

/-! ## T40, odd rings: the perfect screen -/

/-- **T40 (positive half).** On an odd cylinder the lone lightlike diagonal
    with `n ≤ t + 1` cells is an information set: one cell per row decodes
    the bulk, meeting the counting bound exactly at `t + 1 = n`. -/
theorem diagScreen_isInformationSet_odd [NeZero n] (hodd : Odd n) {t : ℕ}
    (hcap : n ≤ t + 1) (j₀ : ZMod n) : IsInformationSet (diagScreen t j₀) := by
  rw [isInformationSet_iff_vanishing]
  intro z hz
  obtain ⟨c, hc⟩ := hodd
  have hkey : ∀ u : ZMod n, ∃ v : ZMod n, u = j₀ + 2 * v := by
    intro u
    refine ⟨((c + 1 : ℕ) : ZMod n) * (u - j₀), ?_⟩
    have h2 : (2 : ZMod n) * ((c + 1 : ℕ) : ZMod n) = 1 := by
      have h0 : ((n : ℕ) : ZMod n) = 0 := ZMod.natCast_self n
      have h1 : (2 * (c + 1) : ℕ) = n + 1 := by omega
      calc (2 : ZMod n) * ((c + 1 : ℕ) : ZMod n)
          = ((2 * (c + 1) : ℕ) : ZMod n) := by push_cast; ring
        _ = ((n + 1 : ℕ) : ZMod n) := by rw [h1]
        _ = 1 := by push_cast [h0]; ring
    calc u = j₀ + (u - j₀) := by ring
      _ = j₀ + ((2 : ZMod n) * ((c + 1 : ℕ) : ZMod n)) * (u - j₀) := by rw [h2]; ring
      _ = j₀ + 2 * (((c + 1 : ℕ) : ZMod n) * (u - j₀)) := by ring
  funext u
  simp only [Pi.zero_apply]
  obtain ⟨v, hv⟩ := hkey u
  have hvv : ((v.val : ℕ) : ZMod n) = v := by rw [ZMod.natCast_val, ZMod.cast_id]
  have hkill := diag_kill hz v.val (by have := ZMod.val_lt v; omega)
  rw [hvv, ← hv] at hkill
  exact hkill

/-- **T40, sharp.** On an odd cylinder the lone diagonal decodes **iff**
    `n ≤ t + 1` — the failure half is the universal counting bound, so the
    screen is *counting-tight*: at `t + 1 = n` every cell buys a dimension. -/
theorem diagScreen_isInformationSet_iff_odd [NeZero n] (hodd : Odd n) (t : ℕ)
    (j₀ : ZMod n) : IsInformationSet (diagScreen t j₀) ↔ n ≤ t + 1 := by
  constructor
  · intro h
    by_contra hlt
    exact card_lt_not_informationSet
      (lt_of_le_of_lt (diagScreen_card_le t j₀) (by omega)) h
  · exact fun h => diagScreen_isInformationSet_odd hodd h j₀

/-! ## T40, even rings: sector blindness -/

/-- On an even ring the opposite-class delta ghost is dark on every diagonal
    whose base shares `j₀`'s parity — the T38 mechanism, pointwise. -/
private theorem delta_dark_on_diag [NeZero n] (hev : 2 ∣ n) {t : ℕ} {j₀ b : ZMod n}
    (hb : ZMod.castHom hev (ZMod 2) b = ZMod.castHom hev (ZMod 2) j₀) :
    VanishesOn (diagScreen t b) (delta (j₀ + 1)) := by
  intro p hp
  have hcell := mem_diagScreen.mp hp
  refine traj_eq_zero_of_class_zero hev
    (p := ZMod.castHom hev (ZMod 2) j₀) ?_ (p.1 : ℕ) p.2 ?_
  · intro j' hj'
    refine delta_apply_of_ne fun hcontra => ?_
    rw [hcontra, map_add, map_one] at hj'
    exact (by decide : ∀ a : ZMod 2, a + 1 ≠ a) _ hj'
  · rw [hcell, map_add, map_natCast, hb]
    exact (by decide : ∀ x a : ZMod 2, x + a + a = x) _ _

/-- **T40 (negative half).** On an even cylinder the lone diagonal *never*
    decodes, at any horizon: it reads a single parity sector and the other
    sector's delta ghost stays dark forever. -/
theorem diagScreen_not_isInformationSet_even [NeZero n] (hev : 2 ∣ n) (t : ℕ)
    (j₀ : ZMod n) : ¬ IsInformationSet (diagScreen t j₀) := by
  rw [isInformationSet_iff_vanishing]
  intro h
  have h0 := h _ (delta_dark_on_diag hev (j₀ := j₀) rfl)
  have h1 := congrFun h0 (j₀ + 1)
  rw [delta_apply_self, Pi.zero_apply] at h1
  exact one_ne_zero h1

/-! ## T41, even rings: two diagonals of opposite parity -/

/-- **T41 (positive half).** Two lightlike diagonals whose bases differ in
    parity decode the even cylinder at the sharp width-2 threshold
    `n ≤ 2(t+1)`, whatever their offset: each diagonal kills its own parity
    class through the Rule-60 conjugacy. -/
theorem diagScreen_pair_isInformationSet_even [NeZero n] (hev : 2 ∣ n) {t : ℕ}
    (hcap : n ≤ 2 * (t + 1)) (j₀ j₁ : ZMod n)
    (hpar : ZMod.castHom hev (ZMod 2) j₁ = ZMod.castHom hev (ZMod 2) j₀ + 1) :
    IsInformationSet (diagScreen t j₀ ∪ diagScreen t j₁) := by
  rw [isInformationSet_iff_vanishing]
  intro z hz
  have hkill : ∀ b : ZMod n, VanishesOn (diagScreen t b) z →
      ∀ j : ZMod n, ZMod.castHom hev (ZMod 2) j = ZMod.castHom hev (ZMod 2) b →
      z j = 0 := by
    intro b hzb j hj
    have hcast : ZMod.castHom hev (ZMod 2) (j - b) = 0 := by
      rw [map_sub, hj, sub_self]
    have hdvd : 2 ∣ (j - b).val := by
      have hv : (((j - b).val : ℕ) : ZMod 2) = 0 := by
        rw [ZMod.natCast_val, ← ZMod.castHom_apply (h := hev)]
        exact hcast
      exact (CharP.cast_eq_zero_iff (ZMod 2) 2 _).mp hv
    obtain ⟨r, hr⟩ := hdvd
    have hrle : r ≤ t := by
      have hvlt : (j - b).val < n := ZMod.val_lt _
      omega
    have h2r : (2 : ZMod n) * ((r : ℕ) : ZMod n) = j - b := by
      calc (2 : ZMod n) * ((r : ℕ) : ZMod n) = ((2 * r : ℕ) : ZMod n) := by
            push_cast; ring
        _ = (((j - b).val : ℕ) : ZMod n) := by rw [← hr]
        _ = j - b := by rw [ZMod.natCast_val, ZMod.cast_id]
    have hw := diag_kill hzb r hrle
    rw [h2r, show b + (j - b) = j by ring] at hw
    exact hw
  funext j
  simp only [Pi.zero_apply]
  rcases (by decide : ∀ a b : ZMod 2, a = b ∨ a = b + 1)
    (ZMod.castHom hev (ZMod 2) j) (ZMod.castHom hev (ZMod 2) j₀) with h | h
  · exact hkill j₀ (fun p hp => hz p (Finset.mem_union_left _ hp)) j h
  · refine hkill j₁ (fun p hp => hz p (Finset.mem_union_right _ hp)) j ?_
    rw [hpar]
    exact h

/-- **T41, sharp.** The opposite-parity diagonal pair decodes **iff**
    `n ≤ 2(t+1)` — the lightlike-tube threshold (T18a), now offset-free. -/
theorem diagScreen_pair_isInformationSet_iff_even [NeZero n] (hev : 2 ∣ n) (t : ℕ)
    (j₀ j₁ : ZMod n)
    (hpar : ZMod.castHom hev (ZMod 2) j₁ = ZMod.castHom hev (ZMod 2) j₀ + 1) :
    IsInformationSet (diagScreen t j₀ ∪ diagScreen t j₁) ↔ n ≤ 2 * (t + 1) := by
  constructor
  · intro h
    by_contra hlt
    have hcard : (diagScreen t j₀ ∪ diagScreen t j₁).card < n := by
      have h₀ := diagScreen_card_le (n := n) t j₀
      have h₁ := diagScreen_card_le (n := n) t j₁
      have hu := Finset.card_union_le (diagScreen t j₀) (diagScreen t j₁)
      omega
    exact card_lt_not_informationSet hcard h
  · exact fun h => diagScreen_pair_isInformationSet_even hev h j₀ j₁ hpar

/-- Two diagonals of the **same** parity never decode an even cylinder: both
    read the same sector, and the other sector's delta ghost stays dark. -/
theorem diagScreen_pair_same_parity_not_isInformationSet [NeZero n] (hev : 2 ∣ n)
    (t : ℕ) (j₀ j₁ : ZMod n)
    (hpar : ZMod.castHom hev (ZMod 2) j₁ = ZMod.castHom hev (ZMod 2) j₀) :
    ¬ IsInformationSet (diagScreen t j₀ ∪ diagScreen t j₁) := by
  rw [isInformationSet_iff_vanishing]
  intro h
  have h0 := h (delta (j₀ + 1)) fun p hp => by
    rcases Finset.mem_union.mp hp with hp | hp
    · exact delta_dark_on_diag hev rfl p hp
    · exact delta_dark_on_diag hev hpar p hp
  have h1 := congrFun h0 (j₀ + 1)
  rw [delta_apply_self, Pi.zero_apply] at h1
  exact one_ne_zero h1

/-! ## Concrete exhibits (kernel-`decide`, cross-checked by the oph_sim battery) -/

/-- The counting-tight exhibit: on the 5-ring, five diagonal cells decode
    five dimensions — zero slack. -/
theorem diag_five_four : IsInformationSet (diagScreen (n := 5) 4 0) := by decide

/-- One cell fewer and the counting bound bites. -/
theorem diag_five_three_fails : ¬ IsInformationSet (diagScreen (n := 5) 3 0) := by
  decide

/-- The even-ring lone diagonal fails even far beyond the width-2 threshold. -/
theorem diag_four_three_fails : ¬ IsInformationSet (diagScreen (n := 4) 3 0) := by
  decide

/-- T41 at capacity: bases `0` and `3` differ in parity on the 6-ring. -/
theorem diagPair_six_two :
    IsInformationSet (diagScreen (n := 6) 2 0 ∪ diagScreen (n := 6) 2 3) := by
  decide

/-- Same parity, same horizon: blind to the odd sector. -/
theorem diagPair_same_six_two_fails :
    ¬ IsInformationSet (diagScreen (n := 6) 2 0 ∪ diagScreen (n := 6) 2 2) := by
  decide

-- Axiom audit: these must report only `[propext, Classical.choice, Quot.sound]`.
#print axioms rule60_prefix_kill
#print axioms rule60_iterate_double_reindex
#print axioms diagScreen_isInformationSet_odd
#print axioms diagScreen_isInformationSet_iff_odd
#print axioms diagScreen_not_isInformationSet_even
#print axioms diagScreen_pair_isInformationSet_even
#print axioms diagScreen_pair_isInformationSet_iff_even
#print axioms diagScreen_pair_same_parity_not_isInformationSet

end OPHProofChain.Rule90
