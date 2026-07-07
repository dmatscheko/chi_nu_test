import Mathlib
import OPHProofChain.Rule90Cylinder
import OPHProofChain.Rule90Decoding

/-!
# The coprimality classification of two-column screens (T25)

`Rule90Decoding.lean` (v4/v5) settled the width-2 screen geometry for
strides 1 and 2: the adjacent tube decodes iff `n ≤ 2(t+1)` (T9, both
parities), the lightlike tilt has the same sharp threshold (T18, boost
invariance), and the gap-2 tube decodes iff `n` is odd — at the same
threshold (T20, the parity classification). The proof chain's §7 then
conjectured, "from T20's mechanism": *gapped screens of general stride `g`
have capacity iff `gcd(g, n) = 1`*.

This module **proves the conjecture, in sharp form**: for every stride,

```
gapTube_isInformationSet_iff :
    the two-column screen {j₀, j₀+g} × [0,t] is an information set
    ⟺  gcd(g, n) = 1  ∧  n ≤ 2(t+1)
```

— coprime strides lose *nothing*: they recover the **full adjacent
capacity at the same sharp threshold**, and non-coprime strides fail at
**every** horizon. T9's sufficiency (`g = 1`), T20's parity classification
(`g = 2`: `gcd(2,n) = 1 ⟺ n` odd), and the width-1 negatives (`g ≡ 0`:
`gcd = n`) are all corollaries of the one statement (re-derived at the end
of this file as consistency checks — the originals stand untouched).

## The two mechanisms

**The mirror lemma (`mirror_of_column_dark`) — new.** A *single* dark
column of depth `t` forces the seed to be mirror-symmetric about that
column whenever `n ≤ 2(t+1)`. Proof idea: the mirror defect
`D_i(u) = x_i(j₀+u) + x_i(j₀−u)` is itself a Rule-90 trajectory in the
displacement variable (the stencil is symmetric, so the defect closes
under the rule), it vanishes identically at displacement `0`, and the
dark column makes it vanish at displacement `1` — so the defect is dark
on an **adjacent pair** of columns and dies by a one-sided sideways sweep.
On even cylinders the antipodal displacement is out of the sweep's reach
but *identically zero* (it compares the antipodal cell with itself). This
sharpens the v3 picture of the width-1 screen: a single column does not
merely fail — it pins **the whole antisymmetric sector** (plus its own
centre cell, read directly at time 0), and its failure kernel consists of
the mirror-symmetric seeds with dark centre — the v3 mirror-kernel seeds.

