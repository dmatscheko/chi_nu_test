import Mathlib

/-!
# The two P branches, machine-checked (L2.5 §P adjudication + L2.10 value)

Formalizes the arithmetic content of `AUDIT_RESPONSE_REVIEW.md` §P (the
"two P's" finding) and the χ_can numerics it feeds (proof-chain rows L2.5,
L2.6, L2.10).

## Provenance honesty (read first)

* `Ppub` is **defined** as `φ + √π / 137.035999177` — the outer identity of
  `extra/fine_structure_constant_derivation.tex:738–744` evaluated at the
  **CODATA α⁻¹** (`measured_endpoint_calibration.py:104–109`,
  `external_input_used: True`). Every theorem about `Ppub` is therefore
  *conditional on that measured input by definition*. Nothing here derives
  α; this file machine-checks what the published constant **is**.
* `ProotReported = 1.63097209569` is the output of the genuine zero-input
  fixed-point solver (`code/P_derivation/`, reproduced by execution for the
  review). Its *derivation* is not formalized (it needs the solver's
  spectral function); it enters only as the reported decimal, so statements
  involving it are statements about the published numerals.

## Results

* `Ppub_bounds` — `Ppub = 1.630968209403959…` : the published digits are
  exactly the CODATA-calibrated definition (`φ` and `√π` bracketed from
  scratch via `√5` / 20-digit `π` bounds).
* `Proot_gap` — the two branches differ by `3.8×10⁻⁶ … 4.0×10⁻⁶`: the
  published constant and the solver output are **distinct numbers** (the
  ~300 ppm α discrepancy of the review, in P-space).
* `chiCanPub_bounds` — `χ_can = e^(−Ppub/24) = 0.93430063…65` (the L2.10
  falsification target), via a 6-term Taylor sandwich with explicit
  remainder (`Real.exp_bound`), no `native_decide`.
* `chiCanRoot_bounds` — `e^(−Proot/24) = 0.93430048…50`.
* `chi_branch_gap` — `1.4×10⁻⁷ < χ_can^pub − χ_can^root < 1.6×10⁻⁷`:
  the branch discrepancy is **real** (8th digit, sign fixed: the published
  branch is the larger) and **immaterial** for the experiment (every
  tolerance in Documents A/C is ≥ 10⁻³ relative) — exactly the review's
  "Δχ ~ 1.6×10⁻⁷ relative, recorded in A §1.2".

Axioms: standard; no `sorry`, no `native_decide`.
-/

namespace OPHProofChain.PBranches

open Real Finset

/-- The golden ratio `φ = (1+√5)/2` (self-contained definition). -/
noncomputable def phi : ℝ := (1 + Real.sqrt 5) / 2

/-- **The published P, by definition**: `φ + √π / α⁻¹_CODATA`. The literal
    `137.035999177` is the CODATA 2022 inverse fine-structure constant —
    a measured input, entering by definition (see module docstring). -/
noncomputable def Ppub : ℝ := phi + Real.sqrt π / 137.035999177

/-- The zero-input solver's reported root (`code/P_derivation/`,
    reproduced by execution; enters as the published numeral). -/
def ProotReported : ℝ := 1.63097209569

/-! ### Bracketing the ingredients -/

