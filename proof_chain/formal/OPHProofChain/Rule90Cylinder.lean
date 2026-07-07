import Mathlib

/-!
# The QECC-strength carrier theorem: Rule-90 holography on the n-cylinder

This module proves the theorem named as the **open jewel** in
`chi_nu_test/proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md` §7.2 (and review R1
of `AUDIT_RESPONSE_REVIEW.md`): *reconstruction from proper boundary subsets
on genuinely multi-edge carriers with constraint redundancy* — generalizing
the width-3, one-step Rule-90 toy of
`observer-patch-holography/LEAN/ObserverPatchHolography/Rule90.lean` to
**n cells and t steps**, with a **sharp** information-set characterization.

## Setting

Rule 90 on the cyclic lattice `ZMod n` over `𝔽₂ = ZMod 2`:
`evolve x j = x (j−1) + x (j+1)`; a spacetime block is the trajectory
`traj x0 : ℕ → Row n` of a seed row. The valid blocks form an `𝔽₂`-linear
code of dimension `n` (the seed is free, everything else determined). The
decodability question: *which subsets of spacetime cells determine the whole
block?*

## Results

* `tube_information_set` — **the timelike holographic screen**: the width-2
  tube `{(i, j₀), (i, j₀+1) : i ≤ t}` determines the seed (hence the whole
  block) whenever `n ≤ 2(t+1)`. The proof is a *sideways* light-cone sweep:
  the Rule-90 constraint can be solved for the left (resp. right) neighbour,
  so two adjacent known columns propagate outward, losing one time step per
  column — the left sweep is obtained from the right sweep by a reflection
  symmetry of the dynamics (`traj_reflect`).
* `tube_not_information_set_of_lt` — **sharpness**: if `n > 2(t+1)` the tube
  (which has exactly `2(t+1)` cells) cannot determine the `2^n` seeds, by
  counting.
* `tube_information_set_iff` — the sharp threshold: the tube is an
  information set **iff** `n ≤ 2(t+1)`, i.e. **iff its raw cell count meets
  the code dimension**. The lightcone bound and the counting bound coincide:
  *the timelike screen saturates the information bound* — a perfect
  holographic screen, with the erasure-correction content carried by the
  constraint redundancy (`2(t+1)` read cells stand in for `n` seed cells;
  for `n ≥ 3, t ≥ n − 2` the tube reads a proper, arbitrarily sparse
  fraction of each row).
* `single_column_not_information_set` — **width 1 fails for every horizon**:
  for `n ≥ 3` a mirror-symmetric nonzero seed keeps the observed column
  identically zero **for all time** (`n = 2`: `single_column_fails_two`, by
  nilpotency). So the minimal timelike screen width is exactly 2.
* `spacelike_proper_subset_fails` — on the cylinder, *no* proper subset of
  the initial row is an information set (counting): the spacelike/timelike
  asymmetry is sharp. (The width-3 toy's proper-subset *row* reconstruction
  lives on a *fixed-boundary* lattice, whose boundary conditions cut the
  code dimension; on the cylinder the redundancy is available only to
  timelike screens.)

`CarrierBridge.lean` packages `tube_information_set` as an `H_fib` discharge
in the exact binder form of the Lean core's
`boundary_fiber_observer_unique`, on a genuinely multi-edge carrier.

Axioms: standard (`propext`, `Classical.choice`, `Quot.sound`); no `sorry`,
no `native_decide`.
-/

namespace OPHProofChain.Rule90

/-- A row of the cyclic Rule-90 lattice: an `𝔽₂` value per cell. -/
abbrev Row (n : ℕ) : Type := ZMod n → ZMod 2

variable {n : ℕ}

/-- One Rule-90 step on the cylinder: each cell becomes the sum (XOR) of its
    two neighbours. -/
def evolve (x : Row n) : Row n := fun j => x (j - 1) + x (j + 1)

/-- The trajectory (spacetime block) of a seed row. -/
def traj (x0 : Row n) : ℕ → Row n
  | 0 => x0
  | i + 1 => evolve (traj x0 i)

@[simp] theorem traj_zero (x0 : Row n) : traj x0 0 = x0 := rfl

theorem traj_succ (x0 : Row n) (i : ℕ) :
    traj x0 (i + 1) = evolve (traj x0 i) := rfl

