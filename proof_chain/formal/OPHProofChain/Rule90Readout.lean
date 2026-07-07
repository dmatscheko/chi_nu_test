import Mathlib
import OPHProofChain.Rule90Cylinder

/-!
# T31 [formal-v8] — the readout trichotomy: ghosts / bijective / unrealizable

**Provenance.** chi_nu_test original (formal-v8 campaign). The statement was
surfaced by the simulation companion (`oph_sim/FINDINGS.md`, item 10): with
`B = 2(t+1)` screen bits and `n` seed unknowns, the width-2 tube readout of
the Rule-90 `n`-cylinder sits in exactly one of three regimes. This module
proves the sharp version:

* **surjectivity** ⟺ `2(t+1) ≤ n` — *every* tube reading is realized by some
  seed as soon as the ring is at least as wide as the screen; in particular
  ABOVE the sharp threshold there are no unrealizable readings at all, only
  ghosts (`readout_ghost`), and the observed reading pins the world only up
  to the kernel;
* **injectivity** ⟺ `n ≤ 2(t+1)` — T9 (`tube_information_set_iff`),
  restated here for the bundle;
* **bijectivity** ⟺ `n = 2(t+1)` — the sharp threshold is a *double*
  extreme: the screen saturates the information bound AND its reading
  carries zero redundancy (the code corrects erasures of the bulk given the
  screen, never erasures of the screen);
* **unrealizable readings exist** ⟺ `n < 2(t+1)` — exactly the regime where
  T27's stall dichotomy has content (the audit's stall witness `n = 3, t = 2`
  lives here: 6 tube bits, 3 unknowns, `2⁶ − 2³` empty fibers).

The only nontrivial ingredient is surjectivity for `2(t+1) ≤ n`. The proof
is a kernel count through the first isomorphism theorem: a seed dark on the
tube vanishes on the `2(t+1)` fan columns (the sideways sweeps of
`Rule90Cylinder.lean` at row 0 — no threshold hypothesis needed), so the
kernel embeds into the functions on the remaining `n − 2(t+1)` free columns;
`|ker| ≤ 2^(n−2(t+1))` forces `|range| ≥ 2^(2(t+1))`, which is all of the
codomain.

Axioms: standard (`propext`, `Classical.choice`, `Quot.sound`); no `sorry`,
no `native_decide`.
-/

namespace OPHProofChain.Rule90

variable {n : ℕ}

/-! ## Additivity of the trajectory and the readout hom -/

theorem evolve_add (x y : Row n) : evolve (x + y) = evolve x + evolve y := by
  funext j
  simp only [evolve, Pi.add_apply]
  ring

theorem traj_add (x y : Row n) (i : ℕ) :
    traj (x + y) i = traj x i + traj y i := by
  induction i with
  | zero => rfl
  | succ i ih => rw [traj_succ, traj_succ, traj_succ, ih, evolve_add]

/-- The width-2 tube readout `tubeData` as an additive group homomorphism
    `(ZMod 2)ⁿ →+ (ZMod 2 × ZMod 2)^(t+1)`. -/
def tubeDataHom (j₀ : ZMod n) (t : ℕ) :
    Row n →+ (Fin (t + 1) → ZMod 2 × ZMod 2) where
  toFun := tubeData j₀ t
  map_zero' := by
    funext i
    simp [tubeData]
  map_add' := by
    intro x y
    funext i
    simp [tubeData, traj_add, Prod.mk_add_mk]

@[simp] theorem tubeDataHom_apply (j₀ : ZMod n) (t : ℕ) (z : Row n) :
    tubeDataHom j₀ t z = tubeData j₀ t z := rfl

/-- Dark tube, unpacked: the readout vanishes iff both tube columns vanish
    at every time `≤ t`. -/
