import Mathlib
import OPHProofChain.Rule90Decoding
import OPHProofChain.Rule90Stride

/-!
# T30 [formal-v8] — the local-decodability phase boundary (ring distance 3)

**Provenance.** chi_nu_test original (formal-v8 campaign). Surfaced by the
simulation companion (`oph_sim/FINDINGS.md`, items 1–3): T25 classifies which
two-column screens *determine* the bulk (`gcd(g,n) = 1 ∧ n ≤ 2(t+1)`), but
the *decoding-complexity* classification underneath it is different, and
cleanly split by the **ring distance** between the screen columns:

* **distance ≥ 3 — no local foothold** (`spread_screen_inferable_iff`): the
  Rule-90 constraint couples three cells in three *consecutive* columns, so
  no single constraint ever touches two screen columns; the propagation
  closure of the screen is the screen itself — local inference derives
  nothing, at every horizon, unconditionally. Combined with T25 this gives
  machine-checked "violet" configurations (`violet_exhibit`, `n = 8, g = 3,
  t = 3`): the screen provably pins a unique world while local propagation
  provably derives **zero** bulk cells. Determination and local derivability
  split.
* **distance 1 — complete local decodability at the sharp threshold**
  (`adjacent_closure_complete`): the propagation closure of the adjacent
  tube is the *entire block* — the sideways fans and the downward rule are
  all single-constraint inferences. As a corollary the jewel's sufficiency
  re-derives through the closure (`tube_information_set_via_propagation`):
  T9's sweep is not merely *a* decoding strategy, it is local constraint
  propagation itself.

The distance-2 (gap) regime — where the simulation observed that the crawl
completes on odd rings at threshold — is **not classified here**; it was the
named open remark of this module. (**Update, formal-v9: closed** — T37,
`Rule90Crawl.lean`: the closure is complete iff the ring is odd; with this
module's two theorems, local decodability of two-column screens is
classified at every ring distance.) What is proven here: `Inferable` is
sound (`inferable_sound` — an inferable cell's value is a function of the
screen readings), so the phase boundary is a genuine statement about
decoding power, not about an arbitrary closure operator.

Axioms: standard (`propext`, `Classical.choice`, `Quot.sound`); no `sorry`,
no `native_decide`.
-/

namespace OPHProofChain.Rule90

variable {n : ℕ}

/-! ## The propagation closure and its soundness -/

/-- The local-inference closure of a cell set: the three directed readings
    of the single Rule-90 constraint
    `traj (i+1) j = traj i (j−1) + traj i (j+1)`. Each rule consumes two
    cells of one constraint and infers the third — exactly the "local
    constraint propagation" decoder of the simulation companion. -/
inductive Inferable {t : ℕ} (S : Finset (Cell n t)) : Cell n t → Prop
  | base {p : Cell n t} : p ∈ S → Inferable S p
  | down {i : Fin t} {j : ZMod n} :
      Inferable S (i.castSucc, j - 1) → Inferable S (i.castSucc, j + 1) →
      Inferable S (i.succ, j)
  | left {i : Fin t} {j : ZMod n} :
      Inferable S (i.succ, j) → Inferable S (i.castSucc, j + 1) →
      Inferable S (i.castSucc, j - 1)
  | right {i : Fin t} {j : ZMod n} :
      Inferable S (i.succ, j) → Inferable S (i.castSucc, j - 1) →
      Inferable S (i.castSucc, j + 1)

/-- Monotonicity of the closure. -/
theorem Inferable.mono {t : ℕ} {S S' : Finset (Cell n t)} (hss : S ⊆ S')
    {p : Cell n t} (h : Inferable S p) : Inferable S' p := by
  induction h with
  | base hp => exact .base (hss hp)
  | down _ _ ih1 ih2 => exact .down ih1 ih2
  | left _ _ ih1 ih2 => exact .left ih1 ih2
  | right _ _ ih1 ih2 => exact .right ih1 ih2

/-- **Soundness**: two trajectories agreeing on `S` agree on every
    inferable cell — local propagation never invents information. -/
