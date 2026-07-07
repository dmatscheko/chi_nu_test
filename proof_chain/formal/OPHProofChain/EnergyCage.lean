import Mathlib

/-!
# The conservation-law cage (G10, theorem side) + design-point arithmetic

Formalizes §5 of `chi_nu_test/proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md`
("Conservation-law bounds that cage the χ_ν chain"), graded by the OPH side
as "valid as an external physics obligation" (`AUDIT_RESPONSE.md`, G10).

## What is formalized

**The cycle theorem.** Model a device with a switchable internal state
(`Bool`) and a position-dependent state energy `E : Pos → Bool → ℝ`
(conservative sector: the force is `−∇E`, so the work extracted moving
`q₁ → q₂` at fixed switch `s` is `E q₁ s − E q₂ s`). Then:

* `cycleWork_eq_toggleCost_diff` — the work extracted by the ABBA cycle
  *(toggle ON at `q₁`) → (move to `q₂`) → (toggle OFF) → (return)* equals
  **exactly** the difference of toggle energies at the two positions. This
  is the first law in identity form. ("No schedule of moves and switches
  beats the toggle ledger" is, since `[formal-v7]`, a theorem at full
  generality — `no_schedule_beats_the_ledger` below, holes-audit F25.)
* `no_free_toggle` — if toggling is (claimed) free to within `ε` everywhere,
  every cycle extracts at most `2ε`: **a switchable force with no toggle
  energy ledger is a perpetual-motion machine**, which is the G10
  obligation in contrapositive form.
* `toggle_ledger_lower_bound` — extracting `W > 0` per cycle forces a
  toggle-energy entry of at least `W/2` somewhere.

**The design-point arithmetic** (machine-checked with `π` bounds; numbers
from the §5 cage):

* `sigma_ph_value` — the phantom surface density lever
  `σ_ph = Δν·g/(4πG)` is `11.6…11.8 kg·m⁻²` per `Δν = 10⁻⁹`
  (`g = 9.81`, `G = 6.674×10⁻¹¹`).