/-- The Rule-90 constraint, pointwise. -/
theorem traj_succ_apply (x0 : Row n) (i : ℕ) (j : ZMod n) :
    traj x0 (i + 1) j = traj x0 i (j - 1) + traj x0 i (j + 1) := rfl

/-! ### Linearity -/

theorem evolve_sub (x y : Row n) : evolve (x - y) = evolve x - evolve y := by
  funext j
  simp only [evolve, Pi.sub_apply]
  ring

@[simp] theorem evolve_zero : evolve (0 : Row n) = 0 := by
  funext j
  simp [evolve]

theorem traj_sub (x y : Row n) (i : ℕ) :
    traj (x - y) i = traj x i - traj y i := by
  induction i with
  | zero => rfl
  | succ i ih => rw [traj_succ, traj_succ, traj_succ, ih, evolve_sub]

@[simp] theorem traj_zero_seed (i : ℕ) : traj (0 : Row n) i = 0 := by
  induction i with
  | zero => rfl
  | succ i ih => rw [traj_succ, ih, evolve_zero]

/-! ### Reflection symmetry

Rule 90 commutes with every reflection `c ↦ m − c` of the cylinder. This
converts the rightward sideways sweep into the leftward one and drives the
mirror-kernel construction for single columns. -/

theorem evolve_reflect (m : ZMod n) (x : Row n) :
    evolve (fun c => x (m - c)) = fun c => evolve x (m - c) := by
  funext j
  show x (m - (j - 1)) + x (m - (j + 1)) = x ((m - j) - 1) + x ((m - j) + 1)
  have h1 : m - (j - 1) = (m - j) + 1 := by ring
  have h2 : m - (j + 1) = (m - j) - 1 := by ring
  rw [h1, h2, add_comm]

theorem traj_reflect (m : ZMod n) (z : Row n) (i : ℕ) :
    traj (fun c => z (m - c)) i = fun c => traj z i (m - c) := by
  induction i with
  | zero => rfl
  | succ i ih => rw [traj_succ, ih, evolve_reflect, traj_succ]

/-! ### The sideways light-cone sweep -/

/-- **Rightward sweep.** If the two adjacent columns `j₀, j₀+1` of a
    trajectory vanish up to time `t`, then column `j₀+1+r` vanishes up to
    time `t − r`: the Rule-90 constraint is solved sideways,
    `x_i(j+1) = x_{i+1}(j) − x_i(j−1)`, losing one time step per column. -/
theorem right_sweep (z : Row n) (t : ℕ) (j₀ : ZMod n)
    (h0 : ∀ i, i ≤ t → traj z i j₀ = 0)
    (h1 : ∀ i, i ≤ t → traj z i (j₀ + 1) = 0) :
    ∀ r : ℕ, ∀ i, i + r ≤ t → traj z i (j₀ + 1 + (r : ZMod n)) = 0 := by
  -- two-step recursion: carry the claim for `r` and `r+1` together
  suffices H : ∀ r : ℕ,
      (∀ i, i + r ≤ t → traj z i (j₀ + 1 + (r : ZMod n)) = 0) ∧
      (∀ i, i + (r + 1) ≤ t → traj z i (j₀ + 1 + ((r + 1 : ℕ) : ZMod n)) = 0) by
    intro r
    exact (H r).1
  intro r
  induction r with
  | zero =>
    constructor
    · intro i hi
      simpa using h1 i (by omega)
    · intro i hi
      -- column `j₀+2` from the constraint at `(i, j₀+1)`
      have hrule : traj z i (j₀ + 1 - 1) + traj z i (j₀ + 1 + 1) =
          traj z (i + 1) (j₀ + 1) := (traj_succ_apply z i (j₀ + 1)).symm
      have hcol : j₀ + 1 - 1 = j₀ := by ring
      rw [hcol] at hrule
      have hz2 : traj z i (j₀ + 1 + 1) =
          traj z (i + 1) (j₀ + 1) - traj z i j₀ := eq_sub_of_add_eq' hrule
      have e1 : traj z (i + 1) (j₀ + 1) = 0 := h1 (i + 1) (by omega)
      have e0 : traj z i j₀ = 0 := h0 i (by omega)
      have : ((0 + 1 : ℕ) : ZMod n) = 1 := by norm_num
      rw [this, hz2, e1, e0, sub_zero]
  | succ r ih =>
    constructor
    · exact ih.2
    · intro i hi
      -- column `j₀+1+(r+2)` from the constraint at `(i, j₀+1+(r+1))`
      have hrule : traj z i (j₀ + 1 + ((r + 1 : ℕ) : ZMod n) - 1) +
          traj z i (j₀ + 1 + ((r + 1 : ℕ) : ZMod n) + 1) =
          traj z (i + 1) (j₀ + 1 + ((r + 1 : ℕ) : ZMod n)) :=
        (traj_succ_apply z i _).symm
      have hcl : j₀ + 1 + ((r + 1 : ℕ) : ZMod n) - 1 = j₀ + 1 + (r : ZMod n) := by
        push_cast
        ring
      have hcr : j₀ + 1 + ((r + 1 : ℕ) : ZMod n) + 1 =
          j₀ + 1 + ((r + 1 + 1 : ℕ) : ZMod n) := by
        push_cast
        ring
      rw [hcl, hcr] at hrule
      have hz2 : traj z i (j₀ + 1 + ((r + 1 + 1 : ℕ) : ZMod n)) =
          traj z (i + 1) (j₀ + 1 + ((r + 1 : ℕ) : ZMod n)) -
            traj z i (j₀ + 1 + (r : ZMod n)) := eq_sub_of_add_eq' hrule
      have e1 : traj z (i + 1) (j₀ + 1 + ((r + 1 : ℕ) : ZMod n)) = 0 :=
        ih.2 (i + 1) (by omega)
      have e0 : traj z i (j₀ + 1 + (r : ZMod n)) = 0 := ih.1 i (by omega)
      rw [hz2, e1, e0, sub_zero]

