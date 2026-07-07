import Mathlib
import OPHProofChain.CollarGate

/-!
# T35 [formal-v8] — a surface for the twelve ports (closes the F24 residue)

**Provenance.** chi_nu_test original (formal-v8 campaign). The second audit
pass (F24 of `OPH_PROOF_CHAIN_HOLES.md`) observed that
`CollarGate.sphere_defect_count` consumes three *assumed equations* over
bare `(V E F : ℕ, deg : Fin V → ℕ)` — "any all-triangle closed surface"
described structure that was absent from the tree. This module supplies the
structure and discharges the equations:

* `TriangulatedSphere` — finite vertices, triangular faces, an edge set
  with the closed-surface conditions (every edge of card 2 in **exactly two
  faces**, every face carrying **exactly three** edges), and Euler
  characteristic 2 — the last is the *named topological input*, exactly as
  the v5 docstring bills it (combinatorics cannot know the genus);
* `edges_eq_biUnion` — the edge set is forced: it provably equals the set
  of all 2-subsets of faces (so listing it as data adds no freedom);
* `three_faces_eq_two_edges` — `3F = 2E`, **proven** by double counting
  (was: hypothesis `triangles` of `sphere_defect_count`);
* `degree_sum_eq_two_edges` — the handshake `∑ deg v = 2E`, **proven** by
  double counting (was: hypothesis `degree_sum`);
* `defect_count` / `twelve_ports` — the v5 theorems
  `sphere_defect_count` / `twelve_unit_defects` consumed **unchanged**,
  their hypotheses now discharged by the structure (transport along
  `Fintype.equivFin`);
* `icosahedron` — a concrete instance (12 vertices, 20 faces, 30 edges,
  every vertex of degree 5), all fields kernel-`decide`d; its twelve ports
  are `icosahedron_ports`.

What stays physics is unchanged and unweakened: **L0** — that the collar's
transverse structure *is* such a complex — remains the named postulate;
this module removes only the mathematical debt (the equations are now
facts *of* a surface).

Axioms: standard (`propext`, `Classical.choice`, `Quot.sound`); no `sorry`,
no `native_decide`.
-/

namespace OPHProofChain.CollarGate

open scoped BigOperators

/-! ## Double counting -/

/-- Counting an incidence relation two ways. -/
theorem double_count {α β : Type*} (s : Finset α) (t : Finset β)
    (r : α → β → Prop) [∀ a b, Decidable (r a b)] :
    ∑ a ∈ s, (t.filter fun b => r a b).card
      = ∑ b ∈ t, (s.filter fun a => r a b).card := by
  simp_rw [Finset.card_filter]
  exact Finset.sum_comm

/-! ## The structure -/

/-- A combinatorial closed triangulated sphere: finitely many vertices,
    triangular faces, and an edge set subject to the closed-surface
    conditions — every edge is a 2-set lying in **exactly two** faces, and
    every face carries **exactly three** edges (equivalently, all its
    2-subsets: see `edges_eq_biUnion`, which shows the edge set is forced
    by the faces). `euler` is the *named topological input*: combinatorics
    alone cannot know the genus, exactly as the chain's L0 discussion bills
    it. -/
structure TriangulatedSphere where
  /-- The vertex type. -/
  Vert : Type
  [instFin : Fintype Vert]
  [instDec : DecidableEq Vert]
  /-- The faces: 3-element subsets of vertices. -/
  faces : Finset (Finset Vert)
  /-- The edges: 2-element subsets of vertices. -/
  edges : Finset (Finset Vert)
  face_card : ∀ f ∈ faces, f.card = 3
  edge_card : ∀ e ∈ edges, e.card = 2
  /-- Closedness: every edge lies in exactly two faces. -/
  edge_two_faces : ∀ e ∈ edges, (faces.filter fun f => e ⊆ f).card = 2
  /-- Every face carries exactly three edges. -/
  face_three_edges : ∀ f ∈ faces, (edges.filter fun e => e ⊆ f).card = 3
  /-- Euler characteristic 2 — the topological input. -/
  euler : (Fintype.card Vert : ℤ) - edges.card + faces.card = 2

attribute [instance] TriangulatedSphere.instFin TriangulatedSphere.instDec

namespace TriangulatedSphere

variable (S : TriangulatedSphere)

/-- The degree of a vertex: the number of edges through it. -/
def deg (v : S.Vert) : ℕ := (S.edges.filter fun e => v ∈ e).card

/-- **The edge set is forced by the faces**: it equals the set of all
    2-subsets of faces. (Listing the edges as data therefore adds no
    freedom — the fields pin them exactly.) -/
