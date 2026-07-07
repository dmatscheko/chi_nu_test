/-
ATTRIBUTION: the F4 field construction and the hexacode definitions/theorems
(everything above the `[formal-v4 additions]` marker below) are ported on
2026-07-06 from
  dula/prime-inertia-engine/hexacode.lean   (repo author: DULA2025)
— the one artifact of the dula/ audit graded genuinely reusable
(formal_audits/PIE_AUDIT_RAW.md; proof chain v3 §9). The port wraps the
original in the `OPHProofChain.HexacodePort` namespace and is otherwise
verbatim except where marked. Everything below the marker is new in this
tree: the minimum-distance theorem d = 4, hermitian self-duality, and the
MDS information-set theorem — closing the source file's own "What this file
does not (yet) establish" list.
-/
import Mathlib

/-!
# The hexacode `[6,3,4]₄`: the proof chain's second information-set toy

This module implements the §9 suggestion of
`chi_nu_test/proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md`: upstream the one
genuinely reusable artifact of the `dula/` audit — a sorry-free hexacode
formalization — into `formal/` as a *second* information-set toy beside
`Rule90Cylinder.lean`, and prove in Lean the statements the source file
explicitly left open (its "What this file does not (yet) establish" list,
kept verbatim in the ported docstring below).

## Setting

The **hexacode** is the 3-dimensional linear code of length 6 over the
four-element field `F4 = {0, 1, ω, ω'}`, spanned by the rows of

    G = ⎡ 1  0  0  1  1  ω  ⎤
        ⎢ 0  1  0  1  ω  1  ⎥
        ⎣ 0  0  1  ω  1  1  ⎦ .

The ported part (attribution header above; everything up to the
`[formal-v4 additions]` marker) supplies the concrete field `F4` with
decidable equality and explicit Cayley tables, the code as
`Set.range codewordOf` and as a `Submodule`, the cardinality
`Hexacode.hexacodeSet_card : Nat.card hexacodeSet = 64` — which, being
`4³`, already *is* the "dimension 3" statement in counting form — the
Hamming `weight`, and the Hermitian inner product `hermInner`.

## Results (new, below the `[formal-v4 additions]` marker)

* `hexacode_min_weight` / `hexacode_weight_four_attained` — every nonzero
  message encodes to Hamming weight `≥ 4`, and weight `4` is attained. With
  the ported cardinality `64 = 4³` this certifies the full `[6,3,4]₄`
  parameter claim in Lean (the source file had only a Python sanity check
  for `d = 4`). Since `d = 4 = 6 − 3 + 1` meets the Singleton bound, the
  hexacode is **MDS** (maximum distance separable).
* `three_subset_information_set` — **the MDS information-set theorem, the
  OPH payoff (§9)**: *every* 3-subset of the 6 coordinates determines the
  message, hence the whole codeword — proved from the minimum distance by
  support counting, not by enumeration. Contrast the Rule-90 cylinder
  carrier (`Rule90Cylinder.lean`), where decodability is
  *geometry-sensitive*: a width-2 **timelike** tube of sufficient duration
  reconstructs (`tube_information_set`), while **no** proper *spacelike*
  subset of a row ever does (`spacelike_proper_subset_fails`). The hexacode
  sits at the opposite, geometry-blind extreme: any 3 of the 6 coordinates
  reconstruct, no matter which. The two toys bracket the
  "which subsets decode?" question the proof chain's carrier theorems
  live on.
* `two_subset_not_information_set` — sharpness of "3": an explicit 2-subset
  and a pair of distinct messages agreeing there (a weight-4 codeword
  vanishes on exactly two coordinates).
* `hexacode_self_dual` — Hermitian self-duality: `⟨u, w⟩_H = 0` for all
  codewords `u, w` (the source file's declared future work #2, previously
  "verified numerically" only).
* `hexacode_weights_only` / `hexacode_weight_distribution` — `[formal-v5]`
  the **full weight distribution** `A₀ = 1, A₄ = 45, A₆ = 18` (weight
  enumerator `x⁶ + 45x²y⁴ + 18y⁶`), the numeric half of the source file's
  Python check, kernel-checked. Every hexacode claim of the source file is
  now closed in Lean.

