import Mathlib

/-!
# The QBFT safety core (appendix B), with a boundary finding

ATTRIBUTION: this module formalizes the *Safety* half of the "QBFT Safety
Bound" theorem of `observer-patch-holography/paper/`
`appendix_B_bft_qecc_extensions.tex` (Theorem `thm:qbft-safety`,
`:66–97`), an OPH-corpus extension appendix. The statement and proof
sketch are the appendix's; the formal counterexample in
`quorum_overlap_gap` is new to this tree.

## What the appendix claims

Under (A1)–(A6), a QBFT-style protocol on the OPH observer graph
satisfies (i) *safety* — no two nonfaulty observers finalise conflicting
patch states; (ii) *liveness* after GST; (iii) *optimality* of `f < n/3`.
The safety proof is a finite counting argument: two `(2f+1)`-certificates
overlap in `≥ f+1` observers (A6), at most `f` of which are Byzantine
(A2), so a *nonfaulty* observer signed both — contradicting single-vote
per view (P1).

## What is formalized here

* `qbft_safety_core` — **the safety argument, exactly as sketched**: if
  the two certificate quorums overlap in `> |F|` observers (`F` the
  faulty set) and every nonfaulty certificate member's unique signed vote
  supports the certified value, the two certified values are equal. The
  vote is modeled as a *function* `V → Option α` — this encodes P1
  (a nonfaulty observer votes at most once per view) together with A5
  (signatures are unforgeable, so a certificate exhibits the observer's
  actual vote).
* `quorum_intersection_exact` — the A6 overlap bound `|Q_a ∩ Q_b| ≥ f+1`
  **derived from A3, at `n = 3f+1` exactly** (the classical BFT sizing):
  inclusion–exclusion against `|Q_a ∪ Q_b| ≤ n`.
* `qbft_safety` — the two composed: safety from A2 + A3 + P1/A5 at
  `n = 3f+1`.
* `quorum_overlap_gap` — **the boundary finding (new).** The appendix
  asserts A6 is "guaranteed by (A3)" (`n ≥ 3f+1`). That parenthetical is
  **false for `n > 3f+1`** when the quorum size stays `2f+1`: already at
  `n = 3f+2` (five observers, `f = 1`) two 3-quorums can overlap in a
  *single* observer — which the adversary may own. So with absolute
  quorum size the safety argument is tied to `n = 3f+1` exactly; for
  general `n ≥ 3f+1` the quorum size must scale (e.g. `n − f`, or any
  size `q` with `2q − n ≥ f + 1`) — `quorum_intersection_general` states
  the correct general-`n` sizing. The theorem's *conclusion* is fine on
  the classical sizing; the "guaranteed by" clause needs the caveat.

## What is *not* formalized (and why, honestly)

* **Liveness** and **optimality** — the appendix itself discharges these
  by citation (DLS 1988 Thm 4.4; Lamport–Shostak–Pease 1982). They are
  external named results about timing models, out of scope for a finite
  counting module.
* The graph-theoretic clause (A4, strong quorum connectivity) — it feeds
  liveness (vote propagation), not the safety counting.
* Any connection to the χ_ν chain: **none exists** — this appendix is a
  corpus *extension* (consensus-protocol engineering on the observer
  graph), not a proof-chain link. It is formalized for completeness of
  the corpus's written finite mathematics, not because anything in
  §§1–8 of the proof chain depends on it.

Axioms: standard; no `sorry`, no `native_decide`.
-/

namespace OPHProofChain.ConsensusSafety

variable {V α : Type*} [DecidableEq V]

/-- **The QBFT safety core** (appendix B, Theorem `thm:qbft-safety` (i),
    the sketched counting argument). `F` is the faulty set; `vote` assigns
    each observer its unique signed vote (P1 + A5); a certificate for a
    value is a quorum whose nonfaulty members all voted for it. If two
    certificates overlap in more observers than `F` can cover, their
    values agree — no two nonfaulty observers finalise conflicting patch
    states. -/