theorem edges_eq_biUnion :
    S.edges = S.faces.biUnion (Finset.powersetCard 2) := by
  classical
  ext e
  simp only [Finset.mem_biUnion, Finset.mem_powersetCard]
  constructor
  · intro he
    have h2 := S.edge_two_faces e he
    have hpos : 0 < (S.faces.filter fun f => e ⊆ f).card := by omega
    obtain ⟨f, hf⟩ := Finset.card_pos.mp hpos
    rw [Finset.mem_filter] at hf
    exact ⟨f, hf.1, hf.2, S.edge_card e he⟩
  · rintro ⟨f, hf, hef, hec⟩
    -- the filter of edges inside `f` has card 3 = #(2-subsets of `f`),
    -- and is contained in them, so it IS them
    have hsub : (S.edges.filter fun e' => e' ⊆ f) ⊆ f.powersetCard 2 := by
      intro e' he'
      rw [Finset.mem_filter] at he'
      rw [Finset.mem_powersetCard]
      exact ⟨he'.2, S.edge_card e' he'.1⟩
    have hcard : (f.powersetCard 2).card = 3 := by
      rw [Finset.card_powersetCard, S.face_card f hf]
      decide
    have heq : (S.edges.filter fun e' => e' ⊆ f) = f.powersetCard 2 :=
      Finset.eq_of_subset_of_card_le hsub
        (by rw [hcard, S.face_three_edges f hf])
    have hmem : e ∈ f.powersetCard 2 :=
      Finset.mem_powersetCard.mpr ⟨hef, hec⟩
    rw [← heq, Finset.mem_filter] at hmem
    exact hmem.1

/-! ## The two counting identities — the audit's assumed equations, proven -/

/-- **`3F = 2E`, proven.** Each face carries exactly three edges; each edge
    lies in exactly two faces. -/
theorem three_faces_eq_two_edges :
    3 * S.faces.card = 2 * S.edges.card := by
  calc 3 * S.faces.card
      = ∑ f ∈ S.faces, 3 := by
        rw [Finset.sum_const, smul_eq_mul, mul_comm]
    _ = ∑ f ∈ S.faces, (S.edges.filter fun e => e ⊆ f).card :=
        (Finset.sum_congr rfl S.face_three_edges).symm
    _ = ∑ e ∈ S.edges, (S.faces.filter fun f => e ⊆ f).card :=
        double_count S.faces S.edges (fun f e => e ⊆ f)
    _ = ∑ e ∈ S.edges, 2 := Finset.sum_congr rfl S.edge_two_faces
    _ = 2 * S.edges.card := by
        rw [Finset.sum_const, smul_eq_mul, mul_comm]

/-- **`∑ deg = 2E`, proven.** Each edge has exactly two endpoints. -/
theorem degree_sum_eq_two_edges :
    ∑ v, S.deg v = 2 * S.edges.card := by
  unfold deg
  calc ∑ v, (S.edges.filter fun e => v ∈ e).card
      = ∑ e ∈ S.edges, (Finset.univ.filter fun v => v ∈ e).card :=
        double_count Finset.univ S.edges (fun v e => v ∈ e)
    _ = ∑ e ∈ S.edges, e.card := by
        refine Finset.sum_congr rfl fun e _ => ?_
        congr 1
        ext v
        simp
    _ = ∑ e ∈ S.edges, 2 :=
        Finset.sum_congr rfl fun e he => S.edge_card e he
    _ = 2 * S.edges.card := by
        rw [Finset.sum_const, smul_eq_mul, mul_comm]

/-! ## The v5 theorems, consumed with their hypotheses discharged -/

/-- **Combinatorial Gauss–Bonnet ON THE STRUCTURE**: total defect 12, no
    assumed equations — `sphere_defect_count` consumed via transport along
    `Fintype.equivFin`, with `3F = 2E` and the handshake supplied by the
    counting theorems and Euler by the structure. -/
theorem defect_count : ∑ v, ((6 : ℤ) - S.deg v) = 12 := by
  classical
  set n := Fintype.card S.Vert with hn
  set e : Fin n ≃ S.Vert := (Fintype.equivFin S.Vert).symm with he
  have h := sphere_defect_count n S.edges.card S.faces.card
    (fun i => S.deg (e i))
    (by rw [hn]; exact_mod_cast S.euler)
    S.three_faces_eq_two_edges
    (by rw [Equiv.sum_comp e (fun v => S.deg v)]
        exact S.degree_sum_eq_two_edges)
  rw [Equiv.sum_comp e (fun v => ((6 : ℤ) - S.deg v))] at h
  exact h

/-- **Exactly twelve ports, on the structure**: unit defects (degrees 5/6)
    force exactly twelve degree-5 vertices — `twelve_unit_defects` consumed
    with all three equations discharged. -/
