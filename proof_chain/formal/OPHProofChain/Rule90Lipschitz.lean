import Mathlib
import OPHProofChain.Rule90Decoding
import OPHProofChain.Rule90Propagation
import OPHProofChain.Rule90Slope

/-!
# T36 [formal-v9] — the Lipschitz worldline theorem: the slope conjecture, closed

**Provenance.** chi_nu_test original (formal-v9 campaign).

**The theorem.** Call a two-cell-per-time screen a *worldline screen* if at
time `i` it reads the adjacent pair `{γ(i), γ(i)+1}` along a column path
`γ(i) = j₀ + c i` with integer offsets `c : ℕ → ℤ`. If the path is
**1-Lipschitz** (`|c (i+1) − c i| ≤ 1` — the observer moves at most one
column per step, i.e. at or below the lattice light speed), then at the
sharp threshold `n ≤ 2(t+1)` the propagation closure of the screen is the
*entire spacetime block* (`pathScreen_closure_complete`), hence the screen
is an information set (`pathScreen_isInformationSet`), and by the
slope-blind counting bound this is sharp
(`pathScreen_isInformationSet_iff`). The proof is a direct fan induction:
downward from the top row, at each level the two chains (left/right) grow
the known interval by one column on each side, and the 1-Lipschitz bound is
exactly what keeps the screen pair inside the previous level's interval —
the sheared-CA attack recorded in v8 dissolves into this two-line geometry.

**Corollary — the slope conjecture (holes-audit F6), closed.** For every
rational slope `0 ≤ p/q ≤ 1` the floor path `i ↦ ⌊i·p/q⌋` is a `{0,1}`-step
staircase, so `slopeTube p q t j₀` is an information set **iff**
`n ≤ 2(t+1)` (`slopeTube_isInformationSet_iff`) — the general theorem whose
two extremes were T9 (slope 0) and T18a (slope 1) and whose sample points
were the v8 kernel instances. Zigzags, bent screens and negative slopes are
all covered by the same theorem: only the Lipschitz bound matters, not
monotonicity or rationality. This also extends T30b: *every* causal
worldline (speed ≤ 1) decodes by local constraint propagation alone.

**Beyond Lipschitz the classification is genuinely wild** (this is the
machine-checked delimitation of the one remaining open item, arbitrary
subsets):

* at `(n,t) = (8,3)` **every** one of the `8^4` pair screens decodes — even
  teleporting paths (instances `pairScreen_slope2_8_3`,
  `pairScreen_teleport_8_3`; full sweep in `evidence/path_screen_sweep.txt`);
* at `(n,t) = (6,2)` exactly half fail, and the complete classification is
  a *last-step* condition (`pairScreen_class_6_2`): the screen decodes iff
  the final step is Lipschitz — the earlier step is completely free. In
  particular decodability is **order-sensitive**: `![0,0,2]` fails while
  `![0,2,2]` decodes, with the same step multiset;
* at `(n,t) = (10,4)` the `(8,3)` universality dies: the superluminal
  slope-2 line and the late jump **fail at exact capacity**
  (`pairScreen_slope2_fails_10_4`, `pairScreen_late_jump_fails_10_4`) while
  the same jump one step earlier decodes (`pairScreen_early_jump_10_4`).

So the Lipschitz hypothesis is sufficient at every size, not necessary at
any fixed small size, and no coarse invariant (step multiset, last step,
cardinality) classifies the general case — that, precisely, is what
remains open.

Axioms: standard (`propext`, `Classical.choice`, `Quot.sound`); no `sorry`,
no `native_decide`.
-/

namespace OPHProofChain.Rule90

variable {n : ℕ}

/-! ## Screens along a column path -/

/-- The general adjacent-pair screen: at time `i` read the two cells
    `{col i, col i + 1}`. `tubeSet`, `lightTube` and `slopeTube` are all
    instances. -/
