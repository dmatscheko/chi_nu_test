import Mathlib
import OPHProofChain.Rule90Stride
import OPHProofChain.Rule90Propagation
import OPHProofChain.Rule90Lipschitz

/-!
# T37 [formal-v9] — the gap-2 crawl, classified (T30's named leftover)

**Provenance.** chi_nu_test original (formal-v9 campaign). T30 classified
local decodability at column ring-distance ≥ 3 (nothing infers, ever) and
distance 1 (everything infers, at the sharp threshold); the simulation
companion observed that at distance 2 "the crawl completes on odd rings at
threshold" (`oph_sim/FINDINGS.md` item 1), and T30 recorded that regime as
its named leftover. This module closes it, both ways:

* **odd rings** (`gapTwoTube_closure_complete_odd`): at the sharp
  threshold the propagation closure of the distance-2 screen is the
  **entire block**. The mechanism is exactly the simulation's crawl, made
  into a proof: the two screen columns *enclose* the middle column, whose
  cells the downward rule supplies at all times ≥ 1
  (`gapTwo_middle_inferable`); the three columns then carry two adjacent
  pairs, whose fans — T36's `inferable_fan_of_pairs` with anchors at times
  `[1, t]` — cover row 1 completely at the odd threshold `n ≤ 2t + 1`
  (`gapTwo_row1`); and row 0 is reached by the crawl proper
  (`gapTwo_crawl`): steps of two columns, seeded by the screen's own two
  row-0 cells, consuming one row-1 cell per step, wrapping the whole ring
  because `2·(m+1) ≡ 1 (mod n)` for `n = 2m + 1`. As a corollary the odd
  half of T25's `g = 2` classification re-derives *through propagation*
  (`gapTwo_information_set_via_propagation`) — the same upgrade T30b gave
  T9: the crawl is not merely a decoding heuristic, it IS a decoder.
* **even rings** (`gapTwoTube_closure_incomplete_even`): the closure can
  never reach the whole seed row, at any horizon — immediate from T25's
  parity negative (`gcd(2, n) = 2`) plus soundness of propagation.

Packaged as `gapTwo_closure_complete_iff_odd`: at the sharp threshold the
crawl completes **iff the ring is odd** — i.e. iff the 2-walk generates
the ring. With T30 (distances 1 and ≥ 3) this classifies the local
decodability of two-column screens at **every** ring distance, and the
remaining open mathematics of the chain is the arbitrary-subset
classification alone.

Axioms: standard (`propext`, `Classical.choice`, `Quot.sound`); no `sorry`,
no `native_decide`.
-/

namespace OPHProofChain.Rule90

variable {n : ℕ} [NeZero n]

/-- The middle column of the gap-2 screen is inferable at every time ≥ 1:
    the screen's two columns enclose it — one downward rule per cell. -/
theorem gapTwo_middle_inferable {t : ℕ} (j₀ : ZMod n) {i : ℕ}
    (h1 : 1 ≤ i) (hit : i ≤ t) :
    Inferable (gapTube 2 t j₀) (⟨i, by omega⟩, j₀ + 1) := by
  have hlt : i - 1 < t := by omega
  have key : Inferable (gapTube 2 t j₀)
      ((⟨i - 1, hlt⟩ : Fin t).succ, j₀ + 1) := by
    refine Inferable.down ?_ ?_
    · rw [show j₀ + 1 - 1 = j₀ from by ring]
      exact .base (mem_gapTube.mpr (Or.inl rfl))
    · rw [show j₀ + 1 + 1 = j₀ + ((2 : ℕ) : ZMod n) from by push_cast; ring]
      exact .base (mem_gapTube.mpr (Or.inr rfl))
  convert key using 2
  exact Fin.ext (show i = i - 1 + 1 by omega)

/-- The left adjacent pair `{j₀, j₀ + 1}` carried by the enclosed columns,
    at every time ≥ 1. -/
theorem gapTwo_left_pair {t : ℕ} (j₀ : ZMod n) {i : ℕ}
    (h1 : 1 ≤ i) (hit : i ≤ t) :
    Inferable (gapTube 2 t j₀) (⟨i, by omega⟩, j₀) ∧
    Inferable (gapTube 2 t j₀) (⟨i, by omega⟩, j₀ + 1) :=
  ⟨.base (mem_gapTube.mpr (Or.inl rfl)), gapTwo_middle_inferable j₀ h1 hit⟩

/-- The right adjacent pair `{j₀ + 1, j₀ + 2}`, at every time ≥ 1. -/
theorem gapTwo_right_pair {t : ℕ} (j₀ : ZMod n) {i : ℕ}
    (h1 : 1 ≤ i) (hit : i ≤ t) :
    Inferable (gapTube 2 t j₀) (⟨i, by omega⟩, j₀ + 1) ∧
    Inferable (gapTube 2 t j₀) (⟨i, by omega⟩, j₀ + 1 + 1) := by
  refine ⟨gapTwo_middle_inferable j₀ h1 hit, ?_⟩
  rw [show j₀ + 1 + 1 = j₀ + ((2 : ℕ) : ZMod n) from by push_cast; ring]
  exact .base (mem_gapTube.mpr (Or.inr rfl))