theorem inferable_sound {t : ℕ} {S : Finset (Cell n t)} {p : Cell n t}
    (h : Inferable S p) (x y : Row n)
    (hxy : ∀ q ∈ S, traj x q.1 q.2 = traj y q.1 q.2) :
    traj x p.1 p.2 = traj y p.1 p.2 := by
  induction h with
  | base hp => exact hxy _ hp
  | @down i j _ _ ih1 ih2 =>
    show traj x i.succ.val j = traj y i.succ.val j
    simp only [Fin.val_succ]
    rw [traj_succ_apply, traj_succ_apply]
    simp only [Fin.val_castSucc] at ih1 ih2
    rw [ih1, ih2]
  | @left i j _ _ ih1 ih2 =>
    show traj x i.castSucc.val (j - 1) = traj y i.castSucc.val (j - 1)
    have hx : traj x i.castSucc.val (j - 1)
        = traj x (i.castSucc.val + 1) j - traj x i.castSucc.val (j + 1) :=
      eq_sub_of_add_eq (traj_succ_apply x i.castSucc.val j).symm
    have hy : traj y i.castSucc.val (j - 1)
        = traj y (i.castSucc.val + 1) j - traj y i.castSucc.val (j + 1) :=
      eq_sub_of_add_eq (traj_succ_apply y i.castSucc.val j).symm
    rw [hx, hy]
    simp only [Fin.val_succ, Fin.val_castSucc] at ih1 ih2
    rw [show i.castSucc.val = i.val from rfl, ih1, ih2]
  | @right i j _ _ ih1 ih2 =>
    show traj x i.castSucc.val (j + 1) = traj y i.castSucc.val (j + 1)
    have hx : traj x i.castSucc.val (j + 1)
        = traj x (i.castSucc.val + 1) j - traj x i.castSucc.val (j - 1) :=
      eq_sub_of_add_eq' (traj_succ_apply x i.castSucc.val j).symm
    have hy : traj y i.castSucc.val (j + 1)
        = traj y (i.castSucc.val + 1) j - traj y i.castSucc.val (j - 1) :=
      eq_sub_of_add_eq' (traj_succ_apply y i.castSucc.val j).symm
    rw [hx, hy]
    simp only [Fin.val_succ, Fin.val_castSucc] at ih1 ih2
    rw [show i.castSucc.val = i.val from rfl, ih1, ih2]

/-! ## Ring distance -/

/-- Ring distance between two columns of the `n`-cylinder. -/
def ringDist (a b : ZMod n) : ℕ := min (a - b).val (b - a).val

theorem ringDist_comm (a b : ZMod n) : ringDist a b = ringDist b a :=
  min_comm _ _

/-- If `b = a + k` for a natural `k`, the ring distance is at most `k`. -/
theorem ringDist_le_of_eq_add [NeZero n] {a b : ZMod n} {k : ℕ}
    (h : b = a + (k : ZMod n)) : ringDist a b ≤ k := by
  have hba : b - a = (k : ZMod n) := by rw [h]; ring
  calc ringDist a b ≤ (b - a).val := min_le_right _ _
    _ = ((k : ℕ) : ZMod n).val := by rw [hba]
    _ ≤ k := by rw [ZMod.val_natCast]; exact Nat.mod_le _ _

/-! ## Distance ≥ 3: the closure adds nothing

The Rule-90 constraint occupies three consecutive columns `{j−1, j, j+1}`,
one cell per column (distinct for `n ≥ 3`). Any two of its cells therefore
sit in distinct columns at ring distance ≤ 2 — so if every screen column is
≥ 3 away from every other, no rule ever finds both premises on the screen. -/

section Spread

variable [NeZero n]

/-- A column set is 3-spread: distinct members are at ring distance ≥ 3. -/
def Spread (C : Finset (ZMod n)) : Prop :=
  ∀ c ∈ C, ∀ c' ∈ C, c ≠ c' → 3 ≤ ringDist c c'

/-- **T30a — the no-foothold theorem.** For `n ≥ 3` and a screen `S` whose
    columns form a 3-spread set, the propagation closure of `S` is `S`
    itself: local inference derives nothing, at every horizon. -/
