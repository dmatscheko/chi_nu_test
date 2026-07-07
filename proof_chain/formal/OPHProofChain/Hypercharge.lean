import Mathlib

/-!
# The hypercharge lattice from anomaly cancellation + Yukawa closure (L2.4, algebra half 1)

Machine-checks the *algebraic* content of the compact paper's
**Theorem [Hypercharge lattice on the realized matter package]**
(`observer-patch-holography/paper/recovering_relativity_and_standard_model_structure_from_observer_overlap_consistency_compact.tex:5628–5654`):
for gauge group `SU(N)×SU(2)×U(1)_Y`, one generation `(Q, u^c, d^c, L, e^c)`
and one Higgs doublet `H` with Yukawa terms `QHu^c`, `QH†d^c`, `LH†e^c`,
the **linear** anomaly conditions and Yukawa closure force the hypercharge
ratios

```
Y_L = −N·Y_Q,  Y_H = N·Y_Q,  Y_u = −(N+1)·Y_Q,  Y_d = (N−1)·Y_Q,  Y_e = 2N·Y_Q
```

and the two *nonlinear* consistency conditions then hold **identically**:

* the `[SU(N)]²U(1)` anomaly is already implied by Yukawa closure alone
  (`su3_anomaly_of_yukawa`), and
* the cubic `[U(1)]³` anomaly cancels as a polynomial identity in `(N, Y_Q)`
  once the ratios hold (`cubic_anomaly_auto`) — no extra condition on `Y_Q`.

Fixing the conventional normalization `Q = T₃ + Y` with `Q(ν_L) = 0`
(i.e. `Y_L = −1/2`) pins `Y_Q = 1/(2N)`, and `N = 3` yields the exact
Standard-Model lattice `(1/6, −2/3, 1/3, −1/2, 1, 1/2)` — uniqueness is
`hypercharges_unique`.

## Honest scope