Axioms: standard (`propext`, `Classical.choice`, `Quot.sound`) at most —
see the audit at the end of the file. No `sorry`, no new axioms, no
`native_decide` (plain kernel `decide` only, over the 64 messages resp.
64 × 64 message pairs).
-/

namespace OPHProofChain.HexacodePort

/-!
# The field 𝔽₄ and the hexacode

This file gives a concrete formalization of the field `F4` with four
elements and the **hexacode** `[6, 3, 4]_4`, a 3-dimensional linear code
of length 6 over `F4` with minimum Hamming distance 4.

## Why a concrete construction?

Mathlib provides `GaloisField 2 2`, which is abstractly the splitting
field of `X^4 - X` over `ZMod 2`. That formulation is correct but heavy:
elements are equivalence classes of polynomials and operations are
defined through a quotient. For the hexacode and the eventual Coxeter–Todd
construction, we want **decidable equality** and **explicit Cayley
tables**, so that membership in the hexacode and weight enumeration are
computable.

We therefore define `F4` as a concrete 4-element inductive type with
hand-written addition and multiplication tables, and verify the
ring/field axioms by `decide`.

## What this file establishes

* `F4` is a commutative ring with decidable equality, and a `Field`.
* Frobenius `x ↦ x²` is the nontrivial field automorphism of `F4`,
  satisfies `conj² = id`, is additive and multiplicative.
* The **hexacode** is the row span of an explicit `3 × 6` generator
  matrix over `F4`.
* It is closed under addition and scalar multiplication (a `Submodule`).
* It contains exactly `64 = 4³` codewords (proved via injectivity of
  the encoding map).
* Definitions of Hamming weight and the Hermitian inner product
  (`hermInner`) on `(F4)⁶`, with additive-linearity in the first
  argument.

## What this file does not (yet) establish

* The minimum nonzero codeword weight is `4` (the `[6,3,4]_4` parameter).
  The Python sanity-check confirms this (and the full weight
  distribution `A_4 = 45`, `A_6 = 18`) but a Lean proof requires
  enumerating the `63` nonzero codewords; we leave it for a follow-up.
* Hermitian self-duality `⟨u, v⟩_H = 0` for all `u, v` in the hexacode.
  Verified numerically; not yet proved in Lean.
* The role of the hexacode in constructing `K₁₂` (the Coxeter–Todd
  lattice). This is the goal of a separate forthcoming file.

**No `sorry`s in this file.** Properties marked "not yet established"
above are stated honestly as future work, not slipped in as `sorry`.

## References

* J. H. Conway, N. J. A. Sloane, *Sphere Packings, Lattices and Groups*,
  3rd ed., Springer 1999, Chapter 3.
* R. T. Curtis, *The Art of Working with the Mathieu Group M24*, CUP
  2024, Chapter 6.
-/

/-- The field `F4` of four elements, as a concrete inductive type. -/
inductive F4 : Type
  | zero : F4
  | one  : F4
  | ω    : F4
  | ω'   : F4    -- this is ω², written `ω'` to keep notation ASCII-friendly
  deriving DecidableEq, Repr

namespace F4

/-! ### Cayley tables -/

/-- Addition in `F4`. In characteristic 2, `x + x = 0` and the table is
symmetric; `ω + 1 = ω'` is the defining relation. -/
def add : F4 → F4 → F4
  | zero, x    => x
  | x,    zero => x
  | one,  one  => zero
  | one,  ω    => ω'
  | one,  ω'   => ω
  | ω,    one  => ω'
  | ω,    ω    => zero
  | ω,    ω'   => one
  | ω',   one  => ω
  | ω',   ω    => one
  | ω',   ω'   => zero

/-- Multiplication in `F4`. The nonzero elements form a cyclic group
of order 3 generated by `ω`, with `ω * ω = ω'` and `ω * ω' = 1`. -/
def mul : F4 → F4 → F4
  | zero, _    => zero
  | _,    zero => zero
  | one,  x    => x
  | x,    one  => x
  | ω,    ω    => ω'
  | ω,    ω'   => one
  | ω',   ω    => one
  | ω',   ω'   => ω