theorem spread_screen_inferable_iff {t : ℕ} {S : Finset (Cell n t)}
    {C : Finset (ZMod n)} (hn : 3 ≤ n) (hC : Spread C)
    (hS : ∀ p ∈ S, p.2 ∈ C) (p : Cell n t) :
    Inferable S p ↔ p ∈ S := by
  have hone : (1 : ZMod n) ≠ 0 := by
    intro h
    have h' : ((1 : ℕ) : ZMod n) = 0 := by
      push_cast
      exact h
    rw [CharP.cast_eq_zero_iff (ZMod n) n] at h'
    have := Nat.le_of_dvd (by omega) h'
    omega
  have htwo : (2 : ZMod n) ≠ 0 := by
    intro h
    have h' : ((2 : ℕ) : ZMod n) = 0 := by
      push_cast
      exact h
    rw [CharP.cast_eq_zero_iff (ZMod n) n] at h'
    have := Nat.le_of_dvd (by omega) h'
    omega
  -- two distinct cells of one constraint sit in distinct columns ≤ 2 apart;
  -- a 3-spread set can contain at most one of the three columns
  have key : ∀ (a b : ZMod n) (k : ℕ), a ≠ b → b = a + (k : ZMod n) →
      k ≤ 2 → a ∈ C → b ∈ C → False := by
    intro a b k hab hk hk2 haC hbC
    have := hC a haC b hbC hab
    have := ringDist_le_of_eq_add hk
    omega
  constructor
  · intro h
    induction h with
    | base hp => exact hp
    | @down i j _ _ ih1 ih2 =>
      exfalso
      have hc1 : j - 1 ∈ C := hS _ ih1
      have hc2 : j + 1 ∈ C := hS _ ih2
      have hne : j - 1 ≠ j + 1 := by
        intro he
        exact htwo (by linear_combination -he)
      exact key (j - 1) (j + 1) 2 hne (by push_cast; ring) le_rfl hc1 hc2
    | @left i j _ _ ih1 ih2 =>
      exfalso
      have hc1 : j ∈ C := hS _ ih1
      have hc2 : j + 1 ∈ C := hS _ ih2
      have hne : j ≠ j + 1 := by
        intro he
        exact hone (by linear_combination -he)
      exact key j (j + 1) 1 hne (by push_cast; ring) one_le_two hc1 hc2
    | @right i j _ _ ih1 ih2 =>
      exfalso
      have hc1 : j ∈ C := hS _ ih1
      have hc2 : j - 1 ∈ C := hS _ ih2
      have hne : j - 1 ≠ j := by
        intro he
        exact hone (by linear_combination -he)
      exact key (j - 1) j 1 hne (by push_cast; ring) one_le_two hc2 hc1
  · exact .base

/-- Two-column special case: a stride screen whose columns are ≥ 3 apart on
    the ring has trivial propagation closure. -/
theorem gapTube_inferable_iff {t : ℕ} (g : ℕ) (j₀ : ZMod n) (hn : 3 ≤ n)
    (hd : 3 ≤ ringDist j₀ (j₀ + (g : ZMod n))) (p : Cell n t) :
    Inferable (gapTube g t j₀) p ↔ p ∈ gapTube g t j₀ := by
  have hne : j₀ ≠ j₀ + (g : ZMod n) := by
    intro he
    have : ringDist j₀ (j₀ + (g : ZMod n)) = 0 := by
      rw [← he]
      simp [ringDist]
    omega
  refine spread_screen_inferable_iff hn (C := {j₀, j₀ + (g : ZMod n)}) ?_ ?_ p
  · intro c hc c' hc' hcc
    rcases Finset.mem_insert.mp hc with rfl | hc <;>
      rcases Finset.mem_insert.mp hc' with rfl | hc'
    · exact absurd rfl hcc
    · rw [Finset.mem_singleton] at hc'
      subst hc'
      exact hd
    · rw [Finset.mem_singleton] at hc
      subst hc
      rw [ringDist_comm]
      exact hd
    · rw [Finset.mem_singleton] at hc hc'
      subst hc hc'
      exact absurd rfl hcc
  · intro p hp
    rcases (mem_gapTube (g := g)).mp hp with h | h
    · exact Finset.mem_insert.mpr (Or.inl h)
    · exact Finset.mem_insert.mpr (Or.inr (Finset.mem_singleton.mpr h))

end Spread

/-! ## Distance 1: complete local decodability at the sharp threshold -/

section Adjacent

variable [NeZero n]

/-- The right sideways fan is inferable: column `j₀+1+r` down to depth
    `t − r`, by the same two-step recursion as `right_sweep`, with every
    step a single `right` inference. -/