theorem qbft_safety_core (F : Finset V) (f : ℕ) (hF : F.card ≤ f)
    (vote : V → Option α) (Qa Qb : Finset V) (a b : α)
    (hoverlap : f + 1 ≤ (Qa ∩ Qb).card)
    (ha : ∀ v ∈ Qa, v ∉ F → vote v = some a)
    (hb : ∀ v ∈ Qb, v ∉ F → vote v = some b) :
    a = b := by
  -- the overlap outnumbers the faulty set, so it contains a nonfaulty observer
  obtain ⟨v, hv, hvF⟩ : ∃ v ∈ Qa ∩ Qb, v ∉ F := by
    by_contra h
    push Not at h
    have hsub : Qa ∩ Qb ⊆ F := fun v hv => h v hv
    have := Finset.card_le_card hsub
    omega
  have h1 := ha v (Finset.mem_of_mem_inter_left hv) hvF
  have h2 := hb v (Finset.mem_of_mem_inter_right hv) hvF
  rw [h1] at h2
  exact Option.some_injective _ h2

/-- **A6 from A3 at the classical sizing `n = 3f+1`**: two `(2f+1)`-quorums
    among `3f+1` observers overlap in at least `f+1` of them
    (inclusion–exclusion against the universe). -/
theorem quorum_intersection_exact [Fintype V] {f : ℕ}
    (hn : Fintype.card V = 3 * f + 1)
    {Qa Qb : Finset V} (hQa : 2 * f + 1 ≤ Qa.card) (hQb : 2 * f + 1 ≤ Qb.card) :
    f + 1 ≤ (Qa ∩ Qb).card := by
  have hunion : (Qa ∪ Qb).card ≤ 3 * f + 1 := hn ▸ Finset.card_le_univ _
  have hie := Finset.card_union_add_card_inter Qa Qb
  omega

/-- The correct general-`n` sizing: quorums of size `q` with
    `f + 1 ≤ 2q − n` always overlap in `≥ f+1` observers. (At `n = 3f+1`,
    `q = 2f+1` satisfies this with equality — `quorum_intersection_exact`;
    for larger `n` the quorum must grow, e.g. `q = n − f`.) -/
theorem quorum_intersection_general [Fintype V] {f q : ℕ}
    (hq : f + 1 + Fintype.card V ≤ 2 * q)
    {Qa Qb : Finset V} (hQa : q ≤ Qa.card) (hQb : q ≤ Qb.card) :
    f + 1 ≤ (Qa ∩ Qb).card := by
  have hunion : (Qa ∪ Qb).card ≤ Fintype.card V := Finset.card_le_univ _
  have hie := Finset.card_union_add_card_inter Qa Qb
  omega

/-- **QBFT safety at the classical sizing** — A2 (≤ `f` faulty) + A3
    (`n = 3f+1`) + P1/A5 (unique signed votes) compose: two
    `(2f+1)`-certificates certify the same value. -/
theorem qbft_safety [Fintype V] (F : Finset V) (f : ℕ) (hF : F.card ≤ f)
    (hn : Fintype.card V = 3 * f + 1)
    (vote : V → Option α) (Qa Qb : Finset V) (a b : α)
    (hQa : 2 * f + 1 ≤ Qa.card) (hQb : 2 * f + 1 ≤ Qb.card)
    (ha : ∀ v ∈ Qa, v ∉ F → vote v = some a)
    (hb : ∀ v ∈ Qb, v ∉ F → vote v = some b) :
    a = b :=
  qbft_safety_core F f hF vote Qa Qb a b
    (quorum_intersection_exact hn hQa hQb) ha hb

/-- **The boundary finding (new in this tree).** The appendix's assumption
    list says the overlap bound A6 is "guaranteed by (A3)" (`n ≥ 3f+1`).
    With the quorum size fixed at `2f+1` that fails for every `n > 3f+1`:
    already at `n = 3f+2` — five observers, `f = 1` — the 3-quorums
    `{0,1,2}` and `{2,3,4}` overlap in exactly **one** observer, not
    `f+1 = 2`. If that observer is the Byzantine one, the safety counting
    argument has no nonfaulty witness. (The fix is standard: scale the
    quorum, `quorum_intersection_general`.) -/
theorem quorum_overlap_gap :
    ∃ Qa Qb : Finset (Fin 5), Qa.card = 3 ∧ Qb.card = 3 ∧ (Qa ∩ Qb).card = 1 :=
  ⟨{0, 1, 2}, {2, 3, 4}, by decide, by decide, by decide⟩

/-! ### Axiom audit -/
#print axioms qbft_safety_core
#print axioms quorum_intersection_exact
#print axioms quorum_intersection_general
#print axioms qbft_safety
#print axioms quorum_overlap_gap

end OPHProofChain.ConsensusSafety