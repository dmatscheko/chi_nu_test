import Mathlib

/-!
# P3 — The layered functional boundary carrier (Lean port)

Port of `observer-patch-holography/paper/reality_as_consensus_protocol.tex`,
Definition `def:layered-functional-boundary-carrier`, Theorem
`thm:layered-carrier-HB-Hfib`, and Corollary
`cor:layered-carrier-reconstruction` (lines 1225–1364).

## What is formalized

* `LayeredCarrier` — a layered directed graph `V = L₀ ⊔ … ⊔ L_D` with
  per-vertex alphabets `A v`, parent sets in strictly earlier layers, and a
  deterministic local rule `F v` at every interior vertex; optional
  cross-check predicates. The boundary is layer `0`; the boundary map
  `restrictB` reads it.
* `extend b` — the functional extension `E(b)` (well-founded recursion on the
  layer), i.e. the unique feed-forward completion of boundary data `b`.
* `layerRepair d` / `sweepUpTo d` / `sweep` — the layer repair maps `R_d` and
  the staged sweep `R_D ∘ ⋯ ∘ R_1`.
* `sweep_boundary` (**H_B**) — no stage writes the boundary.
* `sweep_eq_extend` (**reconstruction**) — the staged sweep from *any* initial
  state lands exactly on `E(B(a))`. (The paper states this under
  admissibility because its `C_Q` includes cross-checks; the sweep identity
  itself is unconditional, and membership in `C_Q` is exactly admissibility —
  both are proven below, separated.)
* `consistent_eq_extend` / `hfib_singleton` (**H_fib**) — a consistent state
  is determined by its boundary: the consistent boundary fiber is `{E(b)}`.
* `reconstruction_of_boundary_preserving_repair` — the content of the paper's
  Corollary: *any* repair process that preserves the boundary and lands in
  the consistent set necessarily outputs `E(B(a))`. (The paper phrases this
  for the global quotient repair operator `Rep_λ`; this form is
  presentation-independent and composes with `QuotientRepair.lean`'s
  `globalRepair` — see `Reconstruction.lean`.)
* `demoLayered` — a concrete *genuinely multi-edge* instance (two boundary
  bits, an interior XOR vertex, a top copy vertex: ≥ 2 dependency edges, one
  layer with 2 dependencies), so every hypothesis above is exhibited
  satisfiable. Non-vacuity: `demoLayered_two_consistent_states`.

## Honest scope (review R1 of the proof chain, preserved)

This is the **feed-forward class**: the boundary is the complete input layer
of a deterministic circuit, so reconstruction is determination-by-
construction. It discharges the *form* of the joint `H_B ∧ H_fib` witness the
Lean core named as open. It does **not** give erasure-correction strength
(reconstruction from a *proper subset* of the natural boundary through
constraint redundancy); that stronger statement is proven on the Rule-90
cylinder in `Rule90Cylinder.lean`. The paper's finiteness assumption is not
needed for any statement here and is therefore not imposed; instances may of
course be finite (the demo is).

Axioms: standard (`propext`, `Classical.choice`, `Quot.sound`); no `sorry`.
-/

namespace OPHProofChain

/-- A layered functional boundary carrier
    (`def:layered-functional-boundary-carrier`). Vertices carry a layer
    `≤ D`; every vertex has a (possibly empty) family of parents in strictly
    earlier layers; every *interior* vertex (layer `> 0`) has a deterministic
    local rule computing its value from its parents' values. Cross-check
    predicates are the paper's optional `χ_e`; they constrain consistency but
    play no role in reconstruction. `parent_lt` forces boundary vertices to
    have no parents (a parent would need a negative layer). -/
