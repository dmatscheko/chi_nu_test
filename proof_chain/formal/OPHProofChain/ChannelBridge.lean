import Mathlib
import OPHProofChain.DeltaSBridge
import OPHProofChain.CollarGate

/-!
# T29 — The channel bridge: one structure, both counters (holes-audit F11)

**The audit hole this closes.** The chain said "coherent matter perturbs
*the same counter* the collar prices" — but `DeltaSBridge.lean` (the
record-side register) and `CollarGate.lean` (the collar-side slice model)
were disjoint modules with no shared type and no identification lemma; the
sameness was prose. The audit's repair option (a): *"a formal bridge — a
structure in which the collar's slices and the register's slots are the same
indexed family, with the Poisson mean and the opportunity count derived from
one object — then 'the same counter' is a theorem about that structure and
the physical residue is cleanly G9."*

This module is that structure. A `Channel` carries **one** finite indexed
family `E` equipped with BOTH panels of data:

* the record panel (activity indicator, opportunity weights, activation
  map) — from which `toRegister` derives a `DeltaSBridge.SlotRegister`;
* the collar panel (slice weights, protected-reserve means) — from which
  `toSlices` derives a `CollarGate.SliceModel`.

The identification "slots = slices" is then **definitional**
(`same_family : (toRegister C).E = (toSlices C).ι := rfl`), and the composite
Tier-B1 law is a theorem about the one structure
(`channel_composite`): under the gate clauses (unbiasedness at `P/24`),

`λ_collar · (𝓛^coh 𝒩)(q) = e^{−P/24} · S · A(q)` —

the collar coefficient multiplying the record-side generator, end to end
inside a single object, with `𝒩` and `λ_collar` both sums over the SAME `E`.

**What remains — cleanly.** Two named residues, and only these:
1. **the channel identification** — that nature's record channel and collar
   channel instantiate ONE `Channel` (i.e. that reality is an instance of
   this structure); previously this hid inside the words "the same counter";
2. **G9** — the numerical size of `S` for any buildable coupon.

Both are physics; neither is bookkeeping anymore.

Axioms: standard (`propext`, `Classical.choice`, `Quot.sound`); no `sorry`.
-/

namespace OPHProofChain.ChannelBridge

open DeltaSBridge CollarGate

/-- **The channel**: one finite indexed family carrying both the record
    panel (activity, opportunity weights, activation) and the collar panel
    (slice weights, reserve means). Slots and slices are the SAME index by
    construction. -/
structure Channel where
  /-- Quotient states (the physical quotient `Q_r`). -/
  Q : Type
  /-- THE shared index family: scalar slots = transverse slices. -/
  E : Type
  [finE : Fintype E]
  [decE : DecidableEq E]
  /-- Record panel: slot-activity indicator. -/
  active : Q → E → Bool
  /-- Record panel: per-slot opportunity weights. -/
  a : E → ℝ
  a_nonneg : ∀ e, 0 ≤ a e
  /-- Record panel: normal-form activation. -/
  activate : Q → E → Q
  activate_active : ∀ q e, active (activate q e) e = true
  activate_other : ∀ q e e', e' ≠ e → active (activate q e) e' = active q e'
  activate_idem : ∀ q e, active q e = true → activate q e = q
  /-- Collar panel: slice weights. -/
  w : E → ℝ
  w_nonneg : ∀ e, 0 ≤ w e
  w_sum_one : ∑ e, w e = 1
  /-- Collar panel: per-slice protected-reserve means. -/
  ε : E → ℝ
  ε_nonneg : ∀ e, 0 ≤ ε e

attribute [instance] Channel.finE Channel.decE

variable (C : Channel)

/-- The record side of the channel — a genuine `SlotRegister`. -/
def toRegister : SlotRegister where
  Q := C.Q
  E := C.E
  finE := C.finE
  decE := C.decE
  active := C.active
  a := C.a
  a_nonneg := C.a_nonneg
  activate := C.activate
  activate_active := C.activate_active
  activate_other := C.activate_other
  activate_idem := C.activate_idem

/-- The collar side of the channel — a genuine `SliceModel`. -/
def toSlices : SliceModel where
  ι := C.E
  fin := C.finE
  w := C.w
  ε := C.ε
  w_nonneg := C.w_nonneg
  w_sum_one := C.w_sum_one
  ε_nonneg := C.ε_nonneg

/-- **The identification, machine-checked — definitionally.** Inside the
    bridge structure, the register's slot family IS the slice model's slice
    family. (This is the sentence "the same counter" was silently pricing;
    here it is `rfl`, because the structure makes it so — and whether
    NATURE is an instance of the structure is the named channel
    identification, listed above.) -/
theorem same_family : (toRegister C).E = (toSlices C).ι := rfl

/-- The record-side counter of the derived register is a sum over the SAME
    family the collar coefficient sums over. -/
theorem count_eq (q : C.Q) :
    count (toRegister C) q
      = ∑ e : C.E, C.a e * (if C.active q e then (1 : ℝ) else 0) := rfl

