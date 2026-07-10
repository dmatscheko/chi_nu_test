# Objectivity Is a Theorem with Hypotheses

## The Observer-Patch Holography proof chain, machine-checked — an expository paper

| | |
|---|---|
| Companion to | [`proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md`](proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md) (v9, 2026-07-09) and the Lean project [`proof_chain/formal/`](proof_chain/formal/) |
| Formal status | Every statement below labelled **Theorem** is machine-checked in Lean 4 + Mathlib: 35 modules, **1235 non-internal theorem/def declarations swept at the environment level in both namespaces — 0 `sorry`, 0 custom axioms, no `native_decide`** (fresh `lake build`, 8284 jobs, clean; count filter documented in `formal/RESULTS.md` §33/§36); every headline theorem reports at most the standard axioms `propext`, `Classical.choice`, `Quot.sound` |
| What this paper adds | Nothing. It is *exposition*: the same results, written as ordinary mathematics (LaTeX), with the proofs spelled out, an explanation of *why* each result holds, and a plain-language paragraph per result. The Lean files are the authority; a theorem-to-Lean map is Appendix A |
| What this paper does **not** do | It does not add new proofs, and it does not upgrade anything. Statements that are **named physical hypotheses** in the chain (SEE, MAR, the L0–L7 collar clauses, the G10 pricing convention, the channel identification, the realized-ℤ₆ gauge-group reading, P's source branch, the Bisognano–Wichmann identification) are named as hypotheses here too, every time they are consumed |
| Adversarial companion | [`OPH_PROOF_CHAIN_HOLES.md`](OPH_PROOF_CHAIN_HOLES.md) — an independent hole inventory of this paper and the chain (2026-07-07). Its F18 erratum table is applied throughout this revision; its mathematics is now closed by theorem: F8 → T26, F2 → T27 (§11a), F9 → T28 (§15a), F11 → T29 (§21a), F10c → the ℤ₆ group isomorphism, F15's anchors → interval arithmetic; **and since v8** the leftovers those closures created are closed too — async-schedule termination → T32, Skolem–Noether → T33 — together with the F24 residue → T35 (the twelve-port count now runs on an actual surface) and two theorems the simulation companion surfaced, T30 (local-decodability phase boundary; "determined ≠ locally derivable", machine-checked) and T31 (the readout trichotomy: empty fibers exist exactly below the sharp threshold); **and since v9 its last open mathematics row is closed too: F6 → T36** — the slope conjecture, proven sharp at every rational slope `≤ 1` as a corollary of the Lipschitz worldline theorem (§13b) — together with T30's gap-2 leftover → **T37** (the crawl completes iff the ring is odd); the chain document's §11–§13 carry the finding-by-finding disposition |

**How to read this paper.** Section 1 explains the whole theory, ending in a plain-language subsection. Parts I–IV then walk the proof chain result by result. Each result gets four blocks:

- **Statement** — the theorem in standard mathematical language;
- **Proof** — the actual argument, as carried out in Lean (rewritten as ordinary mathematics);
- **Why this happens** — the conceptual reason the theorem is true, and what work it does in the chain;
- **In plain language** — the same result for a reader with no mathematical background.

Labels T0–T29 match the proof-chain document. If you only read one technical section, read Section 11 (the sharp holographic screen, T9) — and its v7 companion 11a, where the screen and the repair dynamics finally run in one room (T27). If you read none, read Sections 1.5 and 27.

---

## Contents

- **1.** The whole theory (with plain-language subsection 1.5)
- **Part I — The consensus core:** 2. Carrier and mismatch (T0) · 3. Termination and completeness (T1, T2) · 4. Objectivity is not free (T3) · 5. The two levers (T4) · 6. The canonical repair operator (T12) · 7. Quotient repair and schedule independence (T6) · 8. The fence: consensus cannot decide Einstein (T7) · 9. The width-3 Rule-90 toy (T5) · 10. The layered carrier (T8)
- **Part II — Holography on a cellular automaton:** 11. The jewel: the sharp width-2 screen (T9) · **11a. Route A assembled (T27, new in v7)** · 12. Boost invariance and the parity obstruction (T18) · 13. The complete parity classification (T20) · 13a. The coprimality classification (T25) · **13b. The Lipschitz worldline theorem: the slope conjecture closed + the gap-2 crawl classified (T36 + T37, new in v9)** · **13c. The parity splitting and the diagonal observers (T38–T41, new in v10)** · 14. The hexacode extreme (T19, T22)
- **Part III — The conditional tower:** 15. Thermal time: the finite modular core (T21) · **15a. The real-time modular flow (T28, new in v7)** · 16. The Einstein-branch algebra (T14) · 16a. The cosmological-constant step (T26) · 17. Hypercharges and the ℤ₆ kernel (T13) · 18. The dark-sector mathematics (T15) · 19. The collar gate and $e^{-P/24}$ (T16) · 20. The unique scalar response under SEE (P4) · 21. The ΔS bridge, definition side (T17) · **21a. The channel bridge (T29, new in v7)** · 22. The two P's (T11 / L2.5)
- **Part IV — The cage, the numbers, the experiment:** 23. The conservation cage (T10) · 24. Run-matrix constants and the erratum (T24) · 25. The QBFT safety appendix (T23)
- **Part V — What remains open:** 26. The named hypotheses and gaps · 27. Verdict (with plain-language close)
- **Appendix A.** Theorem → Lean map · **Appendix C.** Related work and references · **Appendix B.** Notation

---

# 1. The whole theory

## 1.1 The problem OPH starts from

Physics is written as if there were a single global state of the world, evolving under global laws, inspected from outside. But physics is only ever *done* by finitely many observers, each with a bounded apparatus, a partial view, and records that must be reconciled with the records of others. **Observer-Patch Holography (OPH)** takes this operational situation as the primitive and asks what must be *proved*, rather than assumed, for the familiar picture — one objective world, geometric spacetime, specific matter content — to emerge.

The discipline of the program is unusual and worth stating up front: every claim is graded. A claim is either

1. **machine-checked** — a Lean 4 theorem, sorry-free, standard axioms only (this is "Layer 0", and as of v4/v5 of the chain it lives in one directory tree, `proof_chain/formal/`);
2. **a paper-side theorem** — written mathematics verified by inspection (as of v5, everything in this class that the audits identified has been formalized, so the class is empty for the chain);
3. **established external physics** the program hooks into (Jacobson's 1995 equation-of-state derivation, holography-as-error-correction);
4. **a conditional chain** — mathematics proven *downstream of named physical hypotheses* (the hypotheses are stated as hypotheses, never silently consumed);
5. **open** — physics gaps, listed by name.

The v5 headline was that the boundary between (1) and (4)/(5) is *exact*: every mathematical sub-claim with a written proof machine-checked, everything open being physics. The v6.1 adversarial audit sharpened the headline's honesty — and the v7 campaign then **closed the audit's mathematics by theorem**: the cosmological-constant step (T26), the Route-A joint model (T27, §11a), the real-time KMS statement (T28, §15a), and the record/collar counter identification (T29, §21a); the one decision-rule convention stays named as the hypothesis it is (the G10 pricing), now bracketed by two machine-checked theorem-grade anchors. The full list of what remains is Section 26.

## 1.2 The model

An observer is modeled as a **patch**: a finite system with a local state. Patches overlap; each overlap is an **interface** on which both patches expose part of their state. Formally (Section 2 gives the precise carrier):

- a finite graph $G = (V, E)$ of patches and shared interfaces;
- a local state space $S_i$ for each patch $i \in V$;
- for each edge $e = \{i, j\}$, an interface alphabet $I_e$ and projections $\pi_{i,e} : S_i \to I_e$, $\pi_{j,e} : S_j \to I_e$ — "what patch $i$ shows on interface $e$";
- a **global record** is a choice of local state for every patch, $x \in \Sigma := \prod_{i \in V} S_i$.

Two postulates, and only two, are laid on top:

**Postulate 1 (consistency).** Overlapping views must agree on shared observables: a record is *consistent* when $\pi_{i,e}(x_i) = \pi_{j,e}(x_j)$ on every edge. Disagreement is quantified by the **mismatch functional**

$$\Phi(x) \;=\; \sum_{e \in E} w_e \, d_e\big(\pi_{\mathrm{src}(e)}(x),\, \pi_{\mathrm{tgt}(e)}(x)\big),$$

with weights $w_e > 0$ and per-edge distances $d_e$ that separate points. Consistency is exactly $\Phi(x) = 0$ (T0).

**Postulate 2 (local repair).** Dynamics is *local repair that reduces disagreement*: a patch may update its own state to restore agreement on its own interfaces, and every accepted step strictly lowers $\Phi$.

Everything else — one objective reality, holographic reconstruction, and eventually the conditional tower toward spacetime and matter — has to be *earned* from these two postulates, or honestly flagged as an extra hypothesis.

## 1.3 The ladder of results

The chain climbs in four rungs. Notation ✅ = machine-checked; 🧩 = machine-checked mathematics consuming *named* physical hypotheses; 🔬 = open physics.

**Rung 1 — consensus dynamics works (✅, with its honest boundary).** Local repair always terminates: T12's canonical operator exists on *every* carrier and strictly descends, so there is no infinite bickering. Its terminal states are exactly the consistent records **under the named hypothesis `EdgeRepairable`** (T2/T12(3)) — and that hypothesis is not free: on some carriers (the width-3 Rule-90 toy, and — a theorem since v7, `rule90CylinderOPH_no_frustrationFree_repair` — every cylinder, at every size) *no* operator can satisfy all three local laws, and repair can terminate **in disagreement**. "Settled consensus" is a well-defined notion; "settled" and "agreed" coincide exactly on Edge-Repairable carriers.

**Rung 2 — one objective world is NOT automatic (✅, the load-bearing negative).** Asynchronous local repair is **not confluent**: from one starting record, different repair schedules can settle into *different* consistent worlds (T3). "There is one public objective reality" is therefore not a consequence of consensus dynamics — it is false in general. This is the theorem the whole program pivots on.

**Rung 3 — objectivity can be earned, two ways (✅).** 
*Route B (declared order):* if repair transactions are scheduled by a declared total order and satisfy four admissibility hypotheses ($H_B$, $H_\downarrow$, $H_\Diamond$, $H_{\mathrm{comp}}$), a total global repair operator exists whose result is **schedule-independent** (T6); the machine also checks that the local-confluence hypothesis $H_\Diamond$ is *not* free (the symmetric counterexample violates it). 
*Route A (boundary determination):* if a boundary readout $B$ is preserved by repair ($H_B$) and consistent records with equal boundary are gauge-equal ($H_{\mathrm{fib}}$), then any two records with the same boundary settle to the same observer-facing world (T4) — *without* confluence. The deep question is then: **which boundaries actually satisfy $H_{\mathrm{fib}}$?** That is a reconstruction — i.e. *holography* — question, and it gets a sharp, complete answer on a concrete carrier: on the Rule-90 cylinder, a width-2 timelike screen reconstructs the whole spacetime block **exactly when** its cell count reaches the code dimension (T9), the threshold is boost-invariant (T18), stretched screens work exactly on odd cylinders (T20), and the geometry-blind opposite extreme is exhibited by the hexacode (T19/T22). Consensus *consistency* + constraint redundancy really produces perfect holographic screens — in theorems, not metaphors. The honest asterisk this sentence used to carry is, since v7, a theorem instead (Section 11a, T27): on the very carrier that hosts the screens, no H1–H3 repair dynamics can exist (now proven for every cylinder) and the canonical operator can stall on inconsistent records (now proven, with the audit's exact witness — whose boundary fiber is proven empty of consistent records) — **and** a genuinely local, tube-preserving *transactional* repair does exist there, settling every record, under every schedule, to the unique world the screen pins. The full Route-A composition — dynamics and redundancy-boundary jointly — is machine-checked, with its one extra piece of declared structure (the responsibility roster) named and billed.

**Rung 4 — the conditional tower (🧩 on top of 🔬).** From here the program continues *outward*, and honesty becomes the main product. Bare consensus provably cannot decide geometric statements (T7 — the "fence"), so everything geometric needs extra structure, supplied as named hypotheses:

- a patch state on a finite record algebra already carries a unique KMS dynamics — "thermal time" (T21 ✅); identifying that flow with geometric *boosts* is the named Bisognano–Wichmann physics (🔬);
- entropy-stationarity identities (🔬) imply the full tensor Einstein equation by pure algebra (T14 ✅), with one scalar of residual freedom *per point*; that the scalar is a single constant — *the* cosmological constant — is its own theorem, from the named Bianchi/conservation inputs (T26 ✅, Section 16a);
- *given* the Standard-Model matter package (selection = the axiom **MAR**, 🔬), anomaly cancellation plus Yukawa closure *force* the hypercharges, and the trivially-acting center is exactly $\mathbb{Z}_6$ (T13 ✅);
- a Poisson counting model of imperfect repair (premises 🔬) yields a dark-sector activation law with exact Newtonian and deep-MOND limits and the baryonic Tully–Fisher relation (T15 ✅);
- a collar-gate model (clauses L0–L7, 🔬 — L0 the named shape postulate) forces the canonical susceptibility $\chi_{\mathrm{can}} = e^{-P/24}$ exactly, with a Jensen band when the gate is only satisfied on average (T16 ✅); the constant $P$ itself has two distinct published branches, both digit-checked (T11 ✅);
- the χ_ν "coherent-matter lift" — the claim that coherent record-keeping matter sources a measurable gravitational-potential anomaly — is bounded before any experiment by a conservation-law **cage**: a switchable force with no energy ledger is a perpetual-motion machine (T10 ✅). What T10 itself forces is a ledger entry at the scale of *realized cycle work* (joules for bench strokes); the headline **≈ 3.5 MJ per toggle** is the *named G10-convention pricing* — the infinity-referenced interaction energy `ΔM·Φ_N` — a declared hypothesis of the decision rule, not a consequence of the theorem (Section 23). The expected outcome of the experiment is NULL either way.

The tower ends in an experiment (the `chi_nu_test` device) whose conversion constants are themselves theorem-form (T24 ✅ — including one erratum found in the ledgers and fixed).

## 1.4 Where mathematics ends and physics begins

The v5 state of the boundary, in one table (details in Section 26):

| Open item | What it is | What already awaits it (machine-checked) |
|---|---|---|
| **SEE** | Scalar Edge-Center Exhaustion: every quotient-local scalar perturbation factors through one edge-center register | unique linear response form (P4), generator composition (T17) |
| **MAR** | Minimal Admissible Realization: the axiom selecting the SM matter package, $N_c = 3$, Yukawa structure | forced hypercharges + exact $\mathbb{Z}_6$ kernel (T13) |
| **L0–L7** | the collar-gate clauses (L0 the icosahedral shape postulate; product algebra, reserve pullback, disintegration, unbiasedness, Poisson survival) | $\lambda_{\mathrm{collar}} = e^{-P/24}$ exactly + Jensen band (T16) |
| **G9** | the numerical record-ΔS → gravity-ΔS calibration | the record side exists as a formal object; Theorem B.7 (T17) |
| **G10 ledger** | the toggle-energy log of a real experiment | the cage theorems + design-point numbers (T10, T24) |
| **P source branch** | the claimed zero-input spectral derivation of $\alpha$ | the two-branch finding: published $P$ is CODATA-calibrated *by definition* (T11) |
| **D3 identification** | Bisognano–Wichmann: modular flow = geometric boosts, plus the scaling limit | the finite modular core: KMS existence *and uniqueness* (T21) |

Note the design: every named hypothesis sits **directly upstream of a machine-checked consequence theorem**. If any hypothesis is ever discharged, its payoff is already proven and propagates instantly. If a hypothesis is refuted, the chain says exactly which conclusions die with it. This is what "the boundary is load-tested from the mathematics side" means.

## 1.5 In plain language

Imagine the world's knowledge held not by one all-seeing librarian but by many clerks, each keeping a small notebook. Neighbouring clerks share a few pages — where their notebooks overlap, the shared pages must say the same thing. The only "law of motion" is humble: when a clerk notices her shared pages disagree with a neighbour's, she may rewrite her own notebook to fix her own shared pages. That's the entire model of reality OPH starts from: notebooks, shared pages, and local corrections.

The machine-checked results then say, in order:

1. **The correcting always finishes.** No infinite bickering — but "finished" and "fully agreed" are the same thing only in offices where every broken page has at least one clerk allowed to fix it (a named condition). In other offices — including, provably, the paper's own star exhibit — the correcting can settle down with some disagreements frozen in.
2. **But different orders of correction can settle on different final stories.** If clerk A fixes first, the office ends up with story X; if clerk B fixes first, story Y. Both are internally consistent. So "one objective truth" is not something you get for free from agreement rules — a genuinely surprising and rigorously proven point.
3. **There are exactly two honest ways to get one story anyway.** Either the office adopts a *rulebook order* for who corrects first (and then the final story provably never depends on timing anymore), or the office designates certain pages as *the boundary record*, protected from rewriting — and if the boundary is rich enough to pin down everything else, then *among fully-corrected offices* the boundary fixes the story uniquely. (Caution, spelled out later: in the specific toy office where the beautiful boundary theorem lives, the correcting procedure itself can jam — the two showpieces have not yet been made to run in the same room.) How rich is "rich enough"? On a toy universe (a simple cellular automaton on a ring), the answer is exact and beautiful: a narrow strip of the record — two adjacent columns watched long enough — determines *everything*, precisely when the number of watched cells reaches the number of unknowns, and not one cell sooner. A tiny, perfect analogue of the "holographic principle" from black-hole physics: the boundary can carry the whole bulk.
4. **Everything beyond that is honestly labelled speculation with its price tag attached.** The program continues toward gravity, particle physics, a dark-matter-like effect, and finally a claim that coherent "record-keeping matter" could very slightly alter its own weight — to be tested by a real device. The mathematics *inside* each speculative step is machine-verified; the physical assumptions are named; and a conservation-law theorem says in advance that a claimed force with genuine work cycles must show its energy in the logs — the theorem sets the minimum (the work actually extracted), and a declared pricing convention (named as such) sets the headline megajoule scale the ledgers audit against. The experiment's expected result, by the chain's own grading, is *null*.

The one-sentence takeaway: **"there is one objective reality" is not an assumption of this framework, and not a free consequence either — it is a theorem with hypotheses, all of which are now written down, and everything mathematical about them is machine-verified.**

---

# Part I — The consensus core

*Modules: `Core/Primitives.lean`, `Core/AbstractRewriting.lean`, `Core/Rule90.lean` (the OPH team's core, imported with its three `sorry`s discharged), `QuotientRepair.lean`, `Rewriting.lean`, `NotEinsteinComplete.lean`, `LayeredCarrier.lean`.*

# 2. The carrier and the mismatch functional (T0)

## Statement

**Definition (OPH carrier).** An *OPH carrier* $C$ consists of: a finite set of patches $V$; a per-patch state space $S_i$ ($i \in V$); a finite edge set $E$ with endpoints $\mathrm{src}(e), \mathrm{tgt}(e) \in V$; per-edge interface alphabets $I_e$ with projections $\pi_{\mathrm{src},e} : S_{\mathrm{src}(e)} \to I_e$ and $\pi_{\mathrm{tgt},e} : S_{\mathrm{tgt}(e)} \to I_e$; weights $w_e > 0$; and per-edge distances $d_e : I_e \times I_e \to \mathbb{R}_{\ge 0}$ with $d_e(a,b) = 0 \iff a = b$.

A **record** is $x \in \Sigma := \prod_{i \in V} S_i$. The **observable overlap data** of $x$ is the map

$$\mathrm{obs}(x) : e \;\longmapsto\; \big(\pi_{\mathrm{src},e}(x_{\mathrm{src}(e)}),\; \pi_{\mathrm{tgt},e}(x_{\mathrm{tgt}(e)})\big),$$

and two records are **gauge-equivalent**, $x \sim_{\mathrm{g}} y$, when $\mathrm{obs}(x) = \mathrm{obs}(y)$ (the kernel of $\mathrm{obs}$ — an equivalence relation by construction). The **mismatch functional** is

$$\Phi(x) \;=\; \sum_{e \in E} w_e \cdot d_e\big(\pi_{\mathrm{src},e}(x),\, \pi_{\mathrm{tgt},e}(x)\big) \;\in\; \mathbb{R}_{\ge 0}.$$

**Theorem T0 (consistency ⇔ edge agreement).** For every record $x$:

$$\Phi(x) = 0 \quad\Longleftrightarrow\quad \forall e \in E:\ \pi_{\mathrm{src},e}(x) = \pi_{\mathrm{tgt},e}(x).$$

*(Lean: `consistent_iff_edgeConsistent`.)*

## Proof

A finite sum of non-negative terms vanishes iff every term vanishes. Each term is $w_e \cdot d_e(\cdot,\cdot)$ with $w_e > 0$, so the term vanishes iff $d_e(\cdot,\cdot) = 0$, which by the separation axiom $d_e(a,b) = 0 \iff a = b$ holds iff the two projections agree on $e$. $\blacksquare$

## Why this happens

T0 looks innocent but is the *faithfulness witness* of the whole model: it guarantees that the numerical functional $\Phi$ (which the dynamics descends on) measures exactly the logical property "all overlapping views agree" (which the theory is about). Without the two carrier axioms $w_e > 0$ and point-separation of $d_e$, $\Phi$ could vanish on records that still disagree, and later theorems (notably completeness, T2) would be about the wrong notion. The model also fixes, once and for all, what "the same world seen by all observers" means *observably*: gauge equivalence is agreement of all exposed interface data — hidden interior differences that no interface can see are deliberately quotiented away.

## In plain language

Before proving anything, you need a disagreement meter. This section builds one: add up, over every shared page between two notebooks, how badly the two copies differ (weighted by how much you care about that page). The first theorem certifies the meter is honest — it reads exactly zero precisely when every shared page agrees perfectly, never sooner. And it fixes a subtle but important convention: two notebook-collections count as "the same world" if they *show* the same thing on every shared page; privately-kept scribbles that nobody else can ever check don't count as part of reality.

# 3. Termination and completeness of local repair (T1, T2)

## Statement

Fix a carrier $C$ and an arbitrary local repair operator $\mathrm{lr} : V \times \Sigma \to \Sigma$ (writing $\mathrm{lr}_i(x)$ for the move at patch $i$), subject to three **local laws**:

- **H1 (locality of writes):** $\mathrm{lr}_i(x)_j = x_j$ for every $j \neq i$;
- **H2 (local trigger):** $\mathrm{lr}_i(x) \neq x \iff$ some edge incident to $i$ is inconsistent at $x$;
- **H3 (local satisfiability):** if $\mathrm{lr}_i(x) \neq x$, then *every* edge incident to $i$ is consistent at $\mathrm{lr}_i(x)$.

An **accepted step** is $x \to y$ with $y = \mathrm{lr}_i(x) \neq x$ for some site $i$; a **normal form** is a record admitting no accepted step.

**Theorem T1 (termination).** The accepted-step relation is well-founded: there is no infinite repair sequence. *(Lean: `termination`.)*

**Theorem T2 (completeness).** A record is a normal form iff it is consistent ($\Phi = 0$). *(Lean: `completeness`.)*

## Proof

Let $\mathrm{Br}(x) \subseteq E$ be the set of *broken* (inconsistent) edges of $x$, and $m(x) = |\mathrm{Br}(x)| \in \mathbb{N}$.

*Key descent lemma:* every accepted step strictly shrinks the broken set, $\mathrm{Br}(\mathrm{lr}_i(x)) \subsetneq \mathrm{Br}(x)$. Indeed, an edge incident to $i$ is consistent after the move (H3), so it is not in $\mathrm{Br}(\mathrm{lr}_i(x))$; an edge not incident to $i$ has both endpoint states unchanged (H1), so its broken-ness is unchanged. Hence $\mathrm{Br}(\mathrm{lr}_i(x)) \subseteq \mathrm{Br}(x)$. Strictness: since the step fired, H2 supplies a broken edge $e_0$ incident to $i$; it lies in $\mathrm{Br}(x)$ but (H3 again) not in $\mathrm{Br}(\mathrm{lr}_i(x))$.

*T1:* the accepted-step relation is a subrelation of the inverse image of $<$ on $\mathbb{N}$ under $m$, hence well-founded. (The $\mathbb{N}$-valued surrogate is necessary: $\Phi$ itself is real-valued, and $<$ on $\mathbb{R}_{\ge 0}$ is not well-founded. Each step also strictly lowers $\Phi$, term by term, by the same descent lemma — for the canonical operator of Section 6 this is the machine-checked `canonical_lyapunov` — but only the counting measure proves termination.)

*T2:* a record is a normal form iff no site fires, iff (H2, contrapositive, for every $i$) every edge incident to every site is consistent, iff every edge is consistent (each edge is incident to its own source), iff $\Phi(x) = 0$ by T0. $\blacksquare$

## Why this happens

The proof is the classical Lyapunov/well-founded-measure pattern, but the important design point is *where the hypotheses live*: H1–H3 are genuinely single-site statements (what one patch may touch, when it must act, what it must achieve), while the conclusions are global facts about the whole record space. Nothing global is smuggled into the hypotheses — there is no "assume a global potential decreases" axiom; the decrease is *derived* from locality. H3 is the one restrictive law: it says a patch can satisfy all its interfaces *simultaneously* (no "frustration"). The next sections show both that a canonical operator achieving H1–H3 exists whenever that is possible at all (T12), and that on some carriers *nothing* can satisfy H1–H3 (Section 9), which is why the chain's completeness theorem is later stated under an honest, weaker hypothesis.

## In plain language

Two guarantees about the correction process. First, it cannot go on forever: every accepted correction fixes at least one broken shared page and breaks none that were fine elsewhere, so the number of broken pages — a whole number — keeps dropping and must hit bottom. Second, when the process stops, it has stopped *for the right reason*: nothing is fixable anymore exactly when nothing is broken anymore. Stalemate-with-disagreement is impossible under these ground rules.

# 4. Objectivity is not free: non-confluence (T3)

## Statement

**Theorem T3 (non-confluence of asynchronous repair).** There is a carrier and a repair operator satisfying H1–H3 whose accepted-step relation is **not confluent**: a single record has two accepted repair sequences ending in two *different* normal forms. Concretely, on the two-patch carrier $\mathsf{demo}$ (patches $\{0,1\}$, states $\mathbb{B} = \{0,1\}$, one edge with identity projections) with the *neighbour-copy* repair $\mathrm{lr}_i(x) = x[i \mapsto x_{\bar\imath}]$: from the record $x = (0,1)$, firing patch $0$ yields the normal form $(1,1)$, firing patch $1$ yields the normal form $(0,0)$, and $(1,1) \neq (0,0)$ — indeed they are not even gauge-equivalent. *(Lean: `demoCarrier_not_confluent`; for the canonical operator of T12, `canonical_not_confluent`.)*

## Proof

The copy-move satisfies H1 (it writes only patch $i$), H2 (it moves iff the two patches disagree, which is exactly "the unique edge is broken"), and H3 (after copying, the two projections agree). From $x = (0,1)$: $\mathrm{lr}_0(x) = (1,1)$ and $\mathrm{lr}_1(x) = (0,0)$. Both results are constant records; on a constant record no patch disagrees with its neighbour, so (H2) no move fires: both are normal forms. If the relation were confluent, the unique-normal-form corollary of Church–Rosser (Newman machinery, Section 7's toolbox) would force the two normal forms reached from the single start $x$ to be equal; they differ in the first component. Moreover $\mathrm{obs}(1,1) = (1,1) \neq (0,0) = \mathrm{obs}(0,0)$ on the single edge, so the two settled worlds differ *observably*. $\blacksquare$

## Why this happens

The two patches are symmetric, and the repair rule respects the symmetry — so the *dynamics has no way to prefer* "copy left" over "copy right". Whichever patch moves first wins, and the tie is broken by the *schedule*, which is exactly the ingredient an asynchronous distributed system does not control. This is the same phenomenon as write conflicts in distributed databases (last-writer-wins ambiguity), here isolated in the smallest possible model and machine-checked. Its role in the chain is foundational: it *refutes* the naive reading "consensus dynamics ⇒ one objective public reality", and thereby forces the entire Route A / Route B analysis of Section 5. The proof chain calls it the load-bearing negative result. Note also what it does **not** say: it does not say every repair is non-confluent (a deterministic, direction-picking repair on the same carrier *is* confluent — `demoCarrier_dir_confluent`); it says confluence is not implied by the consensus laws, so anyone claiming a unique objective world owes an extra argument.

## In plain language

Here is the whole surprise in one tiny office. Two clerks each hold one bit, and the rule says: if your bit disagrees with your neighbour's, you may copy theirs. Start them in disagreement — say clerk A holds 0, clerk B holds 1. If A corrects first, both end up at 1. If B corrects first, both end up at 0. Two perfectly consistent, perfectly settled offices — with *opposite* contents, decided by nothing but who moved first. Agreement rules alone manufacture *an* agreed story, but not *the* story. If you want one canonical shared reality, you must add something — and the next section proves there are exactly two honest somethings to add.

# 5. The two levers that restore objectivity (T4)

## Statement

Keep a carrier $C$ and a repair $\mathrm{lr}$ satisfying H1–H3.

**Theorem T4a (commutation route / Route B, sufficient condition).** Assume additionally
**H4 (global commutation):** $\mathrm{lr}_i \circ \mathrm{lr}_j = \mathrm{lr}_j \circ \mathrm{lr}_i$ for all sites $i, j$. Then the accepted-step relation is confluent (Church–Rosser), hence — with T1 — every record has a *unique* normal form, independent of the schedule. *(Lean: `confluence_of_commute`.)*

**Theorem T4b (boundary route / Route A: observer-uniqueness without confluence).** Let $B : \Sigma \to \beta$ be a boundary map with
**HB (boundary preservation):** $B(\mathrm{lr}_i(x)) = B(x)$ for all $i, x$, and
**Hfib (gauge-singleton consistent fibers):** any two consistent records with equal boundary are gauge-equivalent.
Then any two records $x, y$ with $B(x) = B(y)$ settle, along *any* accepted repair sequences, to gauge-equivalent normal forms. Confluence is not assumed and does not enter. *(Lean: `boundary_fiber_observer_unique`.)*

**Complements (all machine-checked).** (i) H4 is not free: the demo copy-repair violates it, and is in fact non-confluent (T3). (ii) Hfib is not free: with the trivial boundary, the demo carrier *refutes* Hfib (`demoCarrier_Hfib_fails`). (iii) The two notions are genuinely different levers: the deterministic direction-picking repair on the demo carrier is confluent yet fails observer-uniqueness under the trivial boundary (`demoCarrier_dir_not_observer_unique`), and regains it when the boundary is refined to a single seed cell (`demoCarrier_dir_observer_unique_under_seed`) — with the repair held fixed, *the boundary's fineness is the controlling lever*.

## Proof

*T4a.* By Newman's lemma it suffices to prove local confluence. Given two accepted one-steps $x \to \mathrm{lr}_i(x)$ and $x \to \mathrm{lr}_j(x)$, the common join is $w := \mathrm{lr}_j(\mathrm{lr}_i(x)) = \mathrm{lr}_i(\mathrm{lr}_j(x))$ (by H4); each side reaches $w$ in at most one accepted step (zero steps if the corresponding move is quiescent there, one otherwise). Termination is T1; Newman (Section 7's toolbox, proved from scratch by well-founded induction) upgrades local confluence to confluence, and confluence forces uniqueness of normal forms.

*T4b.* Along any accepted reduction the boundary never changes (HB, by induction along the reduction). Let $x \to^* n_x$ and $y \to^* n_y$ with $n_x, n_y$ normal forms. By T2, $n_x$ and $n_y$ are consistent. Their boundaries satisfy $B(n_x) = B(x) = B(y) = B(n_y)$. Hfib applied to the two consistent, boundary-equal records gives $n_x \sim_{\mathrm{g}} n_y$. $\blacksquare$

## Why this happens

The two routes repair the schedule-dependence of T3 at two different joints. Route B removes the *ambiguity of the race*: if all moves commute, the order never mattered (algebraically, the rewriting system becomes a lattice of commuting squares and Newman's lemma collapses all maximal paths to one endpoint). Route A never touches the race at all; it works because the *destination is pinned by data the race cannot touch*. The boundary is repair-invariant, so it survives to the normal form; consistency at the normal form is guaranteed by T2; and Hfib says boundary + consistency leave no observable freedom. The chain's later holographic theorems (Part II) are precisely the study of when Hfib can be *true for a small boundary* — that is where "the boundary determines the bulk" stops being a hypothesis and becomes a theorem about a concrete carrier. The complements matter for honesty: each hypothesis is exhibited as satisfiable and as failable, so neither theorem is vacuous, and the two uniqueness notions (per-input uniqueness vs. per-boundary uniqueness) are proved genuinely independent.

## In plain language

Two fixes for the "who moves first decides the truth" problem. **Fix one:** make the corrections order-proof — if doing A-then-B always lands exactly where B-then-A lands, timing can't matter anymore. That's a strong demand on the correction rules (our two-clerk office fails it). **Fix two:** don't fight about timing at all; instead declare some pages *read-only* — the boundary record. Corrections may never touch them, and if the read-only pages are informative enough to pin down everything else once the office is fully consistent, then no matter who corrected in what order, all final stories must match. The genuinely deep question becomes: *how few read-only pages are enough?* Astonishingly, on the toy universe of Part II the answer is: a thin strip, and the theorem tells you its exact minimum size. That is a *holographic* statement — a lower-dimensional boundary carrying the full higher-dimensional content — earned here as a theorem rather than borrowed as a metaphor.

# 6. The canonical repair operator: the core's three `sorry`s, discharged (T12)

## Statement

The OPH team's own Lean core stated the repair operator abstractly and left three `sorry`s: the local operator, the composite operator, and gauge-respect. The chain's v4 campaign *constructed* them, on **every** carrier:

**Definition (canonical frustration-free snap).** For a patch $i$ and record $x$, say $s \in S_i$ is a *local fix* if updating patch $i$ to $s$ makes every edge incident to $i$ consistent; say $i$ *should fire* at $x$ if (a) some incident edge is broken and (b) a local fix exists. Define

$$\mathrm{localRepair}_i(x) \;=\; \begin{cases} x[i \mapsto s_{i,x}] & \text{if } i \text{ should fire, where } s_{i,x} \text{ is a fixed choice of local fix,} \\ x & \text{otherwise;} \end{cases}$$

and let $\mathrm{Repair}(x)$ iterate "fire the *least* firing site in a declared enumeration of the patches" until no site fires.

**Theorem T12.** On every carrier: (1) $\mathrm{Repair}$ is total (the iteration terminates); (2) every genuine move strictly lowers $\Phi$ and the broken-edge count, so the file's own `LyapunovDescent` and `Termination` obligations hold *unconditionally*; (3) normal forms are exactly the consistent records under the named hypothesis **EdgeRepairable** (every broken edge has at least one endpoint that can satisfy all its interfaces — **strictly** weaker than full frustration-freeness: the implication is `edgeRepairable_of_frustrationFree`, and the strictness is witnessed, `edgeRepairable_strictly_weaker` — the width-3 carrier of Section 9 is Edge-Repairable yet admits no frustration-free operator at all); (4) **gauge-respect**: $x \sim_{\mathrm{g}} y \implies \mathrm{Repair}(x) \sim_{\mathrm{g}} \mathrm{Repair}(y)$; (5) the operator is not degenerate: on the demo carrier it *equals* the neighbour-copy repair, and consequently asynchronous `Confluence` for the canonical operator is **refuted** there (T3 restated for the real operator); (6) $\mathrm{Repair}$ is idempotent, fixes consistent records, and its run is one particular accepted schedule (so it adds no new primitive). *(Lean: `localRepair`, `Repair`, `canonical_lyapunov`, `canonical_termination`, `canonical_completeness`, `repair_respects_gauge`, `localRepair_demoCarrier`, `canonical_not_confluent`, `Repair_idem`, …)*

## Proof

*(1)–(2).* When $i$ fires, the chosen state is a local fix, so all edges incident to $i$ come out consistent — including the broken witness that caused the firing — and H1-style locality holds by construction (only patch $i$ is updated). The descent lemma of Section 3 applies verbatim: the broken-edge count strictly drops, giving totality of the iteration by well-founded recursion, and $\Phi$ strictly drops term-by-term ($w_{e_0} d_{e_0} > 0$ before, $= 0$ after, no other term increases).

*(3).* Consistent records fire nowhere (no broken incident edge), so they are normal forms unconditionally. Conversely, if $x$ has a broken edge $e$, EdgeRepairable supplies an endpoint $i$ of $e$ that can fix all its interfaces; then $i$ *should fire*, so $x$ is not a normal form. (The hypothesis is honest and necessary in this weaker form: Section 9 proves a carrier where nothing satisfies H1∧H2∧H3, so the H1–H3 route to unconditional completeness is closed.)

*(4) — the delicate one.* The point is that **every ingredient of the operator is a function of the observable overlap data** $\mathrm{obs}(x)$ only: whether an edge is consistent (it compares two projections — components of $\mathrm{obs}$); whether a candidate $s$ is a local fix (it examines updated projections, and the far endpoint of an incident edge enters only through its projection — again $\mathrm{obs}$); hence whether $i$ should fire; hence the firing set, the least firing site in the declared order, and the descent measure. For the chosen state one more fact is needed: the choice function picks *one fixed witness per predicate*, and gauge-equivalent records have literally *equal* local-fix predicates, hence equal chosen states. An induction along the (terminating) iteration then transports $\mathrm{obs}(x) = \mathrm{obs}(y)$ through every step: the same sites fire in the same order, snapping to the same states.

*(5).* On the demo carrier the unique local fix at a broken edge is "copy the neighbour" (machine-checked case analysis), so the canonical operator coincides with the copy repair — the anti-degeneracy witness demanded by the source file's own `sorry` documentation (no `Repair := id` smuggling). Non-confluence then transfers from T3 verbatim. $\blacksquare$

## Why this happens

Before T12, the chain's Route B lived only in quotient form (Section 7); the core's own repair was a promissory note. The construction shows the note was good: an operator exists on *every* carrier and provably respects gauge because it was built out of observable data only. Its declared-structure bill has **two** lines, both Route-B-type: the declared patch order, **and a declared local-fix selector** (the construction uses a global choice of one satisfying state per fix predicate — `Classical.choose`; gauge-respect survives because gauge-equal records have literally equal predicates, an intensional fact — a physical implementation must pick concrete fixes and its picks are conventional structure of exactly the kind T3 teaches us to bill). "Canonical" here means *arbitrary-but-fixed-and-billed*, not choice-free. Two design choices carry the honesty: the fire condition demands `CanFix` (so the operator is total even on frustrated carriers — it simply declines to fire where no local fix exists, which is also exactly why unconditional H2 fails on frustrated carriers and completeness needs `EdgeRepairable`); and schedule-independence is *not* claimed for the asynchronous relation — it is refuted (point 5) — but only *purchased* by the declared order, which is the whole Route-B lesson in operator form.

## In plain language

The original authors had written "and here a concrete correction procedure would go" in three places, with IOUs. This result pays the IOUs. It exhibits an actual procedure any office can run: a clerk acts only when one of her shared pages is broken *and* she can fix all her pages at once; when she acts, she rewrites to a fixed repair; and clerks take turns in a published roster order. The procedure provably always finishes, fixes everything fixable, treats look-alike offices identically (it never peeks at private scribbles — only at shared pages), and is genuinely the natural rule (on the two-clerk office it *is* "copy your neighbour"). And, importantly, the theorem does not pretend the timing problem vanished: without the roster, this very procedure still exhibits the two-endings problem. The roster is what you pay for one ending.

# 7. The quotient repair package and schedule independence (T6)

## Statement

**Definition (quotient repair presentation).** A tuple $\mathcal{P} = (\Sigma, \Gamma, q, Q, C_Q, B, \mu, \mathsf{A}, \prec_{\mathsf{A}})$: a presentation space $\Sigma$, a surjective quotient map $q : \Sigma \to Q$ onto the physical quotient (the redundancy groupoid $\Gamma$ is the kernel of $q$), a consistency set $C_Q \subseteq Q$, a protected boundary map $B : Q \to \mathcal{B}$, a descent measure $\mu : Q \to (W, \prec)$ with $\prec$ well-founded, and a *finite* set $\mathsf{A}$ of partial repair transactions $a : D_a \to Q$ (decidable domains) carrying a declared total order $\prec_{\mathsf{A}}$. The presentation is **OPH-admissible** when four hypotheses hold:

- $H_B$: every transaction preserves the boundary, $B(a(x)) = B(x)$ on $D_a$;
- $H_\downarrow$: every transaction strictly descends, $\mu(a(x)) \prec \mu(x)$ on $D_a$;
- $H_\Diamond$: the induced one-step relation $x \to y \iff \exists a,\ x \in D_a,\ y = a(x)$ is *locally confluent*;
- $H_{\mathrm{comp}}$: $x \in C_Q \iff$ no transaction is enabled at $x$.

Define the **local repair** $\mathrm{locRep}(x)$ = apply the $\prec_{\mathsf{A}}$-least enabled transaction (fix $x$ if none), and the **global repair** $\mathrm{Rep}_\lambda(x)$ = iterate $\mathrm{locRep}$ to a fixed point (total by $H_\downarrow$).

**Theorem T6.** For every OPH-admissible presentation:

1. $\mathrm{Rep}_\lambda(x) \in C_Q$; 2. $B(\mathrm{Rep}_\lambda(x)) = B(x)$; 3. $\mathrm{Rep}_\lambda$ is idempotent; 4. $\mathrm{Rep}_\lambda(x) = x \iff x \in C_Q$; and
5. **(schedule independence)** every terminal state of *every* accepted execution from $x$ — any maximal sequence of enabled transactions, in any order — equals $\mathrm{Rep}_\lambda(x)$.

Moreover, with $\mathrm{World}(s) := \mathrm{Rep}_\lambda(q(s))$: $\mathrm{World}$ is a repair fixed point, and **repair respects gauge** — $q(s) = q(s')$ implies $\mathrm{World}(s) = \mathrm{World}(s')$, hence every observable of the repaired world is invariant under all gauge moves $\gamma$ with $q \circ \gamma = q$.

**Separation theorem ($H_\Diamond$ does real work).** The *symmetric* two-transaction system on the two-cell carrier — "snap the pair to the first cell" and "snap to the second", both enabled exactly on broken states — strictly descends a well-founded measure (`symmetricPair_descends`) and is quiescence-complete (its normal forms are exactly the consistent states, `symmetricPair_normalForm_iff` — an axiom-free proof), with the boundary clause vacuous on this boundary-free carrier, yet it is **not** locally confluent: from $(1,0)$ the two transactions reach the distinct terminal states $(1,1)$ and $(0,0)$. So $H_\Diamond$ is not implied by the other hypotheses — the witness satisfies them honestly, not vacuously; $H_\Diamond$ is exactly where T3's non-confluence is excluded, by declared structure. *(Lean: `QuotientRepairPresentation.*`, `schedule_independence`, `repair_respects_gauge`, `symmetricPair_not_locallyConfluent`, `symmetricPair_descends`, `symmetricPair_normalForm_iff`, and the computed instance `demoPresentation_settles`.)*

## Proof

*(1)–(4).* $\mathrm{locRep}$ is boundary-preserving (it applies one transaction, $H_B$), strictly descending off $C_Q$ ($H_\downarrow$), and fixes exactly $C_Q$ ($H_{\mathrm{comp}}$ for "if"; for "only if", a fixed point with an enabled transaction would contradict strict descent — a well-founded relation is irreflexive). Iterating to a fixed point is total by well-founded recursion along $\mu$; the fixed point lies in $C_Q$ by the fixed-point characterization, the boundary is preserved at every stage (induction), idempotence is "consistent states are fixed", and (4) combines both directions.

*(5).* The one-step relation terminates ($H_\downarrow$ pulls well-foundedness back along $\mu$) and is locally confluent ($H_\Diamond$), so by **Newman's lemma** it is confluent, and a confluent terminating relation has unique normal forms: any two maximal executions from $x$ join, and normal forms only reduce to themselves. By $H_{\mathrm{comp}}$, normal forms = $C_Q$, and the canonical iteration is itself one accepted execution ending in a normal form, so every other terminal state equals $\mathrm{Rep}_\lambda(x)$.

(Newman's lemma is itself proved from scratch in the tree — `Rewriting.lean` — by well-founded induction on the peak: given $x \to^* y$, $x \to^* z$, peel one step off each side, join the two first steps locally, then close the two remaining peaks by the induction hypothesis at the smaller elements.)

*Gauge respect* is now structural: $\mathrm{World} = \mathrm{Rep}_\lambda \circ q$ literally factors through $q$, so equal quotients give equal worlds — the content of the Lean core's third `sorry`, in the quotient setting the paper works in.

*Separation.* Both symmetric transactions are enabled at $(1,0)$; one yields $(1,1)$, the other $(0,0)$; both results are quiescent (consistent), and quiescent states only reduce to themselves, so no common reduct exists — local confluence fails. $\blacksquare$

## Why this happens

T6 is Route B *as an interface*: it names the exact price of schedule-independent objectivity. Three of the four hypotheses are cheap bookkeeping ($H_B$, $H_\downarrow$, $H_{\mathrm{comp}}$ hold for any sane repair); the entire monopoly rent is $H_\Diamond$, and the separation theorem proves the rent is real — it is precisely T3's counterexample re-expressed, and it is *excluded by fiat*, by the declared order structure, not derived. The payoff of paying: Newman turns local joins into global joins, and "the world you settle into" becomes a *function* $\mathrm{World}(s)$ — total, idempotent, boundary-respecting, gauge-invariant. This is the formal sense in which the chain's slogan reads: *objectivity is purchased with declared structure, and the receipt is machine-checked.* The demo instance computes ($\mathrm{Rep}_\lambda(1,0) = (1,1)$), so nothing is vacuous.

One regress deserves its own paragraph (the audit's F4). Both objectivity routes purchase uniqueness with a **globally shared** object — Route B a total order every patch consults, Route A a boundary designation every patch honours. In a program whose founding ontology is "finitely many observers with partial views and no global structure", *establishing* such a shared object among the observers is itself a consensus problem — the very problem T3 proves has no canonical solution without extra structure; in distributed-systems terms, total-order broadcast is equivalent to consensus, and assuming a sequencer relocates the problem rather than solving it. The theorems are honest conditionals on the declared structure being *given*; a theorem about *emergent* order (symmetry-broken schedules from local randomness, say) would genuinely earn the word "earned" and is not currently on offer.

## In plain language

This is the fine print of "adopt a rulebook order". Write every allowed correction as a transaction; publish a fixed priority list; and demand four printed clauses, of which three are obvious hygiene and one — "any two corrections started from the same place can be brought back together" — is the load-bearing one. The theorems then guarantee: the office's settling procedure always finishes, never touches the protected boundary pages, gives the same final story *no matter how the timing actually unfolded*, and never depends on private scribbles. And the fine print is honest about its one expensive clause: the two-clerk office from Section 4, with its two symmetric "copy me!" corrections, violates exactly that clause — which is *why* it had two endings. You now know precisely what you bought and what it cost.

# 8. The fence: bare consensus cannot decide the Einstein equation (T7)

## Statement

**Definition.** A *bare consensus reduct* is the tuple $\mathsf{Cons} = (\Sigma, \Gamma, Q, \Phi, \to, n, C)$: presentation space, redundancy (kernel of $q$), physical quotient, an $\mathbb{N}$-valued mismatch, an accepted-step relation, a normal-form map, and the consistent set — together with the reduct laws ($C = \Phi^{-1}(0)$, steps strictly lower $\Phi$, normal forms are consistent). A *geometric extension* $\mathcal{E}$ of a reduct adds an event set $P \neq \emptyset$ and decoration $g, \mathrm{curv}, T : P \to \mathbb{Z}$, $\Lambda, \kappa \in \mathbb{Z}$; the *Einstein equation* of $\mathcal{E}$ is the proposition

$$\mathrm{EE}(\mathcal{E}) \;:\iff\; \forall p \in P:\ \mathrm{curv}(p) + \Lambda\, g(p) = \kappa\, T(p).$$

**Theorem T7 (not Einstein-complete).** There is no predicate $f$ of the bare consensus reduct with $f(\mathcal{E}.\mathsf{reduct}) \iff \mathrm{EE}(\mathcal{E})$ for all geometric extensions $\mathcal{E}$ — and no $\{0,1\}$-valued reduct functional either. *(Lean: `bare_consensus_not_einstein_complete`, `no_reduct_functional_determines_geometry`.)*

## Proof

Exhibit one genuine, non-degenerate reduct $\mathsf{demo}$ (two Boolean patches, one overlap; mismatch counts the broken edge; a genuine copy step; both a consistent and an inconsistent state exist, so nothing is rigged) and two extensions of *definitionally the same* reduct: $\mathcal{E}_1$ with flat/vacuum decoration ($\mathrm{curv} = T = 0$, $\Lambda = 0$) — $\mathrm{EE}$ **holds**; $\mathcal{E}_2$ with $\mathrm{curv} = 1$, $T = 0$ — $\mathrm{EE}$ **fails** at the (unique) event. If $f$ existed, $f(\mathsf{demo})$ would have to be true (via $\mathcal{E}_1$) and false (via $\mathcal{E}_2$). $\blacksquare$

## Why this happens

This is a *definability* separation, not a physics argument: the geometric fields simply do not exist reduct-side, so two extensions can disagree geometrically while agreeing on every consensus-language statement. Its role is architectural — it is **the fence** between Layer 0 and the conditional tower. Everything geometric in Part III (Lorentz flow, Einstein equation, gauge group) must therefore enter through *extra structure*, and the chain makes that structure explicit as named hypotheses. The fence also protects the program from its own enthusiasm: any future claim that "consensus dynamics alone yields general relativity" is machine-refutably false as stated; only "consensus + declared structure X yields …" can be true, and X is then on the table for inspection. Graded honestly (the audit's F5): the separation holds *because* the geometric decoration is attached with no connecting law at all — the same proof shows bare consensus decides nothing whatsoever about any fresh structure — so the fence certifies **bookkeeping discipline**, not a discovered mathematical obstruction; its value is architectural, and by design it makes "geometry *from* bare overlap consistency" definitionally unreachable, so every later recovery is hypothesis-import and is labelled as such.

## In plain language

Could the humble notebook-and-corrections picture, all by itself, already decide the laws of gravity? No — and that "no" is itself a theorem. Two imaginary universes are built that are *identical* in every respect the notebook language can express, yet one obeys Einstein's equation and the other violates it. So no amount of cleverness with notebooks alone can settle gravity; whatever brings geometry in must be an extra ingredient, declared openly. The framework builds this fence around its own core to keep later, more speculative storeys honest: whenever gravity appears in this program, you will see exactly which added assumption carried it in.

# 9. The width-3 Rule-90 toy: a carrier with real gauge and no frustration-free repair (T5)

## Statement

Encode one time-step of the elementary cellular automaton **Rule 90** on a width-3 tape with zero boundary as a two-patch carrier: patch $0$ holds the seed row $(a,b,c) \in \mathbb{F}_2^3$, patch $1$ holds the next row, and the single edge exposes $\big(R(a,b,c),\, \text{(next row)}\big)$ where

$$R(a,b,c) = (b,\; a \oplus c,\; b)$$

(each cell becomes the XOR of its neighbours; the boundary zeros make the outer image cells both equal $b$). Consistency ⇔ "the bottom row is the Rule-90 image of the seed" ⇔ the record is a valid CA diagram. Then:

1. **(Hfib holds for a proper boundary)** Reading bottom-row cells $\{0,1\}$ pins the whole observable: two consistent diagrams agreeing there are gauge-equivalent. *(`rule90_Hfib_good`)*
2. **(Hfib fails for a same-size boundary)** Reading bottom-row cells $\{0,2\}$ reads the redundant bit twice and misses $a \oplus c$: two consistent diagrams agree there yet differ observably. *(`rule90_Hfib_bad_fails`)*
3. **(the gauge is non-trivial)** $R$ has a one-dimensional kernel — seeds $(0,0,0)$ and $(1,0,1)$ share their image — so consistent records with *different seeds* can be gauge-equivalent. *(`rule90_gauge_nontrivial`)*
4. **(no frustration-free repair exists)** No local move satisfies H1∧H2∧H3 on this carrier. *(`rule90_no_frustrationFree_repair`)*

## Proof

*(1).* Consistency gives (bottom) $= R($seed$)$; the CA redundancy forces bottom cell $2 =$ bottom cell $0$ (both equal $b$). So the two read cells $\{0,1\}$ determine the whole bottom row, and the observable of a consistent record is (bottom, bottom).

*(2).* Seeds $(0,0,0)$ and $(0,0,1)$ produce bottoms $(0,0,0)$ and $(0,1,0)$: both consistent, both reading $(0,0)$ on cells $\{0,2\}$, observably different in the middle cell.

*(3).* $R(1,0,1) = (0, 1\oplus 1, 0) = (0,0,0) = R(0,0,0)$: two consistent records with different seeds and equal observables.

*(4).* Take any record whose bottom row is $(0,0,1)$ — outer cells unequal, hence *outside the image of $R$ for every seed* (all images have equal outer cells). The single edge is broken whatever the seed; H2 then forces the *seed*-patch move to fire; H1 pins the bottom row; H3 demands the edge become consistent, i.e. demands a Rule-90 preimage of $(0,0,1)$ — which does not exist. Contradiction. $\blacksquare$

## Why this happens

The width-3 toy is small enough to compute yet already exhibits the three phenomena the big theorems live on. *Redundancy:* the CA constraint makes part of the exposed data recoverable from the rest, so a boundary can be strictly smaller than the observable and still identify it — but only if it reads the *right* cells; an equal-sized wrong choice fails. *Gauge:* the constraint map has a kernel, so "the observable" genuinely quotients seed information away — the gauge equivalence is not a bookkeeping fiction. *Frustration:* some inconsistent records cannot be fixed by any single-patch move that keeps its own side (the bottom row is simply not an image), which kills unconditional H2∧H3 on this carrier and is the honest reason the core's completeness theorem carries the `EdgeRepairable` hypothesis (Section 6). Everything in Part II is this toy grown up: many rows instead of two, a ring instead of a bounded tape, and a *sharp, quantitative* version of "the right cells".

## In plain language

A miniature universe with three cells and one law ("each cell becomes the XOR of its neighbours") already teaches three lessons. First, its law creates *redundancy*: the outer two cells of the new row are always equal, so a spy who reads the correct two of the three cells knows everything — but a spy reading the *wrong* two learns one fact twice and stays ignorant. Which pages you protect matters, not just how many. Second, different starting rows can lead to identical visible outcomes — some of the past is genuinely invisible from the record, which is what "gauge" means. Third, some corrupted records cannot be repaired by any local fix at all — the mess is provably beyond one clerk's reach — which is why the framework's repair guarantees carry a stated fixability condition rather than pretending.

# 10. The layered feed-forward carrier (T8)

## Statement

**Definition (layered functional boundary carrier).** A directed graph on vertices $V$ layered as $V = L_0 \sqcup L_1 \sqcup \dots \sqcup L_D$; per-vertex alphabets $A_v$; each vertex $v$ has parents in strictly earlier layers; each *interior* vertex (layer $> 0$) carries a deterministic local rule $F_v$ computing its value from its parents' values; optional cross-check predicates. The **boundary** is layer $0$, read by $B(a) = a|_{L_0}$. The **functional extension** $E(b)$ of boundary data $b$ assigns $b$ on $L_0$ and recursively $F_v(\text{parents})$ above. A state is *consistent* when every interior equation $a_v = F_v\big((a_u)_{u \in P(v)}\big)$ holds and all cross-checks pass. The **staged sweep** $R_{\mathrm{sweep}} = R_D \circ \dots \circ R_1$ rewrites layer $d$ from its parents at stage $d$.

**Theorem T8.** (i) *(HB)* No stage writes the boundary: $B(R_{\mathrm{sweep}}(a)) = B(a)$. (ii) *(reconstruction)* From **any** initial state, $R_{\mathrm{sweep}}(a) = E(B(a))$. (iii) *(Hfib)* A consistent state equals the extension of its own boundary; hence the consistent fiber over any boundary value is the singleton $\{E(b)\}$ (when $b$ is admissible), and two consistent states with equal boundary are equal. (iv) *(presentation-free corollary)* **Any** repair $R$ with $B(R(a)) = B(a)$ and $R(a)$ consistent necessarily outputs $E(B(a))$. A genuinely multi-edge instance (two boundary bits, an interior XOR vertex, a copy vertex) witnesses all hypotheses jointly. *(Lean: `sweep_restrictB`, `sweep_eq_extend`, `hfib_singleton`, `reconstruction_of_boundary_preserving_repair`, `demoLayered_two_consistent_states`.)*

**Honest scope.** This is the *feed-forward class*: the boundary is the complete input layer of a deterministic circuit, so reconstruction is determination-by-construction. It supplies the joint $H_B \wedge H_{\mathrm{fib}}$ *form* the core named as open, but not erasure-correction strength (reconstruction from a *proper subset* through constraint redundancy). That strictly stronger phenomenon is Part II.

## Proof

(i) Stage $d$ writes only layer $d \ge 1$. (ii) Induction on stages: after stage $d$, every vertex of layer $\le d$ carries $E(B(a))$ — layers $< d$ untouched by stage $d$ (induction hypothesis), and a layer-$d$ vertex is rewritten from parents that live in layers $< d$ and are already correct. (iii) Strong induction on the layer: a consistent state agrees with $E(B(a))$ on layer $0$ by definition and propagates upward through its own functional equations. (iv) Let $y = R(a)$; by (iii) $y = E(B(y)) = E(B(a))$. $\blacksquare$

## Why this happens

If the boundary is the full input layer of a circuit, of course it determines the bulk — the theorem's value is not surprise but *form*: it is the first machine-checked instance where $H_B$ and $H_{\mathrm{fib}}$ hold **jointly** for a natural repair (the sweep) on a multi-edge carrier, so Route A (T4b) has a real, non-vacuous home. The corollary (iv) is quietly the strongest sentence: it is repair-agnostic — *any* process that protects the boundary and reaches consistency has no freedom left in its output. The chain keeps the honest label "feed-forward class" attached because the boundary here is not *smaller* than the information content; making it smaller, and finding the exact threshold where it stops working, is precisely the jewel of the next Part.

## In plain language

Think of a spreadsheet where row 0 holds the inputs and every later row is computed from earlier rows by fixed formulas. Obviously the inputs determine the whole sheet. The theorem grinds that obviousness into certified form — recompute row by row and you *always* land on the unique consistent sheet over your inputs, no matter how scrambled the sheet was before, and *any* cleanup procedure that doesn't touch row 0 and ends consistent must land on that very sheet. This settles the easy case of "the boundary determines the bulk": when the boundary is the complete set of inputs. The genuinely deep case — a boundary much *smaller* than the inputs that still determines everything because the universe's law weaves redundancy through the record — is next.

---

# Part II — Holography on a cellular automaton

*Modules: `Rule90Cylinder.lean`, `CarrierBridge.lean`, `Rule90Decoding.lean`, `HexacodePort.lean`. The chain's review said the first theorem here "remains the open jewel"; it is now a sharp iff, extended to a complete classification of two-column screen geometry at every stride. **Prior art (added after the audit's F7):** the *sideways-solve* itself is classical — Rule 90 is bipermutive, and for bipermutive 1-D CA it is textbook symbolic dynamics that a width-2 vertical strip of the spacetime diagram determines the bi-infinite configuration (Hedlund's permutive-CA theory; Boyle–Lind expansive subdynamics; Kůrka's classification — Appendix C). What is new here is the *finite-cylinder* theory: the sharp counting threshold $n \le 2(t+1)$, its boost and stride variants, and the complete classifications (T20, T25) — plus the machine-checking of all of it.*

## The setting, once

**Rule 90 on the $n$-cylinder.** Cells sit on a ring $\mathbb{Z}/n$; each carries a bit; one time-step is

$$(\mathrm{ev}\,x)(j) \;=\; x(j-1) + x(j+1) \pmod 2 .$$

The **spacetime block** of a seed row $z : \mathbb{Z}/n \to \mathbb{F}_2$ is its trajectory $\mathrm{traj}(z, i) = \mathrm{ev}^i(z)$ for $i = 0, 1, \dots, t$. Because $\mathrm{ev}$ is $\mathbb{F}_2$-linear, the set of valid blocks is a **linear code of dimension $n$** (the seed is free; every later row is determined): $2^n$ codewords, each a $(t{+}1) \times n$ array of bits satisfying the local constraint everywhere.

**The decodability question.** Call a set $S$ of spacetime cells an **information set** if the values on $S$ determine the entire block:

$$\forall\, x, y:\ \big(\forall (i,j) \in S:\ \mathrm{traj}(x,i)(j) = \mathrm{traj}(y,i)(j)\big) \implies x = y .$$

By linearity this is equivalent to the **vanishing form**: the only seed whose trajectory vanishes on all of $S$ is $0$. Which subsets are information sets? In particular: can a *thin, timelike* screen — a couple of columns watched over time — determine the whole bulk?

**The carrier reading.** `CarrierBridge.lean` re-packages the block as an OPH carrier: $t+1$ patches (one per row), $t$ edges ($i \to i+1$, exposing $(\mathrm{ev}\,\mathrm{row}_i,\ \mathrm{row}_{i+1})$), so *consistency = being a valid trajectory*. An information set gives a boundary satisfying $H_{\mathrm{fib}}$ **with the stronger equality conclusion**; the converse fails — gauge-equivalence tolerates kernel differences the information-set property forbids, and the failure is a theorem (`hfib_strictly_weaker_than_informationSet`, new in v7 after the audit's F20: on the $n{=}3, t{=}1$ cylinder the full row-1 readout satisfies the $H_{\mathrm{fib}}$ binder verbatim while two distinct consistent records share it). So the screen theorems answer a question strictly *harder* than Route A's hypothesis.

# 11. The jewel: the width-2 timelike screen is sharp (T9)

## Statement

Fix $n \ge 1$, a horizon $t \ge 0$, and a base column $j_0 \in \mathbb{Z}/n$. The **width-2 timelike tube** is the screen

$$\mathrm{Tube}(j_0, t) \;=\; \{\,(i, j_0),\ (i, j_0{+}1) \;:\; 0 \le i \le t\,\}$$

— a readout of $2(t{+}1)$ bits: two adjacent columns, watched for $t{+}1$ ticks.

**Theorem T9 (the sharp threshold).**

$$\mathrm{Tube}(j_0, t) \text{ is an information set} \quad\Longleftrightarrow\quad n \;\le\; 2(t+1).$$

That is: the screen reconstructs the whole spacetime block **exactly when its raw cell count reaches the code dimension** — the geometric (light-cone) bound and the information-counting bound coincide, so the timelike screen *saturates the information bound*: it is an information-theoretically perfect holographic screen. *(Lean: `tube_information_set_iff`.)*

**Sharpness on every side (same module):**

- **Width 1 fails at every horizon.** For $n \ge 3$ there is a nonzero seed whose trajectory vanishes on the single column $j_0$ for *all* time (`single_column_not_information_set`); for $n = 2$ likewise, by nilpotency (`single_column_fails_two`). Minimal screen width is exactly 2.
- **No spacelike shortcut.** No proper subset of the initial row is ever an information set (`spacelike_proper_subset_fails`): reconstruction-from-a-part is a strictly *timelike* phenomenon on the cylinder.
- **Carrier form.** On the $(t{+}1)$-patch carrier, the tube readout (2 of $n$ cells per row — a proper, arbitrarily sparse part of each interface, provably coarser than the full observable) discharges $H_{\mathrm{fib}}$ in the Lean core's exact binder form when $n \le 2(t+1)$, with the *stronger* conclusion $x = y$; and fails it when $n > 2(t+1)$ (`rule90Cylinder_Hfib_tube`, `…_sharp`, `…_column_fails`, `tubeBoundary_strictly_coarser`).

## Proof

By linearity, prove the vanishing form: if $\mathrm{traj}(z, i)$ vanishes on both tube columns for all $i \le t$ and $n \le 2(t+1)$, then $z = 0$.

**The sideways light-cone sweep.** The Rule-90 constraint $\mathrm{traj}(z, i{+}1)(j) = \mathrm{traj}(z,i)(j{-}1) + \mathrm{traj}(z,i)(j{+}1)$ can be *solved for a neighbour*:

$$\mathrm{traj}(z,i)(j{+}1) \;=\; \mathrm{traj}(z,i{+}1)(j) \;-\; \mathrm{traj}(z,i)(j{-}1).$$

So two adjacent columns known to vanish propagate their vanishing *sideways*: if columns $j_0, j_0{+}1$ vanish up to time $t$, then column $j_0{+}1{+}r$ vanishes up to time $t - r$ — one time step is spent per column gained (proved by a two-column strong induction on $r$). This is the **rightward sweep**; the **leftward sweep** follows free of charge from a symmetry: Rule 90 commutes with every reflection $c \mapsto m - c$ of the ring, and the reflection through the tube's midpoint ($m = 2j_0 + 1$) swaps the two tube columns, converting the rightward sweep into the leftward one.

**Reaching the seed.** Write any cell $c$ of the seed row as $c = j_0 + 1 + r$ with $0 \le r < n$. If $r \le t$, the rightward sweep reaches it at time $0$. Otherwise set $l = n - 1 - r$, so $c = j_0 - l$ on the ring; from $n \le 2(t+1)$ and $r > t$ one gets $l \le t$, and the leftward sweep reaches it. Every seed cell is inside one of the two sideways light-cones, so $z = 0$.

**Converse (counting).** The readout map sends $2^n$ seeds into $2^{2(t+1)}$ possible tube histories; injectivity forces $2^n \le 2^{2(t+1)}$, i.e. $n \le 2(t+1)$.

**Width-1 failure (the mirror kernel).** For $n \ge 3$, take the two-cell seed $z = \delta_{j_0+1} + \delta_{j_0-1}$ (indicators). It is symmetric under the reflection through $j_0$; since the dynamics commutes with that reflection, *every* row of its trajectory keeps the symmetry. The two neighbours of $j_0$ are mirror images, hence always equal, and their $\mathbb{F}_2$ sum — which is the next value at $j_0$ — is always $0$; at time $0$, $z(j_0) = 0$ as well. So a nonzero seed is invisible on the column forever: no horizon helps. ($n = 2$: both neighbours of any cell coincide, so $\mathrm{ev}\,x = x + x = 0$ kills everything in one step; the seed $\delta_{j_0+1}$ is nonzero and invisible.)

**Spacelike failure.** A proper subset $S \subsetneq \mathbb{Z}/n$ of the initial row misses some cell $c_0$; the seeds $\delta_{c_0}$ and $0$ agree on $S$ and differ. $\blacksquare$

## Why this happens

Three facts conspire. *(a) The constraint is invertible sideways:* Rule 90's local law can be read as "right neighbour = future − left neighbour", so knowledge flows not only forward in time but *across space*, at one column per time step — a sideways light-cone. A width-2 screen watched for duration $t$ therefore commands a spatial reach of $t$ columns in each direction: total reach $2t + 2$ cells including itself, which is exactly its own cell count. *(b) Counting caps everything:* no screen can ever beat one recovered seed-bit per read bit. The theorem's content is that these two bounds — one geometric, one information-theoretic — *touch*: the screen wastes nothing. *(c) Width 2 is the minimum aperture because of symmetry:* a single column cannot break the ring's mirror symmetry through itself, and the mirror-symmetric part of the seed space is a blind spot forever. The spacelike negative completes the picture: on a translation-invariant ring, the initial row has no redundancy at all (the seed is exactly the free data), so spacelike reading buys only what it reads; all redundancy in the code is woven *through time*. This is the chain's mathematical model of holography-as-error-correction (Almheiri–Dong–Harlow's lesson, Layer 1 — with the direction stated honestly: here the screen must be read *completely*; the code corrects erasure of the bulk given the screen, not erasures of the screen itself): the "boundary reconstructs the bulk" property holds, holds for a *thin timelike* boundary, and holds *exactly at* the information-theoretic threshold — and in carrier language it discharges Route A's $H_{\mathrm{fib}}$ on a genuinely multi-edge carrier from a proper-subset boundary, which was the named open jewel. **Scope, stated where the jewel is shown** (the adversarial audit's F2): $H_{\mathrm{fib}}$ is the *static* half of Route A. On this same carrier no repair operator can satisfy the three local laws (now a theorem for **every** cylinder — Section 11a), and T12's canonical operator can terminate on inconsistent records (also now a theorem, with the audit's exact witness). The composition "run the dynamics, let the boundary pin the world" therefore needed T6-style *transactional* repair with a local sweep order — **and, as of v7, has it**: Section 11a (T27) runs exactly that repair on exactly this carrier, jointly with the sharp $H_{\mathrm{fib}}$.

## In plain language

Picture a loop of $n$ light bulbs evolving in lockstep by a simple XOR rule, and suppose you may only watch **two adjacent bulbs** — but you may watch them for a long time, $t{+}1$ ticks. Can your narrow peephole reveal the *entire* history of all $n$ bulbs? The theorem answers with an exactness that is rare outside pure mathematics: **yes, precisely when the number of bits you've seen, $2(t{+}1)$, reaches the number of bulbs $n$ — and never a single tick sooner.** Watching long enough is not merely helpful; it is *perfectly efficient* — each observed bit ends up carrying one full bulb's worth of the hidden past, with zero waste. The fine print is equally sharp: one bulb alone never suffices (some ghost patterns are exactly mirror-symmetric around it and cancel there forever), and glancing briefly at *many* bulbs never beats reading them all (a snapshot has no redundancy to exploit; only *time* weaves the redundancy). A thin strip of "boundary", watched patiently, holds the whole "bulk" — a working, fully proven miniature of the holographic principle.

# 11a. Route A assembled: the decode-repair and the screen in one room (T27, new in v7)

## Statement

**Theorem T27** (`RouteA.lean`). On the Rule-90 $n$-cylinder with horizon $t$, at the sharp threshold $n \le 2(t+1)$, fix the width-2 tube $\{j_0, j_0{+}1\}$. There is a family of **local decode transactions** — each writes a single cell of a single patch, reading only that patch and one edge-adjacent patch, enabled exactly when its *declared formula* disagrees with the cell — such that:

1. *(liveness)* from every record, the declared rank schedule reaches a normal form in one finite pass; normal forms are exactly the decode-quiescent records;
2. *($H_B$)* every accepted transaction preserves the tube reading;
3. *(observer uniqueness)* any two records with equal tube reading settle — under **any** schedules, to **any** normal forms — to the **same** record (literal equality; no realizability assumed);
4. *(completeness ⟺ realizability)* the settled world is consistent **iff** some consistent record carries the starting tube reading; on unrealizable fibers **no** record is consistent, so any tube-preserving repair must settle inconsistent there — by logic, not weakness;
5. *(jointly with the jewel)* on the same carrier, the consistent fiber over any tube reading is a singleton (T9′).

And both negatives are theorems: **no** operator satisfies $H1 \wedge H2 \wedge H3$ on the cylinder carrier, for every $n \ge 1, t \ge 1$ (`rule90CylinderOPH_no_frustrationFree_repair`); and the canonical T12 operator, started from the audit's record $(0, \delta_0, \delta_1)$ on $n{=}3, t{=}2$, fires exactly once and stalls at $(0, \delta_0, \mathrm{ev}\,\delta_0)$ with edge 0 broken forever (`canonical_repair_stalls`) — on a fiber that provably contains no consistent record at all (`stallRecord_tube_unrealizable`).

## Proof

The declared structure is a **responsibility roster**: each non-tube column, at offset $u \in [1, n-2]$ from the tube, is assigned to the right sweep (if $u \le R := \min(t, n{-}2)$), else the left sweep (distances $\ell = n{-}1{-}u \le L := (n{-}2){-}R$), each within its light cone ($\text{row} + \text{distance} \le t$); everything deeper is downward territory. A roster with both budgets $\le t$ exists **iff** $n \le 2(t+1)$ — the same threshold as the screen theorem, because the roster *is* the decoding strategy the information-set theorem certifies. The formulas are the CA constraint solved sideways (right: $x_i(c) = x_{i+1}(c{-}1) + x_i(c{-}2)$; left mirrored; downward: the constraint verbatim), so on a consistent record every formula already holds (characteristic 2 makes the rearrangement an identity). The load-bearing lemma is **stratification**: every formula reads strictly below its own declared rank, so (i) one pass in rank order leaves every cell matched forever, and (ii) the formulas pin a quiescent record cell-by-cell, by strong induction on rank, from the tube outward. Uniqueness is then the linear trick: formulas commute with record subtraction, so the difference of two quiescent records with equal tube is a formula-quiescent record with zero tube — killed stratum by stratum. Completeness on realizable fibers: the consistent witness is itself quiescent, so the settled world equals it. The negatives: $\delta_0$ has odd weight while every Rule-90 image has even weight (the cells of $\mathrm{ev}\,x$ sum to zero — each seed cell is counted twice), so a record with row 1 $= \delta_0$ has its first edge broken for every seed; $H2$ forces the seed patch to fire, $H1$ pins row 1, and $H3$ demands the impossible preimage. $\square$

## Why this happens

The audit's F2 said the chain's two showcase results — the correction dynamics and the holographic window — lived in different rooms, and provably could not share the exhibited room *in the local-repair reading*. The repair was not to weaken the window but to change what "repair" carries: the impossibility is specifically about operators that must fix **all** of a patch's interfaces at once (frustration-freeness); the decode transactions instead let the *boundary* say what each cell should be, one cell at a time, along a declared schedule. The price is exactly one more piece of declared structure — the roster — and the chain's own Route-B lesson already set the precedent of billing declared structure rather than pretending it away. What is genuinely new is that the threshold for the roster to exist coincides with the threshold for the screen to determine the bulk: the dynamics can be assembled *precisely when* the boundary has something to say. The stall witness completes the honesty: where the boundary's fiber is empty, every boundary-respecting dynamics must stall, so the audit's stall was not a defect of the canonical operator but an instance of a dichotomy the assembled theory now states.

## In plain language

The audit's sharpest structural complaint was: "your correction process and your magic window have never been run in the same room — and in the room with the window, the correction provably jams." That room now works. Give every cell of the office one declared rule — "your value is computed *this* way from your neighbours, working outward from the window" — and let clerks apply their rules in any order whatsoever. Three things are now proven: the office always settles; the window's cells are never overwritten; and **two offices that agree on the window always settle to the identical story, no matter who moved first in either**. If some fully consistent story matches the window, the settled story *is* it — the unique one the window theorem promised. If no consistent story matches the window (the audit's jamming example is exactly such a case — machine-checked), then settling in disagreement is not a bug: there was provably nothing consistent to settle to, and no window-respecting procedure could do better. The one honest price: someone had to write the rulebook assigning each cell its rule — the same kind of price the theory already pays, and bills, for its published turn order.

# 12. Decodability in general: boost invariance and the parity obstruction (T18)

## Statement

**The framework.** For an arbitrary finite set $S$ of spacetime cells: $S$ is an information set iff the only seed vanishing on $S$ is $0$ (`isInformationSet_iff_vanishing`); this makes the property **decidable** (finite check over $2^n$ seeds), so concrete instances are machine-decidable; it is monotone under $\supseteq$; and the **universal counting bound** holds: $|S| < n \implies S$ is not an information set (`card_lt_not_informationSet`).

**Theorem T18a (boost invariance; `n ≥ 1` — `[NeZero n]` — throughout this Part).** The **lightlike tube** — the width-2 screen tilted onto a light-cone diagonal, reading cells $\{(i,\, j_0{+}i),\ (i,\, j_0{+}i{+}1) : 0 \le i \le t\}$ — is an information set **iff $n \le 2(t+1)$**: the same sharp threshold as the timelike tube. Tilting the screen changes the decoding geometry (the sweep becomes one-sided but double-speed) yet not the capacity: **a width-2 adjacent screen saturates the information bound at both extreme slopes — rest frame and light cone.** Screens at intermediate rational slopes (a moving observer's window) are definable and remain **open**; machine experiment at slopes 1/2, 1/3, 2/3, 1/4, 3/4 for all `n ≤ 20` finds decoding at exactly the same sharp threshold in every case (artifact, floor-convention screen definition, and output tables: `proof_chain/formal/evidence/decodability_checker.py` — committed in v7 after the audit's F22), so the conjecture is full slope-invariance — but the theorem so far covers the two extremes. *(Lean: `lightTube_isInformationSet_iff`.)* **Update (v9): the conjecture is now a theorem, and more — the threshold is invariant across every 1-Lipschitz worldline, §13b (T36).**

**Theorem T18b (the parity obstruction — adjacency is load-bearing).** On every **even** cylinder, the **gap-2 screen** reading columns $\{j_0,\ j_0{+}2\}$ is *never* an information set, at any horizon — for $n \ge 4$ even by the chequerboard argument below, and for $n = 2$ because the screen degenerates to a single column on the nilpotent cylinder. *(Lean: `gapTwoTube_fails_even`, `gapTwoTube_fails_two`.)*

## Proof

*Framework.* Vanishing form: readouts are linear in the seed, so equal readouts ⇔ the difference vanishes on $S$. Counting: an injective map from $2^n$ seeds into $2^{|S|}$ readouts needs $|S| \ge n$.

*T18a.* The one new computation is the **double-speed one-sided sweep**: solving the constraint *along the tilted diagonal* — at cell $(i,\ j_0 + i + u + 1)$, the constraint's "future" point $(i{+}1,\ j_0+i+u+1)$ itself lies one diagonal step along the screen's direction — advances the known-zero region by **two columns per time step** on one side (Lean: `light_sweep`, proving vanishing at all offsets $u$ with $u + 2i \le 2t + 1$). At time $0$ this cone covers offsets $u \le 2t+1$, i.e. $2t+2$ consecutive cells including the two read ones — everything, once $n \le 2(t+1)$. There is no second side (the screen outruns its own left flank), but none is needed: one cone at double speed covers what two cones at single speed covered. Failure for $n > 2(t+1)$ is the general counting bound (the tilted screen still has $\le 2(t+1)$ cells).

*T18b.* Colour the ring by displacement parity from $j_0$ and take the **alternating seed** $z_{\mathrm{alt}}(j_0 + r) = r \bmod 2$ — well-defined on the ring exactly because $n$ is even. Two facts: (i) *it dies in one step:* the two neighbours of any cell have parities $p-1$ and $p+1$, equal mod 2, so their $\mathbb{F}_2$ sum is $0$ — $\mathrm{ev}(z_{\mathrm{alt}}) = 0$, and every later row is $0$; (ii) *the screen never sees it:* both read columns sit at even displacement ($0$ and $2$), where $z_{\mathrm{alt}} = 0$, so row $0$ reads zero too. A nonzero seed ($n \ge 3$: the cell at displacement 1 carries a 1) invisible forever. For $n = 2$: $j_0 + 2 = j_0$, the "gapped" screen degenerates to a single column, and the indicator of the unread cell dies in one step (nilpotency). $\blacksquare$

## Why this happens

Two independent surprises, both machine-found. *Boost invariance:* one might guess a screen tilted to the light-cone reads "half new information per tick" and loses capacity (the module's docstring records that the author conjectured exactly that); instead the tilt trades the *number of sweep fronts* against their *speed* — two fronts at speed 1 become one front at speed 2 — and capacity is exactly conserved. The screen's power is slope-robust at both proved extremes (and — since v9, by theorem — at every slope in $[0,1]$ and indeed every 1-Lipschitz worldline: §13b). *The parity obstruction:* Rule 90's constraint couples a cell only to neighbours at distance 1, so the spacetime lattice splits into two chequerboard classes that interact but do not mix positions of fixed parity at fixed time along distance-2 reads; a gapped screen on an even ring reads *one class only*, and the other class contains a kernel state (the alternating seed) that is, additionally, invisible after one tick. So what T9's screen actually exploits is not "being timelike" (tilt is irrelevant) and not "being narrow" — it is **parity coverage**: touching both chequerboard classes. This re-diagnosis is completed, and turned into a full classification, by T20.

## In plain language

Two follow-up experiments on the peephole. First: what if the peephole *moves* — each tick, you watch the next pair of bulbs around the loop, riding along at the speed of the pattern itself? Intuition says a moving window should catch less; the theorem says it catches *exactly as much* — same perfect threshold. The window's power doesn't care about its state of motion. Second: what if you keep two fixed bulbs but leave a gap between them — watch bulbs 0 and 2 instead of 0 and 1? On loops with an *even* number of bulbs this is ruined *forever*: paint the bulbs alternately black and white, and note both your watched bulbs are black. There is a ghost pattern living only on the white bulbs that vanishes entirely after one tick — you can never see it, no matter how long you watch. So the real secret of the perfect peephole was neither its narrowness nor its stillness: it was that its two bulbs had *different colours*.

# 13. The complete parity classification of the gapped screen (T20)

## Statement

**Theorem T20.** For every cylinder size $n$, horizon $t$, and base $j_0$:

$$\{j_0,\ j_0{+}2\} \times [0,t] \text{ is an information set} \quad\Longleftrightarrow\quad n \text{ is odd} \;\wedge\; n \le 2(t+1).$$

On **odd** cylinders the gapped screen recovers the *full adjacent capacity at the same sharp threshold*; on even cylinders, never (T18b). Together with T18a: **for width-2 screens, tilt (boost) is irrelevant, and separation matters exactly through cycle parity.** *(Lean: `gapTwoTube_isInformationSet_iff_parity`, via `gapTwoTube_isInformationSet_iff_odd`; the v4 `decide`-instance `gapTwo_five_two` survives as a cross-check.)*

## Proof

Only the odd-$n$ sufficiency is new (failure: counting bound; even case: T18b). Let $n$ be odd, $n \le 2(t+1)$ (equivalently $n \le 2t+1$, as an odd number cannot equal $2t+2$), and let $z$ vanish on both screen columns up to time $t$. Three moves, the last one *algebraic*:

**1. The enclosed middle column.** The Rule-90 constraint *at the middle cell* $(k{+}1,\ j_0{+}1)$ reads its two inputs at columns $j_0$ and $j_0{+}2$ — **both on the screen**:

$$\mathrm{traj}(z, k{+}1)(j_0{+}1) = \mathrm{traj}(z,k)(j_0) + \mathrm{traj}(z,k)(j_0{+}2) = 0 \qquad (0 \le k \le t).$$

So the middle column vanishes at all times $1 \le i \le t{+}1$ — determined one step *later* than the screen (its seed cell, time 0, stays invisible). This decoding really is different from the adjacent sweep: the screen's columns *enclose* a third column and squeeze it out of the constraint.

**2. Two fans zero out row 1.** With three consecutive vanishing columns (on time windows starting at 1), the sideways sweep of T9 runs from the pair $(j_0{+}1, j_0{+}2)$ rightward and — by the reflection through the screen's midpoint $m = 2j_0+2$, which swaps $j_0 \leftrightarrow j_0{+}2$ — leftward from $(j_0, j_0{+}1)$, each losing one time step per column but starting at time 1. Once $n \le 2t+1$, the two fans and the middle column jointly cover the whole ring **at time 1**: $\mathrm{traj}(z,1) = 0$, i.e. $\mathrm{ev}(z) = 0$. The fans can *never* reach time 0 (the middle column's time-0 cell is invisible), so the sweep alone cannot finish —

**3. — the seed dies by algebra.** Suppose $\mathrm{ev}(z) = 0$. The constraint at $j{+}1$ says $z(j) + z(j{+}2) = 0$, i.e. $z(j{+}2) = z(j)$ over $\mathbb{F}_2$: **$z$ is constant along the distance-2 walk** $j \mapsto j + 2$. On an **odd** ring, $2$ is invertible mod $n$, so the distance-2 walk visits *every* cell: $z$ is globally constant. And the screen reads $z(j_0) = 0$ at time 0, killing the constant: $z = 0$. (On an even ring the same walk has exactly two orbits — the chequerboard — and the surviving orbit is precisely T18b's alternating kernel seed: the two halves of the classification are the two behaviours of one walk.) $\blacksquare$

## Why this happens

The gapped screen loses the adjacent screen's direct sweep (its columns are not neighbours), but gains something else: its columns *bracket* a hidden column whose every later value is an XOR of screen values. That restores three consecutive columns — one tick late — and the late start costs exactly the seed row, which must then be recovered by a *global* argument rather than a local sweep. The global argument is where the ring's parity enters irreducibly: "killed in one step" means "constant along steps of two", and steps of two generate the whole ring iff the ring is odd. So the classification's boundary is not an artifact of a proof technique — it is the orbit structure of $j \mapsto j+2$ on $\mathbb{Z}/n$, i.e. $\gcd(2, n)$. This resolves the question T18 left open (v4 had only a decided instance on the 5-cylinder as evidence) and closes the width-2 story completely; the natural generalization — stride-$g$ screens work iff $\gcd(g,n) = 1$ — was conjectured here in v5 and is now itself a sharp theorem (T25, next section): parity was the shadow of the gcd.

## In plain language

The gap experiment, finished. On an odd loop the gap costs *nothing*: watching bulbs 0 and 2 is exactly as powerful as watching 0 and 1, perfect threshold included — but the *reason* is delightfully different. Your two bulbs surround bulb 1, and the rule makes tomorrow's bulb 1 the XOR of today's bulbs 0 and 2 — both of which you see. So you learn the middle bulb (a day late), then sweep sideways around the loop as before, and you end up knowing the *entire second day* is dark. The last step is a pincer of pure logic: a pattern that dies in one day must repeat every two bulbs around the loop; on an odd loop, stepping by twos eventually visits *every* bulb, so such a pattern must be the same everywhere; and you saw one bulb dark on day one — so the pattern was nothing at all. On an even loop, stepping by twos visits only half the bulbs, exactly the blind half where the ghost lives. One tidy dichotomy: **a stretched peephole works precisely when the loop is odd** — and the machine has checked every clause of it.

# 13a. The coprimality classification: every two-column screen (T25)

*Module: `Rule90Stride.lean` (new in v6). The v5 edition of this paper listed "stride-$g$ screens work iff $\gcd(g,n) = 1$" as a conjecture; it is now a sharp theorem — stronger than conjectured, since nothing is lost at the threshold either — and its proof produced two tools of independent value, the mirror lemma and the quotient lift.*

## Statement

**Theorem T25 (`gapTube_isInformationSet_iff`).** On the Rule-90 $n$-cylinder run for $t$ steps, for every base column $j_0$ and every stride $g \in \mathbb{N}$: the two-column screen $\{j_0,\ j_0{+}g\} \times [0,t]$ is an information set **iff**

$$\gcd(g, n) = 1 \qquad\text{and}\qquad n \le 2(t+1).$$

So coprime strides keep the **full adjacent capacity at the same sharp threshold**, and non-coprime strides fail at **every** horizon. Special cases, re-derived in-file as consistency checks (`tubeSet_iff_via_stride`, `gapTwoTube_parity_via_stride`, `gapTube_zero_iff`): $g = 1$ ($\gcd = 1$ always) is T9's sharp iff; $g = 2$ ($\gcd(2,n) = 1 \iff n$ odd) is exactly T20's parity classification — two independent proofs now agree; $g \equiv 0$ ($\gcd = n$) decodes only the trivial 1-cylinder — the width-1 negatives in one line. Boundary instances are kernel-checked by `decide`: $(n,g,t) = (8,3,3)$ decodes at the exact threshold, $(8,3,2)$ fails by counting, $(9,3,4)$ fails by gcd with time to spare.

Two lemmas carry the theorem and are stated separately because each is independently useful:

**The mirror lemma (`mirror_of_column_dark`).** If a trajectory's column $j_0$ is zero at all times $0, \dots, t$ and $n \le 2(t+1)$, the seed is mirror-symmetric about $j_0$: $z(x) = z(2j_0 - x)$ for every cell $x$. *A single dark column pins the whole antisymmetric sector of the seed* (plus its own centre cell, read at time 0) — and its failure kernel consists of the mirror-symmetric seeds with dark centre, v3's mirror seeds (forward inclusion is the lemma; the converse is assemblable, unformalized — audit F29): the width-1 failure theorem and the mirror lemma are two halves of one fact.

**The quotient lift (`traj_comap`, `mirrorPair_dark`).** For $d \mid n$, cell-wise reduction $\mathbb{Z}_n \to \mathbb{Z}_d$ is a covering of the dynamics: the trajectory of a pulled-back seed is the pulled-back trajectory. And every $d$-cylinder with $d \ge 2$ carries a nonzero seed whose whole trajectory is dark on one chosen column — the mirror pair $\delta_{+1} + \delta_{-1}$ about it (at $d = 2$ the pair degenerates to the single cell $\delta_1$, whose lift is T18b's alternating checkerboard seed).

## Proof

*Failure, $d := \gcd(g,n) \ge 2$.* Both read columns reduce to the **same** column of the $d$-cylinder ($j_0 + g \equiv j_0 \bmod d$, since $d \mid g$). Lift the mirror-pair seed of the $d$-cylinder along the covering: the lift is nonzero (it reads $1$ at $j_0{+}1$), and its trajectory — the pullback of the quotient trajectory — vanishes on both read columns at every time, because downstairs the one column they both cover is dark forever. Darkness downstairs is a symmetry argument: the pair seed is mirror-symmetric about the centre; the rule's stencil is symmetric, so symmetry propagates; a symmetric row's next value at the centre is $u(c{-}1) + u(c{+}1) = u(c{+}1) + u(c{+}1) = 0$ over $\mathbb{F}_2$; and the time-0 centre value is $0$ because $d \ge 2$ puts both pair cells off-centre. So the screen has a kernel element at every horizon. (For $n > 2(t+1)$, failure is the universal counting bound, as always.)

*The mirror lemma.* Consider the mirror defect about the dark column, $D_i(u) = x_i(j_0{+}u) + x_i(j_0{-}u)$, as a configuration in the displacement $u$. Two observations: (i) regrouping the four stencil terms gives $D_{i+1}(u) = D_i(u{-}1) + D_i(u{+}1)$ — **the defect is itself a Rule-90 trajectory** in displacement space; (ii) $D_i(0) = 0$ identically, and $D_i(1) = x_i(j_0{-}1) + x_i(j_0{+}1) = x_{i+1}(j_0) = 0$ for $i < t$ — **the defect is dark on the adjacent pair of columns $\{0, 1\}$**. A one-sided sideways sweep (solve the constraint for the outer displacement, losing one time step per column) yields $D_i(u) = 0$ whenever $i + u \le t$; at $i = 0$ the defect dies at every displacement $u \le t$. If $n$ is odd, $n \le 2(t+1)$ forces $n \le 2t+1$, and displacements up to $(n-1)/2$ — all of them — are covered. If $n$ is even, the sweep reaches $n/2 - 1$, and the one displacement left, the antipode $n/2$, is *identically zero*: $j_0 + n/2$ and $j_0 - n/2$ are the same cell, so the defect there compares a cell with itself. Either way $D_0 = 0$: the seed is symmetric about $j_0$.

*Success, $\gcd(g,n) = 1$, $n \le 2(t+1)$.* The mirror lemma at both read columns makes the seed symmetric about $j_0$ *and* about $j_0{+}g$; the composition of the two reflections is a translation, so the seed is $2g$-periodic: $z(x + 2g) = z(2(j_0{+}g) - (x + 2g)) = z(2j_0 - x) = z(x)$. Coprimality finishes. If $n$ is odd, $2g$ is invertible mod $n$, every cell is $j_0 + 2gk$, and the single time-0 reading $z(j_0) = 0$ kills everything. If $n$ is even, $g$ is odd (else $2 \mid \gcd$); displacement parity from $j_0$ is a ring homomorphism $\mathbb{Z}_n \to \mathbb{Z}_2$ (well-defined because $2 \mid n$); even-displacement cells are $2g$-reachable from $j_0$ (invert $g$ mod $n$ and double the congruence), odd-displacement cells are $2g$-reachable from $j_0{+}g$, and the two time-0 readings kill the two classes. $\blacksquare$

## Why this happens

T20 looked like a statement about *parity*; T25 shows it was about *divisibility* all along. The structure underneath is the pair (reflection group, covering space). A dark column is not an absence of information but a *constraint*: by the mirror lemma it pins the entire antisymmetric sector of the code (and its own centre cell). Two dark columns pin two reflections; two reflections compose to the translation by twice the separation; and the screen sees everything iff that translation, seeded at the two read columns, walks the whole ring — an arithmetic condition, $\gcd(g,n) = 1$. When instead $d = \gcd \ge 2$, the ring covers a ring of size $d$ in which the two columns *coincide*, and the smaller ring always owns a pattern invisible to a single column — the mirror pair about it; pulled back, that pattern is invisible to the whole screen forever. The v4/v5 special cases fall out: T18b's checkerboard seed is the $d = 2$ lift, and T20's "algebraic seed-descent" is the odd branch of the coprime kill. The threshold, finally, is *still* $n \le 2(t+1)$ with no loss at any coprime stride, because the mirror lemma spends its budget in displacement space — where every screen is adjacent.

## In plain language

Final round of the bulb game. Watch any two bulbs on the loop of $n$, separated by however many steps you like, for the usual amount of time. Can you always reconstruct the whole history? The machine-checked answer is one line of arithmetic: **yes, exactly when the separation and the loop size share no common factor.** The surprise inside the proof is what one watched bulb is worth: a bulb that stays dark acts as a perfect *mirror* — everything about the initial pattern that is lopsided around it gets pinned down completely, and what it can never tell you is precisely the part that looks identical in the mirror. Two watched bulbs give two mirrors, and two mirrors make a kaleidoscope: they shove the pattern around the loop in hops of twice the separation. In the no-common-factor case the hops trap the even-displacement half of the pattern, and the second bulb's mirror traps the other half — so the pattern must be blank. If the separation and the loop share a factor, say 3, the loop folds onto a loop one third the size *in which your two bulbs land on the same spot*, and that smaller loop always hides a ghost: a pattern its one watched bulb can never see, which unfolds into a ghost on the big loop that your whole screen never sees. Stretch the peephole however you like — only the arithmetic decides.

# 13b. The Lipschitz worldline theorem: the slope conjecture, closed (T36, new in v9)

*Module: `Rule90Lipschitz.lean` (new in v9). Every edition of this paper since v4 carried the same open conjecture: screens at intermediate slopes decode at the same sharp threshold as the two proved extremes (rest frame, T9; light cone, T18a). It is now a theorem — and, as with T25, stronger than conjectured: the threshold is invariant not merely for every rational slope but for every 1-Lipschitz worldline, and the decoding is local constraint propagation, not just linear algebra.*

## Statement

**Theorem T36 (`pathScreen_isInformationSet_iff`, `pathScreen_closure_complete`).** Let $c : \mathbb{N} \to \mathbb{Z}$ be any **1-Lipschitz column path** — $|c(i{+}1) - c(i)| \le 1$, an observer moving at most one column per tick — and let the *worldline screen* read the adjacent pair $\{j_0 + c(i),\ j_0 + c(i) + 1\}$ at each time $i \le t$. Then:

1. *(capacity, sharp, path-uniform)* the worldline screen is an information set **iff** $n \le 2(t+1)$ — the same sharp threshold as the static tube, for **every** such path: slopes, zigzags, reversals;
2. *(local decodability)* at the threshold the screen's **constraint-propagation closure is the entire spacetime block** (`pathScreen_closure_complete`): a causal observer decodes the world by repeatedly applying single Rule-90 constraints, no global linear algebra required — T30b extended from the static observer to every causal one.

**Corollary (the slope conjecture, holes-audit F6; `slopeTube_isInformationSet_iff`).** For every rational slope $0 \le p/q \le 1$ (floor convention), every $n$, $t$, $j_0$: the sloped screen of T34-lite is an information set **iff** $n \le 2(t+1)$. T9 is the slope-$0$ extreme, T18a the slope-$1$ extreme, and the v8 kernel instances are sample points.

**Beyond the Lipschitz class the landscape is provably wild** (kernel-checked): at $(n,t) = (6,2)$ the complete classification of pair screens $[a,b,c]$ is *"the last step is Lipschitz"* (`pairScreen_class_6_2` — order-sensitive: $[0,0,2]$ fails while $[0,2,2]$ decodes, same step multiset); at $(8,3)$ **all** $8^4$ paths decode, teleports included; at $(10,4)$ the slope-2 line and the late jump **fail at exact capacity** while the same jump one step earlier decodes. So the Lipschitz hypothesis is sufficient at every size and necessary at none of the small ones, and no coarse invariant — step multiset, last step, cardinality — classifies the general case. (Sweep artifact: `formal/evidence/path_screen_sweep.txt`.)

**Coda — the gap-2 crawl, classified (T37; `Rule90Crawl.lean`).** The same fan engine, anchored on *inferred* pairs instead of screen cells, closes T30's named leftover: for the distance-2 screen at the sharp threshold, the constraint-propagation closure is the **entire block iff the ring is odd** (`gapTwo_closure_complete_iff_odd`). The two screen columns enclose the middle column (one downward rule per cell, times ≥ 1); the three columns carry two adjacent pairs whose fans cover row 1 completely whenever $n \le 2t+1$ — no parity hypothesis; and row 0 is reached by the crawl proper, two columns per step, which wraps the ring exactly when $2$ is invertible — odd $n$. On even rings the closure never reaches the seed row (T25's parity negative plus soundness). Corollary: T25's odd $g = 2$ half re-derives *through propagation* — the simulation's crawl (`oph_sim/FINDINGS.md` item 1) is not a heuristic but a decoder. With T30, the local decodability of two-column screens is classified at **every** ring distance: $d = 1$ complete at threshold, $d = 2$ complete iff odd, $d \ge 3$ nothing infers, ever.

## Proof

*Failure* is the universal counting bound, as always (a two-cell-per-time screen has at most $2(t+1)$ cells).

*Success* is a downward fan induction along the worldline, entirely local. Write $I_k$ for the integer column interval $[c(t) - k,\ c(t) + 1 + k]$ — width $2k+2$. Claim (`pathScreen_fan`): at level $i = t - k$ the propagation closure of the screen contains all columns of $I_k$. At $k = 0$ this is the screen pair itself. For the step, let the level below be covered and consider level $i$ with its screen pair $\{c(i), c(i){+}1\}$. Two chains grow the interval: solving the constraint $x_{i+1}(j) = x_i(j{-}1) + x_i(j{+}1)$ for its right cell marches rightward — each new cell consumes one already-inferred level-$(i{+}1)$ cell and the level-$i$ cell two columns back — and the mirror chain marches leftward. The chains are anchored at the screen pair, so they need the level-$(i{+}1)$ cells at columns $[c(i){+}1, \ldots]$ and $[\ldots, c(i)]$ respectively — and the **1-Lipschitz telescope** $|c(t) - c(i)| \le t - i = k+1$ is *exactly* the condition that places the level-$i$ screen pair inside $I_{k}$, so every cell the chains consume is already known. Each level therefore adds one column on each side: $I_{k+1}$ from $I_k$. At the seed row the interval has width $2(t+1) \ge n$ and wraps the ring; the downward rule then fills all higher rows, so the closure is the whole block, and soundness of propagation (`inferable_sound`, T30) turns closure into decoding. The v8-recorded sheared-CA attack — transforming the sloped screen into a time-inhomogeneous straight tube — was never needed; the shear's bookkeeping *is* the Lipschitz telescope, read geometrically. $\blacksquare$

## Why this happens

The screen's power was never about *where* the observer sits (T25 already showed stride doesn't matter when coprime) nor about *which frame* it moves in (T18a's surprise) — it is about staying inside the light cone of one's own past readings. The fan of level $k$ is precisely the set of columns whose value is forced by the screen's top $k{+}1$ readings, and it grows at speed one per side — the lattice light speed. A 1-Lipschitz worldline never outruns its own fan, so the fan never tears; a superluminal path can outrun it, and then capacity survives only by accidents of global algebra — which is exactly what the beyond-Lipschitz instances show: accidents present at $(8,3)$, absent at $(10,4)$, order-sensitive at $(6,2)$ because a late jump leaves no time for the fan to re-anchor while an early jump does. The Route-A reading: *any* causal observer's width-2 record pins the world at the same sharp capacity, by local inference alone — frame freedom in the worldline direction, which is what "holographic screen" ought to have meant all along.

## In plain language

Same bulb game, but now you are allowed to *walk* while you watch: each tick you may keep watching the same adjacent pair of bulbs or shift your gaze one bulb left or right — any itinerary you like, as long as you never move faster than the signals do. The machine-checked answer: **walking costs nothing.** Whatever wandering path you take, you reconstruct the whole history exactly when the sitting-still watcher could — and you can do it the lazy way, one little deduction at a time, never needing to solve equations about the loop as a whole. But try to *teleport* — hop two or more bulbs in one tick — and all bets are off: sometimes you still win (on the loop of 8, every itinerary wins, even absurd ones), sometimes you lose at full capacity (on the loop of 10, the steady two-per-tick sprint loses), and whether a single big hop hurts depends on *when* you make it (early is fine, last-minute is fatal, on the loop of 6). The dividing line between "always works, provably" and "genuinely lawless" is the speed of light on the lattice.

# 13c. The parity splitting and the diagonal observers (T38–T41, new in v10)

*Modules: `Rule90Parity.lean`, `Rule90TwoPower.lean`, `Rule90Diagonal.lean` (new in v10). The v9 edition left exactly one open mathematics item — the arbitrary-subset classification — and its simulation companion (`oph_sim` v2) answered with numerically-exact structure: finding R1 (the even-ring block splits into two Rule-60 sectors), conjecture C1 (the shadow atlas), conjecture C3 (two-power universality). The v10 campaign turned R1 and C3 into theorems, proved C1's containment half unconditionally, and found — via a probe on the way — a screen family nobody had asked about: the lone lightlike diagonal, the first one-cell-per-row information set, sharp at the absolute counting bound.*

## Statement

Throughout, `rule60` is the one-sided difference automaton $(\mathsf{T}y)(u) = y(u) + y(u{+}1)$, and the **bridge** (`traj_eq_rule60_iterate`) is the identity $\mathrm{traj}\,x\,i\,(j) = \mathsf{T}^{2i}x\,(j - i)$: Rule 90 *is* doubled Rule 60 composed with a unit drift.

**Theorem T38 (the parity splitting; `traj_parityProj`, `not_isInformationSet_iff_single_parity_shadow`).** On an even ring, the trajectory of the parity projection of a seed agrees with the full trajectory on the matching chequerboard sector and vanishes identically on the other: the two sectors never talk. Consequently an **arbitrary** cell set $S$ — any $n$ even, any $t$ — fails to be an information set **iff a nonzero single-parity ghost is dark on $S$**. The maximal ghost shadows all come from the $2^{n/2+1}-2$ single-parity seeds: the containment half of the simulation's shadow-atlas conjecture C1, unconditional. Moreover (`sectorTrace_succ`, the finding R1 itself): reading the block along a sector, in half-ring coordinates, evolves by **Rule 60 on $\mathbb{Z}/(n/2)$** — the even-ring Rule-90 block *is* two independent Rule-60 systems.

**Theorem T39 (two-power universality; `pairScreen_isInformationSet_iff_two_pow`, `pathScreen_isInformationSet_iff_two_pow`).** On $n = 2^k$, **every** adjacent-pair worldline screen — every column path, with no causality hypothesis whatsoever, teleports included — is an information set **iff** $n \le 2(t+1)$. T36's beyond-Lipschitz wildness vanishes completely on two-power rings; the $(8,3)$ "all $8^4$ paths decode" exhibit was the $k=3$ instance of a theorem.

**Theorem T40 (the lone diagonal observer; `diagScreen_isInformationSet_iff_odd`, `diagScreen_not_isInformationSet_even`).** The lightlike diagonal $\{(i,\ j_0{+}i) : i \le t\}$ — **one cell per row** — is an information set on an odd ring **iff** $n \le t+1$. At $t{+}1 = n$ this meets the universal counting bound *exactly*: $n$ cells decode $n$ dimensions, zero slack — the first counting-tight screen family in the tree (every previous family is width-2 and needs $2(t{+}1) \ge n$). The timelike single column never decodes at any horizon (T9's counterpoint, proved in v3); boosting the one-cell observer onto the light cone flips it from never-decoding to counting-optimal. On even rings the lone diagonal reads a single parity sector and **never** decodes.

**Theorem T41 (diagonal pairs; `diagScreen_pair_isInformationSet_iff_even`).** On an even ring, two lightlike diagonals decode **iff** their base columns have opposite parity, at the sharp width-2 threshold $n \le 2(t+1)$ — **at any relative offset**. T18a's lightlike tube is the adjacent case; the offset is irrelevant because each diagonal reconstructs its own parity class by itself. Same-parity pairs never decode.

## Proof

All four run through the bridge and two elementary lemmas, every step probe-verified before formalization.

*T38.* The Rule-90 stencil moves diagonally: cell $(i,j)$ reads seed sites $j+i-2r$ only, all in the chequerboard class of $j+i$ — on an even ring a well-defined $\mathbb{Z}/2$ class, so a two-line induction gives sector blindness. A dark ghost's parity projections are then dark (matching-sector cells agree with the ghost; other-sector cells are blind to the projection), and a nonzero ghost has a nonzero projection. The half-ring conjugacy is the same induction in sector coordinates $u \mapsto i + b + 2u$, where $+1$ on the half ring is $+2$ on the full ring.

*T39.* The **doubling lemma** — $\mathsf{T}^{2^k}x\,(j) = x(j) + x(j + 2^k)$, a two-line induction with no binomials — makes $\mathsf{T}$ **nilpotent** on $n = 2^k$: $\mathsf{T}^n = 0$. A row killed by one $\mathsf{T}$-step is constant, so the *last nonzero iterate* $\mathsf{T}^s z$ of any nonzero seed is the all-ones row, $s \le n-1 \le 2t+1$. If $s = 2i$, the screen's row-$i$ cell reads $\mathsf{T}^{2i}z = \mathbf{1}$ at some site: contradiction with darkness. If $s = 2i{+}1$, the row-$i$ *pair* reads two adjacent cells of $\mathsf{T}^{2i}z$ whose sum is $(\mathsf{T}^{s}z)(\cdot) = 1$: two zeros summing to one. The pair geometry is used exactly once, at odd $s$; nothing else about the worldline matters. $\blacksquare$

*T40/T41.* The bridge sends the diagonal cell $(i, j_0{+}i)$ to $\mathsf{T}^{2i}z\,(j_0)$ — a **fixed site**. The **doubling reindex** $w(v) := z(j_0 + 2v)$ satisfies $\mathsf{T}^{i}w\,(v) = \mathsf{T}^{2i}z\,(j_0 + 2v)$, so the diagonal readouts are the fixed-site iterates of $w$; and the **prefix kill** — from $\mathsf{T}^i w\,(u_0) = 0$ for $i \le t$ conclude $w = 0$ on the interval $u_0 .. u_0{+}t$, by the triangular recursion $\mathsf{T}^i w(u{+}1) = \mathsf{T}^i w(u) + \mathsf{T}^{i+1} w(u)$ — kills $w$ on $t+1$ consecutive sites. On an odd ring $2$ is invertible (explicitly $2 \cdot \tfrac{n+1}{2} = 1$), so $t+1 \ge n$ sites of $w$ are all of $z$. On an even ring they are exactly the parity class of $j_0$ — one class per diagonal, whence T41 with any opposite-parity offsets, and the T38 delta ghost for the negatives. Failure halves are the counting bound. $\blacksquare$

## Why this happens

The chequerboard was always there (T18's parity obstruction, T20, T37's odd/even split) — T38 says it is the *whole* story of even-ring failure: not one obstruction among many but the complete reduction, because the dynamics literally factors. And the bridge explains the two magic ring families at once. On $2^k$ rings the difference operator is nilpotent — the ring has *finite information depth*, every seed funnels to the all-ones row in at most $n$ steps, and an adjacent pair is exactly the instrument that detects both the constant row (one cell) and the alternating pre-image (two adjacent cells) — so *no observer can fail*, however lawless its motion. On odd rings the doubling walk $j_0, j_0{+}2, j_0{+}4, \ldots$ visits every site — the crawl of T37, reappearing here as the reason a *single moving cell* can be a perfect screen provided it surfs the light cone, where its readouts become a fixed-site filtration instead of a moving target. Superficially T39 and T40 are opposite corners (all observers on even $2^k$; the thinnest observer on odd) — the proof shows they are the same three lemmas.

## In plain language

Three new laws of the bulb game. *One:* on a loop with an even number of bulbs, the game splits into two completely separate games — odd-numbered positions and even-numbered positions never mix — so the only way any strategy fails is by going blind to one of the two sub-games; check those two and you have checked everything. *Two:* if the loop length is a power of two — 8, 16, 32 — then **every** watcher wins: sit still, wander, teleport wildly; at the standard horizon you cannot lose, and this is a theorem, not a survey of examples. *Three:* on an odd loop there is a perfect minimal spy — watch a *single* bulb per tick while gliding sideways at exactly the speed of light, and after $n$ ticks you know everything, with not one wasted glance ($n$ observations, $n$ unknowns). The same glide on an even loop learns only half the world, forever — unless a second glider of the *other* parity flies with you, anywhere at all, in which case the two of you decode the loop at the standard horizon.

# 14. The hexacode: the geometry-blind extreme (T19, T22)

## Statement

The **hexacode** is the 3-dimensional linear code of length 6 over the four-element field $\mathbb{F}_4 = \{0, 1, \omega, \bar\omega\}$ ($\bar\omega = \omega^2$, $\omega^2 + \omega + 1 = 0$), spanned by the rows of

$$G = \begin{pmatrix} 1 & 0 & 0 & 1 & 1 & \omega \\ 0 & 1 & 0 & 1 & \omega & 1 \\ 0 & 0 & 1 & \omega & 1 & 1 \end{pmatrix}.$$

**Theorem T19.** (i) The code has exactly $4^3 = 64$ codewords and minimum Hamming weight exactly $4$ — the parameters $[6, 3, 4]_4$, meeting the Singleton bound $d = n - k + 1$, so the hexacode is **MDS**. (ii) *(the information-set theorem)* **Every** 3-subset of the 6 coordinates is an information set: two messages whose codewords agree on any 3 coordinates are equal. (iii) *(sharpness)* Some 2-subset is not: the weight-4 codeword $c = (1, 1, 0, 0, \bar\omega, \bar\omega)$ vanishes on coordinates $\{2,3\}$, so the distinct messages $(1,1,0)$ and $0$ agree there. (iv) *(Hermitian self-duality)* With conjugation the Frobenius $x \mapsto x^2$, $\langle u, w\rangle_H = \sum_i u_i \overline{w_i} = 0$ for all codewords $u, w$. *(Lean: `hexacode_min_weight`, `three_subset_information_set`, `two_subset_not_information_set`, `hexacode_self_dual`; the port closes the two hexacode-internal items of the source file's open list; the third item, the hexacode→K₁₂ construction, is expressly out of scope.)*

**Theorem T22 (the full weight distribution).** The only weights occurring are $0, 4, 6$, with counts $A_0 = 1$, $A_4 = 45$, $A_6 = 18$ — the weight enumerator

$$W(x, y) = x^6 + 45\,x^2 y^4 + 18\, y^6 \qquad (1 + 45 + 18 = 64).$$

*(Lean: `hexacode_weights_only`, `hexacode_weight_distribution` — kernel-checked, closing the source file's Python-checked numbers.)*

## Proof

*(i)* The encoder $v \mapsto v^\top G$ is injective (the first three columns form the identity, so the message is read off the first three coordinates): $64$ codewords. Minimum weight $\ge 4$ is a finite check over the 63 nonzero messages, carried out by the proof kernel itself (`decide` — no external computation trusted); weight 4 is attained by $(1,1,0) \mapsto (1,1,0,0,\bar\omega,\bar\omega)$.

*(ii) — from the minimum distance, not by enumeration.* Let $v \neq w$ agree on $S$ with $|S| \ge 3$. The difference codeword $c(v) - c(w) = c(v - w)$ is nonzero (injective encoder) and vanishes on $S$, so its support lies in the complement: weight $\le 6 - |S| \le 3 < 4$ — contradicting the minimum weight. Hence $v = w$.

*(iii)* Direct witness. *(iv)* A kernel-`decide` over the $64 \times 64$ message pairs (codewords are encoder images by definition, so checking message pairs *is* checking codeword pairs). *(T22)* kernel-`decide` over the 64 messages. $\blacksquare$

## Why this happens

MDS codes sit at the absolute optimum of the Singleton trade-off, and the classical equivalence "MDS ⟺ every $k$-subset of coordinates is an information set" is here derived in its concrete instance by the three-line support-counting argument. The hexacode is in the chain as a *foil*: on the Rule-90 cylinder, decodability is exquisitely **geometry-sensitive** (timelike works at a sharp duration threshold, tilt is irrelevant, gaps obey parity, spacelike never works); the hexacode is the opposite pole — **geometry-blind**, *any* 3 of 6 coordinates reconstruct, no matter which. The two toys bracket the design space of "which boundaries satisfy $H_{\mathrm{fib}}$": one code stores its redundancy in spacetime structure, the other spreads it perfectly symmetrically. (Provenance is part of the story: the hexacode formalization is the one artifact of the audited `dula/` satellite repos graded genuinely reusable; the port closed the source's own open items — minimum distance, self-duality, weight distribution — so every claim that file makes about the hexacode is now kernel-checked.)

## In plain language

For contrast, meet a code with the *opposite* personality. Six symbols are sent, of which any three — **any** three, you pick — fully determine the other three; two never suffice. There is no geometry here, no "watch these two, not those two": the redundancy is spread with perfect symmetry, like a hologram cut into six shards where any three shards rebuild the image. Set side by side with the bulb loop — where *which* cells you watch is everything — the pair marks out the two extremes of how a universe can hide redundancy in its records: woven through the structure of space and time, or smeared out with total indifference to it. (This example was salvaged from a satellite repository whose other claims did not survive audit; its one good artifact was finished — every one of its open items proved — and put to work here.)

---

# Part III — The conditional tower

*Modules: `ModularCore.lean`, `ModularFlow.lean`, `EinsteinBranch.lean`, `LambdaConstancy.lean`, `Hypercharge.lean`, `CenterZ6.lean`, `DarkSector.lean`, `CollarGate.lean`, `ScalarResponse.lean`, `DeltaSBridge.lean`, `ChannelBridge.lean`, `PBranches.lean`. From here on, every section machine-checks the **mathematics inside** a physics step whose physical premises are **named hypotheses**. T7 (Section 8) is the standing fence: none of this follows from consensus alone, and the chain never claims it does.*

# 15. Thermal time: the finite modular core of D3 (T21)

## Statement

Let $M_d(\mathbb{C})$ be a finite matrix algebra and $\rho$ a **positive-definite** density matrix defining the faithful state $\omega(A) = \mathrm{tr}(\rho A)$. Define the **modular map**

$$\Delta_\rho(A) \;=\; \rho\, A\, \rho^{-1}.$$

**Theorem T21.** 

1. **(KMS existence)** $\omega\big(A \cdot \Delta_\rho(B)\big) = \omega(B A)$ for all $A, B$ — the algebraic KMS identity at imaginary unit time. *(`kms`)*
2. **(KMS uniqueness — the state pins its dynamics)** If **any** map $D : M_d(\mathbb{C}) \to M_d(\mathbb{C})$ — not assumed linear, continuous, or multiplicative — satisfies $\omega(A \cdot D(B)) = \omega(BA)$ for all $A, B$, then $D = \Delta_\rho$. *(`kms_unique`)*
3. **(flow structure)** $\Delta_\rho$ is a unital algebra automorphism; its $k$-fold iterate is conjugation by $\rho^k$ (an ℕ-indexed iterate — the *integer* imaginary-time steps; the genuine one-parameter group, real-time and entire in the parameter, is T28, Section 15a); it is invariant under rescaling $\rho \mapsto c\rho$ for $c \neq 0$ (the flow sees the state's shape, not its normalization); and $\omega \circ \Delta_\rho = \omega$. *(`modular_mul`, `modular_iterate`, `modular_smul_rho`, `state_modular`)*
4. **(triviality ⟺ traciality)** $\Delta_\rho = \mathrm{id}$ **iff** $\omega$ is a trace ($\omega(AB) = \omega(BA)$ for all $A,B$). *Every non-tracial state ticks.* *(`modular_eq_id_iff_tracial`)*
5. **(the standing hypotheses, discharged)** $\omega$ is a faithful state: $\omega(1) = 1$ (normalized $\rho$), $\omega(A^\dagger) = \overline{\omega(A)}$, $\omega(A^\dagger A) \ge 0$, and $\omega(A^\dagger A) = 0 \Rightarrow A = 0$. *(`state_one/star/nonneg/faithful`)*
6. **(non-vacuity)** For the qubit state $\rho \propto \mathrm{diag}(1,2)$: $\Delta_\rho(E_{01}) = \tfrac12 E_{01} \neq E_{01}$ — a concrete faithful state whose modular clock genuinely ticks. *(`qubitState_modular_ne_id`)*

**Honest fence (updated in v7).** What stays physics is exactly the **Bisognano–Wichmann identification** — that the modular flow of wedge/cap states is *geometric boosts* — plus the scaling limit (weak-* / GNS extraction, possible exit from type I). The real-time flow $\Delta^{it}$, which this fence used to list as unformalized, is now the theorem T28 (Section 15a). This module retires the chain's old sentence "D3 has no isolable finite-mathematics core": the finite core exists and is machine-checked; D3 is now graded like every other Layer-2 link.

## Proof

*(1)* Two cyclic permutations under the trace:

$$\mathrm{tr}\big(\rho A\, \rho B \rho^{-1}\big) = \mathrm{tr}\big(\rho^{-1} \rho A \rho B\big) = \mathrm{tr}\big(A \rho B\big) = \mathrm{tr}\big(\rho B A\big).$$

*(2)* The workhorse is **non-degeneracy of the trace pairing**: if $\mathrm{tr}(C X) = 0$ for all $C$, then $X = 0$ (test $C$ = matrix units: $\mathrm{tr}(E_{ji} X) = X_{ij}$). Now fix $B$ and test the KMS property of $D$ against $A := \rho^{-1} C$ for arbitrary $C$:

$$\mathrm{tr}\big(C \cdot D(B)\big) = \omega\big(\rho^{-1}C \cdot D(B)\big) = \omega\big(B \rho^{-1} C\big) = \omega\big(\rho^{-1}C \cdot \Delta_\rho(B)\big) = \mathrm{tr}\big(C \cdot \Delta_\rho(B)\big),$$

where the middle two equalities are the KMS property of $D$ and (1) read backwards. So $\mathrm{tr}\big(C(D(B) - \Delta_\rho(B))\big) = 0$ for all $C$, forcing $D(B) = \Delta_\rho(B)$.

*(4)* Forward: if $\Delta_\rho = \mathrm{id}$, then (1) *is* traciality. Backward: if $\omega$ is tracial, then $D = \mathrm{id}$ satisfies the KMS identity, and uniqueness (2) forces $\Delta_\rho = \mathrm{id}$. (Both directions one line — the point of having existence *and* uniqueness.)

*(3), (5), (6)* are direct computations; positivity/faithfulness reduce, by cycling $\omega(A^\dagger A) = \mathrm{tr}(A \rho A^\dagger)$, to the positive-definiteness of $\rho$ on the starred rows of $A$. $\blacksquare$

## Why this happens

In finite dimensions, Tomita–Takesaki modular theory collapses to matrix algebra — but the collapse preserves its philosophical punchline, and the punchline is what the chain needs. A *state* — a mere assignment of expectation values — turns out to **contain a canonical dynamics**: the unique map that makes the state look thermal (KMS) with respect to it. Uniqueness is the remarkable half: the KMS condition is an equation on a completely unconstrained map, yet it has exactly one solution; the state's failure-to-be-tracial ($\rho$'s unequal eigenvalues) is precisely the "gradient" that drives the flow, and it drives it uniquely because the trace pairing is non-degenerate. In OPH's reading: a *patch* is a finite system, its record algebra is exactly this type-I class, so **a patch state already carries a distinguished automorphism — its imaginary-time modular step — uniquely pinned by the KMS identity**. Two honest steps used to separate that from "a clock"; as of v7 only one remains: the *real-time* one-parameter group `ρ^{it}(·)ρ^{−it}`, its KMS boundary condition, and its uniqueness (within the Hamiltonian-implemented class) are now the theorem T28 (Section 15a) — the state's distinguished operation IS a flow, finite-dimensionally; *which geometric flow* it is (boosts — Bisognano–Wichmann) remains physics. This is the mathematically-solid kernel of the "thermal time" idea (Connes–Rovelli), delivered at exactly the finite level the chain's D3 row starts from.

## In plain language

A quietly astonishing fact from quantum theory, in its simplest setting. Describe a small system only by its *statistics* — the odds of each measurement outcome. You'd think that says nothing about *time*: statistics are a snapshot. The theorem says otherwise: hidden inside any (fully general, "faithful") statistical state there is exactly **one** built-in reshuffling operation with respect to which the state looks thermal — no more, no less, and not a matter of choice: demand thermality and the operation is *forced*, uniquely. Perfectly uniform states (all outcomes equally weighted) are the single exception — their operation is "do nothing"; any state with the slightest imbalance singles out a genuine move, in exactly one way. Whether that operation deserves the word *clock* — something that ticks smoothly through real time — is a further (smaller, formalizable) mathematical step not yet machine-checked; and whether the resulting time matches the geometric time of relativity is the honestly-labelled physics. The operation is proven; "clock" is two steps of honesty away.

# 15a. The real-time modular flow (T28, new in v7)

## Statement

**Theorem T28** (`ModularFlow.lean`). Let $\rho$ be positive definite on a finite matrix algebra, $\omega = \mathrm{tr}(\rho\,\cdot)$.

1. *(the Hamiltonian exists)* There is a Hermitian $H$ with $e^{-H} = \rho$ (i.e. $H = -\log\rho$; spectral construction).
2. *(the flow)* $\sigma_z(A) := e^{izH} A\, e^{-izH}$, defined for **every complex** $z$, satisfies: $\sigma_0 = \mathrm{id}$, $\sigma_{z+w} = \sigma_z \circ \sigma_w$ (a one-parameter group, entire in the parameter), each $\sigma_z$ is a unital algebra automorphism, $\sigma_t$ is $\ast$-preserving with unitary propagators for real $t$, the propagator is norm-continuous in the parameter, and $\omega \circ \sigma_z = \omega$ for all $z$.
3. *(the anchor)* $\sigma_i = \Delta_\rho$: the analytic value of the flow at $z = i$ is exactly T21's imaginary-time modular map.
4. *(KMS boundary condition — the textbook form, $\beta = 1$)* $\omega(A\,\sigma_{t+i}(B)) = \omega(\sigma_t(B)\,A)$ for all $t \in \mathbb{C}$ (in particular all real times) and all $A, B$.
5. *(uniqueness)* If a Hamiltonian-implemented flow $\tau_z = e^{izK}(\cdot)e^{-izK}$ (any Hermitian $K$) satisfies the KMS identity against $\omega$, then $e^{-K} = c\,\rho$ with $c$ **real and positive** — $K = -\log\rho$ up to the additive constant conjugation cannot see — and $\tau$'s imaginary-time step is the modular map.

## Proof

(1) Diagonalize $\rho = U\,\mathrm{diag}(\lambda)\,U^\ast$ with $\lambda_i > 0$; set $H := U\,\mathrm{diag}(-\log\lambda_i)\,U^\ast$; then $e^{-H} = U\,\mathrm{diag}(e^{\log\lambda_i})\,U^\ast = \rho$. (2) is exponential algebra: same-generator exponentials commute, so the group law is $e^{X+Y} = e^X e^Y$ for commuting $X, Y$; unitarity at real $t$ is $(e^{itH})^\dagger = e^{-itH}$ for Hermitian $H$. (3) At $z = i$: $e^{i\cdot i H} = e^{-H} = \rho$ and $e^{-i \cdot i H} = \rho^{-1}$, so $\sigma_i(A) = \rho A \rho^{-1} = \Delta_\rho(A)$. (4) is one line: $t + i = i + t$, the group law gives $\sigma_{t+i} = \sigma_i \circ \sigma_t = \Delta_\rho \circ \sigma_t$, and T21's `kms` applied to $B' := \sigma_t(B)$ finishes. (5) $\tau$'s imaginary step is conjugation by $V := e^{-K}$ (invertible); T21's **uniqueness** forces $V B V^{-1} = \rho B \rho^{-1}$ for all $B$, so $\rho^{-1}V$ is central, hence scalar: $V = c\rho$. For $c$: $e^{-K} = (e^{-K/2})^\dagger(e^{-K/2})$ is positive definite, so testing the quadratic form on one basis vector gives $c = (\text{positive})/(\text{positive})$, real and positive. $\square$

## Why this happens

Everything rests on the finite-dimensional collapse of analyticity: on a matrix algebra the flow $t \mapsto \rho^{it}(\cdot)\rho^{-it}$ *extends entirely* in the parameter, so the KMS boundary condition — in infinite dimensions a statement about analytic continuation to a strip — becomes an algebraic identity connecting the flow's value at $t$ to its value at $t + i$, and the group law does the continuation for free. That is why the audit's F9 was exactly right that the "clock" content was unformalized *and* exactly wrong to fear it was deep: the real-time statement was one spectral construction plus exponential algebra away, sitting directly on T21's uniqueness engine. The uniqueness clause is the physically meaningful one: within the class of flows a finite system can actually implement (Hamiltonian conjugation), demanding that the state look thermal pins the Hamiltonian to $-\log\rho$ up to the one freedom (an additive constant / overall normalization) that no conjugation can see. The honest leftover is stated in the module: extending uniqueness beyond the Hamiltonian-implemented class needs Skolem–Noether (every automorphism of a matrix algebra is inner) — standard mathematics, deliberately named rather than silently claimed — and everything geometric (boosts) remains the named Bisognano–Wichmann physics.

## In plain language

The previous section proved that a lopsided statistical state singles out one special reshuffling operation; the audit rightly noted that calling it a *clock* — something that ticks through real time — was not yet checked. Now it is. The special operation extends to a genuine flow: a smooth one-parameter family of transformations, one for every instant, which compose correctly (running $s$ then $t$ equals running $s{+}t$), preserve the state, respect all the algebraic structure — and whose value at the *imaginary* instant $i$ is exactly the operation from before, tying the two together the way a function ties into its own analytic continuation. Moreover, among all flows a finite system can implement, only this one (up to resetting the zero of energy, which changes nothing observable) makes the state look thermal. So the state does not merely pin an operation; it pins a *clock*, in the full sense — finite-dimensionally, with machine-checked proofs. What it does not pin — and what stays honestly on the physics side of the ledger — is whether that clock is the *boost* clock of spacetime.

# 16. The Einstein-branch algebra (T14)

## Statement

Work in Minkowski $\mathbb{R}^{1,n}$ with $\eta = \mathrm{diag}(-1, 1, \dots, 1)$; bilinear forms are symmetric matrices $B$, with quadratic form $B(u,u)$.

**Theorem T14a (rest-frame arithmetic of `thm:einstein`).** Assume, as **named physics** (the D3–D5 variational identities): entropy stationarity $\delta S + \delta A/(4G) = 0$; the small-ball bridge $\delta S = \frac{8\pi^2 \ell^4}{15} X$; and the area variation $\delta A = -\frac{4\pi \ell^4}{15} Z$ (with $G, \ell > 0$). Then

$$Z = 8\pi G\, X.$$

*(`rest_frame_relation`)*

**Theorem T14b (timelike polynomial upgrade).** A symmetric bilinear form $B$ with $B(u,u) = 0$ for **every future unit timelike** $u$ (i.e. $\eta(u,u) = -1$, $u^0 > 0$) vanishes identically. Consequently *(`tensor_upgrade`)*: if the rest-frame relation $(G_{ab} + \Lambda g_{ab})u^a u^b = \kappa\, T_{ab} u^a u^b$ holds in every local rest frame, the full tensor equation $G_{ab} + \Lambda g_{ab} = \kappa T_{ab}$ holds entrywise.

**Theorem T14c (the null-cone / Jacobson step).** A symmetric form vanishing on the whole **null cone** equals $\lambda\eta$ for $\lambda = -B_{00}$ *(`null_cone_determines`)*; hence if $F(k,k) = \kappa\, T(k,k)$ for all null $k$ — the algebraic residue of "$\delta Q = T\,\delta S$ on all local Rindler horizons" (Jacobson 1995) — then

$$\exists\, \lambda:\quad F = \kappa\, T + \lambda\, \eta,$$

i.e. the residual pointwise freedom is one scalar **per point** — a field λ(x), not yet a constant. **The promotion to *the* cosmological constant is its own theorem (T26, new in v6.1)**: with the contracted Bianchi identity and local stress conservation as *named* inputs, on a chart whose points are all step-reachable from a base point the field λ is forced to a single constant Λ (`einstein_equation_with_constant`, `LambdaConstancy.lean`; a disconnected counterexample shows the reachability clause is load-bearing; since v7 the symmetric-closure form `lambda_constant_symm` covers ℤⁿ-style charts — audit F23). Three scope notes the audit priced (F23): the divergence conditions are *assumptions about the discrete fields* — their continuum counterparts are an identity (Bianchi) and a law (conservation), but nothing in the discrete chart makes them free; the chart is flat (a globally constant η — the algebraic shadow of Jacobson's metric-compatibility step, which stays with the D-branch physics); and "connected" means reachable, not topological. *(`jacobson_step` + T26)*

## Proof

*(a).* Pure arithmetic: from stationarity, $\delta A = -4G\,\delta S$; substitute both identities and cancel the common positive factor $\frac{4\pi\ell^4}{15}$: $Z \cdot \frac{4\pi \ell^4}{15} = 4G \cdot \frac{8\pi^2\ell^4}{15} X$, so $Z = 8\pi G X$.

*(b).* First scale into the open cone: if $\eta(w,w) < 0$, $w^0 > 0$, then $u = w / \sqrt{-\eta(w,w)}$ is future unit timelike, and $B(w,w) = -\eta(w,w) \cdot B(u,u) = 0$ — so $B$ vanishes on the whole open future cone. Then evaluate on finitely many explicit cone vectors: $e_0$ gives $B_{00} = 0$; $e_0 + s e_i$ for $s = \frac12, \frac13$ (both timelike: $\eta = -1 + s^2 < 0$) give $B_{00} + 2sB_{0i} + s^2 B_{ii} = 0$ at two values of $s$, forcing $B_{0i} = B_{ii} = 0$; and $e_0 + \frac12(e_i + e_j)$ ($\eta = -\frac12$) then forces $B_{ij} = 0$. No open-ball or analyticity argument is needed — finitely many witnesses plus one scaling.

*(c).* Same strategy on the cone $\eta(k,k) = 0$: the null vectors $e_0 \pm e_i$ give $B_{00} \pm 2B_{0i} + B_{ii} = 0$, forcing $B_{0i} = 0$ and $B_{ii} = -B_{00}$; the null vector $\sqrt2\, e_0 + e_i + e_j$ then forces $B_{ij} = 0$ for $i \neq j$. Entrywise this is exactly $B = (-B_{00})\,\eta$. Apply to $B := F - \kappa T$. $\blacksquare$

## Why this happens

Jacobson's celebrated 1995 argument derives the Einstein equation as an *equation of state*: demand that the Clausius relation $\delta Q = T \delta S$ (with entropy ∝ horizon area) hold for all local Rindler horizons, and the Einstein tensor is forced up to one scalar of integration — the cosmological constant. The chain's D5 route is Jacobson-shaped, and this module isolates precisely the part of such derivations that is *mathematics*: once the variational identities hand you the equation on enough directions (all rest frames, or the whole null cone), linear algebra alone upgrades it to the full tensor equation, and the null-cone route's kernel — the forms invisible to all null directions — is exactly the one-dimensional space $\lambda\eta$. That the $\lambda\eta$ kernel appears *as the kernel of an algebraic determination problem* is the cleanest available answer to "why does this kind of derivation always produce a cosmological-constant term": it is not put in and cannot be kept out — per point; that the per-point scalar is one **constant** is the separate theorem T26 (Section 16a). The named-physics hypotheses (stationarity, small-ball, area variation) stay open — T7 guarantees they cannot come from consensus alone — and the module's division of labor makes the IOU exact.

## In plain language

There's a famous idea (Jacobson's) that Einstein's equation of gravity might not be fundamental but *thermodynamic* — the way "heat flows from hot to cold" summarizes molecular chaos, gravity might summarize the statistics of microscopic information at horizons. Arguments in that family always have two parts: a physics part (entropy behaves so-and-so at every little horizon) and a mathematics part (from so-and-so *in every direction*, the full equation follows). This section machine-checks the mathematics part completely. Two bonuses fall out. First, only a handful of cleverly chosen directions are needed — the verification is finite, almost by hand. Second, the method *cannot* pin down one famous constant: a single knob's worth of freedom always survives *at each point*, and the follow-up theorem (T26, next section) shows the knobs are all the same knob — precisely the **cosmological constant**: the term Einstein once called his greatest blunder shows up here as the exact leftover slack of the derivation, no more and no less. The physics premises remain premises, clearly labelled.

## 16a. The cosmological-constant step (T26, new in v6.1)

**Statement (`einstein_equation_with_constant`, `LambdaConstancy.lean`).** Let points form a discrete chart (a successor map per coordinate direction) with every point step-reachable from a base point. Suppose at every point the null-cone matching hypothesis of T14c holds, and suppose the two *named* divergence inputs: the discrete divergence of $F$ vanishes (the contracted Bianchi identity, geometry's identity) and the discrete divergence of $T$ vanishes (local stress conservation, matter's law). Then there is a **single constant** $\Lambda$ with $F(p) = \kappa T(p) + \Lambda\,\eta$ at *every* point $p$.

**Proof.** T14c at each point yields a pointwise $\lambda(p)$. Subtracting, the field $p \mapsto \lambda(p)\eta$ is divergence-free; because $\eta$ is constant, its discrete divergence is exactly the $\eta$-contracted discrete gradient of $\lambda$ (the Leibniz step, exact here); because $\eta$ is diagonal with unit entries, the contraction vanishes only if each partial difference does — so $\lambda$ is invariant along every coordinate step, hence constant on the connected chart. A two-point disconnected chart with $\lambda = (0, 1)$ satisfies every other hypothesis, so the connectivity clause is load-bearing (`lambda_not_constant_without_connectivity`). $\blacksquare$

**Why this happens.** This is Jacobson's own closing move, in the chain's finite-algebra style: the equation-of-state derivation leaves one scalar of freedom per point, and it is the conservation laws — not the variational argument — that stitch the pointwise freedoms into one global constant. The audit (F8) correctly flagged that this step was written mathematics the chain consumed silently; it is now a theorem with its inputs named, and the Einstein branch ends at the Einstein equation.

**In plain language.** The gravity derivation leaves one loose dial at every point of space and time. Einstein's equation needs all those dials to show the same number — otherwise you have not a constant of nature but an unexplained new field. The classical argument that locks the dials together uses two bookkeeping laws (one an identity of geometry, one the local conservation of matter); the machine now checks that with those two laws — labelled as the assumptions they are — the dials must all agree, and that on a disconnected world they genuinely need not.

# 17. The Standard-Model algebra: hypercharges forced, kernel exactly ℤ₆ (T13)

## Statement

**Setting.** Gauge group $SU(N) \times SU(2) \times U(1)_Y$; one generation of left-handed Weyl multiplets $Q, u^c, d^c, L, e^c$ and a Higgs doublet $H$, with hypercharges $Y_Q, Y_u, Y_d, Y_L, Y_e, Y_H \in \mathbb{Q}$; Yukawa terms $QHu^c$, $QH^\dagger d^c$, $LH^\dagger e^c$.

**Theorem T13a (hypercharges forced).** Assume *(named physics: the realized package — selection is the axiom MAR)* Yukawa closure

$$Y_Q + Y_H + Y_u = 0, \qquad Y_Q - Y_H + Y_d = 0, \qquad Y_L - Y_H + Y_e = 0,$$

and the two **linear** anomaly cancellations $[SU(2)]^2 U(1) : N Y_Q + Y_L = 0$ and $[\mathrm{grav}]^2 U(1) : N(2Y_Q + Y_u + Y_d) + 2Y_L + Y_e = 0$. Then the ratios are forced for every $N$:

$$Y_L = -N Y_Q, \quad Y_H = N Y_Q, \quad Y_u = -(N{+}1) Y_Q, \quad Y_d = (N{-}1) Y_Q, \quad Y_e = 2N Y_Q;$$

moreover the $[SU(N)]^2 U(1)$ anomaly is **implied by Yukawa closure alone**, and the cubic $[U(1)]^3$ anomaly **cancels identically** on this ray (a polynomial identity in $N, Y_Q$ — no extra constraint). Fixing the electroweak normalization $Q = T_3 + Y$ with $Q(\nu_L) = 0$ (i.e. $Y_L = -\tfrac12$) pins $Y_Q = \tfrac{1}{2N}$; at $N = 3$ the assignment is **uniquely** the Standard-Model lattice

$$\big(Y_Q, Y_u, Y_d, Y_L, Y_e, Y_H\big) = \big(\tfrac16,\ -\tfrac23,\ \tfrac13,\ -\tfrac12,\ 1,\ \tfrac12\big).$$

*(Lean: `hypercharge_ratios`, `su3_anomaly_of_yukawa`, `cubic_anomaly_auto`, `YQ_of_normalization`, `hypercharges_unique`.)*

**Theorem T13b (the kernel is exactly ℤ₆).** Write the center of $SU(3) \times SU(2) \times U(1)$ additively as $\mathbb{Z}_3 \times \mathbb{Z}_2 \times \mathbb{R}/\mathbb{Z}$; an element $(a, b, \theta)$ acts on a multiplet of triality $t$, duality $d$, integer charge $q = 6Y$ by the phase $t\frac{a}{3} + d\frac{b}{2} + q\theta \in \mathbb{R}/\mathbb{Z}$. With the six realized multiplets $Q = (1,1,1)$, $u^c = (2,0,-4)$, $d^c = (2,0,2)$, $L = (0,1,-3)$, $e^c = (0,0,6)$, $H = (0,1,3)$ (charges matching T13a's lattice via $q = 6Y$): the subgroup acting trivially on **all six** is exactly

$$\big\{\, g_k = (k \bmod 3,\ k \bmod 2,\ k/6) \;:\; k \in \mathbb{Z} \,\big\} \;\cong\; \mathbb{Z}_6,$$

generated by $g_1 = (\omega_3, -1, e^{i\pi/3})$ of order exactly 6. Hence the faithfully-acting gauge group of the realized spectrum is $\big(SU(3)\times SU(2)\times U(1)\big)/\mathbb{Z}_6$. *(Lean: `actsTrivially_iff`, `kernel_bijection`, `addOrderOf_g0`, `charges_match_hypercharges`.)*

## Proof

*T13a.* Linear elimination over $\mathbb{Q}$: the $SU(2)$ anomaly gives $Y_L = -N Y_Q$; adding the first two Yukawa relations gives $2Y_Q + Y_u + Y_d = 0$ (which *is* the $[SU(N)]^2$ condition — hence "implied"); substituting into the gravitational anomaly cancels every $N$-multiplied term and leaves $2Y_L + Y_e = 0$, i.e. $Y_e = 2N Y_Q$; the third Yukawa relation gives $Y_H = Y_L + Y_e = N Y_Q$; the first two then give $Y_u = -(N{+}1)Y_Q$, $Y_d = (N{-}1)Y_Q$. For the cubic: substituting the ray,

$$N\big(2 + (-(N{+}1))^3 + (N{-}1)^3\big) + 2(-N)^3 + (2N)^3 = N(2 - 6N^2 - 2) - 2N^3 + 8N^3 = -6N^3 + 6N^3 = 0$$

identically in $(N, Y_Q)$ — the machine checks this with `ring`. Normalization and uniqueness are substitution.

*T13b.* *Sufficiency:* $g_k$ acts on a multiplet by the phase $\frac{k}{6}\big(2t + 3d + q\big) \bmod 1$ (after absorbing representative shifts), and each of the six multiplets satisfies $2t + 3d + q \equiv 0 \pmod 6$: for $Q$, $2 + 3 + 1 = 6$; $u^c$, $4 + 0 - 4 = 0$; $d^c$, $4 + 0 + 2 = 6$; $L$, $0 + 3 - 3 = 0$; $e^c$, $0 + 0 + 6 = 6$; $H$, $0 + 3 + 3 = 6$. *Necessity — two multiplets suffice:* triviality on $e^c = (0, 0, 6)$ forces $6\theta \in \mathbb{Z}$, i.e. $\theta = n/6$; triviality on $Q = (1,1,1)$ then forces $\frac{a}{3} + \frac{b}{2} + \frac{n}{6} \in \mathbb{Z}$, i.e. $2a + 3b + n \equiv 0 \pmod 6$, which pins $a \equiv n \pmod 3$ and $b \equiv n \pmod 2$ — so the element *is* $g_n$. Faithfulness of the parameterization ($g_k = g_{k'} \iff k \equiv k' \bmod 6$) and the order-6 computation for $g_1$ complete the bijection with $\mathbb{Z}_6$. $\blacksquare$

## Why this happens

Two classic pieces of "Standard-Model rigidity", fully algebraic once the *spectrum* is given. First: the SM's peculiar-looking hypercharges $(\tfrac16, -\tfrac23, \tfrac13, -\tfrac12, 1, \tfrac12)$ are not adjustable dials — Yukawa couplings tie them together linearly, the two linear anomaly conditions cut the solution space to a single ray, the notorious *cubic* condition then costs nothing (it cancels identically on that ray — which is *why* charge quantization needs the electroweak normalization rather than more anomalies), and one physical normalization ("the neutrino is neutral") freezes the scale. Second: the global shape of the gauge group is likewise not a choice — the center elements acting trivially on the realized fields form exactly $\mathbb{Z}_6$, no more, no less, so the group that *acts* is the quotient. Both facts are theorems *about the package*; the chain's honesty point is that **selecting the package** (why these multiplets, why $N = 3$ colors, why these Yukawas) is the named axiom **MAR**, and nothing here derives it. Three inputs deserve their own labels (the audit's F13): the normalization "the neutrino is neutral" is an *empirical* anchor, not algebra; the uniqueness is package-relative, and nature has already amended the package (neutrino mass requires at least a right-handed or Majorana addition, which changes the anomaly/Yukawa system the forcing runs through — the ray survives, the uniqueness statement's hypotheses shift); and the anomaly conditions are imposed per-generation, with cross-generation cancellations excluded by MAR's one-generation ansatz. Separately, *which* quotient $SU(3){\times}SU(2){\times}U(1)/\Gamma$ nature realizes ($\Gamma \in \{1, \mathbb{Z}_2, \mathbb{Z}_3, \mathbb{Z}_6\}$) is a famously open empirical question — the kernel computation says the action on the *known* fields factors through the $\mathbb{Z}_6$ quotient, not that the quotient is realized; the collar gate consumes the realized-$\mathbb{Z}_6$ reading as a hypothesis (Section 19). Downstream, the "$6$" of the $\mathbb{Z}_6$ kernel is what the collar gate's $P/24 = (P/4)/6$ bookkeeping consumes (Section 19).

## In plain language

Why does the electron carry exactly $-1$ unit of charge, the up-quark exactly $+\tfrac23$, the neutrino exactly $0$ — such oddly specific fractions? Given the *cast of particles* and the requirement that the theory not self-destruct (its quantum anomalies must cancel) nor forbid the interactions that give particles mass, the charges have **no freedom at all**: they are the unique solution of a small linear-algebra puzzle, and the fanciest consistency condition turns out to be automatically satisfied — the machine has checked every line. A second rigidity follows: the true symmetry structure of the Standard Model carries a specific sixfold redundancy — exactly six central "rotations" act invisibly on all matter — and that "six" is forced too. What is *not* forced, and is flagged in bold as an assumption, is the cast list itself: why nature realized these particular particles is the axiom the program names MAR and does not pretend to have proven. Given the cast, the script writes itself; the casting remains open.

# 18. The dark-sector mathematics (T15)

## Statement

**The activation law.** With coupling $\lambda > 0$, define the activation probability and the OPH interpolation function

$$p(x) = 1 - e^{-\lambda\sqrt{x}}, \qquad \nu_{\mathrm{OPH}}(x) = \frac{1}{1 - e^{-\lambda\sqrt{x}}} \qquad (x = g_b / a_0 > 0).$$

**Theorem T15 (all machine-checked; premises named below).**

1. *(well-definedness)* $0 < p(x) < 1$ and $\nu_{\mathrm{OPH}}(x) > 1$ for $x > 0$; $\nu_{\mathrm{OPH}}$ is strictly decreasing on $(0,\infty)$.
2. *(closure inversion)* If the flux-recovery closure $g_b = p(x)\, g_{\mathrm{obs}}$ holds with $p(x) \neq 0$, then $g_{\mathrm{obs}} = \nu_{\mathrm{OPH}}(x)\, g_b$.
3. *(Newtonian limit)* $\nu_{\mathrm{OPH}}(x) \to 1$ as $x \to \infty$: high accelerations are exactly Newtonian.
4. *(deep-MOND limit, exact scaling)* $p(x)/(\lambda\sqrt{x}) \to 1$ as $x \to 0^+$; consequently, with $g_b = a_0 x$ and $a_{\mathrm{eff}} = a_0/\lambda^2$,
$$\frac{g_{\mathrm{obs}}}{\sqrt{a_{\mathrm{eff}}\, g_b}} \longrightarrow 1 \qquad (x \to 0^+),$$
the square-root ("MOND-like") regime with the exact effective acceleration scale.
5. *(BTFR)* From $g = \sqrt{a_{\mathrm{eff}} \cdot GM/r^2}$ and $v^2 = g r$ (with $a_{\mathrm{eff}}, GM \ge 0$ and $r > 0$): $v^4 = G M\, a_{\mathrm{eff}}$ — the baryonic Tully–Fisher relation as an identity.
6. *(rare events)* $\big(1 - \mu/m\big)^m \to e^{-\mu}$: the Poisson zero-count limit that grounds $p$'s exponential form.
7. *(L2.7: phantom density is bookkeeping)* Over **any** linear divergence operator (and any $G \neq 0$): if $\mathrm{div}\, g_b = -4\pi G\, \rho_b$, then $\mathrm{div}(g_b + g_A) = -4\pi G(\rho_b + \rho_A)$ with $\rho_A := -(4\pi G)^{-1}\, \mathrm{div}\, g_A$ — an identity with **zero physical content**, exactly as the chain grades it.
8. *(point source, exact profile)* $M_A(r) = M_b\big(e^{\lambda r_M / r} - 1\big)^{-1}$ is positive and strictly increasing on $(0,\infty)$, with derivative **exactly** $M_A'(r) = 4\pi r^2 \rho_A(r)$ for the paper's displayed
$$\rho_A(r) = \frac{M_b\, \lambda\, r_M\, e^{\lambda r_M/r}}{4\pi r^4 \big(e^{\lambda r_M/r} - 1\big)^2} > 0.$$
9. *(L2.11's derivation half: the thin-device force law)* Given the lab anomaly law $\rho_{\mathrm{lab}}(z) = \frac{g\chi}{4\pi G} \partial_z S$ *(named input)*, integrating through a thin column of height $h$ and area $A$ gives
$$F_\chi \;=\; \int_0^h \rho_{\mathrm{lab}}(z)\, g\, A \, dz \;=\; \frac{g^2}{4\pi G}\, A\, \chi\, \Delta S, \qquad \Delta S = S(h) - S(0),$$
one application of the fundamental theorem of calculus.

*(Lean: `activation_*`, `nuOPH_*`, `flux_closure_inversion`, `deepMOND_limit`, `deepMOND_gobs`, `btfr`, `rare_event_zero_count`, `phantom_bookkeeping`, `MA_pos`, `MA_strictMonoOn`, `hasDerivAt_MA`, `rhoA_pos`, `thin_device_force`.)*

**Named physics (not proven, per the papers' own labels):** codimension-one collar support (the mean count $\mu(x) = \lambda_c \sqrt{x}$), independent increments / rare local repair events / refinement stability (the Poisson premises), the flux-recovery closure itself, and the lab response law in (9). The *value* of the collar coupling is Section 19/22.

## Proof

*(1)–(3)* elementary monotonicity of $\exp$ plus one algebraic inversion; the Newtonian limit is $e^{-\lambda\sqrt{x}} \to 0$.

*(4)* The one-variable kernel $\frac{1 - e^{-t}}{t} \to 1$ as $t \to 0^+$ is proved by a squeeze from $1 + t \le e^t$:

$$\frac{1}{1+t} \;\le\; \frac{1 - e^{-t}}{t} \;\le\; 1 \qquad (t > 0),$$

then compose with $t = \lambda\sqrt{x} \to 0^+$. For the corollary, the pointwise identity $\frac{\nu(x)\, a_0 x}{\sqrt{(a_0/\lambda^2)(a_0 x)}} = \Big(\frac{p(x)}{\lambda\sqrt{x}}\Big)^{-1}$ (substitute $x = s^2$ and simplify) converts the kernel limit into the acceleration scaling.

*(5)* $v^4 = (gr)^2 = g^2 r^2 = a_{\mathrm{eff}} \frac{GM}{r^2} r^2 = GM\, a_{\mathrm{eff}}$.

*(6)* is the classical $(1 + y/m)^m \to e^y$ at $y = -\mu$. *(7)* Linearity: $\mathrm{div}(g_b + g_A) = -4\pi G \rho_b + \mathrm{div}\, g_A$ and the definition of $\rho_A$ absorbs the second term. *(8)* One quotient-rule differentiation, then algebra to match the displayed $\rho_A$; positivity and monotonicity from $e^{\lambda r_M / r} > 1$ and its decrease in $r$. *(9)* Pull constants out of the integral; FTC gives $\int_0^h S' = S(h) - S(0)$. $\blacksquare$

## Why this happens

The dark-sector story is the one continuation of the chain with genuine phenomenological content, and this module splits it with a scalpel. The *shape* of the law is dictated by a counting picture: if repair opportunities along a thin collar are Poisson with mean $\propto \sqrt{g_b/a_0}$, then "at least one opportunity active" has probability exactly $1 - e^{-\lambda\sqrt{x}}$ — and everything phenomenological follows *by mathematics alone*: Newtonian behaviour where accelerations are high, the square-root MOND regime where they are low (with the $\lambda$-to-$a_{\mathrm{eff}}$ relation exact within the ansatz), and the Tully–Fisher $v^4 \propto M$ scaling as a two-line identity. Three context facts the audit (F14) rightly demands on the label: **(i)** this interpolation function is, curve for curve, the *published empirical fitting function of the radial-acceleration relation* (McGaugh–Lelli–Schombert 2016) — the Poisson story is a proposed *mechanism for the known fit*, and the listed phenomenological virtues are properties shared by every MOND interpolation with those limits, so items (1)–(6) test the mechanism not at all; **(ii)** the upstream dark paper itself notes the algebraic law $g_{\mathrm{obs}} = \nu g_b$ is exact only where symmetry kills the curl term — the formalization is scalar/point-source, where that obstruction is invisible; **(iii)** the corpus's own Correction Audit records that $e^{-P/24} = 0.9343$ sits between the binned-RAR-preferred $0.9367$ and the common-$a_0$-preferred $0.9261$ and cannot reach the latter without new theory — the one place the tower touches data, carried here so the reader meets it. Meanwhile item (7) is deliberately deflationary: writing the anomaly as a "phantom dark density" is *definitionally* possible for any field and carries no evidence — the chain grades L2.7 as bookkeeping and the machine confirms there is nothing there to prove. Items (8)–(9) close the calculus IOUs: the printed point-source density is exactly the shell-mass derivative of the printed mass profile, and the device force law used by the experiment is one honest FTC step downstream of a *named* lab response law, not an independent assumption.

## In plain language

The framework's dark-matter-like story goes: gravity's bookkeeping is done by the same repair traffic as everything else, and where gravity is extremely weak the repair events become *rare* — occasionally none fire, a fraction of the accounting goes missing, and the visible pull looks stronger than the matter warrants. Assume only that the rare events follow the statistics of rare independent events (the "named" assumption), and the mathematics then delivers, with no further knobs: normal gravity where fields are strong; a boosted law where they are faint — a law which, in shape, is exactly the formula astronomers already fit to the data (this theory adds a proposed mechanism and a strength, not the curve); and one of astronomy's cleanest observed regularities — rotation speed to the fourth power tracks ordinary mass — as a two-line consequence, as it is for every law of that shape. The law is also honest only for round sources (its own source paper says so), and the predicted strength sits measurably between the data's two preferred values — both facts now on this label. The module is equally frank about what is *empty*: calling the discrepancy a "phantom density" is a relabeling exercise, true for any theory whatsoever, and it is proven here precisely to certify that it proves nothing. The experiment's force formula, finally, is shown to be one integration step from the declared lab law — so the device tests the *declared physics*, not hidden mathematics.

# 19. The collar gate: $\lambda_{\mathrm{collar}} = e^{-P/24}$, the Jensen band, and the twelve ports (T16)

## Statement

**The finite-slice collar model.** Finitely many transverse slices $y$ with weights $w_y \ge 0$, $\sum_y w_y = 1$, and per-slice protected-reserve means $\varepsilon_y \ge 0$; the collar survival coefficient is

$$\lambda_{\mathrm{collar}} \;=\; \sum_y w_y\, e^{-\varepsilon_y}.$$

**Theorem T16 (skeleton of L2.6; gate clauses are named physics).**

1. *(per-slice survival = Poisson zero count)* $\mathrm{Poisson}(\varepsilon)\{0\} = e^{-\varepsilon}$.
2. *(the gate theorem)* Slice-wise unbiasedness — $\varepsilon_y = P/24$ for **every** slice (the boxed clause of the gate) — forces
$$\lambda_{\mathrm{collar}} \;=\; e^{-P/24} \quad \textbf{exactly}.$$
3. *(the Jensen band)* If only the **weighted mean** reserve equals $P/24$ ($\sum_y w_y \varepsilon_y = P/24$), then
$$e^{-P/24} \;\le\; \lambda_{\mathrm{collar}} \;\le\; 1,$$
the lower bound by Jensen's inequality for the convex exponential, the upper from $\varepsilon_y \ge 0$.
4. *(forced susceptibility)* If the surviving coherent fraction is written both as $\lambda S$ and as $\chi S$ with $S \neq 0$, then $\chi = \lambda$ — the paper's "forced canonical susceptibility" is literally a cancellation.
5. *(the 24 bookkeeping)* $(P/4)/6 = P/24$; the $6$ is $\#\mathbb{Z}_6$ (the kernel of Section 17); the $24$ is $\#(\mathrm{ports} \times \mathrm{orientation}) = \#(\{1..12\} \times \{\mathrm{write}, \mathrm{check}\})$.
6. *(defect arithmetic: where "twelve" comes from)* For any counts $V, E, F$ and degree list satisfying the three identities that every all-triangle closed surface of Euler characteristic 2 satisfies — $V - E + F = 2$, $3F = 2E$, handshake $\sum_v \deg v = 2E$; that a *surface* satisfies them is consumed informally, the Lean sees only the numbers (audit F24) — the total defect is
$$\sum_v \big(6 - \deg v\big) = 12;$$
if every vertex has degree 5 or 6 (unit defects — the icosahedral screen-sieve situation), there are **exactly twelve** defect vertices.

*(Lean: `poisson_zero_count`, `uniform_gate`, `jensen_band`, `chi_forced`, `reserve_split`, `six_is_card_z6`, `twentyfour_is_oriented_ports`, `sphere_defect_count`, `twelve_unit_defects`.)*

**Named physics (unchanged):** the gate clauses themselves — product collar algebra and trace, reserve pullback, scalar-activation disintegration, slice-wise unbiasedness, local Poisson reserve survival (the papers' L1–L7 stack). The theorem prices their consequence; it does not derive them. The *number* $e^{-P/24}$ is Section 22.

## Proof

*(2)* Substitute and use normalization: $\sum_y w_y e^{-P/24} = e^{-P/24} \sum_y w_y = e^{-P/24}$.

*(3)* Jensen for the convex function $\exp$: $e^{\sum_y w_y(-\varepsilon_y)} \le \sum_y w_y e^{-\varepsilon_y}$, and the exponent on the left is $-P/24$ by the mean condition; the upper bound is termwise $e^{-\varepsilon_y} \le 1$.

*(4)* Cancel $S$.

*(6)* From the three counting identities: $\sum_v (6 - \deg v) = 6V - \sum_v \deg v = 6V - 2E$; triangulation gives $F = \tfrac23 E$, so Euler reads $V - E + \tfrac23 E = 2$, i.e. $6V - 2E = 12$. If degrees are only 5 or 6, each degree-5 vertex contributes $+1$ and each degree-6 vertex $0$, so the number of degree-5 vertices is the total defect, $12$. $\blacksquare$

## Why this happens

The chain's most numerically specific claim is that the canonical susceptibility of the χ_ν continuation is $\chi_{\mathrm{can}} = e^{-P/24} \approx 0.9343$. This module shows exactly which part of that claim is inevitable and which is hypothesis. The *inevitable* part: if each slice of the collar independently survives with the Poisson zero-count probability of its protected reserve, and if the reserve is unbiased at $P/24$ per slice, then the aggregate coefficient is exactly $e^{-P/24}$ — a one-line consequence of normalization; and if unbiasedness holds only on average, convexity still pins the coefficient into the band $[e^{-P/24}, 1]$, so the number is a *floor*, not a point prediction, under the weaker hypothesis. The *hypothesis* part is the gate itself — and honestly counted it is L0–L7, where **L0 is the geometric postulate the arithmetic decorates**: *the collar's transverse structure is an all-triangle Euler-characteristic-2 complex with vertex degrees in {5,6}, its 12 defects are the ports, ports carry two orientations, and the reserve splits uniformly over the ℤ₆ classes of the realized package* (whose identification as the gauge group nature realizes — Γ = ℤ₆ among the four candidate quotients — is itself an open empirical question, consumed here as a hypothesis). Given L0, Euler's formula makes the twelve exact (the soccer-ball count), and the two factorizations $(P/4)/6$ and $12 \times 2$ are verified arithmetic — but nothing formal connects the two stories to each other or to the Poisson exponent; the same machinery would certify $e^{-P/12}$ from a different L0. So the correct grade is *numerology with its postulates named* — the chain's own standard — not "not numerology". What the machine cannot do is make L0–L7 true; it can and does make their price exact.

## In plain language

Here the theory commits to an actual number: coherent record-keeping matter should couple with strength $e^{-P/24} \approx 0.93$ — about a 7% discount from full strength. This section dissects the number. The discount mechanism is survival statistics: the effect must pass through a protective layer of slices, each of which "survives" with the textbook probability of *zero rare events*; if every slice carries the same protected budget, the total discount is exactly the exponential of that budget — forced, no wiggle room. If the budget is only right *on average*, a convexity theorem still traps the discount between $0.93$ and $1$. The budget's value comes from a chain of small integers — an entropy quarter $P/4$, split six ways, on twelve two-sided ports. The twelve *does* follow from soccer-ball arithmetic (the machine checks the defect count from the Euler/triangle/handshake identities; that closed all-triangle surfaces satisfy those identities is classical and consumed informally — audit F24) — but only after you assume the protective layer is shaped like a soccer ball, and assuming the soccer ball is precisely the numerology-shaped step, now written on the label (clause L0). What remains unproven, and is stamped as such, is the physical story that sets the budget — including the shape. The mathematics guarantees only: *if* that story holds, the number is exactly this; if it half-holds, here is the exact band.

# 20. The unique scalar response under SEE (P4, form half)

## Statement

Let $V$ be a real vector space of admissible sources.

**Theorem (unique scalar linear response).** If — **SEE**, the named hypothesis — every admissible source is valued in the one-generator register spanned by the edge-center dual vector $\eta \in V$ (i.e. every $S \in V$ is $S = c\,\eta$), then every linear response $\delta\nu : V \to \mathbb{R}$ acts as

$$\delta\nu(c\,\eta) = \chi \cdot c \qquad \text{with the single susceptibility } \chi := \delta\nu(\eta),$$

and **no second susceptibility exists**: two linear responses agreeing on $\eta$ agree on every admissible source. *(Lean: `unique_scalar_linear_response`, `no_second_susceptibility`.)*

## Proof

Linearity: $\delta\nu(c\,\eta) = c\,\delta\nu(\eta)$. If $\delta\nu_1(\eta) = \delta\nu_2(\eta)$, then on $S = c\,\eta$ both give $c\,\delta\nu_i(\eta)$, equal. $\blacksquare$

## Why this happens

The mathematics is two lines, and that is precisely the point of formalizing it: the entire strength of the χ_ν *form* claim — "the response is $\delta\nu = \chi \langle \eta, S\rangle$ with one number $\chi$, and no independent local scalar channel can be added" — is concentrated in the **hypothesis** SEE (*Scalar Edge-Center Exhaustion*: every quotient-local scalar perturbation that can affect a collar record factors through the unique scalar edge-center register). Once SEE holds, a response has one degree of freedom because a line has one coordinate. The chain keeps SEE deliberately undischarged — it is physical input about which perturbations exist — and this module certifies that nothing else is hiding in the derivation of the form. (Section 21 composes this with the source generator; Section 19 supplies the conditional value of $\chi$.)

## In plain language

If the theory's assumption is right that all relevant disturbances funnel through a single narrow channel, then "how strongly does matter respond?" is answered by **one** number — the response is a dial, not a mixing board, and no secret second dial can exist. The proof is almost embarrassingly short, and that is its value as honesty: it certifies that the entire weight of the claim rests on the funnel assumption (named SEE) and none of it on hidden cleverness. Test the funnel and you have tested everything.

# 21. The ΔS bridge, definition side: the coherent-source generator (T17)

## Statement

**The register (the formal object the chain previously lacked).** A *scalar-slot register* $R$: a state space $Q$ (the physical quotient), a finite slot set $E$, an activity indicator $p_e(q) \in \{0,1\}$, nonnegative opportunity weights $a_e$, and a normal-form activation $q \oplus e$ satisfying three laws — it activates $e$; it changes no other slot's activity; and if $e$ is already active, $q \oplus e = q$. The **canonical opportunity count** is

$$\mathcal{N}(q) \;=\; \sum_{e \in E} a_e\, p_e(q)$$

— a counter *of the same form as* the one the dark-sector collar channel prices (their identification is definitional inside T29's `Channel` structure, Section 21a; that nature instantiates that structure is the named channel hypothesis). A **coherent source** on $R$: a footprint $b_e \ge 0$ with $\sum_e b_e = 1$, and a strength $S \ge 0$ (the observer-side receipts defining $S_{\mathrm{coh}}$ — self-reading, durable re-readable records, prediction beating shuffled controls — are the paper's named operational tests, *not modeled*). The **generator** and **availability** are

$$(\mathcal{L}f)(q) = S \sum_e b_e\big(f(q \oplus e) - f(q)\big), \qquad \mathcal{A}(q) = \sum_e b_e\, a_e\,\big(1 - p_e(q)\big).$$

**Theorem T17.**

1. *(one-slot increment)* $\mathcal{N}(q \oplus e) - \mathcal{N}(q) = a_e\,\big(1 - p_e(q)\big)$: activating a free slot gains exactly its weight; an already-active slot gains nothing.
2. *(Theorem B.7)* $(\mathcal{L}\,\mathcal{N})(q) = S \cdot \mathcal{A}(q)$ — **coherent matter perturbs exactly the counter the collar prices** — with strict positivity when $S > 0$ and $\mathcal{A}(q) > 0$.
3. *(non-saturation, exactly)* $\mathcal{A}(q) > 0 \iff$ some slot has $b_e a_e > 0$ and is inactive at $q$.
4. *(Tier-B response shape)* Composing with Section 20's forced linear response: $\chi \cdot (\mathcal{L}\,\mathcal{N})(q) = (\chi S)\, \mathcal{A}(q)$.
5. *(non-vacuity)* A concrete two-slot register with uniform footprint and $S = 2$ has $\mathcal{A} = \tfrac12$ and $(\mathcal{L}\mathcal{N})(q_0) = 1 > 0$: all hypotheses jointly satisfiable, the generator genuinely fires.

*(Lean: `count_activate`, `gen_count`, `gen_count_pos`, `avail_pos_iff`, `response_form`, `demo_gen_value`.)*

**What stays open — G9, now sharply posed.** The *numerical* record-ΔS → gravity-ΔS calibration is a physical measurement, not a formalizable object; until it exists, a null experiment bounds only the product $\chi \cdot \Delta S$.

## Proof

*(1)* Case split. If $p_e(q) = 1$: $q \oplus e = q$ (idempotence law) and both sides are $0$. If $p_e(q) = 0$: in the sum defining $\mathcal{N}(q\oplus e) - \mathcal{N}(q)$, every slot $e' \neq e$ contributes $0$ (activation touches nothing else) and slot $e$ contributes $a_e(1 - 0) = a_e$.

*(2)* Substitute (1) into the generator:

$$(\mathcal{L}\mathcal{N})(q) = S \sum_e b_e \big(\mathcal{N}(q \oplus e) - \mathcal{N}(q)\big) = S \sum_e b_e\, a_e \big(1 - p_e(q)\big) = S\,\mathcal{A}(q).$$

*(3)* A finite sum of nonnegative terms is positive iff some term is. *(4)* multiply (2) by $\chi$. $\blacksquare$

## Why this happens

Before v4, the chain's row L2.12 said, with unusual bluntness: the "record-side ΔS" that the χ_ν experiment is supposed to source *did not exist as a formal object* — only as prose. This module builds the object, and the payoff is a precision it was impossible to state before. Theorem B.7 now literally says: acting with a coherent source on the canonical opportunity count produces the increment $S \cdot \mathcal{A}(q)$ — a counter **of the same form as** the one whose collar survival Section 19 prices at $e^{-P/24}$. The *identification* of the two — that this register is the channel the collar prices — is, since v7, definitional inside one structure (T29's `Channel`, Section 21a) whose two panels derive both modules' objects; what is *not* a theorem, and stays named channel physics, is that nature instantiates that structure, and the theory's speculative endpoint is *type-correct* exactly modulo that identification plus one missing number. That missing number is the honest content of gap **G9** — what physics must supply is a calibration of this formally-defined record increment against gravity-side entropy — and the chain can now state exactly what an experimental null does and does not bound ($\chi \cdot \Delta S$, jointly).

## In plain language

The theory's boldest speculation says: matter that *keeps coherent records of itself* should ever-so-slightly disturb the same ledger that gravity reads. For years the claim's record-keeping side was words. This section replaces the words with a machine: a finite panel of "slots" that coherent activity can switch on, a counter that adds up switched-on slots, and a theorem computing exactly what a coherent source does to the counter — strength times available head-room, nothing else. The point is not that this proves the speculation; it doesn't and says so. The point is that the speculation is now *sharply posed*: both sides of the conjectured bridge are well-defined objects, provably of the same kind, and exactly one number — the exchange rate between record-ledger and gravity-ledger, gap G9 — is missing. An experiment that sees nothing therefore constrains a precise product of quantities, not a fog.

# 21a. The channel bridge: one structure, both counters (T29, new in v7)

## Statement

**Theorem T29** (`ChannelBridge.lean`). There is a structure `Channel` — one finite indexed family $E$ carrying both the *record panel* (activity indicator, opportunity weights, activation map) and the *collar panel* (slice weights, protected-reserve means) — such that:

1. the T17 slot register and the T16 slice model are both **derived** from it (`toRegister`, `toSlices`), and the identification "slots = slices" is definitional (`same_family … := rfl`);
2. the record-side counter $\mathcal{N}$ and the collar-side coefficient $\lambda_{\mathrm{collar}}$ are sums **over the same family**;
3. *(the composite Tier-B1 law)* under the gate clauses (slice-wise unbiasedness at $P/24$), for any coherent source on the channel:
$$\lambda_{\mathrm{collar}} \cdot (\mathcal{L}^{\mathrm{coh}}\mathcal{N})(q) \;=\; e^{-P/24}\cdot S \cdot A(q),$$
with a non-vacuity instance on which everything fires jointly and strictly positively.

## Proof

The structure *is* the proof: `Channel` packages both panels over one index type; `toRegister`/`toSlices` are field re-bundlings, so the identification is `rfl`; the composite is T16's `uniform_gate` rewriting $\lambda_{\mathrm{collar}}$ to $e^{-P/24}$, times T17's `gen_count` rewriting the generator's action on the counter to $S \cdot A(q)$ — both now speaking about one object. $\square$

## Why this happens

The audit's F11 observed that "coherent matter perturbs **the same counter** the collar prices" had no formal counterpart — the two counters lived in disjoint modules, and the sameness was prose. The repair is not a theorem *connecting* two structures (there is nothing to prove between unrelated types); it is a **structure inside which the sameness is definitional**, which is the honest formal shape of an identification claim. The physical content that used to hide inside the word "same" is now exactly two named residues, and nothing else: whether nature's record channel and collar channel instantiate one `Channel` (the channel identification — a hypothesis about the world, not about the mathematics), and the numerical size of $S$ for a buildable coupon (G9 proper). The chain's headline number $e^{-P/24}$ now flows through one machine-checked composite from gate clauses to response law.

## In plain language

The theory keeps one ledger for "how much record-keeping is happening" and another for "how much the gravity-discount mechanism cares", and the audit caught the documents asserting — in prose only — that these are the same ledger. The fix is a formal object that *has one ledger with two columns*: build it, and "same ledger" stops being a claim and becomes the definition; the discount coefficient and the record activity are then provably two readings of one book, and the famous discount-times-activity law is a single checked computation. What remains genuinely open is no longer hidden: does the real world keep its books in this shape (a physics question, now named), and how large is the activity for anything we can actually build (the calibration gap G9).

# 22. The two P's (T11 / L2.5)

## Statement

The constant $P$ enters the chain only through $\chi_{\mathrm{can}} = e^{-P/24}$. The corpus contains **two** values with different provenance, and both are now digit-checked:

**Theorem T11.**

1. *(the published constant is a definition)* With $\varphi = \frac{1 + \sqrt5}{2}$,
$$P_{\mathrm{pub}} \;:=\; \varphi + \frac{\sqrt{\pi}}{137.035999177} \;\in\; \big(1.630968209403959,\ 1.630968209403960\big),$$
where $137.035999177$ is the CODATA 2022 inverse fine-structure constant, entering **by definition**. The published digits are exactly this CODATA-calibrated expression — bracketed from scratch ($\sqrt5$ by squaring, 20-digit $\pi$ bounds). Nothing here derives $\alpha$.
2. *(the solver root is a different number)* The zero-input fixed-point solver's reported root $P_{\mathrm{root}} = 1.63097209569$ satisfies
$$P_{\mathrm{root}} - P_{\mathrm{pub}} \in \big(3.8 \times 10^{-6},\ 4.0 \times 10^{-6}\big)$$
— the two branches are **distinct numbers** (the ≈ 300 ppm α-discrepancy of the review, expressed in P-space).
3. *(the χ targets, to nine digits)* $\chi_{\mathrm{can}}^{\mathrm{pub}} = e^{-P_{\mathrm{pub}}/24} \in (0.934300639,\ 0.93430064)$ and $\chi_{\mathrm{can}}^{\mathrm{root}} = e^{-P_{\mathrm{root}}/24} \in (0.934300487,\ 0.934300489)$, via a six-term Taylor sandwich for $\exp$ with explicit remainder (no floating point, no `native_decide`).
4. *(the branch gap is real and immaterial)* $\chi^{\mathrm{pub}} - \chi^{\mathrm{root}} \in (1.4 \times 10^{-7},\ 1.6 \times 10^{-7})$: real in the 7th decimal place (published branch larger), and far inside every tolerance of the experiment's Documents A/C ($\ge 10^{-3}$ relative).

*(Lean: `Ppub_bounds`, `Proot_gap`, `chiCanPub_bounds`, `chiCanRoot_bounds`, `chi_branch_gap`.)*

## Proof

*(1)* Bracket the ingredients: $2.2360679774997896 < \sqrt5 < 2.2360679774997897$ (squaring both rational bounds), hence tight bounds on $\varphi$; $1.77245385090551602 < \sqrt\pi < 1.77245385090551603$ from 20-digit rational bounds on $\pi$; divide by the CODATA value with directed rounding; add. *(2)* subtract the brackets. *(3)* For $q = -P/24 \in (-1, 0)$, the Lean-verified bound $\big|e^q - \sum_{m<6} \frac{q^m}{m!}\big| \le |q|^6 \cdot \frac{7}{4320}$ sandwiches $e^q$ between two explicit rationals evaluated at the two ends of the $P$-bracket; monotonicity of $\exp$ transports the bracket. *(4)* subtract the χ brackets. $\blacksquare$

## Why this happens

This is the chain's *forensic accounting* result. The corpus's rhetoric sometimes presented $P$ as derived with "zero fitted parameters"; the audit found — and the machine now certifies — that the *published* $P$ is, by its own defining formula, a repackaging of the **measured** fine-structure constant (golden ratio plus $\sqrt\pi/\alpha^{-1}_{\mathrm{CODATA}}$: a definition, not a derivation), while the genuine zero-input solver, when actually executed, produces a *different number*, missing CODATA α by ≈ 300 ppm. Both facts are now theorems about the published numerals. The third theorem prices the discrepancy where it actually matters: the experiment's target $\chi_{\mathrm{can}}$ shifts only in its 7th decimal place — irrelevant for any measurement contemplated (tolerances are $10^{-3}$), decisive for the "zero fitted parameters" claim (which the fine print of the corpus already conceded and the headline should not repeat). The solver's own derivation (its spectral input — "P's source branch") remains the named open item.

## In plain language

A story about intellectual bookkeeping. The theory's key constant $P$ was published with a beautiful-looking formula and, at times, the boast "derived from nothing". Checked to the last digit by machine, the published number turns out to be built *from a measured quantity* — the fine-structure constant, physics' most famous measured number — plugged straight into its definition. Meanwhile the actual from-scratch computation, run for real, yields a slightly *different* value, off by about three parts in ten thousand. Both findings are now certified. And the practical verdict is also certified: for the planned experiment the difference is utterly negligible (eighth decimal place of the target), so nothing about the test changes — but the "derived from nothing" headline is dead, by proof. The framework keeps both numbers on the books, labelled by provenance: one is a calibration, the other an unfinished derivation.

---

# Part IV — The cage, the numbers, and the experiment

*Modules: `EnergyCage.lean`, `LedgerNumerics.lean`, `ConsensusSafety.lean`. These theorems price the experiment in `chi_nu_test/` before it runs: what a detection must cost, what a null bounds, and what the ledgers' printed constants really are.*

**Composition (added after the audit's F17).** Put T11 next to Section 19 and say the quiet part: on the only executed branch, the experiment's canonical target $\chi_{\mathrm{can}} = e^{-P_{\mathrm{pub}}/24}$ inherits the measured fine-structure constant *by definition*. A hypothetical clean measurement of $0.9343$ would therefore confirm an $\alpha$-calibrated number, not a zero-input derivation — that reading requires first closing P's source branch, which currently misses CODATA by $\sim$300 ppm, i.e. by $\sim 2\times 10^{6}$ standard deviations of the measured constant.

# 23. The conservation cage (T10)

## Statement

Model a device with a switchable internal state $s \in \{\mathrm{OFF}, \mathrm{ON}\}$ and a position-dependent state energy $E : \mathrm{Pos} \times \{\mathrm{OFF},\mathrm{ON}\} \to \mathbb{R}$ (conservative sector: the force is $-\nabla E$, so moving $q_1 \to q_2$ at fixed switch extracts $E(q_1, s) - E(q_2, s)$). Define the **toggle cost** $\tau(q) = E(q, \mathrm{ON}) - E(q, \mathrm{OFF})$ and the **ABBA cycle work**

$$W_{\mathrm{cyc}}(q_1, q_2) = \big(E(q_1, \mathrm{ON}) - E(q_2, \mathrm{ON})\big) + \big(E(q_2, \mathrm{OFF}) - E(q_1, \mathrm{OFF})\big)$$

(toggle ON at $q_1$ → move to $q_2$ → toggle OFF → return).

**Theorem T10.**

1. *(cycle identity — the first law as an identity)* $W_{\mathrm{cyc}}(q_1, q_2) = \tau(q_1) - \tau(q_2)$, identically. And since v7 the slogan is a theorem at its advertised generality (audit F25): for **every** closed schedule of moves and toggles, extracted work = net toggle-ledger payment, so no schedule whose toggles are ledgered at most ε extracts more than (number of toggles)·ε (`no_schedule_beats_the_ledger`).
2. *(no free toggle)* If $|\tau(q)| \le \varepsilon$ everywhere, every cycle extracts at most $2\varepsilon$. Contrapositive: **a switchable force with a zero toggle-energy ledger is a perpetual-motion machine.**
3. *(ledger lower bound)* Extracting $W$ per cycle forces $|\tau(q_1)| \ge W/2$ or $|\tau(q_2)| \ge W/2$: a genuine DETECT must *log* it.
4. *(the design-point numbers, machine-checked with π-bounds)* The phantom surface density lever $\sigma_{\mathrm{ph}} = \Delta\nu \cdot g/(4\pi G) \in (11.6,\ 11.8)\ \mathrm{kg\,m^{-2}}$ per $\Delta\nu = 10^{-9}$; the Earth-surface potential $\Phi_N = G M_E / R_E \in (6.24,\ 6.26) \times 10^7\ \mathrm{J\,kg^{-1}}$; and the toggle transaction at the 56 gf design point ($\Delta M = 0.056\ \mathrm{kg}$):
$$|\Delta M \cdot \Phi_N| \;\in\; (3.49,\ 3.52)\ \mathrm{MJ} \quad\text{per ACTIVE toggle.}$$
5. *(budget cap)* A per-toggle energy budget $B$ caps the switchable phantom mass at $\Delta M \le B / \Phi_N$.

*(Lean: `cycleWork_eq_toggleCost_diff`, `no_free_toggle`, `toggle_ledger_lower_bound`, `sigma_ph_value`, `phi_N_value`, `toggle_energy_value`, `phantom_mass_cap`.)*

## Proof

*(1)* Expand and cancel — four terms, two signs each: $W_{\mathrm{cyc}} = E(q_1,\mathrm{ON}) - E(q_1,\mathrm{OFF}) - \big(E(q_2,\mathrm{ON}) - E(q_2,\mathrm{OFF})\big) = \tau(q_1) - \tau(q_2)$.

*(2)* Triangle inequality on (1). *(3)* If both were $< W/2$, (1) would bound the cycle below $W$. *(4)* Interval arithmetic with rational endpoints and the Mathlib bounds $3.141592 < \pi < 3.141593$. *(5)* Divide. $\blacksquare$

## Why this happens

The χ_ν device claims a force that can be *switched* (coherent record-keeping on/off). Energy conservation then speaks with unusual bluntness, and the cage formalizes it: in a conservative sector, work around any toggle-move cycle is *identically* the difference of toggle costs, so either switching the state costs real energy — logged somewhere — or arbitrarily repeatable work comes from nowhere. What the theorems themselves force is precise and modest: cycle work equals toggle-cost *differences*, so a DETECT with genuine transport cycles must log at least the realized cycle work — `ΔM·g·Δh ≈ 0.55 J` per metre of stroke at the design point, and ≈ 0 for a balance protocol at fixed height. The vivid headline — each activation transacting about **3.5 megajoules** against the Earth's potential — is `ΔM·Φ_N`, the *infinity-referenced interaction energy*: a **named pricing convention** (the G10-convention: toggling transacts the full interaction energy against a locally-audited ledger), adopted by the ledgers as their default audit scale, *not* a consequence of theorems (2)–(3); pricing genuine source creation relativistically would instead give `ΔM·c² ≈ 5×10¹⁵ J`. This is why the chain's own expected outcome is **NULL**, and why its falsification discipline demands that any claimed DETECT arrive together with the Document C Part 7 energy log — the theorems set the minimum, the named convention sets the scale the log is audited against. The cage does not refute the force law (non-conservative completions would have to document themselves in exactly that ledger); it prices it, and v6.1 prices the pricing.

## In plain language

Suppose the gadget worked — you flip a switch and a tray of coherent matter gets measurably lighter. Then here is a money machine: flip it on, let the "lightness" lift it; flip it off, let full weight pull it down; repeat, harvesting the difference forever. The only escape from that absurdity — and it *is* the only escape; that's a theorem, not rhetoric — is that flipping must *cost* energy wherever the machine actually harvests work: the theorem computes that cost as exactly the work harvested (joules per metre of lift at this experiment's scale). The famous phone-battery-per-flip figure is bigger: it prices each flip as if the 56 grams were hauled in from infinitely far away — a declared bookkeeping convention the ledgers audit against, now carried on the label as a hypothesis rather than sold as the theorem. So the framework predicts its own experiment will read *nothing*, and it pre-registers the standard of proof for the alternative: a claimed detection must arrive with an energy log that reconciles — against the theorem's minimum and the convention's declared scale. The physics may be speculative; the accounting is honest about which line is law and which is convention.

# 24. Run-matrix conversion constants, and one erratum (T24)

## Statement

All inputs are the test ledgers' own declared constants ($g = 9.80665\ \mathrm{m/s^2}$, $G = 6.67430 \times 10^{-11}$, coupon area $A = 4.8\times 10^{-3}\ \mathrm{m^2}$, lock-in floor $F_{\min} = 5\times10^{-8}\ \mathrm{N}$, battery energy $E_{\mathrm{batt}} = 3.6 \times 10^4\ \mathrm{J}$).

**Theorem T24 (the derived instrument numbers, theorem-form).**

$$C_{\mathrm{geom}} = \frac{g^2}{4\pi G} \in (1.146636,\ 1.146638)\times 10^{11}\ \mathrm{N\,m^{-2}} \quad\text{(the printed } 1.146637\times10^{11}\text{ is exact to its last digit);}$$

$C_{\mathrm{geom}} A \in (5.5038, 5.5039)\times 10^8\ \mathrm{N}$ per unit $\Delta\nu$; the headline null-bound conversion $\Delta\nu_{\min} = F_{\min}/(C_{\mathrm{geom}} A) \in (9.084, 9.085) \times 10^{-17}$ (the printed $9.1\times10^{-17}$ rounds **up** — the safe direction for a null bound); the design point $\Delta\nu = 10^{-9}$ gives force $\in (0.55038, 0.55039)\ \mathrm{N}$, i.e. $(56.12, 56.13)$ gf, and SNR $\in (1.100, 1.101)\times 10^7$; the lock-in statistical floor is **exactly**

$$\sigma_F = 10^{-6}\,\sqrt{2/1800} = \frac{10^{-6}}{30}\ \mathrm{N} \qquad\text{(because } \sqrt{2/1800} = \sqrt{1/900} = 1/30\text{ — no numerics at all);}$$

and the **battery-coupon ceiling** — the largest $\chi \cdot \Delta S$ a battery-powered coupon can source against $\Phi_N$ — is

$$\frac{E_{\mathrm{batt}}/\Phi_N \cdot g}{C_{\mathrm{geom}} A} \;\in\; (1.02,\ 1.03)\times 10^{-11}$$

(in the ledger's force units that interval is 0.575 to 0.578 gf — a rendering of the in-proof force bracket; the gf conversion is ledger-side arithmetic, not itself a Lean clause — audit F29).

**Erratum (found by this theorem, fixed in the ledgers).** DOCUMENT A §1.9 printed the ceiling as "$\lesssim 1\times10^{-11}$ ($\approx 0.5$ gf)" — about **3% below the true ceiling, in the unsafe direction** for a discrimination bound (a battery-sourced signal could slightly exceed the printed cutoff and be misclassified as beyond-battery). The ledger now prints $\lesssim 1.1\times10^{-11}$ ($\approx 0.58$ gf) with an erratum note. *(Lean: `Cgeom_bounds`, `CgeomA_bounds`, `dnu_min_bounds`, `design_force_bounds`, `design_gf_bounds`, `design_snr_bounds`, `lockin_stat_exact`, `battery_coupon_bounds`.)*

## Proof

Directed interval arithmetic over the declared rationals, with $\pi \in (3.141592, 3.141593)$; each bound is a `nlinarith`-checked inequality between rationals. The lock-in floor is the one *exact* identity: $2/1800 = 1/900 = (1/30)^2$. The battery ceiling composes the $\Phi_N$ bracket of T10 with the $C_{\mathrm{geom}}A$ bracket. $\blacksquare$

## Why this happens

A NULL/DETECT verdict is only as good as the conversion constants the decision rules quote, and hand arithmetic in lab documents is exactly where small errors hide. Pushing the run matrix through theorem-form interval arithmetic did three things: certified that almost every printed number was right (several to their last digit, one — the statistical floor — *exactly*, by an accidental perfect square); certified that the one deliberate rounding (the headline $\Delta\nu$ bound) errs in the conservative direction; and caught one genuine mistake — the battery-discrimination ceiling, understated by ~3% *in the direction that could misclassify a mundane signal as exotic*. The erratum is small, but its moral is the chain's whole method in miniature: the same machinery that formalizes holographic screens will happily audit a lab notebook, and the notebook needed it.

## In plain language

Before trusting the experiment's verdict, audit its arithmetic. Every conversion factor the decision rules use — how a force reading translates into the theory's units, what the noise floor is, how big a signal a mere battery could fake — was re-derived under proof-checker discipline, where rounding must be justified line by line. Result: the lab documents were almost impeccable — one constant even turned out to be an exact fraction, $10^{-6}/30$, hiding behind a decimal — and their one rounding of the headline bound leans the *cautious* way. But one number was genuinely wrong: the "could a battery fake this?" ceiling was printed 3% too low, the one direction that could let a battery-powered artifact masquerade as new physics. It is now fixed, with the proof as the paper trail. Even notebooks deserve theorems.

# 25. The QBFT safety appendix, with a boundary finding (T23)

*(A corpus **extension**, not a chain link: consensus-protocol engineering on the observer graph, formalized so the corpus's written finite mathematics is fully covered. No connection to the χ_ν chain exists — the module says so.)*

## Statement

Observers $V$, at most $f$ of them faulty (Byzantine), $F \subseteq V$ the faulty set, $|F| \le f$; each observer casts at most one signed vote per view, modeled as a function $\mathrm{vote} : V \to \mathrm{Option}(\alpha)$ (this encodes single-voting P1 + unforgeable signatures A5). A **certificate** for a value $a$ is a quorum $Q_a$ all of whose nonfaulty members voted for $a$.

**Theorem T23.**

1. *(safety core)* If two certificates' quorums overlap in more than $|F|$ observers, their certified values are equal.
2. *(quorum intersection at the classical sizing)* If $|V| = 3f + 1$ and both quorums have size $\ge 2f+1$, then $|Q_a \cap Q_b| \ge f + 1$; composing: **no two nonfaulty observers finalize conflicting values** at $n = 3f+1$ — the appendix's Theorem (i).
3. *(the general-$n$ sizing)* Quorums of size $q$ with $f + 1 + |V| \le 2q$ always overlap in $\ge f+1$ observers.
4. *(boundary finding — new, contradicting a clause of the appendix's prose)* The appendix asserts the overlap bound "is guaranteed by" $n \ge 3f + 1$. **False for $n > 3f+1$ at fixed quorum size $2f+1$**: already at $n = 3f + 2$ (five observers, $f = 1$) the 3-quorums $\{0,1,2\}$ and $\{2,3,4\}$ overlap in exactly **one** observer — which the adversary may own. The theorem stands at $n = 3f+1$ exactly; for general $n$ the quorum must scale as in (3).

*(Lean: `qbft_safety_core`, `quorum_intersection_exact`, `quorum_intersection_general`, `qbft_safety`, `quorum_overlap_gap`. Liveness and optimality remain external citations — DLS 1988, Lamport–Shostak–Pease 1982 — as in the appendix itself.)*

## Proof

*(1)* The overlap has more members than $F$ can cover, so it contains a nonfaulty observer $v$; $v$'s unique vote supports both $a$ and $b$; hence $a = b$. *(2)* Inclusion–exclusion against the universe: $|Q_a \cap Q_b| = |Q_a| + |Q_b| - |Q_a \cup Q_b| \ge (2f{+}1) + (2f{+}1) - (3f{+}1) = f + 1$. *(3)* Same, with $|Q_a \cup Q_b| \le |V|$. *(4)* Explicit finite counterexample, checked by `decide`. $\blacksquare$

## Why this happens

Byzantine-fault-tolerant safety is a pure counting fact — two big-enough committees in a small-enough universe must share an honest member, and one honest member cannot have voted both ways. The interesting part is the *boundary finding*: the appendix's prose claimed the committee-overlap property follows from the population bound $n \ge 3f+1$, quietly holding the committee size at $2f+1$; the machine found the gap — the property is an equality-tight fact at $n = 3f+1$ and *fails immediately* at $n = 3f+2$ — and the module supplies the correct general sizing. A small but genuine example of formalization catching a quantifier slip that survived human review, in the one part of the corpus that is ordinary distributed-systems mathematics.

## In plain language

A side chapter: if some observers may *lie*, how do the honest ones avoid certifying two contradictory official stories? The classical answer — make every decision require a committee so large that any two committees must share an honest member — is verified here in full. And the proof checker earned its keep: the source document claimed the safety margin follows from having "at least $3f+1$" observers; actually it holds *only at exactly* $3f+1$ unless committees grow with the population — with five observers and one liar, two legal committees of three can overlap in just one member, possibly the liar. A concrete five-person counterexample, a corrected rule, and a reminder that "at least" and "exactly" are different words.

---

# Part V — What remains open

# 26. The named hypotheses and gaps (the honest ledger)

Everything unproven in the chain is *physics*, listed here by name. The v5 sweep of the full corpus confirmed none of these is secretly discharged anywhere; each sits directly upstream of machine-checked consequences (its "payoff, already banked").

**SEE — Scalar Edge-Center Exhaustion.** *Claim:* every quotient-local scalar perturbation that can affect a collar record factors through the unique scalar edge-center register. *Status:* physical hypothesis, stated as an assumption in the papers. *Banked payoff:* the response form is one dial (Section 20), and the source generator composes with it (Section 21).

**MAR — Minimal Admissible Realization.** *Claim:* the structural-economy axiom selecting the realized matter package ($N_c = 3$, the five multiplets + Higgs, the Yukawa pattern). *Status:* explicitly an axiom; the corpus proves consequences inside the MAR-admissible class, never MAR. *Banked payoff:* hypercharges forced uniquely; kernel exactly $\mathbb{Z}_6$ (Section 17).

**L1–L7 — the collar-gate clauses.** *Claim:* product collar algebra and trace, reserve pullback, scalar-activation disintegration, slice-wise unbiasedness at $P/24$, local Poisson reserve survival. *Status:* the gate of the exact-coefficient theorem; receipts discipline defined but no certified instance. *Banked payoff:* $\lambda_{\mathrm{collar}} = e^{-P/24}$ exactly, the Jensen band, the forced $\chi_{\mathrm{can}} = \lambda_{\mathrm{collar}}$, the 24- and 12-bookkeeping (Section 19).

**G9 — the record-ΔS → gravity-ΔS numerical bridge.** *Claim needed:* a calibration identifying the formally-defined record-side increment (Section 21) with gravity-side entropy change, with a number. *Status:* the #1 physics gap; no draft exists anywhere in the corpus (v5 sweep). *Consequence:* a null experiment bounds only the product $\chi \cdot \Delta S$.

**G10 — the toggle-energy ledger, and the G10-convention.** *Claim needed:* the experimental energy log itself. *Status:* the cage is theorem-form (Section 23); the *ledger* is an experiment. A DETECT with transport cycles and no entry ≥ the realized cycle work is self-refuting by T10; the ≈ 3.5 MJ audit scale is the **named G10-convention** (infinity-referenced interaction pricing), a hypothesis of the decision rule.

**P's source branch.** *Claim needed:* the Ward-projected hadronic spectral computation that would turn the solver's $136.9948$ into a genuine prediction of $137.0360$. *Status:* open by the corpus's own admission (`HADRON.md`); meanwhile the published $P$ is CODATA-calibrated by definition (Section 22).

**D3's Bisognano–Wichmann identification + scaling limit.** *Claim needed:* that the (now machine-checked, Section 15) state-generated modular flow of cap/wedge states *is* geometric boosts, in the scaling limit. *Status:* fully conditional; formalizing it would require type-III operator-algebra modular theory. The finite core is no longer open — only the identification.

**Payoff grading (added after the audit's F12).** The named hypotheses above do heterogeneous work, and the ledger should say so. *Forcing-grade* (modest hypothesis, sharp surprising consequence): MAR → T13. *Band-grade* (hypothesis buys an inequality): mean-unbiasedness → the Jensen band of T16. *Restatement-grade* (the hypothesis is the conclusion in other words): SEE → P4 (a linear functional on a line is a scalar); slice-wise unbiasedness → `uniform_gate` (a weighted average of a constant). The experiment's headline number flows through two restatement-grade links in a row — a reader should know that.

**The named conventions and identifications (v6.1, from the audit).**

**G10-convention.** *Claim:* toggling transacts the full infinity-referenced interaction energy `ΔM·Φ_N` against a locally-audited ledger (the ≈ 3.5 MJ audit scale). *Status:* a declared pricing convention of the decision rule — T10 forces only realized cycle work (Section 23). *Banked payoff:* the ledger arithmetic is theorem-form given the convention (T24).

**L0 — the collar's shape.** *Claim:* the collar's transverse structure is an all-triangle χ = 2 complex with degrees in {5,6}; its 12 defects are the ports, two orientations each; the reserve splits uniformly over the ℤ₆ classes. *Status:* the geometric postulate the 24-bookkeeping decorates (Section 19). *Banked payoff:* Euler's formula makes the twelve exact given L0 (T16).

**The realized-ℤ₆ reading.** *Claim:* nature's gauge group is the full quotient `SU(3)×SU(2)×U(1)/ℤ₆` (Γ = ℤ₆ among the four candidates). *Status:* open empirical question; the kernel theorem (T13b) says the known fields factor, not that the quotient is realized. *Banked payoff:* the "6" of `P/24`.

**The channel identification.** *Claim:* the source generator's opportunity counter (Section 21) *is* the channel the collar prices (Section 19). *Status:* named physics; since v7 the mathematical half is done — inside T29's `Channel` structure (Section 21a) the identification is definitional and the composite law is a theorem — so what remains is exactly whether nature instantiates the structure. *Banked payoff:* type-correctness of the ΔS bridge (T17).

**Open mathematics (named after the audit's F19; as of v8, all four audit rows AND their leftovers are closed).** The λ-constancy step (audit F8) is **closed** — T26. The **Route-A joint model** (audit F2) is **closed** — T27, §11a — and its termination leftover is closed too: **T32**, `decodeStep_wellFounded` — the decode dynamics terminates under EVERY scheduler (the rank stratification is itself a lexicographic potential), so every schedule lands on the one record the tube pins. The **real-time KMS statement** (audit F9) is **closed at the finite-dimensional level** — T28, §15a — and its Skolem–Noether leftover is closed: **T33**, every algebra automorphism of the matrix algebra is inner, so the Hamiltonian-implemented form was never a restriction; any KMS-satisfying automorphism IS the modular map with conjugator `c·ρ`. The twelve-port count's missing surface (audit F24) is closed: **T35**, `TriangulatedSphere` — `3F = 2E` and the handshake are now proven of an actual closed triangulated surface (Euler stays the named topological input), with a kernel-checked icosahedron. Two further theorems came from the simulation companion: **T31** (the readout trichotomy — above the sharp threshold every tube reading is realizable, at it the readout is a bijection, below it empty fibers exist; the stall dichotomy of T27.4 has content exactly below the threshold) and **T30** (the local-decodability phase boundary — screens with column ring-distance ≥ 3 admit zero local constraint-propagation inferences while the adjacent tube's closure is the entire block: *being determined* and *being locally derivable* provably split, with the `n=8, g=3, t=3` full-rank/zero-inference configuration machine-checked). **And since v9 the intermediate-slope item is closed too — T36, §13b**: the sharp threshold is invariant across every 1-Lipschitz worldline (all rational slopes `≤ 1`, zigzags, reversals), with complete local decodability; `slopeTube_isInformationSet_iff` is the conjectured statement, proven sharp for every `p ≤ q`, every `n, t`, every base point. Still open, formalizable — now exactly **one** item: the **arbitrary-subset weight-distribution classification** below (T30's own named leftover, the gap-2 propagation-completeness classification, is closed too: **T37**, complete iff the ring is odd — §13b Coda) — and T36's beyond-Lipschitz instances supply its machine-checked walls: no coarse invariant (step multiset, last step, cardinality) can classify it (`pairScreen_class_6_2` at `(6,2)` is order-sensitive; ALL `8^4` paths decode at `(8,3)`; the slope-2 line fails at exact capacity at `(10,4)`). **And since v10 (§13c) that one item is substantially reduced:** on **even** rings T38 proves failure ⟺ a single-parity ghost is dark — arbitrary subsets classify sector-by-sector, so the residual question is the zero-set order of Rule 60 on the half ring (numerically rigid through `m = 13`, minimal rigid window exactly `⌊m/2⌋`); on **two-power** rings the worldline case closes outright — T39, every pair screen, no causality hypothesis; and the diagonal family is classified on both parities (T40/T41). What remains is the odd-ring general case (the simulation's C2: all `2^n − 1` zero-sets pairwise incomparable, exhaustive `n ≤ 13`) and the Rule-60 rigidity statement itself.

Also honestly recorded: the chain's remaining *mathematical* stretch item (not required by any physics reading) — the full weight-distribution classification of arbitrary Rule-90 cell subsets; it is a decidable predicate, so candidate answers stay machine-testable. (The v5 edition of this paragraph also listed the stride-$g$ conjecture; that one is now the theorem T25 of Section 13a. The v9 edition listed it whole; since v10 the even-ring half is the theorem T38 — reduced to single-parity ghosts — and the two-power worldline case is closed, T39, so what is genuinely open is the odd-ring order structure and Rule-60 zero-set rigidity, §13c.)

# 27. Verdict

Strip the corpus to what survives scrutiny and five things remain, all now load-bearing:

1. **A complete, self-contained, machine-checked consensus core.** Termination and completeness for a canonical repair operator that *exists on every carrier*; the non-confluence counterexample that makes objectivity a real problem; and both objectivity routes as theorems — Route B with the machine check that its declared order is genuinely load-bearing, Route A with a holographic screen theory that is *sharp* (T9), *boost-invariant* (T18), *completely classified for two-column screens at every stride* (T25, subsuming T20's parity classification: capacity ⟺ coprimality ∧ the counting bound) — **and, since v7, assembled**: a genuinely local, tube-preserving repair runs on the jewel's own carrier and — since v8 with *termination under every scheduler*, T32 — every schedule settles to the one world the tube pins (T27, §11a) — with the screen theory now *worldline-free* as well (since v9, T36: every causal observer's screen carries full capacity, by local propagation alone; and T37: two-column local decodability classified at every ring distance), *factored* (since v10, T38: even rings split into two non-interacting Rule-60 sectors and arbitrary-subset failure ⟺ a single-parity ghost), *causality-free on two-power rings* (T39: every worldline decodes, teleports included), *counting-optimal on odd rings* (T40: the lone lightlike diagonal — one cell per row — decodes with zero slack; T41: opposite-parity diagonal pairs at any offset), and the geometry-blind MDS extreme (T19/T22) marking the opposite pole. One tree, 38 modules, 1284 environment-swept non-internal theorem/def declarations (both namespaces), 0 `sorry`.

2. **An exactly-drawn mathematics/physics boundary, stress-tested four times** (v5 corpus sweep; v6 statement audit; the two-pass adversarial audit; the v7 closure campaign). Every written mathematical sub-claim in the chain is formalized *up to the one named residual item of Section 26* (the arbitrary-subset classification — the intermediate-slope positive half became a theorem in v9, T36; since v10 its even-ring half is the theorem T38 and its two-power worldline case the theorem T39, leaving the odd-ring order structure and Rule-60 rigidity, §13c); the audit's own mathematics rows became theorems (T26–T29), their leftovers became theorems in v8 (T32, T33 — plus T30, T31, T35), and the places where earlier versions had been too generous to physics were reclaimed (T20, T21, and in v7 the real-time half of D3, T28). What remains open is exactly the list of Section 26 — and each item's first consequence is already proven.

3. **A falsification methodology with theorems attached.** The conservation cage (T10) prices the χ_ν claim in advance; the run-matrix constants are theorem-form with one erratum caught in the unsafe direction (T24); a DETECT/NULL verdict will adjudicate *named physics*, never arithmetic.

4. **The two-P finding, beyond dispute** (T11): the published constant is a CODATA-calibrated definition; the executed solver gives a different number; the difference is priced between $1.4\times10^{-7}$ and $1.6\times10^{-7}$ in χ — immaterial for the experiment, decisive against "zero fitted parameters" rhetoric.

5. **A map of what is open that is purely physical** — two gaps, four named hypothesis families, one source branch, one identification — with the property that discharging any item propagates instantly through Lean-checked mathematics.

**In plain language, finally.** This program's real discovery so far is not a new force and not a new particle. It is a *demonstrated way of working*: take an idea usually left to philosophy — "is there one objective reality, and what would it cost?" — and push it all the way down to machine-checked theorems, so that the honest answer ("objectivity is a theorem with hypotheses; here are the hypotheses; here is the exact price of each") replaces both wishful thinking and hand-waving skepticism. Along the way it produced one genuinely beautiful piece of mathematics — a perfect, sharp, fully classified holographic screen on the humblest universe imaginable — audited its own lab notebooks by proof, caught its own errata, refuted its own headline rhetoric where it deserved refuting, submitted to a full adversarial audit and adopted its findings, and wrote down, in advance — with the law and the convention on separate lines — exactly what it would take to believe its boldest speculation. The most likely experimental outcome, by its own theorems, is *nothing*; and the honest yield of *nothing* is a bound on a product with one factor still uncalibrated (G9) — a bound-setting exercise and a rehearsal of the receipt discipline, informative but not, until G9 exists, an adjudication of the tower; hitting the χ target would, on the only executed branch, confirm an α-calibrated number rather than a derivation (Section 22). Even "dynamics" turned out to be a theorem with a hypothesis: every observer's state already carries its distinguished modular step (T21); whether that step is a clock, and which geometric time it tells, are the mathematics and physics still owed.

---

# Appendix A. Theorem → Lean map

All paths relative to [`proof_chain/formal/OPHProofChain/`](proof_chain/formal/OPHProofChain/). Every listed declaration is `sorry`-free; `#print axioms` reports at most `propext`, `Classical.choice`, `Quot.sound`.

| Label | Result | Module | Key declarations |
|---|---|---|---|
| T0 | consistency ⇔ edge agreement | `Core/Primitives.lean` | `consistent_iff_edgeConsistent` |
| T1 | termination of local repair (H1–H3) | `Core/Primitives.lean` | `termination`, `mismatchCount_lt` |
| T2 | completeness (normal forms = consistent) | `Core/Primitives.lean` | `completeness` |
| T3 | non-confluence of asynchronous repair | `Core/Primitives.lean` | `demoCarrier_not_confluent`, `demoCarrier_repairs_dont_commute` |
| T4a | confluence from commutation (Route B, sufficient) | `Core/Primitives.lean` | `confluence_of_commute`, `locallyConfluent_of_commute` |
| T4b | boundary-fiber observer-uniqueness (Route A) | `Core/Primitives.lean` | `boundary_fiber_observer_unique`; complements `demoCarrier_Hfib_fails`, `demoCarrier_dir_confluent`, `demoCarrier_dir_not_observer_unique`, `demoCarrier_dir_observer_unique_under_seed`, `demoCarrier_Hfib_holds_seed` |
| T5 | Rule-90 width-3 toy | `Core/Rule90.lean` | `rule90_Hfib_good`, `rule90_Hfib_bad_fails`, `rule90_gauge_nontrivial`, `rule90_no_frustrationFree_repair` |
| T6 | quotient repair package + schedule independence | `QuotientRepair.lean` | `globalRepair_*`, `schedule_independence`, `World`, `repair_respects_gauge`, `symmetricPair_not_locallyConfluent`, `symmetricPair_descends`, `symmetricPair_normalForm_iff`; Newman in `Rewriting.lean` |
| T7 | bare consensus not Einstein-complete | `NotEinsteinComplete.lean` | `bare_consensus_not_einstein_complete`, `no_reduct_functional_determines_geometry` |
| T8 | layered carrier reconstruction | `LayeredCarrier.lean` | `sweep_eq_extend`, `hfib_singleton`, `sweep_restrictB`, `reconstruction_of_boundary_preserving_repair` |
| T9 | the sharp width-2 timelike screen | `Rule90Cylinder.lean` | `tube_information_set_iff`, `right_sweep`, `left_sweep`, `seed_eq_zero_of_tube_zero`, `single_column_not_information_set`, `spacelike_proper_subset_fails` |
| T9′ | the jewel in carrier form ($H_{\mathrm{fib}}$) | `CarrierBridge.lean` | `rule90Cylinder_Hfib_tube`, `…_sharp`, `…_column_fails`, `tubeBoundary_strictly_coarser` |
| T10 | conservation cage + design numbers | `EnergyCage.lean` | `cycleWork_eq_toggleCost_diff`, `no_free_toggle`, `toggle_ledger_lower_bound`, `sigma_ph_value`, `toggle_energy_value` |
| T11 | the two P branches + χ numerics | `PBranches.lean` | `Ppub_bounds`, `Proot_gap`, `chiCanPub_bounds`, `chiCanRoot_bounds`, `chi_branch_gap` |
| T12 | the core's three `sorry`s discharged | `Core/Primitives.lean` | `localRepair`, `Repair`, `repair_respects_gauge`, `canonical_lyapunov`, `canonical_termination`, `canonical_completeness`, `localRepair_demoCarrier`, `canonical_not_confluent` |
| T13 | hypercharges forced + ℤ₆ kernel | `Hypercharge.lean`, `CenterZ6.lean` | `hypercharge_ratios`, `cubic_anomaly_auto`, `hypercharges_unique`; `actsTrivially_iff`, `kernel_bijection`, `addOrderOf_g0` |
| T14 | Einstein-branch algebra | `EinsteinBranch.lean` | `rest_frame_relation`, `unit_timelike_determines`, `tensor_upgrade`, `null_cone_determines`, `jacobson_step` |
| T15 | dark-sector mathematics | `DarkSector.lean` | `nuOPH_*`, `deepMOND_gobs`, `btfr`, `rare_event_zero_count`, `phantom_bookkeeping`, `hasDerivAt_MA`, `thin_device_force` |
| T16 | collar-gate skeleton | `CollarGate.lean` | `uniform_gate`, `jensen_band`, `chi_forced`, `reserve_split`, `sphere_defect_count`, `twelve_unit_defects` |
| T17 | ΔS-bridge definition side | `DeltaSBridge.lean` | `count_activate`, `gen_count`, `gen_count_pos`, `avail_pos_iff`, `response_form` |
| T18 | boost invariance + parity obstruction | `Rule90Decoding.lean` | `lightTube_isInformationSet_iff`, `light_sweep`, `gapTwoTube_fails_even`, `card_lt_not_informationSet` |
| T19 | hexacode `[6,3,4]₄` MDS | `HexacodePort.lean` | `hexacode_min_weight`, `three_subset_information_set`, `two_subset_not_information_set`, `hexacode_self_dual` |
| T20 | complete parity classification | `Rule90Decoding.lean` | `gapTwoTube_isInformationSet_iff_parity`, `gap_mid_col`, `gap_right_fan`, `eq_zero_of_evolve_zero_odd` |
| T21 | D3 finite modular core | `ModularCore.lean` | `kms`, `kms_unique`, `modular_iterate`, `modular_eq_id_iff_tracial`, `state_faithful`, `qubitState_modular_ne_id` |
| T22 | hexacode weight distribution | `HexacodePort.lean` | `hexacode_weights_only`, `hexacode_weight_distribution` |
| T23 | QBFT safety + boundary finding | `ConsensusSafety.lean` | `qbft_safety`, `quorum_intersection_general`, `quorum_overlap_gap` |
| T24 | run-matrix constants + erratum | `LedgerNumerics.lean` | `Cgeom_bounds`, `dnu_min_bounds`, `lockin_stat_exact`, `battery_coupon_bounds` |
| T12+ | `EdgeRepairable` strictly weaker than `FrustrationFree` (witness) | `RepairHypotheses.lean` | `rule90_edgeRepairable`, `rule90_not_frustrationFree`, `edgeRepairable_strictly_weaker` |
| T25 | coprimality classification of two-column screens | `Rule90Stride.lean` | `gapTube_isInformationSet_iff`, `mirror_of_column_dark`, `mirror_sweep`, `traj_comap`, `mirrorPair_dark`, `gapTube_not_informationSet_of_dvd`, `tubeSet_iff_via_stride`, `gapTwoTube_parity_via_stride`, `gapTube_zero_iff`, `gapThree_eight_three` |
| T26 | the cosmological-constant step (Bianchi + conservation ⇒ one Λ) | `LambdaConstancy.lean` | `einstein_equation_with_constant`, `lambda_constant`, `step_invariant_of_divergence_free`, `ddiv_lam_eta`, `row_eta_cancel`, `lambda_not_constant_without_connectivity` |
| T27 | Route A assembled: local tube-preserving decode-repair + `H_B` + sharp `H_fib` jointly; both negatives | `RouteA.lean` | `routeA_assembled`, `routeA_observer_uniqueness`, `routeA_world_exists_unique`, `routeA_world_consistent_iff`, `pass_spec`, `quiescent_ext`, `coverage`, `no_consistent_completion_of_unrealizable`, `rule90CylinderOPH_no_frustrationFree_repair`, `canonical_repair_stalls`, `stallRecord_tube_unrealizable` |
| T28 | the real-time modular flow: existence, group law, KMS boundary condition, uniqueness | `ModularFlow.lean` | `exists_modularHamiltonian`, `flow_add`, `flow_mul`, `flow_star_real`, `flowU_continuous`, `state_flow`, `flow_I_eq_modular`, `kms_boundary`, `kms_conjugation_eq`, `posDef_exp_neg`, `hamiltonian_kms_unique` |
| T29 | the channel bridge: one family, both counters, composite Tier-B1 law | `ChannelBridge.lean` | `same_family`, `count_eq`, `lambdaCollar_eq`, `bridge_gate`, `channel_composite`, `demoChannel_composite_pos` |
| T13 add. | the ℤ₆ kernel as a group isomorphism | `CenterZ6.lean` | `kernelSubgroup`, `kernelAddEquiv`, `phase_add`, `phase_zero`, `phase_neg` |
| T10/T24 add. | the theorem-grade anchors beside the G10-convention | `EnergyCage.lean` | `cycleWork_self`, `bench_cycle_work_value`, `mass_energy_value`, `anchor_ordering` |
| P4 | unique scalar response under SEE | `ScalarResponse.lean` | `unique_scalar_linear_response`, `no_second_susceptibility` |
| T30 | local-decodability phase boundary (v8) | `Rule90Propagation.lean` | `Inferable`, `inferable_sound`, `spread_screen_inferable_iff`, `gapTube_inferable_iff`, `adjacent_closure_complete`, `tube_information_set_via_propagation`, `violet_exhibit` |
| T31 | the readout trichotomy (v8) | `Rule90Readout.lean` (+ `RouteA.lean` corollaries) | `tubeData_surjective_iff`, `tubeData_bijective_iff`, `readout_trichotomy`, `fanColumns_card`, `exists_unrealizable_tube_iff`, `all_tubes_realizable`, `no_stall_at_threshold` |
| T32 | universal (any-scheduler) termination of Route-A decode (v8) | `RouteA.lean` `[formal-v8]` | `misMeasure_decreases`, `decodeStep_wellFounded`, `no_infinite_decode_run`, `exists_normalForm_extension`, `routeA_universal_settlement` |
| T33 | Skolem–Noether + KMS genericity (v8) | `ModularFlow.lean` `[formal-v8]` | `algEquiv_matrix_inner`, `kms_algEquiv_structure` |
| T34-lite | sloped screens: definition, failure half, threshold instances (v8) | `Rule90Slope.lean` | `slopeTube`, `slopeTube_zero_eq_tubeSet`, `slopeTube_not_informationSet`, `slope_half_8_3`, `slope_third_8_3`, `slope_twoThirds_8_3`, `slope_half_7_3`, `slope_half_10_4` |
| T35 | the twelve-port surface (v8) | `SimplicialSurface.lean` | `TriangulatedSphere`, `three_faces_eq_two_edges`, `degree_sum_eq_two_edges`, `edges_eq_biUnion`, `defect_count`, `twelve_ports`, `TriangulatedSphere.ofFn`, `icosahedron`, `icosahedron_ports` |
| **T36** | **the Lipschitz worldline theorem — the slope conjecture, closed (v9)** | `Rule90Lipschitz.lean` | `pathScreen`, `pathScreen_fan`, `pathScreen_closure_complete`, `pathScreen_isInformationSet_iff`, `slopeTube_eq_pathScreen`, **`slopeTube_isInformationSet_iff`**, `isInformationSet_of_seedRow_inferable`, `pairScreen_class_6_2`, `pairScreen_slope2_8_3`, `pairScreen_teleport_8_3`, `pairScreen_slope2_fails_10_4`, `pairScreen_late_jump_fails_10_4`, `pairScreen_early_jump_10_4` |
| **T37** | **the gap-2 crawl classified (v9)** | `Rule90Crawl.lean` | `gapTwo_middle_inferable`, `gapTwo_left_pair`, `gapTwo_right_pair`, `gapTwo_row1`, `gapTwo_crawl`, `gapTwo_row0`, **`gapTwoTube_closure_complete_odd`**, `gapTwo_information_set_via_propagation`, **`gapTwoTube_closure_incomplete_even`**, **`gapTwo_closure_complete_iff_odd`** |
| **T38** | **the parity splitting — R1 formalized, C1 containment unconditional (v10)** | `Rule90Parity.lean` | `traj_congr_on_class`, `parityProj`, `parityProj_add`, **`traj_parityProj`**, `VanishesOn.parityProj`, `SingleParity`, **`isInformationSet_iff_single_parity_ghost`**, **`not_isInformationSet_iff_single_parity_shadow`**, `rule60`, **`traj_eq_rule60_iterate`** (the bridge), `halfEmbed`, **`sectorTrace_succ`**, `sectorTrace_eq_iterate` |
| **T39** | **two-power universality — every worldline decodes on `n = 2^k` (v10; closes oph_sim conjecture C3)** | `Rule90TwoPower.lean` | `rule60_iterate_two_pow_apply` (doubling), `rule60_iterate_self_eq_zero` (nilpotency), `rule60_apply_eq_of_eq_zero` (the all-ones funnel), **`pairScreen_isInformationSet_two_pow`**, **`pairScreen_isInformationSet_iff_two_pow`**, **`pathScreen_isInformationSet_iff_two_pow`**, `pairScreen_teleport_4_1` |
| **T40/T41** | **the lone diagonal observer (v10): counting-tight on odd rings, sector-blind on even; opposite-parity pairs sharp at any offset** | `Rule90Diagonal.lean` | `diagScreen`, `rule60_prefix_kill`, `rule60_iterate_double_reindex`, **`diagScreen_isInformationSet_odd`**, **`diagScreen_isInformationSet_iff_odd`**, **`diagScreen_not_isInformationSet_even`**, **`diagScreen_pair_isInformationSet_even`**, **`diagScreen_pair_isInformationSet_iff_even`**, `diagScreen_pair_same_parity_not_isInformationSet`, `diag_five_four`, `diagPair_six_two` |

**Provenance notes.** `Core/*` are attributed copies of the OPH team's Lean core (`observer-patch-holography/LEAN/`), with the three documented `sorry`s discharged in this tree (all modifications `[formal-v4]`-tagged; the team's own repo is unchanged). `HexacodePort.lean` is an attributed port from `dula/prime-inertia-engine` (the one reusable artifact of that audit), completed here. `ConsensusSafety.lean` formalizes the corpus appendix B with attribution. Everything else is native to this tree. Toolchain: `leanprover/lean4:v4.29.1`, Mathlib pinned to the same revision as the OPH core, so upstreaming is a file move.

# Appendix C. Related work and references (added in v6.1, after the audit's F7)

The chain formalizes several results whose infinite-lattice or classical antecedents are standard; the formalizations have independent value, but the *mathematical* novelty claims are confined to the finite sharp thresholds and classifications. The map:

- **Sideways expansiveness of permutive CA** (the mechanism behind T9's sweep): G. A. Hedlund, *Endomorphisms and automorphisms of the shift dynamical system* (1969) — permutive local rules; M. Boyle & D. Lind, *Expansive subdynamics* (1997) — vertical expansiveness with finite-width windows; P. Kůrka, *Topological and symbolic dynamics* (2003). **New here:** the finite-cylinder sharp threshold `n ≤ 2(t+1)` (T9), boost/gap variants (T18), and the complete parity and coprimality classifications (T20, T25) with the mirror lemma and quotient lift.
- **Holography as error correction** (Layer-1 hook): A. Almheiri, X. Dong & D. Harlow, *Bulk locality and quantum error correction in AdS/CFT* (2015).
- **MDS codes and the hexacode** (T19/T22): F. J. MacWilliams & N. J. A. Sloane, *The Theory of Error-Correcting Codes* (1977); J. H. Conway & N. J. A. Sloane, *Sphere Packings, Lattices and Groups* (the hexacode chapter). The `[6,3,4]₄` parameters, self-duality, and weight enumerator are classical; the Lean port is the contribution.
- **Hypercharge quantization from anomalies + Yukawa closure** (T13a): C. Q. Geng & R. E. Marshak (1989); J. A. Minahan, P. Ramond & R. C. Warner (1990). **Global form of the SM gauge group** (the ℤ₆ kernel, and the open question of which quotient nature realizes — consumed by Section 19 as a named hypothesis): D. Tong, *Line operators in the Standard Model* (2017).
- **Finite-dimensional modular theory / KMS** (T21): O. Bratteli & D. W. Robinson, *Operator Algebras and Quantum Statistical Mechanics*; the thermal-time reading is A. Connes & C. Rovelli, *Von Neumann algebra automorphisms and time-thermodynamics relation in generally covariant quantum theories* (1994).
- **Einstein equation as an equation of state** (T14/T26's shape): T. Jacobson, *Thermodynamics of spacetime: the Einstein equation of state* (1995) — including the Bianchi-plus-conservation closing step that T26 formalizes discretely.
- **Quorum intersection / BFT safety** (T23): M. Castro & B. Liskov, *Practical Byzantine Fault Tolerance* (1999); D. Malkhi & M. Reiter, *Byzantine quorum systems* (1998).
- **MOND phenomenology and the radial-acceleration relation** (Section 18's fitting function): M. Milgrom (1983); B. Famaey & S. McGaugh, *MOND: observational phenomenology and relativistic extensions* (2012); S. McGaugh, F. Lelli & J. Schombert, *Radial acceleration relation in rotationally supported galaxies* (2016) — the interpolation function whose mechanism the dark-sector story proposes.

# Appendix B. Notation

| Symbol | Meaning |
|---|---|
| $V, E$ | patches (observers) and interface edges of the carrier |
| $S_i$, $I_e$, $\pi_{i,e}$ | local state spaces, interface alphabets, interface projections |
| $\Sigma$, $x$ | global record space $\prod_i S_i$ and a record |
| $\Phi(x)$ | weighted mismatch $\sum_e w_e\, d_e(\pi_{\mathrm{src}}, \pi_{\mathrm{tgt}})$; consistency = $\Phi = 0$ |
| $\mathrm{obs}$, $\sim_{\mathrm{g}}$ | observable overlap data; gauge equivalence (its kernel) |
| H1–H3, H4 | local repair laws (locality, trigger, satisfiability); global commutation |
| $H_B$, $H_{\mathrm{fib}}$ | boundary preservation; gauge-singleton consistent fibers (Route A) |
| $H_\downarrow$, $H_\Diamond$, $H_{\mathrm{comp}}$ | strict descent, local confluence, quiescence-completeness (Route B) |
| $\mathrm{Rep}_\lambda$, $\mathrm{World}$ | global quotient repair; $\mathrm{World}(s) = \mathrm{Rep}_\lambda(q(s))$ |
| $\mathrm{ev}$, $\mathrm{traj}(z,i)$ | Rule-90 step $x(j{-}1)+x(j{+}1)$ over $\mathbb{F}_2$; trajectory of seed $z$ |
| information set | a cell set whose values determine the whole spacetime block |
| $\Delta_\rho$, KMS | modular map $\rho\, \cdot\, \rho^{-1}$ of the state $\omega = \mathrm{tr}(\rho\,\cdot)$; the identity $\omega(A\,\Delta_\rho(B)) = \omega(BA)$ |
| SEE, MAR, L1–L7 | named physical hypotheses (Section 26) |
| G9, G10 | open gaps: the ΔS calibration; the experimental energy ledger |
| $P$, $\chi_{\mathrm{can}}$ | the collar constant (two branches, Section 22); $e^{-P/24} \approx 0.9343006$ |
| $C_{\mathrm{geom}}$, $\sigma_{\mathrm{ph}}$, $\Phi_N$ | $g^2/4\pi G$; phantom surface density per $\Delta\nu$; Earth-surface potential |

---

*Written 2026-07-07 as an expository companion to proof-chain v5, revised the same day alongside v6/v6.1/v7. The Lean sources in [`proof_chain/formal/`](proof_chain/formal/) are the authority for every claim labelled **Theorem**; this document adds explanation, not content. Errors of exposition are this document's alone; the theorems don't have any.*