/-- **Row 1 is fully inferable** whenever `n ≤ 2t + 1`: the union of the
    two pair-fans (T36's engine with anchors on `[1, t]`) has width
    `2t + 1` at time 1. No parity hypothesis — the crawl's parity
    obstruction lives strictly in row 0. -/
theorem gapTwo_row1 {t : ℕ} (j₀ : ZMod n) (ht : 1 ≤ t)
    (hn : n ≤ 2 * t + 1) (x : ZMod n) :
    Inferable (gapTube 2 t j₀) (⟨1, by omega⟩, x) := by
  have hcz : ∀ i, i < t →
      (((fun _ => (0 : ℤ)) (i + 1)) - ((fun _ => (0 : ℤ)) i)).natAbs ≤ 1 := by
    intro i _
    simp
  set δ : ℕ := (x - (j₀ + ((1 - (t : ℤ) : ℤ) : ZMod n))).val with hδdef
  have hδn : δ < n := ZMod.val_lt _
  have hδcast : ((δ : ℕ) : ZMod n)
      = x - (j₀ + ((1 - (t : ℤ) : ℤ) : ZMod n)) := by
    rw [hδdef]
    exact ZMod.natCast_rightInverse _
  have hx : x = j₀ + (((1 : ℤ) - t + δ : ℤ) : ZMod n) := by
    rw [show (((1 : ℤ) - t + δ : ℤ) : ZMod n)
        = ((1 - (t : ℤ) : ℤ) : ZMod n) + ((δ : ℕ) : ZMod n) from by
      push_cast; ring]
    rw [hδcast]
    ring
  rw [hx]
  by_cases hm : (1 : ℤ) - t + δ ≤ t
  · -- left fan, base `j₀`, at level `k = t - 1`
    have h := inferable_fan_of_pairs (S := gapTube 2 t j₀)
      (fun _ => (0 : ℤ)) j₀ 1 ht hcz
      (fun i h1 hi => ⟨by simpa using (gapTwo_left_pair j₀ h1 hi).1,
                       by simpa using (gapTwo_left_pair j₀ h1 hi).2⟩)
      (t - 1) (by omega) ((1 : ℤ) - t + δ)
      (by simp only []; omega) (by simp only []; omega)
    simp only [show t - (t - 1) = 1 from by omega] at h
    exact h
  · -- the single leftover column `m = t + 1`: right fan, base `j₀ + 1`
    have hm' : (1 : ℤ) - t + δ = t + 1 := by omega
    have h := inferable_fan_of_pairs (S := gapTube 2 t j₀)
      (fun _ => (0 : ℤ)) (j₀ + 1) 1 ht hcz
      (fun i h1 hi => ⟨by simpa using (gapTwo_right_pair j₀ h1 hi).1,
                       by simpa using (gapTwo_right_pair j₀ h1 hi).2⟩)
      (t - 1) (by omega) ((t : ℤ))
      (by simp only []; omega) (by simp only []; omega)
    simp only [show t - (t - 1) = 1 from by omega] at h
    rw [hm', show j₀ + (((t : ℤ) + 1 : ℤ) : ZMod n)
        = (j₀ + 1) + ((t : ℤ) : ZMod n) from by push_cast; ring]
    exact h

/-- **The crawl**: row-0 columns at even offsets from `j₀`, two at a time —
    each step consumes one full-row-1 cell and the row-0 cell two columns
    back, seeded by the screen's own row-0 cells. -/
theorem gapTwo_crawl {t : ℕ} (j₀ : ZMod n) (ht : 1 ≤ t)
    (hn : n ≤ 2 * t + 1) (k : ℕ) :
    Inferable (gapTube 2 t j₀)
      (⟨0, Nat.succ_pos t⟩, j₀ + ((2 * k : ℕ) : ZMod n)) := by
  induction k with
  | zero =>
    have h : Inferable (gapTube 2 t j₀) (⟨0, Nat.succ_pos t⟩, j₀) :=
      .base (mem_gapTube.mpr (Or.inl rfl))
    simpa using h
  | succ k ih =>
    have h0t : 0 < t := ht
    have key : Inferable (gapTube 2 t j₀)
        ((⟨0, h0t⟩ : Fin t).castSucc,
          (j₀ + ((2 * k + 1 : ℕ) : ZMod n)) + 1) := by
      refine Inferable.right ?_ ?_
      · exact gapTwo_row1 j₀ ht hn (j₀ + ((2 * k + 1 : ℕ) : ZMod n))
      · rw [show (j₀ + ((2 * k + 1 : ℕ) : ZMod n)) - 1
            = j₀ + ((2 * k : ℕ) : ZMod n) from by push_cast; ring]
        exact ih
    rw [show j₀ + ((2 * (k + 1) : ℕ) : ZMod n)
        = (j₀ + ((2 * k + 1 : ℕ) : ZMod n)) + 1 from by push_cast; ring]
    exact key

/-- On an odd ring the crawl wraps: `2` is invertible, so every seed cell
    is an even offset from `j₀`. -/
theorem gapTwo_row0 {t : ℕ} (j₀ : ZMod n) (ht : 1 ≤ t) (hodd : Odd n)
    (hn : n ≤ 2 * t + 1) (x : ZMod n) :
    Inferable (gapTube 2 t j₀) (⟨0, Nat.succ_pos t⟩, x) := by
  obtain ⟨m, hm⟩ := hodd
  set v : ℕ := (x - j₀).val with hvdef
  have hvcast : ((v : ℕ) : ZMod n) = x - j₀ := by
    rw [hvdef]
    exact ZMod.natCast_rightInverse _
  have harith : 2 * (v * (m + 1)) = v * (n + 1) := by
    rw [hm]
    ring
  have hcast2 : ((2 * (v * (m + 1)) : ℕ) : ZMod n) = ((v : ℕ) : ZMod n) := by
    rw [harith]
    push_cast [ZMod.natCast_self]
    ring
  have hx : x = j₀ + ((2 * (v * (m + 1)) : ℕ) : ZMod n) := by
    rw [hcast2, hvcast]
    ring
  rw [hx]
  exact gapTwo_crawl j₀ ht hn (v * (m + 1))

/-- **T37a — the crawl completes: odd rings, sharp threshold.** The
    propagation closure of the gap-2 screen is the entire spacetime
    block. (`oph_sim/FINDINGS.md` item 1, now a theorem.) -/
theorem gapTwoTube_closure_complete_odd {t : ℕ} (j₀ : ZMod n)
    (hodd : Odd n) (hn : n ≤ 2 * (t + 1)) (p : Cell n t) :
    Inferable (gapTube 2 t j₀) p := by
  obtain ⟨m, hm⟩ := hodd
  rcases Nat.lt_or_ge n 3 with h3 | h3
  · -- `n = 1`: the one-column ring — every cell is a screen cell
    have hn1 : n = 1 := by
      have := NeZero.pos n
      omega
    have hcol : p.2 = j₀ := by
      subst hn1
      exact Subsingleton.elim _ _
    exact .base (mem_gapTube.mpr (Or.inl hcol))
  · have ht : 1 ≤ t := by omega
    have hn' : n ≤ 2 * t + 1 := by omega
    exact closure_complete_of_seedRow
      (fun x => gapTwo_row0 j₀ ht ⟨m, hm⟩ hn' x) p

/-- The odd half of T25's `g = 2` classification, re-derived through the
    closure: the crawl IS a decoder — the same upgrade T30b gave T9. -/
theorem gapTwo_information_set_via_propagation {t : ℕ} (j₀ : ZMod n)
    (hodd : Odd n) (hn : n ≤ 2 * (t + 1)) :
    IsInformationSet (gapTube 2 t j₀) :=
  isInformationSet_of_seedRow_inferable fun x =>
    gapTwoTube_closure_complete_odd j₀ hodd hn (⟨0, Nat.succ_pos t⟩, x)

/-- **T37b — the crawl stalls: even rings, every horizon.** The closure
    cannot reach the whole seed row — else the screen would decode,
    contradicting the parity negative (`gcd(2, n) = 2`, T25). -/
theorem gapTwoTube_closure_incomplete_even {t : ℕ} (j₀ : ZMod n)
    (heven : Even n) :
    ¬ ∀ x : ZMod n, Inferable (gapTube 2 t j₀) (⟨0, Nat.succ_pos t⟩, x) := by
  intro h
  have hIS : IsInformationSet (gapTube 2 t j₀) :=
    isInformationSet_of_seedRow_inferable h
  rw [gapTube_isInformationSet_iff] at hIS
  obtain ⟨m, hm⟩ := heven
  have hgcd : Nat.gcd 2 n = 2 := Nat.gcd_eq_left ⟨m, by omega⟩
  omega

/-- **T37 — the distance-2 local-decodability classification.** At the
    sharp threshold the crawl completes **iff the ring is odd** — iff the
    2-walk generates the ring. With T30 (distances 1 and ≥ 3) local
    decodability of two-column screens is classified at every ring
    distance. -/
theorem gapTwo_closure_complete_iff_odd {t : ℕ} (j₀ : ZMod n)
    (hn : n ≤ 2 * (t + 1)) :
    (∀ p : Cell n t, Inferable (gapTube 2 t j₀) p) ↔ Odd n := by
  constructor
  · intro h
    by_contra hodd
    rw [Nat.not_odd_iff_even] at hodd
    exact gapTwoTube_closure_incomplete_even j₀ hodd
      (fun x => h (⟨0, Nat.succ_pos t⟩, x))
  · intro hodd
    exact gapTwoTube_closure_complete_odd j₀ hodd hn

/-! ### Axiom audit -/
#print axioms gapTwoTube_closure_complete_odd
#print axioms gapTwo_information_set_via_propagation
#print axioms gapTwoTube_closure_incomplete_even
#print axioms gapTwo_closure_complete_iff_odd

end OPHProofChain.Rule90