/-- **Leftward sweep**, by reflecting the rightward one through the midpoint
    of the tube (`m = 2j₀ + 1` swaps `j₀ ↔ j₀+1`). -/
theorem left_sweep (z : Row n) (t : ℕ) (j₀ : ZMod n)
    (h0 : ∀ i, i ≤ t → traj z i j₀ = 0)
    (h1 : ∀ i, i ≤ t → traj z i (j₀ + 1) = 0) :
    ∀ l : ℕ, ∀ i, i + l ≤ t → traj z i (j₀ - (l : ZMod n)) = 0 := by
  intro l i hil
  set m : ZMod n := 2 * j₀ + 1 with hm
  have hrefl := traj_reflect m z
  -- the reflected trajectory has its tube columns j₀, j₀+1 vanishing
  have h0' : ∀ i, i ≤ t → traj (fun c => z (m - c)) i j₀ = 0 := by
    intro i hi
    have hcf : traj (fun c => z (m - c)) i j₀ = traj z i (m - j₀) :=
      congrFun (hrefl i) j₀
    rw [hcf, show m - j₀ = j₀ + 1 from by rw [hm]; ring]
    exact h1 i hi
  have h1' : ∀ i, i ≤ t → traj (fun c => z (m - c)) i (j₀ + 1) = 0 := by
    intro i hi
    have hcf : traj (fun c => z (m - c)) i (j₀ + 1) = traj z i (m - (j₀ + 1)) :=
      congrFun (hrefl i) (j₀ + 1)
    rw [hcf, show m - (j₀ + 1) = j₀ from by rw [hm]; ring]
    exact h0 i hi
  have key := right_sweep (fun c => z (m - c)) t j₀ h0' h1' l i hil
  have hcf : traj (fun c => z (m - c)) i (j₀ + 1 + (l : ZMod n)) =
      traj z i (m - (j₀ + 1 + (l : ZMod n))) := congrFun (hrefl i) _
  rw [hcf, show m - (j₀ + 1 + (l : ZMod n)) = j₀ - (l : ZMod n) from by
    rw [hm]; ring] at key
  exact key

/-! ### The vanishing theorem -/

/-- **Vanishing theorem.** On the `n`-cylinder with `n ≤ 2(t+1)`, a
    trajectory whose width-2 tube `{j₀, j₀+1}` vanishes up to time `t` has
    zero seed. Every cell of the seed row is within sideways light-cone
    reach of one of the two sweeps. -/