**The quotient lift (`traj_comap`) — new.** For `d = gcd(g, n) ≥ 2` the
cylinder covers `ℤ_d` (cell-wise reduction mod `d` is a graph covering,
so trajectories of pulled-back seeds are pulled-back trajectories), and
*both* read columns of the screen land on the **same** column of the
quotient cylinder. Any nonzero seed of `ℤ_d` whose trajectory is dark on
one column — the mirror-pair seed `δ_{+1} + δ_{−1}`, dark by the
symmetry argument above — lifts to a kernel seed of the screen at every
horizon. (For `d = 2` the pair degenerates to the single cell `δ_1` and
the lift is exactly v4's alternating checkerboard seed.)

The success half then composes: dark screen ⇒ (mirror lemma, twice) the
seed is symmetric about *both* columns ⇒ invariant under translation by
`2g` ⇒ (coprimality) constant on each parity class reachable from a read
column, and the two time-0 readings kill both classes. The sharp
threshold `n ≤ 2(t+1)` is exactly what the mirror lemma needs — the
boundary cases are tight in both parities.

Nothing here is physics: it is coding theory for the carrier, completing
the two-column chapter of the §7.6 decodability program. The full
arbitrary-subset classification stays open (and stays a decidable
predicate, `IsInformationSet`).

No `sorry`, no new axioms, no `native_decide` (the cross-check instances
use plain kernel `decide` through the vanishing form).
-/

namespace OPHProofChain.Rule90

variable {n : ℕ}

/-! ### The general two-column screen -/

/-- The stride-`g` two-column screen: columns `{j₀, j₀ + g}`, all times
    `≤ t`. `g = 1` is T9's adjacent tube, `g = 2` is T20's gapped tube,
    `g ≡ 0 (mod n)` degenerates to the width-1 column. -/
def gapTube [NeZero n] (g t : ℕ) (j₀ : ZMod n) : Finset (Cell n t) :=
  colFamily t (fun _ => j₀) (fun _ => j₀ + (g : ZMod n))

theorem mem_gapTube [NeZero n] {g t : ℕ} {j₀ : ZMod n} {p : Cell n t} :
    p ∈ gapTube g t j₀ ↔ p.2 = j₀ ∨ p.2 = j₀ + (g : ZMod n) :=
  mem_colFamily

/-- The stride-`g` screen has at most `2(t+1)` cells. -/
theorem gapTube_card_le [NeZero n] {g t : ℕ} (j₀ : ZMod n) :
    (gapTube g t j₀).card ≤ 2 * (t + 1) :=
  colFamily_card_le _ _

/-! ### The mirror lemma: a dark column forces mirror symmetry

The mirror defect `D_i(u) = x_i(j₀+u) + x_i(j₀−u)` closes under Rule 90
(the stencil is symmetric), vanishes at displacement 0 identically, and
vanishes at displacement 1 exactly because the column is dark one step
later. The sweep below propagates these two dark defect-columns sideways,
one displacement per time step — the same lightcone bookkeeping as the
adjacent tube, in displacement space. -/

/-- **The defect sweep.** If column `j₀` is dark up to time `t`, the
    mirror defect vanishes on the sideways cone: for `1 ≤ u` and
    `i + u ≤ t`, the values at displacements `±u` agree at time `i`. -/
theorem mirror_sweep (z : Row n) (t : ℕ) (j₀ : ZMod n)
    (hdark : ∀ i, i ≤ t → traj z i j₀ = 0) :
    ∀ u : ℕ, 1 ≤ u → ∀ i, i + u ≤ t →
      traj z i (j₀ + (u : ZMod n)) = traj z i (j₀ - (u : ZMod n)) := by
  -- helper: the two-sided constraint, solved for the outer displacement
  have key : ∀ u : ℕ, ∀ i,
      traj z i (j₀ + ((u + 2 : ℕ) : ZMod n)) =
        traj z (i + 1) (j₀ + ((u + 1 : ℕ) : ZMod n)) +
          traj z i (j₀ + (u : ZMod n)) := by
    intro u i
    have hrule := traj_succ_apply z i (j₀ + ((u + 1 : ℕ) : ZMod n))
    have hcl : j₀ + ((u + 1 : ℕ) : ZMod n) - 1 = j₀ + (u : ZMod n) := by
      push_cast; ring
    have hcr : j₀ + ((u + 1 : ℕ) : ZMod n) + 1 = j₀ + ((u + 2 : ℕ) : ZMod n) := by
      push_cast; ring
    rw [hcl, hcr] at hrule
    rw [hrule]
    exact (show ∀ a b : ZMod 2, b = a + b + a from by decide) _ _
  have keyL : ∀ u : ℕ, ∀ i,
      traj z i (j₀ - ((u + 2 : ℕ) : ZMod n)) =
        traj z (i + 1) (j₀ - ((u + 1 : ℕ) : ZMod n)) +
          traj z i (j₀ - (u : ZMod n)) := by
    intro u i
    have hrule := traj_succ_apply z i (j₀ - ((u + 1 : ℕ) : ZMod n))
    have hcl : j₀ - ((u + 1 : ℕ) : ZMod n) - 1 = j₀ - ((u + 2 : ℕ) : ZMod n) := by
      push_cast; ring
    have hcr : j₀ - ((u + 1 : ℕ) : ZMod n) + 1 = j₀ - (u : ZMod n) := by
      push_cast; ring
    rw [hcl, hcr] at hrule
    rw [hrule]
    exact (show ∀ a b : ZMod 2, a = a + b + b from by decide) _ _
  -- displacement 1, at every admissible time: the constraint at the dark column
  have p1 : ∀ i, i + 1 ≤ t →
      traj z i (j₀ + ((1 : ℕ) : ZMod n)) = traj z i (j₀ - ((1 : ℕ) : ZMod n)) := by
    intro i hi
    have hrule := traj_succ_apply z i j₀
    rw [hdark (i + 1) (by omega)] at hrule
    have hc : ((1 : ℕ) : ZMod n) = 1 := by push_cast; ring
    rw [hc]
    exact (show ∀ a b : ZMod 2, 0 = a + b → b = a from by decide) _ _ hrule
  -- paired induction on the displacement
  suffices H : ∀ u : ℕ,
      (∀ i, i + (u + 1) ≤ t →
        traj z i (j₀ + ((u + 1 : ℕ) : ZMod n)) =
          traj z i (j₀ - ((u + 1 : ℕ) : ZMod n))) ∧
      (∀ i, i + (u + 2) ≤ t →
        traj z i (j₀ + ((u + 2 : ℕ) : ZMod n)) =
          traj z i (j₀ - ((u + 2 : ℕ) : ZMod n))) by
    intro u hu i hiu
    obtain ⟨v, rfl⟩ : ∃ v, u = v + 1 := ⟨u - 1, by omega⟩
    exact (H v).1 i hiu
  intro u
  induction u with
  | zero =>
    refine ⟨fun i hi => by simpa using p1 i hi, ?_⟩
    -- displacement 2: `key`/`keyL` at `u = 0` + displacement 1 one step up
    intro i hi
    have hk := key 0 i
    have hkL := keyL 0 i
    have hd : traj z i j₀ = 0 := hdark i (by omega)
    have hz : ((0 : ℕ) : ZMod n) = 0 := by push_cast; ring
    rw [hz, add_zero, hd, add_zero] at hk
    rw [hz, sub_zero, hd, add_zero] at hkL
    rw [hk, hkL]
    simpa using p1 (i + 1) (by omega)
  | succ u ih =>
    constructor
    · exact ih.2
    · -- displacement u+3 from u+2 (one step up) and u+1 (same time)
      intro i hi
      have hk := key (u + 1) i
      have hkL := keyL (u + 1) i
      rw [show u + 1 + 2 = u + 3 from rfl, show u + 1 + 1 = u + 2 from rfl] at hk hkL
      rw [show u + 1 + 2 = u + 3 from rfl]
      rw [hk, hkL, ih.2 (i + 1) (by omega), ih.1 i (by omega)]

/-- **THE MIRROR LEMMA (new).** A single dark column of depth `t` forces
    mirror symmetry about that column, as soon as `n ≤ 2(t+1)`: the
    column pins the whole antisymmetric sector of the seed (and its own
    centre cell, read at time 0). Its failure kernel contains exactly the
    -- (forward inclusion = this lemma; the converse assembles from
    -- `evolve_symmetric`/`evolve_symmetric_center` but is not a named theorem)
    mirror-symmetric seeds with dark centre — v3's mirror seeds — so this
    is sharp in content as well as in threshold. -/
theorem mirror_of_column_dark [NeZero n] (z : Row n) (t : ℕ) (j₀ : ZMod n)
    (hn : n ≤ 2 * (t + 1)) (hdark : ∀ i, i ≤ t → traj z i j₀ = 0) :
    ∀ x : ZMod n, z x = z (2 * j₀ - x) := by
  intro x
  set e : ZMod n := x - j₀ with he
  have hx : x = j₀ + e := by rw [he]; ring
  have hmirror : 2 * j₀ - x = j₀ - e := by rw [he]; ring
  rw [hmirror, hx]
  set u : ℕ := e.val with hu
  have hun : u < n := ZMod.val_lt _
  have hcast : ((u : ℕ) : ZMod n) = e := by rw [hu]; exact ZMod.natCast_rightInverse _
  rcases Nat.eq_zero_or_pos u with h0 | hpos
  · -- displacement 0: both sides are the same cell
    have : e = 0 := by rw [← hcast, h0]; push_cast; ring
    rw [this, add_zero, sub_zero]
  rcases Nat.lt_or_ge u (t + 1) with hut | hut
  · -- inside the sweep cone
    have := mirror_sweep z t j₀ hdark u hpos 0 (by omega)
    rw [traj_zero, hcast] at this
    exact this
  · -- reflect: use the complementary displacement `n − u`
    set v : ℕ := n - u with hv
    have hvcast : ((v : ℕ) : ZMod n) = -e := by
      rw [hv, Nat.cast_sub (le_of_lt hun), ZMod.natCast_self, hcast]; ring
    rcases Nat.lt_or_ge v (t + 1) with hvt | hvt
    · rcases Nat.eq_zero_or_pos v with hv0 | hvpos
      · -- v = 0 forces u = n, impossible
        omega
      have := mirror_sweep z t j₀ hdark v hvpos 0 (by omega)
      rw [traj_zero, hvcast] at this
      -- `z (j₀ + (−e)) = z (j₀ − (−e))` is the goal, flipped
      rw [show j₀ + -e = j₀ - e from by ring, show j₀ - -e = j₀ + e from by ring]
        at this
      exact this.symm
    · -- the antipode: `u = v = t+1`, `n = 2(t+1)`, and `−e = e`
      have huv : u = t + 1 ∧ v = t + 1 := by omega
      have hee : e = -e := by
        nth_rewrite 1 [← hcast]
        rw [huv.1, ← huv.2, hvcast]
      rw [show j₀ - e = j₀ + -e from by ring, ← hee]

/-! ### Success: coprime strides decode at the sharp threshold -/

/-- Mirror symmetry about both read columns forces `2g`-translation
    invariance (the composition of the two reflections). -/
theorem periodic_of_double_mirror {g : ℕ} (z : Row n) (j₀ : ZMod n)
    (h0 : ∀ x : ZMod n, z x = z (2 * j₀ - x))
    (hg : ∀ x : ZMod n, z x = z (2 * (j₀ + (g : ZMod n)) - x)) :
    ∀ x : ZMod n, z (x + ((2 * g : ℕ) : ZMod n)) = z x := by
  intro x
  have step1 := hg (x + ((2 * g : ℕ) : ZMod n))
  have harith : 2 * (j₀ + (g : ZMod n)) - (x + ((2 * g : ℕ) : ZMod n))
      = 2 * j₀ - x := by push_cast; ring
  rw [harith] at step1
  rw [step1, ← h0 x]

/-- Iterating the `2g`-translation invariance. -/
theorem walk_of_periodic {g : ℕ} (z : Row n)
    (hper : ∀ x : ZMod n, z (x + ((2 * g : ℕ) : ZMod n)) = z x) :
    ∀ (x : ZMod n) (k : ℕ), z (x + ((2 * g * k : ℕ) : ZMod n)) = z x := by
  intro x k
  induction k with
  | zero => simp
  | succ k ih =>
    have harith : x + ((2 * g * (k + 1) : ℕ) : ZMod n)
        = (x + ((2 * g * k : ℕ) : ZMod n)) + ((2 * g : ℕ) : ZMod n) := by
      push_cast; ring
    rw [harith, hper, ih]

/-- A unit multiplier reaches every cell: if `(m : ZMod n)` is a unit,
    every `b` is `m·k` for some natural `k`. -/
theorem exists_nat_mul_step [NeZero n] {m : ℕ}
    (hm : IsUnit ((m : ℕ) : ZMod n)) (b : ZMod n) :
    ∃ k : ℕ, b = ((m * k : ℕ) : ZMod n) := by
  obtain ⟨u, hu⟩ := hm.exists_right_inv
  refine ⟨(u * b).val, ?_⟩
  have hval : (((u * b).val : ℕ) : ZMod n) = u * b := ZMod.natCast_rightInverse _
  push_cast
  rw [hval, ← mul_assoc, hu, one_mul]

/-- **The vanishing theorem for coprime strides.** If `gcd(g,n) = 1` and
    `n ≤ 2(t+1)`, a seed dark on both columns of the stride-`g` screen is
    zero: the mirror lemma (twice) gives `2g`-periodicity, and the two
    time-0 readings kill the one or two translation classes. -/
theorem seed_eq_zero_of_gapTube_zero [NeZero n] {g : ℕ}
    (hg : Nat.gcd g n = 1) (z : Row n) (t : ℕ) (j₀ : ZMod n)
    (hn : n ≤ 2 * (t + 1))
    (h0 : ∀ i, i ≤ t → traj z i j₀ = 0)
    (h1 : ∀ i, i ≤ t → traj z i (j₀ + (g : ZMod n)) = 0) : z = 0 := by
  have hz0 : z j₀ = 0 := by simpa using h0 0 (Nat.zero_le t)
  have hzg : z (j₀ + (g : ZMod n)) = 0 := by simpa using h1 0 (Nat.zero_le t)
  -- the two mirror symmetries and the resulting periodicity
  have hsym0 := mirror_of_column_dark z t j₀ hn h0
  have hsymg := mirror_of_column_dark z t (j₀ + (g : ZMod n)) hn h1
  have hper := periodic_of_double_mirror z j₀ hsym0 hsymg
  have hwalk := walk_of_periodic z hper
  have hgunit : IsUnit ((g : ℕ) : ZMod n) :=
    (ZMod.isUnit_iff_coprime g n).mpr hg
  funext c
  show z c = 0
  rcases Nat.even_or_odd n with hnev | hnodd
  · -- even cylinder: `g` is odd; split cells by the parity homomorphism
    obtain ⟨halfn, hhalf⟩ := hnev
    have h2n : (2 : ℕ) ∣ n := ⟨halfn, by omega⟩
    have hgodd : ¬ (2 : ℕ) ∣ g := by
      intro h2g
      have : (2 : ℕ) ∣ Nat.gcd g n := Nat.dvd_gcd h2g h2n
      omega
    -- the parity of a cell, as a ring hom to `ZMod 2`
    set pod : ZMod n →+* ZMod 2 := ZMod.castHom h2n (ZMod 2) with hpod
    have hpodg : pod ((g : ℕ) : ZMod n) = 1 := by
      rw [map_natCast]
      obtain ⟨k, hk⟩ := Nat.odd_iff.mpr (Nat.two_dvd_ne_zero.mp hgodd)
      subst hk
      push_cast
      rw [show (2 : ZMod 2) = 0 from by decide]
      ring
    -- a parity-0 cell is an even displacement, hence `2g`-reachable
    have reach : ∀ b : ZMod n, pod b = 0 → ∃ k : ℕ, b = ((2 * g * k : ℕ) : ZMod n) := by
      intro b hb
      have hbval : (((b.val : ℕ) : ZMod n)) = b := ZMod.natCast_rightInverse _
      have hbpar : ((b.val : ℕ) : ZMod 2) = 0 := by
        have hp : pod ((b.val : ℕ) : ZMod n) = 0 := by rw [hbval, hb]
        rwa [map_natCast] at hp
      have hbeven : (2 : ℕ) ∣ b.val := by
        rcases Nat.even_or_odd b.val with he | ho
        · exact he.two_dvd
        · exfalso
          obtain ⟨k, hk⟩ := ho
          rw [hk] at hbpar
          push_cast at hbpar
          rw [show (2 : ZMod 2) = 0 from by decide] at hbpar
          simp at hbpar
      obtain ⟨m, hm⟩ := hbeven
      obtain ⟨k, hk⟩ := exists_nat_mul_step hgunit ((m : ℕ) : ZMod n)
      refine ⟨k, ?_⟩
      rw [← hbval, hm]
      push_cast
      push_cast at hk
      rw [mul_assoc, ← hk]
  -- decide by the parity of `c − j₀`
    rcases (show ∀ a : ZMod 2, a = 0 ∨ a = 1 from by decide) (pod (c - j₀)) with hc | hc
    · obtain ⟨k, hk⟩ := reach (c - j₀) hc
      have hc' : c = j₀ + ((2 * g * k : ℕ) : ZMod n) := by rw [← hk]; ring
      rw [hc', walk_of_periodic z hper j₀ k]
      exact hz0
    · have hcg : pod (c - (j₀ + (g : ZMod n))) = 0 := by
        rw [show c - (j₀ + (g : ZMod n)) = (c - j₀) - ((g : ℕ) : ZMod n) from by
          ring]
        rw [map_sub, hc, hpodg]
        decide
      obtain ⟨k, hk⟩ := reach _ hcg
      have : c = (j₀ + (g : ZMod n)) + ((2 * g * k : ℕ) : ZMod n) := by
        rw [← hk]; ring
      rw [this, walk_of_periodic z hper _ k]
      exact hzg
  · -- odd cylinder: `2g` is itself a unit, one reading suffices
    have h2co : Nat.Coprime 2 n := hnodd.coprime_two_left
    have h2gco : Nat.Coprime (2 * g) n := Nat.Coprime.mul_left h2co hg
    have h2gunit : IsUnit ((2 * g : ℕ) : ZMod n) :=
      (ZMod.isUnit_iff_coprime (2 * g) n).mpr h2gco
    obtain ⟨k, hk⟩ := exists_nat_mul_step h2gunit (c - j₀)
    have : c = j₀ + ((2 * g * k : ℕ) : ZMod n) := by
      rw [← hk]; ring
    rw [this, walk_of_periodic z hper j₀ k]
    exact hz0

/-! ### Failure: non-coprime strides never decode

The quotient lift. For `d = gcd(g,n) ≥ 2`, reduction mod `d` is a graph
covering `ℤ_n → ℤ_d`, so pulled-back seeds have pulled-back trajectories —
and both read columns land on the single quotient column `π j₀`. The
mirror-pair seed `δ_{π j₀ + 1} + δ_{π j₀ − 1}` on the quotient is dark on
that column forever (its trajectory stays mirror-symmetric, and a
symmetric row always sums to zero at the centre), so its lift is a kernel
seed for the screen at every horizon. -/

section QuotientLift

variable {d : ℕ}

/-- One step commutes with cell-wise reduction: the pullback of a
    configuration evolves to the pullback of its evolution. -/
theorem evolve_comap [NeZero n] [NeZero d] (h : d ∣ n) (w : Row d) :
    evolve (n := n) (fun c => w (ZMod.castHom h (ZMod d) c)) =
      fun c => evolve (n := d) w (ZMod.castHom h (ZMod d) c) := by
  funext c
  show w (ZMod.castHom h (ZMod d) (c - 1)) + w (ZMod.castHom h (ZMod d) (c + 1))
      = w (ZMod.castHom h (ZMod d) c - 1) + w (ZMod.castHom h (ZMod d) c + 1)
  rw [map_sub, map_add, map_one]

/-- Trajectories commute with cell-wise reduction (the covering property). -/
theorem traj_comap [NeZero n] [NeZero d] (h : d ∣ n) (w : Row d) (i : ℕ) :
    traj (n := n) (fun c => w (ZMod.castHom h (ZMod d) c)) i =
      fun c => traj (n := d) w i (ZMod.castHom h (ZMod d) c) := by
  induction i with
  | zero => rfl
  | succ i ih => rw [traj_succ, ih, evolve_comap h, traj_succ]

/-- The mirror-pair seed about `m`: the indicator of `{m+1, m−1}`.
    (On `ℤ₂` the two cells coincide and this is the single-cell seed —
    v4's alternating checkerboard, after lifting.) -/
def mirrorPair (m : ZMod d) : Row d :=
  fun c => if c = m + 1 ∨ c = m - 1 then 1 else 0

theorem mirrorPair_symmetric (m : ZMod d) :
    ∀ c, mirrorPair m (2 * m - c) = mirrorPair m c := by
  intro c
  unfold mirrorPair
  by_cases h1 : c = m + 1
  · rw [if_pos (Or.inl h1), if_pos]
    right
    rw [h1]; ring
  · by_cases h2 : c = m - 1
    · rw [if_pos (Or.inr h2), if_pos]
      left
      rw [h2]; ring
    · rw [if_neg, if_neg]
      · exact fun h => h.elim h1 h2
      · rintro (h | h)
        · exact h2 (by linear_combination -h)
        · exact h1 (by linear_combination -h)

/-- A mirror-symmetric row reads zero at its centre after one step. -/
theorem evolve_symmetric_center (u : Row d) (m : ZMod d)
    (hsym : ∀ c, u (2 * m - c) = u c) : evolve u m = 0 := by
  show u (m - 1) + u (m + 1) = 0
  have h : u (m - 1) = u (m + 1) := by
    have := hsym (m + 1)
    rw [show 2 * m - (m + 1) = m - 1 from by ring] at this
    exact this
  rw [h]
  exact (show ∀ a : ZMod 2, a + a = 0 from by decide) _


/-- Symmetry is preserved by the dynamics. -/
theorem evolve_symmetric (u : Row d) (m : ZMod d)
    (hsym : ∀ c, u (2 * m - c) = u c) :
    ∀ c, evolve u (2 * m - c) = evolve u c := by
  intro c
  show u (2 * m - c - 1) + u (2 * m - c + 1) = u (c - 1) + u (c + 1)
  rw [show 2 * m - c - 1 = 2 * m - (c + 1) from by ring,
    show 2 * m - c + 1 = 2 * m - (c - 1) from by ring,
    hsym (c + 1), hsym (c - 1), add_comm]

/-- **The dark column of the mirror-pair seed.** For `d ≥ 2` the
    trajectory of `mirrorPair m` vanishes on column `m` at every time. -/
theorem mirrorPair_dark (hd : 2 ≤ d) (m : ZMod d) :
    ∀ i, traj (mirrorPair m) i m = 0 := by
  haveI : NeZero d := ⟨by omega⟩
  haveI : Fact (1 < d) := ⟨by omega⟩
  -- symmetric at every time, dark at the centre from time 1 on
  have hsymall : ∀ i, ∀ c, traj (mirrorPair m) i (2 * m - c) =
      traj (mirrorPair m) i c := by
    intro i
    induction i with
    | zero => exact mirrorPair_symmetric m
    | succ i ih =>
      intro c
      rw [traj_succ]
      exact evolve_symmetric _ m ih c
  intro i
  cases i with
  | zero =>
    -- time 0: the centre is on neither cell of the pair
    show mirrorPair m m = 0
    unfold mirrorPair
    rw [if_neg]
    rintro (h | h)
    · exact one_ne_zero (α := ZMod d) (by linear_combination -h)
    · exact one_ne_zero (α := ZMod d) (by linear_combination h)
  | succ i =>
    rw [traj_succ]
    exact evolve_symmetric_center _ m (hsymall i)

/-- **The lifted kernel seed.** If a common divisor `d ≥ 2` of the stride
    and the cylinder exists, the mirror-pair seed of the `d`-cylinder
    lifts along cell-wise reduction to a nonzero seed whose trajectory
    both read columns never see — at any horizon. -/
theorem gapTube_not_informationSet_of_dvd [NeZero n] {g d : ℕ}
    (hd2 : 2 ≤ d) (hdvdn : d ∣ n) (hdvdg : d ∣ g) (t : ℕ) (j₀ : ZMod n) :
    ¬ IsInformationSet (gapTube g t j₀) := by
  haveI : NeZero d := ⟨by omega⟩
  rw [isInformationSet_iff_vanishing]
  intro h
  -- the lifted seed vanishes on the whole screen …
  have hvan : VanishesOn (gapTube g t j₀)
      (fun c => mirrorPair (ZMod.castHom hdvdn (ZMod d) j₀)
        (ZMod.castHom hdvdn (ZMod d) c)) := by
    intro p hp
    rw [mem_gapTube] at hp
    have htraj := congrFun
      (traj_comap hdvdn (mirrorPair (ZMod.castHom hdvdn (ZMod d) j₀)) (p.1 : ℕ)) p.2
    rcases hp with hc | hc
    · rw [htraj, hc]
      exact mirrorPair_dark hd2 _ _
    · rw [htraj, hc, map_add]
      have hg0 : ZMod.castHom hdvdn (ZMod d) ((g : ℕ) : ZMod n) = 0 := by
        rw [map_natCast]
        obtain ⟨q, hq⟩ := hdvdg
        subst hq
        push_cast
        rw [ZMod.natCast_self, zero_mul]
      rw [hg0, add_zero]
      exact mirrorPair_dark hd2 _ _
  -- … but it is not zero
  have hne : (fun c => mirrorPair (ZMod.castHom hdvdn (ZMod d) j₀)
      (ZMod.castHom hdvdn (ZMod d) c)) ≠ (0 : Row n) := by
    intro h0
    have := congrFun h0 (j₀ + 1)
    simp only [map_add, map_one, Pi.zero_apply] at this
    unfold mirrorPair at this
    rw [if_pos (Or.inl rfl)] at this
    exact one_ne_zero (α := ZMod 2) this
  exact hne (h _ hvan)

/-- **NON-COPRIME STRIDES FAIL FOREVER.** If `gcd(g, n) ≥ 2`, the
    stride-`g` screen is not an information set at any horizon. -/
theorem gapTube_not_informationSet_of_gcd_ne_one [NeZero n] {g : ℕ}
    (hg : Nat.gcd g n ≠ 1) (t : ℕ) (j₀ : ZMod n) :
    ¬ IsInformationSet (gapTube g t j₀) := by
  have hn0 : n ≠ 0 := NeZero.ne n
  have hd2 : 2 ≤ Nat.gcd g n := by
    rcases Nat.eq_zero_or_pos (Nat.gcd g n) with h0 | h1
    · exact absurd (Nat.eq_zero_of_gcd_eq_zero_right h0) hn0
    · omega
  exact gapTube_not_informationSet_of_dvd hd2
    (Nat.gcd_dvd_right g n) (Nat.gcd_dvd_left g n) t j₀

end QuotientLift

/-! ### The classification theorem -/

/-- **T25 — THE COPRIMALITY CLASSIFICATION OF TWO-COLUMN SCREENS (new;
    was the §7 stretch conjecture).** For every cylinder size `n`, stride
    `g`, base column `j₀` and horizon `t`: the two-column screen
    `{j₀, j₀+g} × [0,t]` is an information set **iff `gcd(g, n) = 1` and
    `n ≤ 2(t+1)`**. Coprime strides lose nothing — the full adjacent
    capacity at the sharp T9 threshold; non-coprime strides never decode.
    T9's sufficiency (`g = 1`), T20 (`g = 2`) and the width-1 negatives
    (`g = 0`) are special cases. Separation matters exactly through
    coprimality — the complete answer to "what does the width-2 screen's
    geometry actually use?". -/
theorem gapTube_isInformationSet_iff {t : ℕ} [NeZero n] (g : ℕ) (j₀ : ZMod n) :
    IsInformationSet (gapTube g t j₀) ↔ (Nat.gcd g n = 1 ∧ n ≤ 2 * (t + 1)) := by
  constructor
  · intro h
    constructor
    · by_contra hg
      exact gapTube_not_informationSet_of_gcd_ne_one hg t j₀ h
    · by_contra hn
      exact card_lt_not_informationSet
        (lt_of_le_of_lt (gapTube_card_le j₀) (by omega)) h
  · rintro ⟨hg, hn⟩
    rw [isInformationSet_iff_vanishing]
    intro z hz
    apply seed_eq_zero_of_gapTube_zero hg z t j₀ hn
    · intro i hi
      exact hz (⟨i, by omega⟩, j₀) (mem_gapTube.mpr (Or.inl rfl))
    · intro i hi
      exact hz (⟨i, by omega⟩, j₀ + (g : ZMod n)) (mem_gapTube.mpr (Or.inr rfl))

/-! ### Consistency corollaries — the old theorems as special cases

The originals (`tubeSet_isInformationSet_iff`, T9;
`gapTwoTube_isInformationSet_iff_parity`, T20; the width-1 negatives of
`Rule90Cylinder.lean`) stand untouched; these re-derivations pin the new
classification against them. -/

/-- `g = 1`: T9 re-derived from the classification. -/
theorem tubeSet_iff_via_stride {t : ℕ} [NeZero n] (j₀ : ZMod n) :
    IsInformationSet (tubeSet t j₀) ↔ n ≤ 2 * (t + 1) := by
  have hset : tubeSet t j₀ = gapTube 1 t j₀ := by
    unfold tubeSet gapTube
    norm_num
  rw [hset, gapTube_isInformationSet_iff]
  simp [Nat.gcd_one_left]

/-- `g = 2`: T20 re-derived from the classification (`gcd(2,n) = 1 ⟺ n`
    odd). The two independent proofs of the parity classification agree. -/
theorem gapTwoTube_parity_via_stride {t : ℕ} [NeZero n] (j₀ : ZMod n) :
    IsInformationSet (gapTwoTube t j₀) ↔ (Odd n ∧ n ≤ 2 * (t + 1)) := by
  have hset : gapTwoTube t j₀ = gapTube 2 t j₀ := by
    unfold gapTwoTube gapTube
    norm_num
  rw [hset, gapTube_isInformationSet_iff]
  constructor
  · rintro ⟨hg, hn⟩
    exact ⟨Nat.coprime_two_left.mp hg, hn⟩
  · rintro ⟨hodd, hn⟩
    exact ⟨Nat.coprime_two_left.mpr hodd, hn⟩

/-- `g = 0`: the degenerate single-column screen decodes only the
    1-cylinder — the v3 width-1 negatives (`n ≥ 3` mirror seeds, `n = 2`
    nilpotency) unified in one line (`gcd(0, n) = n`). -/
theorem gapTube_zero_iff {t : ℕ} [NeZero n] (j₀ : ZMod n) :
    IsInformationSet (gapTube 0 t j₀) ↔ n = 1 := by
  rw [gapTube_isInformationSet_iff]
  constructor
  · rintro ⟨hg, -⟩
    simpa using hg
  · rintro rfl
    exact ⟨by simp, by omega⟩

/-! ### Kernel cross-checks at the boundary -/

set_option maxRecDepth 8192 in
set_option maxHeartbeats 1600000 in
/-- Boundary instance of the success half: stride 3 on the 8-cylinder at
    `t = 3` — `8 = 2(3+1)` exactly, `gcd(3,8) = 1`. -/
theorem gapThree_eight_three : IsInformationSet (gapTube (n := 8) 3 3 0) := by
  decide

set_option maxRecDepth 8192 in
set_option maxHeartbeats 1600000 in
/-- Boundary instance of the counting half: the same screen one step
    short (`t = 2`, `8 > 2(2+1)`) fails. -/
theorem gapThree_eight_two : ¬ IsInformationSet (gapTube (n := 8) 3 2 0) := by
  decide

set_option maxRecDepth 8192 in
set_option maxHeartbeats 3200000 in
/-- Boundary instance of the gcd half: stride 3 on the 9-cylinder fails
    even with time to spare (`t = 4`, `9 ≤ 2(4+1)` — the failure is the
    `gcd(3,9) = 3` obstruction, not counting). -/
theorem gapThree_nine_four : ¬ IsInformationSet (gapTube (n := 9) 3 4 0) := by
  decide

/-! ### Axiom audit -/
#print axioms mirror_sweep
#print axioms mirror_of_column_dark
#print axioms periodic_of_double_mirror
#print axioms walk_of_periodic
#print axioms exists_nat_mul_step
#print axioms seed_eq_zero_of_gapTube_zero
#print axioms evolve_comap
#print axioms traj_comap
#print axioms mirrorPair_symmetric
#print axioms evolve_symmetric_center
#print axioms evolve_symmetric
#print axioms mirrorPair_dark
#print axioms gapTube_not_informationSet_of_dvd
#print axioms gapTube_not_informationSet_of_gcd_ne_one
#print axioms gapTube_isInformationSet_iff
#print axioms tubeSet_iff_via_stride
#print axioms gapTwoTube_parity_via_stride
#print axioms gapTube_zero_iff
#print axioms gapThree_eight_three
#print axioms gapThree_eight_two
#print axioms gapThree_nine_four

end OPHProofChain.Rule90
