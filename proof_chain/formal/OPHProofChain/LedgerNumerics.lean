import Mathlib

/-!
# Run-matrix conversion constants, theorem-form (test ledgers, DOCUMENT C)

**Status: native to `chi_nu_test/`** — this module machine-checks the
*derived instrument numbers* that the test ledgers' decision rules quote:
`../../test/DOCUMENT_A_prediction_ledger.md` §§1.1, 5 and
`../../test/DOCUMENT_C_run_matrix_and_error_budget.md` §§0–4. It extends
`EnergyCage.lean`'s "§5 arithmetic with π-bounds" to the run matrix, so
that a NULL/DETECT verdict converts through *theorem-form* constants. All
inputs are the ledgers' own declared values (`g = 9.80665`,
`G = 6.67430×10⁻¹¹`, `A = 4.8×10⁻³ m²`, `F_min = 5×10⁻⁸ N`,
`E_batt = 3.6×10⁴ J`).

Checked against the printed ledger values:

| printed (ledger) | theorem here | verdict |
|---|---|---|
| `C_geom = 1.146637×10¹¹ N m⁻²` | `∈ (1.146636, 1.146638)×10¹¹` | print exact to 7 digits |
| `C_geom·A = 5.50×10⁸ N` (one zone) | `∈ (5.5038, 5.5039)×10⁸` | ✓ |
| `Δν_min (lock-in) = 9.1×10⁻¹⁷` | `∈ (9.084, 9.085)×10⁻¹⁷` | print rounds up — **conservative-safe** as a null bound |
| design force `0.550 N` at `Δν = 10⁻⁹` | `∈ (0.55038, 0.55039)` | ✓ (and `∈ (56.12, 56.13)` gf — printed "56 gf") |
| design SNR `1.1×10⁷` | `∈ (1.100, 1.101)×10⁷` | ✓ |
| lock-in statistical floor `≈ 3.3×10⁻⁸ N` | `= 10⁻⁶/30` **exactly** (`√(2/1800) = 1/30`), `∈ (3.33, 3.34)×10⁻⁸` | ✓ |
| battery coupon `χ·ΔS ≲ 1×10⁻¹¹ (≈ 0.5 gf)` | `∈ (1.02, 1.03)×10⁻¹¹` (`∈ (0.575, 0.578)` gf) | **ERRATUM: the printed bound is ~3 % low.** A battery-sourced signal can reach `1.03×10⁻¹¹`, slightly *above* the printed ceiling; the honest print is "≲ 1.1×10⁻¹¹ (≈ 0.58 gf)". Fixed in DOCUMENT A §1.9 with a pointer here. |

The remaining run-matrix rows (torsion/static/small-coupon/full-board and
the hover-threshold rows) are the same three operations — multiply by
`C_geom`, multiply by the area, divide by `F_min` — and are *not*
duplicated here; the headline lock-in row and the design point are the
rows the decision rules in DOCUMENT C §4 actually consume.

Axioms: standard; no `sorry`, no `native_decide`. π enters through
Mathlib's `pi_gt_d6`/`pi_lt_d6` as in `EnergyCage.lean`.
-/

namespace OPHProofChain.LedgerNumerics

open Real

/-- **`C_geom = g²/(4πG)` to seven digits** — the ledger's
    `1.146637×10¹¹ N m⁻²` (DOCUMENT A §1.1) is exact to its last printed
    digit: the true value is `1.1466365…×10¹¹`. -/
theorem Cgeom_bounds :
    1.146636e11 < 9.80665 ^ 2 / (4 * π * 6.67430e-11) ∧
    9.80665 ^ 2 / (4 * π * 6.67430e-11) < 1.146638e11 := by
  have hπl : (3.141592 : ℝ) < π := pi_gt_d6
  have hπu : π < 3.141593 := pi_lt_d6
  have hden : (0 : ℝ) < 4 * π * 6.67430e-11 := by positivity
  constructor
  · rw [lt_div_iff₀ hden]
    nlinarith
  · rw [div_lt_iff₀ hden]
    nlinarith

/-- The one-zone conversion constant `C_geom · A` for the baseline coupon
    (`A = 4.8×10⁻³ m²`, 80×60 mm): the run matrix's `5.50×10⁸ N` per unit
    `Δν`. -/
theorem CgeomA_bounds :
    5.5038e8 < 9.80665 ^ 2 / (4 * π * 6.67430e-11) * 4.8e-3 ∧
    9.80665 ^ 2 / (4 * π * 6.67430e-11) * 4.8e-3 < 5.5039e8 := by
  obtain ⟨hl, hu⟩ := Cgeom_bounds
  constructor <;> nlinarith

/-- **The headline null-bound conversion**: the lock-in row's
    `Δν_min = F_min/(C_geom·A) = 9.1×10⁻¹⁷` at `F_min = 5×10⁻⁸ N`. True
    value `9.0845…×10⁻¹⁷` — the print rounds *up*, which is the safe
    direction for a null bound (`χ·ΔS ≤ Δν_min` is quoted weaker than
    proven). -/
theorem dnu_min_bounds :
    9.084e-17 < 5e-8 / (9.80665 ^ 2 / (4 * π * 6.67430e-11) * 4.8e-3) ∧
    5e-8 / (9.80665 ^ 2 / (4 * π * 6.67430e-11) * 4.8e-3) < 9.085e-17 := by
  obtain ⟨hl, hu⟩ := CgeomA_bounds
  have hpos : (0 : ℝ) < 9.80665 ^ 2 / (4 * π * 6.67430e-11) * 4.8e-3 := by
    nlinarith
  constructor
  · rw [lt_div_iff₀ hpos]
    nlinarith
  · rw [div_lt_iff₀ hpos]
    nlinarith