theorem seed_eq_zero_of_tube_zero [NeZero n] (z : Row n) (t : ℕ) (j₀ : ZMod n)
    (hn : n ≤ 2 * (t + 1))
    (h0 : ∀ i, i ≤ t → traj z i j₀ = 0)
    (h1 : ∀ i, i ≤ t → traj z i (j₀ + 1) = 0) :
    z = 0 := by
  funext c
  -- write `c = j₀ + 1 + r` with `r = (c − (j₀+1)).val < n`
  set r : ℕ := (c - (j₀ + 1)).val with hr
  have hrn : r < n := ZMod.val_lt _
  have hcast : ((r : ℕ) : ZMod n) = c - (j₀ + 1) := by
    rw [hr]
    exact ZMod.natCast_rightInverse _
  have hc : c = j₀ + 1 + (r : ZMod n) := by
    rw [hcast]
    ring
  by_cases hrt : r ≤ t
  · -- rightward reach
    have := right_sweep z t j₀ h0 h1 r 0 (by omega)
    rw [traj_zero] at this
    rw [hc]
    exact this
  · -- leftward reach: `c = j₀ − l` with `l = n − 1 − r ≤ t`
    push_neg at hrt
    set l : ℕ := n - 1 - r with hl
    have hlt : l ≤ t := by omega
    have hcl : c = j₀ - (l : ZMod n) := by
      have hln : (l : ZMod n) = (n : ZMod n) - 1 - (r : ZMod n) := by
        rw [hl]
        push_cast [Nat.cast_sub (by omega : r ≤ n - 1), Nat.cast_sub (by omega : 1 ≤ n)]
        ring
      rw [hln, ZMod.natCast_self, hcast]
      ring
    have := left_sweep z t j₀ h0 h1 l 0 (by omega)
    rw [traj_zero] at this
    rw [hcl]
    exact this

/-! ### The sharp information-set theorem -/

/-- The width-2 timelike tube readout: both tube columns, times `0 … t`. -/
def tubeData (j₀ : ZMod n) (t : ℕ) (x0 : Row n) :
    Fin (t + 1) → ZMod 2 × ZMod 2 :=
  fun i => (traj x0 i j₀, traj x0 i (j₀ + 1))

/-- **The timelike holographic screen (sufficiency).** For `n ≤ 2(t+1)`, the
    width-2 tube is an information set: equal tube data forces equal seeds
    (hence equal spacetime blocks). -/
theorem tube_information_set [NeZero n] (j₀ : ZMod n) (t : ℕ)
    (hn : n ≤ 2 * (t + 1)) :
    Function.Injective (tubeData (n := n) j₀ t) := by
  intro x0 y0 htube
  have hz : x0 - y0 = 0 := by
    apply seed_eq_zero_of_tube_zero (t := t) (j₀ := j₀) _ hn
    · intro i hi
      have := congrFun htube ⟨i, by omega⟩
      have h := congrArg Prod.fst this
      simp only [tubeData] at h
      rw [traj_sub, Pi.sub_apply, h, sub_self]
    · intro i hi
      have := congrFun htube ⟨i, by omega⟩
      have h := congrArg Prod.snd this
      simp only [tubeData] at h
      rw [traj_sub, Pi.sub_apply, h, sub_self]
  exact sub_eq_zero.mp hz

/-- **Sharpness (counting).** For `n > 2(t+1)` the tube readout cannot be
    injective: `2^n` seeds, only `4^(t+1) = 2^(2(t+1))` tube values. -/
theorem tube_not_information_set_of_lt [NeZero n] (j₀ : ZMod n) (t : ℕ)
    (hn : 2 * (t + 1) < n) :
    ¬ Function.Injective (tubeData (n := n) j₀ t) := by
  intro hinj
  have hcard := Fintype.card_le_of_injective _ hinj
  have hrow : Fintype.card (Row n) = 2 ^ n := by
    rw [Fintype.card_fun, ZMod.card, ZMod.card]
  have htube : Fintype.card (Fin (t + 1) → ZMod 2 × ZMod 2) = 2 ^ (2 * (t + 1)) := by
    rw [Fintype.card_fun, Fintype.card_prod, ZMod.card, Fintype.card_fin]
    rw [show (2 * 2 : ℕ) = 2 ^ 2 by norm_num, ← pow_mul]
  rw [hrow, htube] at hcard
  have := (Nat.pow_le_pow_iff_right (by norm_num : 1 < 2)).mp hcard
  omega