This module proves *linear algebra over ℚ*. It does **not** select the
matter package `(Q,u^c,d^c,L,e^c,H)` itself, the number of colors `N = 3`,
or the Yukawa structure — in the OPH chain that selection is **MAR**
(the compact paper's Axiom `ax:mar`), which remains the named physical
hypothesis of link L2.4. Together with `CenterZ6.lean` (the ℤ₆ kernel
computation downstream of these hypercharges) this closes the
"real algebra" half of L2.4 by machine; the *selection* half stays physics.

Anomaly conventions (all left-handed Weyl fields): `[SU(2)]²U(1)`:
`N·Y_Q + Y_L = 0`; `[grav]²U(1)`: `N(2Y_Q + Y_u + Y_d) + 2Y_L + Y_e = 0`;
`[SU(N)]²U(1)`: `2Y_Q + Y_u + Y_d = 0`; `[U(1)]³`:
`N(2Y_Q³ + Y_u³ + Y_d³) + 2Y_L³ + Y_e³ = 0`. The Higgs is a scalar and
enters no fermionic anomaly, only the Yukawa closure.

No `sorry`, no new axioms, no `native_decide`.
-/

namespace OPHProofChain.Hypercharge

/-- One generation of hypercharges plus the Higgs, over `ℚ`
    (the lattice statement is exact, so we work in `ℚ`, not `ℝ`). -/
structure Assignment where
  /-- quark doublet `Q` -/
  YQ : ℚ
  /-- up-type singlet `u^c` -/
  Yu : ℚ
  /-- down-type singlet `d^c` -/
  Yd : ℚ
  /-- lepton doublet `L` -/
  YL : ℚ
  /-- charged-lepton singlet `e^c` -/
  Ye : ℚ
  /-- Higgs doublet `H` -/
  YH : ℚ

variable (N : ℚ) (a : Assignment)

/-- Yukawa closure: `Q H u^c`, `Q H† d^c`, `L H† e^c` are `U(1)_Y`-invariant. -/
def YukawaClosed : Prop :=
  a.YQ + a.YH + a.Yu = 0 ∧ a.YQ - a.YH + a.Yd = 0 ∧ a.YL - a.YH + a.Ye = 0

/-- `[SU(2)]²U(1)` anomaly cancellation: `N` colored quark doublets and one
    lepton doublet. -/
def SU2AnomalyFree : Prop := N * a.YQ + a.YL = 0

/-- Mixed gravitational–`U(1)` anomaly cancellation: the sum of all Weyl
    hypercharges vanishes. -/
def GravAnomalyFree : Prop :=
  N * (2 * a.YQ + a.Yu + a.Yd) + 2 * a.YL + a.Ye = 0

/-- `[SU(N)]²U(1)` anomaly cancellation. -/
def SU3AnomalyFree : Prop := 2 * a.YQ + a.Yu + a.Yd = 0

/-- `[U(1)]³` anomaly cancellation. -/
def CubicAnomalyFree : Prop :=
  N * (2 * a.YQ ^ 3 + a.Yu ^ 3 + a.Yd ^ 3) + 2 * a.YL ^ 3 + a.Ye ^ 3 = 0

/-- **The hypercharge-ratio theorem** (compact paper, Theorem
    `thm:hypercharge`, ratio half): Yukawa closure + the `[SU(2)]²U(1)` and
    gravitational anomalies force every hypercharge to be the stated multiple
    of `Y_Q`. Pure linear algebra — the solution space is the line spanned by
    the Standard-Model ray. -/
theorem hypercharge_ratios (hy : YukawaClosed a) (h2 : SU2AnomalyFree N a)
    (hg : GravAnomalyFree N a) :
    a.YL = -N * a.YQ ∧ a.YH = N * a.YQ ∧ a.Yu = -(N + 1) * a.YQ ∧
      a.Yd = (N - 1) * a.YQ ∧ a.Ye = 2 * N * a.YQ := by
  obtain ⟨h1, h2', h3⟩ := hy
  have hsu2 : N * a.YQ + a.YL = 0 := h2
  have hgrav : N * (2 * a.YQ + a.Yu + a.Yd) + 2 * a.YL + a.Ye = 0 := hg
  have hL : a.YL = -N * a.YQ := by linear_combination hsu2
  have hE : a.Ye = 2 * N * a.YQ := by
    linear_combination hgrav + (-N) * h1 + (-N) * h2' + (-2) * hL
  have hH : a.YH = N * a.YQ := by
    linear_combination (-1) * h3 + hL + hE
  refine ⟨hL, hH, ?_, ?_, hE⟩
  · linear_combination h1 + (-1) * hH
  · linear_combination h2' + hH

/-- The `[SU(N)]²U(1)` anomaly is **implied by Yukawa closure alone** — it
    is not an independent condition on the realized package. -/
theorem su3_anomaly_of_yukawa (hy : YukawaClosed a) : SU3AnomalyFree a := by
  obtain ⟨h1, h2', _⟩ := hy
  unfold SU3AnomalyFree
  linear_combination h1 + h2'

/-- **The cubic anomaly cancels identically** once the linear conditions
    hold: `N(2Y_Q³ + Y_u³ + Y_d³) + 2Y_L³ + Y_e³ = 0` is a polynomial
    identity in `(N, Y_Q)` on the solution ray — machine-checked `ring`
    algebra, no constraint on `Y_Q` (this is why the normalization has to
    come from `Q = T₃ + Y`, not from anomalies). -/
theorem cubic_anomaly_auto (hy : YukawaClosed a) (h2 : SU2AnomalyFree N a)
    (hg : GravAnomalyFree N a) : CubicAnomalyFree N a := by
  obtain ⟨hL, hH, hu, hd, hE⟩ := hypercharge_ratios N a hy h2 hg
  unfold CubicAnomalyFree
  rw [hL, hu, hd, hE]
  ring

/-- Electroweak normalization: `Q = T₃ + Y` with `Q(ν_L) = 0` reads
    `Y_L = −1/2`; with the ratio theorem this pins `Y_Q = 1/(2N)`. -/
theorem YQ_of_normalization (hN : N ≠ 0) (hL : a.YL = -N * a.YQ)
    (hnorm : a.YL = -(1 / 2)) : a.YQ = 1 / (2 * N) := by
  have h : -N * a.YQ = -(1 / 2) := hL ▸ hnorm
  field_simp
  linarith [h]

/-- The Standard-Model hypercharge assignment (`N = 3`). -/
def smAssignment : Assignment :=
  ⟨1 / 6, -(2 / 3), 1 / 3, -(1 / 2), 1, 1 / 2⟩

/-- The SM assignment satisfies every condition (linear and cubic). -/
theorem smAssignment_valid :
    YukawaClosed smAssignment ∧ SU2AnomalyFree 3 smAssignment ∧
      GravAnomalyFree 3 smAssignment ∧ SU3AnomalyFree smAssignment ∧
      CubicAnomalyFree 3 smAssignment := by
  refine ⟨⟨?_, ?_, ?_⟩, ?_, ?_, ?_, ?_⟩ <;> norm_num [smAssignment,
    SU2AnomalyFree, GravAnomalyFree, SU3AnomalyFree, CubicAnomalyFree]

/-- **Uniqueness** (compact paper, Theorem `thm:hypercharge`, `N = 3` half):
    at three colors, Yukawa closure + the two linear anomalies + the
    electroweak normalization determine the assignment **completely** — it is
    the Standard-Model lattice `(1/6, −2/3, 1/3, −1/2, 1, 1/2)`. -/
theorem hypercharges_unique (a : Assignment) (hy : YukawaClosed a)
    (h2 : SU2AnomalyFree 3 a) (hg : GravAnomalyFree 3 a)
    (hnorm : a.YL = -(1 / 2)) : a = smAssignment := by
  obtain ⟨hL, hH, hu, hd, hE⟩ := hypercharge_ratios 3 a hy h2 hg
  have hQ : a.YQ = 1 / 6 := by
    have := YQ_of_normalization 3 a (by norm_num) hL hnorm
    linarith [this]
  cases a
  simp only [smAssignment, Assignment.mk.injEq]
  simp only at hQ hL hH hu hd hE hnorm
  refine ⟨hQ, ?_, ?_, hnorm, ?_, ?_⟩ <;> rw [hQ] at hu hd hH hE <;> norm_num at hu hd hH hE <;>
    assumption

/-! ### Axiom audit -/
#print axioms hypercharge_ratios
#print axioms su3_anomaly_of_yukawa
#print axioms cubic_anomaly_auto
#print axioms YQ_of_normalization
#print axioms smAssignment_valid
#print axioms hypercharges_unique

end OPHProofChain.Hypercharge