theorem sqrt5_bounds :
    (2.2360679774997896 : ℝ) < Real.sqrt 5 ∧
    Real.sqrt 5 < 2.2360679774997897 := by
  constructor
  · exact (Real.lt_sqrt (by norm_num)).mpr (by norm_num)
  · exact (Real.sqrt_lt' (by norm_num)).mpr (by norm_num)

theorem phi_bounds :
    (1.6180339887498948 : ℝ) < phi ∧ phi < 1.61803398874989485 := by
  obtain ⟨h1, h2⟩ := sqrt5_bounds
  unfold phi
  constructor <;> linarith

theorem sqrtPi_bounds :
    (1.77245385090551602 : ℝ) < Real.sqrt π ∧
    Real.sqrt π < 1.77245385090551603 := by
  constructor
  · exact (Real.lt_sqrt (by norm_num)).mpr
      (lt_trans (by norm_num) pi_gt_d20)
  · exact (Real.sqrt_lt' (by norm_num)).mpr
      (lt_trans pi_lt_d20 (by norm_num))

/-! ### The published digits -/

/-- **`Ppub = 1.630968209403959…`** — the published constant is the
    CODATA-calibrated definition, digit for digit. -/
theorem Ppub_bounds :
    (1.630968209403959 : ℝ) < Ppub ∧ Ppub < 1.630968209403960 := by
  obtain ⟨hφl, hφu⟩ := phi_bounds
  obtain ⟨hsl, hsu⟩ := sqrtPi_bounds
  have hA : (0 : ℝ) < 137.035999177 := by norm_num
  have hdl : (1.77245385090551602 : ℝ) / 137.035999177
      < Real.sqrt π / 137.035999177 := by gcongr
  have hdu : Real.sqrt π / 137.035999177
      < (1.77245385090551603 : ℝ) / 137.035999177 := by gcongr
  have hql : (0.0129342206540644 : ℝ)
      < (1.77245385090551602 : ℝ) / 137.035999177 := by
    refine (lt_div_iff₀ hA).mpr ?_
    norm_num
  have hqu : ((1.77245385090551603 : ℝ) / 137.035999177 : ℝ)
      < 0.0129342206540646 := by
    refine (div_lt_iff₀ hA).mpr ?_
    norm_num
  unfold Ppub
  constructor <;> linarith

/-- **The two branches are distinct numbers**: the solver root exceeds the
    published constant by `3.8×10⁻⁶ … 4.0×10⁻⁶` (the ~300 ppm α
    discrepancy, in P-space). -/
theorem Proot_gap :
    (3.8e-6 : ℝ) < ProotReported - Ppub ∧ ProotReported - Ppub < 4.0e-6 := by
  obtain ⟨h1, h2⟩ := Ppub_bounds
  unfold ProotReported
  constructor <;> [linarith; linarith]

/-! ### The Taylor sandwich for `exp` at a rational point -/

/-- Six-term Taylor sandwich with explicit remainder for `exp` on `[-1, 1]`
    (`Real.exp_bound` at `n = 6`, remainder `|q|⁶·7/4320`; `|q|⁶ = q⁶`). -/
theorem exp_taylor6_sandwich {q lo hi : ℝ} (hq : |q| ≤ 1)
    (hlo : lo ≤ (∑ m ∈ Finset.range 6, q ^ m / (m.factorial : ℝ))
        - q ^ 6 * (7 / 4320))
    (hhi : (∑ m ∈ Finset.range 6, q ^ m / (m.factorial : ℝ))
        + q ^ 6 * (7 / 4320) ≤ hi) :
    lo ≤ Real.exp q ∧ Real.exp q ≤ hi := by
  have hb := Real.exp_bound hq (n := 6) (by norm_num)
  have habs : |q| ^ 6 = q ^ 6 := by
    rw [pow_abs, abs_of_nonneg (by positivity)]
  rw [habs] at hb
  norm_num [Nat.factorial] at hb
  obtain ⟨h1, h2⟩ := abs_le.mp hb
  constructor <;> linarith

/-! ### χ_can on the published branch (L2.10 target) -/

/-- The canonical susceptibility on the published branch:
    `χ_can = e^(−P_pub/24)`. -/
noncomputable def chiCanPub : ℝ := Real.exp (-(Ppub / 24))

/-- The same functional at the solver root. -/
noncomputable def chiCanRoot : ℝ := Real.exp (-(ProotReported / 24))

/-- **`χ_can = 0.9343006…`** — the L2.10 falsification target, to nine
    digits, from the definition of `Ppub` alone. -/
theorem chiCanPub_bounds :
    (0.934300639 : ℝ) < chiCanPub ∧ chiCanPub < 0.93430064 := by
  obtain ⟨hPl, hPu⟩ := Ppub_bounds
  -- sandwich `exp` at the two rational endpoints of the `Ppub` bracket
  have hlo := (exp_taylor6_sandwich (q := -(1.630968209403960 / 24))
      (lo := 0.9343006391) (hi := 1)
      (by rw [abs_neg, abs_of_nonneg (by norm_num)]; norm_num)
      (by
        rw [Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ,
          Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ,
          Finset.sum_range_zero]
        norm_num [Nat.factorial])
      (by
        rw [Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ,
          Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ,
          Finset.sum_range_zero]
        norm_num [Nat.factorial])).1
  have hhi := (exp_taylor6_sandwich (q := -(1.630968209403959 / 24))
      (lo := 0) (hi := 0.9343006396)
      (by rw [abs_neg, abs_of_nonneg (by norm_num)]; norm_num)
      (by
        rw [Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ,
          Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ,
          Finset.sum_range_zero]
        norm_num [Nat.factorial])
      (by
        rw [Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ,
          Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ,
          Finset.sum_range_zero]
        norm_num [Nat.factorial])).2
  have hm1 : Real.exp (-(1.630968209403960 / 24)) ≤ chiCanPub := by
    unfold chiCanPub
    exact Real.exp_le_exp.mpr (by linarith)
  have hm2 : chiCanPub ≤ Real.exp (-(1.630968209403959 / 24)) := by
    unfold chiCanPub
    exact Real.exp_le_exp.mpr (by linarith)
  constructor
  · linarith
  · linarith

/-- **`e^(−P_root/24) = 0.93430048…`** — the solver-branch value. -/
theorem chiCanRoot_bounds :
    (0.934300487 : ℝ) < chiCanRoot ∧ chiCanRoot < 0.934300489 := by
  have h := exp_taylor6_sandwich (q := -(1.63097209569 / 24))
      (lo := 0.9343004879) (hi := 0.9343004883)
      (by rw [abs_neg, abs_of_nonneg (by norm_num)]; norm_num)
      (by
        rw [Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ,
          Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ,
          Finset.sum_range_zero]
        norm_num [Nat.factorial])
      (by
        rw [Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ,
          Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ,
          Finset.sum_range_zero]
        norm_num [Nat.factorial])
  unfold chiCanRoot ProotReported
  constructor
  · linarith [h.1]
  · linarith [h.2]

/-- **The branch discrepancy in χ**: real (8th digit, published branch
    larger) and immaterial (`< 1.6×10⁻⁷`, far inside every tolerance of
    Documents A/C). This is the review's "Δχ ~ 1.6×10⁻⁷ — immaterial for
    the experiment", machine-checked. -/
theorem chi_branch_gap :
    (1.4e-7 : ℝ) < chiCanPub - chiCanRoot ∧
    chiCanPub - chiCanRoot < 1.6e-7 := by
  obtain ⟨h1, h2⟩ := chiCanPub_bounds
  obtain ⟨h3, h4⟩ := chiCanRoot_bounds
  constructor <;> linarith

/-! ### Axiom audit -/
#print axioms Ppub_bounds
#print axioms Proot_gap
#print axioms chiCanPub_bounds
#print axioms chiCanRoot_bounds
#print axioms chi_branch_gap

end OPHProofChain.PBranches
