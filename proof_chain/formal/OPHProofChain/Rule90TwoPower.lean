import Mathlib
import OPHProofChain.Rule90Lipschitz
import OPHProofChain.Rule90Parity

/-!
# T39 [formal-v10] — two-power universality: every observer decodes

**Provenance.** chi_nu_test original (formal-v10 campaign). This module closes
conjecture **C3** of `oph_sim/FINDINGS.md` (item 18): on a cylinder whose
circumference is a power of two, **every** adjacent-pair screen — every
worldline, with *no* causality hypothesis whatsoever — is an information set
at the sharp threshold `n ≤ 2(t+1)`.

## The theorem

`pairScreen_isInformationSet_two_pow`: for `n = 2^k` and `n ≤ 2(t+1)`, every
column path `col : Fin (t+1) → ZMod n` gives an information set — teleporting
observers included. `pairScreen_isInformationSet_iff_two_pow` and
`pathScreen_isInformationSet_iff_two_pow` add the sharp converse (the
slope-blind counting bound). Contrast: at `(n,t) = (10,4)` the superluminal
slope-2 worldline **fails** (`pairScreen_slope2_fails_10_4`, T36 module), so
the two-power hypothesis is genuinely load-bearing — on `2^k` rings the
beyond-Lipschitz wildness of T36 disappears completely.

## The proof (elementary, via the Rule-60 bridge)

Everything reduces to the difference operator `rule60` of `Rule90Parity`
(`traj x i j = rule60^[2i] x (j − i)`), plus three facts:

* **doubling** (`rule60_iterate_two_pow_apply`):
  `rule60^[2^k] x j = x j + x (j + 2^k)` — a two-line induction on `k`;
* **nilpotency** (`rule60_iterate_self_eq_zero`): on `n = 2^k` the doubling
  lemma at `k` collapses to `x j + x j = 0`: `rule60^[n] = 0`;
* **the all-ones funnel** (`rule60_apply_eq_of_eq_zero`): a row killed by one
  Rule-60 step is constant, so the *last nonzero iterate* of any nonzero seed
  is the all-ones row.

Given a dark ghost `z ≠ 0`, take the last nonzero iterate `rule60^[s] z = 𝟙`,
`s ≤ n−1 ≤ 2t+1`. If `s = 2i`, the screen's cell `(i, col i)` reads
`rule60^[2i] z (col i − i) = 1 ≠ 0`. If `s = 2i+1`, the *pair*
`{col i, col i + 1}` reads two adjacent zeros of `rule60^[2i] z`, whose sum
must be `(rule60^[s] z)(col i − i) = 1` — contradiction. The pair geometry is
used exactly once, at odd `s`; nothing else about the worldline matters.

All lemma shapes were verified numerically first (probes E1–E5: the bridge
identity for all `n = 3..20`, doubling, sharp nilpotency, the all-ones
funnel on 3000 seeds, and the theorem itself exhaustively at `(8,3)` — all
`8^4` paths — plus randomized sweeps at `(16,7)`, `(16,11)`, `(32,15)`,
`(64,31)`).

No `sorry`, no new axioms, no `native_decide`.
-/

namespace OPHProofChain.Rule90

variable {n : ℕ}

private theorem zmod2_eq_one_of_ne_zero' : ∀ a : ZMod 2, a ≠ 0 → a = 1 := by
  decide

/-! ## Doubling, nilpotency, and the all-ones funnel -/

/-- **The doubling lemma**: `2^k` Rule-60 steps form the distance-`2^k`
    difference — iterated freshman's dream, with no binomials anywhere. -/
theorem rule60_iterate_two_pow_apply (k : ℕ) (x : Row n) (j : ZMod n) :
    rule60^[2 ^ k] x j = x j + x (j + ((2 ^ k : ℕ) : ZMod n)) := by
  induction k generalizing x j with
  | zero => simpa using rule60_iterate_succ_apply x 0 j
  | succ k ih =>
    have hcancel : ∀ a b c : ZMod 2, a + b + (b + c) = a + c := by decide
    rw [show 2 ^ (k + 1) = 2 ^ k + 2 ^ k by rw [pow_succ, Nat.mul_two],
      Function.iterate_add_apply, ih, ih, ih, hcancel]
    congr 1
    push_cast
    ring_nf