theorem tubeData_eq_zero_iff {j₀ : ZMod n} {t : ℕ} {z : Row n} :
    tubeData j₀ t z = 0 ↔
      (∀ i, i ≤ t → traj z i j₀ = 0) ∧ (∀ i, i ≤ t → traj z i (j₀ + 1) = 0) := by
  constructor
  · intro h
    constructor
    · intro i hi
      have := congrFun h ⟨i, by omega⟩
      exact congrArg Prod.fst this
    · intro i hi
      have := congrFun h ⟨i, by omega⟩
      exact congrArg Prod.snd this
  · rintro ⟨h0, h1⟩
    funext i
    exact Prod.ext (h0 i.1 (by omega)) (h1 i.1 (by omega))

/-! ## The fan columns and the kernel bound -/

section Fans

/-- The columns covered by the two sideways fans: right offsets
    `j₀+1+r, r ≤ t` and left offsets `j₀−l, l ≤ t`. -/
def fanColumns (j₀ : ZMod n) (t : ℕ) : Finset (ZMod n) :=
  ((Finset.range (t + 1)).image fun r : ℕ => j₀ + 1 + (r : ZMod n)) ∪
    ((Finset.range (t + 1)).image fun l : ℕ => j₀ - (l : ZMod n))

/-- A seed dark on the tube vanishes on every fan column (the sideways
    sweeps at row 0; no threshold hypothesis). -/
theorem dark_tube_zero_on_fan {j₀ : ZMod n} {t : ℕ} {z : Row n}
    (hz : tubeData j₀ t z = 0) {c : ZMod n} (hc : c ∈ fanColumns j₀ t) :
    z c = 0 := by
  obtain ⟨h0, h1⟩ := tubeData_eq_zero_iff.mp hz
  rcases Finset.mem_union.mp hc with h | h
  · obtain ⟨r, hr, rfl⟩ := Finset.mem_image.mp h
    have := right_sweep z t j₀ h0 h1 r 0
      (by simpa using Nat.lt_succ_iff.mp (Finset.mem_range.mp hr))
    simpa using this
  · obtain ⟨l, hl, rfl⟩ := Finset.mem_image.mp h
    have := left_sweep z t j₀ h0 h1 l 0
      (by simpa using Nat.lt_succ_iff.mp (Finset.mem_range.mp hl))
    simpa using this

/-- For `2(t+1) ≤ n` the two fans neither self-overlap nor collide:
    exactly `2(t+1)` covered columns. -/
theorem fanColumns_card [NeZero n] {j₀ : ZMod n} {t : ℕ}
    (hn : 2 * (t + 1) ≤ n) :
    (fanColumns j₀ t).card = 2 * (t + 1) := by
  have hval : ∀ a ∈ Finset.range (t + 1), a < n := by
    intro a ha
    have := Finset.mem_range.mp ha
    omega
  have hinjR : Set.InjOn (fun r : ℕ => j₀ + 1 + (r : ZMod n))
      ↑(Finset.range (t + 1)) := by
    intro a ha b hb hab
    have h : ((a : ℕ) : ZMod n) = ((b : ℕ) : ZMod n) := add_left_cancel hab
    have := congrArg ZMod.val h
    rwa [ZMod.val_natCast_of_lt (hval a ha), ZMod.val_natCast_of_lt (hval b hb)]
      at this
  have hinjL : Set.InjOn (fun l : ℕ => j₀ - (l : ZMod n))
      ↑(Finset.range (t + 1)) := by
    intro a ha b hb hab
    have h : ((a : ℕ) : ZMod n) = ((b : ℕ) : ZMod n) := by
      have h' : j₀ - ((a : ℕ) : ZMod n) = j₀ - ((b : ℕ) : ZMod n) := hab
      have := sub_right_injective h'
      exact this
    have := congrArg ZMod.val h
    rwa [ZMod.val_natCast_of_lt (hval a ha), ZMod.val_natCast_of_lt (hval b hb)]
      at this
  have hdisj : Disjoint
      ((Finset.range (t + 1)).image fun r : ℕ => j₀ + 1 + (r : ZMod n))
      ((Finset.range (t + 1)).image fun l : ℕ => j₀ - (l : ZMod n)) := by
    rw [Finset.disjoint_left]
    rintro c hcR hcL
    obtain ⟨r, hr, rfl⟩ := Finset.mem_image.mp hcR
    obtain ⟨l, hl, hrl⟩ := Finset.mem_image.mp hcL
    have hr' : r ≤ t := Nat.lt_succ_iff.mp (Finset.mem_range.mp hr)
    have hl' : l ≤ t := Nat.lt_succ_iff.mp (Finset.mem_range.mp hl)
    -- `j₀ − l = j₀ + 1 + r` ⟹ `(r + l + 1 : ZMod n) = 0` ⟹ `n ∣ r + l + 1`
    have hzero : ((r + l + 1 : ℕ) : ZMod n) = 0 := by
      have h' : j₀ - (l : ZMod n) = j₀ + 1 + (r : ZMod n) := hrl
      push_cast
      linear_combination -h'
    have hdvd : n ∣ r + l + 1 := by
      rwa [CharP.cast_eq_zero_iff (ZMod n) n] at hzero
    have hpos : 0 < r + l + 1 := by omega
    have hle := Nat.le_of_dvd hpos hdvd
    omega
  rw [fanColumns, Finset.card_union_of_disjoint hdisj,
    Finset.card_image_of_injOn hinjR, Finset.card_image_of_injOn hinjL,
    Finset.card_range]
  ring