def pairScreen [NeZero n] (t : ℕ) (col : Fin (t + 1) → ZMod n) :
    Finset (Cell n t) :=
  colFamily t col (fun i => col i + 1)

theorem mem_pairScreen [NeZero n] {t : ℕ} {col : Fin (t + 1) → ZMod n}
    {p : Cell n t} :
    p ∈ pairScreen t col ↔ p.2 = col p.1 ∨ p.2 = col p.1 + 1 :=
  mem_colFamily

theorem pairScreen_card_le [NeZero n] {t : ℕ} (col : Fin (t + 1) → ZMod n) :
    (pairScreen t col).card ≤ 2 * (t + 1) :=
  colFamily_card_le _ _

/-- The worldline screen of an integer column path `c` based at `j₀`: at
    time `i` read the adjacent pair `{j₀ + c i, j₀ + c i + 1}`. -/
def pathScreen [NeZero n] (t : ℕ) (c : ℕ → ℤ) (j₀ : ZMod n) :
    Finset (Cell n t) :=
  colFamily t (fun i => j₀ + ((c i.val : ℤ) : ZMod n))
    (fun i => j₀ + ((c i.val : ℤ) : ZMod n) + 1)

theorem pathScreen_eq_pairScreen [NeZero n] (t : ℕ) (c : ℕ → ℤ)
    (j₀ : ZMod n) :
    pathScreen t c j₀
      = pairScreen t (fun i => j₀ + ((c i.val : ℤ) : ZMod n)) :=
  rfl

theorem mem_pathScreen [NeZero n] {t : ℕ} {c : ℕ → ℤ} {j₀ : ZMod n}
    {p : Cell n t} :
    p ∈ pathScreen t c j₀ ↔
      p.2 = j₀ + ((c p.1.val : ℤ) : ZMod n) ∨
        p.2 = j₀ + ((c p.1.val : ℤ) : ZMod n) + 1 :=
  mem_colFamily

theorem pathScreen_card_le [NeZero n] (t : ℕ) (c : ℕ → ℤ) (j₀ : ZMod n) :
    (pathScreen t c j₀).card ≤ 2 * (t + 1) :=
  colFamily_card_le _ _

/-! ## Cast plumbing -/

private theorem col_shift [NeZero n] (j₀ : ZMod n) (m : ℤ) :
    j₀ + ((m + 1 : ℤ) : ZMod n) = j₀ + (m : ZMod n) + 1 := by
  push_cast
  ring

private theorem col_shift' [NeZero n] (j₀ : ZMod n) (m : ℤ) :
    j₀ + ((m - 1 : ℤ) : ZMod n) = j₀ + (m : ZMod n) - 1 := by
  push_cast
  ring

/-- A 1-Lipschitz path moves at most `b − a` columns between times `a ≤ b`. -/
private theorem lipschitz_telescope {t : ℕ} {c : ℕ → ℤ}
    (hc : ∀ i, i < t → (c (i + 1) - c i).natAbs ≤ 1) :
    ∀ a b : ℕ, a ≤ b → b ≤ t → (c b - c a).natAbs ≤ b - a := by
  intro a b hab hbt
  obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_le hab
  clear hab
  induction d with
  | zero => simp
  | succ d ih =>
    have hstep := hc (a + d) (by omega)
    have hprev := ih (by omega)
    rw [show a + (d + 1) = a + d + 1 from rfl]
    omega

/-! ## The fan: downward induction along the worldline

At level `k` below the top (time `t − k`) the closure of the screen covers
the integer column interval `[c t − k, c t + 1 + k]` — width `2k + 2`,
growing by one column per side per level. The 1-Lipschitz bound
`|c t − c i| ≤ t − i` is exactly the condition that keeps the screen pair
of level `i` inside the level-`(i+1)` interval, so both chains always have
their upper premise available. -/