/-- **THE SHARP THRESHOLD.** The width-2 timelike tube of duration `t` on the
    `n`-cylinder is an information set **iff** `n ≤ 2(t+1)` — iff its raw
    cell count `2(t+1)` meets the code dimension `n`. The sideways lightcone
    bound and the information-counting bound coincide exactly: the screen is
    information-theoretically perfect. -/
theorem tube_information_set_iff [NeZero n] (j₀ : ZMod n) (t : ℕ) :
    Function.Injective (tubeData (n := n) j₀ t) ↔ n ≤ 2 * (t + 1) := by
  constructor
  · intro hinj
    by_contra hn
    exact tube_not_information_set_of_lt j₀ t (by omega) hinj
  · exact tube_information_set j₀ t

/-! ### Width 1 fails for every horizon -/

/-- The one-cell indicator row. -/
def delta (a : ZMod n) : Row n := fun c => if c = a then 1 else 0

theorem delta_apply_self (a : ZMod n) : delta a a = 1 := if_pos rfl

theorem delta_apply_of_ne {a c : ZMod n} (h : c ≠ a) : delta a c = 0 := if_neg h

/-- Reflecting an indicator: `δ_a(m − c) = δ_{m−a}(c)`. -/
theorem delta_reflect (m a c : ZMod n) :
    delta a (m - c) = delta (m - a) c := by
  unfold delta
  refine if_congr ?_ rfl rfl
  constructor
  · intro h
    linear_combination -h
  · intro h
    linear_combination -h

/-- **Width 1 fails (mirror kernel), `n ≥ 3`.** The mirror-symmetric seed
    `δ_{j₀+1} + δ_{j₀−1}` is nonzero, yet its whole trajectory vanishes on
    column `j₀` for **all** time: reflection symmetry through `j₀` makes the
    two neighbour contributions cancel in `𝔽₂`. So no single column — no
    matter how long observed — determines the bulk. -/
theorem single_column_not_information_set (hn : 3 ≤ n) (j₀ : ZMod n) :
    ∃ z : Row n, z ≠ 0 ∧ ∀ i : ℕ, traj z i j₀ = 0 := by
  haveI : NeZero n := ⟨by omega⟩
  -- the mirror-symmetric two-cell seed
  set z : Row n := delta (j₀ + 1) + delta (j₀ - 1) with hz
  have hpair : j₀ + 1 ≠ j₀ - 1 := by
    intro h
    have h2 : ((2 : ℕ) : ZMod n) = 0 := by
      push_cast
      linear_combination h
    have hdvd := (CharP.cast_eq_zero_iff (ZMod n) n 2).mp h2
    have := Nat.le_of_dvd (by norm_num) hdvd
    omega
  refine ⟨z, ?_, ?_⟩
  · -- nonzero at cell j₀+1
    intro h0
    have := congrFun h0 (j₀ + 1)
    rw [hz, Pi.add_apply, delta_apply_self, delta_apply_of_ne hpair,
      Pi.zero_apply] at this
    exact one_ne_zero this
  · -- column j₀ vanishes forever
    -- mirror symmetry of the seed …
    have hsym : (fun c => z ((2 * j₀) - c)) = z := by
      funext c
      rw [hz, Pi.add_apply, Pi.add_apply, delta_reflect, delta_reflect]
      have e1 : (2 * j₀) - (j₀ + 1) = j₀ - 1 := by ring
      have e2 : (2 * j₀) - (j₀ - 1) = j₀ + 1 := by ring
      rw [e1, e2, add_comm]
    -- … propagates to the whole trajectory
    have htraj : ∀ i (c : ZMod n), traj z i ((2 * j₀) - c) = traj z i c := by
      intro i c
      have := congrFun (traj_reflect (2 * j₀) z i) c
      rw [hsym] at this
      exact this.symm
    -- neighbours of j₀ are mirror images, so their 𝔽₂ sum cancels
    intro i
    induction i with
    | zero =>
      show z j₀ = 0
      have hne1 : j₀ ≠ j₀ + 1 := by
        intro h
        have : (1 : ZMod n) = 0 := by linear_combination - h
        have h1 : ((1 : ℕ) : ZMod n) = 0 := by push_cast; exact this
        have hdvd := (CharP.cast_eq_zero_iff (ZMod n) n 1).mp h1
        have := Nat.le_of_dvd (by norm_num) hdvd
        omega
      have hne2 : j₀ ≠ j₀ - 1 := by
        intro h
        have : (1 : ZMod n) = 0 := by linear_combination h
        have h1 : ((1 : ℕ) : ZMod n) = 0 := by push_cast; exact this
        have hdvd := (CharP.cast_eq_zero_iff (ZMod n) n 1).mp h1
        have := Nat.le_of_dvd (by norm_num) hdvd
        omega
      rw [hz, Pi.add_apply, delta_apply_of_ne hne1, delta_apply_of_ne hne2,
        add_zero]
    | succ i _ =>
      rw [traj_succ_apply]
      have hmirror : traj z i (j₀ - 1) = traj z i (j₀ + 1) := by
        have := htraj i (j₀ + 1)
        have e : (2 * j₀) - (j₀ + 1) = j₀ - 1 := by ring
        rw [e] at this
        exact this
      rw [hmirror]
      exact (show ∀ a : ZMod 2, a + a = 0 by decide) _