/-- **Nilpotency on two-power rings**: `2^k` steps see distance `2^k = 0`. -/
theorem rule60_iterate_self_eq_zero {k : ℕ} (hn : n = 2 ^ k) (x : Row n) :
    rule60^[n] x = 0 := by
  subst hn
  funext j
  simp only [Pi.zero_apply]
  rw [rule60_iterate_two_pow_apply, ZMod.natCast_self, add_zero]
  exact (by decide : ∀ a : ZMod 2, a + a = 0) _

/-- **The all-ones funnel**: a row killed by one Rule-60 step is constant
    around the cylinder. -/
theorem rule60_apply_eq_of_eq_zero [NeZero n] {d : Row n} (hd : rule60 d = 0)
    (u v : ZMod n) : d u = d v := by
  have hstep : ∀ a : ZMod n, d (a + 1) = d a := by
    intro a
    have h : d a + d (a + 1) = 0 := by
      have := congrFun hd a
      simpa [rule60] using this
    exact (by decide : ∀ x y : ZMod 2, x + y = 0 → y = x) _ _ h
  have hnat : ∀ k : ℕ, d ((k : ℕ) : ZMod n) = d 0 := by
    intro k
    induction k with
    | zero => norm_num
    | succ k ih =>
      push_cast
      rw [hstep]
      push_cast at ih
      exact ih
  have hu : ((u.val : ℕ) : ZMod n) = u := by rw [ZMod.natCast_val, ZMod.cast_id]
  have hv : ((v.val : ℕ) : ZMod n) = v := by rw [ZMod.natCast_val, ZMod.cast_id]
  rw [← hu, ← hv, hnat, hnat]

/-! ## T39 — every worldline decodes on a two-power ring -/

/-- **T39.** On `n = 2^k` at the sharp threshold, *every* adjacent-pair screen
    is an information set — arbitrary column paths, teleports included. The
    causality (Lipschitz) hypothesis of T36 is vacuous on two-power rings. -/