/-- **The kernel bound.** For `2(t+1) ≤ n` the dark-tube kernel has at most
    `2^(n − 2(t+1))` elements: a kernel element is pinned to `0` on the fan
    columns, so it is determined by its values on the free columns. -/
theorem card_ker_tubeDataHom_le [NeZero n] {j₀ : ZMod n} {t : ℕ}
    (hn : 2 * (t + 1) ≤ n) :
    Nat.card (tubeDataHom (n := n) j₀ t).ker ≤ 2 ^ (n - 2 * (t + 1)) := by
  classical
  set F : Finset (ZMod n) := (fanColumns j₀ t)ᶜ with hF
  have hcardF : F.card = n - 2 * (t + 1) := by
    rw [hF, Finset.card_compl, ZMod.card, fanColumns_card hn]
  -- restriction to the free columns is injective on the kernel
  have hinj : Function.Injective
      (fun z : (tubeDataHom (n := n) j₀ t).ker => fun c : F => (z : Row n) c.1) := by
    intro z w hzw
    have hker : tubeData j₀ t ((z : Row n) - (w : Row n)) = 0 := by
      have : tubeDataHom (n := n) j₀ t ((z : Row n) - (w : Row n)) = 0 := by
        rw [map_sub]
        have hz := z.2
        have hw := w.2
        rw [AddMonoidHom.mem_ker] at hz hw
        rw [hz, hw, sub_zero]
      simpa using this
    have hdiff : ((z : Row n) - (w : Row n)) = 0 := by
      funext c
      by_cases hc : c ∈ fanColumns j₀ t
      · exact dark_tube_zero_on_fan hker hc
      · have hcF : c ∈ F := by
          rw [hF, Finset.mem_compl]
          exact hc
        have := congrFun hzw ⟨c, hcF⟩
        show (z : Row n) c - (w : Row n) c = 0
        rw [sub_eq_zero]
        exact this
    exact Subtype.ext (sub_eq_zero.mp hdiff)
  have hle := Nat.card_le_card_of_injective _ hinj
  have hcardfun : Nat.card (F → ZMod 2) = 2 ^ (n - 2 * (t + 1)) := by
    rw [Nat.card_eq_fintype_card, Fintype.card_fun, ZMod.card,
      Fintype.card_coe, hcardF]
  rwa [hcardfun] at hle

/-! ## Surjectivity -/