* `toggle_energy_value` — at the 56 gf design point (`ΔM = 0.056 kg`) the
  infinity-referenced interaction transaction against the Earth surface
  potential `Φ_N = G·M_E/R_E` is `|ΔM·Φ_N| ∈ (3.49, 3.52) MJ` — the
  "≈ 3.5 MJ per ACTIVE toggle". `[formal-v6.1]` **Scope note (holes-audit
  F15):** this is arithmetic on the *named G10-convention pricing* (the
  ledgers' declared audit scale); the cycle theorems above force only
  toggle-cost *differences* — i.e. realized cycle work, `ΔM·g·Δh` for a
  stroke `Δh` — never an absolute per-toggle cost.
* `phantom_mass_cap` — the budget corollary: a toggle-energy budget `B`
  caps the switchable phantom mass by `ΔM ≤ B/Φ_N`.

## Honest scope

This module prices the χ_ν force claim; it does **not** derive or refute the
force law (L2.11 stays open). The physical content imported is exactly: the
conservative-sector work bookkeeping (an identity once `E` is given) and the
numerical constants of the §5 design point. `NULL` remains the expected
experimental outcome; a genuine `DETECT` must arrive with the Document C
Part 7 energy log — this module says *how large* that log entry has to be.

Axioms: standard; no `sorry`.
-/

namespace OPHProofChain.EnergyCage

/-! ### The abstract cycle theorem -/

variable {Pos : Type}

/-- Energy needed (from the environment's ledger) to toggle the switch
    OFF → ON at position `q`, in the conservative sector: the state-energy
    difference. -/
def toggleCost (E : Pos → Bool → ℝ) (q : Pos) : ℝ := E q true - E q false

/-- Work extracted by the ABBA cycle: toggle ON at `q₁`, move `q₁ → q₂`
    with the switch ON (extracting `E q₁ ON − E q₂ ON`), toggle OFF at
    `q₂`, return with the switch OFF (extracting `E q₂ OFF − E q₁ OFF`). -/
def cycleWork (E : Pos → Bool → ℝ) (q₁ q₂ : Pos) : ℝ :=
  (E q₁ true - E q₂ true) + (E q₂ false - E q₁ false)

/-- **The cycle identity (first law).** The work any ABBA cycle extracts is
    exactly the toggle-ledger difference between its two endpoints. No
    scheduling cleverness can beat the ledger. -/
theorem cycleWork_eq_toggleCost_diff (E : Pos → Bool → ℝ) (q₁ q₂ : Pos) :
    cycleWork E q₁ q₂ = toggleCost E q₁ - toggleCost E q₂ := by
  unfold cycleWork toggleCost
  ring

/-- **No free toggle.** If the toggle is claimed to cost at most `ε` of
    ledger energy at every position, then no cycle extracts more than `2ε`:
    a switchable conservative force with a *zero* toggle ledger extracts
    zero work — otherwise it is a perpetual-motion machine. -/
theorem no_free_toggle (E : Pos → Bool → ℝ) (ε : ℝ)
    (h : ∀ q : Pos, |toggleCost E q| ≤ ε) (q₁ q₂ : Pos) :
    |cycleWork E q₁ q₂| ≤ 2 * ε := by
  rw [cycleWork_eq_toggleCost_diff]
  calc |toggleCost E q₁ - toggleCost E q₂|
      ≤ |toggleCost E q₁| + |toggleCost E q₂| := abs_sub _ _
    _ ≤ ε + ε := add_le_add (h q₁) (h q₂)
    _ = 2 * ε := by ring

/-- **Ledger lower bound.** Extracting `W` per cycle forces a toggle-energy
    entry of at least `W/2` (in magnitude) at one of the endpoints. -/
theorem toggle_ledger_lower_bound (E : Pos → Bool → ℝ) {q₁ q₂ : Pos} {W : ℝ}
    (hW : W ≤ |cycleWork E q₁ q₂|) :
    W / 2 ≤ |toggleCost E q₁| ∨ W / 2 ≤ |toggleCost E q₂| := by
  by_contra h
  push_neg at h
  obtain ⟨h1, h2⟩ := h
  have hb : |cycleWork E q₁ q₂| ≤ |toggleCost E q₁| + |toggleCost E q₂| := by
    rw [cycleWork_eq_toggleCost_diff]
    exact abs_sub _ _
  linarith

/-! ### Design-point arithmetic (§5 numbers, machine-checked) -/

open Real

/-- The phantom surface density lever: `σ_ph = Δν·g/(4πG)` with
    `Δν = 10⁻⁹`, `g = 9.81 m/s²`, `G = 6.674×10⁻¹¹` lands in
    `(11.6, 11.8) kg/m²` — the "≈ 11.7 kg·m⁻² per 10⁻⁹" of §5. -/
theorem sigma_ph_value :
    11.6 < (1e-9 * 9.81) / (4 * π * 6.674e-11) ∧
    (1e-9 * 9.81) / (4 * π * 6.674e-11) < 11.8 := by
  have hπl : (3.141592 : ℝ) < π := pi_gt_d6
  have hπu : π < 3.141593 := pi_lt_d6
  have hden_pos : (0 : ℝ) < 4 * π * 6.674e-11 := by positivity
  constructor
  · refine (lt_div_iff₀ hden_pos).mpr ?_
    nlinarith
  · refine (div_lt_iff₀ hden_pos).mpr ?_
    nlinarith

/-- The Earth-surface Newtonian potential magnitude `Φ_N = G·M_E/R_E`
    (`G = 6.674×10⁻¹¹`, `M_E = 5.972×10²⁴ kg`, `R_E = 6.371×10⁶ m`) lands
    in `(6.24×10⁷, 6.26×10⁷) J/kg`. -/
theorem phi_N_value :
    (6.24e7 : ℝ) < (6.674e-11 * 5.972e24) / 6.371e6 ∧
    ((6.674e-11 * 5.972e24) / 6.371e6 : ℝ) < 6.26e7 := by
  have hden : (0 : ℝ) < 6.371e6 := by norm_num
  constructor
  · refine (lt_div_iff₀ hden).mpr ?_
    norm_num
  · refine (div_lt_iff₀ hden).mpr ?_
    norm_num

/-- **The toggle transaction at the design point.** Switching a phantom mass
    of `ΔM = 0.056 kg` (the 56 gf design point) against the Earth-surface
    potential prices at `(3.49, 3.52) MJ` — the "≈ 3.5 MJ per ACTIVE
    toggle" of §5, **on the named G10-convention audit scale** (a pricing
    hypothesis of the decision layer, not a consequence of the cycle
    theorems — which force only the anchors below). Document C Part 7 logs
    against this declared scale. -/
theorem toggle_energy_value :
    (3.49e6 : ℝ) < 0.056 * ((6.674e-11 * 5.972e24) / 6.371e6) ∧
    (0.056 * ((6.674e-11 * 5.972e24) / 6.371e6) : ℝ) < 3.52e6 := by
  have hden : (0 : ℝ) < 6.371e6 := by norm_num
  have hassoc : (0.056 * ((6.674e-11 * 5.972e24) / 6.371e6) : ℝ)
      = 0.056 * (6.674e-11 * 5.972e24) / 6.371e6 := by ring
  rw [hassoc]
  constructor
  · refine (lt_div_iff₀ hden).mpr ?_
    norm_num
  · refine (div_lt_iff₀ hden).mpr ?_
    norm_num

/-- **Budget cap.** If the per-toggle energy budget is `B` and the toggle
    must pay `ΔM·Φ_N`, the switchable phantom mass is capped at `B/Φ_N`. -/
theorem phantom_mass_cap {B ΔM Φ : ℝ} (hΦ : 0 < Φ) (hpay : ΔM * Φ ≤ B) :
    ΔM ≤ B / Φ :=
  (le_div_iff₀ hΦ).mpr hpay

/-! ### `[formal-v7]` Arbitrary schedules: the first law and the ledger bound
(holes-audit F25)

The cage's slogan — "no schedule of moves and switches beats the toggle
ledger" — was proven for exactly one schedule (the ABBA cycle). Here it is
for **every** schedule: a schedule is any finite list of legs (move the
device with the switch held, or toggle the switch in place); for CLOSED
schedules (final position and switch state = initial), the extracted work
equals the net toggle-ledger payment (`closed_schedule_work_eq_ledger` — the
first law), so if every toggle is ledgered at most `ε`, no closed schedule
extracts more than `(number of toggles)·ε` (`no_schedule_beats_the_ledger`).
The ABBA results above are the two-toggle special case. -/

/-- One leg of a schedule: move to a position (switch held fixed), or
    toggle the switch in place. -/
inductive Leg (Pos : Type) where
  /-- move to position `q`, switch state unchanged -/
  | move (q : Pos)
  /-- toggle the switch, position unchanged -/
  | toggle

/-- Execute one leg on a `(position, switch)` state. -/
def legStep : Pos × Bool → Leg Pos → Pos × Bool
  | (_, s), .move q' => (q', s)
  | (q, s), .toggle => (q, !s)

