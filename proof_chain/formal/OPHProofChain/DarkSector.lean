import Mathlib

/-!
# The dark-sector activation law and phantom density (L2.8 + L2.7 mathematics)

Formalizes the *mathematical* content of the OPH dark-sector papers:

* `observer-patch-holography/cosmology/oph_dark_matter_paper.tex` —
  Poisson activation, lines 681–751 ("Conditional theorem 2, activation
  law", lines 739–751); Newtonian and deep-MOND limits, lines 798–833
  (BTFR theorem, lines 826–833); effective dark density, lines 835–899
  (point-source `M_A`/`ρ_A`, lines 854–868; positivity, lines 870–878).
* `observer-patch-holography/extra/chi_nu_susceptibility_bounds.tex` —
  the `ρ_A` divergence identity, lines 353–362; the planar force law,
  lines 1311–1345.

## What is proven (machine-checked mathematics)

With `activation lam x = 1 − e^(−λ√x)` (the paper's `p(x)`, eq:activation)
and `nuOPH lam x = (activation lam x)⁻¹` (eq:ophrar):

* `activation_pos`, `activation_lt_one`, `one_lt_nuOPH` — well-definedness:
  `0 < p(x) < 1` and `ν_OPH(x) > 1` for `λ, x > 0`.
* `nuOPH_antitone` — `ν_OPH` is strictly decreasing on `(0, ∞)`.
* `flux_closure_inversion` — the one-line algebra taking the flux-recovery
  closure `g_b = p(x)·g_obs` (eq:fluxrecovery) to `g_obs = ν_OPH(x)·g_b`
  (eq:ophrar).
* `nuOPH_tendsto_one` — Newtonian limit: `ν_OPH(x) → 1` as `x → ∞`.
* `deepMOND_limit` — deep-MOND limit: `p(x)/(λ√x) → 1` as `x → 0⁺`
  (the paper's `p(x) = λ√x + O(x)`).
* `deepMOND_gobs` — the physics-shaped corollary: with `g_obs = ν_OPH·(a₀x)`
  and `a_eff = a₀/λ²`, the ratio `g_obs/√(a_eff·(a₀x)) → 1` as `x → 0⁺` —
  the exact `g_obs ≃ √(a_eff·g_b)` scaling.
* `btfr` — the baryonic Tully–Fisher identity (paper Theorem 3): from
  `g = √(a_eff·GM/r²)` and `v² = g·r` follows `v⁴ = GM·a_eff`.
* `rare_event_zero_count` — the rare-events exponential
  `(1 − μ/m)^m → e^(−μ)`, the paper's `Pr[N=0] = e^(−μ)` zero-count limit
  (the analysis step inside eq:poissonlaw).
* `phantom_bookkeeping` — the phantom-density identity (chi_nu tex 353–362,
  dark paper eq:rhoaeq), stated over an arbitrary linear "divergence"
  operator: if `div g_b = −4πG·ρ_b`, then
  `div (g_b + g_A) = −4πG·(ρ_b + ρ_A)` with
  `ρ_A := −(4πG)⁻¹·div g_A` — an *identity* with zero physical content,
  which is exactly what proof-chain link L2.7 claims. Reading: with
  `g_A := (ν_OPH − 1)·g_b` this is `∇·g = −4πG(ρ_b + ρ_A)`.
* `MA_pos`, `MA_strictMonoOn` — the point-source phantom mass profile
  `M_A(r) = M_b/(e^(λ r_M/r) − 1)` is positive and strictly increasing on
  `(0, ∞)`.
* `hasDerivAt_MA` — **the density identity**: `M_A′(r) = 4πr²·ρ_A(r)` with
  the paper's displayed
  `ρ_A(r) = M_b·λ·r_M·e^(λ r_M/r) / (4πr⁴(e^(λ r_M/r) − 1)²)` —
  machine-checking that the printed `ρ_A` is exactly the shell-mass
  bookkeeping `(4πr²)⁻¹·dM_A/dr` (lines 854–868).
* `rhoA_pos` — shell positivity of the point-source phantom density (the
  positivity criterion of lines 870–878 holds for the point source).
* `thin_device_force` — the L2.11 derivation step (chi_nu tex 1311–1345):
  integrating the lab-anomaly density `ρ_lab(z) = (gχ/(4πG))·∂_z S` through
  a thin column of area `A` gives the Planar Response Law
  `F_χ = g²/(4πG)·A·χ·ΔS` — the fundamental-theorem-of-calculus step,
  with the response law itself entering only as the shape of the integrand.

## What is NOT proven (the named physics premises)

Nothing here derives the activation law from consensus dynamics. The
paper's "Conditional theorem 2" hypotheses remain **named inputs**:

1. **Codimension-one collar support** — the mean repair-opportunity count
   `μ(x) = λ_c·√x` (dark paper, lines 683–686). Here `√x` enters by
   definition of `activation`.
2. **Independent increments, rare local repair events, refinement
   stability** — the Poisson counting premises (lines 687–705). Only the
   downstream analysis fact (`rare_event_zero_count`) is machine-checked;
   the probabilistic modelling assumptions are not.
3. **Flux-recovery closure** — `g_b = p(x)·g_obs` (eq:fluxrecovery,
   lines 725–730). It enters `flux_closure_inversion` as a hypothesis.
4. **The lab response law** — `ρ_A^lab = (gχ/(4πG))·∂_z S` (chi_nu tex
   eq:rho-lab, used at lines 1331–1336). It enters `thin_device_force` as
   the declared integrand; the theorem is the FTC step after it.

The value of the collar coupling `λ_collar = e^(−P/24)` is
`CollarGate.lean`/`PBranches.lean` territory, not this module's.

Axioms: standard; no `sorry`, no `native_decide`.
-/

namespace OPHProofChain.DarkSector

/-! ### Section 1 — the activation law `ν(x) = 1/(1 − e^(−λ√x))`  [L2.8] -/

/-- The paper's activation probability `p(x) = 1 − e^(−λ√x)` (eq:activation):
    the probability that at least one repair opportunity is active, given the
    Poisson premises. -/
noncomputable def activation (lam x : ℝ) : ℝ := 1 - Real.exp (-(lam * Real.sqrt x))

/-- The OPH interpolation function `ν_OPH(x) = 1/(1 − e^(−λ√x))` (eq:ophrar). -/
noncomputable def nuOPH (lam x : ℝ) : ℝ := (activation lam x)⁻¹

/-- `0 < p(x)` for `λ, x > 0`: the activation probability is positive. -/
theorem activation_pos {lam x : ℝ} (hlam : 0 < lam) (hx : 0 < x) :
    0 < activation lam x := by
  unfold activation
  have hpos : 0 < lam * Real.sqrt x := mul_pos hlam (Real.sqrt_pos.mpr hx)
  have h : Real.exp (-(lam * Real.sqrt x)) < 1 :=
    Real.exp_lt_one_iff.mpr (by linarith)
  linarith

/-- `p(x) < 1` always: the activation is a genuine probability deficit
    (`e^(−λ√x) > 0`). -/
theorem activation_lt_one (lam x : ℝ) : activation lam x < 1 := by
  unfold activation
  have h := Real.exp_pos (-(lam * Real.sqrt x))
  linarith

/-- `ν_OPH(x) > 1` for `λ, x > 0`: the observed acceleration always exceeds
    the baryonic one. -/
theorem one_lt_nuOPH {lam x : ℝ} (hlam : 0 < lam) (hx : 0 < x) :
    1 < nuOPH lam x := by
  unfold nuOPH
  exact one_lt_inv_iff₀.mpr ⟨activation_pos hlam hx, activation_lt_one lam x⟩

/-- The activation probability is strictly increasing on `(0, ∞)`. -/
theorem activation_strictMonoOn {lam : ℝ} (hlam : 0 < lam) :
    StrictMonoOn (activation lam) (Set.Ioi 0) := by
  intro x hx y _hy hxy
  unfold activation
  have hx0 : (0:ℝ) < x := hx
  have hs : Real.sqrt x < Real.sqrt y := Real.sqrt_lt_sqrt hx0.le hxy
  have h1 : lam * Real.sqrt x < lam * Real.sqrt y :=
    mul_lt_mul_of_pos_left hs hlam
  have h2 : Real.exp (-(lam * Real.sqrt y)) < Real.exp (-(lam * Real.sqrt x)) :=
    Real.exp_lt_exp.mpr (by linarith)
  linarith

/-- `ν_OPH` is strictly decreasing on `(0, ∞)`: more Newtonian at higher
    accelerations, more anomalous at lower ones. -/
theorem nuOPH_antitone {lam : ℝ} (hlam : 0 < lam) :
    StrictAntiOn (nuOPH lam) (Set.Ioi 0) := by
  intro x hx y hy hxy
  unfold nuOPH
  exact (inv_lt_inv₀ (activation_pos hlam (Set.mem_Ioi.mp hy))
    (activation_pos hlam (Set.mem_Ioi.mp hx))).mpr
    (activation_strictMonoOn hlam hx hy hxy)

/-- **Flux-closure inversion** (eq:fluxrecovery → eq:ophrar). If the settled
    scalar closure `g_b = p(x)·g_obs` holds and `p(x) ≠ 0`, then
    `g_obs = ν_OPH(x)·g_b`. This is the entire algebraic content of the step
    from the counting law to the galaxy response law. -/
theorem flux_closure_inversion {lam x : ℝ} (gb gobs : ℝ)
    (hne : activation lam x ≠ 0) (h : gb = activation lam x * gobs) :
    gobs = nuOPH lam x * gb := by
  subst h
  unfold nuOPH
  rw [← mul_assoc, inv_mul_cancel₀ hne, one_mul]

/-- **Newtonian limit** (paper lines 798–803): `ν_OPH(x) → 1` as `x → ∞`,
    so `g_obs → g_b`. -/
theorem nuOPH_tendsto_one {lam : ℝ} (hlam : 0 < lam) :
    Filter.Tendsto (nuOPH lam) Filter.atTop (nhds 1) := by
  have h1 : Filter.Tendsto (fun x : ℝ => lam * Real.sqrt x)
      Filter.atTop Filter.atTop :=
    Real.tendsto_sqrt_atTop.const_mul_atTop hlam
  have h2 : Filter.Tendsto (fun x : ℝ => -(lam * Real.sqrt x))
      Filter.atTop Filter.atBot :=
    Filter.tendsto_neg_atTop_atBot.comp h1
  have h3 : Filter.Tendsto (fun x : ℝ => Real.exp (-(lam * Real.sqrt x)))
      Filter.atTop (nhds 0) :=
    Real.tendsto_exp_atBot.comp h2
  have h4 : Filter.Tendsto (activation lam) Filter.atTop (nhds 1) := by
    have h5 : Filter.Tendsto (fun x : ℝ => 1 - Real.exp (-(lam * Real.sqrt x)))
        Filter.atTop (nhds (1 - 0)) :=
      Filter.Tendsto.sub tendsto_const_nhds h3
    rw [sub_zero] at h5
    exact h5
  have h6 := h4.inv₀ one_ne_zero
  rw [inv_one] at h6
  exact h6

/-- The one-variable deep-MOND kernel: `(1 − e^(−t))/t → 1` as `t → 0⁺`.
    Proven by a squeeze: for `t > 0`, `(1 + t)⁻¹ ≤ (1 − e^(−t))/t ≤ 1`
    (both bounds from `t + 1 ≤ e^t`). -/
theorem one_sub_exp_neg_div_tendsto :
    Filter.Tendsto (fun t : ℝ => (1 - Real.exp (-t)) / t)
      (nhdsWithin 0 (Set.Ioi 0)) (nhds 1) := by
  have hlow : ∀ᶠ t in nhdsWithin (0:ℝ) (Set.Ioi 0),
      (1 + t)⁻¹ ≤ (1 - Real.exp (-t)) / t := by
    filter_upwards [eventually_mem_nhdsWithin] with t ht
    have ht0 : (0:ℝ) < t := ht
    have h1t : (0:ℝ) < 1 + t := by linarith
    have h1t' : (1:ℝ) + t ≠ 0 := ne_of_gt h1t
    have hexp : Real.exp (-t) ≤ (1 + t)⁻¹ := by
      rw [Real.exp_neg]
      exact inv_anti₀ h1t (by linarith [Real.add_one_le_exp t])
    rw [le_div_iff₀ ht0]
    have hkey : (1 + t)⁻¹ * t = 1 - (1 + t)⁻¹ := by
      rw [inv_mul_eq_div, div_eq_iff h1t', sub_mul, one_mul,
        inv_mul_cancel₀ h1t']
      ring
    linarith
  have hupp : ∀ᶠ t in nhdsWithin (0:ℝ) (Set.Ioi 0),
      (1 - Real.exp (-t)) / t ≤ 1 := by
    filter_upwards [eventually_mem_nhdsWithin] with t ht
    have ht0 : (0:ℝ) < t := ht
    rw [div_le_one ht0]
    linarith [Real.add_one_le_exp (-t)]
  have hlowlim : Filter.Tendsto (fun t : ℝ => (1 + t)⁻¹)
      (nhdsWithin 0 (Set.Ioi 0)) (nhds 1) := by
    have hcont : Continuous (fun t : ℝ => 1 + t) := continuous_const.add continuous_id
    have hc : Filter.Tendsto (fun t : ℝ => 1 + t) (nhds 0) (nhds 1) := by
      have := hcont.tendsto (0:ℝ)
      simpa using this
    have hc2 : Filter.Tendsto (fun t : ℝ => (1 + t)⁻¹) (nhds 0) (nhds 1) := by
      have h := hc.inv₀ one_ne_zero
      rwa [inv_one] at h
    exact hc2.mono_left nhdsWithin_le_nhds
  exact tendsto_of_tendsto_of_tendsto_of_le_of_le' hlowlim tendsto_const_nhds hlow hupp

/-- **Deep-MOND limit** (paper lines 804–818): `p(x)/(λ√x) → 1` as
    `x → 0⁺` — the activation probability is `λ√x + O(x)` in the deep-IR
    regime. -/
theorem deepMOND_limit {lam : ℝ} (hlam : 0 < lam) :
    Filter.Tendsto (fun x : ℝ => activation lam x / (lam * Real.sqrt x))
      (nhdsWithin 0 (Set.Ioi 0)) (nhds 1) := by
  have hmap : Filter.Tendsto (fun x : ℝ => lam * Real.sqrt x)
      (nhdsWithin 0 (Set.Ioi 0)) (nhdsWithin 0 (Set.Ioi 0)) := by
    rw [tendsto_nhdsWithin_iff]
    constructor
    · have hsq : Filter.Tendsto (fun x : ℝ => Real.sqrt x) (nhds 0) (nhds 0) := by
        have := Real.continuous_sqrt.tendsto (0:ℝ)
        simpa using this
      have hmul : Filter.Tendsto (fun x : ℝ => lam * Real.sqrt x)
          (nhds 0) (nhds (lam * 0)) := hsq.const_mul lam
      rw [mul_zero] at hmul
      exact hmul.mono_left nhdsWithin_le_nhds
    · filter_upwards [eventually_mem_nhdsWithin] with x hx
      exact mul_pos hlam (Real.sqrt_pos.mpr hx)
  exact one_sub_exp_neg_div_tendsto.comp hmap

/-- Pointwise algebra behind `deepMOND_gobs`: for `λ, a₀, x > 0`, the
    physics-shaped ratio `g_obs/√(a_eff·g_b)` (with `g_b = a₀x`,
    `a_eff = a₀/λ²`) equals the inverse of the deep-MOND kernel ratio. -/
private lemma gobs_ratio_eq {lam a0 x : ℝ} (hlam : 0 < lam) (ha0 : 0 < a0)
    (hx : 0 < x) :
    nuOPH lam x * (a0 * x) / Real.sqrt (a0 / lam ^ 2 * (a0 * x))
      = (activation lam x / (lam * Real.sqrt x))⁻¹ := by
  obtain ⟨s, hs0, rfl⟩ : ∃ s : ℝ, 0 < s ∧ s ^ 2 = x :=
    ⟨Real.sqrt x, Real.sqrt_pos.mpr hx, Real.sq_sqrt hx.le⟩
  have hA : 0 < activation lam (s ^ 2) := activation_pos hlam (pow_pos hs0 2)
  have hAne : activation lam (s ^ 2) ≠ 0 := ne_of_gt hA
  have hsne : s ≠ 0 := ne_of_gt hs0
  have hlamne : lam ≠ 0 := ne_of_gt hlam
  have ha0ne : a0 ≠ 0 := ne_of_gt ha0
  have hsq2 : Real.sqrt (s ^ 2) = s := Real.sqrt_sq hs0.le
  have hsqa : Real.sqrt (a0 / lam ^ 2 * (a0 * s ^ 2)) = a0 / lam * s := by
    have hform : a0 / lam ^ 2 * (a0 * s ^ 2) = (a0 / lam * s) ^ 2 := by ring
    have hnn : 0 ≤ a0 / lam * s := le_of_lt (mul_pos (div_pos ha0 hlam) hs0)
    rw [hform, Real.sqrt_sq hnn]
  rw [hsq2, hsqa, inv_div]
  unfold nuOPH
  field_simp

/-- **Deep-MOND acceleration scaling** (paper lines 804–818): with
    `g_obs(x) = ν_OPH(x)·(a₀x)` (i.e. `g_b = a₀x`) and `a_eff = a₀/λ²`,
    the ratio `g_obs/√(a_eff·(a₀x)) → 1` as `x → 0⁺`. This is the exact
    `g_obs ≃ √(a_eff·g_b)` statement of the paper. -/
theorem deepMOND_gobs {lam a0 : ℝ} (hlam : 0 < lam) (ha0 : 0 < a0) :
    Filter.Tendsto
      (fun x : ℝ => nuOPH lam x * (a0 * x) / Real.sqrt (a0 / lam ^ 2 * (a0 * x)))
      (nhdsWithin 0 (Set.Ioi 0)) (nhds 1) := by
  have hbase : Filter.Tendsto
      (fun x : ℝ => (activation lam x / (lam * Real.sqrt x))⁻¹)
      (nhdsWithin 0 (Set.Ioi 0)) (nhds 1) := by
    have h := (deepMOND_limit hlam).inv₀ one_ne_zero
    rwa [inv_one] at h
  refine Filter.Tendsto.congr' ?_ hbase
  filter_upwards [eventually_mem_nhdsWithin] with x hx
  exact (gobs_ratio_eq hlam ha0 hx).symm

/-- **BTFR identity** (paper Theorem 3, lines 826–833). For a circular orbit
    in the deep-IR regime: from `g = √(a_eff·GM/r²)` and `v² = g·r` follows
    the baryonic Tully–Fisher scaling `v⁴ = GM·a_eff`. Pure algebra. -/
theorem btfr {aeff G M r g v : ℝ} (haeff : 0 ≤ aeff) (hGM : 0 ≤ G * M)
    (hr : 0 < r) (hg : g = Real.sqrt (aeff * (G * M / r ^ 2)))
    (hv : v ^ 2 = g * r) :
    v ^ 4 = G * M * aeff := by
  have hx : 0 ≤ aeff * (G * M / r ^ 2) :=
    mul_nonneg haeff (div_nonneg hGM (le_of_lt (pow_pos hr 2)))
  have hg2 : g ^ 2 = aeff * (G * M / r ^ 2) := by rw [hg]; exact Real.sq_sqrt hx
  have hrne : r ≠ 0 := ne_of_gt hr
  have hv4 : v ^ 4 = g ^ 2 * r ^ 2 := by
    calc v ^ 4 = (v ^ 2) ^ 2 := by ring
    _ = (g * r) ^ 2 := by rw [hv]
    _ = g ^ 2 * r ^ 2 := by ring
  rw [hv4, hg2, mul_assoc, div_mul_cancel₀ _ (pow_ne_zero 2 hrne)]
  ring

/-- **Rare-event zero count** (paper lines 708–713): the Poisson zero-count
    limit `(1 − μ/m)^m → e^(−μ)` as the refinement `m → ∞`. This is the
    analysis fact inside eq:poissonlaw; the *premises* that make `μ` the
    right mean (codimension-one support, independent increments, rare
    events) are the named physics inputs, not proven here. -/
theorem rare_event_zero_count (μ : ℝ) :
    Filter.Tendsto (fun m : ℕ => (1 - μ / m) ^ m) Filter.atTop
      (nhds (Real.exp (-μ))) := by
  have h := Real.tendsto_one_add_div_pow_exp (-μ)
  have heq : (fun m : ℕ => (1 - μ / m) ^ m)
      = fun m : ℕ => (1 + -μ / m) ^ m := by
    funext m
    rw [neg_div, ← sub_eq_add_neg]
  rw [heq]
  exact h

/-! ### Section 2 — phantom density bookkeeping  [L2.7] -/

/-- **The phantom-density identity is bookkeeping** (chi_nu tex 353–362,
    dark paper eq:rhoaeq). Over ANY linear divergence operator: if the
    baryonic field solves `div g_b = −4πG·ρ_b`, then the total field
    `g_b + g_A` solves `div (g_b + g_A) = −4πG·(ρ_b + ρ_A)` where
    `ρ_A := −(4πG)⁻¹·div g_A` — by definition of `ρ_A`. With
    `g_A := (ν_OPH − 1) • g_b` this IS the paper's
    `∇·g = −4πG(ρ_b + ρ_A)`: an identity, zero physical content, which is
    exactly what proof-chain link L2.7 claims. -/
theorem phantom_bookkeeping {V W : Type*} [AddCommGroup V] [Module ℝ V]
    [AddCommGroup W] [Module ℝ W]
    (div : V →ₗ[ℝ] W) (G : ℝ) (hG : G ≠ 0) (gb gA : V) (ρb : W)
    (hb : div gb = (-(4 * Real.pi * G)) • ρb) :
    div (gb + gA)
      = (-(4 * Real.pi * G)) • (ρb + (-(4 * Real.pi * G))⁻¹ • div gA) := by
  have hc : (-(4 * Real.pi * G)) ≠ 0 :=
    neg_ne_zero.mpr (mul_ne_zero (mul_ne_zero (by norm_num) Real.pi_ne_zero) hG)
  rw [map_add, hb, smul_add, smul_smul, mul_inv_cancel₀ hc, one_smul]

/-! ### The point-source phantom profile (dark paper lines 854–868) -/

/-- The exact equilibrium phantom mass inside radius `r` for a point
    baryonic source `M_b`: `M_A(r) = M_b/(e^(λ r_M/r) − 1)`. -/
noncomputable def MA (Mb lam rM r : ℝ) : ℝ := Mb / (Real.exp (lam * rM / r) - 1)

/-- The paper's displayed point-source phantom density
    `ρ_A(r) = M_b·λ·r_M·e^(λ r_M/r) / (4πr⁴(e^(λ r_M/r) − 1)²)`. -/
noncomputable def rhoA (Mb lam rM r : ℝ) : ℝ :=
  Mb * lam * rM * Real.exp (lam * rM / r) /
    (4 * Real.pi * r ^ 4 * (Real.exp (lam * rM / r) - 1) ^ 2)

private lemma one_lt_exp_ratio {lam rM r : ℝ} (hlam : 0 < lam) (hrM : 0 < rM)
    (hr : 0 < r) : 1 < Real.exp (lam * rM / r) :=
  Real.one_lt_exp_iff.mpr (div_pos (mul_pos hlam hrM) hr)

/-- The point-source phantom mass is positive. -/
theorem MA_pos {Mb lam rM r : ℝ} (hMb : 0 < Mb) (hlam : 0 < lam)
    (hrM : 0 < rM) (hr : 0 < r) : 0 < MA Mb lam rM r := by
  unfold MA
  have h := one_lt_exp_ratio hlam hrM hr
  exact div_pos hMb (by linarith)

/-- The point-source phantom mass profile is strictly increasing on
    `(0, ∞)` — the monotonicity form of the paper's positivity criterion
    (lines 870–878), here established directly. -/
theorem MA_strictMonoOn {Mb lam rM : ℝ} (hMb : 0 < Mb) (hlam : 0 < lam)
    (hrM : 0 < rM) : StrictMonoOn (MA Mb lam rM) (Set.Ioi 0) := by
  intro r₁ hr₁ r₂ hr₂ h12
  unfold MA
  have hr₁0 : (0:ℝ) < r₁ := hr₁
  have hr₂0 : (0:ℝ) < r₂ := hr₂
  have harg : lam * rM / r₂ < lam * rM / r₁ :=
    div_lt_div_of_pos_left (mul_pos hlam hrM) hr₁0 h12
  have hexp : Real.exp (lam * rM / r₂) < Real.exp (lam * rM / r₁) :=
    Real.exp_lt_exp.mpr harg
  have h₂ := one_lt_exp_ratio hlam hrM hr₂0
  exact div_lt_div_of_pos_left hMb (by linarith) (by linarith)

/-- **The density identity** (lines 854–868, machine-checked): the paper's
    displayed `ρ_A(r)` is exactly the shell-mass bookkeeping
    `M_A′(r) = 4πr²·ρ_A(r)`. Note `M_b` is arbitrary here — the identity is
    pure calculus. -/
theorem hasDerivAt_MA {Mb lam rM r : ℝ} (hlam : 0 < lam) (hrM : 0 < rM)
    (hr : 0 < r) :
    HasDerivAt (MA Mb lam rM) (4 * Real.pi * r ^ 2 * rhoA Mb lam rM r) r := by
  have hrne : r ≠ 0 := ne_of_gt hr
  have hE1 : 1 < Real.exp (lam * rM / r) := one_lt_exp_ratio hlam hrM hr
  have hEne : Real.exp (lam * rM / r) - 1 ≠ 0 := by
    intro hcontra
    linarith [hcontra]
  have hπ : Real.pi ≠ 0 := Real.pi_ne_zero
  have hu : HasDerivAt (fun s : ℝ => lam * rM / s)
      (lam * rM * (-(r ^ 2)⁻¹)) r := by
    have h := (hasDerivAt_inv hrne).const_mul (lam * rM)
    simpa [div_eq_mul_inv] using h
  have hE : HasDerivAt (fun s : ℝ => Real.exp (lam * rM / s))
      (Real.exp (lam * rM / r) * (lam * rM * (-(r ^ 2)⁻¹))) r := hu.exp
  have hden : HasDerivAt (fun s : ℝ => Real.exp (lam * rM / s) - 1)
      (Real.exp (lam * rM / r) * (lam * rM * (-(r ^ 2)⁻¹))) r :=
    (hasDerivAt_sub_const_iff 1).mpr hE
  have hq : HasDerivAt (fun s : ℝ => Mb / (Real.exp (lam * rM / s) - 1))
      ((0 * (Real.exp (lam * rM / r) - 1) -
          Mb * (Real.exp (lam * rM / r) * (lam * rM * (-(r ^ 2)⁻¹)))) /
        (Real.exp (lam * rM / r) - 1) ^ 2) r :=
    (hasDerivAt_const r Mb).div hden hEne
  have hfun : MA Mb lam rM = fun s : ℝ => Mb / (Real.exp (lam * rM / s) - 1) := rfl
  rw [hfun]
  convert hq using 1
  unfold rhoA
  field_simp
  ring

/-- **Shell positivity** of the point-source phantom density (the paper's
    positivity criterion, lines 870–878, for the point source): `ρ_A(r) > 0`
    on `(0, ∞)`. Together with `hasDerivAt_MA` this is
    `d/dr M_A(r) = 4πr²·ρ_A(r) > 0`. -/
theorem rhoA_pos {Mb lam rM r : ℝ} (hMb : 0 < Mb) (hlam : 0 < lam)
    (hrM : 0 < rM) (hr : 0 < r) : 0 < rhoA Mb lam rM r := by
  unfold rhoA
  have hE1 : 1 < Real.exp (lam * rM / r) := one_lt_exp_ratio hlam hrM hr
  have hnum : 0 < Mb * lam * rM * Real.exp (lam * rM / r) :=
    mul_pos (mul_pos (mul_pos hMb hlam) hrM) (Real.exp_pos _)
  have hden : 0 < 4 * Real.pi * r ^ 4 * (Real.exp (lam * rM / r) - 1) ^ 2 :=
    mul_pos (mul_pos (mul_pos (by norm_num) Real.pi_pos) (pow_pos hr 4))
      (pow_pos (by linarith) 2)
  exact div_pos hnum hden

/-! ### The thin-device force law (chi_nu tex 1311–1345)  [L2.11 derivation step] -/

set_option linter.unusedVariables false in
/-- **Planar Response Law, FTC step** (chi_nu tex, Theorem "Planar response
    law", lines 1311–1345). The integrand `ρ_lab(z)·g·A` with
    `ρ_lab = (gχ/(4πG))·∂_z S` is the paper's lab anomaly law — the NAMED
    response input. Given it, integrating through the thin column of height
    `h` and area `A` yields `F_χ = g²/(4πG)·A·χ·ΔS` with `ΔS = S(h) − S(0)`
    — exactly the fundamental theorem of calculus. This moves L2.11's
    *derivation* content into Lean; the response law itself remains the
    declared physics input. (`hG` documents the premise `G ≠ 0`; the FTC
    identity itself holds for any `Gc`, hence the linter exemption.) -/
theorem thin_device_force (g χ Gc A h : ℝ) (S S' : ℝ → ℝ)
    (hG : Gc ≠ 0)
    (hS : ∀ z ∈ Set.uIcc (0:ℝ) h, HasDerivAt S (S' z) z)
    (hInt : IntervalIntegrable S' MeasureTheory.volume 0 h) :
    (∫ z in (0:ℝ)..h, (g * χ / (4 * Real.pi * Gc) * S' z) * g * A)
      = g ^ 2 / (4 * Real.pi * Gc) * A * χ * (S h - S 0) := by
  have hftc : (∫ z in (0:ℝ)..h, S' z) = S h - S 0 :=
    intervalIntegral.integral_eq_sub_of_hasDerivAt hS hInt
  have hpt : ∀ z : ℝ, (g * χ / (4 * Real.pi * Gc) * S' z) * g * A
      = g * χ / (4 * Real.pi * Gc) * g * A * S' z := fun z => by ring
  simp only [hpt]
  rw [intervalIntegral.integral_const_mul, hftc]
  ring

/-! ### Axiom audit -/
#print axioms activation_pos
#print axioms activation_lt_one
#print axioms one_lt_nuOPH
#print axioms nuOPH_antitone
#print axioms flux_closure_inversion
#print axioms nuOPH_tendsto_one
#print axioms one_sub_exp_neg_div_tendsto
#print axioms deepMOND_limit
#print axioms deepMOND_gobs
#print axioms btfr
#print axioms rare_event_zero_count
#print axioms phantom_bookkeeping
#print axioms MA_pos
#print axioms MA_strictMonoOn
#print axioms hasDerivAt_MA
#print axioms rhoA_pos
#print axioms thin_device_force

end OPHProofChain.DarkSector