/-- **Surjectivity of the tube readout for `2(t+1) ≤ n`** — every tube
    reading is realized by some seed. First isomorphism theorem plus the
    kernel bound. -/
theorem tubeData_surjective_of_le [NeZero n] {j₀ : ZMod n} {t : ℕ}
    (hn : 2 * (t + 1) ≤ n) :
    Function.Surjective (tubeData (n := n) j₀ t) := by
  classical
  set f := tubeDataHom (n := n) j₀ t with hf
  -- |Row n| = |Row n ⧸ ker f| · |ker f| and |Row n ⧸ ker f| = |range f|
  have hsplit : Nat.card (Row n) =
      Nat.card (Row n ⧸ f.ker) * Nat.card f.ker :=
    AddSubgroup.card_eq_card_quotient_mul_card_addSubgroup f.ker
  have hquot : Nat.card (Row n ⧸ f.ker) = Nat.card f.range :=
    Nat.card_congr (QuotientAddGroup.quotientKerEquivRange f).toEquiv
  have hdom : Nat.card (Row n) = 2 ^ n := by
    rw [Nat.card_eq_fintype_card, Fintype.card_fun, ZMod.card, ZMod.card]
  have hcod : Nat.card (Fin (t + 1) → ZMod 2 × ZMod 2) = 2 ^ (2 * (t + 1)) := by
    rw [Nat.card_eq_fintype_card, Fintype.card_fun, Fintype.card_prod,
      ZMod.card, Fintype.card_fin,
      show (2 * 2 : ℕ) = 2 ^ 2 by norm_num, ← pow_mul]
  -- range is bounded by the codomain…
  have hrange_le : Nat.card f.range ≤ 2 ^ (2 * (t + 1)) := by
    rw [← hcod]
    exact Nat.card_le_card_of_injective _ Subtype.val_injective
  -- …and the kernel bound forces equality
  have hker_le := card_ker_tubeDataHom_le (j₀ := j₀) (t := t) hn
  have hrange_ge : 2 ^ (2 * (t + 1)) ≤ Nat.card f.range := by
    by_contra hlt
    rw [not_le] at hlt
    have h1 : Nat.card (Row n ⧸ f.ker) * Nat.card f.ker
        < 2 ^ (2 * (t + 1)) * 2 ^ (n - 2 * (t + 1)) := by
      apply Nat.mul_lt_mul_of_lt_of_le (hquot ▸ hlt) hker_le
        (Nat.pow_pos (by norm_num))
    rw [← hsplit, hdom, ← pow_add] at h1
    have : 2 * (t + 1) + (n - 2 * (t + 1)) = n := by omega
    rw [this] at h1
    exact lt_irrefl _ h1
  have hrange_eq : Nat.card f.range = Nat.card (Fin (t + 1) → ZMod 2 × ZMod 2) := by
    rw [hcod]
    omega
  -- a subgroup with full cardinality is everything
  have htop : f.range = ⊤ := by
    apply AddSubgroup.eq_top_of_card_eq
    exact hrange_eq
  intro τ
  have : τ ∈ f.range := htop ▸ AddSubgroup.mem_top τ
  obtain ⟨z, hz⟩ := this
  exact ⟨z, hz⟩

/-- **Surjectivity is exact**: the readout is onto iff `2(t+1) ≤ n`. -/
theorem tubeData_surjective_iff [NeZero n] (j₀ : ZMod n) (t : ℕ) :
    Function.Surjective (tubeData (n := n) j₀ t) ↔ 2 * (t + 1) ≤ n := by
  constructor
  · intro h
    have hcard := Fintype.card_le_of_surjective _ h
    have hdom : Fintype.card (Row n) = 2 ^ n := by
      rw [Fintype.card_fun, ZMod.card, ZMod.card]
    have hcod : Fintype.card (Fin (t + 1) → ZMod 2 × ZMod 2)
        = 2 ^ (2 * (t + 1)) := by
      rw [Fintype.card_fun, Fintype.card_prod, ZMod.card, Fintype.card_fin,
        show (2 * 2 : ℕ) = 2 ^ 2 by norm_num, ← pow_mul]
    rw [hdom, hcod] at hcard
    exact (Nat.pow_le_pow_iff_right (by norm_num : 1 < 2)).mp hcard
  · exact tubeData_surjective_of_le

