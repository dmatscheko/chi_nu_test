import Mathlib
import OPHProofChain.Rule90Decoding

/-!
# T38 [formal-v10] — the parity splitting: R1 formalized

**Provenance.** chi_nu_test original (formal-v10 campaign). This module is the
Lean transcription of finding **R1** of `oph_sim/FINDINGS.md` (item 24): on an
even cylinder the Rule-90 spacetime block splits into two non-interacting
parity sectors, each of which is a **Rule-60** system. The numerical evidence
(23 600 cells bit-identical, kernel direct sums on 300 random subsets, and an
exhaustive statement-level check of the T38 classification on 4 096 subsets at
`(6,1)` plus randomized `(10,3)`/`(12,·)` sweeps) preceded this file; here the
splitting becomes theorems.

## Contents

1. **R1a — sector blindness** (`traj_congr_on_class`): on an even cylinder the
   value of cell `(i,j)` depends only on the seed's values on the parity class
   `castHom j + i` of the spacetime checkerboard. Corollaries:
   `traj_eq_zero_of_class_zero` and the crisp independence statement
   `traj_parityProj` (`traj (parityProj p c) = traj c` on sector-`p` cells and
   `0` elsewhere — "the sectors do not talk").

2. **T38 — the even-ring classification reduction**
   (`isInformationSet_iff_single_parity_ghost`,
   `not_isInformationSet_iff_single_parity_shadow`): an arbitrary cell set `S`
   on an even cylinder fails to be an information set **iff a nonzero
   single-parity ghost is dark on `S`**. This is *unconditional in `t` and
   `S`* and proves the containment half of conjecture C1: every failing subset
   is shadowed by a single-parity ghost, so the maximal ghost shadows are
   found among the `2^{n/2+1} − 2` single-parity seeds. (The exactness half —
   that distinct single-parity ghosts have incomparable shadows — is Rule-60
   zero-set rigidity, numerically verified through `m = 13` but open.)

3. **Rule 60 and its iterate calculus** (`rule60`,
   `rule60_iterate_succ_apply`, `rule60_iterate_two_apply`,
   `rule60_iterate_shift`, and the bridge `traj_eq_rule60_iterate`:
   `traj x i j = rule60^[2i] x (j − i)`). Rule 90 *is* the square of Rule 60
   composed with a drift — this identity, checked exactly for all
   `n = 3..20` in the probes, is the engine of the v10 modules
   (`Rule90TwoPower`, `Rule90Diagonal`).

4. **R1b — the half-ring conjugacy** (`sectorTrace_succ`,
   `sectorTrace_eq_iterate`): reading an even-`n` trajectory along a sector
   (base column `b`, half-ring coordinate `u ↦ i + b + 2u`) evolves by
   **Rule 60 on `ZMod m`**, `n = 2m` — the "two independent Rule-60 systems"
   statement, exact and horizon-free.

No `sorry`, no new axioms, no `native_decide` (the `decide` calls below are
kernel-checked case splits on `ZMod 2` values).
-/

namespace OPHProofChain.Rule90

variable {n : ℕ}

/-! ## `ZMod 2` step arithmetic (kernel-decided case splits) -/

private theorem zmod2_step_sub : ∀ x i p : ZMod 2, x + (i + 1) = p → (x - 1) + i = p := by
  decide

private theorem zmod2_step_add : ∀ x i p : ZMod 2, x + (i + 1) = p → (x + 1) + i = p := by
  decide

private theorem zmod2_eq_one_of_ne_zero : ∀ a : ZMod 2, a ≠ 0 → a = 1 := by
  decide

/-! ## R1a — sector blindness

The Rule-90 stencil moves diagonally: the cell `(i, j)` reads seeds only on
the sites `j' ≡ j + i (mod 2)`. On an even cylinder that congruence is a
well-defined `ZMod 2` class via `ZMod.castHom`, and induction on `i` makes the
blindness exact. -/

/-- **R1a.** On an even cylinder, two seeds that agree on the parity class `p`
    have identical trajectories at every spacetime cell of sector `p`
    (`sector (i,j) := castHom j + i`). The other class is invisible from
    sector `p`. -/
