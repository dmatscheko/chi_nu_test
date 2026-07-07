import Mathlib
import OPHProofChain.Rule90Cylinder

/-!
# General decodability on the Rule-90 cylinder (the §7.6 stretch item)

`Rule90Cylinder.lean` proved the sharp screen theorem (T9) for the natural
screen families. This module attacks the **general decodability question**
the proof chain's §7.6 lists as the stretch item: *which arbitrary finite
sets of spacetime cells determine the bulk?* It provides

1. **the general framework** — `IsInformationSet S` for an arbitrary
   `Finset` of spacetime cells, the linearity reduction to the vanishing
   form (`isInformationSet_iff_vanishing`), a `Decidable` instance through
   that cheap form (so concrete instances are one `decide` away), the
   universal counting bound (`card_lt_not_informationSet`: fewer than `n`
   cells never suffice), and monotonicity (`isInformationSet_mono`);

2. **the screen families, restated and completed in the framework**:
   * `tubeSet_isInformationSet_iff` — the T9 sharp threshold
     `n ≤ 2(t+1)` for the adjacent (timelike) width-2 tube, now with the
     failure half obtained from the *general* counting bound;
   * **`lightTube_isInformationSet_iff` (NEW): boost invariance.** The
     *lightlike* width-2 screen — the tube tilted onto a lightcone
     diagonal, reading cells `{(i, j₀+i), (i, j₀+i+1)}` — is an
     information set **iff `n ≤ 2(t+1)`, the same sharp threshold**. The
     sideways sweep becomes one-sided but *double-speed* (two columns per
     time step: the solved-for cell advances along the tilted cone), so
     tilting the screen changes the decoding geometry yet **the capacity
     of a width-2 adjacent screen is invariant under boosts** — it
     saturates the information bound in every frame. (Machine-checked
     surprise: the author of this module first conjectured halved capacity
     for the lightlike screen; the general sweep below *proves* full
     capacity, and `decide` instances confirmed it beforehand.)
   * **`gapTwoTube_isInformationSet_iff_parity` (NEW in v5; the even half
     was NEW in v4): the complete parity classification of the gapped
     screen.** The width-2 screen with a one-cell **gap** — columns
     `{j₀, j₀+2}` — is an information set **iff `n` is odd and
     `n ≤ 2(t+1)`**. On an **even** cylinder it fails at every horizon
     (`gapTwoTube_fails_even`): both read columns lie in the same class of
     the spacetime checkerboard, and the alternating seed is a kernel
     element the screen never sees. On an **odd** cylinder
     (`gapTwoTube_isInformationSet_iff_odd` — v4 left this open with only
     the `decide` instance `gapTwo_five_two` as evidence) the gapped
     screen recovers the **full adjacent capacity at the same sharp
     threshold**: the screen's columns *enclose* the middle column and
     determine it one step up, two fans sweep row 1 to zero around the
     cylinder, and the final descent to the seed is algebraic — a row
     killed by one step is constant along the distance-2 walk, which is
     transitive exactly when the cycle is odd. So what T9's screen buys is
     not adjacency per se: it is *parity coverage* — and boost (tilt) is
     irrelevant while separation matters exactly through cycle parity.

## Honest scope

The *full* weight-distribution classification of arbitrary cell subsets
(equivalently, of the dual code of the Rule-90 spacetime code) remains
open — this module turns the question into a decidable predicate and
settles the width-2 geometry completely (adjacent: sharp at `2(t+1)` in
every frame; gapped: the complete parity classification, sharp at the
same threshold on odd cylinders and empty on even ones), which is the
part the holographic-screen reading of the proof chain uses. Nothing here
is physics: it is coding theory for the carrier.

No `sorry`, no new axioms, no `native_decide` (the instance lemmas use
plain kernel `decide` through the vanishing form).
-/

namespace OPHProofChain.Rule90

variable {n : ℕ}

/-- A spacetime cell of the depth-`t` block on the `n`-cylinder. -/
abbrev Cell (n t : ℕ) : Type := Fin (t + 1) × ZMod n

/-- The seed `z` vanishes on every cell of `S`. By linearity this is the
    kernel condition for the readout on `S`. -/
def VanishesOn {t : ℕ} (S : Finset (Cell n t)) (z : Row n) : Prop :=
  ∀ p ∈ S, traj z p.1 p.2 = 0

/-- `S` is an information set: the cells of `S` determine the seed (hence
    the whole spacetime block). -/
def IsInformationSet {t : ℕ} (S : Finset (Cell n t)) : Prop :=
  ∀ x y : Row n, (∀ p ∈ S, traj x p.1 p.2 = traj y p.1 p.2) → x = y

/-- **Linearity reduction**: `S` is an information set iff the only seed
    vanishing on `S` is `0`. -/
theorem isInformationSet_iff_vanishing {t : ℕ} (S : Finset (Cell n t)) :
    IsInformationSet S ↔ ∀ z : Row n, VanishesOn S z → z = 0 := by
  constructor
  · intro h z hz
    apply h z 0
    intro p hp
    rw [hz p hp, traj_zero_seed, Pi.zero_apply]
  · intro h x y hxy
    have hz : VanishesOn S (x - y) := by
      intro p hp
      rw [traj_sub, Pi.sub_apply, hxy p hp, sub_self]
    exact sub_eq_zero.mp (h (x - y) hz)

/-- Information-set membership is decidable (through the vanishing form:
    `2^n` seeds, each checked on the cells of `S`), so concrete instances
    are `decide`-able. -/
instance {t : ℕ} [NeZero n] (S : Finset (Cell n t)) :
    Decidable (IsInformationSet S) :=
  decidable_of_iff (∀ z : Row n, (∀ p ∈ S, traj z p.1 p.2 = 0) → z = 0)
    (isInformationSet_iff_vanishing S).symm