/-! ## The trichotomy -/

/-- Above the sharp threshold ghosts exist: a nonzero seed dark on the whole
    tube. -/
theorem readout_ghost [NeZero n] {j₀ : ZMod n} {t : ℕ} (hn : 2 * (t + 1) < n) :
    ∃ z : Row n, z ≠ 0 ∧ tubeData j₀ t z = 0 := by
  have hni := tube_not_information_set_of_lt j₀ t hn
  rw [Function.not_injective_iff] at hni
  obtain ⟨x, y, hxy, hne⟩ := hni
  refine ⟨x - y, sub_ne_zero.mpr hne, ?_⟩
  have : tubeDataHom (n := n) j₀ t (x - y) = 0 := by
    rw [map_sub]
    rw [show tubeDataHom (n := n) j₀ t x = tubeData j₀ t x from rfl,
      show tubeDataHom (n := n) j₀ t y = tubeData j₀ t y from rfl, hxy,
      sub_self]
  simpa using this

/-- **T31 — THE READOUT TRICHOTOMY.** With `B = 2(t+1)` tube bits and `n`
    seed unknowns:

    * `n > B` — **ghosts**: the readout is surjective but not injective;
      every reading is realizable, and each is realized by `≥ 2` seeds;
    * `n = B` — **bijective**: every reading realizable by exactly one seed;
      the screen saturates the information bound with zero redundancy;
    * `n < B` — **unrealizable readings**: the readout is injective but not
      surjective; some readings are carried by no seed at all (T27's stall
      regime). -/
theorem readout_trichotomy [NeZero n] (j₀ : ZMod n) (t : ℕ) :
    (2 * (t + 1) < n →
      Function.Surjective (tubeData (n := n) j₀ t) ∧
      ∃ z : Row n, z ≠ 0 ∧ tubeData j₀ t z = 0) ∧
    (n = 2 * (t + 1) → Function.Bijective (tubeData (n := n) j₀ t)) ∧
    (n < 2 * (t + 1) →
      Function.Injective (tubeData (n := n) j₀ t) ∧
      ∃ τ, ∀ z : Row n, tubeData j₀ t z ≠ τ) := by
  refine ⟨fun hn => ⟨tubeData_surjective_of_le (by omega), readout_ghost hn⟩,
    fun hn => ⟨tube_information_set j₀ t (by omega),
      tubeData_surjective_of_le (by omega)⟩,
    fun hn => ⟨tube_information_set j₀ t (by omega), ?_⟩⟩
  have hns : ¬ Function.Surjective (tubeData (n := n) j₀ t) := by
    rw [tubeData_surjective_iff]
    omega
  simp only [Function.Surjective, not_forall, not_exists] at hns
  obtain ⟨τ, hτ⟩ := hns
  exact ⟨τ, hτ⟩

/-- **Bijectivity is exactly the sharp threshold** — the double extreme. -/
theorem tubeData_bijective_iff [NeZero n] (j₀ : ZMod n) (t : ℕ) :
    Function.Bijective (tubeData (n := n) j₀ t) ↔ n = 2 * (t + 1) := by
  constructor
  · rintro ⟨hinj, hsurj⟩
    have h1 := (tube_information_set_iff j₀ t).mp hinj
    have h2 := (tubeData_surjective_iff j₀ t).mp hsurj
    omega
  · intro hn
    exact (readout_trichotomy j₀ t).2.1 hn

end Fans

/-! ### Axiom audit -/
#print axioms tubeData_surjective_iff
#print axioms readout_trichotomy
#print axioms tubeData_bijective_iff

end OPHProofChain.Rule90
