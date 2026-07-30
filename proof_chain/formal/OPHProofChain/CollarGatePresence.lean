import OPHProofChain.CollarGate

/-!
# The presence-reading collar coefficient (L5 occupancy-law correction)

Machine-checks the occupancy-law sensitivity of the collar survival
coefficient. Paper anchors:

* `observer-patch-holography/paper/screen_microphysics_and_observer_synchronization.tex`
  — Definition of the conditional reserve profile `ε_{ℤ₆,r}(y)` as a ratio
  of quotient traces of projections (lines 1102–1123), Definition
  *Protected Z₆ reserve projector* (lines 622–649: `Z₆` is a sum of sector
  projections, hence `τ_q(Z₆)` is the probability of the reserve-presence
  event), Assumption *Local Poisson reserve survival* (lines 1260–1271),
  Theorem *Scalar-channel exhaustion* (lines 699–740: the surviving channel
  is the summand `Π·(1−Z₆)`).

## The finding

The papers define `ε(y)` as a conditional trace of a projection — the
conditional probability of the reserve-presence event — and then consume
the same number as a Poisson **mean count** (Assumption L5). These are
different quantities. If the presence event is `Z₆` (forced by
*No separate scalar carrier*), survival is the complement event and the
per-slice survival factor is `1 − ε(y)` for **every** occupancy law; the
Poisson zero-count factor `e^(−ε(y))` is not attainable by any occupancy
variable whose presence event has probability `ε(y)`, because
`1 − ε < e^(−ε)` strictly for `ε > 0`.

Three theorem-grade consequences, proved below:

