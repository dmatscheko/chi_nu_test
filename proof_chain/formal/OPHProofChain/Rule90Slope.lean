import Mathlib
import OPHProofChain.Rule90Decoding

/-!
# T34-lite [formal-v8] — sloped screens: the definition, the free half, and
machine-checked threshold instances

**Provenance.** chi_nu_test original (formal-v8 campaign). The
slope-invariance conjecture (F6 of `OPH_PROOF_CHAIN_HOLES.md`; chain doc
§26) says: screens of every rational slope `0 ≤ p/q ≤ 1` are information
sets exactly at the sharp threshold `n ≤ 2(t+1)`.

> **Update (formal-v9): the conjecture is CLOSED.** The general positive
> half is now the theorem `slopeTube_isInformationSet_iff` in
> `Rule90Lipschitz.lean` (T36), a corollary of the Lipschitz worldline
> theorem — the sheared-CA attack recorded below dissolved into a direct
> two-chain fan induction. This module remains as the definition layer and
> the kernel-checked sample points.

At v8 time the general theorem remained open (the recorded attack: shear
`y_i(j) = x_i(j + ⌊s·i⌋)` turns the sloped screen into a straight tube of
a *time-inhomogeneous* CA alternating rule-90 and shifted-double steps,
with parity-staggered sweep depths). This module contributes the pieces
that are free or finite:

* **the definition** (`slopeTube`) — previously the conjecture lived in
  prose and in committed sweep artifacts (`evidence/slope_sweep.txt`,
  floor convention); the Lean definition pins it down and provably matches
  the two proven extremes (`slopeTube_zero_eq_tubeSet`; slope 1 is the
  lightlike screen geometry of T18a, same floor convention);
* **the failure half, at every slope** (`slopeTube_not_informationSet`):
  beyond the threshold no sloped screen can work — the counting bound is
  slope-blind;
* **threshold instances, kernel-checked** (`slope_half_*`, `slope_third_*`,
  `slope_twoThirds_*`): at the exact threshold `n = 2(t+1)` the slopes
  1/2, 1/3, 2/3 all decode — the conjecture's content at sample points,
  now in-tree (the `n ≤ 20` sweep lives in `evidence/`).

Together with T9 (slope 0) and T18a (slope 1), every *rational slope in
lowest terms with `q ≤ 3`* has at least one machine-checked positive
instance at the sharp threshold, and the negative half is a theorem at all
slopes. What was open at v8 — the positive half for general `n` — is
closed in v9 by T36 (`Rule90Lipschitz.lean`).

Axioms: standard (`propext`, `Classical.choice`, `Quot.sound`); no `sorry`,
no `native_decide`.
-/

namespace OPHProofChain.Rule90

variable {n : ℕ}

/-- The slope-`p/q` screen (floor convention): at time `i` read the two
    adjacent cells at columns `j₀ + ⌊i·p/q⌋` and `j₀ + ⌊i·p/q⌋ + 1`.
    Slope `0/1` is the timelike tube of T9; slope `1/1` is the lightlike
    screen of T18a. This is the definition the committed sweep artifact
    (`evidence/slope_sweep.txt`) checks for all `n ≤ 20`. -/
def slopeTube [NeZero n] (p q t : ℕ) (j₀ : ZMod n) : Finset (Cell n t) :=
  colFamily t (fun i => j₀ + ((i.val * p / q : ℕ) : ZMod n))
    (fun i => j₀ + ((i.val * p / q : ℕ) : ZMod n) + 1)

/-- Sloped screens read at most `2(t+1)` cells — the counting envelope is
    slope-independent. -/
theorem slopeTube_card_le [NeZero n] (p q t : ℕ) (j₀ : ZMod n) :
    (slopeTube p q t j₀).card ≤ 2 * (t + 1) :=
  colFamily_card_le _ _

/-- Slope `0` is exactly the timelike tube of T9. -/
theorem slopeTube_zero_eq_tubeSet [NeZero n] (q t : ℕ) (j₀ : ZMod n) :
    slopeTube 0 q t j₀ = tubeSet t j₀ := by
  unfold slopeTube tubeSet
  congr 1 <;> funext i <;> simp [Nat.zero_div]

/-- **The failure half of the slope conjecture, at every slope**: beyond
    the sharp threshold no sloped screen is an information set. The
    counting bound does not care about the slope. -/
theorem slopeTube_not_informationSet [NeZero n] (p q t : ℕ) (j₀ : ZMod n)
    (hn : 2 * (t + 1) < n) : ¬ IsInformationSet (slopeTube p q t j₀) :=
  card_lt_not_informationSet
    (lt_of_le_of_lt (slopeTube_card_le p q t j₀) hn)

/-! ## Threshold instances, kernel-checked

Each is at the exact threshold `n = 2(t+1)` — full capacity through a
tilted screen. Together with `slopeTube_not_informationSet` at
`n = 2(t+1) + 1`, these are the conjecture's sample points as theorems. -/

section Instances

set_option maxRecDepth 8192
set_option maxHeartbeats 3200000

/-- Slope 1/2 decodes at the sharp threshold (`n = 8, t = 3`). -/
theorem slope_half_8_3 :
    IsInformationSet (slopeTube (n := 8) 1 2 3 0) := by decide

/-- Slope 1/3 decodes at the sharp threshold (`n = 8, t = 3`). -/
theorem slope_third_8_3 :
    IsInformationSet (slopeTube (n := 8) 1 3 3 0) := by decide

/-- Slope 2/3 decodes at the sharp threshold (`n = 8, t = 3`). -/
theorem slope_twoThirds_8_3 :
    IsInformationSet (slopeTube (n := 8) 2 3 3 0) := by decide

/-- Slope 1/2 decodes at the sharp threshold on an odd ring
    (`n = 7, t = 3`, `7 ≤ 8`). -/
theorem slope_half_7_3 :
    IsInformationSet (slopeTube (n := 7) 1 2 3 0) := by decide

/-- Slope 1/2 at `n = 10, t = 4` — the exact threshold one size up. -/
theorem slope_half_10_4 :
    IsInformationSet (slopeTube (n := 10) 1 2 4 0) := by decide

end Instances

/-! ### Axiom audit -/
#print axioms slopeTube_not_informationSet
#print axioms slopeTube_zero_eq_tubeSet
#print axioms slope_half_8_3
#print axioms slope_half_10_4

end OPHProofChain.Rule90
