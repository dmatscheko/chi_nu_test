import Mathlib

/-!
# P5 / L2.12 — the ΔS bridge, definition side: the finite coherent-matter source generator

Port of the finite combinatorial core of
`observer-patch-holography/extra/chi_nu_susceptibility_bounds.tex`,
§"Finite Coherent-Matter Source Generator":

* Definition B.4 "Scalar-slot footprint" (lines 674–706),
* Definition B.5 "Unit-normalized coherent scalar source generator"
  (lines 713–734),
* Theorem B.7 "Coherent material perturbs the canonical scalar count"
  (lines 751–807),
* Corollary B.11 "Tier-B response law from the finite generator"
  (lines 911–943).

This is the proof-chain link the audit graded "definition side closed on
paper" with *no formal object yet* (`OPH_CORE_MINIMAL_PROOF_CHAIN.md`, row
L2.12 / item P5). This file **creates the formal object**: a finite
scalar-slot register (`SlotRegister`), the canonical opportunity count
`count` (the paper's `𝒩_{ν,r,C}`), the coherent source datum
`CoherentSource` (footprint `b`, strength `S`), the unit-normalized
generator `gen` (the paper's `𝓛^coh_{U,r,C}`), and the availability factor
`avail` (the paper's `A_{U,r,C}`) — and machine-checks:

* `count_activate` — the exact one-slot increment computation inside the
  proof of Theorem B.7 (lines 786–792): activating slot `e` changes the
  count by exactly `a_e·[1 − p_{e,ν}(q)]`;
* `gen_count` — Theorem B.7's displayed identity `𝓛^coh 𝒩_ν = S·A`;
* `gen_count_pos` — its strict-positivity clause (`S > 0`, `A > 0` ⇒ the
  perturbation is nonzero);
* `avail_pos_iff` — the non-saturation reading of Definition B.4's last
  line, as an exact iff;
* `response_form` — the Corollary B.11 shape `δν = (χ·S)·A`;
* `demoR`/`demoSrc`/`demo_gen_value`/`demo_gen_pos` — non-vacuity: a
  concrete two-slot register on which every hypothesis holds jointly and
  the generator genuinely fires.

## Honest scope

1. **Definition side only.** What is formalized is the finite generator,
   the footprint, and the exact increment identity — the mathematics the
   proof chain marks "closed on paper". Nothing more.
2. **`S` is a black box here.** The observer-side receipts that *define*
   the canonical coherent scalar `S_coh` — self-reading, durable
   re-readable records, prediction better than shuffled controls
   (Definition B.3, lines 653–672) — are the paper's named operational
   tests. They are physics, **not modeled** in this file; `S` enters only
   as a nonnegative real.
3. **Gap G9 stays OPEN.** The *numerical* record-ΔS → gravity-ΔS bridge is
   a physical calibration; no formal object can close it. A null
   experiment bounds only the product χ·ΔS — exactly the proof chain's
   L2.12 grading. Nothing in this file touches G9.
4. Cross-references: `ScalarResponse.lean` (the forced linear *form* of
   the response under SEE), `CollarGate.lean` (the conditional *value*
   gate `χ_can = e^{−P/24}`), `EnergyCage.lean` (what a `DETECT` must
   ledger before it may be believed).

Axioms: standard; no `sorry`.
-/

namespace OPHProofChain.DeltaSBridge

/-! ### The finite scalar-slot register (paper lines 634–642, 713–722) -/

/-- The imported edge-center scalar-slot register at fixed regulator `r`
    and collar `C` (chi_nu lines 634–642): a finite slot set `E` (the
    paper's `E_{ν,r}(C)`), the slot-activity indicator `active` (the
    paper's `p_{e,ν} : Q_r → {0,1}`), nonnegative per-slot opportunity
    weights `a` (the paper's `a_e`), and the normal-form activation map
    `activate` (the paper's `q ⊕ e := n_r(q with slot e activated)`,
    Definition B.5 lines 715–722) with its three defining laws: it
    activates `e`, it touches no other slot, and it fixes states where `e`
    is already active. -/
structure SlotRegister where
  /-- Quotient states (the paper's physical quotient `Q_r = Σ_r/Γ_r`). -/
  Q : Type
  /-- Scalar slots — the edge register `E_{ν,r}(C)`. -/
  E : Type
  [finE : Fintype E]
  [decE : DecidableEq E]
  /-- Slot-activity indicator: the paper's `p_{e,ν}(q) ∈ {0,1}`. -/
  active : Q → E → Bool
  /-- Per-slot opportunity weights `a_e`. -/
  a : E → ℝ
  /-- Opportunity weights are nonnegative. -/
  a_nonneg : ∀ e, 0 ≤ a e
  /-- `q ⊕ e`: the quotient normal form with scalar slot `e` activated. -/
  activate : Q → E → Q
  /-- Activation activates: slot `e` is active in `q ⊕ e`. -/
  activate_active : ∀ q e, active (activate q e) e = true
  /-- Activation touches nothing else: every slot `e' ≠ e` keeps its
      activity. -/
  activate_other : ∀ q e e', e' ≠ e → active (activate q e) e' = active q e'
  /-- Already-active slots: "If the slot is active in `q`, set `q ⊕ e = q`"
      (Definition B.5, line 721). -/
  activate_idem : ∀ q e, active q e = true → activate q e = q

attribute [instance] SlotRegister.finE SlotRegister.decE

/-- The canonical scalar opportunity count
    `𝒩_{ν,r,C}(q) = ∑_{e} a_e · p_{e,ν}(q)` (chi_nu lines 639–642) — the
    *same* counter that appears in the dark-sector collar channel. -/
def count (R : SlotRegister) (q : R.Q) : ℝ :=
  ∑ e, R.a e * (if R.active q e then (1 : ℝ) else 0)

/-- A coherent source datum on the register `R`:

    * `b` — the quotient-visible scalar-slot footprint `b_{U,r,C}(·;q)` of
      Definition B.4 (lines 674–706), nonnegative and unit-normalized
      (`∑ e, b e = 1` on the active support);
    * `S` — the canonical coherent scalar strength `S_coh` of Definition
      B.3. Its observer-side receipts (self-read gate, durable re-readable
      records, prediction better than shuffled controls) are the paper's
      named operational tests — physics, **not modeled here**; only
      `0 ≤ S` is carried. -/
structure CoherentSource (R : SlotRegister) where
  /-- The scalar-slot footprint `b_{U,r,C}(e;q)` (Definition B.4). -/
  b : R.E → ℝ
  /-- Footprints are nonnegative. -/
  b_nonneg : ∀ e, 0 ≤ b e
  /-- Unit normalization on the active support: `∑ e, b e = 1`
      (Definition B.4, lines 681–683). -/
  b_sum_one : ∑ e, b e = 1
  /-- The canonical coherent scalar strength `S_coh` (Definition B.3);
      its defining receipts are physics, not modeled here. -/
  S : ℝ
  /-- The canonical strength is nonnegative. -/
  S_nonneg : 0 ≤ S

/-- **The unit-normalized coherent scalar source generator** (Definition
    B.5, lines 713–734): for a test function `f : Q_r → ℝ`,
    `(𝓛^coh f)(q) = S · ∑_e b_e · [f(q ⊕ e) − f(q)]`.
    Engineering inefficiencies, stored-energy amplification, substrate
    directness, and geometry factors belong to the engineering chart, not
    to this canonical channel identity. -/
def gen (R : SlotRegister) (src : CoherentSource R) (f : R.Q → ℝ) (q : R.Q) : ℝ :=
  src.S * ∑ e, src.b e * (f (R.activate q e) - f q)

/-- **The availability factor** (Definition B.4, lines 699–705):
    `A_{U,r,C}(q) = ∑_e b_e · a_e · [1 − p_{e,ν}(q)]` — the footprint's
    weight on the *inactive* slots. "The source is non-saturated at `q`
    when `A_{U,r,C}(q) > 0`." -/
def avail (R : SlotRegister) (src : CoherentSource R) (q : R.Q) : ℝ :=
  ∑ e, src.b e * R.a e * (if R.active q e then (0 : ℝ) else 1)

/-! ### The count-increment identity (the discrete computation inside B.7) -/

/-- **One-slot increment** (the exact computation at chi_nu lines 786–792):
    activating slot `e` changes the canonical count by exactly
    `a_e · [1 − p_{e,ν}(q)]` — by `a_e` if the slot was free, by `0` if it
    was already active (where `q ⊕ e = q` by `activate_idem`). -/
theorem count_activate (R : SlotRegister) (q : R.Q) (e : R.E) :
    count R (R.activate q e) - count R q
      = R.a e * (if R.active q e then (0 : ℝ) else 1) := by
  cases hqe : R.active q e with
  | true =>
      -- already active: `q ⊕ e = q`, both sides vanish
      simp [R.activate_idem q e hqe]
  | false =>
      -- free slot: all `e' ≠ e` terms agree; the `e` term gains `a e`
      have key : ∀ e' ∈ Finset.univ,
          R.a e' * (if R.active (R.activate q e) e' then (1 : ℝ) else 0)
              - R.a e' * (if R.active q e' then (1 : ℝ) else 0)
            = if e' = e then R.a e else 0 := by
        intro e' _
        rcases eq_or_ne e' e with rfl | he'
        · simp [R.activate_active, hqe]
        · simp [R.activate_other q e e' he', he']
      have main : count R (R.activate q e) - count R q = R.a e := by
        calc count R (R.activate q e) - count R q
            = ∑ e', (R.a e' * (if R.active (R.activate q e) e' then (1 : ℝ) else 0)
                - R.a e' * (if R.active q e' then (1 : ℝ) else 0)) := by
              simp only [count, Finset.sum_sub_distrib]
          _ = ∑ e', if e' = e then R.a e else 0 := Finset.sum_congr rfl key
          _ = R.a e := by simp
      rw [main]
      simp

/-! ### Theorem B.7, machine-checked (the ΔS-bridge definition side) -/

/-- **Coherent material perturbs the canonical scalar count** (Theorem B.7,
    chi_nu lines 751–807): evaluating the source generator on the canonical
    count gives *exactly* `(𝓛^coh 𝒩_ν)(q) = S · A(q)`.

    This is the paper's "coherent material perturbs the same quotient-edge
    scalar opportunity count `𝒩_{ν,r,C}` that appears in the dark-sector
    collar channel" — read with the v7 scope: the record-side ΔS is a
    formally-defined perturbation of a counter OF THE SAME FORM as the one
    the collar prices; the identification is definitional inside
    `ChannelBridge.lean`'s `Channel` (T29), and that nature instantiates
    that structure is the named channel hypothesis. What remains open
    is **G9**: the NUMERICAL map from this record-side increment to the
    gravity-side ΔS. No formal object can close that — it is a physical
    calibration; a null experiment bounds only the product χ·ΔS. -/
theorem gen_count (R : SlotRegister) (src : CoherentSource R) (q : R.Q) :
    gen R src (count R) q = src.S * avail R src q := by
  simp only [gen, avail]
  congr 1
  refine Finset.sum_congr rfl fun e _ => ?_
  rw [count_activate R q e]
  ring

/-- The strict-positivity clause of Theorem B.7: a coherent source with
    `S > 0` acting on a non-saturated state (`A > 0`) perturbs the
    canonical count by a strictly positive amount. -/
theorem gen_count_pos (R : SlotRegister) (src : CoherentSource R) (q : R.Q)
    (hS : 0 < src.S) (hA : 0 < avail R src q) :
    0 < gen R src (count R) q := by
  rw [gen_count]
  exact mul_pos hS hA

/-! ### The non-saturation reading of the availability factor -/

/-- **Non-saturation, exactly** (Definition B.4, last line): `A(q) > 0` iff
    some slot carries strictly positive footprint-weighted opportunity
    (`b_e · a_e > 0`) *and* is still inactive at `q`. This is what "the
    source is non-saturated at `q`" means, as an iff. -/
theorem avail_pos_iff (R : SlotRegister) (src : CoherentSource R) (q : R.Q) :
    0 < avail R src q ↔ ∃ e, 0 < src.b e * R.a e ∧ R.active q e = false := by
  constructor
  · intro hpos
    by_contra hno
    push Not at hno
    have hzero : avail R src q = 0 := by
      simp only [avail]
      refine Finset.sum_eq_zero fun e _ => ?_
      cases hqe : R.active q e with
      | true => simp
      | false =>
          have hba : src.b e * R.a e = 0 :=
            le_antisymm (not_lt.mp fun h => hno e h hqe)
              (mul_nonneg (src.b_nonneg e) (R.a_nonneg e))
          simp [hba]
    rw [hzero] at hpos
    exact lt_irrefl 0 hpos
  · rintro ⟨e, hba, hqe⟩
    simp only [avail]
    refine Finset.sum_pos' (fun e' _ => ?_) ⟨e, Finset.mem_univ e, ?_⟩
    · have h2 : (0 : ℝ) ≤ if R.active q e' then (0 : ℝ) else 1 := by
        split <;> norm_num
      exact mul_nonneg (mul_nonneg (src.b_nonneg e') (R.a_nonneg e')) h2
    · simpa [hqe] using hba

/-! ### The Tier-B response-law shape (Corollary B.11) -/

/-- **Tier-B response law from the finite generator** (Corollary B.11,
    chi_nu lines 911–943), mathematical content: composing the forced
    linear response `δν = χ·⟨η, S⟩` (`ScalarResponse.lean`, under Scalar
    Edge-Center Exhaustion) with the source generator gives the Tier-B1
    law `δν = χ_can · S_coh`, with the availability factor `A` as the
    geometric prefactor: `χ · (𝓛^coh 𝒩_ν)(q) = (χ·S) · A(q)`.

    The *value* `χ_can = e^{−P/24}` is `CollarGate.lean`/`PBranches.lean`
    territory (conditional on L1–L7); this file supplies only the shape. -/
theorem response_form (χ : ℝ) (R : SlotRegister) (src : CoherentSource R) (q : R.Q) :
    χ * gen R src (count R) q = (χ * src.S) * avail R src q := by
  rw [gen_count]
  ring

/-! ### Non-vacuity: a concrete two-slot register where the generator fires

Slots `E = Bool`, states `Q = Bool → Bool` (slot-activity maps), unit
weights, activation = "set the slot's bit" (a genuine normal-form map: it
is extensionally idempotent on already-active slots). The source has the
uniform footprint `b ≡ 1/2` and strength `S = 2`. In the state `demoQ0`
with slot `true` active and slot `false` free: `count = 1`, `A = 1/2`, and
the generator fires with `𝓛^coh 𝒩 = S·A = 1 > 0` — all hypotheses of
`gen_count_pos` are jointly satisfiable. -/

/-- Demo register: two slots, states are slot-activity maps, unit weights,
    activation sets the slot's bit. -/
def demoR : SlotRegister where
  Q := Bool → Bool
  E := Bool
  finE := inferInstanceAs (Fintype Bool)
  decE := inferInstanceAs (DecidableEq Bool)
  active := fun q e => q e
  a := fun _ => 1
  a_nonneg := fun _ => zero_le_one
  activate := fun q e => fun e' => if e' = e then true else q e'
  activate_active := fun q e => by simp
  activate_other := fun q e e' he' => by simp [he']
  activate_idem := fun q e hq => by
    funext e'
    rcases eq_or_ne e' e with rfl | he'
    · simp [hq]
    · simp [he']

/-- Demo source: uniform footprint `b ≡ 1/2` (normalized over two slots),
    strength `S = 2`. -/
noncomputable def demoSrc : CoherentSource demoR where
  b := fun _ => 1 / 2
  b_nonneg := fun _ => by norm_num
  b_sum_one := by
    show ∑ _e : Bool, (1 / 2 : ℝ) = 1
    rw [Fintype.sum_bool]
    norm_num
  S := 2
  S_nonneg := by norm_num

/-- Demo state: slot `true` already active, slot `false` still free. -/
def demoQ0 : demoR.Q := fun e => e

/-- On the demo state the availability factor is
    `A = b(false)·a(false)·1 + b(true)·a(true)·0 = 1/2`: exactly the free
    slot's footprint weight. -/
theorem demo_avail_value : avail demoR demoSrc demoQ0 = 1 / 2 := by
  dsimp only [avail, demoR, demoSrc, demoQ0]
  simp only [Fintype.sum_bool]
  norm_num

/-- The generator genuinely fires on the demo: activating the free slot
    raises the count from `1` to `2`, the active slot contributes `0`
    (idempotence), and `𝓛^coh 𝒩 = 2·(1/2·1 + 1/2·0) = 1 = S·A`. -/
theorem demo_gen_value : gen demoR demoSrc (count demoR) demoQ0 = 1 := by
  dsimp only [gen, count, demoR, demoSrc, demoQ0]
  simp only [Fintype.sum_bool]
  norm_num

/-- Non-vacuity of the B.7 positivity clause: the hypotheses `0 < S` and
    `0 < A` of `gen_count_pos` hold jointly on the demo, so the strictly
    positive perturbation is witnessed, not vacuous. -/
theorem demo_gen_pos : 0 < gen demoR demoSrc (count demoR) demoQ0 :=
  gen_count_pos demoR demoSrc demoQ0
    (by dsimp only [demoSrc]; norm_num)
    (by rw [demo_avail_value]; norm_num)

/-- The demo state is non-saturated in the exact sense of `avail_pos_iff`. -/
example : 0 < avail demoR demoSrc demoQ0 := by
  rw [demo_avail_value]
  norm_num

/-! ### Axiom audit -/
#print axioms count_activate
#print axioms gen_count
#print axioms gen_count_pos
#print axioms avail_pos_iff
#print axioms response_form
#print axioms demo_gen_value
#print axioms demo_gen_pos

end OPHProofChain.DeltaSBridge