/-- **Width 1 fails, `n = 2`** (nilpotency: on the 2-cylinder both neighbours
    coincide, so every step doubles and kills everything in `𝔽₂`). -/
theorem single_column_fails_two (j₀ : ZMod 2) :
    ∃ z : Row 2, z ≠ 0 ∧ ∀ i : ℕ, traj z i j₀ = 0 := by
  refine ⟨delta (j₀ + 1), ?_, ?_⟩
  · intro h0
    have := congrFun h0 (j₀ + 1)
    rw [delta_apply_self, Pi.zero_apply] at this
    exact one_ne_zero this
  · have hstep : ∀ x : Row 2, evolve x = 0 := by
      intro x
      funext j
      show x (j - 1) + x (j + 1) = 0
      have : j - 1 = j + 1 := by
        have h2 : (2 : ZMod 2) = 0 := by decide
        linear_combination -h2
      rw [this]
      exact (show ∀ a : ZMod 2, a + a = 0 by decide) _
    intro i
    cases i with
    | zero =>
      exact delta_apply_of_ne (by
        intro h
        have : (1 : ZMod 2) = 0 := by linear_combination - h
        exact one_ne_zero this)
    | succ i =>
      rw [traj_succ, hstep]
      rfl

/-- Two **distinct trajectories with identical single-column history**: the
    non-injectivity form of `single_column_not_information_set`. -/
theorem single_column_two_trajectories (hn : 3 ≤ n) (j₀ : ZMod n) :
    ∃ x0 y0 : Row n, x0 ≠ y0 ∧ ∀ i : ℕ, traj x0 i j₀ = traj y0 i j₀ := by
  obtain ⟨z, hz0, hzcol⟩ := single_column_not_information_set hn j₀
  exact ⟨z, 0, hz0, fun i => by rw [hzcol i, traj_zero_seed, Pi.zero_apply]⟩

/-! ### The spacelike side: no proper subset of the initial row works -/

/-- On the cylinder, **no proper subset of the initial row** determines the
    seed — reading spacelike data buys nothing beyond the cells read. The
    contrast with `tube_information_set` (a *timelike* screen of the same
    cardinality does reconstruct) is the sharp spacelike/timelike asymmetry
    of the carrier. -/
theorem spacelike_proper_subset_fails [NeZero n] (S : Finset (ZMod n))
    (hS : S ≠ Finset.univ) :
    ∃ x0 y0 : Row n, x0 ≠ y0 ∧ ∀ c ∈ S, x0 c = y0 c := by
  obtain ⟨c0, hc0⟩ : ∃ c0 : ZMod n, c0 ∉ S := by
    by_contra h
    push_neg at h
    exact hS (Finset.eq_univ_iff_forall.mpr h)
  refine ⟨delta c0, 0, ?_, ?_⟩
  · intro h0
    have := congrFun h0 c0
    rw [delta_apply_self, Pi.zero_apply] at this
    exact one_ne_zero this
  · intro c hc
    rw [delta_apply_of_ne (by rintro rfl; exact hc0 hc), Pi.zero_apply]

/-! ### Axiom audit -/
#print axioms tube_information_set
#print axioms tube_not_information_set_of_lt
#print axioms tube_information_set_iff
#print axioms single_column_not_information_set
#print axioms single_column_fails_two
#print axioms spacelike_proper_subset_fails

end OPHProofChain.Rule90