/-- The collar-side coefficient of the derived slice model is a sum over
    the SAME family the counter sums over. -/
theorem lambdaCollar_eq :
    lambdaCollar (toSlices C) = ∑ e : C.E, C.w e * Real.exp (-(C.ε e)) := rfl

/-- The gate on the derived slice model: unbiasedness at `P/24` forces the
    collar coefficient to `e^{−P/24}` exactly (T16's `uniform_gate`,
    consumed through the bridge). -/
theorem bridge_gate (P : ℝ) (h_unbiased : ∀ e : C.E, C.ε e = P / 24) :
    lambdaCollar (toSlices C) = Real.exp (-(P / 24)) :=
  uniform_gate (toSlices C) P h_unbiased

/-- **THE COMPOSITE — the Tier-B1 law inside one structure.** For a coherent
    source on the channel's register side, under slice-wise unbiasedness at
    `P/24` on the channel's collar side:

    `λ_collar · (𝓛^coh 𝒩)(q) = e^{−P/24} · S · A(q)`.

    The record-side generator (T17) and the collar-side coefficient (T16)
    compose on the SAME indexed family: "the same counter" is now a theorem
    about `Channel`, and what is left open is exactly (1) whether nature
    instantiates `Channel` (the named channel identification) and (2) the
    numerical `S` (G9). -/
theorem channel_composite (src : CoherentSource (toRegister C)) (q : C.Q)
    (P : ℝ) (h_unbiased : ∀ e : C.E, C.ε e = P / 24) :
    lambdaCollar (toSlices C)
        * gen (toRegister C) src (count (toRegister C)) q
      = Real.exp (-(P / 24)) * (src.S * avail (toRegister C) src q) := by
  rw [bridge_gate C P h_unbiased, gen_count]

/-! ### Non-vacuity: a channel where everything fires jointly

Two slots/slices, uniform weights, reserve means pinned at `P/24`; the
record panel is the `DeltaSBridge` demo. On it: the gate holds, the source
fires, and the composite law evaluates to `e^{−P/24}·1 > 0`. -/

/-- Demo channel: the `DeltaSBridge` demo register glued to a uniform
    two-slice collar panel with reserve means `P/24`. -/
noncomputable def demoChannel (P : ℝ) (hP : 0 ≤ P) : Channel where
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
  w := fun _ => 1 / 2
  w_nonneg := fun _ => by norm_num
  w_sum_one := by
    show ∑ _e : Bool, (1 / 2 : ℝ) = 1
    rw [Fintype.sum_bool]
    norm_num
  ε := fun _ => P / 24
  ε_nonneg := fun _ => by positivity

/-- The uniform demo source (footprint `1/2`, strength `S = 2`) on the demo
    channel's register side. -/
noncomputable def demoChannelSrc (P : ℝ) (hP : 0 ≤ P) :
    CoherentSource (toRegister (demoChannel P hP)) where
  b := fun _ => 1 / 2
  b_nonneg := fun _ => by norm_num
  b_sum_one := by
    show ∑ _e : Bool, (1 / 2 : ℝ) = 1
    rw [Fintype.sum_bool]
    norm_num
  S := 2
  S_nonneg := by norm_num

/-- The demo channel's gate: its collar coefficient is exactly
    `e^{−P/24}`. -/
theorem demoChannel_gate (P : ℝ) (hP : 0 ≤ P) :
    lambdaCollar (toSlices (demoChannel P hP)) = Real.exp (-(P / 24)) :=
  bridge_gate (demoChannel P hP) P (fun _ => rfl)

/-- The composite genuinely fires on the demo channel: with the uniform
    source of strength `S = 2` on the state with one free slot, the
    composed Tier-B1 quantity is strictly positive. -/
theorem demoChannel_composite_pos (P : ℝ) (hP : 0 ≤ P) :
    0 < lambdaCollar (toSlices (demoChannel P hP))
        * gen (toRegister (demoChannel P hP)) (demoChannelSrc P hP)
            (count (toRegister (demoChannel P hP))) (fun e => e) := by
  rw [demoChannel_gate P hP, gen_count]
  have h1 : (0 : ℝ) < Real.exp (-(P / 24)) := Real.exp_pos _
  have h2 : (0 : ℝ) < avail (toRegister (demoChannel P hP))
      (demoChannelSrc P hP) (fun e => e) := by
    rw [avail_pos_iff]
    refine ⟨false, ?_, rfl⟩
    show (0 : ℝ) < (1 / 2 : ℝ) * 1
    norm_num
  have h3 : (0 : ℝ) < (demoChannelSrc P hP).S := by
    norm_num [demoChannelSrc]
  exact mul_pos h1 (mul_pos h3 h2)

/-! ### Axiom audit -/
#print axioms same_family
#print axioms count_eq
#print axioms lambdaCollar_eq
#print axioms bridge_gate
#print axioms channel_composite
#print axioms demoChannel_gate
#print axioms demoChannel_composite_pos

end OPHProofChain.ChannelBridge