/-- Execute a whole schedule. -/
def runSchedule (st : Pos × Bool) (ls : List (Leg Pos)) : Pos × Bool :=
  ls.foldl legStep st

/-- Work extracted by one leg: moves extract the state-energy drop; toggles
    extract nothing (their energy moves through the ledger). -/
def legWork (E : Pos → Bool → ℝ) : Pos × Bool → Leg Pos → ℝ
  | (q, s), .move q' => E q s - E q' s
  | _, .toggle => 0

/-- Ledger payment of one leg: toggles draw the state-energy difference
    from the environment's ledger (negative when energy is returned);
    moves draw nothing. -/
def legLedger (E : Pos → Bool → ℝ) : Pos × Bool → Leg Pos → ℝ
  | (q, s), .toggle => E q (!s) - E q s
  | _, .move _ => 0

/-- Total work extracted along a schedule. -/
def totalWork (E : Pos → Bool → ℝ) : Pos × Bool → List (Leg Pos) → ℝ
  | _, [] => 0
  | st, l :: ls => legWork E st l + totalWork E (legStep st l) ls

/-- Total ledger payment along a schedule. -/
def totalLedger (E : Pos → Bool → ℝ) : Pos × Bool → List (Leg Pos) → ℝ
  | _, [] => 0
  | st, l :: ls => legLedger E st l + totalLedger E (legStep st l) ls

/-- The number of toggles in a schedule. -/
def toggleCount : List (Leg Pos) → ℕ
  | [] => 0
  | .toggle :: ls => toggleCount ls + 1
  | .move _ :: ls => toggleCount ls

/-- **The first law for arbitrary schedules**: along any schedule, extracted
    work minus ledger payments equals the state-energy drop. -/