/-- Additive inverse: in characteristic 2, `neg x = x`. -/
def neg (x : F4) : F4 := x

/-! ### Instances -/

instance : Zero F4 := ⟨zero⟩
instance : One F4 := ⟨one⟩
instance : Add F4 := ⟨add⟩
instance : Mul F4 := ⟨mul⟩
instance : Neg F4 := ⟨neg⟩
instance : Sub F4 := ⟨fun x y => add x (neg y)⟩

/-- `F4` has exactly four elements. -/
instance : Fintype F4 where
  elems := {zero, one, ω, ω'}
  complete := by intro x; cases x <;> decide

/-! ### Commutative ring structure -/

instance : CommRing F4 where
  add := (· + ·)
  add_assoc     := by decide
  zero          := 0
  zero_add      := by decide
  add_zero      := by decide
  add_comm      := by decide
  neg           := Neg.neg
  neg_add_cancel := by decide
  mul           := (· * ·)
  one           := 1
  one_mul       := by decide
  mul_one       := by decide
  mul_assoc     := by decide
  left_distrib  := by decide
  right_distrib := by decide
  mul_comm      := by decide
  zero_mul      := by decide
  mul_zero      := by decide
  zsmul         := zsmulRec
  nsmul         := nsmulRec
  sub_eq_add_neg := by decide

/-! ### Field structure

Every nonzero element has an inverse; in our cyclic group of order 3,
`ω⁻¹ = ω'`. We give an explicit `inv` and verify the field axioms by
`decide`. -/

/-- Inverse: `0⁻¹ := 0`, `1⁻¹ = 1`, `ω⁻¹ = ω'`, `(ω')⁻¹ = ω`. -/
def inv : F4 → F4
  | zero => zero
  | one  => one
  | ω    => ω'
  | ω'   => ω

instance : Inv F4 := ⟨inv⟩

instance : Field F4 where
  inv := Inv.inv
  exists_pair_ne := ⟨zero, one, by decide⟩
  mul_inv_cancel := by intro x hx; cases x <;> first | (exact absurd rfl hx) | decide
  inv_zero := rfl
  nnqsmul := _
  nnqsmul_def := fun _ _ => rfl
  qsmul := _
  qsmul_def := fun _ _ => rfl

/-! ### Field characteristic and cardinality -/

theorem card_eq_four : Fintype.card F4 = 4 := by decide

/-- `F4` has characteristic 2: `1 + 1 = 0`. -/
theorem one_add_one : (1 : F4) + 1 = 0 := by decide

/-! ### Frobenius / Hermitian conjugation

The map `x ↦ x²` is the nontrivial field automorphism of `F4` (Frobenius).
It sends `ω ↔ ω'` and fixes `0, 1`. This will be the "Hermitian
conjugation" used for self-duality of the hexacode. -/

/-- The Frobenius `x ↦ x^2`, which is the nontrivial Galois automorphism. -/
def conj (x : F4) : F4 := x * x

@[simp] theorem conj_zero : conj zero = zero := by decide
@[simp] theorem conj_one  : conj one  = one  := by decide
@[simp] theorem conj_omega : conj ω = ω' := by decide
@[simp] theorem conj_omega' : conj ω' = ω := by decide

/-- Frobenius is an involution: `(x^2)^2 = x` in `F4`. -/
theorem conj_conj (x : F4) : conj (conj x) = x := by cases x <;> decide

/-- Frobenius is additive: `(x + y)^2 = x^2 + y^2` (characteristic 2). -/
theorem conj_add (x y : F4) : conj (x + y) = conj x + conj y := by
  cases x <;> cases y <;> decide

/-- Frobenius is multiplicative. -/
theorem conj_mul (x y : F4) : conj (x * y) = conj x * conj y := by
  cases x <;> cases y <;> decide

end F4

/-! ## The hexacode

The hexacode is the row span of the generator matrix
```
G = ⎡ 1  0  0  1  1  ω  ⎤
    ⎢ 0  1  0  1  ω  1  ⎥
    ⎣ 0  0  1  ω  1  1  ⎦
```
as a subspace of `(F4)⁶`. Equivalently it is the set
`{ (a, b, c, f(1), f(ω), f(ω²)) : f(x) = ax² + bx + c, a, b, c ∈ F4 }`,
but we use the matrix form for direct computation.
-/

namespace Hexacode

open F4

/-- The generator matrix `G : Matrix (Fin 3) (Fin 6) F4`. -/
def G : Matrix (Fin 3) (Fin 6) F4 :=
  !![1, 0, 0, 1, 1, ω;
     0, 1, 0, 1, ω, 1;
     0, 0, 1, ω, 1, 1]

/-- A codeword of the hexacode: the row-span vector `vᵀ · G`. -/
def codewordOf (v : Fin 3 → F4) : Fin 6 → F4 :=
  fun j => ∑ i, v i * G i j

/-- The hexacode as a set: all vectors of the form `codewordOf v`. -/
def hexacodeSet : Set (Fin 6 → F4) :=
  Set.range codewordOf

/-! ### Closure under addition and scalar multiplication

These follow from `codewordOf` being a linear map. We prove them
directly to keep things explicit. -/

/-- `codewordOf` is additive in `v`. -/
theorem codewordOf_add (v w : Fin 3 → F4) :
    codewordOf (v + w) = codewordOf v + codewordOf w := by
  funext j
  simp only [codewordOf, Pi.add_apply]
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro i _
  ring

/-- `codewordOf` respects scalar multiplication by elements of `F4`. -/
theorem codewordOf_smul (c : F4) (v : Fin 3 → F4) :
    codewordOf (c • v) = c • codewordOf v := by
  funext j
  simp only [codewordOf, Pi.smul_apply, smul_eq_mul]
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i _
  ring

/-- The hexacode is closed under addition. -/
theorem hexacodeSet_add_mem {x y : Fin 6 → F4}
    (hx : x ∈ hexacodeSet) (hy : y ∈ hexacodeSet) :
    x + y ∈ hexacodeSet := by
  obtain ⟨v, hv⟩ := hx
  obtain ⟨w, hw⟩ := hy
  refine ⟨v + w, ?_⟩
  rw [codewordOf_add, hv, hw]

/-- The hexacode contains the zero vector. -/
theorem hexacodeSet_zero_mem : (0 : Fin 6 → F4) ∈ hexacodeSet := by
  refine ⟨0, ?_⟩
  funext j
  simp [codewordOf]

/-- The hexacode is closed under scalar multiplication by `F4`. -/
theorem hexacodeSet_smul_mem {c : F4} {x : Fin 6 → F4}
    (hx : x ∈ hexacodeSet) :
    c • x ∈ hexacodeSet := by
  obtain ⟨v, hv⟩ := hx
  refine ⟨c • v, ?_⟩
  rw [codewordOf_smul, hv]

/-! ### The hexacode as a submodule -/

/-- The hexacode as a submodule of `(F4)⁶`. -/
def hexacode : Submodule F4 (Fin 6 → F4) where
  carrier := hexacodeSet
  zero_mem' := hexacodeSet_zero_mem
  add_mem' := hexacodeSet_add_mem
  smul_mem' _c _ hx := hexacodeSet_smul_mem hx

/-! ### Cardinality: 64 codewords

We show the hexacode has exactly `4^3 = 64` elements. The argument:

* `codewordOf : (Fin 3 → F4) → (Fin 6 → F4)` is injective (first three
  columns of `G` are the identity, so `v` is recovered as the first
  three coordinates of `codewordOf v`).
* The hexacode is `Set.range codewordOf` by definition.
* So `|hexacode| = |Fin 3 → F4| = 4^3 = 64`.

To express this cleanly we work at the level of the underlying set
rather than the `Submodule` carrier; the equivalence is immediate. -/

/-- The map `codewordOf : (Fin 3 → F4) → (Fin 6 → F4)` is injective.

The first three columns of `G` form the identity matrix, so `v i` can
be recovered as the `i`-th coordinate of `codewordOf v`. -/
theorem codewordOf_injective : Function.Injective codewordOf := by
  intro v w h
  funext i
  -- Show that for any u, the i-th coordinate of codewordOf u equals u i.
  have key : ∀ (u : Fin 3 → F4) (k : Fin 3),
      codewordOf u ⟨k.val, by omega⟩ = u k := by
    intro u k
    simp only [codewordOf, G]
    fin_cases k <;>
      simp [Fin.sum_univ_three, Matrix.cons_val', Matrix.cons_val_zero,
            Matrix.cons_val_one, Matrix.empty_val',
            Matrix.cons_val_fin_one]
  have h1 := congr_fun h ⟨i.val, by omega⟩
  rw [key v i, key w i] at h1
  exact h1

/-- The hexacode (as a set) is in bijection with `Fin 3 → F4`. -/
noncomputable def codewordEquiv : (Fin 3 → F4) ≃ hexacodeSet :=
  Equiv.ofInjective codewordOf codewordOf_injective

/-- The hexacode has exactly `4^3 = 64` codewords (as a set). -/
theorem hexacodeSet_card : Nat.card hexacodeSet = 64 := by
  rw [Nat.card_congr codewordEquiv.symm]
  simp [Nat.card_eq_fintype_card, F4.card_eq_four]

/-! ### Hamming weight

We define the Hamming weight (number of nonzero coordinates) for use
in stating the minimum-distance property `d = 4`. We do not prove
`d = 4` in this file; that requires enumerating the 63 nonzero
codewords. We provide the definition and one easy lemma. -/

/-- Hamming weight: the number of nonzero coordinates. -/
def weight (x : Fin 6 → F4) : ℕ :=
  (Finset.univ.filter (fun i => x i ≠ 0)).card

/-- The zero vector has weight zero. -/
@[simp] theorem weight_zero : weight (fun _ => (0 : F4)) = 0 := by
  simp [weight]

/-! ### Hermitian inner product

For the hexacode's self-duality (to be proved later), we need the
Hermitian inner product
  ⟨x, y⟩_H := ∑ᵢ xᵢ · conj(yᵢ)
on `(F4)⁶`. -/

/-- The Hermitian inner product on `(F4)⁶`. -/
def hermInner (x y : Fin 6 → F4) : F4 :=
  ∑ i, x i * F4.conj (y i)

/-- The Hermitian inner product is `F4`-linear in the first argument. -/
theorem hermInner_add_left (x y z : Fin 6 → F4) :
    hermInner (x + y) z = hermInner x z + hermInner y z := by
  simp only [hermInner, Pi.add_apply]
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro i _
  ring

end Hexacode

/-! ## [formal-v4 additions]

Everything above this marker is the verbatim port (see the attribution
header at the top of the file). Everything below is new in this tree
(2026-07-06): it closes the ported file's own "What this file does not
(yet) establish" list — minimum distance and Hermitian self-duality —
and adds the proof-chain reading (§9): the MDS information-set theorem
with its sharpness witness. -/

namespace Hexacode

/-- `codewordOf` respects subtraction — companion to the ported
`codewordOf_add`, same proof shape. (Over `F4`, characteristic 2 makes
subtraction *equal* to addition, but the direct proof keeps the statement
independent of that.) -/
theorem codewordOf_sub (v w : Fin 3 → F4) :
    codewordOf (v - w) = codewordOf v - codewordOf w := by
  funext j
  simp only [codewordOf, Pi.sub_apply]
  rw [← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro i _
  ring

end Hexacode

/-! ### Minimum distance: the full `[6,3,4]₄` parameter claim

The source file's declared future work #1. Since the encoder is injective
(ported `codewordOf_injective`), quantifying over the 64 messages *is*
quantifying over the codewords, so a plain kernel `decide` over
`Fin 3 → F4` settles it — no `native_decide` anywhere in this file.
Together with the ported `hexacodeSet_card` (`64 = 4³` codewords, i.e.
dimension 3 in counting form) this certifies the full `[6,3,4]₄`
parameter triple in Lean; the source file had only a Python sanity check
for `d = 4`. -/

/-- **Minimum weight 4.** Every nonzero message encodes to a codeword of
Hamming weight at least 4; equivalently (by linearity), the minimum
distance of the hexacode is at least 4. -/
theorem hexacode_min_weight :
    ∀ v : Fin 3 → F4, v ≠ 0 → 4 ≤ Hexacode.weight (Hexacode.codewordOf v) := by
  decide

/-- **Weight 4 is attained** — by the sum of the first two generator rows,
`codewordOf ![1,1,0] = (1, 1, 0, 0, ω', ω')` — so the minimum distance is
exactly 4. -/
theorem hexacode_weight_four_attained :
    ∃ v : Fin 3 → F4, Hexacode.weight (Hexacode.codewordOf v) = 4 :=
  ⟨![1, 1, 0], by decide⟩

/-! ### The MDS information-set theorem (the OPH payoff, §9)

`d = 4` meets the Singleton bound `d ≤ n − k + 1 = 6 − 3 + 1`, and the MDS
property in information-set form says: *every* `k`-subset of coordinates
determines the message. This is proved **from** the minimum distance — the
point of the exercise — not by a second brute-force enumeration: two
messages agreeing on a 3-subset `S` have a difference codeword supported
outside `S`, hence of weight `≤ 3 < 4`, forcing the difference to be zero.

Contrast with `Rule90Cylinder.lean`: there, decodability of a subset
depends on its spacetime *geometry* (timelike tubes of the right duration
reconstruct; proper spacelike subsets never do). Here reconstruction is
completely geometry-blind — any 3 of the 6 coordinates work. -/

/-- **Every 3-subset of coordinates is an information set.** If two
messages produce codewords agreeing on any `S` with `|S| ≥ 3`, the
messages are equal. Proved from `hexacode_min_weight` by support counting:
the difference codeword vanishes on `S`, so its support lives in `Sᶜ` and
has cardinality `≤ 6 − |S| ≤ 3 < 4`. -/
theorem three_subset_information_set (S : Finset (Fin 6)) (hS : 3 ≤ S.card)
    {v w : Fin 3 → F4} (h : ∀ i ∈ S, Hexacode.codewordOf v i = Hexacode.codewordOf w i) :
    v = w := by
  by_contra hne
  have hd : v - w ≠ 0 := sub_ne_zero.mpr hne
  have hmin : 4 ≤ Hexacode.weight (Hexacode.codewordOf (v - w)) :=
    hexacode_min_weight (v - w) hd
  -- the difference codeword vanishes on S …
  have hvanish : ∀ i ∈ S, Hexacode.codewordOf (v - w) i = 0 := by
    intro i hi
    rw [Hexacode.codewordOf_sub, Pi.sub_apply, h i hi, sub_self]
  -- … so its support avoids S, giving weight ≤ 6 − |S|
  have hcard : Hexacode.weight (Hexacode.codewordOf (v - w)) ≤ 6 - S.card := by
    have hsupp :
        (Finset.univ.filter fun i => Hexacode.codewordOf (v - w) i ≠ 0) ⊆ Sᶜ := by
      intro i hi
      rw [Finset.mem_filter] at hi
      rw [Finset.mem_compl]
      exact fun hiS => hi.2 (hvanish i hiS)
    calc Hexacode.weight (Hexacode.codewordOf (v - w))
        = (Finset.univ.filter fun i => Hexacode.codewordOf (v - w) i ≠ 0).card := rfl
      _ ≤ (Sᶜ).card := Finset.card_le_card hsupp
      _ = 6 - S.card := by rw [Finset.card_compl, Fintype.card_fin]
  omega

/-- **Sharpness: 2-subsets are not information sets.** The weight-4
codeword `codewordOf ![1,1,0] = (1, 1, 0, 0, ω', ω')` vanishes on
coordinates `{2, 3}`, so the distinct messages `![1,1,0]` and `0` agree
there. (Weight 4 means a codeword is zero on exactly two coordinates, so
some 2-subset always fails; one explicit witness suffices for sharpness.) -/
theorem two_subset_not_information_set :
    ∃ S : Finset (Fin 6), S.card = 2 ∧
      ∃ v w : Fin 3 → F4, v ≠ w ∧
        ∀ i ∈ S, Hexacode.codewordOf v i = Hexacode.codewordOf w i :=
  ⟨{2, 3}, by decide, ![1, 1, 0], 0, by decide, by decide⟩

/-! ### Hermitian self-duality

The source file's declared future work #2 (previously "verified
numerically"). The code has `4³ = 64` elements in an ambient space of
`4⁶`, so being self-orthogonal it is genuinely self-*dual*
(`dim + dim = 6` with the Hermitian form nondegenerate). We first check
the message-level statement — a plain `decide` over the `64 × 64` message
pairs — then transport it to the set-level statement through
`Set.range`. -/

set_option maxRecDepth 8192 in
/-- Message-level self-orthogonality: any two encoded messages are
Hermitian-orthogonal. Plain kernel `decide` over the 4096 message pairs
(the nested 64 × 64 fold needs more recursion depth than the default 512,
but no `native_decide` and no extra axioms). -/
theorem hermInner_codewordOf_eq_zero :
    ∀ a b : Fin 3 → F4,
      Hexacode.hermInner (Hexacode.codewordOf a) (Hexacode.codewordOf b) = 0 := by
  decide

/-- **Hermitian self-duality of the hexacode**: `⟨u, w⟩_H = 0` for all
codewords `u, w`. -/
theorem hexacode_self_dual :
    ∀ u ∈ Hexacode.hexacodeSet, ∀ w ∈ Hexacode.hexacodeSet,
      Hexacode.hermInner u w = 0 := by
  rintro u ⟨a, rfl⟩ w ⟨b, rfl⟩
  exact hermInner_codewordOf_eq_zero a b

/-! ### The full weight distribution — `[formal-v5]`

The ported file's "does not (yet) establish" list quoted its Python check
of the weight distribution (`A₄ = 45, A₆ = 18`) alongside the minimum
distance. The minimum distance was closed in v4 (above); this closes the
rest: the complete weight enumerator

    W(x, y) = x⁶ + 45·x²y⁴ + 18·y⁶

at the message level (the encoder is injective — ported
`codewordOf_injective` — so message counts *are* codeword counts). Plain
kernel `decide` over the 64 messages; no `native_decide`. With this, every
numerical claim of the source file about the hexacode itself is
kernel-checked (its remaining open item, the `K₁₂` lattice construction,
is out of scope for this tree). -/

set_option maxRecDepth 8192 in
/-- Only weights `0`, `4`, `6` occur in the hexacode (the support of the
weight enumerator). -/
theorem hexacode_weights_only :
    ∀ v : Fin 3 → F4, Hexacode.weight (Hexacode.codewordOf v) = 0 ∨
      Hexacode.weight (Hexacode.codewordOf v) = 4 ∨
      Hexacode.weight (Hexacode.codewordOf v) = 6 := by
  decide

set_option maxRecDepth 8192 in
/-- **The full weight distribution `A₀ = 1, A₄ = 45, A₆ = 18`** (summing to
the ported cardinality `64`): the source file's Python-checked
distribution, now kernel-checked. -/
theorem hexacode_weight_distribution :
    ((Finset.univ.filter fun v : Fin 3 → F4 =>
      Hexacode.weight (Hexacode.codewordOf v) = 0).card = 1) ∧
    ((Finset.univ.filter fun v : Fin 3 → F4 =>
      Hexacode.weight (Hexacode.codewordOf v) = 4).card = 45) ∧
    ((Finset.univ.filter fun v : Fin 3 → F4 =>
      Hexacode.weight (Hexacode.codewordOf v) = 6).card = 18) := by
  refine ⟨?_, ?_, ?_⟩ <;> decide

/-! ### Axiom audit -/
#print axioms hexacode_min_weight
#print axioms three_subset_information_set
#print axioms hexacode_self_dual
#print axioms Hexacode.hexacodeSet_card
#print axioms hexacode_weights_only
#print axioms hexacode_weight_distribution

end OPHProofChain.HexacodePort