* `presence_gate` — under the presence reading, the scalar-weighted mean
  receipt `∑ w·ε = P/24` alone forces `λ_collar = 1 − P/24` **exactly**,
  by linearity. No uniformity clause (the papers' L7) is consumed: the
  Jensen gap of the exponential is an artifact of the Poisson choice.
* `presence_below_poisson_floor` — the presence-reading value lies
  **strictly below** `e^(−P/24)`, so the papers' claimed theorem-level
  band `[e^(−P/24), 1]` excludes the value implied by their own receipt
  semantics. The corrected exact value is
  `1 − P/24 = 0.9320429912748350…`, not `e^(−P/24) = 0.9343006394893864…`.
* `markov_band` — under the mean-count reading (which severs the link to
  the projection trace and needs a carrier beyond `Z₆`), Markov's
  inequality alone gives the assumption-minimal band
  `1 − P/24 ≤ λ ≤ 1` for **any** ℕ-valued occupancy. The papers'
  qualitative claim — the coefficient is order one and bounded away from
  zero — therefore survives with strictly weaker hypotheses than L5;
  only the 16-digit exact value is occupancy-law-dependent.

`presence_le_poisson` and `sub_one_lt_exp_neg` supply the pointwise
comparison; `finite_refinement_below_poisson` shows every finite
`m`-fold sub-slot refinement `(1 − ε/m)^m` also sits strictly below the
Poisson value, so `e^(−P/24)` is the supremum of the finite-carrier
family, attained by no finite regulator.

## Honest scope

Nothing here decides which reading nature uses; that is the same G9-class
physical obligation the papers name. What is machine-checked is that the
two readings are mutually exclusive at the stated precision, that the
receipt `Z6_NORMALIZED_TRACE_P_OVER_24` (a trace of a projection) carries
the presence semantics, and that the exact value licensed by that receipt
is `1 − P/24`.

No `sorry`, no new axioms, no `native_decide`.
-/

namespace OPHProofChain.CollarGatePresence

open scoped BigOperators
open OPHProofChain.CollarGate

/-- The presence-reading collar coefficient: per-slice survival is the
    complement of the reserve-presence probability,
    `λ_presence = ∑ y, w(y)·(1 − ε(y))`. This is the survival fraction
    forced by the scalar-channel-exhaustion split `Π = Π(1−Z₆) + Π·Z₆`
    together with the definition of `ε(y)` as a conditional trace of the
    projection `Z₆`. -/
def lambdaPresence (M : SliceModel) : ℝ :=
  ∑ y, M.w y * (1 - M.ε y)

/-- **The presence gate**: the scalar-weighted mean receipt alone —
    `∑ w·ε = P/24`, the papers' `SCALAR_WEIGHTED_Z6_MEAN` — forces
    `λ_presence = 1 − P/24` exactly. Linearity replaces both the Poisson
    clause (L5) and the uniformity clause (L7): under the presence reading
    the exact coefficient needs strictly fewer gate clauses than the
    papers' `UNIFORM_PRODUCT_THICKENING_EXACT` conjunction. -/
theorem presence_gate (M : SliceModel) (P : ℝ)
    (h_mean : ∑ y, M.w y * M.ε y = P / 24) :
    lambdaPresence M = 1 - P / 24 := by
  unfold lambdaPresence
  have h : ∀ y ∈ Finset.univ, M.w y * (1 - M.ε y)
      = M.w y - M.w y * M.ε y := by
    intro y _
    ring
  rw [Finset.sum_congr rfl h, Finset.sum_sub_distrib, M.w_sum_one, h_mean]

/-- Pointwise strict comparison: `1 − x < e^(−x)` for `x > 0`. The
    Poisson zero-count factor strictly exceeds the presence-reading
    survival factor at every slice with nonzero reserve. -/
theorem sub_one_lt_exp_neg {x : ℝ} (hx : x ≠ 0) :
    1 - x < Real.exp (-x) := by
  have h := Real.add_one_lt_exp (x := -x) (by simpa using hx)
  linarith

/-- The presence-reading coefficient never exceeds the Poisson-reading
    coefficient: `λ_presence ≤ λ_collar`, slice by slice. -/
theorem presence_le_poisson (M : SliceModel) :
    lambdaPresence M ≤ lambdaCollar M := by
  unfold lambdaPresence lambdaCollar
  refine Finset.sum_le_sum (fun y _ => ?_)
  have hexp : 1 - M.ε y ≤ Real.exp (-(M.ε y)) := by
    have h := Real.add_one_le_exp (-(M.ε y))
    linarith
  exact mul_le_mul_of_nonneg_left hexp (M.w_nonneg y)

/-- **The corrected exact value sits strictly below the papers' claimed
    band floor**: for `P > 0`, under the presence reading and the mean
    receipt, `λ_presence = 1 − P/24 < e^(−P/24)`. The papers' theorem-level
    band `[e^(−P/24), 1]` therefore excludes the value implied by their own
    projection-trace receipt. -/
theorem presence_below_poisson_floor (M : SliceModel) (P : ℝ)
    (hP : 0 < P) (h_mean : ∑ y, M.w y * M.ε y = P / 24) :
    lambdaPresence M < Real.exp (-(P / 24)) := by
  rw [presence_gate M P h_mean]
  exact sub_one_lt_exp_neg (by positivity)

/-- **The assumption-minimal Markov band**: for any per-slice survival
    profile `s` obeying only `1 − ε(y) ≤ s(y) ≤ 1` — which Markov's
    inequality grants to any ℕ-valued occupancy with mean `ε(y)`, and which
    the presence reading grants with equality on the left — the mean
    receipt pins the aggregate coefficient into `[1 − P/24, 1]`. The
    papers' qualitative claim (the coefficient is order one and nonzero)
    holds with no Poisson clause at all; only the exact value moves. -/
theorem markov_band (M : SliceModel) (P : ℝ) (s : M.ι → ℝ)
    (h_lb : ∀ y, 1 - M.ε y ≤ s y) (h_ub : ∀ y, s y ≤ 1)
    (h_mean : ∑ y, M.w y * M.ε y = P / 24) :
    1 - P / 24 ≤ ∑ y, M.w y * s y ∧ ∑ y, M.w y * s y ≤ 1 := by
  have h1 : lambdaPresence M ≤ ∑ y, M.w y * s y := by
    unfold lambdaPresence
    exact Finset.sum_le_sum (fun y _ =>
      mul_le_mul_of_nonneg_left (h_lb y) (M.w_nonneg y))
  have h2 : ∑ y, M.w y * s y ≤ 1 := by
    rw [← M.w_sum_one]
    exact Finset.sum_le_sum (fun y _ =>
      mul_le_of_le_one_right (M.w_nonneg y) (h_ub y))
  exact ⟨presence_gate M P h_mean ▸ h1, h2⟩

/-- Every finite `m`-fold sub-slot refinement of a slice with reserve mean
    `ε > 0` — independent Bernoulli(`ε/m`) occupancy on each sub-slot,
    survival the all-empty event — has survival `(1 − ε/m)^m` strictly
    below the Poisson factor `e^(−ε)`. The Poisson value is the `m → ∞`
    supremum of the finite-carrier family and is attained by no finite
    regulator: a fixed-cutoff finite carrier cannot realize `e^(−P/24)`. -/
theorem finite_refinement_below_poisson {ε : ℝ} (hε : 0 < ε)
    {m : ℕ} (hm : 0 < m) (hbd : ε / m ≤ 1) :
    (1 - ε / m) ^ m < Real.exp (-ε) := by
  have hlt : 1 - ε / m < Real.exp (-(ε / m)) :=
    sub_one_lt_exp_neg (by positivity)
  have hnn : 0 ≤ 1 - ε / m := by linarith
  calc (1 - ε / m) ^ m
      < Real.exp (-(ε / m)) ^ m := by
        exact pow_lt_pow_left₀ hlt hnn (by omega)
    _ = Real.exp (-ε) := by
        rw [← Real.exp_nat_mul]
        congr 1
        field_simp
#print axioms OPHProofChain.CollarGatePresence.presence_gate
#print axioms OPHProofChain.CollarGatePresence.sub_one_lt_exp_neg
#print axioms OPHProofChain.CollarGatePresence.presence_le_poisson
#print axioms OPHProofChain.CollarGatePresence.presence_below_poisson_floor
#print axioms OPHProofChain.CollarGatePresence.markov_band
#print axioms OPHProofChain.CollarGatePresence.finite_refinement_below_poisson

end OPHProofChain.CollarGatePresence