theorem work_sub_ledger_eq_energy_drop (E : Pos → Bool → ℝ) :
    ∀ (ls : List (Leg Pos)) (st : Pos × Bool),
      totalWork E st ls - totalLedger E st ls
        = E st.1 st.2 - E (runSchedule st ls).1 (runSchedule st ls).2
  | [], st => by
    show (0 : ℝ) - 0 = E st.1 st.2 - E st.1 st.2
    ring
  | l :: ls, st => by
    have ih := work_sub_ledger_eq_energy_drop E ls (legStep st l)
    show legWork E st l + totalWork E (legStep st l) ls
        - (legLedger E st l + totalLedger E (legStep st l) ls)
      = E st.1 st.2 - E (runSchedule (legStep st l) ls).1
          (runSchedule (legStep st l) ls).2
    have hleg : legWork E st l - legLedger E st l
        = E st.1 st.2 - E (legStep st l).1 (legStep st l).2 := by
      obtain ⟨q, s⟩ := st
      cases l with
      | move q' =>
        show E q s - E q' s - 0 = E q s - E q' s
        ring
      | toggle =>
        show (0 : ℝ) - (E q (!s) - E q s) = E q s - E q (!s)
        ring
    linarith [ih, hleg]

/-- **Closed schedules: work = ledger.** Any schedule returning to its
    starting position and switch state extracts exactly what the toggle
    ledger paid. -/
theorem closed_schedule_work_eq_ledger (E : Pos → Bool → ℝ)
    {st : Pos × Bool} {ls : List (Leg Pos)}
    (hclosed : runSchedule st ls = st) :
    totalWork E st ls = totalLedger E st ls := by
  have h := work_sub_ledger_eq_energy_drop E ls st
  rw [hclosed] at h
  linarith