/-- The design point: `Δν = 10⁻⁹` on the baseline coupon is
    `0.550 N` (DOCUMENT C §2 row 2). -/
theorem design_force_bounds :
    0.55038 < 9.80665 ^ 2 / (4 * π * 6.67430e-11) * 4.8e-3 * 1e-9 ∧
    9.80665 ^ 2 / (4 * π * 6.67430e-11) * 4.8e-3 * 1e-9 < 0.55039 := by
  obtain ⟨hl, hu⟩ := CgeomA_bounds
  constructor <;> nlinarith

/-- …which is the ledger's "56 gf" design point (true value 56.12 gf). -/
theorem design_gf_bounds :
    56.12 < 9.80665 ^ 2 / (4 * π * 6.67430e-11) * 4.8e-3 * 1e-9 * 1000 / 9.80665 ∧
    9.80665 ^ 2 / (4 * π * 6.67430e-11) * 4.8e-3 * 1e-9 * 1000 / 9.80665 < 56.13 := by
  obtain ⟨hl, hu⟩ := design_force_bounds
  have hg : (0 : ℝ) < 9.80665 := by norm_num
  constructor
  · rw [lt_div_iff₀ hg]
    nlinarith
  · rw [div_lt_iff₀ hg]
    nlinarith

/-- …and the design-point SNR against the quoted lock-in floor
    `F_min = 5×10⁻⁸ N` is the run matrix's `1.1×10⁷`. -/
theorem design_snr_bounds :
    1.100e7 < 9.80665 ^ 2 / (4 * π * 6.67430e-11) * 4.8e-3 * 1e-9 / 5e-8 ∧
    9.80665 ^ 2 / (4 * π * 6.67430e-11) * 4.8e-3 * 1e-9 / 5e-8 < 1.101e7 := by
  obtain ⟨hl, hu⟩ := design_force_bounds
  have h5 : (0 : ℝ) < 5e-8 := by norm_num
  constructor
  · rw [lt_div_iff₀ h5]
    nlinarith
  · rw [div_lt_iff₀ h5]
    nlinarith

/-- **The lock-in statistical floor is exactly `10⁻⁶/30 N`**: DOCUMENT C
    §1.3's `σ_F = σ₁·√(2/n_eff)` at `σ₁ = 10⁻⁶ N`, `n_eff = 1800` has
    `√(2/1800) = √(1/900) = 1/30` — the quoted `3.3×10⁻⁸ N` is
    `3.3̅×10⁻⁸` exactly, no numerics involved. -/
theorem lockin_stat_exact :
    1e-6 * Real.sqrt (2 / 1800) = 1e-6 / 30 := by
  rw [show (2 : ℝ) / 1800 = (1 / 30) ^ 2 from by norm_num,
    Real.sqrt_sq (by norm_num : (0 : ℝ) ≤ 1 / 30)]
  norm_num

/-- **The battery-coupon ceiling, corrected (ERRATUM to DOCUMENT A §1.9).**
    A battery-powered coupon (`E_batt = 3.6×10⁴ J`) toggling against the
    Earth potential `Φ_N ∈ (6.24, 6.26)×10⁷ J/kg` (theorem-form in
    `EnergyCage.lean`) can source at most
    `Δν = (E/Φ_N)·g/(C_geom·A) ∈ (1.02, 1.03)×10⁻¹¹` — i.e. **slightly
    more** than the ledger's printed "≲ 1×10⁻¹¹". The honest ceiling is
    `1.03×10⁻¹¹` (`0.578` gf), and the coupon-discrimination rule should
    quote it. -/
theorem battery_coupon_bounds {Φ : ℝ} (hΦl : 6.24e7 < Φ) (hΦu : Φ < 6.26e7) :
    1.02e-11 < 3.6e4 / Φ * 9.80665 /
      (9.80665 ^ 2 / (4 * π * 6.67430e-11) * 4.8e-3) ∧
    3.6e4 / Φ * 9.80665 /
      (9.80665 ^ 2 / (4 * π * 6.67430e-11) * 4.8e-3) < 1.03e-11 := by
  have hΦpos : (0 : ℝ) < Φ := by nlinarith
  have hF : 5.639e-3 < 3.6e4 / Φ * 9.80665 ∧
      3.6e4 / Φ * 9.80665 < 5.658e-3 := by
    have hq : 3.6e4 / Φ < 3.6e4 / 6.24e7 :=
      div_lt_div_of_pos_left (by norm_num) (by norm_num) hΦl
    have hq' : 3.6e4 / 6.26e7 < 3.6e4 / Φ :=
      div_lt_div_of_pos_left (by norm_num) hΦpos hΦu
    constructor <;> nlinarith
  obtain ⟨hFl, hFu⟩ := hF
  obtain ⟨hCl, hCu⟩ := CgeomA_bounds
  have hCpos : (0 : ℝ) < 9.80665 ^ 2 / (4 * π * 6.67430e-11) * 4.8e-3 := by
    nlinarith
  constructor
  · rw [lt_div_iff₀ hCpos]
    nlinarith
  · rw [div_lt_iff₀ hCpos]
    nlinarith

/-! ### Axiom audit -/
#print axioms Cgeom_bounds
#print axioms CgeomA_bounds
#print axioms dnu_min_bounds
#print axioms design_force_bounds
#print axioms design_gf_bounds
#print axioms design_snr_bounds
#print axioms lockin_stat_exact
#print axioms battery_coupon_bounds

end OPHProofChain.LedgerNumerics