theorem right_fan_inferable {t : ℕ} (j₀ : ZMod n) :
    ∀ r i : ℕ, (hir : i + r ≤ t) →
      Inferable (tubeSet t j₀) (⟨i, by omega⟩, j₀ + 1 + (r : ZMod n)) := by
  suffices H : ∀ r : ℕ,
      (∀ i : ℕ, (hir : i + r ≤ t) →
        Inferable (tubeSet t j₀) (⟨i, by omega⟩, j₀ + 1 + (r : ZMod n))) ∧
      (∀ i : ℕ, (hir : i + (r + 1) ≤ t) →
        Inferable (tubeSet t j₀)
          (⟨i, by omega⟩, j₀ + 1 + ((r + 1 : ℕ) : ZMod n))) by
    intro r
    exact (H r).1
  intro r
  induction r with
  | zero =>
    constructor
    · intro i hi
      refine .base ((mem_tubeSet).mpr (Or.inr ?_))
      show j₀ + 1 + ((0 : ℕ) : ZMod n) = j₀ + 1
      norm_num
    · intro i hi
      have hit : i < t := by omega
      have hcol : j₀ + 1 + ((0 + 1 : ℕ) : ZMod n) = (j₀ + 1) + 1 := by
        push_cast
        ring
      rw [hcol]
      refine Inferable.right (i := ⟨i, hit⟩) (j := j₀ + 1) ?_ ?_
      · exact .base ((mem_tubeSet).mpr (Or.inr rfl))
      · refine .base ((mem_tubeSet).mpr (Or.inl ?_))
        show j₀ + 1 - 1 = j₀
        ring
  | succ r ih =>
    constructor
    · exact ih.2
    · intro i hi
      have hit : i < t := by omega
      have hcol : j₀ + 1 + ((r + 1 + 1 : ℕ) : ZMod n)
          = (j₀ + 1 + ((r + 1 : ℕ) : ZMod n)) + 1 := by
        push_cast
        ring
      rw [hcol]
      refine Inferable.right (i := ⟨i, hit⟩) (j := j₀ + 1 + ((r + 1 : ℕ) : ZMod n))
        ?_ ?_
      · exact ih.2 (i + 1) (by omega)
      · have hcl : j₀ + 1 + ((r + 1 : ℕ) : ZMod n) - 1
            = j₀ + 1 + ((r : ℕ) : ZMod n) := by
          push_cast
          ring
        rw [hcl]
        exact ih.1 i (by omega)

/-- The left sideways fan is inferable: column `j₀−l` down to depth `t − l`,
    mirror of the right fan with `left` inferences. -/
theorem left_fan_inferable {t : ℕ} (j₀ : ZMod n) :
    ∀ l i : ℕ, (hil : i + l ≤ t) →
      Inferable (tubeSet t j₀) (⟨i, by omega⟩, j₀ - (l : ZMod n)) := by
  suffices H : ∀ l : ℕ,
      (∀ i : ℕ, (hil : i + l ≤ t) →
        Inferable (tubeSet t j₀) (⟨i, by omega⟩, j₀ - (l : ZMod n))) ∧
      (∀ i : ℕ, (hil : i + (l + 1) ≤ t) →
        Inferable (tubeSet t j₀)
          (⟨i, by omega⟩, j₀ - ((l + 1 : ℕ) : ZMod n))) by
    intro l
    exact (H l).1
  intro l
  induction l with
  | zero =>
    constructor
    · intro i hi
      refine .base ((mem_tubeSet).mpr (Or.inl ?_))
      show j₀ - ((0 : ℕ) : ZMod n) = j₀
      norm_num
    · intro i hi
      have hit : i < t := by omega
      have hcol : j₀ - ((0 + 1 : ℕ) : ZMod n) = j₀ - 1 := by
        push_cast
        ring
      rw [hcol]
      refine Inferable.left (i := ⟨i, hit⟩) (j := j₀) ?_ ?_
      · exact .base ((mem_tubeSet).mpr (Or.inl rfl))
      · exact .base ((mem_tubeSet).mpr (Or.inr rfl))
  | succ l ih =>
    constructor
    · exact ih.2
    · intro i hi
      have hit : i < t := by omega
      have hcol : j₀ - ((l + 1 + 1 : ℕ) : ZMod n)
          = (j₀ - ((l + 1 : ℕ) : ZMod n)) - 1 := by
        push_cast
        ring
      rw [hcol]
      refine Inferable.left (i := ⟨i, hit⟩) (j := j₀ - ((l + 1 : ℕ) : ZMod n))
        ?_ ?_
      · exact ih.2 (i + 1) (by omega)
      · have hcr : j₀ - ((l + 1 : ℕ) : ZMod n) + 1
            = j₀ - ((l : ℕ) : ZMod n) := by
          push_cast
          ring
        rw [hcr]
        exact ih.1 i (by omega)

/-- Under the sharp threshold, every seed cell is in one of the two fans —
    the closure reaches the whole seed row. -/