theorem pairScreen_isInformationSet_two_pow [NeZero n] {k : ℕ} (hn : n = 2 ^ k)
    {t : ℕ} (hcap : n ≤ 2 * (t + 1)) (col : Fin (t + 1) → ZMod n) :
    IsInformationSet (pairScreen t col) := by
  classical
  rw [isInformationSet_iff_vanishing]
  intro z hz
  by_contra hz0
  have hpos : 0 < n := Nat.pos_of_ne_zero (NeZero.ne n)
  -- the least vanishing iterate exists by nilpotency
  have hex : ∃ s, rule60^[s] z = 0 := ⟨n, rule60_iterate_self_eq_zero hn z⟩
  have hm₀ : rule60^[Nat.find hex] z = 0 := Nat.find_spec hex
  have hm₀pos : 0 < Nat.find hex := by
    rcases Nat.eq_zero_or_pos (Nat.find hex) with h | h
    · exact absurd (by simpa [h] using hm₀) hz0
    · exact h
  have hm₀le : Nat.find hex ≤ n := Nat.find_le (rule60_iterate_self_eq_zero hn z)
  -- s: the last nonzero iterate
  set s := Nat.find hex - 1 with hs_def
  have hsz : rule60^[s] z ≠ 0 := Nat.find_min hex (by omega)
  have hstep : rule60 (rule60^[s] z) = 0 := by
    have h1 : s + 1 = Nat.find hex := by omega
    have h2 : rule60^[s + 1] z = 0 := by rw [h1]; exact hm₀
    rw [Function.iterate_succ_apply'] at h2
    exact h2
  -- the last nonzero iterate is the all-ones row
  have hone : ∀ u : ZMod n, rule60^[s] z u = 1 := by
    obtain ⟨u₀, hu₀⟩ : ∃ u, rule60^[s] z u ≠ 0 := by
      by_contra h
      refine hsz (funext fun u => ?_)
      by_contra hu
      exact h ⟨u, hu⟩
    intro u
    rw [rule60_apply_eq_of_eq_zero hstep u u₀]
    exact zmod2_eq_one_of_ne_zero' _ hu₀
  have hs_le : s ≤ n - 1 := by omega
  -- split on the parity of s; either way row i := ⌊s/2⌋ is read by the screen
  rcases Nat.even_or_odd s with ⟨i, hi⟩ | ⟨i, hi⟩
  · -- s = 2i: the single cell (i, col i) already sees a 1
    have hit : i < t + 1 := by omega
    have hcell : ((⟨i, hit⟩ : Fin (t + 1)), col ⟨i, hit⟩) ∈ pairScreen t col :=
      mem_pairScreen.mpr (Or.inl rfl)
    have h0 : traj z i (col ⟨i, hit⟩) = 0 := hz _ hcell
    rw [traj_eq_rule60_iterate, show 2 * i = s by omega, hone] at h0
    exact one_ne_zero h0
  · -- s = 2i+1: the adjacent pair sums to 1 but reads two zeros
    have hit : i < t + 1 := by omega
    have hcellA : ((⟨i, hit⟩ : Fin (t + 1)), col ⟨i, hit⟩) ∈ pairScreen t col :=
      mem_pairScreen.mpr (Or.inl rfl)
    have hcellB : ((⟨i, hit⟩ : Fin (t + 1)), col ⟨i, hit⟩ + 1) ∈ pairScreen t col :=
      mem_pairScreen.mpr (Or.inr rfl)
    have hA : traj z i (col ⟨i, hit⟩) = 0 := hz _ hcellA
    have hB : traj z i (col ⟨i, hit⟩ + 1) = 0 := hz _ hcellB
    rw [traj_eq_rule60_iterate] at hA hB
    have h1 : rule60 (rule60^[2 * i] z) (col ⟨i, hit⟩ - (i : ZMod n)) = 1 := by
      have hh : rule60^[2 * i + 1] z = rule60 (rule60^[2 * i] z) :=
        Function.iterate_succ_apply' rule60 (2 * i) z
      rw [← hh, ← hi]
      exact hone _
    rw [rule60_apply, hA,
      show col ⟨i, hit⟩ - (i : ZMod n) + 1 = col ⟨i, hit⟩ + 1 - (i : ZMod n) by ring,
      hB] at h1
    exact absurd h1 (by decide)

/-- T39, sharp form: on a two-power ring a worldline pair screen decodes
    **iff** `n ≤ 2(t+1)` — for every column path. -/
theorem pairScreen_isInformationSet_iff_two_pow [NeZero n] {k : ℕ} (hn : n = 2 ^ k)
    (t : ℕ) (col : Fin (t + 1) → ZMod n) :
    IsInformationSet (pairScreen t col) ↔ n ≤ 2 * (t + 1) := by
  constructor
  · intro h
    by_contra hlt
    exact card_lt_not_informationSet
      (lt_of_le_of_lt (pairScreen_card_le col) (by omega)) h
  · exact fun h => pairScreen_isInformationSet_two_pow hn h col

/-- T39 for integer-offset worldlines: **every** path `c : ℕ → ℤ` — Lipschitz
    or wildly superluminal — decodes on a two-power ring iff `n ≤ 2(t+1)`.
    (Compare `pathScreen_isInformationSet_iff`, which needs the 1-Lipschitz
    hypothesis but works on every `n`.) -/
theorem pathScreen_isInformationSet_iff_two_pow [NeZero n] {k : ℕ} (hn : n = 2 ^ k)
    (t : ℕ) (c : ℕ → ℤ) (j₀ : ZMod n) :
    IsInformationSet (pathScreen t c j₀) ↔ n ≤ 2 * (t + 1) := by
  rw [pathScreen_eq_pairScreen]
  exact pairScreen_isInformationSet_iff_two_pow hn t _

/-! ## Concrete exhibit (kernel-`decide`) -/

/-- The smallest teleporting observer: on the 4-ring the half-ring jump
    `![0, 2]` decodes at capacity — the `k = 2` instance of T39. (The `(8,3)`
    exhibits `pairScreen_teleport_8_3`, `pairScreen_slope2_8_3` of the T36
    module are the `k = 3` instances; T39 is the theorem they were waiting
    for.) -/
theorem pairScreen_teleport_4_1 :
    IsInformationSet (pairScreen (n := 4) 1 ![0, 2]) := by decide

-- Axiom audit: these must report only `[propext, Classical.choice, Quot.sound]`.
#print axioms rule60_iterate_two_pow_apply
#print axioms rule60_iterate_self_eq_zero
#print axioms rule60_apply_eq_of_eq_zero
#print axioms pairScreen_isInformationSet_two_pow
#print axioms pairScreen_isInformationSet_iff_two_pow
#print axioms pathScreen_isInformationSet_iff_two_pow

end OPHProofChain.Rule90