theorem twelve_ports (hdeg : ∀ v, S.deg v = 5 ∨ S.deg v = 6) :
    (Finset.univ.filter fun v => S.deg v = 5).card = 12 := by
  classical
  set n := Fintype.card S.Vert with hn
  set e : Fin n ≃ S.Vert := (Fintype.equivFin S.Vert).symm with he
  have h := twelve_unit_defects n S.edges.card S.faces.card
    (fun i => S.deg (e i))
    (by rw [hn]; exact_mod_cast S.euler)
    S.three_faces_eq_two_edges
    (by rw [Equiv.sum_comp e (fun v => S.deg v)]
        exact S.degree_sum_eq_two_edges)
    (fun i => hdeg (e i))
  rw [← h]
  -- transport the filtered count along the equivalence
  refine Finset.card_bij (fun v _ => e.symm v) ?_ ?_ ?_
  · intro v hv
    rw [Finset.mem_filter] at hv ⊢
    refine ⟨Finset.mem_univ _, ?_⟩
    simpa using hv.2
  · intro v₁ _ v₂ _ hv
    exact e.symm.injective hv
  · intro i hi
    rw [Finset.mem_filter] at hi
    refine ⟨e i, ?_, by simp⟩
    rw [Finset.mem_filter]
    exact ⟨Finset.mem_univ _, hi.2⟩

end TriangulatedSphere

/-! ## The indexed constructor

Kernel reduction of `Finset (Finset _)` filters goes through the multiset
quotient's permutation decisions and is catastrophically deep, so concrete
instances are built from *indexed* data: a face family `Fin F → Finset Vert`
and an edge family `Fin E → Finset Vert`, all side conditions being counts
over the **index** types — single-level `Finset` computations the kernel
handles easily. The translation to the structure's `Finset`-of-`Finset`
fields happens here, once, abstractly. -/

/-- Build a `TriangulatedSphere` from injective indexed families of faces
    and edges with index-level counting conditions. -/
def TriangulatedSphere.ofFn {V : Type} [Fintype V] [DecidableEq V] {nF nE : ℕ}
    (fv : Fin nF → Finset V) (ev : Fin nE → Finset V)
    (hfinj : Function.Injective fv) (heinj : Function.Injective ev)
    (hfcard : ∀ f, (fv f).card = 3) (hecard : ∀ e, (ev e).card = 2)
    (hef : ∀ e, (Finset.univ.filter fun f => ev e ⊆ fv f).card = 2)
    (hfe : ∀ f, (Finset.univ.filter fun e => ev e ⊆ fv f).card = 3)
    (heuler : (Fintype.card V : ℤ) - nE + nF = 2) :
    TriangulatedSphere where
  Vert := V
  faces := Finset.univ.image fv
  edges := Finset.univ.image ev
  face_card := by
    intro f hf
    obtain ⟨i, _, rfl⟩ := Finset.mem_image.mp hf
    exact hfcard i
  edge_card := by
    intro e he
    obtain ⟨i, _, rfl⟩ := Finset.mem_image.mp he
    exact hecard i
  edge_two_faces := by
    intro e he
    obtain ⟨i, _, rfl⟩ := Finset.mem_image.mp he
    have himg : (Finset.univ.image fv).filter (fun f => ev i ⊆ f)
        = (Finset.univ.filter fun f => ev i ⊆ fv f).image fv := by
      rw [Finset.filter_image]
    rw [himg, Finset.card_image_of_injective _ hfinj]
    exact hef i
  face_three_edges := by
    intro f hf
    obtain ⟨i, _, rfl⟩ := Finset.mem_image.mp hf
    have himg : (Finset.univ.image ev).filter (fun e => e ⊆ fv i)
        = (Finset.univ.filter fun e => ev e ⊆ fv i).image ev := by
      rw [Finset.filter_image]
    rw [himg, Finset.card_image_of_injective _ heinj]
    exact hfe i
  euler := by
    rw [Finset.card_image_of_injective _ hfinj,
      Finset.card_image_of_injective _ heinj, Finset.card_univ,
      Finset.card_univ, Fintype.card_fin, Fintype.card_fin]
    exact heuler

/-- The degree of a vertex in an `ofFn` surface is the index-level count of
    edges through it. -/