/-- **The general two-chain fan** (T36's engine, stated for an arbitrary
    screen): if the closure of `S` already contains the adjacent pair
    `{j₀ + c i, j₀ + c i + 1}` at every time `i ∈ [i₀, t]` along a
    1-Lipschitz path `c`, then at level `k ≤ t − i₀` below the top it
    contains the whole column interval `[c t − k, c t + 1 + k]`.
    `pathScreen_fan` is the instance `i₀ = 0` with the screen's own cells
    as anchors; the gap-2 crawl (T37, `Rule90Crawl.lean`) is the instance
    `i₀ = 1` with *inferred* anchors. -/
theorem inferable_fan_of_pairs [NeZero n] {t : ℕ} {S : Finset (Cell n t)}
    (c : ℕ → ℤ) (j₀ : ZMod n) (i₀ : ℕ) (hi₀ : i₀ ≤ t)
    (hc : ∀ i, i < t → (c (i + 1) - c i).natAbs ≤ 1)
    (hpair : ∀ i, i₀ ≤ i → (hi : i ≤ t) →
      Inferable S (⟨i, by omega⟩, j₀ + ((c i : ℤ) : ZMod n)) ∧
      Inferable S (⟨i, by omega⟩, j₀ + ((c i : ℤ) : ZMod n) + 1)) :
    ∀ k : ℕ, k ≤ t - i₀ → ∀ m : ℤ, c t - k ≤ m → m ≤ c t + 1 + k →
      Inferable S (⟨t - k, by omega⟩, j₀ + (m : ZMod n)) := by
  intro k
  induction k with
  | zero =>
    intro _ m hm1 hm2
    have hbt0 : Inferable S
        (⟨t - 0, by omega⟩, j₀ + ((c t : ℤ) : ZMod n)) :=
      (hpair t hi₀ le_rfl).1
    have hbt1 : Inferable S
        (⟨t - 0, by omega⟩, j₀ + ((c t : ℤ) : ZMod n) + 1) :=
      (hpair t hi₀ le_rfl).2
    have hm : m = c t ∨ m = c t + 1 := by omega
    rcases hm with rfl | rfl
    · exact hbt0
    · rw [col_shift]
      exact hbt1
  | succ k ih =>
    intro hk m hm1 hm2
    set i := t - (k + 1) with hidef
    have hlt : i < t := by omega
    have hi1 : i < t + 1 := by omega
    -- the Lipschitz bound between level i and the top
    have htel : (c t - c i).natAbs ≤ k + 1 := by
      have h := lipschitz_telescope hc i t (by omega) le_rfl
      omega
    -- the two anchor cells of level i
    have hb0 : Inferable S (⟨i, hi1⟩, j₀ + ((c i : ℤ) : ZMod n)) :=
      (hpair i (by omega) (by omega)).1
    have hb1' : Inferable S (⟨i, hi1⟩, j₀ + ((c i + 1 : ℤ) : ZMod n)) := by
      rw [col_shift]
      exact (hpair i (by omega) (by omega)).2
    -- the induction hypothesis, re-indexed to `(⟨i, hlt⟩ : Fin t).succ`
    have hIH : ∀ m' : ℤ, c t - (k : ℤ) ≤ m' → m' ≤ c t + 1 + (k : ℤ) →
        Inferable S ((⟨i, hlt⟩ : Fin t).succ, j₀ + (m' : ZMod n)) := by
      intro m' h1 h2
      have h := ih (by omega) m' h1 h2
      convert h using 2
      exact Fin.ext (show i + 1 = t - k by omega)
    -- right chain: pairs marching right from the screen pair
    have hH : ∀ d : ℕ, c i + 1 + (d : ℤ) ≤ c t + 2 + (k : ℤ) →
        Inferable S (⟨i, hi1⟩, j₀ + ((c i + (d : ℤ) : ℤ) : ZMod n)) ∧
        Inferable S (⟨i, hi1⟩, j₀ + ((c i + 1 + (d : ℤ) : ℤ) : ZMod n)) := by
      intro d
      induction d with
      | zero =>
        intro _
        constructor
        · simpa using hb0
        · simpa using hb1'
      | succ d ihd =>
        intro hd
        obtain ⟨h1, h2⟩ := ihd (by omega)
        constructor
        · rw [show (c i + ((d + 1 : ℕ) : ℤ)) = c i + 1 + (d : ℤ) from by
            push_cast; ring]
          exact h2
        · rw [show (c i + 1 + ((d + 1 : ℕ) : ℤ)) = (c i + 1 + (d : ℤ)) + 1 from by
              push_cast; ring,
            col_shift]
          refine Inferable.right (i := ⟨i, hlt⟩)
            (j := j₀ + ((c i + 1 + (d : ℤ) : ℤ) : ZMod n)) ?_ ?_
          · exact hIH (c i + 1 + (d : ℤ)) (by omega) (by omega)
          · rw [show j₀ + ((c i + 1 + (d : ℤ) : ℤ) : ZMod n) - 1
                = j₀ + ((c i + (d : ℤ) : ℤ) : ZMod n) from by push_cast; ring]
            exact h1
    -- left chain: pairs marching left from the screen pair
    have hG : ∀ d : ℕ, c t - ((k : ℤ) + 1) ≤ c i - (d : ℤ) →
        Inferable S (⟨i, hi1⟩, j₀ + ((c i - (d : ℤ) : ℤ) : ZMod n)) ∧
        Inferable S (⟨i, hi1⟩, j₀ + ((c i - (d : ℤ) + 1 : ℤ) : ZMod n)) := by
      intro d
      induction d with
      | zero =>
        intro _
        constructor
        · simpa using hb0
        · rw [show (c i - ((0 : ℕ) : ℤ) + 1) = c i + 1 from by push_cast; ring]
          exact hb1'
      | succ d ihd =>
        intro hd
        obtain ⟨h1, h2⟩ := ihd (by omega)
        constructor
        · rw [show (c i - ((d + 1 : ℕ) : ℤ)) = (c i - (d : ℤ)) - 1 from by
              push_cast; ring,
            col_shift']
          refine Inferable.left (i := ⟨i, hlt⟩)
            (j := j₀ + ((c i - (d : ℤ) : ℤ) : ZMod n)) ?_ ?_
          · exact hIH (c i - (d : ℤ)) (by omega) (by omega)
          · rw [show j₀ + ((c i - (d : ℤ) : ℤ) : ZMod n) + 1
                = j₀ + ((c i - (d : ℤ) + 1 : ℤ) : ZMod n) from by push_cast; ring]
            exact h2
        · rw [show (c i - ((d + 1 : ℕ) : ℤ) + 1) = c i - (d : ℤ) from by
            push_cast; ring]
          exact h1
    -- combine: every column of the level-(k+1) interval is in a chain
    rcases lt_trichotomy m (c i) with hcase | hcase | hcase
    · have h := (hG (c i - m).toNat (by omega)).1
      rw [show (c i - (((c i - m).toNat : ℕ) : ℤ)) = m from by omega] at h
      exact h
    · rw [← hcase] at hb0
      exact hb0
    · have h := (hH (m - (c i + 1)).toNat (by omega)).2
      rw [show (c i + 1 + (((m - (c i + 1)).toNat : ℕ) : ℤ)) = m from by
        omega] at h
      exact h

/-- The worldline fan: the instance of `inferable_fan_of_pairs` in which
    the anchors are the screen's own cells (`i₀ = 0`). -/
theorem pathScreen_fan [NeZero n] (t : ℕ) (c : ℕ → ℤ) (j₀ : ZMod n)
    (hc : ∀ i, i < t → (c (i + 1) - c i).natAbs ≤ 1) :
    ∀ k : ℕ, k ≤ t → ∀ m : ℤ, c t - k ≤ m → m ≤ c t + 1 + k →
      Inferable (pathScreen t c j₀) (⟨t - k, by omega⟩, j₀ + (m : ZMod n)) :=
  inferable_fan_of_pairs c j₀ 0 (Nat.zero_le t) hc fun _ _ _ =>
    ⟨.base (mem_pathScreen.mpr (Or.inl rfl)),
     .base (mem_pathScreen.mpr (Or.inr rfl))⟩

/-- At the sharp threshold the level-`t` interval (width `2(t+1) ≥ n`)
    wraps the whole ring: every seed cell is inferable. -/
theorem pathScreen_seedRow_inferable [NeZero n] (t : ℕ) (c : ℕ → ℤ)
    (j₀ : ZMod n) (hc : ∀ i, i < t → (c (i + 1) - c i).natAbs ≤ 1)
    (hn : n ≤ 2 * (t + 1)) (x : ZMod n) :
    Inferable (pathScreen t c j₀) (⟨0, Nat.succ_pos t⟩, x) := by
  set δ : ℕ := (x - (j₀ + ((c t - t : ℤ) : ZMod n))).val with hδdef
  have hδn : δ < n := ZMod.val_lt _
  have hδcast : ((δ : ℕ) : ZMod n) = x - (j₀ + ((c t - t : ℤ) : ZMod n)) := by
    rw [hδdef]
    exact ZMod.natCast_rightInverse _
  have hx : x = j₀ + ((c t - t + δ : ℤ) : ZMod n) := by
    rw [show ((c t - (t : ℤ) + (δ : ℤ) : ℤ) : ZMod n)
        = ((c t - (t : ℤ) : ℤ) : ZMod n) + ((δ : ℕ) : ZMod n) from by
      push_cast; ring]
    rw [hδcast]
    ring
  rw [hx]
  have h := pathScreen_fan t c j₀ hc t le_rfl (c t - t + δ) (by omega)
    (by omega)
  simp only [Nat.sub_self] at h
  exact h

/-- Down-closure bootstrap, factored for any screen: a closure containing
    the whole seed row contains the whole block. -/
theorem closure_complete_of_seedRow {t : ℕ} {S : Finset (Cell n t)}
    (h : ∀ x : ZMod n, Inferable S (⟨0, Nat.succ_pos t⟩, x)) (p : Cell n t) :
    Inferable S p := by
  obtain ⟨⟨i, hi⟩, x⟩ := p
  induction i generalizing x with
  | zero => exact h x
  | succ i ihi =>
    have hit : i < t := by omega
    have h1 : Inferable S (⟨i, by omega⟩, x - 1) := ihi (x - 1) (by omega)
    have h2 : Inferable S (⟨i, by omega⟩, x + 1) := ihi (x + 1) (by omega)
    exact Inferable.down (i := ⟨i, hit⟩) h1 h2

/-- **T36a — complete local decodability of causal worldline screens.** At
    the sharp threshold the propagation closure of a 1-Lipschitz worldline
    screen is the entire spacetime block — T30b's adjacent-tube statement,
    extended from the static observer to every observer moving at or below
    the lattice light speed. -/
theorem pathScreen_closure_complete [NeZero n] (t : ℕ) (c : ℕ → ℤ)
    (j₀ : ZMod n) (hc : ∀ i, i < t → (c (i + 1) - c i).natAbs ≤ 1)
    (hn : n ≤ 2 * (t + 1)) (p : Cell n t) :
    Inferable (pathScreen t c j₀) p :=
  closure_complete_of_seedRow
    (fun x => pathScreen_seedRow_inferable t c j₀ hc hn x) p

/-- Soundness bridge, factored for any screen: a screen whose closure
    reaches the whole seed row is an information set. -/
theorem isInformationSet_of_seedRow_inferable {t : ℕ} {S : Finset (Cell n t)}
    (h : ∀ x : ZMod n, Inferable S (⟨0, Nat.succ_pos t⟩, x)) :
    IsInformationSet S := by
  intro x y hxy
  funext v
  have h0 := inferable_sound (h v) x y hxy
  simpa using h0

/-- **T36b — the Lipschitz worldline theorem, positive half.** Every
    1-Lipschitz worldline screen is an information set at the sharp
    threshold. -/
theorem pathScreen_isInformationSet [NeZero n] (t : ℕ) (c : ℕ → ℤ)
    (j₀ : ZMod n) (hc : ∀ i, i < t → (c (i + 1) - c i).natAbs ≤ 1)
    (hn : n ≤ 2 * (t + 1)) : IsInformationSet (pathScreen t c j₀) :=
  isInformationSet_of_seedRow_inferable fun x =>
    pathScreen_seedRow_inferable t c j₀ hc hn x

/-- **T36b′ — sharp.** For 1-Lipschitz worldlines the threshold is exactly
    the counting bound, uniformly in the path: worldline screens carry full
    capacity iff `n ≤ 2(t+1)`. -/
theorem pathScreen_isInformationSet_iff [NeZero n] (t : ℕ) (c : ℕ → ℤ)
    (j₀ : ZMod n) (hc : ∀ i, i < t → (c (i + 1) - c i).natAbs ≤ 1) :
    IsInformationSet (pathScreen t c j₀) ↔ n ≤ 2 * (t + 1) := by
  constructor
  · intro h
    by_contra hn
    exact card_lt_not_informationSet
      (lt_of_le_of_lt (pathScreen_card_le t c j₀) (by omega)) h
  · exact pathScreen_isInformationSet t c j₀ hc

/-! ## The slope conjecture (holes-audit F6), closed -/

/-- The floor path of a slope `p/q ≤ 1` takes steps in `{0, 1}`. -/
private theorem slope_floor_step (p q i : ℕ) (hpq : p ≤ q) :
    ((((i + 1) * p / q : ℕ) : ℤ) - ((i * p / q : ℕ) : ℤ)).natAbs ≤ 1 := by
  have h1 : i * p / q ≤ (i + 1) * p / q :=
    Nat.div_le_div_right (Nat.mul_le_mul_right p (by omega))
  have h2 : (i + 1) * p / q ≤ i * p / q + 1 := by
    rcases Nat.eq_zero_or_pos q with hq | hq
    · subst hq
      simp
    · have hmul : (i + 1) * p = i * p + p := by ring
      rw [hmul]
      calc (i * p + p) / q ≤ (i * p + q) / q := Nat.div_le_div_right (by omega)
        _ = i * p / q + 1 := Nat.add_div_right _ hq
  omega

/-- `slopeTube` is the worldline screen of the floor path. -/
theorem slopeTube_eq_pathScreen [NeZero n] (p q t : ℕ) (j₀ : ZMod n) :
    slopeTube p q t j₀
      = pathScreen t (fun i => ((i * p / q : ℕ) : ℤ)) j₀ := by
  unfold slopeTube pathScreen
  congr 1
  · funext i
    simp only [Int.cast_natCast]
  · funext i
    simp only [Int.cast_natCast]

/-- **T36c — the slope conjecture, positive half (holes-audit F6).** Every
    rational-slope screen with `0 ≤ p/q ≤ 1` is an information set at the
    sharp threshold — for every `n`, `t`, base point and slope. The v8
    kernel instances (`slope_half_8_3` …) are sample points of this
    theorem. -/
theorem slopeTube_isInformationSet [NeZero n] {p q : ℕ} (t : ℕ)
    (hpq : p ≤ q) (j₀ : ZMod n) (hn : n ≤ 2 * (t + 1)) :
    IsInformationSet (slopeTube p q t j₀) := by
  rw [slopeTube_eq_pathScreen]
  exact pathScreen_isInformationSet t _ j₀
    (fun i _ => slope_floor_step p q i hpq) hn

/-- **T36c′ — the slope conjecture, closed sharp.** A sloped screen of any
    rational slope `0 ≤ p/q ≤ 1` is an information set **iff**
    `n ≤ 2(t+1)`. Together with T9 (slope 0) and T18a (slope 1) — both now
    corollaries — this is the full statement conjectured in §7 item 6 of
    the chain document and F6 of the adversarial audit. -/
theorem slopeTube_isInformationSet_iff [NeZero n] {p q : ℕ} (t : ℕ)
    (hpq : p ≤ q) (j₀ : ZMod n) :
    IsInformationSet (slopeTube p q t j₀) ↔ n ≤ 2 * (t + 1) := by
  constructor
  · intro h
    by_contra hn
    exact slopeTube_not_informationSet p q t j₀ (by omega) h
  · exact slopeTube_isInformationSet t hpq j₀

/-! ## Beyond Lipschitz: the wild regime, machine-checked

The Lipschitz bound is sufficient at every size — but not necessary at any
fixed small size, and no coarse invariant classifies arbitrary paths. The
kernel instances below pin the three phenomena; the full `8^4`-path sweep
at `(8,3)` lives in `evidence/path_screen_sweep.txt`. -/

section Instances

set_option maxRecDepth 8192
set_option maxHeartbeats 3200000

/-- **T36d — the complete pair-screen classification at `(n,t) = (6,2)`.**
    A pair screen `![a, b, c]` at exact capacity decodes **iff its last
    step is Lipschitz** — the first step is completely free. In particular
    decodability is order-sensitive: `![j₀,0,2]` fails while `![j₀,2,2]`
    decodes, with the same step multiset. -/
theorem pairScreen_class_6_2 :
    ∀ a b c : ZMod 6,
      IsInformationSet (pairScreen 2 ![a, b, c]) ↔ ringDist b c ≤ 1 := by
  decide

/-- At `(8,3)`, the superluminal slope-2 line decodes at exact capacity —
    Lipschitz is not necessary there (the full sweep decodes all `8^4`
    paths). -/
theorem pairScreen_slope2_8_3 :
    IsInformationSet (pairScreen 3 (![0, 2, 4, 6] : Fin 4 → ZMod 8)) := by
  decide

/-- At `(8,3)` even a teleporting path (jump 4 = half the ring, twice)
    decodes at exact capacity. -/
theorem pairScreen_teleport_8_3 :
    IsInformationSet (pairScreen 3 (![0, 4, 0, 4] : Fin 4 → ZMod 8)) := by
  decide

/-- At `(10,4)` the `(8,3)` universality dies: the slope-2 line **fails**
    at exact capacity — 10 cells on a 10-ring that do not determine the
    seed. Superluminal screens can drop below capacity. -/
theorem pairScreen_slope2_fails_10_4 :
    ¬ IsInformationSet (pairScreen 4 (![0, 2, 4, 6, 8] : Fin 5 → ZMod 10)) := by
  decide

/-- At `(10,4)` the late jump fails … -/
theorem pairScreen_late_jump_fails_10_4 :
    ¬ IsInformationSet (pairScreen 4 (![0, 0, 0, 0, 2] : Fin 5 → ZMod 10)) := by
  decide

/-- … while the same jump one step earlier decodes: order sensitivity is
    not a small-`n` artifact. -/
theorem pairScreen_early_jump_10_4 :
    IsInformationSet (pairScreen 4 (![0, 0, 0, 2, 2] : Fin 5 → ZMod 10)) := by
  decide

end Instances

/-! ### Axiom audit -/
#print axioms pathScreen_fan
#print axioms pathScreen_closure_complete
#print axioms pathScreen_isInformationSet_iff
#print axioms slopeTube_isInformationSet_iff
#print axioms pairScreen_class_6_2
#print axioms pairScreen_slope2_fails_10_4

end OPHProofChain.Rule90