theorem traj_congr_on_class (hn : 2 ∣ n) {p : ZMod 2} {c c' : Row n}
    (hcc : ∀ j, ZMod.castHom hn (ZMod 2) j = p → c j = c' j) :
    ∀ (i : ℕ) (j : ZMod n), ZMod.castHom hn (ZMod 2) j + (i : ZMod 2) = p →
      traj c i j = traj c' i j := by
  intro i
  induction i with
  | zero =>
    intro j hj
    simpa using hcc j (by simpa using hj)
  | succ i ih =>
    intro j hj
    push_cast at hj
    have h₁ : (ZMod.castHom hn (ZMod 2)) (j - 1) + (i : ZMod 2) = p := by
      rw [map_sub, map_one]
      exact zmod2_step_sub _ _ _ hj
    have h₂ : (ZMod.castHom hn (ZMod 2)) (j + 1) + (i : ZMod 2) = p := by
      rw [map_add, map_one]
      exact zmod2_step_add _ _ _ hj
    rw [traj_succ_apply, traj_succ_apply, ih (j - 1) h₁, ih (j + 1) h₂]

/-- A seed vanishing on the parity class `p` has zero trajectory at every
    cell of sector `p`. -/
theorem traj_eq_zero_of_class_zero (hn : 2 ∣ n) {p : ZMod 2} {c : Row n}
    (hc : ∀ j, ZMod.castHom hn (ZMod 2) j = p → c j = 0) (i : ℕ) (j : ZMod n)
    (hj : ZMod.castHom hn (ZMod 2) j + (i : ZMod 2) = p) : traj c i j = 0 := by
  have h := traj_congr_on_class hn (c := c) (c' := 0)
    (fun j hj => by simpa using hc j hj) i j hj
  simpa using h

/-! ## The parity projections -/

/-- The restriction of a seed to the parity class `p` (zero elsewhere). -/
def parityProj (hn : 2 ∣ n) (p : ZMod 2) (c : Row n) : Row n :=
  fun j => if ZMod.castHom hn (ZMod 2) j = p then c j else 0

theorem parityProj_apply_of_class (hn : 2 ∣ n) {p : ZMod 2} (c : Row n) {j : ZMod n}
    (hj : ZMod.castHom hn (ZMod 2) j = p) : parityProj hn p c j = c j := if_pos hj

theorem parityProj_apply_of_ne_class (hn : 2 ∣ n) {p : ZMod 2} (c : Row n) {j : ZMod n}
    (hj : ZMod.castHom hn (ZMod 2) j ≠ p) : parityProj hn p c j = 0 := if_neg hj

/-- The two parity projections reassemble the seed. -/
theorem parityProj_add (hn : 2 ∣ n) (c : Row n) :
    parityProj hn 0 c + parityProj hn 1 c = c := by
  funext j
  by_cases h : ZMod.castHom hn (ZMod 2) j = 0
  · simp [Pi.add_apply, parityProj, h]
  · have h1 : ZMod.castHom hn (ZMod 2) j = 1 := zmod2_eq_one_of_ne_zero _ h
    simp [Pi.add_apply, parityProj, h1]

/-- **The independence statement (R1a, crisp form).** The trajectory of a
    parity projection agrees with the full trajectory on the matching sector
    and vanishes identically on the other — the two sectors never talk. -/
theorem traj_parityProj (hn : 2 ∣ n) (c : Row n) (p : ZMod 2) (i : ℕ) (j : ZMod n) :
    traj (parityProj hn p c) i j =
      if ZMod.castHom hn (ZMod 2) j + (i : ZMod 2) = p then traj c i j else 0 := by
  split_ifs with hs
  · exact traj_congr_on_class hn (fun j' hj' => parityProj_apply_of_class hn c hj') i j hs
  · exact traj_eq_zero_of_class_zero hn
      (fun j' hj' => parityProj_apply_of_ne_class hn c
        (fun hp => hs (hj'.symm.trans hp))) i j rfl

/-- Darkness (vanishing on a cell set) is inherited by the parity projections:
    matching-sector cells agree with the dark full ghost, other-sector cells
    are blind to the projection altogether. -/
theorem VanishesOn.parityProj (hn : 2 ∣ n) {t : ℕ} {S : Finset (Cell n t)} {z : Row n}
    (hz : VanishesOn S z) (p : ZMod 2) : VanishesOn S (Rule90.parityProj hn p z) := by
  intro q hq
  rw [traj_parityProj]
  split_ifs with hs
  · exact hz q hq
  · rfl

/-! ## T38 — the even-ring classification reduction -/

/-- A seed supported on a single parity class. -/
def SingleParity (hn : 2 ∣ n) (p : ZMod 2) (z : Row n) : Prop :=
  ∀ j, ZMod.castHom hn (ZMod 2) j ≠ p → z j = 0

theorem singleParity_parityProj (hn : 2 ∣ n) (p : ZMod 2) (z : Row n) :
    SingleParity hn p (parityProj hn p z) :=
  fun _ hj => if_neg hj

/-- **T38.** On an even cylinder an arbitrary cell set is an information set
    iff no nonzero *single-parity* ghost is dark on it: the general
    decodability question reduces to the two parity sectors separately.
    Unconditional in `t`, `S`. -/
theorem isInformationSet_iff_single_parity_ghost (hn : 2 ∣ n) {t : ℕ}
    (S : Finset (Cell n t)) :
    IsInformationSet S ↔
      ∀ (p : ZMod 2) (z : Row n), SingleParity hn p z → VanishesOn S z → z = 0 := by
  rw [isInformationSet_iff_vanishing]
  constructor
  · exact fun h p z _ hz => h z hz
  · intro h z hz
    have h0 : parityProj hn 0 z = 0 :=
      h 0 _ (singleParity_parityProj hn 0 z) (hz.parityProj hn 0)
    have h1 : parityProj hn 1 z = 0 :=
      h 1 _ (singleParity_parityProj hn 1 z) (hz.parityProj hn 1)
    rw [← parityProj_add hn z, h0, h1, add_zero]

/-- **T38, failure form (the C1 containment).** An arbitrary cell set on an
    even cylinder fails iff some nonzero single-parity ghost shadows it — the
    maximal ghost shadows all come from single-parity seeds. -/
theorem not_isInformationSet_iff_single_parity_shadow (hn : 2 ∣ n) {t : ℕ}
    (S : Finset (Cell n t)) :
    ¬ IsInformationSet S ↔
      ∃ (p : ZMod 2) (z : Row n), z ≠ 0 ∧ SingleParity hn p z ∧ VanishesOn S z := by
  rw [isInformationSet_iff_single_parity_ghost hn S]
  constructor
  · intro h
    by_contra hno
    apply h
    intro p z hsp hv
    by_contra hz
    exact hno ⟨p, z, hz, hsp, hv⟩
  · rintro ⟨p, z, hz, hsp, hv⟩ h
    exact hz (h p z hsp hv)

/-! ## Rule 60 and its iterate calculus

`rule60 y u = y u + y (u+1)` is the one-sided additive automaton (Wolfram's
Rule 60, up to orientation). Rule 90 is its square composed with a unit
drift: `traj x i j = rule60^[2i] x (j − i)`. Everything the v10 modules do
flows through this bridge. -/

/-- One step of **Rule 60**: each cell becomes the sum of itself and its
    right neighbour (the difference operator `1 + σ`). -/
def rule60 {m : ℕ} (y : Row m) : Row m := fun u => y u + y (u + 1)

theorem rule60_apply {m : ℕ} (y : Row m) (u : ZMod m) :
    rule60 y u = y u + y (u + 1) := rfl

/-- Pointwise recursion for Rule-60 iterates. -/
theorem rule60_iterate_succ_apply (w : Row n) (i : ℕ) (u : ZMod n) :
    rule60^[i + 1] w u = rule60^[i] w u + rule60^[i] w (u + 1) := by
  rw [Function.iterate_succ_apply']
  rfl

/-- Two Rule-60 steps skip the odd site: the square is the gap-2 difference. -/
theorem rule60_sq_apply (y : Row n) (u : ZMod n) :
    rule60 (rule60 y) u = y u + y (u + 2) := by
  have h : ∀ a b c : ZMod 2, a + b + (b + c) = a + c := by decide
  show (y u + y (u + 1)) + (y (u + 1) + y (u + 1 + 1)) = y u + y (u + 2)
  rw [show u + 1 + 1 = u + 2 by ring]
  exact h _ _ _

theorem rule60_iterate_two_apply (y : Row n) (u : ZMod n) :
    rule60^[2] y u = y u + y (u + 2) := by
  show rule60 (rule60 y) u = y u + y (u + 2)
  exact rule60_sq_apply y u

/-- **The bridge: Rule 90 is drifted double Rule 60.** Checked exactly for
    all `n = 3..20` (probe E1) before formalization. -/
theorem traj_eq_rule60_iterate (x : Row n) (i : ℕ) (j : ZMod n) :
    traj x i j = rule60^[2 * i] x (j - (i : ZMod n)) := by
  induction i generalizing j with
  | zero => simp
  | succ i ih =>
    rw [traj_succ_apply, ih (j - 1), ih (j + 1),
      show 2 * (i + 1) = 2 + 2 * i by ring,
      Function.iterate_add_apply, rule60_iterate_two_apply]
    have e1 : j - 1 - (i : ZMod n) = j - ((i + 1 : ℕ) : ZMod n) := by
      push_cast; ring
    have e2 : j + 1 - (i : ZMod n) = j - ((i + 1 : ℕ) : ZMod n) + 2 := by
      push_cast; ring
    rw [e1, e2]

/-! ## R1b — the half-ring conjugacy

On `n = 2m` the even residues are the image of `ZMod m` under doubling; along
a sector (base column `b`, time `i`, half-ring coordinate `u`), the Rule-90
trajectory evolves by Rule 60 *on the half ring*. -/

private theorem two_mul_natCast_mod (m a : ℕ) :
    (2 : ZMod (2 * m)) * ((a % m : ℕ) : ZMod (2 * m)) = 2 * (a : ZMod (2 * m)) := by
  have h0 : (2 : ZMod (2 * m)) * (m : ZMod (2 * m)) = 0 := by
    have h := ZMod.natCast_self (2 * m)
    push_cast at h
    exact h
  calc (2 : ZMod (2 * m)) * ((a % m : ℕ) : ZMod (2 * m))
      = 2 * ((a % m : ℕ) : ZMod (2 * m))
        + (2 * (m : ZMod (2 * m))) * ((a / m : ℕ) : ZMod (2 * m)) := by rw [h0]; ring
    _ = ((2 * (a % m + m * (a / m)) : ℕ) : ZMod (2 * m)) := by push_cast; ring
    _ = 2 * (a : ZMod (2 * m)) := by rw [Nat.mod_add_div]; push_cast; ring

/-- The doubling embedding of the half ring: `u ↦ 2·u.val` lands on the even
    residues of `ZMod (2m)`. -/
def halfEmbed (m : ℕ) (u : ZMod m) : ZMod (2 * m) := 2 * ((u.val : ℕ) : ZMod (2 * m))

/-- The one property the conjugacy needs: doubling turns `+1` on the half
    ring into `+2` on the full ring. -/
theorem halfEmbed_add_one (m : ℕ) [NeZero m] (u : ZMod m) :
    halfEmbed m (u + 1) = halfEmbed m u + 2 := by
  unfold halfEmbed
  have h1 : ((u.val : ℕ) : ZMod m) = u := by rw [ZMod.natCast_val, ZMod.cast_id]
  have h2 : u + 1 = ((u.val + 1 : ℕ) : ZMod m) := by push_cast; rw [h1]
  have hval : (u + 1).val = (u.val + 1) % m := by rw [h2, ZMod.val_natCast]
  rw [hval, two_mul_natCast_mod]
  push_cast
  ring

/-- The trace of the trajectory of `c` along the sector with base column `b`:
    at time `i`, half-ring coordinate `u`, read cell `(i, i + b + 2u)`. -/
def sectorTrace (m : ℕ) (c : Row (2 * m)) (b : ZMod (2 * m)) (i : ℕ) : Row m :=
  fun u => traj c i ((i : ZMod (2 * m)) + b + halfEmbed m u)

/-- **R1b — the parity/Rule-60 splitting.** A sector trace of Rule 90 on the
    even cylinder evolves by **Rule 60 on the half ring**: the even-`n`
    spacetime block *is* two independent Rule-60 systems. -/
theorem sectorTrace_succ (m : ℕ) [NeZero m] (c : Row (2 * m)) (b : ZMod (2 * m)) (i : ℕ) :
    sectorTrace m c b (i + 1) = rule60 (sectorTrace m c b i) := by
  funext u
  show traj c (i + 1) _ = _
  rw [traj_succ_apply]
  have e1 : ((i + 1 : ℕ) : ZMod (2 * m)) + b + halfEmbed m u - 1
      = (i : ZMod (2 * m)) + b + halfEmbed m u := by push_cast; ring
  have e2 : ((i + 1 : ℕ) : ZMod (2 * m)) + b + halfEmbed m u + 1
      = (i : ZMod (2 * m)) + b + (halfEmbed m u + 2) := by push_cast; ring
  rw [e1, e2, ← halfEmbed_add_one]
  rfl

/-- The sector trace at time `i` is the `i`-fold Rule-60 iterate of the
    initial trace: the conjugacy, integrated. -/
theorem sectorTrace_eq_iterate (m : ℕ) [NeZero m] (c : Row (2 * m)) (b : ZMod (2 * m))
    (i : ℕ) : sectorTrace m c b i = rule60^[i] (sectorTrace m c b 0) := by
  induction i with
  | zero => rfl
  | succ i ih => rw [sectorTrace_succ, ih, Function.iterate_succ_apply']

-- Axiom audit: these must report only `[propext, Classical.choice, Quot.sound]`.
#print axioms traj_congr_on_class
#print axioms traj_parityProj
#print axioms isInformationSet_iff_single_parity_ghost
#print axioms not_isInformationSet_iff_single_parity_shadow
#print axioms traj_eq_rule60_iterate
#print axioms sectorTrace_succ
#print axioms sectorTrace_eq_iterate

end OPHProofChain.Rule90