theorem seed_row_inferable {t : ℕ} (j₀ : ZMod n) (hn : n ≤ 2 * (t + 1))
    (c : ZMod n) :
    Inferable (tubeSet t j₀) (⟨0, Nat.succ_pos t⟩, c) := by
  set r : ℕ := (c - (j₀ + 1)).val with hr
  have hrn : r < n := ZMod.val_lt _
  have hcast : ((r : ℕ) : ZMod n) = c - (j₀ + 1) := by
    rw [hr]
    exact ZMod.natCast_rightInverse _
  have hc : c = j₀ + 1 + (r : ZMod n) := by
    rw [hcast]
    ring
  by_cases hrt : r ≤ t
  · rw [hc]
    exact right_fan_inferable j₀ r 0 (by omega)
  · rw [not_le] at hrt
    set l : ℕ := n - 1 - r with hl
    have hlt : l ≤ t := by omega
    have hcl : c = j₀ - (l : ZMod n) := by
      have hln : (l : ZMod n) = (n : ZMod n) - 1 - (r : ZMod n) := by
        rw [hl]
        push_cast [Nat.cast_sub (by omega : r ≤ n - 1),
          Nat.cast_sub (by omega : 1 ≤ n)]
        ring
      rw [hln, ZMod.natCast_self, hcast]
      ring
    rw [hcl]
    exact left_fan_inferable j₀ l 0 (by omega)

/-- **T30b — complete local decodability of the adjacent tube.** At the
    sharp threshold the propagation closure of the width-2 tube is the
    entire spacetime block: seed row by the fans, higher rows by the
    downward rule. -/
theorem adjacent_closure_complete {t : ℕ} (j₀ : ZMod n)
    (hn : n ≤ 2 * (t + 1)) (p : Cell n t) :
    Inferable (tubeSet t j₀) p := by
  obtain ⟨⟨i, hi⟩, c⟩ := p
  induction i generalizing c with
  | zero => exact seed_row_inferable j₀ hn c
  | succ i ihi =>
    have hit : i < t := by omega
    have h1 : Inferable (tubeSet t j₀) (⟨i, by omega⟩, c - 1) :=
      ihi (c - 1) (by omega)
    have h2 : Inferable (tubeSet t j₀) (⟨i, by omega⟩, c + 1) :=
      ihi (c + 1) (by omega)
    exact Inferable.down (i := ⟨i, hit⟩) (j := c) h1 h2

/-- The jewel's sufficiency, re-derived through the closure: soundness plus
    completeness of local propagation give T9's information-set property
    without a separate sweep — the sweep *is* propagation. -/
theorem tube_information_set_via_propagation {t : ℕ} (j₀ : ZMod n)
    (hn : n ≤ 2 * (t + 1)) :
    IsInformationSet (tubeSet t j₀) := by
  intro x y hxy
  funext c
  have h := inferable_sound (adjacent_closure_complete j₀ hn
    (⟨0, Nat.succ_pos t⟩, c)) x y hxy
  simpa using h

end Adjacent

/-! ## The violet exhibit: determined globally, locally dark -/

/-- **The simulation's flagship (`n = 8, g = 3, t = 3`), machine-checked.**
    At the exact threshold `8 = 2·(3+1)` with `gcd(3,8) = 1`, the stride-3
    screen IS an information set (T25: it pins a unique world) — while its
    propagation closure is the screen itself: **zero** bulk cells are
    locally derivable. Determination without local derivability. -/
theorem violet_exhibit :
    IsInformationSet (gapTube (n := 8) 3 3 (0 : ZMod 8)) ∧
      (∀ p : Cell 8 3,
        Inferable (gapTube (n := 8) 3 3 (0 : ZMod 8)) p ↔
          p ∈ gapTube (n := 8) 3 3 (0 : ZMod 8)) := by
  constructor
  · rw [gapTube_isInformationSet_iff]
    exact ⟨by norm_num, by norm_num⟩
  · intro p
    refine gapTube_inferable_iff 3 (0 : ZMod 8) (by norm_num) ?_ p
    show 3 ≤ ringDist (0 : ZMod 8) (0 + (3 : ℕ))
    decide

/-! ### Axiom audit -/
#print axioms inferable_sound
#print axioms spread_screen_inferable_iff
#print axioms gapTube_inferable_iff
#print axioms adjacent_closure_complete
#print axioms tube_information_set_via_propagation
#print axioms violet_exhibit

end OPHProofChain.Rule90