/-- Growing the read set preserves the information-set property. -/
theorem isInformationSet_mono {t : ℕ} {S S' : Finset (Cell n t)}
    (hss : S ⊆ S') (h : IsInformationSet S) : IsInformationSet S' :=
  fun x y hxy => h x y fun p hp => hxy p (hss hp)

/-- **The universal counting bound**: an information set has at least `n`
    cells — `2^n` seeds cannot inject into fewer readouts. Every negative
    result below the code dimension is a corollary. -/
theorem card_lt_not_informationSet {t : ℕ} [NeZero n]
    {S : Finset (Cell n t)} (hcard : S.card < n) : ¬ IsInformationSet S := by
  intro h
  -- the readout map on `S` is injective
  have hinj : Function.Injective (fun z : Row n => fun p : S => traj z p.1.1 p.1.2) := by
    intro x y hxy
    apply h x y
    intro p hp
    exact congrFun hxy ⟨p, hp⟩
  have hcard' := Fintype.card_le_of_injective _ hinj
  have hrow : Fintype.card (Row n) = 2 ^ n := by
    rw [Fintype.card_fun, ZMod.card, ZMod.card]
  have hread : Fintype.card (S → ZMod 2) = 2 ^ S.card := by
    rw [Fintype.card_fun, ZMod.card, Fintype.card_coe]
  rw [hrow, hread] at hcard'
  have := (Nat.pow_le_pow_iff_right (by norm_num : 1 < 2)).mp hcard'
  omega

/-! ### The adjacent (timelike) tube, restated in the framework -/

/-- A generic column family: at time `i` read the two cells `colA i` and
    `colB i`. Both tube geometries below are instances, and the shared
    cardinality bound is proved once. -/
def colFamily [NeZero n] (t : ℕ) (colA colB : Fin (t + 1) → ZMod n) :
    Finset (Cell n t) :=
  (Finset.univ.image fun i : Fin (t + 1) => (i, colA i)) ∪
    (Finset.univ.image fun i : Fin (t + 1) => (i, colB i))

theorem mem_colFamily [NeZero n] {t : ℕ} {colA colB : Fin (t + 1) → ZMod n}
    {p : Cell n t} :
    p ∈ colFamily t colA colB ↔ p.2 = colA p.1 ∨ p.2 = colB p.1 := by
  unfold colFamily
  simp only [Finset.mem_union, Finset.mem_image, Finset.mem_univ, true_and]
  constructor
  · rintro (⟨i, hi⟩ | ⟨i, hi⟩)
    · have h1 : p.1 = i := (congrArg Prod.fst hi).symm
      have h2 : p.2 = colA i := (congrArg Prod.snd hi).symm
      exact Or.inl (h2.trans (congrArg colA h1.symm))
    · have h1 : p.1 = i := (congrArg Prod.fst hi).symm
      have h2 : p.2 = colB i := (congrArg Prod.snd hi).symm
      exact Or.inr (h2.trans (congrArg colB h1.symm))
  · rintro (h | h)
    · exact Or.inl ⟨p.1, Prod.ext rfl h.symm⟩
    · exact Or.inr ⟨p.1, Prod.ext rfl h.symm⟩

/-- Any two-column family has at most `2(t+1)` cells. -/
theorem colFamily_card_le [NeZero n] {t : ℕ} (colA colB : Fin (t + 1) → ZMod n) :
    (colFamily t colA colB).card ≤ 2 * (t + 1) := by
  unfold colFamily
  calc ((Finset.univ.image fun i : Fin (t + 1) => (i, colA i)) ∪
        (Finset.univ.image fun i : Fin (t + 1) => (i, colB i))).card
      ≤ (Finset.univ.image fun i : Fin (t + 1) => (i, colA i)).card +
        (Finset.univ.image fun i : Fin (t + 1) => (i, colB i)).card :=
        Finset.card_union_le _ _
    _ ≤ (t + 1) + (t + 1) := by
        have hA := Finset.card_image_le
          (s := (Finset.univ : Finset (Fin (t + 1))))
          (f := fun i : Fin (t + 1) => (i, colA i))
        have hB := Finset.card_image_le
          (s := (Finset.univ : Finset (Fin (t + 1))))
          (f := fun i : Fin (t + 1) => (i, colB i))
        rw [Finset.card_univ, Fintype.card_fin] at hA hB
        omega
    _ = 2 * (t + 1) := by ring

/-- The width-2 timelike tube as a cell set: columns `{j₀, j₀+1}`, all
    times `≤ t`. -/
def tubeSet [NeZero n] (t : ℕ) (j₀ : ZMod n) : Finset (Cell n t) :=
  colFamily t (fun _ => j₀) (fun _ => j₀ + 1)

theorem mem_tubeSet [NeZero n] {t : ℕ} {j₀ : ZMod n} {p : Cell n t} :
    p ∈ tubeSet t j₀ ↔ p.2 = j₀ ∨ p.2 = j₀ + 1 :=
  mem_colFamily

/-- The tube has at most `2(t+1)` cells. -/
theorem tubeSet_card_le [NeZero n] {t : ℕ} (j₀ : ZMod n) :
    (tubeSet t j₀).card ≤ 2 * (t + 1) :=
  colFamily_card_le _ _

/-- **T9 in the framework** — the adjacent width-2 tube is an information
    set iff `n ≤ 2(t+1)`: sufficiency is the sideways lightcone sweep of
    `Rule90Cylinder.lean`; failure now follows from the *general* counting
    bound. -/
theorem tubeSet_isInformationSet_iff {t : ℕ} [NeZero n] (j₀ : ZMod n) :
    IsInformationSet (tubeSet t j₀) ↔ n ≤ 2 * (t + 1) := by
  constructor
  · intro h
    by_contra hn
    exact card_lt_not_informationSet
      (lt_of_le_of_lt (tubeSet_card_le j₀) (by omega)) h
  · intro hn
    rw [isInformationSet_iff_vanishing]
    intro z hz
    apply seed_eq_zero_of_tube_zero z t j₀ hn
    · intro i hi
      exact hz (⟨i, by omega⟩, j₀) (mem_tubeSet.mpr (Or.inl rfl))
    · intro i hi
      exact hz (⟨i, by omega⟩, j₀ + 1) (mem_tubeSet.mpr (Or.inr rfl))

/-! ### The lightlike (boosted) tube — NEW

Tilt the screen onto a lightcone diagonal: at time `i` read cells
`j₀ + i` and `j₀ + i + 1`. The Rule-90 constraint solved *sideways along
the tilted cone* advances **two** columns per time step (one-sided,
double-speed), so the screen reaches `2(t+1)` seed cells — exactly the
counting bound again. -/

/-- The lightlike width-2 tube: cells `{(i, j₀+i), (i, j₀+i+1)} : i ≤ t`. -/
def lightTube [NeZero n] (t : ℕ) (j₀ : ZMod n) : Finset (Cell n t) :=
  colFamily t (fun i => j₀ + ((i : ℕ) : ZMod n)) (fun i => j₀ + ((i : ℕ) : ZMod n) + 1)

theorem mem_lightTube [NeZero n] {t : ℕ} {j₀ : ZMod n} {p : Cell n t} :
    p ∈ lightTube t j₀ ↔
      p.2 = j₀ + ((p.1 : ℕ) : ZMod n) ∨ p.2 = j₀ + ((p.1 : ℕ) : ZMod n) + 1 :=
  mem_colFamily

/-- The lightlike tube has at most `2(t+1)` cells. -/
theorem lightTube_card_le [NeZero n] {t : ℕ} (j₀ : ZMod n) :
    (lightTube t j₀).card ≤ 2 * (t + 1) :=
  colFamily_card_le _ _

/-- **The double-speed one-sided sweep.** If the trajectory vanishes on the
    lightlike tube up to time `t`, it vanishes at every offset `u` to the
    right of the moving base point, within the tilted cone
    `u + 2i ≤ 2t + 1`: solving the constraint along the diagonal gains two
    columns per time step. -/
theorem light_sweep (z : Row n) (t : ℕ) (j₀ : ZMod n)
    (h0 : ∀ i, i ≤ t → traj z i (j₀ + (i : ZMod n)) = 0)
    (h1 : ∀ i, i ≤ t → traj z i (j₀ + (i : ZMod n) + 1) = 0) :
    ∀ u : ℕ, ∀ i, u + 2 * i ≤ 2 * t + 1 →
      traj z i (j₀ + (i : ZMod n) + (u : ZMod n)) = 0 := by
  suffices H : ∀ u : ℕ,
      (∀ i, u + 2 * i ≤ 2 * t + 1 →
        traj z i (j₀ + (i : ZMod n) + (u : ZMod n)) = 0) ∧
      (∀ i, (u + 1) + 2 * i ≤ 2 * t + 1 →
        traj z i (j₀ + (i : ZMod n) + ((u + 1 : ℕ) : ZMod n)) = 0) by
    intro u
    exact (H u).1
  intro u
  induction u with
  | zero =>
    constructor
    · intro i hi
      have := h0 i (by omega)
      simpa using this
    · intro i hi
      have := h1 i (by omega)
      have hcast : j₀ + (i : ZMod n) + ((0 + 1 : ℕ) : ZMod n)
          = j₀ + (i : ZMod n) + 1 := by
        push_cast
        ring
      rw [hcast]
      exact this
  | succ u ih =>
    constructor
    · exact ih.2
    · intro i hi
      -- solve the constraint at `(i, j₀ + i + (u+1))` for its right neighbour
      have hrule : traj z i (j₀ + (i : ZMod n) + ((u + 1 : ℕ) : ZMod n) - 1) +
          traj z i (j₀ + (i : ZMod n) + ((u + 1 : ℕ) : ZMod n) + 1) =
          traj z (i + 1) (j₀ + (i : ZMod n) + ((u + 1 : ℕ) : ZMod n)) :=
        (traj_succ_apply z i _).symm
      have hcl : j₀ + (i : ZMod n) + ((u + 1 : ℕ) : ZMod n) - 1
          = j₀ + (i : ZMod n) + (u : ZMod n) := by
        push_cast
        ring
      have hcr : j₀ + (i : ZMod n) + ((u + 1 : ℕ) : ZMod n) + 1
          = j₀ + (i : ZMod n) + ((u + 1 + 1 : ℕ) : ZMod n) := by
        push_cast
        ring
      have hcm : j₀ + (i : ZMod n) + ((u + 1 : ℕ) : ZMod n)
          = j₀ + ((i + 1 : ℕ) : ZMod n) + (u : ZMod n) := by
        push_cast
        ring
      rw [hcl, hcr, hcm] at hrule
      have hz2 : traj z i (j₀ + (i : ZMod n) + ((u + 1 + 1 : ℕ) : ZMod n)) =
          traj z (i + 1) (j₀ + ((i + 1 : ℕ) : ZMod n) + (u : ZMod n)) -
            traj z i (j₀ + (i : ZMod n) + (u : ZMod n)) :=
        eq_sub_of_add_eq' hrule
      have e1 : traj z (i + 1) (j₀ + ((i + 1 : ℕ) : ZMod n) + (u : ZMod n)) = 0 := by
        have := ih.1 (i + 1) (by omega)
        simpa using this
      have e0 : traj z i (j₀ + (i : ZMod n) + (u : ZMod n)) = 0 :=
        ih.1 i (by omega)
      rw [hz2, e1, e0, sub_zero]

/-- **Vanishing theorem for the boosted screen**: for `n ≤ 2(t+1)`, a
    trajectory vanishing on the lightlike tube has zero seed — every seed
    cell is inside the one-sided double-speed cone. -/
theorem seed_eq_zero_of_lightTube_zero [NeZero n] (z : Row n) (t : ℕ) (j₀ : ZMod n)
    (hn : n ≤ 2 * (t + 1))
    (h0 : ∀ i, i ≤ t → traj z i (j₀ + (i : ZMod n)) = 0)
    (h1 : ∀ i, i ≤ t → traj z i (j₀ + (i : ZMod n) + 1) = 0) :
    z = 0 := by
  funext c
  set u : ℕ := (c - j₀).val with hu
  have hun : u < n := ZMod.val_lt _
  have hcast : ((u : ℕ) : ZMod n) = c - j₀ := by
    rw [hu]
    exact ZMod.natCast_rightInverse _
  have hc : c = j₀ + ((0 : ℕ) : ZMod n) + (u : ZMod n) := by
    rw [hcast]
    push_cast
    ring
  have := light_sweep z t j₀ h0 h1 u 0 (by omega)
  rw [traj_zero] at this
  rw [hc]
  exact this

/-- **BOOST INVARIANCE OF SCREEN CAPACITY (new).** The lightlike width-2
    screen is an information set **iff `n ≤ 2(t+1)`** — precisely the T9
    threshold of the timelike screen. Tilting the width-2 adjacent screen
    onto the lightcone changes the decoding sweep (one-sided,
    double-speed) but not the capacity: in every frame the screen
    saturates the information bound. -/
theorem lightTube_isInformationSet_iff {t : ℕ} [NeZero n] (j₀ : ZMod n) :
    IsInformationSet (lightTube t j₀) ↔ n ≤ 2 * (t + 1) := by
  constructor
  · intro h
    by_contra hn
    exact card_lt_not_informationSet
      (lt_of_le_of_lt (lightTube_card_le j₀) (by omega)) h
  · intro hn
    rw [isInformationSet_iff_vanishing]
    intro z hz
    apply seed_eq_zero_of_lightTube_zero z t j₀ hn
    · intro i hi
      have := hz (⟨i, by omega⟩, j₀ + ((i : ℕ) : ZMod n))
        (mem_lightTube.mpr (Or.inl rfl))
      simpa using this
    · intro i hi
      have := hz (⟨i, by omega⟩, j₀ + ((i : ℕ) : ZMod n) + 1)
        (mem_lightTube.mpr (Or.inr rfl))
      simpa using this

/-! ### The gapped tube — adjacency is load-bearing -/

/-- The gap-2 width-2 tube: columns `{j₀, j₀ + 2}`, all times `≤ t`. -/
def gapTwoTube [NeZero n] (t : ℕ) (j₀ : ZMod n) : Finset (Cell n t) :=
  colFamily t (fun _ => j₀) (fun _ => j₀ + 2)

theorem mem_gapTwoTube [NeZero n] {t : ℕ} {j₀ : ZMod n} {p : Cell n t} :
    p ∈ gapTwoTube t j₀ ↔ p.2 = j₀ ∨ p.2 = j₀ + 2 :=
  mem_colFamily

/-- The alternating seed relative to `j₀`: the indicator of the cells at
    odd displacement from `j₀`. On an even cylinder this is the
    checkerboard class the gapped screen never reads. -/
def altSeed (j₀ : ZMod n) : Row n := fun c => (((c - j₀).val : ℕ) : ZMod 2)

theorem altSeed_apply_add_nat (j₀ : ZMod n) [NeZero n] (hev : 2 ∣ n) (r : ℕ) :
    altSeed j₀ (j₀ + (r : ZMod n)) = ((r : ℕ) : ZMod 2) := by
  unfold altSeed
  have h1 : j₀ + (r : ZMod n) - j₀ = ((r : ℕ) : ZMod n) := by ring
  rw [h1]
  -- `(r mod n) ≡ r (mod 2)` because `2 ∣ n`
  have hval : (((r : ZMod n)).val : ℕ) = r % n := ZMod.val_natCast (n := n) r
  rw [hval]
  have hn2 : ((n : ℕ) : ZMod 2) = 0 := (CharP.cast_eq_zero_iff (ZMod 2) 2 n).mpr hev
  conv_rhs => rw [← Nat.mod_add_div r n]
  push_cast
  rw [hn2]
  ring

/-- One Rule-90 step kills the alternating seed (both neighbours of any
    cell carry the same alternating value, and `𝔽₂` cancels them). -/
theorem evolve_altSeed (j₀ : ZMod n) [NeZero n] (hev : 2 ∣ n) :
    evolve (altSeed j₀) = 0 := by
  have hn2 : 2 ≤ n := Nat.le_of_dvd (Nat.pos_of_ne_zero (NeZero.ne n)) hev
  -- val of `e + 1` has parity `val e + 1` because `2 ∣ n`
  have key : ∀ e : ZMod n, (((e + 1).val : ℕ) : ZMod 2) = ((e.val : ℕ) : ZMod 2) + 1 := by
    intro e
    have hone : (1 : ZMod n).val = 1 := by
      rw [ZMod.val_one_eq_one_mod]
      exact Nat.mod_eq_of_lt (by omega)
    have hadd : (e + 1).val = (e.val + 1) % n := by
      rw [ZMod.val_add, hone]
    have hmod2 : (e + 1).val % 2 = (e.val + 1) % 2 := by
      rw [hadd]
      exact Nat.mod_mod_of_dvd _ hev
    have hcast : ∀ m : ℕ, ((m : ℕ) : ZMod 2) = ((m % 2 : ℕ) : ZMod 2) := by
      intro m
      conv_lhs => rw [← Nat.mod_add_div m 2]
      push_cast
      rw [show (2 : ZMod 2) = 0 from by decide]
      ring
    rw [hcast ((e + 1).val), hmod2, ← hcast (e.val + 1)]
    push_cast
    ring
  funext c
  show altSeed j₀ (c - 1) + altSeed j₀ (c + 1) = 0
  unfold altSeed
  have h1 : c - 1 - j₀ = (c - j₀) - 1 := by ring
  have h2 : c + 1 - j₀ = (c - j₀) + 1 := by ring
  rw [h1, h2]
  set d : ZMod n := c - j₀ with hd
  have hd1 : ((((d - 1) + 1).val : ℕ) : ZMod 2) = (((d - 1).val : ℕ) : ZMod 2) + 1 :=
    key (d - 1)
  rw [show d - 1 + 1 = d from by ring] at hd1
  have hd2 : (((d + 1).val : ℕ) : ZMod 2) = ((d.val : ℕ) : ZMod 2) + 1 := key d
  rw [hd2, show (((d - 1).val : ℕ) : ZMod 2) = ((d.val : ℕ) : ZMod 2) - 1 from by
    rw [hd1]; ring]
  exact (show ∀ a : ZMod 2, a - 1 + (a + 1) = 0 by decide) _

/-- The alternating seed is nonzero (`n ≥ 3`: the cell at displacement 1
    carries a 1). -/
theorem altSeed_ne_zero (j₀ : ZMod n) [NeZero n] (hn : 3 ≤ n) :
    altSeed j₀ ≠ 0 := by
  intro h
  have := congrFun h (j₀ + 1)
  unfold altSeed at this
  have h1 : j₀ + 1 - j₀ = (1 : ZMod n) := by ring
  rw [h1] at this
  have hval : ((1 : ZMod n)).val = 1 := ZMod.val_one_eq_one_mod n ▸ Nat.mod_eq_of_lt (by omega)
  rw [hval] at this
  simp at this

/-- **ADJACENCY IS LOAD-BEARING (new).** On an **even** cylinder the gap-2
    width-2 screen `{j₀, j₀+2}` is *never* an information set — at any
    horizon `t`. Both read columns lie at even displacement from `j₀`, so
    they never see the odd checkerboard class: the alternating seed is a
    nonzero kernel element whose trajectory dies after one step with both
    read columns blank forever. Together with
    `lightTube_isInformationSet_iff` this pins what T9's screen geometry
    actually uses: *adjacency* (both checkerboard classes) is essential,
    while *boost* (timelike vs lightlike tilt) is irrelevant. -/
theorem gapTwoTube_fails_even {t : ℕ} [NeZero n] (hev : 2 ∣ n) (hn : 3 ≤ n)
    (j₀ : ZMod n) : ¬ IsInformationSet (gapTwoTube t j₀) := by
  rw [isInformationSet_iff_vanishing]
  intro h
  apply altSeed_ne_zero j₀ hn
  apply h
  intro p hp
  rw [mem_gapTwoTube] at hp
  -- the trajectory of the alternating seed: row 0 is the seed, rows ≥ 1 vanish
  have htraj : ∀ i : ℕ, 1 ≤ i → traj (altSeed j₀) i = 0 := by
    intro i hi
    induction i with
    | zero => omega
    | succ i ih =>
      rcases Nat.eq_or_lt_of_le hi with h1 | h1
      · rw [traj_succ, show i = 0 by omega, traj_zero]
        exact evolve_altSeed j₀ hev
      · rw [traj_succ, ih (by omega), evolve_zero]
  rcases Nat.eq_zero_or_pos (p.1 : ℕ) with h0 | h0
  · -- row 0: both read columns are at even displacement, value 0
    have : traj (altSeed j₀) p.1 = altSeed j₀ := by
      rw [show ((p.1 : ℕ)) = 0 from h0, traj_zero]
    rw [this]
    rcases hp with hc | hc
    · rw [hc]
      have := altSeed_apply_add_nat j₀ hev 0
      simpa using this
    · rw [hc]
      have := altSeed_apply_add_nat j₀ hev 2
      push_cast at this
      simpa using this
  · rw [htraj (p.1 : ℕ) h0]
    rfl

/-! ### The gap-2 screen on odd cylinders — the complete parity classification

On odd cylinders the checkerboard obstruction cannot exist (an odd cycle is
not bipartite), and in fact the gapped screen recovers the **full adjacent
capacity**: information set ⟺ `n ≤ 2(t+1)`, the same sharp threshold as T9.
The decoding is genuinely different from the adjacent sweep:

1. the two read columns *enclose* the middle column and determine it one
   step later (`gap_mid_col` — the constraint at the middle cell has both
   its inputs on the screen);
2. with three consecutive columns known, two fans sweep the rest of the
   cylinder (`gap_right_fan`, and `gap_left_fan` by the reflection
   symmetry), zeroing **row 1** everywhere once `n ≤ 2t+1` — but *not*
   row 0: the middle column's seed cell is invisible to the screen, so the
   sweeps can never reach time 0 on their own;
3. the last step is algebraic, and this is where odd parity enters:
   `evolve z = 0` forces `z` to be constant along the distance-2 walk
   (`parity_const_of_evolve_zero`), and on an **odd** cycle that walk is
   transitive — `z` is globally constant, and one screen cell read at time
   0 kills the constant. (On even cylinders the walk has two orbits and
   exactly the surviving orbit is `gapTwoTube_fails_even`'s kernel seed —
   the two halves of the classification are the two behaviours of the same
   walk.)
-/

/-- **The enclosed middle column.** The gapped screen's two columns are
    both inputs of the Rule-90 constraint at the middle cell, so the middle
    column `j₀ + 1` is determined (zero) at all times `1 ≤ i ≤ t + 1`. -/
theorem gap_mid_col (z : Row n) (t : ℕ) (j₀ : ZMod n)
    (h0 : ∀ i, i ≤ t → traj z i j₀ = 0)
    (h2 : ∀ i, i ≤ t → traj z i (j₀ + 2) = 0) :
    ∀ i, 1 ≤ i → i ≤ t + 1 → traj z i (j₀ + 1) = 0 := by
  intro i hi1 hit
  obtain ⟨k, rfl⟩ : ∃ k, i = k + 1 := ⟨i - 1, by omega⟩
  have hrule := traj_succ_apply z k (j₀ + 1)
  rw [show j₀ + 1 - 1 = j₀ from by ring, show j₀ + 1 + 1 = j₀ + 2 from by ring]
    at hrule
  rw [hrule, h0 k (by omega), h2 k (by omega), add_zero]

/-- **The rightward fan.** With the middle column known on `[1, t+1]`, the
    pair `(j₀+1, j₀+2)` sweeps right exactly like the adjacent tube, on
    windows that start at time 1 and lose one step per column. -/
theorem gap_right_fan (z : Row n) (t : ℕ) (j₀ : ZMod n)
    (h0 : ∀ i, i ≤ t → traj z i j₀ = 0)
    (h2 : ∀ i, i ≤ t → traj z i (j₀ + 2) = 0) :
    ∀ r : ℕ, ∀ i, 1 ≤ i → i + r ≤ t → traj z i (j₀ + 2 + (r : ZMod n)) = 0 := by
  have hmid := gap_mid_col z t j₀ h0 h2
  suffices H : ∀ r : ℕ,
      (∀ i, 1 ≤ i → i + r ≤ t → traj z i (j₀ + 2 + (r : ZMod n)) = 0) ∧
      (∀ i, 1 ≤ i → i + (r + 1) ≤ t →
        traj z i (j₀ + 2 + ((r + 1 : ℕ) : ZMod n)) = 0) by
    intro r
    exact (H r).1
  intro r
  induction r with
  | zero =>
    constructor
    · intro i _ hi
      simpa using h2 i (by omega)
    · intro i hi1 hi
      -- column `j₀+3` from the constraint at `(i, j₀+2)`
      have hrule : traj z i (j₀ + 2 - 1) + traj z i (j₀ + 2 + 1) =
          traj z (i + 1) (j₀ + 2) := (traj_succ_apply z i (j₀ + 2)).symm
      rw [show j₀ + 2 - 1 = j₀ + 1 from by ring] at hrule
      have hz2 : traj z i (j₀ + 2 + 1) =
          traj z (i + 1) (j₀ + 2) - traj z i (j₀ + 1) := eq_sub_of_add_eq' hrule
      have e1 : traj z (i + 1) (j₀ + 2) = 0 := h2 (i + 1) (by omega)
      have e0 : traj z i (j₀ + 1) = 0 := hmid i hi1 (by omega)
      rw [show ((0 + 1 : ℕ) : ZMod n) = 1 from by norm_num, hz2, e1, e0, sub_zero]
  | succ r ih =>
    constructor
    · exact ih.2
    · intro i hi1 hi
      -- column `j₀+2+(r+2)` from the constraint at `(i, j₀+2+(r+1))`
      have hrule : traj z i (j₀ + 2 + ((r + 1 : ℕ) : ZMod n) - 1) +
          traj z i (j₀ + 2 + ((r + 1 : ℕ) : ZMod n) + 1) =
          traj z (i + 1) (j₀ + 2 + ((r + 1 : ℕ) : ZMod n)) :=
        (traj_succ_apply z i _).symm
      have hcl : j₀ + 2 + ((r + 1 : ℕ) : ZMod n) - 1 = j₀ + 2 + (r : ZMod n) := by
        push_cast
        ring
      have hcr : j₀ + 2 + ((r + 1 : ℕ) : ZMod n) + 1 =
          j₀ + 2 + ((r + 1 + 1 : ℕ) : ZMod n) := by
        push_cast
        ring
      rw [hcl, hcr] at hrule
      have hz2 : traj z i (j₀ + 2 + ((r + 1 + 1 : ℕ) : ZMod n)) =
          traj z (i + 1) (j₀ + 2 + ((r + 1 : ℕ) : ZMod n)) -
            traj z i (j₀ + 2 + (r : ZMod n)) := eq_sub_of_add_eq' hrule
      have e1 : traj z (i + 1) (j₀ + 2 + ((r + 1 : ℕ) : ZMod n)) = 0 :=
        ih.2 (i + 1) (by omega) (by omega)
      have e0 : traj z i (j₀ + 2 + (r : ZMod n)) = 0 := ih.1 i hi1 (by omega)
      rw [hz2, e1, e0, sub_zero]

/-- **The leftward fan**, by reflecting the rightward one through the
    screen's midpoint (`m = 2j₀ + 2` swaps `j₀ ↔ j₀ + 2`). -/
theorem gap_left_fan (z : Row n) (t : ℕ) (j₀ : ZMod n)
    (h0 : ∀ i, i ≤ t → traj z i j₀ = 0)
    (h2 : ∀ i, i ≤ t → traj z i (j₀ + 2) = 0) :
    ∀ r : ℕ, ∀ i, 1 ≤ i → i + r ≤ t → traj z i (j₀ - (r : ZMod n)) = 0 := by
  have h0' : ∀ i, i ≤ t → traj (fun c => z (2 * j₀ + 2 - c)) i j₀ = 0 := by
    intro i hit
    rw [congrFun (traj_reflect (2 * j₀ + 2) z i) j₀,
      show 2 * j₀ + 2 - j₀ = j₀ + 2 from by ring]
    exact h2 i hit
  have h2' : ∀ i, i ≤ t → traj (fun c => z (2 * j₀ + 2 - c)) i (j₀ + 2) = 0 := by
    intro i hit
    rw [congrFun (traj_reflect (2 * j₀ + 2) z i) (j₀ + 2),
      show 2 * j₀ + 2 - (j₀ + 2) = j₀ from by ring]
    exact h0 i hit
  intro r i hi1 hi
  have key := gap_right_fan (fun c => z (2 * j₀ + 2 - c)) t j₀ h0' h2' r i hi1 hi
  rw [congrFun (traj_reflect (2 * j₀ + 2) z i) (j₀ + 2 + (r : ZMod n)),
    show 2 * j₀ + 2 - (j₀ + 2 + (r : ZMod n)) = j₀ - (r : ZMod n) from by ring]
    at key
  exact key

/-- A row killed by one Rule-90 step is constant along the distance-2 walk:
    the constraint at `j + 1` reads `z j + z (j + 2) = 0`, and `𝔽₂` turns
    that sum into an equality. -/
theorem parity_const_of_evolve_zero (z : Row n) (hev : evolve z = 0)
    (j : ZMod n) : z (j + 2) = z j := by
  have h : z (j + 1 - 1) + z (j + 1 + 1) = 0 := congrFun hev (j + 1)
  rw [show j + 1 - 1 = j from by ring, show j + 1 + 1 = j + 2 from by ring] at h
  exact (show ∀ a b : ZMod 2, a + b = 0 → b = a from by decide) _ _ h

/-- Iterating the distance-2 constancy. -/
theorem walk_two_of_evolve_zero (z : Row n) (hev : evolve z = 0) (j : ZMod n) :
    ∀ k : ℕ, z (j + ((2 * k : ℕ) : ZMod n)) = z j := by
  intro k
  induction k with
  | zero => simp
  | succ k ih =>
    have hstep := parity_const_of_evolve_zero z hev (j + ((2 * k : ℕ) : ZMod n))
    rw [show j + ((2 * k : ℕ) : ZMod n) + 2 = j + ((2 * (k + 1) : ℕ) : ZMod n)
      from by push_cast; ring] at hstep
    rw [hstep, ih]

/-- On an **odd** cylinder the distance-2 walk is transitive: `2` is a unit
    mod `n`, so every cell is `a + 2k` for some `k`. This is exactly the
    step that fails on even cylinders (where the walk has two orbits — the
    checkerboard of `gapTwoTube_fails_even`). -/
theorem exists_two_mul_step (hodd : Odd n) [NeZero n] (a b : ZMod n) :
    ∃ k : ℕ, b = a + ((2 * k : ℕ) : ZMod n) := by
  have hcop : Nat.Coprime 2 n := hodd.coprime_two_left
  have hunit : IsUnit (2 : ZMod n) := by
    have := (ZMod.isUnit_iff_coprime 2 n).mpr hcop
    simpa using this
  obtain ⟨u, hu⟩ := hunit.exists_right_inv
  refine ⟨(u * (b - a)).val, ?_⟩
  have hval : (((u * (b - a)).val : ℕ) : ZMod n) = u * (b - a) :=
    ZMod.natCast_rightInverse _
  rw [Nat.cast_mul, hval]
  push_cast
  rw [← mul_assoc, hu]
  ring

/-- **The odd-cylinder kernel step**: a row killed in one step and read
    zero anywhere is zero — the transitive parity walk spreads the single
    zero reading around the whole cycle. -/
theorem eq_zero_of_evolve_zero_odd (hodd : Odd n) [NeZero n] (z : Row n)
    (j₀ : ZMod n) (hev : evolve z = 0) (hj : z j₀ = 0) : z = 0 := by
  funext c
  obtain ⟨k, hk⟩ := exists_two_mul_step hodd j₀ c
  rw [hk, walk_two_of_evolve_zero z hev j₀ k, hj]
  rfl

/-- **The odd-cylinder vanishing theorem for the gapped screen.** For odd
    `n ≤ 2(t+1)`: the screen determines its enclosed middle column one step
    up, the two fans zero out **row 1** across the whole cylinder, and the
    transitive parity walk then kills the seed. Note the proof genuinely
    cannot zero row 0 directly (the middle column's seed cell is invisible)
    — the seed dies by algebra, not by sweep. -/
theorem seed_eq_zero_of_gapTwoTube_zero [NeZero n] (hodd : Odd n)
    (z : Row n) (t : ℕ) (j₀ : ZMod n) (hn : n ≤ 2 * (t + 1))
    (h0 : ∀ i, i ≤ t → traj z i j₀ = 0)
    (h2 : ∀ i, i ≤ t → traj z i (j₀ + 2) = 0) : z = 0 := by
  obtain ⟨m, hm⟩ := hodd
  rcases Nat.eq_zero_or_pos m with hm0 | hmpos
  · -- `n = 1`: the single cell is read directly at time 0
    have hn1 : n = 1 := by omega
    subst hn1
    funext c
    rw [Subsingleton.elim c j₀]
    simpa using h0 0 (Nat.zero_le t)
  · -- `n = 2m + 1 ≥ 3`
    -- row 1 vanishes everywhere: middle column + the two fans cover the cycle
    have hrow1 : traj z 1 = 0 := by
      funext c
      simp only [Pi.zero_apply]
      obtain ⟨v, hvn, hcv⟩ : ∃ v : ℕ, v < n ∧ c = j₀ + (v : ZMod n) :=
        ⟨(c - j₀).val, ZMod.val_lt _, by
          rw [ZMod.natCast_rightInverse (c - j₀)]; ring⟩
      rw [hcv]
      rcases Nat.lt_or_ge v 2 with hvsmall | hv2
      · interval_cases v
        · simpa using h0 1 (by omega)
        · simpa using gap_mid_col z t j₀ h0 h2 1 le_rfl (by omega)
      · rcases Nat.lt_or_ge (m + 1) v with hvl | hvr
        · -- left fan, `r = n - v ≤ m - 1`
          have hfan := gap_left_fan z t j₀ h0 h2 (n - v) 1 le_rfl (by omega)
          have hcol : j₀ - ((n - v : ℕ) : ZMod n) = j₀ + (v : ZMod n) := by
            rw [Nat.cast_sub (le_of_lt hvn), ZMod.natCast_self]
            ring
          rw [← hcol]
          exact hfan
        · -- right fan, `r = v - 2 ≤ m - 1`
          have hfan := gap_right_fan z t j₀ h0 h2 (v - 2) 1 le_rfl (by omega)
          have hcol : j₀ + 2 + ((v - 2 : ℕ) : ZMod n) = j₀ + (v : ZMod n) := by
            rw [Nat.cast_sub hv2]
            push_cast
            ring
          rw [← hcol]
          exact hfan
    have hev : evolve z = 0 := hrow1
    exact eq_zero_of_evolve_zero_odd ⟨m, hm⟩ z j₀ hev
      (by simpa using h0 0 (Nat.zero_le t))

/-- The gapped tube has at most `2(t+1)` cells. -/
theorem gapTwoTube_card_le [NeZero n] {t : ℕ} (j₀ : ZMod n) :
    (gapTwoTube t j₀).card ≤ 2 * (t + 1) :=
  colFamily_card_le _ _

/-- **THE ODD-CYLINDER GAP-2 THRESHOLD (new — was this module's stated open
    question).** On odd cylinders the gapped width-2 screen has exactly the
    adjacent screen's sharp capacity: information set ⟺ `n ≤ 2(t+1)`. A
    screen may be stretched apart without losing capacity — as long as the
    cycle parity keeps the distance-2 walk transitive. -/
theorem gapTwoTube_isInformationSet_iff_odd {t : ℕ} [NeZero n] (hodd : Odd n)
    (j₀ : ZMod n) :
    IsInformationSet (gapTwoTube t j₀) ↔ n ≤ 2 * (t + 1) := by
  constructor
  · intro h
    by_contra hn
    exact card_lt_not_informationSet
      (lt_of_le_of_lt (gapTwoTube_card_le j₀) (by omega)) h
  · intro hn
    rw [isInformationSet_iff_vanishing]
    intro z hz
    apply seed_eq_zero_of_gapTwoTube_zero hodd z t j₀ hn
    · intro i hi
      exact hz (⟨i, by omega⟩, j₀) (mem_gapTwoTube.mpr (Or.inl rfl))
    · intro i hi
      exact hz (⟨i, by omega⟩, j₀ + 2) (mem_gapTwoTube.mpr (Or.inr rfl))

/-- On the 2-cylinder the "gapped" screen degenerates to a single column
    (`j₀ + 2 = j₀`), and a single column never determines the 2-cylinder:
    the unread cell's indicator dies in one step (`n = 2` is the nilpotent
    cylinder). -/
theorem gapTwoTube_fails_two {t : ℕ} (j₀ : ZMod 2) :
    ¬ IsInformationSet (gapTwoTube (n := 2) t j₀) := by
  rw [isInformationSet_iff_vanishing]
  intro h
  have hker : (fun c => if c = j₀ + 1 then 1 else 0 : Row 2) = 0 := by
    apply h
    intro p hp
    -- the seed dies after one step …
    have hev : evolve (fun c => if c = j₀ + 1 then 1 else 0 : Row 2) = 0 := by
      funext c
      show (if c - 1 = j₀ + 1 then (1 : ZMod 2) else 0) +
        (if c + 1 = j₀ + 1 then 1 else 0) = 0
      rw [show c - 1 = c + 1 from
        (show ∀ x : ZMod 2, x - 1 = x + 1 from by decide) c]
      exact (show ∀ a : ZMod 2, a + a = 0 from by decide) _
    have htraj : ∀ i : ℕ, 1 ≤ i →
        traj (fun c => if c = j₀ + 1 then 1 else 0 : Row 2) i = 0 := by
      intro i hi
      induction i with
      | zero => omega
      | succ i ih =>
        rcases Nat.eq_or_lt_of_le hi with h1 | h1
        · rw [traj_succ, show i = 0 from by omega, traj_zero]
          exact hev
        · rw [traj_succ, ih (by omega), evolve_zero]
    -- … and both read columns are the same unread cell `j₀`
    rw [mem_gapTwoTube] at hp
    have hcol : p.2 = j₀ := by
      rcases hp with hc | hc
      · exact hc
      · rw [hc, show (2 : ZMod 2) = 0 from by decide, add_zero]
    rcases Nat.eq_zero_or_pos (p.1 : ℕ) with h0 | h0
    · rw [show ((p.1 : ℕ)) = 0 from h0, traj_zero, hcol, if_neg]
      intro hcontra
      exact absurd (by simpa using congrArg (· - j₀) hcontra)
        (by decide : ¬ (0 : ZMod 2) = 1)
    · rw [htraj (p.1 : ℕ) h0]
      rfl
  have := congrFun hker (j₀ + 1)
  rw [if_pos rfl] at this
  exact absurd this (by decide : ¬ (1 : ZMod 2) = 0)

/-- **THE COMPLETE PARITY CLASSIFICATION OF THE GAPPED SCREEN (new).** For
    every cylinder size: the gap-2 width-2 screen is an information set
    **iff `n` is odd and `n ≤ 2(t+1)`**. Odd cylinders: full adjacent
    capacity at the sharp threshold (the distance-2 walk closes around an
    odd cycle). Even cylinders: never, at any horizon (the checkerboard
    obstruction; at `n = 2` the degenerate single-column screen). With
    boost invariance (`lightTube_isInformationSet_iff`) this completes the
    width-2 screen geometry: *tilt is irrelevant; separation matters
    exactly through cycle parity.* -/
theorem gapTwoTube_isInformationSet_iff_parity {t : ℕ} [NeZero n] (j₀ : ZMod n) :
    IsInformationSet (gapTwoTube t j₀) ↔ (Odd n ∧ n ≤ 2 * (t + 1)) := by
  rcases Nat.even_or_odd n with hev | hodd
  · constructor
    · intro h
      exfalso
      have hn2 : 2 ≤ n := by
        obtain ⟨k, hk⟩ := hev
        have := NeZero.ne n
        omega
      rcases eq_or_lt_of_le hn2 with h2 | h3
      · have h2' : n = 2 := h2.symm
        subst h2'
        exact gapTwoTube_fails_two j₀ h
      · exact gapTwoTube_fails_even hev.two_dvd (by omega) j₀ h
    · rintro ⟨hodd, -⟩
      exact absurd hodd (Nat.not_odd_iff_even.mpr hev)
  · rw [gapTwoTube_isInformationSet_iff_odd hodd]
    simp [hodd]

set_option maxRecDepth 8192 in
/-- Machine-checked cross-check of the odd-cylinder theorem at a boundary
    instance: the gap-2 screen on the 5-cylinder at horizon `t = 2` (the
    sharp threshold `5 ≤ 2·3`, non-adjacent columns). Kept from the v4
    campaign, where it was the evidence for what is now
    `gapTwoTube_isInformationSet_iff_odd`. -/
theorem gapTwo_five_two : IsInformationSet (gapTwoTube (n := 5) 2 0) := by decide

set_option maxRecDepth 8192 in
/-- The same decidability lens on the boundary of the counting bound: the
    lightlike screen on the 6-cylinder at `t = 2` — `6 = 2(2+1)` exactly —
    is an information set (a `decide` cross-check of the sharp theorem at
    the tight boundary). -/
theorem lightTube_six_two : IsInformationSet (lightTube (n := 6) 2 0) := by decide

/-! ### Axiom audit -/
#print axioms isInformationSet_iff_vanishing
#print axioms card_lt_not_informationSet
#print axioms isInformationSet_mono
#print axioms tubeSet_isInformationSet_iff
#print axioms light_sweep
#print axioms seed_eq_zero_of_lightTube_zero
#print axioms lightTube_isInformationSet_iff
#print axioms gapTwoTube_fails_even
#print axioms gap_mid_col
#print axioms gap_right_fan
#print axioms gap_left_fan
#print axioms parity_const_of_evolve_zero
#print axioms eq_zero_of_evolve_zero_odd
#print axioms seed_eq_zero_of_gapTwoTube_zero
#print axioms gapTwoTube_isInformationSet_iff_odd
#print axioms gapTwoTube_fails_two
#print axioms gapTwoTube_isInformationSet_iff_parity
#print axioms gapTwo_five_two
#print axioms lightTube_six_two

end OPHProofChain.Rule90