theorem TriangulatedSphere.ofFn_deg {V : Type} [Fintype V] [DecidableEq V] {nF nE : ℕ}
    (fv : Fin nF → Finset V) (ev : Fin nE → Finset V)
    (hfinj : Function.Injective fv) (heinj : Function.Injective ev)
    (hfcard : ∀ f, (fv f).card = 3) (hecard : ∀ e, (ev e).card = 2)
    (hef : ∀ e, (Finset.univ.filter fun f => ev e ⊆ fv f).card = 2)
    (hfe : ∀ f, (Finset.univ.filter fun e => ev e ⊆ fv f).card = 3)
    (heuler : (Fintype.card V : ℤ) - nE + nF = 2) (v : V) :
    (TriangulatedSphere.ofFn fv ev hfinj heinj hfcard hecard hef hfe
      heuler).deg v
      = (Finset.univ.filter fun e => v ∈ ev e).card := by
  show ((Finset.univ.image ev).filter (fun e => v ∈ e)).card = _
  have himg : (Finset.univ.image ev).filter (fun e => v ∈ e)
      = (Finset.univ.filter fun e => v ∈ ev e).image ev := by
    rw [Finset.filter_image]
  rw [himg, Finset.card_image_of_injective _ heinj]

/-! ## The icosahedron -/

section Icosahedron

set_option maxRecDepth 65536
set_option maxHeartbeats 1600000

/-- The twenty faces of the icosahedron on vertices `0..11`: pole `0`,
    upper ring `1..5`, lower ring `6..10`, pole `11`. -/
def icoF : Fin 20 → Finset (Fin 12) :=
  ![{0, 1, 2}, {0, 2, 3}, {0, 3, 4}, {0, 4, 5}, {0, 5, 1},
    {1, 2, 6}, {2, 3, 7}, {3, 4, 8}, {4, 5, 9}, {5, 1, 10},
    {2, 6, 7}, {3, 7, 8}, {4, 8, 9}, {5, 9, 10}, {1, 10, 6},
    {6, 7, 11}, {7, 8, 11}, {8, 9, 11}, {9, 10, 11}, {10, 6, 11}]

/-- The thirty edges of the icosahedron. -/
def icoE : Fin 30 → Finset (Fin 12) :=
  ![{0, 1}, {0, 2}, {0, 3}, {0, 4}, {0, 5},
    {1, 2}, {2, 3}, {3, 4}, {4, 5}, {5, 1},
    {1, 6}, {2, 6}, {2, 7}, {3, 7}, {3, 8},
    {4, 8}, {4, 9}, {5, 9}, {5, 10}, {1, 10},
    {6, 7}, {7, 8}, {8, 9}, {9, 10}, {10, 6},
    {6, 11}, {7, 11}, {8, 11}, {9, 11}, {10, 11}]

/-- **The icosahedron is a `TriangulatedSphere`** — all index-level side
    conditions checked by kernel `decide`: 20 triangular faces, 30 edges
    each in exactly two faces, three edges per face, `12 − 30 + 20 = 2`. -/
def icosahedron : TriangulatedSphere :=
  TriangulatedSphere.ofFn icoF icoE
    (by decide) (by decide) (by decide) (by decide)
    (by decide) (by decide) (by decide)

/-- Every icosahedron vertex has degree 5 — the all-unit-defect situation
    of the chain's port count. -/
theorem icosahedron_deg : ∀ v, icosahedron.deg v = 5 := by
  intro v
  rw [show icosahedron.deg v
      = (Finset.univ.filter fun e => v ∈ icoE e).card from
    TriangulatedSphere.ofFn_deg icoF icoE _ _ _ _ _ _ _ v]
  revert v
  decide

/-- The counts: 20 faces, 30 edges. -/
theorem icosahedron_counts :
    icosahedron.faces.card = 20 ∧ icosahedron.edges.card = 30 := by
  constructor
  · show (Finset.univ.image icoF).card = 20
    rw [Finset.card_image_of_injective _ (by decide : Function.Injective icoF),
      Finset.card_univ, Fintype.card_fin]
  · show (Finset.univ.image icoE).card = 30
    rw [Finset.card_image_of_injective _ (by decide : Function.Injective icoE),
      Finset.card_univ, Fintype.card_fin]

end Icosahedron

/-- **The twelve ports of the icosahedron** — `twelve_unit_defects` firing
    on an actual surface: all twelve vertices are degree-5 defects. -/
theorem icosahedron_ports :
    (Finset.univ.filter fun v => icosahedron.deg v = 5).card = 12 :=
  icosahedron.twelve_ports (fun v => Or.inl (icosahedron_deg v))

/-! ### Axiom audit -/
#print axioms double_count
#print axioms TriangulatedSphere.ofFn
#print axioms TriangulatedSphere.edges_eq_biUnion
#print axioms TriangulatedSphere.three_faces_eq_two_edges
#print axioms TriangulatedSphere.degree_sum_eq_two_edges
#print axioms TriangulatedSphere.defect_count
#print axioms TriangulatedSphere.twelve_ports
#print axioms icosahedron
#print axioms icosahedron_ports

end OPHProofChain.CollarGate