/-- Each toggle's ledger entry is bounded by the toggle-cost bound. -/
theorem totalLedger_bound (E : Pos → Bool → ℝ) {ε : ℝ}
    (h : ∀ q : Pos, |toggleCost E q| ≤ ε) :
    ∀ (ls : List (Leg Pos)) (st : Pos × Bool),
      |totalLedger E st ls| ≤ toggleCount ls * ε
  | [], st => by
    show |(0 : ℝ)| ≤ (0 : ℕ) * ε
    simp
  | .move q' :: ls, st => by
    have ih := totalLedger_bound E h ls (legStep st (.move q'))
    show |0 + totalLedger E (legStep st (.move q')) ls|
      ≤ (toggleCount ls : ℕ) * ε
    rw [zero_add]
    exact ih
  | .toggle :: ls, st => by
    have ih := totalLedger_bound E h ls (legStep st .toggle)
    obtain ⟨q, s⟩ := st
    have hthis : |legLedger E (q, s) Leg.toggle| ≤ ε := by
      cases s with
      | false =>
        show |E q true - E q false| ≤ ε
        exact h q
      | true =>
        show |E q false - E q true| ≤ ε
        rw [abs_sub_comm]
        exact h q
    calc |legLedger E (q, s) Leg.toggle
          + totalLedger E (legStep (q, s) Leg.toggle) ls|
        ≤ |legLedger E (q, s) Leg.toggle|
          + |totalLedger E (legStep (q, s) Leg.toggle) ls| := abs_add_le _ _
      _ ≤ ε + toggleCount ls * ε := add_le_add hthis ih
      _ = (toggleCount ls + 1 : ℕ) * ε := by push_cast; ring

/-- **NO SCHEDULE BEATS THE TOGGLE LEDGER** — now for every schedule, not
    just the ABBA cycle: a closed schedule whose every toggle is ledgered at
    most `ε` extracts at most `(number of toggles)·ε` of work. The slogan is
    a theorem at its advertised generality (holes-audit F25). -/
theorem no_schedule_beats_the_ledger (E : Pos → Bool → ℝ) {ε : ℝ}
    (h : ∀ q : Pos, |toggleCost E q| ≤ ε)
    {st : Pos × Bool} {ls : List (Leg Pos)}
    (hclosed : runSchedule st ls = st) :
    |totalWork E st ls| ≤ toggleCount ls * ε := by
  rw [closed_schedule_work_eq_ledger E hclosed]
  exact totalLedger_bound E h ls st

/-! ### `[formal-v7]` The two theorem-grade anchors beside the G10-convention
(holes-audit F15)

The audit's repair demanded the two *defensible* anchors be stated next to
the named convention. Here they are, as machine-checked arithmetic:

* the **cycle theorems force** (per 1 m bench stroke at the design point)
  a per-toggle entry of at least `W/2 ≈ 0.27 J` — and exactly **zero** for
  a toggle at fixed position (`cycleWork_self`);
* the **relativistic source-creation reading** prices the same toggle at
  `ΔM·c² ≈ 5.03×10¹⁵ J`;
* the G10-convention figure `ΔM·Φ_N ≈ 3.5 MJ` sits **strictly between**
  them (`anchor_ordering`) — seven orders above the forced floor, nine
  below the creation ceiling. The convention is thereby visible as a
  *pricing choice inside the theorem-grade corridor*, exactly as the
  disposition of F15 states. -/

/-- Toggling at a fixed position closes a cycle of zero work: the cycle
    theorems force **no** ledger entry at all for the experiment's actual
    fixed-position protocol. -/
theorem cycleWork_self (E : Pos → Bool → ℝ) (q : Pos) :
    cycleWork E q q = 0 := by
  unfold cycleWork
  ring

/-- **The forced floor.** The realized work of a 1 m bench cycle at the
    design point — `ΔM·g·Δh` with `ΔM = 0.056 kg`, `g = 9.81 m/s²`,
    `Δh = 1 m` — is `(0.549, 0.550) J`; the forced per-toggle entry
    (`toggle_ledger_lower_bound`) is half that: `≈ 0.27 J`. -/
theorem bench_cycle_work_value :
    (0.549 : ℝ) < 0.056 * 9.81 * 1 ∧ (0.056 * 9.81 * 1 : ℝ) < 0.550 := by
  norm_num

/-- **The creation ceiling.** Pricing genuine creation of `ΔM = 0.056 kg`
    of gravitating source strength relativistically costs
    `ΔM·c² ∈ (5.03, 5.04)×10¹⁵ J`. -/
theorem mass_energy_value :
    (5.03e15 : ℝ) < 0.056 * (2.99792458e8 : ℝ) ^ 2 ∧
    (0.056 * (2.99792458e8 : ℝ) ^ 2 : ℝ) < 5.04e15 := by
  norm_num

/-- **The corridor.** At the design point, the G10-convention figure
    `ΔM·Φ_N` sits strictly between the theorem-forced bench floor
    `ΔM·g·Δh` and the relativistic creation ceiling `ΔM·c²`:
    `0.55 J < 3.5 MJ < 5.0×10¹⁵ J`. The convention prices inside the
    corridor the theorems and relativity leave open — a declared choice,
    not a theorem, exactly as the F15 disposition states. -/
theorem anchor_ordering :
    (0.056 * 9.81 * 1 : ℝ) < 0.056 * ((6.674e-11 * 5.972e24) / 6.371e6) ∧
    (0.056 * ((6.674e-11 * 5.972e24) / 6.371e6) : ℝ)
      < 0.056 * (2.99792458e8 : ℝ) ^ 2 := by
  have hden : (0 : ℝ) < 6.371e6 := by norm_num
  constructor
  · have h1 : (0.056 * ((6.674e-11 * 5.972e24) / 6.371e6) : ℝ)
        = 0.056 * (6.674e-11 * 5.972e24) / 6.371e6 := by ring
    rw [h1, lt_div_iff₀ hden]
    norm_num
  · have h1 : (0.056 * ((6.674e-11 * 5.972e24) / 6.371e6) : ℝ)
        = 0.056 * (6.674e-11 * 5.972e24) / 6.371e6 := by ring
    rw [h1, div_lt_iff₀ hden]
    norm_num

/-! ### Axiom audit -/
#print axioms cycleWork_eq_toggleCost_diff
#print axioms no_free_toggle
#print axioms toggle_ledger_lower_bound
#print axioms sigma_ph_value
#print axioms toggle_energy_value
#print axioms cycleWork_self
#print axioms bench_cycle_work_value
#print axioms mass_energy_value
#print axioms anchor_ordering
#print axioms work_sub_ledger_eq_energy_drop
#print axioms closed_schedule_work_eq_ledger
#print axioms no_schedule_beats_the_ledger

end OPHProofChain.EnergyCage