structure LayeredCarrier where
  /-- Depth `D` of the layering `V = L₀ ⊔ … ⊔ L_D`. -/
  D : ℕ
  /-- Vertices. -/
  V : Type
  /-- Layer assignment. -/
  layer : V → ℕ
  /-- Layers do not exceed the depth. -/
  layer_le : ∀ v, layer v ≤ D
  /-- Per-vertex finite alphabet `A_v` (finiteness not needed for the
      theorems; see module docstring). -/
  A : V → Type
  /-- Index type of the parent family `P(v)`. -/
  ParentIdx : V → Type
  /-- The parent family. -/
  parent : (v : V) → ParentIdx v → V
  /-- Parents live in strictly earlier layers. -/
  parent_lt : ∀ (v : V) (k : ParentIdx v), layer (parent v k) < layer v
  /-- The deterministic local rule at an interior vertex. -/
  F : (v : V) → 0 < layer v → ((k : ParentIdx v) → A (parent v k)) → A v
  /-- Cross-check edge index (the paper's optional `χ_e`; may be empty). -/
  Check : Type
  /-- Cross-check predicates on global states. -/
  checkOK : Check → ((v : V) → A v) → Prop

namespace LayeredCarrier

/-- The quotient state space `Q = ∏_v A_v`. -/
abbrev Q (C : LayeredCarrier) : Type := (v : C.V) → C.A v

/-- The boundary layer `L₀` as a subtype. -/
abbrev Bnd (C : LayeredCarrier) : Type := {v : C.V // C.layer v = 0}

/-- Boundary data `∏_{v ∈ L₀} A_v`. -/
abbrev BData (C : LayeredCarrier) : Type := (u : C.Bnd) → C.A u.val

/-- The boundary map `B : Q → ∏_{v∈L₀} A_v` (restriction to layer 0). -/
def restrictB (C : LayeredCarrier) (a : C.Q) : C.BData := fun u => a u.val

/-- The functional extension `E(b)`: boundary vertices read `b`; interior
    vertices apply their rule to their parents' extensions. Well-founded
    recursion on the layer. -/
def extend (C : LayeredCarrier) (b : C.BData) : (v : C.V) → C.A v :=
  fun v =>
    if h : C.layer v = 0 then b ⟨v, h⟩
    else
      C.F v (Nat.pos_of_ne_zero h) (fun k => extend C b (C.parent v k))
termination_by v => C.layer v
decreasing_by exact C.parent_lt v k

variable (C : LayeredCarrier)

/-- `E(b)` at a boundary vertex reads the boundary data. -/
theorem extend_eq_of_layer_eq_zero (b : C.BData) {v : C.V} (h : C.layer v = 0) :
    C.extend b v = b ⟨v, h⟩ := by
  rw [extend, dif_pos h]

/-- `E(b)` restricted to the boundary is `b`. -/
theorem extend_boundary (b : C.BData) (u : C.Bnd) :
    C.extend b u.val = b u := by
  obtain ⟨v, hv⟩ := u
  exact C.extend_eq_of_layer_eq_zero b hv

/-- `E(b)` satisfies every interior functional equation. -/
theorem extend_interior (b : C.BData) (v : C.V) (hv : 0 < C.layer v) :
    C.extend b v = C.F v hv (fun k => C.extend b (C.parent v k)) := by
  rw [extend, dif_neg (Nat.pos_iff_ne_zero.mp hv)]

/-- The functional-equation half of consistency: every interior vertex
    satisfies `a_v = F_v((a_u)_{u ∈ P(v)})`. -/
def FunctionalEq (a : C.Q) : Prop :=
  ∀ (v : C.V) (hv : 0 < C.layer v), a v = C.F v hv (fun k => a (C.parent v k))

/-- Consistency `C_Q`: all interior functional equations hold and all
    cross-check predicates pass. -/
def Consistent (a : C.Q) : Prop :=
  C.FunctionalEq a ∧ ∀ c : C.Check, C.checkOK c a

/-- Admissibility of boundary data: its extension is consistent
    (`C_Q = {E(b) : b admissible}` is `consistent_iff_extend_admissible`
    below plus `consistent_eq_extend`). -/
def Admissible (b : C.BData) : Prop := C.Consistent (C.extend b)

/-- The layer repair map `R_d`: rewrite exactly the vertices of layer `d`
    (`d ≥ 1`) from their parents; leave everything else. -/
def layerRepair (d : ℕ) (a : C.Q) : C.Q :=
  fun v =>
    if h : C.layer v = d ∧ 0 < C.layer v then
      C.F v h.2 (fun k => a (C.parent v k))
    else a v

end LayeredCarrier

/-- The staged sweep through layers `1, …, d`. -/
def LayeredCarrier.sweepUpTo (C : LayeredCarrier) : ℕ → C.Q → C.Q
  | 0, a => a
  | d + 1, a => C.layerRepair (d + 1) (C.sweepUpTo d a)

namespace LayeredCarrier

variable (C : LayeredCarrier)

/-- The full staged repair sweep `R_sweep = R_D ∘ ⋯ ∘ R_1`. -/
def sweep (a : C.Q) : C.Q := C.sweepUpTo C.D a

/-- `R_d` never writes a vertex outside layer `d`. -/
theorem layerRepair_eq_of_ne {d : ℕ} {v : C.V} (h : C.layer v ≠ d) (a : C.Q) :
    C.layerRepair d a v = a v := by
  unfold layerRepair
  rw [dif_neg]
  intro hc
  exact h hc.1

/-- **H_B for every stage**: the sweep never writes the boundary
    (`B(a^{(d)}) = b` in the paper's notation). -/
theorem sweepUpTo_boundary (d : ℕ) (a : C.Q) (u : C.Bnd) :
    C.sweepUpTo d a u.val = a u.val := by
  induction d with
  | zero => rfl
  | succ d ih =>
      show C.layerRepair (d + 1) (C.sweepUpTo d a) u.val = a u.val
      have hu : C.layer u.val ≠ d + 1 := by
        have := u.property
        omega
      rw [C.layerRepair_eq_of_ne hu, ih]

/-- **H_B**, boundary-map form: `B(R_sweep(a)) = B(a)`. -/
theorem sweep_restrictB (a : C.Q) :
    C.restrictB (C.sweep a) = C.restrictB a := by
  funext u
  exact C.sweepUpTo_boundary C.D a u

/-- The paper's staged induction: after stage `d`, every vertex of layer
    `≤ d` carries the functional extension of the (preserved) boundary. -/
theorem sweepUpTo_eq_extend (a : C.Q) :
    ∀ (d : ℕ) (v : C.V), C.layer v ≤ d →
      C.sweepUpTo d a v = C.extend (C.restrictB a) v := by
  intro d
  induction d with
  | zero =>
      intro v hv
      have h0 : C.layer v = 0 := Nat.le_zero.mp hv
      show a v = _
      rw [C.extend_eq_of_layer_eq_zero _ h0]
      rfl
  | succ d ih =>
      intro v hv
      rcases Nat.lt_or_ge (C.layer v) (d + 1) with hlt | hge
      · -- earlier layers: `R_{d+1}` does not touch `v`
        show C.layerRepair (d + 1) (C.sweepUpTo d a) v = _
        rw [C.layerRepair_eq_of_ne (by omega), ih v (by omega)]
      · -- layer exactly `d+1`: the repair writes the rule of the parents,
        -- which are all in layers `≤ d` and hence already correct
        have hd : C.layer v = d + 1 := le_antisymm hv hge
        have hpos : 0 < C.layer v := by omega
        show C.layerRepair (d + 1) (C.sweepUpTo d a) v = _
        unfold layerRepair
        rw [dif_pos ⟨hd, hpos⟩, C.extend_interior _ v hpos]
        congr 1
        funext k
        exact ih (C.parent v k) (by have := C.parent_lt v k; omega)

/-- **Reconstruction by the staged sweep** (`a^{(D)} = E(b)`): from *any*
    initial state, the full sweep lands exactly on the functional extension
    of the initial boundary data. -/
theorem sweep_eq_extend (a : C.Q) :
    C.sweep a = C.extend (C.restrictB a) := by
  funext v
  exact C.sweepUpTo_eq_extend a C.D v (C.layer_le v)

/-- If the boundary is admissible, the sweep lands in `C_Q`
    (the paper's "`a^{(D)} = E(b) ∈ C_Q`"). -/
theorem sweep_consistent_of_admissible (a : C.Q)
    (h : C.Admissible (C.restrictB a)) : C.Consistent (C.sweep a) := by
  rw [C.sweep_eq_extend a]
  exact h

/-- **The key H_fib lemma**: a consistent state *is* the functional extension
    of its own boundary (strong induction on the layer, exactly the paper's
    proof). Only the functional-equation half of consistency is used. -/
theorem functionalEq_eq_extend {a : C.Q} (ha : C.FunctionalEq a) :
    a = C.extend (C.restrictB a) := by
  have key : ∀ (n : ℕ) (v : C.V), C.layer v ≤ n →
      a v = C.extend (C.restrictB a) v := by
    intro n
    induction n with
    | zero =>
        intro v hv
        have h0 : C.layer v = 0 := Nat.le_zero.mp hv
        rw [C.extend_eq_of_layer_eq_zero _ h0]
        rfl
    | succ n ih =>
        intro v hv
        rcases Nat.lt_or_ge (C.layer v) (n + 1) with hlt | hge
        · exact ih v (by omega)
        · have hpos : 0 < C.layer v := by omega
          rw [ha v hpos, C.extend_interior _ v hpos]
          congr 1
          funext k
          exact ih (C.parent v k) (by have := C.parent_lt v k; omega)
  funext v
  exact key (C.layer v) v le_rfl

/-- **H_fib (singleton consistent boundary fiber)**:
    `C_Q ∩ B⁻¹(b) = {E(b)}` — two consistent states with the same boundary
    are equal (`thm:layered-carrier-HB-Hfib`, last claim). -/
theorem hfib_singleton {a a' : C.Q}
    (ha : C.Consistent a) (ha' : C.Consistent a')
    (hB : C.restrictB a = C.restrictB a') : a = a' := by
  have h1 := C.functionalEq_eq_extend ha.1
  have h2 := C.functionalEq_eq_extend ha'.1
  rw [h1, h2, hB]

/-- The consistent set is exactly the set of extensions of admissible
    boundaries (`C_Q = {E(b) : b admissible}`). -/
theorem consistent_iff_extend_admissible (a : C.Q) :
    C.Consistent a ↔ ∃ b : C.BData, C.Admissible b ∧ a = C.extend b := by
  constructor
  · intro ha
    refine ⟨C.restrictB a, ?_, C.functionalEq_eq_extend ha.1⟩
    unfold Admissible
    rw [← C.functionalEq_eq_extend ha.1]
    exact ha
  · rintro ⟨b, hb, rfl⟩
    exact hb

/-- **Corollary (`cor:layered-carrier-reconstruction`), presentation-free
    form**: *any* repair process `R` that preserves the boundary and lands in
    the consistent set necessarily outputs the functional extension of the
    input's boundary, `R(a) = E(B(a))` — and hence every readout of `R(a)`
    factors through `E(B(a))`. Instantiating `R := Rep_λ` of an OPH-admissible
    presentation (whose `H_B`/`H_comp` give exactly the two hypotheses)
    recovers the paper's statement; see `Reconstruction.lean`. -/
theorem reconstruction_of_boundary_preserving_repair
    (R : C.Q → C.Q) (a : C.Q)
    (hB : C.restrictB (R a) = C.restrictB a)
    (hC : C.Consistent (R a)) :
    R a = C.extend (C.restrictB a) := by
  have h := C.functionalEq_eq_extend hC.1
  rw [h, hB]

end LayeredCarrier

/-! ### A genuinely multi-edge instance (non-vacuity witness)

Two boundary bits `b₀, b₁` (layer 0), one interior vertex `m` (layer 1)
computing `b₀ XOR b₁` through **two** dependency edges, and a top vertex
(layer 2) copying `m`. This meets the paper's "genuinely multi-edge" clause
(at least two dependency edges; a layer with more than one dependency), and
its boundary is a proper subset of the vertex set. No cross-checks. -/

/-- Vertices of the demo carrier: two boundary bits, the XOR vertex, the top
    copy vertex. -/
inductive DemoV where
  | b0 : DemoV
  | b1 : DemoV
  | mid : DemoV
  | top : DemoV
deriving DecidableEq

/-- The demo carrier: `mid = b0 XOR b1` (two dependency edges into one
    vertex), `top = mid`. -/
def demoLayered : LayeredCarrier where
  D := 2
  V := DemoV
  layer := fun v =>
    match v with
    | .b0 => 0
    | .b1 => 0
    | .mid => 1
    | .top => 2
  layer_le := by intro v; cases v <;> decide
  A := fun _ => Bool
  ParentIdx := fun v =>
    match v with
    | .b0 => Empty
    | .b1 => Empty
    | .mid => Bool
    | .top => Unit
  parent := fun v =>
    match v with
    | .b0 => fun k => nomatch k
    | .b1 => fun k => nomatch k
    | .mid => fun k => if k then .b0 else .b1
    | .top => fun _ => .mid
  parent_lt := fun v => by
    cases v with
    | b0 => exact fun k => nomatch k
    | b1 => exact fun k => nomatch k
    | mid => intro k; cases k <;> decide
    | top => intro k; cases k; decide
  F := fun v =>
    match v with
    | .b0 => fun hpos => absurd hpos (by decide)
    | .b1 => fun hpos => absurd hpos (by decide)
    | .mid => fun _ vals => xor (vals true) (vals false)
    | .top => fun _ vals => vals ()
  Check := Empty
  checkOK := fun c _ => nomatch c

/-- Non-vacuity: the demo carrier has (at least) two distinct consistent
    states — so `hfib_singleton` and `sweep_eq_extend` quantify over a
    genuinely populated, multi-edge consistent set. -/
theorem demoLayered_two_consistent_states :
    ∃ a a' : demoLayered.Q,
      demoLayered.Consistent a ∧ demoLayered.Consistent a' ∧ a ≠ a' := by
  refine ⟨fun _ => false,
          fun v => match v with | .b0 => true | .b1 => false | .mid => true | .top => true,
          ⟨?_, ?_⟩, ⟨?_, ?_⟩, ?_⟩
  · intro v hv
    cases v with
    | b0 => exact absurd hv (by decide)
    | b1 => exact absurd hv (by decide)
    | mid => rfl
    | top => rfl
  · intro c
    exact nomatch c
  · intro v hv
    cases v with
    | b0 => exact absurd hv (by decide)
    | b1 => exact absurd hv (by decide)
    | mid => rfl
    | top => rfl
  · intro c
    exact nomatch c
  · intro h
    have := congrFun h .b0
    simp at this

/-! ### Axiom audit -/
#print axioms LayeredCarrier.sweep_eq_extend
#print axioms LayeredCarrier.hfib_singleton
#print axioms LayeredCarrier.sweep_restrictB
#print axioms LayeredCarrier.reconstruction_of_boundary_preserving_repair
#print axioms demoLayered_two_consistent_states

end OPHProofChain
