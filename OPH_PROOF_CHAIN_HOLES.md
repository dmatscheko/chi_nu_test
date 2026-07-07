# The Hypotheses Have Hypotheses

## Holes in the mathematics and physics of the OPH proof chain — an adversarial audit companion

| | |
|---|---|
| Companion to | [`OPH_PROOF_CHAIN_PAPER.md`](OPH_PROOF_CHAIN_PAPER.md) and [`proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md`](proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md) |
| First pass (F1–F19) | audited proof-chain **v5** at commit `b8a31c7` (2026-07-07); the Lean tree verified on an isolated copy; findings filed against the interpretation layer |
| Second pass (dispositions + F20–F29) | audited proof-chain **v6.1** at commit `2ce895c` (2026-07-07, same day, later): the chain *adopted* this audit (disposition table in the chain document's §11, T26, the G10-convention naming, the F18 erratum pass) — this pass verifies **whether each claimed disposition is real**, re-verifies the formal layer including the three new modules, and files ten new findings |
| Anchor convention | F1–F19 blocks quote **v5** line numbers (`git show b8a31c7:<path>`); the *Disposition audit* blocks appended to them, and all of Part VI, quote **v6.1** line numbers (`git show 2ce895c:<path>`). Verbatim quotes remain the durable anchors |
| Method (second pass) | frozen APFS clone of the v6.1 tree; full build replay; an environment-level `collectAxioms` sweep over **both** OPH namespaces (835 theorem/def declarations — the first pass's 838 differs only by internal-declaration filtering); the three new Lean modules read line-by-line; every current Statement block re-checked against Lean by two independent readers; every printed Part-IV number recomputed at 60-digit precision; the chain's two new computational-evidence claims independently reproduced; every claimed fix grepped for at its anchor *and* for surviving recurrences |
| Headline (second pass) | **The two new theorems are real; the fix was anchor-deep.** T26 genuinely closes F8, T25 is statement-faithful, and every number checks. But most wording fixes were applied at the exact lines this audit quoted and nowhere else — the same claims survive at 40+ other sites, five disposition rows overstate what was done, one banner was *re-written still false*, and the second pass found two new misstatement-grade holes the first pass missed (F20, F21) |
| v7 response (added post-audit; the audit text is frozen) | The maintainers' third pass (proof-chain **v7**, same day) answers both audit passes — this time by theorem where the audit asked for theorems and by grep where it asked for sweeps: F2 → **T27** (`RouteA.lean`: Route A assembled, with this audit's stall witness, its impossibility claim for every cylinder, and the emptiness of the stall fiber all machine-checked); F9 → **T28** (`ModularFlow.lean`: the real-time flow, the textbook KMS boundary condition, Hamiltonian-implemented uniqueness); F11 → **T29** (`ChannelBridge.lean` — the repair option (a) of F11, verbatim); F10(c) → `kernelAddEquiv`; F15's anchors → interval arithmetic incl. the strict corridor (`anchor_ordering`); F20 → the counterexample committed in-tree (`hfib_strictly_weaker_than_informationSet`); F25 → `no_schedule_beats_the_ledger`; F26 → subsumed by T27's negatives; F22 → the checker + outputs committed (`proof_chain/formal/evidence/`); F23 → wording + `lambda_constant_symm`; F21's residue ledger → swept grep-first, with the five overstated rows rewritten; F24/F27/F28/F29 → wording/bookkeeping applied. Finding-by-finding: chain §11 (both tables). Environment sweep after v7: 1480 declarations, 0 sorry, standard axioms |
| v8 response (added post-audit; the audit text is frozen) | The maintainers' fifth pass (proof-chain **v8**, same day) begins with the verification discipline this audit's second pass demanded — the v7 modules re-read end-to-end against their claims, a fresh build, and a **two-namespace** environment sweep (the `OPH.*` trap of the second pass's Method row, heeded) — then closes the leftovers the v7 theorems created: T27's arbitrary-schedule termination → **T32** (`decodeStep_wellFounded` — the stratified-measure argument the chain called routine, carried out; no scheduler can run forever, and with T27a every schedule lands on the tube-pinned record), T28's Skolem–Noether extension → **T33** (`algEquiv_matrix_inner` — every algebra automorphism of the matrix algebra is inner, so Hamiltonian-implemented uniqueness was never a restriction; `kms_algEquiv_structure`), and the F24 residue → **T35** (`TriangulatedSphere` — the three "assumed equations" of `sphere_defect_count` are now theorems of an actual surface; kernel-checked icosahedron). Two additional theorems came from the simulation companion's findings (`oph_sim/FINDINGS.md` items 1–3 and 10): **T30** (the local-decodability phase boundary — determination ≠ local derivability, with the `n=8, g=3, t=3` violet configuration machine-checked) and **T31** (the readout trichotomy — unrealizable tube readings exist **iff** `n < 2(t+1)`, sharpening the stall regime of T27.4; every reading realizable above the threshold; bijective exactly at it). F6 (intermediate slopes) is pinned down without being closed: `slopeTube` is now a formal in-tree definition (floor convention = the committed evidence artifacts'), the failure half is a theorem at every slope, and slopes 1/2, 1/3, 2/3 have kernel-checked threshold instances — the general positive half is the chain's named open conjecture. Environment sweep after v8: 33 modules, 1199 non-internal theorem/def declarations in both namespaces, 0 sorry, standard axioms only (count filter now documented — `formal/RESULTS.md` §33 — so sweep-count bookkeeping is reproducible). Campaign log: chain §12 |
| What this document is **not** | It is not a refutation of the program, and it does not dispute the machine-checked layer (which both passes *confirm*, independently). It is the hole inventory the chain's own method demands: the same discipline the chain applied to the OPH corpus, applied to the chain — twice |

**How to read this document.** Section 1 records what the audits *verified* — the reader should know what survived before reading what did not (1.0 = first pass, 1.1 = second pass). Parts I–IV walk the first-pass holes in the order of the paper's own parts; **each finding now ends with a boxed *Disposition audit* verdict** stating whether the v6.1 fix is real, partial, or misreported. Part VI holds the second-pass findings (F20–F29). Each substantive hole gets four blocks:

- **The hole** — what is wrong or missing, stated precisely;
- **Where it bites** — the exact sentences and anchors (file:line) that carry the problem;
- **What would close it** — the theorem, hypothesis-naming, or rewording that would repair it;
- **In plain language** — the same finding for a reader with no mathematical background.

Findings are labelled **F1–F29** and graded:

| Grade | Meaning |
|---|---|
| ■ **misstatement** | a sentence in the chain documents is false, or asserts something the cited theorem does not establish |
| ▲ **overreach** | the formal result is correct, but the claim built on it adds unproven content without naming it |
| ● **limitation** | a real boundary of the result that the documents should carry visibly |

Disposition verdicts use: **✅ closed** · **◑ closed with residue** · **✳ acknowledged-open (a legitimate closure for ●-grade findings)** · **✗ misapplied**.

If you read only three first-pass findings, read **F15** (the megajoule ledger is a convention, not a theorem), **F2** (Route A is never actually assembled), and **F8** (the machine-checked "Einstein equation" stops one mathematical step short of the Einstein equation). If you read only three second-pass items, read **F21** (the disposition fixed the quoted lines, not the claims — and misreports itself), **F20** (a machine-refutably false "exactly" at the sentence that frames all of Part II), and the **F8 disposition block** (the one finding closed by an actual theorem — what closure is supposed to look like).

---

## Contents

- **1.** What this audit verified (the fairness section) · **1.1** Second-pass verification
- **Part I — The consensus core:** 2. The rung-1 misstatement (F1) · 3. Route A is never assembled (F2) · 4. "Canonical" repair and the hidden choice function (F3) · 5. The declared order is consensus at the meta-level (F4) · 6. How much fence is the fence? (F5)
- **Part II — Holography:** 7. "Boost invariance" is two data points (F6) · 8. Novelty, prior art, and the missing bibliography (F7)
- **Part III — The conditional tower:** 9. The pointwise λ is not the cosmological constant (F8) · 10. The KMS "clock" ticks in imaginary time only (F9) · 11. The 24 = 4·6 = 2·12 bookkeeping proves arithmetic, not structure (F10) · 12. "The same counter" is a naming, not a theorem (F11) · 13. SEE: a hypothesis the width of its conclusion (F12) · 14. What "forced" means in the hypercharge theorem (F13) · 15. The dark sector's law is the literature's fitting function (F14)
- **Part IV — The cage, the numbers, the experiment:** 16. The 3.5 MJ toggle ledger rests on a zero-point convention (F15) · 17. What the experiment can actually adjudicate (F16) · 18. The two P's: what remains under-stated (F17)
- **Part V — Cross-cutting:** 19. The exposition adds content — an erratum-grade list (F18) · 20. "Everything open is physics" is not quite true (F19)
- **Part VI — The second pass (v6.1):** 21. Scorecard · 22. A false "exactly" at Part II's front door (F20) · 23. The fix was anchor-deep, and the disposition table misreports it (F21) · 24. Computational evidence with no artifact (F22) · 25. What T26's rendering imports (F23) · 26. The Gauss–Bonnet clause has no surface (F24) · 27. "No schedule beats the toggle ledger" is proven for one schedule (F25) · 28. The disposition embeds new unformalized mathematics (F26) · 29. Three slips in the new v6 prose (F27) · 30. Version bookkeeping: the ledgers' headers contradict their bodies (F28) · 31. Statement-precision nanos (F29)
- **32.** Verdict — first pass · second pass (with plain-language close)
- **Appendix A.** Finding → anchor map (first pass) · **Appendix B.** Verification transcripts (B1 first pass · B2 second pass)

---

# 1. What this audit verified

Symmetry demands the confirmations be listed with the same care as the holes.

**1.0 First pass (v5, commit `b8a31c7`).**

1. **The build claim is true.** The committed v5 tree compiles from scratch replay with zero errors and zero warnings (8272 jobs). No `sorry`, `admit`, `axiom`, `native_decide`, `unsafe`, `partial def`, or `@[implemented_by]` appears outside docstrings anywhere in the 23 modules.
2. **The axiom claim is true — and stronger than advertised.** The tree self-audits 172 declarations via `#print axioms`. This audit swept the *entire environment*: all **838** theorem/def declarations in the OPH namespaces depend on at most `propext`, `Classical.choice`, `Quot.sound`. Nothing is smuggled anywhere, including in helper lemmas the self-audit does not list.
3. **The load-bearing theorems say what the paper says they say.** For every theorem checked in detail — T0–T12 (consensus core), T9/T18/T20 (the screen family and its full parity classification, including the genuinely elegant odd-cylinder algebraic descent), T13 (hypercharges/ℤ₆), T15's calculus, T16's inequalities, T21's matrix algebra, T22–T24 — the Lean statement matches the paper's Statement block. The paper's Statement/Proof blocks are faithful translations. Where this document says "the theorem is true but…", the "true" part was verified, not assumed.
4. **The two-P finding (T11) is solid** and is exactly the kind of forensic result formalization is for. The published `P` is machine-checked to be the CODATA-calibrated definition; the branch gap is real and priced.
5. **The QBFT boundary finding (T23) is correct**: the appendix's "A6 is guaranteed by A3" does fail at `n = 3f+2` with quorums held at `2f+1`.
6. **The T24 erratum is arithmetically genuine**: the old printed battery-coupon ceiling was ~3 % below the interval-checked value. (What that ceiling *means* is F15's problem, not an arithmetic one.)
7. **The self-audit documents are unusually honest.** `RESULTS.md`'s "Does not establish" rows, the named-hypothesis discipline, and the Core files' own scope warnings are real and mostly accurate. Several findings below were locatable *because* a Lean docstring states a caveat that the higher-level documents then drop.

## 1.1 Second-pass verification (v6.1, commit `2ce895c`)

1. **The v6.1 build claim is true.** Frozen-copy replay: **8275 jobs, 0 errors, 0 warnings**; the emitted `#print axioms` lines report at most the standard trio.
2. **The axiom claim is true at v6.1, over both namespaces.** An environment-level `collectAxioms` sweep over all **835** theorem/def declarations in `OPHProofChain.*` (663) **and** `OPH.*` (172 — `Core/Primitives`, `Core/Rule90`, `RepairHypotheses`): **0** non-standard axioms, **0** `sorryAx`, **0** `ofReduceBool`. The headline count is exact: **205** `#print axioms` declarations across **26** modules (counted).
3. **T25 is statement-faithful.** `gapTube_isInformationSet_iff` (`Rule90Stride.lean:532–533`) is verbatim the advertised iff — every `n ≥ 1` (`[NeZero n]`, the only side condition), every natural stride `g` including 0 and wraparound, every base column, every horizon; `IsInformationSet` is genuine readout-injectivity on seeds. The mirror lemma, quotient lift, failure-at-every-horizon theorem, the three consistency corollaries (the first two **proposition-identical** to the untouched T9/T20 originals — "two independent proofs now agree" is fair; the routes are genuinely disjoint), and the three kernel-`decide` boundary instances all exist under the advertised names and say what the docs say.
4. **T26 is genuine and closes F8.** `einstein_equation_with_constant` (`LambdaConstancy.lean:187–204`) **composes with `jacobson_step` in-tree** (line 199–200 — not a disconnected restatement); the Leibniz step, diagonal cancellation, and reachability induction are correct; `lambda_not_constant_without_connectivity` makes the connectivity clause load-bearing; the module's honest-scope block names Bianchi/conservation as the inputs. What its *rendering* imports is F23 — a pricing note, not a reopening.
5. **The "axiom-free" boast is true.** `symmetricPair_normalForm_iff` genuinely depends on **no axioms** (verified independently twice; mechanically: Batteries' `by_contra` takes the `Decidable` path on a `Bool` goal).
6. **Every printed number in Part IV and §22 recomputes.** C_geom to the half-ulp; Δν_min, design force/gf/SNR, the exact `10⁻⁶/30` lock-in floor; `Φ_N ∈ (6.24, 6.26)×10⁷`, `ΔM·Φ_N ∈ (3.49, 3.52)` MJ, `ΔM·c² ≈ 5.03×10¹⁵ J`, `ΔM·g ≈ 0.55 J/m`; the battery ceiling `1.0253×10⁻¹¹` (old print genuinely unsafe-direction); the P-branch gap `3.886×10⁻⁶` **consistent** with the "~300 ppm α miss" under `dP = √π·Δ(α⁻¹)/(α⁻¹)²`; `e^{−P/24} = 0.93430063…`; the "~2×10⁶ σ" composition figure (`0.0412/2.1×10⁻⁸ ≈ 1.96×10⁶`).
7. **Appendix C's attributions are all correct** for what they are cited for — including that Jacobson 1995 does contain the Bianchi-plus-conservation closing move T26 discretizes, and that the MLS16 fitting function is curve-for-curve `ν_OPH`.
8. **The chain's two new computational-evidence claims are true** — verified by independent reproduction here, because the repo contains no artifact for them (that absence is F22): the stride classification holds for all `n ≤ 28` (minimal horizon exactly `⌈n/2⌉−1` at every coprime stride; no decode to `t = 80` at any non-coprime stride), and width-2 screens at slopes 1/2, 1/3, 2/3, 1/4, 3/4 decode at exactly the sharp threshold for all `n ≤ 20` under the floor convention.
9. **F15's and F18's fixes are real at every site the disposition names.** The G10-convention naming is correctly carried in CORE §5, paper §23/§26, DOCUMENT A §1.9, DOCUMENT B, DOCUMENT C Part 7, and the `EnergyCage.lean` module header; all nine F18 erratum rows are applied at their cited anchors.

The holes below are therefore, still, not about the proofs. The first-pass holes were about the load path from theorem to claim; the second-pass holes are mostly about the load path from *finding* to *fix*.

---

# Part I — The consensus core

# 2. The rung-1 misstatement: no operator obeys the three laws on every carrier (F1 ■)

## The hole

The paper's Section 1.3 asserts:

> "This holds for *every* carrier once repair obeys three local laws, and (T12) a canonical repair operator obeying them *exists* on every carrier — it is constructed, not assumed."

This is false, and it is refuted by the tree's own theorems. The canonical operator of T12 satisfies **H1** and **H3** unconditionally, but **H2** ("fires iff a broken incident edge exists") only on frustration-free carriers — that is exactly `canonical_H2` (`Core/Primitives.lean:841`), which *requires* the hypothesis `FrustrationFree C`. And on the Rule-90 carrier **no operator whatsoever** satisfies H1∧H2∧H3: `rule90_no_frustrationFree_repair` (`Core/Rule90.lean:212`). On a frustrated carrier the canonical operator deliberately fires *less often* than H2 demands (that is what keeps it total), and consequently its completeness needs the extra hypothesis `EdgeRepairable` — which the paper's own Section 6 states correctly, two sections after Section 1.3 states it wrongly.

The plain-language summary (Section 1.5, item 1) inherits the error in stronger form: "**The correcting always finishes.** No infinite bickering: eventually every shared page agrees." On a frustrated carrier the correcting finishes *without* every shared page agreeing — repair stalls on inconsistent records. The tree proves this possibility is real, not hypothetical (F2 exhibits it on the holographic carrier itself).

## Where it bites

- `OPH_PROOF_CHAIN_PAPER.md:76` (rung 1) — the false existence claim;
- `OPH_PROOF_CHAIN_PAPER.md:117` (plain language) — "eventually every shared page agrees", unconditional;
- contradicted by `Core/Primitives.lean:747–753` (the file's own "H2 fine print"), `canonical_H2` at `:841`, and `Core/Rule90.lean:212`.

## What would close it

Reword rung 1 to what T12 proves: *termination and Lyapunov descent hold unconditionally for the canonical operator on every carrier; completeness (terminal = consistent) holds under `EdgeRepairable`; on some carriers (Rule-90, provably) no operator can satisfy all three local laws, and repair can terminate in disagreement.* One sentence; the paper's own Section 6 already contains it.

## In plain language

The overview chapter promises that the correction procedure always ends with every disagreement fixed, on every possible office. The technical chapters — and the machine — say something more interesting: the procedure always *ends*, but on some offices there are messes no single clerk is allowed to fix, and there the office settles down still disagreeing. The fine print knows this; the headline forgot it. This matters because the offices where it happens include the star exhibit of the whole paper (next finding).

> **Disposition audit (second pass): ◑ closed with one residue.** The two cited anchors are genuinely fixed — rung 1 (paper:77) now says exactly what T12 proves (termination unconditional; completeness "under the named hypothesis `EdgeRepairable`"; "repair can terminate **in disagreement**"), and §1.5 item 1 (paper:118) now carries "the correcting can settle down with some disagreements frozen in." **Residue:** the verdict re-lumps what the fix separated — paper:1071 still opens "Termination and completeness for a canonical repair operator that *exists on every carrier*", the pre-fix conflation in one sentence. Also note: the fixed rung 1 asserts the impossibility for the toy "— and its cylinder big brother" as fact; the cylinder half is unformalized written mathematics (→ F26).

# 3. Route A is never assembled: no carrier carries dynamics, boundary-preservation, and a redundancy-boundary jointly (F2 ▲)

## The hole

Route A's advertised composition is: repair dynamics (H1–H3) **+** boundary preservation (HB) **+** gauge-singleton fibers (Hfib) **⇒** all observers settle to one world pinned by the boundary (T4b). The chain's celebrated progress on Route A is the jewel (T9/T9′): Hfib discharged on the Rule-90 cylinder by a *proper-subset*, redundancy-driven boundary. But:

1. **On the jewel carrier, the dynamics leg is impossible or stalls.** The width-3 version is proven in-tree: no H1∧H2∧H3 repair exists on the Rule-90 carrier (`Core/Rule90.lean:212`), and its docstring states plainly that the joint HB∧Hfib witness "never can" be supplied there via local repair. The same obstruction holds on the `rule90Cylinder n t` carrier of `CarrierBridge.lean`, where T9′ lives — not proven in-tree, but checkable by hand: `evolve` has nontrivial kernel (the constant row dies), so its image is a proper subspace, so bottom rows outside the image exist, and the same three-line argument kills H1∧H2∧H3. Worse, the canonical operator of T12 genuinely **stalls on inconsistent records** there. Concrete witness on `rule90Cylinder 3 2`: start from rows `(0, δ₀, δ₁)`. Patch 0 cannot fix edge 0 (δ₀ has odd weight; every `evolve`-image has even weight). Patch 1 cannot fix both its edges (it would need `evolve² 0 = δ₁`). Patch 2 fires once (setting row 2 := `evolve δ₀`), and the result `(0, δ₀, (0,1,1))` is a **normal form with edge 0 permanently broken**. `Repair` terminates in disagreement on the very carrier whose screen theorem the paper crowns.
2. **The only joint witness in the tree is redundancy-free.** The demo carrier does exhibit dynamics + HB + Hfib together (`demoCarrier_dir_observer_unique_under_seed`) — but with a boundary that reads one cell of a two-cell record: half the record, no constraint redundancy, exactly the "feed-forward-grade" determination the review's R1 already discounted. The erasure-strength Hfib (Part II) and the dynamics package (T4b/T6/T12) are **never instantiated on the same carrier**. The `LayeredCarrier` gives HB∧Hfib jointly but with the boundary = the complete input layer (its own honest-scope says so); the cylinder gives erasure-strength Hfib but provably cannot carry the local-repair dynamics.

So the chain's strongest sentence about Route A — the paper's rung 3: "Consensus + constraint redundancy really produces perfect holographic screens — in theorems, not metaphors" — is true only if "consensus" is read as *the static consistency predicate*. As a statement about consensus **dynamics** it has no witness anywhere in the tree, and on the exhibited carrier its dynamics half is false. The source Lean core flagged the joint witness as "open modeling task" (`Core/Primitives.lean:1186–1190`); v3–v5 closed the Hfib half brilliantly and quietly stopped repeating that the joint task is still open.

*(v6 note, added at publication: the concurrent session's new `RepairHypotheses.lean` proves `EdgeRepairable` for the **one-edge width-3 toy** — there the bottom patch can always copy the CA image, so the canonical repair does reach consistency. This is correct, and it sharpens the present finding rather than repairing it: on the **multi-edge cylinder** — the carrier T9′ actually lives on — interior patches must satisfy two interfaces at once, `EdgeRepairable` fails, and the stall witness above stands. The v6 module celebrates completeness on the small toy while the flagship carrier still lacks it, and still no document says so.)*

## Where it bites

- `OPH_PROOF_CHAIN_PAPER.md:82` (rung 3: "Consensus + constraint redundancy really produces perfect holographic screens"), `:119` (plain language: "all clerks provably converge to the same story"), `:459` ("in carrier language it discharges Route A's H_fib … which was the named open jewel" — true, but the reader is not told the *other* premises of Route A cannot hold there);
- `proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md:126–143` (T9 blurb; same elision);
- the still-open joint task: `Core/Primitives.lean:1186–1190` (the source file's own scope note, which no v5 document repeats);
- the impossibility on the toy: `Core/Rule90.lean:59–72, 212`.

## What would close it

Either (a) a theorem: exhibit a carrier + repair (transactional repair in the T6 sense is fine — e.g. a *local, bounded-window* transaction set on the cylinder) satisfying HB for the tube boundary and reaching consistent normal forms, jointly with the sharp Hfib — the honest completion of issue #304; or (b) a sentence in both chain documents: *"the jewel discharges the static hypothesis Hfib only; on this carrier no H1–H3 repair exists (and the canonical operator stalls on inconsistent records), so the full Route-A composition — dynamics included — currently has no redundancy-boundary instance."* Note that a *global* decode-and-rewrite transaction would satisfy the letter of T6 but not its spirit (locality), and should be called what it is if used.

## In plain language

The paper's two showcase results are: (1) the correction dynamics works, and (2) a narrow window pins down the whole office's story. The suggestion throughout is that together they mean: run the correction, and the window forces everyone to the same story. But the two results live in *different* toy offices, and in the window's office the correction provably jams — some broken pages nobody is allowed to fix, so the office can settle while still inconsistent, and then the window theorem (which only speaks about *fully consistent* offices) says nothing at all. Nothing in the machine-checked tree runs both showpieces in the same room. The old to-do note that said "make them work together" is still open; it just stopped being quoted.

> **Disposition audit (second pass): ✳ acknowledged-open, correctly — option (b) taken.** The demanded sentence exists at the jewel itself (paper:462: "H_fib is the *static* half of Route A. On this same carrier no repair operator can satisfy the three local laws … and T12's canonical operator can terminate on inconsistent records — so the composition … is not yet witnessed on any redundancy-boundary carrier"), rung 3 carries the asterisk (paper:83), and the joint model is on both open lists (paper:1063; chain §7 item 7) with the honest route named (transactional repair, local sweep order). **Two residues:** the chain document's own §1 T9 block (CORE:121–146) still presents the jewel with no caveat — the disposition row's "the audit's stall witness is quoted where the jewel is presented" is true only of the paper, and "quoted" overstates even there (the stall *possibility* is stated; the concrete `(0, δ₀, δ₁)` witness appears nowhere); and the supporting cylinder-impossibility claims are now asserted as unformalized fact (→ F26).

# 4. The "canonical" operator hides a choice function behind the declared order (F3 ▲)

## The hole

The paper (Section 6) prices T12's operator as needing "no choices beyond a declared patch order (the same declared structure Route B was always going to charge for)". This undercounts. The operator's firing *state* is `Classical.choose` on the local-fix predicate (`Core/Primitives.lean:321–322`): a global selection, for every patch and every predicate of states, of one satisfying witness — on infinite state spaces this is the axiom of choice, and physically it is a **fix-selection rule**, a second piece of declared structure beyond the roster. Gauge-respect survives only because Lean's `choose` is a function of the *predicate* and gauge-equivalent records have literally equal predicates (`choose_eq_of_pred_eq`, `:274`) — an intensional artifact with no operational counterpart: a physical implementation must pick concrete fixes, different implementations pick differently, and each pick is a schedule-like piece of conventional structure of exactly the kind T3 teaches us to charge for. "Canonical" is a misnomer; "arbitrary-but-fixed" is the honest term, and the honest price list for Route B on the original carrier is: a declared order **and** a declared fix-selector.

## Where it bites

- `OPH_PROOF_CHAIN_PAPER.md:270` ("needs no choices beyond a declared patch order");
- `Core/Primitives.lean:321–322` (the `choose`), `:274` (why gauge-respect survives).

## What would close it

One sentence in Section 6 and in T12's row: the operator consumes a declared patch order **and** a declared local-fix selection (AC in general; a definable selector on concrete carriers); both are Route-B-type declared structure. Optionally: on carriers with canonically orderable state spaces, replace `choose` with `min` and the caveat disappears.

## In plain language

The repair recipe says each clerk, when she acts, rewrites her page "to a fixed repair". Fixed by whom? The mathematics quietly assumes a universal chooser that picks one repair out of every possible set of repairs, everywhere, in advance. That's a second rulebook on top of the published turn order — harmless, but the paper's own accounting standard ("every piece of declared structure gets named and billed") should bill it.

> **Disposition audit (second pass): ✅ closed.** Paper §6 (paper:271) now bills **two** lines of declared structure — "the declared patch order, **and a declared local-fix selector**" — names `Classical.choose`, explains the intensional survival of gauge-respect, and demotes "canonical" to "*arbitrary-but-fixed-and-billed*". The chain document's T12 block names the `Classical.choose` state openly (CORE:154).

# 5. Route B's declared order is consensus at the meta-level (F4 ●)

## The hole

Both machine-checked objectivity routes buy uniqueness with a **globally shared** object: Route B a total order on transactions/patches (`aLinearOrder`, `siteOrder`), Route A a globally agreed boundary designation. The program's founding ontology is "finitely many observers with partial views" and no global structure. How do observers with partial views come to share a total order? That is *itself* a consensus problem — the very problem T3 proves has no canonical solution without extra structure. The chain thus establishes, correctly: objectivity is purchasable with declared global structure. It never addresses that the purchasing currency (a shared roster) presupposes a solved instance of the problem being solved — a regress that is standard in distributed systems (leader election / total-order broadcast is equivalent to consensus) and is nowhere acknowledged in the corpus documents.

This does not make the theorems wrong; it bounds what they can mean physically. In the distributed-systems literature the analogous move (assume a sequencer) is understood as *relocating* the problem, not solving it.

## Where it bites

- `OPH_PROOF_CHAIN_PAPER.md:82` ("objectivity can be earned, two ways"), `:312` ("objectivity is purchased with declared structure, and the receipt is machine-checked"), `:1016` (verdict).

## What would close it

A named acknowledgment (one paragraph): the declared order is global structure whose establishment among partial-view observers is itself a consensus problem; the chain's theorems are conditional on it being *given*. Or — the interesting research direction — a theorem about *emergent* order (e.g. symmetry-broken schedules from local randomness with almost-sure agreement), which would genuinely earn the word "earned".

## In plain language

The two fixes for "who moves first decides the truth" are: publish a rulebook everyone follows, or protect pages everyone agrees are special. Both fixes begin "everyone agrees…". But *getting* everyone to agree was the original problem. The theorems honestly say what happens after the agreement exists; the story around them sometimes sounds like the agreement came for free.

> **Disposition audit (second pass): ✅ closed (acknowledged).** The demanded paragraph exists verbatim in spirit at paper:315: the regress named as "the very problem T3 proves has no canonical solution", the distributed-systems equivalence stated ("total-order broadcast is equivalent to consensus, and assuming a sequencer relocates the problem"), the theorems framed as conditionals on the structure being *given*, and the emergent-order direction named as "not currently on offer".

# 6. How much fence is the fence? (F5 ●)

## The hole

T7 ("bare consensus is not Einstein-complete") is machine-checked and true — and nearly contentless as mathematics, a fact the module half-admits ("symbol-counting, not analysis") and the paper acknowledges ("a definability separation") while still crowning it "the fence" with load-bearing rhetorical weight. The geometric decoration of a `GeometricExtension` shares *no field and no connecting law whatsoever* with the reduct — `Point`, `g`, `curv`, `T` are fresh, unconstrained data. Under such freedom nothing determines anything: the same proof shows bare consensus cannot decide the weather, the parity of `Point`'s cardinality, or the title of any book. The theorem's only real content is architectural self-discipline (any future "consensus ⇒ geometry" claim must name its imported structure). Note also the tension the documents never surface: T7 makes the program's own founding ambition — geometry *from* overlap consistency — definitionally unreachable in bare form, so every later "recovery" is hypothesis-import by construction. That is a legitimate design; it should be said in one sentence rather than framed as a discovered obstruction.

## Where it bites

- `OPH_PROOF_CHAIN_PAPER.md:326–338` (T7's framing: "the fence", "machine-refutably false");
- `NotEinsteinComplete.lean:144–162` (the decoration is fully unconstrained).

## What would close it

Nothing needs *proving*; the framing needs one honest clause: the separation holds because the extension's geometric data is unconstrained by any law — the fence certifies bookkeeping discipline, not a mathematical obstruction that required discovering.

## In plain language

One theorem says: the notebook rules alone can't decide Einstein's equation. True — in the same way the contents of a room can't decide the title of a book someone might later carry in: the model attaches the geometry to the world with no strings at all, so *of course* nothing about it follows. As self-discipline ("whenever we say gravity, we must say which added assumption carried it in") the fence is genuinely useful. As mathematics it is the observation that unrelated things are unrelated.

> **Disposition audit (second pass): ✅ closed.** Paper §8 (paper:337) now carries the honest clause nearly verbatim: "the separation holds *because* the geometric decoration is attached with no connecting law at all — the same proof shows bare consensus decides nothing whatsoever about any fresh structure — so the fence certifies **bookkeeping discipline**, not a discovered mathematical obstruction", including the unreachability-by-design sentence.

---

# Part II — Holography

# 7. "Boost invariance" is two data points (F6 ▲)

## The hole

T18a proves the width-2 screen works at slope 0 (the timelike tube) and at slope 1 — the lattice light-cone (`lightTube` reads `(i, j₀+i)`). From these **two** slopes the documents conclude: "a width-2 adjacent screen saturates the information bound **in every frame**" and "The screen's power is Lorentz-robust in the only sense available on a CA". Both sentences overreach:

1. "Every frame" has been checked at two slopes. Screens at intermediate rational velocities (e.g. one column per two ticks, reading `(i, j₀+⌈i/2⌉)` and its neighbour) are perfectly definable on the lattice, are the natural CA analogue of a *moving observer* (the slope-1 screen is a light-like locus, which no observer rides), and are untreated. The tree's own stride-`g` conjecture shows the authors know spatial deformations matter; velocity deformations are the same kind of open question, not a settled invariance.
2. "The only sense available on a CA" is wrong in the direction that matters: intermediate-slope screens *are* available; they were not analyzed.

The correct statement — sharp threshold at the two extreme slopes, intermediate slopes open — is weaker than "boost invariance" and much weaker than "in every frame".

## Where it bites

- `OPH_PROOF_CHAIN_PAPER.md:471` ("saturates the information bound in every frame"), `:485` ("Lorentz-robust in the only sense available on a CA");
- `Rule90Decoding.lean:23–34, 326–331` (the two proved slopes);
- `proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md:206–215` (same claim).

## What would close it

Either the theorem for general rational-slope width-2 screens (the sweep machinery looks adaptable; slopes `p/q` should trade sweep speed against window multiplicity — a genuinely interesting question), or the honest phrase: "at both extreme slopes (rest frame and light cone); intermediate slopes are open, conjecturally at the same threshold."

## In plain language

The paper tested the peephole standing still and the peephole moving at the absolute maximum speed, found both work perfectly, and announced the peephole works "in every state of motion". Walking speed was never tested. Probably it works there too — but "probably" is precisely the word the rest of this chain is so careful about.

> **Disposition audit (second pass): ◑ closed wording; a new debt opened.** The honest phrase is in place at every presentation site — paper:474 ("at both extreme slopes — rest frame and light cone … intermediate rational slopes … remain **open**"), paper:488, the chain's T18 block and §7 item 6 — and grep finds no surviving "in every frame" or "Lorentz-robust" anywhere. **Residues:** `test/DOCUMENT_B_critique_ledger.md:181` still cites unqualified "**boost invariance** of screen capacity"; and the fix's supporting evidence — "machine experiment at slopes 1/2, 1/3, 2/3, 1/4, 3/4 for all n ≤ 20" — exists nowhere in the repository as an artifact (→ F22; the claim itself is true — reproduced independently in Appendix B2).

# 8. Novelty, prior art, and the missing bibliography (F7 ●)

## The hole

The chain contains **zero citations** to the cellular-automaton / symbolic-dynamics literature, while its centerpiece phenomenon is classical there. Rule 90 is *bipermutive* (its local rule is a permutation in each extreme variable), and it is textbook symbolic dynamics that for bipermutive one-dimensional CA the vertical direction is expansive with a width-2 window: a two-column vertical strip of the spacetime diagram determines the entire (bi-infinite) configuration — the same sideways-solve that powers T9, known in the expansive-subdynamics literature (Boyle–Lind, *Expansive subdynamics*, 1997; Kůrka's CA classification; the standard theory of permutive CA going back to Hedlund). What is plausibly new in the tree is the *finite-cylinder sharp counting threshold* `n ≤ 2(t+1)`, the boost/gap variants, and the complete parity classification T20 — nice, publishable-shaped refinements. But the corpus's self-description ("the genuinely novel mathematics on offer", quoted into the paper's Part II header) and the paper's framing of the sideways sweep as a discovery are unsupported against prior art that nobody looked for. Similarly T19/T22 (hexacode `[6,3,4]₄`, MDS, weight enumerator) and T13 (hypercharges from anomalies + Yukawa; the ℤ₆ center kernel) and T21 (finite-dimensional Tomita–Takesaki) and T23 (quorum intersection) are standard known results — valuable *as formalizations*, misleading if read as mathematical contributions of the program.

## Where it bites

- `OPH_PROOF_CHAIN_PAPER.md:399` ("the genuinely novel mathematics on offer"), `:459` (the ADH analogy, which also elides that the screen here must be read *completely* — the code corrects erasures of the bulk given the screen, not erasures of the screen itself);
- the absence itself: no `\cite`, no reference list, anywhere in `proof_chain/` or the paper.

## What would close it

A related-work paragraph: bipermutivity/expansiveness for the infinite-lattice antecedent of T9; MDS folklore for T19; Geng–Marshak-type anomaly-uniqueness literature and the known SM global-gauge-group analysis for T13; finite-dimensional modular theory for T21 — and then the honest delta: the finite sharp thresholds and the parity classification. Formal-methods venues would also want exactly this.

## In plain language

The window-into-the-loop trick has been in the mathematics of cellular automata for decades under a different name; this project's real additions are the exact finite-size threshold and the odd/even classification — genuinely nice, smaller than advertised. Several other "theorems" of the chain are century-to-decades-old standards, formalized (which has value!) rather than discovered. A reference list would cost a page and would recalibrate the reader's sense of what is new here.

> **Disposition audit (second pass): ✅ closed.** Appendix C exists (paper:1125–1136) with exactly the demanded map — Hedlund 1969 / Boyle–Lind 1997 / Kůrka 2003 for the sideways-solve, MacWilliams–Sloane and Conway–Sloane for the hexacode, Geng–Marshak 1989 and Minahan–Ramond–Warner 1990 for hypercharge uniqueness, Tong 2017 for the global-gauge-group question, Bratteli–Robinson and Connes–Rovelli 1994 for the modular core, Jacobson 1995 (including the closing move T26 formalizes), Castro–Liskov 1999 / Malkhi–Reiter 1998 for T23, Milgrom 1983 / Famaey–McGaugh 2012 / MLS 2016 for the dark sector. Every attribution independently verified correct. The Part II header now concedes the sweep is classical and states the honest delta (the finite-cylinder theory); "the genuinely novel mathematics on offer" appears nowhere. The ADH-direction elision is also fixed (paper:462: "the screen must be read *completely*; the code corrects erasure of the bulk given the screen, not erasures of the screen itself").

---

# Part III — The conditional tower

# 9. The pointwise λ is not the cosmological constant (F8 ■)

## The hole

T14c (`jacobson_step`) is a statement about **one symmetric matrix** — one point of spacetime: if `F(k,k) = κT(k,k)` on the null cone at a point, then `F = κT + λη` at that point, for some number λ *at that point*. Over a region this yields a scalar **field** λ(x). The paper then writes: "the cosmological constant is exactly the residual pointwise freedom" and, in plain language, "a single knob's worth of freedom always survives, and it is precisely the **cosmological constant**". That identification is exactly one step of *mathematics* away from being true, and the step is missing: in Jacobson's own 1995 derivation, after the pointwise `G + λg = κT` one invokes the contracted Bianchi identity `∇·G = 0` together with stress conservation `∇·T = 0` to conclude `∇λ = 0` — only then is λ *a constant*, i.e. **the** cosmological constant rather than an undetermined scalar field (with which the equation would be a different, generally inconsistent theory). The chain formalizes no derivatives, no manifold, no Bianchi identity; the constancy step is neither machine-checked nor — the more surprising omission — **named as a hypothesis** anywhere (it does not appear in Section 26's ledger, nor in the T14 module's "does not establish" list, which names only the variational identities). The v5 slogan "every mathematical sub-claim in the chain with a written proof is machine-checked" fails here: the constancy argument is written mathematics in the very paper (Jacobson's) the chain cites as its Layer-1 hook.

Secondarily: the entire T14 layer is linear algebra at a single tangent space with *constant* matrices. "The full tensor equation holds entrywise" (T14b) means: at each point where the rest-frame relation holds for all frames, the matrices match at that point. Fields, curvature, and the equation *as a PDE* are untouched. The module's honest-scope says a version of this; the paper's Section 16 headline blocks do not.

## Where it bites

- `OPH_PROOF_CHAIN_PAPER.md:618–622` (T14c statement: "the cosmological constant is exactly the residual pointwise freedom"), `:634` ("it is not put in and cannot be kept out"), `:638` (plain language: "it is precisely the cosmological constant");
- `EinsteinBranch.lean:374–396` (`∃ lam : ℝ` — one point), module scope `:39–49` (names the variational identities as the *only* imported physics);
- `proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md:176–182` (T14 blurb, same identification);
- missing from the open-items ledger: `OPH_PROOF_CHAIN_PAPER.md:982–1000` (Section 26).

## What would close it

Smallest fix: rename λ honestly ("an undetermined scalar per point") and add the constancy step to the named list ("Bianchi + local stress conservation ⇒ dλ = 0 — written mathematics, not yet formalized"). Better: formalize it — even in the chain's own algebraic style a discrete/first-order version (λ as a function on points, a formalized divergence-free condition forcing local constancy) is a well-scoped module, and it would make T14 end at the Einstein equation instead of one step before it.

## In plain language

The chain proves: at any single point, the leftover freedom in this kind of gravity derivation is one number. Einstein's equation needs more: that it is the *same* number everywhere — otherwise you don't have a constant of nature, you have an unexplained new field, and the theory generally doesn't even hold together. The classical argument that forces "same everywhere" exists (it's in the very paper this program builds on), is pure mathematics, and is the one step of the Einstein story that this chain neither machine-checked nor listed as owed. The paper's claim to have priced everything it hasn't proven misses exactly this line item.

> **Disposition audit (second pass): ✅ CLOSED BY THEOREM — the exemplary disposition.** The "better" option was taken: **T26** (`LambdaConstancy.lean`, read in full here) formalizes exactly the demanded discrete/first-order version, and it is genuine — `einstein_equation_with_constant` (:187–204) **composes with `jacobson_step` in-tree** (:199–200), the constancy mechanism (Leibniz step `ddiv_lam_eta`, diagonal cancellation `row_eta_cancel`, reachability induction) is correct, the disconnected two-point counterexample (:212–233) makes connectivity load-bearing, and the honest-scope block (:51–61) names Bianchi + conservation as the inputs. The paper's §16 Statement is fixed ("a field λ(x), not yet a constant", paper:659) and §16a presents T26 faithfully. What the *rendering* of T26 imports (the "identity" naming, the "connected chart" gloss, the flat-η shadow, the index convention) is priced separately as **F23** — notes on the closure's wording, not a reopening. **Soft leftovers:** the §1.3 rung-4 bullet (paper:88) still attributes "the cosmological constant" to T14's residual freedom with no per-point caveat and no mention of T26 — the overview never learned about the chain's proudest v6.1 addition — and §16's Why-block (paper:671) still calls the pointwise kernel "the cosmological constant … not put in and cannot be kept out".

# 10. The KMS "clock" ticks in imaginary time only (F9 ▲)

## The hole

T21's uniqueness (`kms_unique`) is genuinely cute: any *map* satisfying `ω(A·D(B)) = ω(BA)` equals `Δ_ρ = ρ·ρ⁻¹`. But this pins the **single algebraic conjugation map** — the imaginary-time step — not a dynamics. The physical "thermal time" claim (Connes–Rovelli; Takesaki's theorem) is about the *real-time one-parameter group* `σ_t = ρ^{it}(·)ρ^{-it}`: the unique σ-weakly continuous automorphism group satisfying the KMS *boundary condition* (an analyticity statement about functions on a strip). The module's honest-scope block concedes real-time flow is not formalized — and then the paper's Section 15 headline reads the algebraic identity as the temporal claim anyway: "a patch state does not need dynamics as extra structure — it already carries its unique KMS **clock**"; plain language: "hidden inside any statistical state there is exactly **one** built-in notion of flow". What is machine-checked supports: *the state determines a distinguished algebra automorphism, characterized by a trace-twisting identity, trivial iff the state is tracial*. Calling that automorphism a clock, a flow, or a dynamics — words whose content is precisely the real-time structure that was not formalized — imports the unformalized half silently. ("Flow structure" in the paper rests on `modular_iterate` over `k : ℕ`: iterates of the same map, a semigroup of integer imaginary steps, not a one-parameter group.)

## Where it bites

- `OPH_PROOF_CHAIN_PAPER.md:571–578` (T21 statement blocks), `:598` ("already carries its unique KMS clock"), `:602` ("exactly one built-in notion of flow … the flow is *forced*, uniquely");
- `ModularCore.lean:59–70` (honest scope: no `Δ^{it}`, no functional calculus), `:150–160` (`modular_iterate`, ℕ only);
- `proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md:246–267` (T21 blurb: "the state pins its dynamics").

## What would close it

Either formalize the finite-dimensional real-time statement — in matrix algebras `ρ^{it}` is elementary via diagonalization, and "the modular group is the unique KMS flow among continuous one-parameter automorphism groups" is a well-scoped finite-dimensional theorem — or reword: "the state pins a distinguished automorphism (the imaginary-time modular step); identifying its real-time continuation as *time* is part of the named D3 physics." The second costs two words ("clock" → "map") in six places.

## In plain language

What the machine checked: every lopsided statistical state singles out one special reshuffling operation, and only perfectly uniform states single out "do nothing". Calling that operation a *clock* — something that ticks through time — is the part that was *not* checked; the actual time-version of the theorem lives in analysis the module explicitly (and honestly) declined to do. The state pins an operation. Whether that operation is time is not just the Bisognano–Wichmann physics the paper names — even the operation's own status *as a flow* is a smaller unformalized step the wording papers over.

> **Disposition audit (second pass): ◑ closed at the cited anchors only — the disposition row ("fixed wording everywhere") is false.** Genuinely fixed: the paper's §15 Why-block and plain language (paper:635, :639 — "the operation is proven; 'clock' is two steps of honesty away"), the chain's L2.2 row (CORE:458), and the real-time statement named open (paper:1063; chain §7 item 7). **Surviving clock/flow/dynamics language with no caveat in reach:** CORE:748–749 — the chain document's *closing sentence* still reads "a patch state already carries its unique KMS clock (T21); what physics must supply is **only** which geometric flow that clock is", contradicting §7 item 7 twenty lines above it; CORE:255 and :260–263 (the §1 T21 block — the word "imaginary" does not occur in it); CORE:563 (§6 diagram); CORE:645–646 (§7 item 5: "the state uniquely determines its KMS dynamics" — the exact content item 7 declares open); paper:87 (rung 4: "already carries a unique KMS dynamics", with Bisognano–Wichmann presented as the *only* remaining gap); paper:609 and :613 (the §15 **Statement** block: "the state pins its dynamics"; "modular clock genuinely ticks"); paper:610 ("a one-parameter group in imaginary time" — the Lean `modular_iterate` is an ℕ-indexed monoid action; no ℤ- or ℝ-indexed statement exists); `RESULTS.md:313`; `formal/README.md:55` (whose "what stays physics" list omits the open real-time mathematics).

# 11. The 24 = 4·6 = 2·12 bookkeeping proves arithmetic, not structure (F10 ▲)

## The hole

Section 19 works hard to make `e^{-P/24}` look inevitable-given-the-gate, and the gate clauses are duly named as physics. But look at what the machine actually checks, and at what the prose then claims for it:

1. `uniform_gate` is: a weighted average of the constant `e^{-P/24}` is `e^{-P/24}` (substitute; `∑w = 1`). `chi_forced` is: cancel `S`. These are true and empty — the entire content of "λ_collar = e^{-P/24} **exactly**" is clause 5 of the gate (ε_y = P/24 per slice), i.e. the conclusion was placed in the hypothesis, verbatim. The Jensen band is the one real inequality, and it is textbook.
2. The "24 bookkeeping" consists of **two unrelated factorizations**: `(P/4)/6 = P/24` (shared-cut quarter over six center classes) and `24 = 12×2` (ports × orientation). The Lean checks each arithmetic identity separately (`reserve_split`, `twentyfour_is_oriented_ports`); *nothing* — formal or informal — connects the icosahedral 12·2 to the ℤ₆-quotient 4·6, or either to the Poisson exponent. Any target number with enough divisors supports such stories; the identical machinery would certify `e^{-P/12}` (2·6; ports × … ) or `e^{-P/48}` with equal rigor. The paper's "even the 'twelve' is given its honest source: it is **not numerology** but Euler's formula" inverts the burden: Gauss–Bonnet converts the *postulate* "the collar is an all-triangle Euler-characteristic-2 surface with degrees in {5,6}" into 12; the postulate — why the collar is an icosahedral sieve at all — is precisely the numerology-shaped step, and it is not among the named L1–L7 clauses in the chain documents' lists.
3. The "6" imports the ℤ₆ kernel of T13 as if the *physical* gauge group were settled to be the full quotient. Two gaps hide there: (a) mathematically, the tree proves a **set bijection** of the trivially-acting central subgroup with `ZMod 6` (plus `addOrderOf g₀ = 6`); the group-isomorphism statement is assemble-able but never assembled; (b) physically, which quotient of `SU(3)×SU(2)×U(1)` is the gauge group of nature (Γ ∈ {1, ℤ₂, ℤ₃, ℤ₆}) is a famously **open empirical question** (it changes the allowed line operators / periodicities, not the perturbative physics) — the kernel computation says the action on the *known* fields factors, not that the quotient is realized. Splitting a "protected reserve" into exactly 6 classes because of ℤ₆ therefore consumes an unproven identification of the global gauge-group form — a named-hypothesis-grade step that is not named.

## Where it bites

- `OPH_PROOF_CHAIN_PAPER.md:747–757` (T16 statements 2, 5, 6), `:773` ("it is not numerology but Euler's formula"), `:777` (plain language: "even the twelve is not numerology");
- `CollarGate.lean:118–126` (`uniform_gate`), `:181–189` (the two disconnected factorizations), `:203–249` (Gauss–Bonnet — correct, but consuming the degree-{5,6} sphere postulate);
- `CenterZ6.lean:341–366` (bijection, not iso, as stated);
- `proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md:193–198` (T16 blurb).

## What would close it

(a) Add the missing clause to the named list: *"L0: the collar's transverse structure is an all-triangle χ=2 complex with vertex degrees in {5,6}, its 12 defects are the ports, ports carry two orientations, and the reserve splits uniformly over the ℤ₆ classes of the realized-package kernel"* — then the 24 is honest-conditional. (b) State the global-gauge-group identification as a hypothesis wherever the "6" is consumed. (c) One-line Lean addition: package the kernel as a group isomorphism. (d) Drop "not numerology": the correct sentence is "numerology with its postulates named", which is the chain's own standard elsewhere.

## In plain language

The famous 7 %-discount number comes from dividing a quantity by 24, and the paper tells two stories about why 24: a quarter split six ways, and twelve doors each used in two directions. Both stories check out as *multiplication*; neither story is connected to the other, or to the discount mechanism, by anything but the narrative. And each story's key integer is itself an assumption: the "six" assumes a fact about nature's symmetry group that real physics has not determined; the "twelve" follows from assuming the protective layer is shaped like a soccer ball. Assuming a soccer ball and deriving twelve pentagons is Euler's theorem; assuming the soccer ball is the part the word "numerology" was invented for. The chain names many hypotheses admirably; these ones it decorates instead.

> **Disposition audit (second pass): ◑ closed in the paper's main sections only — the disposition row ("L0 named wherever the twelve ports are consumed") is false.** Genuinely fixed, in the paper: (a) L0 named in §19 (paper:820) and in the §26 conventions block (:1055–1057); (b) the realized-ℤ₆ identification named in T13's Why (paper:725) and §26 (:1059); (d) "not numerology" demoted to "numerology with its postulates named" (paper:820, :824). **Not done / surviving:** (a′) in the *chain document*, L0 appears **only inside the disposition table itself** (CORE:886, :899) — the T16 bullet (:193–198), the L2.6 row (:462), the L2.10 row (:466), the §6 diagram (:555–557), and every hypothesis list (CORE:50, :424, :577, :632, :705) still read bare "L1–L7"; the paper is also internally split (front matter :10 says "L0–L7", the §1.4 table :104 and notation table :1154 say "L1–L7"); and `test/DOCUMENT_A` §1.4 (:144–149) — the pre-registration ledger that consumes `χ_can` — grants "L1–L7" with no L0 row (DOCUMENT_C inherits it). (b′) the realized-Γ caveat is likewise absent at the chain's consumption sites (L2.4 row :460; T13 bullet :167–174), and two formal-layer texts flatly assert the identification the fix names as open: `RESULTS.md:171` ("the kernel is exactly ℤ₆ — `G_phys = SU(3)×SU(2)×U(1)/ℤ₆`") and `CenterZ6.lean:57–60` ("the global structure is forced to the ℤ₆ quotient — both machine-checked"). (c′) the one-line Lean iso was not added: `CenterZ6.lean` still exports `kernel_bijection` / `kernelEquivZMod6` (a plain `Equiv`) + `addOrderOf_g0 = 6`, while paper:709–711 (a **Theorem**-labelled block), CORE:171–172, and `formal/README.md:34` all print "≅ ℤ₆".

# 12. "The same counter the collar prices" is a naming, not a theorem (F11 ▲)

## The hole

T17's headline — "coherent matter perturbs **exactly the counter the collar prices**", elevated in Section 21 to "the record-side perturbation and the gravity-side channel are **provably the same** bookkeeping quantity" — has no formal counterpart. `DeltaSBridge.count` (a weighted sum of slot indicators over a `SlotRegister`) and the collar's priced object (`CollarGate.SliceModel`'s per-slice reserve means ε, or `DarkSector`'s Poisson mean) live in **disjoint modules with no imports between them, no shared type, and no identification lemma**. What is machine-checked is: the generator increments *its own register's* counter by `S·avail` — an exact, and essentially definitional, computation (`gen_count` is three lines of algebra after `count_activate`'s case split). The claimed sameness — that this register *is* the channel the dark-sector/collar mathematics prices — is the physical identification, i.e. it is (part of) SEE/L1–L7/G9, and calling it "provably" anything mislabels prose as proof. The honest sentence exists in the tree ("the *same* counter" is asserted in a docstring, not proven anywhere) and the paper hardened it.

## Where it bites

- `OPH_PROOF_CHAIN_PAPER.md:818` (T17.2: "coherent matter perturbs exactly the counter the collar prices"), `:839` ("provably the same bookkeeping quantity, up to one missing number");
- `DeltaSBridge.lean:102–105, 194–199` (the counter and the identity — self-contained), absence of any cross-module identification (no imports of `CollarGate`/`DarkSector`);
- `proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md:200–204` (T17 blurb: "perturbs the *same* counter").

## What would close it

Either a formal bridge (a structure in which the collar's slices and the register's slots are the same indexed family, with the Poisson mean and the opportunity count derived from one object — then "the same counter" is a theorem about that structure and the physical residue is cleanly G9), or demote the word: "perturbs a counter *of the same form as* the one the collar prices; their identification is the named channel hypothesis."

## In plain language

The theory keeps one ledger for "how much record-keeping is happening" and another for "how much the gravity-discount mechanism cares". The machine checked a fact about the first ledger alone: coherent activity writes into it at a computable rate. The claim that the two ledgers are *the same ledger* — the actual bridge in "the ΔS bridge" — is not checked anywhere; the two ledgers never even meet inside the mathematics. Saying "provably the same" about them is exactly the sentence this program's own rules exist to catch.

> **Disposition audit (second pass): ◑ the secondary anchor was fixed; the primary survives — the disposition row overclaims.** Genuinely fixed: the §21 Why-block (paper:886 — "a counter **of the same form as** … The *identification* of the two … is not a theorem anywhere (the two live in modules that never meet)"), the chain's L2.12 row (CORE:468), and the §26 channel-identification block (paper:1061). **Surviving — including this finding's own primary anchor:** the §21 **Statement** block still says "— *the same counter the dark-sector collar channel prices*" (paper:858) and, in bold, inside theorem-labelled text, "*(Theorem B.7)* … **coherent matter perturbs exactly the counter the collar prices**" (paper:865) — directly contradicting the Why-block twenty lines below it; the chain's §1 T17 bullet (CORE:203–204, "perturbs the *same* counter the collar prices"); `RESULTS.md:285`; and the origin docstring `DeltaSBridge.lean:190` ("perturbation of the SAME counter the collar prices"). The statement readers will quote is the one that was not fixed.

# 13. SEE: a hypothesis the width of its conclusion (F12 ●)

## The hole

P4's formal content: if every admissible source lies on the line `ℝ·η`, then every linear response on sources is one number. The paper is admirably frank that the proof is two lines and that SEE carries everything. Two things still deserve flags. First, as formalized SEE literally says *the source space is one-dimensional* — the "theorem" is then "a linear functional on a line is multiplication by a scalar". The distance between hypothesis and conclusion is zero; unlike T13 (whose hypotheses — anomaly cancellation, Yukawa closure — are independently motivated constraints that *happen* to force the answer), SEE is the conclusion wearing a definition's clothes. The chain's uniform rhetoric — every named hypothesis "sits directly upstream of a machine-checked consequence theorem", each with a "banked payoff" — flattens exactly the distinction that matters: for MAR the payoff (T13) is a genuine forcing theorem; for SEE the payoff (P4) is a restatement, and for L1–L7 the payoff (T16.2) is a weighted average of a constant. Second, the *linearity* of the response is itself physics (first-order response), consumed silently through the type `V →ₗ[ℝ] ℝ`; the paper's own claimed form "δν = χ⟨η,S⟩ + O(S²)" contains a remainder clause that the formal statement drops.

## Where it bites

- `OPH_PROOF_CHAIN_PAPER.md:785–801` (P4 blocks — honest about shortness, silent about the flatness distinction), `:109` ("every named hypothesis sits directly upstream of a machine-checked consequence theorem" — true, with wildly heterogeneous content);
- `ScalarResponse.lean:48–64`.

## What would close it

A one-line informativeness grade per named hypothesis in Section 26 ("payoff type: forcing / band / restatement"), so a reader can see which conditionals do work and which are bookkeeping. It would cost the chain nothing — its best rows (MAR→T13) would shine more, not less.

## In plain language

Some of the tower's "if physics gives us X, mathematics delivers Y" links are real machines: feed in a modest assumption, get out a sharp surprising consequence. Others are conveyor belts one meter long: the assumption *is* the consequence, restated. The program's ledger lists both kinds with the same proud stamp. A reader deserves the distinction — especially since the experiment's headline number flows through two of the one-meter belts in a row.

> **Disposition audit (second pass): ✅ closed.** The demanded grading exists exactly where demanded, §26 (paper:1051): forcing / band / restatement, with SEE → P4 graded "restatement" and the blunt closing sentence "The experiment's headline number flows through two restatement-grade links in a row — a reader should know that." (Nano: the chain document's own hypothesis list, §7 item 3, keeps the ungraded uniform rhetoric.)

# 14. What "forced" means in the hypercharge theorem (F13 ●)

## The hole

T13 is correct, classical, and its scope notes are good (MAR is named; the paper says "given the cast of particles"). Three boundary facts still never appear in the chain documents: (i) the electroweak normalization `Q(ν_L) = 0` is an *empirical* input — the paper calls it "one physical normalization" without flagging that it is a measured fact of exactly the kind the "no freedom at all" rhetoric elides; (ii) uniqueness is package-relative in a way that current physics already strains: the realized package contains no right-handed neutrino, while neutrino oscillations require neutrino mass — the minimal extensions (add ν_R, or a Majorana sector) change the anomaly/Yukawa system that "forces" the charges (the ray survives, the uniqueness statement's hypotheses change), so the "cast list" MAR selects is one nature has already amended; (iii) the anomaly conditions are imposed per-generation — cross-generation cancellations are excluded by the one-generation ansatz, i.e. by MAR again. All three belong in the honest-scope of a chain that prides itself on naming every leaned-on fact; none is a defect of the algebra.

## Where it bites

- `OPH_PROOF_CHAIN_PAPER.md:654–658, 678–682`;
- `Hypercharge.lean:30–44` (scope: names MAR, not the empirical normalization's status or the ν_R issue).

## What would close it

Two sentences in the T13 scope: the normalization is an empirical anchor; the package is known-incomplete (neutrino mass), and the theorem's uniqueness is relative to the unamended package.

## In plain language

"Given the particle cast, the charges are forced" is right — but one of the forcing inputs is a measurement (the neutrino's neutrality), and the cast itself is one that real experiments have already shown needs at least a understudy (something that gives neutrinos mass). Neither point dents the algebra; both belong on the label.

> **Disposition audit (second pass): ✅ closed.** All three labels are now carried in T13's Why-block (paper:725): the normalization flagged as "an *empirical* anchor, not algebra"; the package-relative caveat with the ν-mass amendment spelled out; the per-generation ansatz named. (Nano: the flags live in the paper; `Hypercharge.lean`'s own scope docstring is unchanged.)

# 15. The dark sector's law is the literature's fitting function (F14 ●)

## The hole

Three omissions make Section 18 read as more OPH-specific than it is:

1. **The interpolation function is the published empirical RAR fit.** `ν_OPH(x) = (1 − e^{−λ√x})⁻¹` is, at λ = 1 (λ absorbable into `a_eff = a₀/λ²`), *exactly* the fitting function of the observed radial-acceleration relation (McGaugh–Lelli–Schombert 2016, `g_obs = g_bar/(1−e^{−√(g_bar/a₀)})`). The chain documents never say so. Consequently "the exact effective acceleration scale — exact, not fitted" (paper §18) is subtly misleading: the λ-relation is derived *within the ansatz*, but the ansatz's shape is the curve the astronomy community fitted to data; the Poisson story is a proposed mechanism *for the known fit*, and every "phenomenological success" listed (Newtonian limit, deep-MOND scaling, BTFR) is a property of the fitted curve shared by **every** MOND interpolation function with those limits — the machine-checked items T15.1–6 test the OPH mechanism not at all.
2. **The curl caveat is dropped.** The upstream dark paper states plainly that the algebraic law `g_obs = ν·g_b` "is exact only when symmetry removes the curl term" (`oph_dark_matter_paper.tex:92`) — the standard obstruction that a pointwise algebraic relation between two gradient fields is inconsistent for generic non-spherical sources. The chain's formalization works with scalars and a point source, where the obstruction is invisible; neither chain document nor the paper carries the caveat, and Section 18's plain language ("a specific, testable 'boosted' law") reads as unconditional.
3. **The misfit disclosure is dropped.** The corpus's own Correction Audit (quoted in `AUDIT_RESPONSE_REVIEW.md`) records that `e^{-P/24} = 0.9343` sits between the binned-RAR preferred `0.9367` and the common-empirical-`a₀` preferred `0.9261` and *cannot reach the latter* without new theory. The expository paper's dark-sector and collar sections never mention this — the one place the tower touches data, and the tension is edited out of the reader's view.

## Where it bites

- `OPH_PROOF_CHAIN_PAPER.md:688–733` (Section 18, incl. "exact, not fitted" at `:729` and the unconditional plain language at `:733`);
- `DarkSector.lean` (correct, scalar-only — the invisibility of (2) by construction);
- upstream honesty not propagated: `oph_dark_matter_paper.tex:92, 519–521, 762, 2304–2338`.

## What would close it

Three sentences: name the function as the RAR fitting function with the Poisson story as its proposed mechanism; carry the spherical-symmetry/curl scope; quote the Correction Audit's numbers where χ_can is presented as a target.

## In plain language

The galaxy-rotation law this theory "predicts" is, curve for curve, the formula astronomers already use to *describe* the data — this program adds a story about why that curve, plus a specific strength. Fine and honest work — but the paper presents the curve's well-known virtues as the theory's achievements, leaves out that the law can't hold exactly for lopsided galaxies (its own source paper says so), and leaves out its own auditors' note that the predicted strength sits measurably off the best-fit values. All three facts are upstream in the corpus; the reader of this paper never meets them.

> **Disposition audit (second pass): ✅ closed.** All three facts are now carried in §18 (paper:776, :780): the MLS16 fitting-function identity ("curve for curve … the Poisson story is a proposed *mechanism for the known fit*", with the honest corollary that items 1–6 "test the mechanism not at all"), the curl/sphericity caveat, and the Correction-Audit misfit numbers (0.9343 between 0.9367 and 0.9261) — plus MLS16 in Appendix C. "Exact, not fitted" is gone (now "the λ-to-a_eff relation exact within the ansatz").

---

# Part IV — The cage, the numbers, the experiment

# 16. The 3.5 MJ toggle ledger rests on a zero-point convention the cycle theorems do not force (F15 ■)

## The hole

T10's machine-checked content is exact and modest: for a switchable state energy `E(q,s)`, ABBA-cycle work `= τ(q₁) − τ(q₂)` (a **difference** of toggle costs), so bounded toggle ledgers bound cycle work (`no_free_toggle`), and extracting `W` per cycle forces a ledger entry `≥ W/2` (`toggle_ledger_lower_bound`). Note what these theorems structurally *cannot* do: a constant offset in τ cancels from every cycle — **conservation constrains only the position-dependence of the toggle cost, never its absolute size**. The theorem-forced ledger scale for the experiment is therefore set by the work its cycles could actually extract: with ΔM = 0.056 kg over a bench stroke Δh,

- `W_cyc = ΔM·g·Δh ≈ 0.55 J` per meter of stroke — forced entry ≥ **0.27 J** per toggle for a 1 m cycle;
- for the experiment's actual protocol (toggling at fixed position on a balance), `W_cyc = 0` and the theorems force **no entry at all**.

The advertised number — "**≈ 3.5 MJ per ACTIVE toggle**", the pivot of the DETECT self-refutation rule and of Document C Part 7 — is `ΔM·Φ_N` with `Φ_N = G M_E/R_E`: the energy to remove 56 g **to spatial infinity**. That is a *zero-point convention* (interaction energy referenced to infinity), attached to the theorems by the arithmetic lemma `toggle_energy_value` but derived from none of them. The steelman: if the toggle genuinely creates/destroys gravitating source strength, then in Newtonian field bookkeeping the Earth–coupon interaction energy does change by ±ΔM·Φ_N — but (a) that transaction is *field-borne and global*, with nothing in the theorems (or in any completed theory on offer) routing it through the device's electronics, so "a DETECT without a ≈3.5 MJ entry **in the experiment's energy log** is self-refuting" does not follow; and (b) if one instead prices genuine source creation relativistically, the honest number is `ΔM·c² ≈ 5.0×10¹⁵ J` — nine orders *above* the advertised one. The 3.5 MJ sits unexplained between the two defensible anchors: **seven orders above what the cycle theorems force for any bench-realizable cycle, nine orders below the mass–energy cost of real source creation.**

Downstream casualties: the **battery-coupon ceiling** (`Δν ≤ (E_batt/Φ_N)·g/(C_geom·A)`, T24) prices a battery's "affordable phantom mass" at `E_batt/Φ_N` — the same convention. Under the difference-only reading a battery could "afford" `E_batt/(g·Δh) ≈ 3.7×10³ kg` per meter-cycle: the ceiling, as a *conservation* bound, does not exist; as a bound on the specific source-creation completion it is hypothesis-conditional. The celebrated erratum (T24: printed ceiling 3 % low, fixed) corrected the third digit of a number whose first digit has no derivation — audited arithmetic downstream of an unaudited convention. And DOCUMENT A §1.9's colorful "~1 kg-TNT-scale heat/work per state change, never observed in any piezo" prices the convention, not a theorem.

To be precise about what survives: the *qualitative* cage is real (a switchable weight coupled to actual transport does yield a work cycle; a completed theory owes an energy account), the NULL expectation stands on many grounds, and the cycle identities are true. What fails is the load path from those theorems to the specific megajoule decision rule the documents call theorem-form.

## Where it bites

- `OPH_PROOF_CHAIN_PAPER.md:91` ("a genuine detection at the design point must arrive with a ≈ 3.5 MJ energy-ledger entry per toggle"), `:897–898` (T10.4 presenting `|ΔM·Φ_N|` as what "the toggle transaction" *is*), `:911` ("each activation must transact about 3.5 megajoules against the Earth's potential … theorems (2)–(3) say in advance how large the log entry must be" — theorems (2)–(3) say `≥ W/2` for realized cycle work `W`, i.e. joules at bench scale), `:915` ("a claimed detection unaccompanied by a matching megajoule entry in the power logs is to be rejected on arrival"), `:933` (battery ceiling);
- `proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md:406–421` (§5), `:522` ("Any DETECT without a ≥ 3.5 MJ-scale ledger entry is self-refuting by T10" — **not** by T10);
- `EnergyCage.lean:63–103` (the difference-only theorems — correct), `:137–153` (`toggle_energy_value` — arithmetic on the convention); `LedgerNumerics.lean:126–155` (`battery_coupon_bounds`);
- `test/DOCUMENT_A_prediction_ledger.md:275–284` (the decision-layer consumption).

## What would close it

Name the convention as a hypothesis — it is one: *"(G10-convention) toggling transacts the full infinity-referenced interaction energy ΔM·Φ_N against a locally-audited ledger"* — and then state the two theorem-grade bounds beside it: per-cycle forced entry `ΔM·g·Δh` (with the experiment's actual Δh), and the relativistic source-creation cost `ΔM·c²` as the ceiling reading. Rewrite the DETECT rule to the defensible version: *a DETECT with genuine transport cycles must show ledger entries ≥ the realized cycle work; a DETECT claiming genuine source creation contradicts local energy conservation at the `ΔM·c²` scale unless the completion documents its energy transport* — which is both stronger as physics and honest about what T10 proves.

## In plain language

The paper's flagship "airtight accounting" claim says: if the gadget really made 56 grams of weight appear and disappear, each flip of the switch must burn about a phone battery of energy — and any claimed detection without that entry in the logs refutes itself. But the actual theorem behind this says only that *round trips* can't create energy: it constrains the *difference* between the flip's cost upstairs and downstairs, and for a device sitting still on a bench that difference is zero — the theorem then demands nothing at all. The phone-battery number comes from pricing the flip as if the 56 grams were being hauled in from infinitely far away — a bookkeeping choice, not a law. Priced by the physics of actually *making* 56 grams of gravitating stuff, the honest number is a billion times bigger; priced by what the bench cycles can extract, it's a million times smaller — about a joule. The megajoule rule so much of the experiment's decision logic leans on lives in the unexplained middle, wearing a theorem's clothes.

> **Disposition audit (second pass): ◑ closed at every dispositioned site — with formal-layer stragglers that recreate the old load path.** This finding received the most thorough application, and every site the disposition names is genuinely fixed and was verified here: the chain's §5 rewrite ("What the theorems force vs what the convention prices", CORE:492–516, with all three anchors — 0.55 J/m, ≈ 0 at fixed height, `ΔM·c² ≈ 5×10¹⁵ J`); paper §23 (:960–966), rung 4 (:92), §1.5 item 4 (:121), the G10 rows (paper:1045; CORE §7 item 2), the §26 convention block (:1055); DOCUMENT A §1.9 (:272–293, including the honest "can be contested without touching any theorem"); DOCUMENT B (:103–108); DOCUMENT C Part 7 (:261–270); and the `EnergyCage.lean` module header (:36–42). The DETECT rule is rewritten to the demanded two-branch version. **Stragglers (files the disposition did not list):** `RESULTS.md:91–94` still bills `no_free_toggle` as "**the G10 obligation as a theorem**" with the 3.5 MJ row two lines below and the word "convention" occurring nowhere in the file; `formal/README.md:23` likewise; and `EnergyCage.lean:141–145` — the docstring *on the theorem itself* — still says "Every ACTIVE half-cycle of the experiment must account for it", unqualified, at the exact point of use the module header qualifies.

# 17. What the experiment can actually adjudicate (F16 ●)

## The hole

Put the chain's own concessions side by side and the experiment's epistemic yield is smaller than the verdict sections suggest. A NULL bounds only the product `χ·ΔS` (G9 open — their #1 gap; no draft calibration exists in the corpus by their own sweep), where `χ`'s "canonical" value is conditional on L1–L7 (whose payoff theorem is a restatement, F12/F10) and `ΔS` has no committed magnitude for any buildable coupon. Under the honest Jensen-only hypothesis the prediction is a **band** `[0.934, 1]` for χ (7 % wide) multiplying an unconstrained ΔS — so a NULL excludes *no* graded claim of the chain, and a DETECT would be filtered by a self-refutation rule that F15 shows is convention-based, plus mundane-artifact ceilings (battery) with the same defect. "A DETECT/NULL verdict will adjudicate *named physics*, never arithmetic" (paper §27) is literally true and practically empty: it adjudicates the *conjunction* SEE ∧ L1–L7 ∧ G9-calibration ∧ response-law — a conjunction with a free product parameter, which a NULL cannot falsify and a DETECT cannot confirm. The chain says each piece of this (the product-bound sentence is theirs); the verdict's "the experiment remains exactly the right instrument: it prices the last two open links no matter whose prior is right" dresses an unfalsifiable-until-G9 situation as a decisive one. The right instrument, by the chain's own logic, is *whatever supplies G9* — before any weighing.

## Where it bites

- `OPH_PROOF_CHAIN_PAPER.md:825` (the product-bound concession — honest), `:1010` ("a falsification methodology with theorems attached"), `:1016` ("a null result will still be informative: it prices the last two open links");
- `proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md:600–602` (verdict: "exactly the right instrument").

## What would close it

One honest sentence in both verdicts: *until G9 exists, a NULL constrains no graded claim of this chain (it bounds a product with a free factor), and the DETECT filters are convention-conditional (F15) — the experiment is a bound-setting exercise and an engineering rehearsal, not an adjudication of the tower.* If that sentence feels too costly, that is itself information.

## In plain language

For the experiment to test the theory, the theory must first say how big an effect it expects. It doesn't — by its own accounting, one number (the exchange rate between "records kept" and "gravity's ledger") is missing, so the prediction is "some strength times an unknown". Seeing nothing is then compatible with everything; seeing something would be judged by an energy rule that (previous finding) isn't actually forced. The documents admit each half of this in different places, then still call the experiment "exactly the right instrument". The right instrument would be the missing exchange rate.

> **Disposition audit (second pass): ◑ half-closed.** The demanded sentence was genuinely added to both verdicts — paper:1081 ("the honest yield of *nothing* is a bound on a product with one factor still uncalibrated (G9) — a bound-setting exercise and a rehearsal of the receipt discipline … not, until G9 exists, an adjudication of the tower") and CORE §8 item 3 (:717–723, ending "the decisive instrument for the tower is whatever supplies G9"). **But the precisely-flagged sentence was not removed:** CORE:739–741 still closes the chain document with "the experiment in this directory remains exactly the right instrument: it prices the last two links no matter whose prior is right" — twenty lines after item 3 says the opposite. The chain's verdict now contains both the concession and the claim the concession refutes.

# 18. The two P's: what remains under-stated (F17 ●)

## The hole

T11 is the chain's best forensic work, and its statements are scrupulously scoped ("statements about the published numerals"). Two residues still deserve visibility. First, `ProotReported` enters as a decimal literal; nothing formal ties it to any function's root — the machine has verified the *distance between two numerals*, so the finding's force rests entirely on the (reproduced, but informal) execution of the solver. Fine — but then the chain-level phrase "the two branches, now machine-checked" (CORE_MINIMAL L2.5) claims slightly too much: the *gap between two published decimals* is machine-checked; the branches are not. Second, the composition of T11 with T16/L2.10 deserves one blunt sentence that no document quite writes: **the experiment's canonical χ target is, through its only executed branch, a repackaging of the measured fine-structure constant** — so even a hypothetical clean measurement of χ_can at 0.9343 would confirm a number *calibrated from α*, and the "zero-input" reading would require first closing P's source branch (which currently misses by 300 ppm ≈ 2×10⁶ σ, a fact stated in P-space but never in σ against the experiment's own precision rhetoric).

## Where it bites

- `proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md:387` ("two branches, now machine-checked");
- `OPH_PROOF_CHAIN_PAPER.md:849–874` (Section 22 — honest, stops one sentence short of the composition above), `:777` (§19's "the theory commits to an actual number" — the committed number is α-calibrated).

## What would close it

The one sentence, in Section 19 or 22: "on the only executed branch, χ_can inherits measured α by definition; a match would not evidence a derivation."

## In plain language

The theory's target number was caught being built out of a measured constant — the chain itself proved this, to its credit. The residual gloss to remove: hitting that target in the lab would therefore confirm a *calibration*, not a prediction. The paper documents the crime scene meticulously and then continues to call the stolen goods "an actual number the theory commits to".

> **Disposition audit (second pass): ✅ closed.** The L2.5 row is reworded exactly as demanded (CORE:461: "the two published numerals and their gap, machine-checked … the solver's root is tied to its function only by the reproduced execution"), and the composition sentence exists at paper:929 — with the σ-figure spelled out ("~300 ppm, i.e. ~2×10⁶ standard deviations of the measured constant"; arithmetic re-verified). The demanded sentence was permitted "in Section 19 **or** 22"; it sits at the head of Part IV, adjacent to §22. (Nano: §19's plain language, paper:824, still opens "Here the theory commits to an actual number" with no local pointer to the calibration note.)

---

# Part V — Cross-cutting

# 19. The exposition adds content: an erratum-grade list (F18 ■)

## The hole

The paper's front matter promises: "**What this paper adds — Nothing.** It is *exposition*… it does not upgrade anything," and closes "Errors of exposition are this document's alone; the theorems don't have any." The second clause is verified true (Section 1). The first is not: in at least six load-bearing places the exposition asserts more than the Lean or misstates it. Collected for fixing:

| # | Location | Sentence | Defect | Finding |
|---|---|---|---|---|
| 1 | `:76` (§1.3) | "a canonical repair operator obeying them exists on every carrier" | false — H2 fails off frustration-free carriers; refuted by `rule90_no_frustrationFree_repair` | F1 |
| 2 | `:117` (§1.5) | "eventually every shared page agrees" | false on frustrated carriers; repair stalls (witness on the jewel carrier) | F1/F2 |
| 3 | `:91, :911, :915` (§1.3, §23) | "must arrive with a ≈ 3.5 MJ energy-ledger entry per toggle"; "theorems (2)–(3) say in advance how large" | the theorems force `≥ W/2` of realized cycle work (joules at bench scale); the MJ figure is a zero-point convention outside the theorems | F15 |
| 4 | `:618–638` (§16) | "the cosmological constant is exactly the residual pointwise freedom … it is precisely the cosmological constant" | pointwise λ is a scalar field; constancy (Bianchi step) unproven and unnamed | F8 |
| 5 | `:598–602` (§15) | "already carries its unique KMS clock … exactly one built-in notion of flow" | uniqueness proven for the imaginary-time map; flow/clock content unformalized (and conceded elsewhere in the same module) | F9 |
| 6 | `:839` (§21) | "provably the same bookkeeping quantity" | no formal identification exists between the two modules' counters | F11 |
| 7 | `:471, :485` (§12) | "in every frame"; "Lorentz-robust in the only sense available" | two slopes checked; intermediate-slope screens exist and are open | F6 |
| 8 | `:270` (§6) | "needs no choices beyond a declared patch order" | also needs a global fix-selection (choice) | F3 |
| 9 | `:773–777` (§19) | "it is not numerology but Euler's formula" | Euler converts the unnamed icosahedral postulate into 12; the postulate is the numerological step | F10 |

Each row is a one-to-three-sentence fix. None requires touching a proof.

## In plain language

The paper opens by promising it adds nothing to the machine-checked results and ends by joking that only the prose can be wrong. Both halves are right — which is the problem: the prose *is* wrong in nine identifiable places, all in the direction of making the chain sound stronger, and the places include the paper's three most-quoted claims (the always-finishing consensus, the megajoule accounting, the cosmological constant). The table above is the repair kit.

> **Disposition audit (second pass): ✅ closed as scoped.** All nine rows were verified applied at the anchors this table cites (rung 1 → paper:77; §1.5 → :118; the MJ rows → :92/:960/:964; §16 → :659; §15 → :635/:639; §21 → :886; §12 → :474/:488; §6 → :271; §19 → :820/:824). Four of the nine *claims* recur at anchors this table did not cite (rows 1, 4, 5, 6 — see the F1/F8/F9/F11 disposition blocks); the recurrence phenomenon is the second pass's F21.

# 20. "Everything open is physics" is not quite true (F19 ●)

## The hole

The v5 banner — "every mathematical sub-claim in the chain with a written proof is machine-checked, and everything that remains open is physics" — fails on at least two counts documented above, and the Section 26 ledger should grow accordingly:

1. **The λ-constancy step** (F8): written mathematics (in Jacobson 1995, the chain's own Layer-1 citation) consumed by the chain's Einstein-branch reading, neither formalized nor listed.
2. **The Route-A joint witness** (F2): the source core's own "open modeling task" — a single carrier carrying dynamics + HB + redundancy-boundary Hfib — is mathematics (a model-construction problem), still open, and absent from the open list (Section 26 lists only the stretch classification and stride conjecture as remaining mathematics).

Arguably also: the real-time KMS statement (F9) and the intermediate-slope screens (F6) — each a well-posed finite mathematical question the chain's claims presuppose or generalize over. None of these is deep; all are *mathematics*; each currently hides under a physics label or under silence.

## Where it bites

- `OPH_PROOF_CHAIN_PAPER.md:49` (the banner), `:982–1000` (§26 — the list these items are missing from), `:1008` (verdict 2: "What remains open is exactly the list of Section 26");
- `proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md:10, 345–350` (same banner, twice).

## What would close it

Add four rows to Section 26: λ-constancy (Bianchi/conservation, formalizable), the Route-A joint model, real-time KMS uniqueness (finite-dimensional, formalizable), intermediate-slope screens (decidable per instance). The banner then becomes true again — with a shorter reach and a cleaner conscience.

## In plain language

The proudest sentence in the project — "everything still open is physics, not mathematics" — was earned by hard work and is *almost* true. This audit found the mathematics hiding in the gaps: the missing "same constant everywhere" step of the gravity derivation, the never-built model where the correction dynamics and the holographic window coexist, the real-time version of the clock theorem, the moving-window cases. Small items, honest work for a v6 — but until then, the sentence needs the word "almost".

> **Disposition audit (second pass): ◑ the asterisk was added; the banners stand — one of them freshly rewritten.** Genuinely done: all four demanded rows exist (paper:1063 "Open mathematics"; chain §7 items 6–7), with F8's row already closed by T26; the §1.1 banner (paper:49) and CORE §8 item 2 (:694–699, "swept three times … carries its honest asterisk") are honestly reworded. **Surviving banners that contradict them:** CORE:10 — *rewritten by the v6.1 edit itself* — still ends "everything else open is physics", while the same document's §7 items 6–7 list the open mathematics; CORE:49–51 and :419–424 ("What remains is physics, exactly …"); CORE:731 (verdict item 5: "now purely physical", citing the §7 whose items 6–7 are mathematics); paper:1035 (§26 *opens* "Everything unproven in the chain is *physics*, listed here by name" — twenty-eight lines above its own Open-mathematics block); paper:1073 (verdict 2 kept the v5 "stress-tested twice / every written mathematical sub-claim is formalized" text its chain twin was corrected away from); paper:1079 (verdict 5: "purely physical"). The section that lists the open mathematics and the sentences that deny its existence now share a page.

---

# Part VI — The second pass (v6.1): how the fixes fared, and what else the audit found

*Everything in this part is anchored to commit `2ce895c` (proof-chain v6.1). Verification transcript in Appendix B2.*

# 21. Scorecard

| Finding | Grade | Disposition claimed (chain §11) | **Verified verdict** |
|---|---|---|---|
| F1 | ■ | fixed | ◑ fixed at both anchors; verdict re-lumps it (paper:1071) |
| F2 | ▲ | acknowledged + open-listed | ✳ correctly acknowledged; CORE's jewel block uncaveated; "witness quoted" overstates |
| F3 | ▲ | fixed | ✅ |
| F4 | ● | acknowledged | ✅ |
| F5 | ● | fixed | ✅ |
| F6 | ▲ | fixed wording + evidence added | ◑ wording fixed; "evidence" is an artifact-free claim (→ F22); DOC_B:181 leftover |
| F7 | ● | fixed | ✅ (all references verified) |
| F8 | ■ | **closed by theorem (T26)** | ✅ **verified closed** — rendering notes → F23; two overview leftovers |
| F9 | ▲ | "fixed wording everywhere" | ◑ fixed at cited anchors; **9+ survivals**; disposition row false |
| F10 | ▲ | "L0 named wherever consumed" | ◑ paper fixed; CORE/DOC_A consumption sites untouched; ≅ℤ₆ unassembled; disposition row false |
| F11 | ▲ | fixed wording | ◑ Why-block fixed; **the Statement block — F11's primary anchor — survives in bold** (paper:858, :865) |
| F12 | ● | fixed | ✅ |
| F13 | ● | fixed | ✅ |
| F14 | ● | fixed | ✅ |
| F15 | ■ | fixed at four named sites | ◑ all named sites verified fixed; RESULTS.md / formal README / theorem-site docstring recreate the old load path |
| F16 | ● | "added to both verdicts" | ◑ added, yes — but the flagged sentence stands (CORE:739–741), contradicting the addition |
| F17 | ● | fixed | ✅ |
| F18 | ■ | all nine applied | ✅ at the cited anchors (recurrences → F21) |
| F19 | ● | fixed | ◑ rows added; banners stand in 7 places, one freshly rewritten (CORE:10) |

**Net: 9 ✅ + F8 closed by theorem = 10 closed · 8 ◑ · 1 ✳ · 0 reopened.** No finding was closed *wrongly* in substance — every claimed theorem exists and says what is claimed — but eight were closed *incompletely*, and the incompleteness has a single shape, documented as F21.

# 22. A false "exactly" at Part II's front door (F20 ■)

## The hole

The sentence that frames all of Part II — "so consistency = being a valid trajectory, and an information set is **exactly** a boundary $B$ satisfying $H_{\mathrm{fib}}$ — Route A's hypothesis, now a concrete combinatorial question" (paper:418) — asserts a biconditional of which only one direction is true. $H_{\mathrm{fib}}$ (paper:226; the Lean binder in `Core/Primitives.lean:1164`) concludes **gauge-equivalence**, not equality; on the cylinder carrier the observable map reads the seed row only through `evolve` (`CarrierBridge.lean:137–138`), and `evolve` has nontrivial kernel for every `n`. So "boundary satisfying H_fib" is strictly weaker than "information set". **Machine-verified counterexample** (compiled against the tree during this audit): on `rule90Cylinder 3 1`, the row-1 readout satisfies the H_fib binder verbatim, yet its cell set is provably *not* an information set (kernel `decide`: the seeds `0` and `(1,1,1)` share the entire row-1 history — `evolve (1,1,1) = 0` on ℤ₃). Only "information set ⟹ H_fib (indeed with the stronger conclusion `x = y`)" holds — which is what `rule90Cylinder_Hfib_tube` actually proves, and what the paper itself says 22 lines later (paper:440: "with the *stronger* conclusion x = y") and concedes at paper:355 ("consistent records with *different seeds* can be gauge-equivalent").

Nothing downstream consumes the false direction — every screen theorem is stated and proven in information-set form. The defect is the framing sentence itself: it identifies the paper's combinatorial object with Route A's hypothesis, and the identification fails in exactly the direction that would matter if anyone ever used it.

## Where it bites

- `OPH_PROOF_CHAIN_PAPER.md:418` (the "exactly"); internally inconsistent with `:355` and `:440`;
- `CarrierBridge.lean:137–138` (`projSrc := fun _ s => evolve s` — the seed is only ever read through `evolve`);
- counterexample: `rule90Cylinder 3 1`, row-1 boundary (Appendix B2, item 6).

## What would close it

Replace "exactly" with the true direction plus the honest delta: *an information set gives a boundary satisfying H_fib with the stronger equality conclusion; the converse fails (gauge-equivalence tolerates kernel differences the information-set property forbids).* One sentence; the paper's own :440 already contains the key phrase.

## In plain language

The paper says the two notions — "this window determines everything" and "Route A's boundary condition" — are the same question in different clothes. They aren't: the machine accepts windows as Route-A boundaries that provably do *not* determine everything (they only determine everything *up to differences the office's bookkeeping happens not to record*). The gap is real, checkable, and checked — a three-bulb example settles it. None of the actual theorems lean on the false half; the advertising sentence does.

# 23. The fix was anchor-deep, and the disposition table misreports it (F21 ■)

## The hole

The v6.1 revision fixed the audited claims **at the lines this audit quoted** and, with few exceptions, nowhere else. The same claims survive verbatim (or hardened) at sites the first pass did not happen to cite — in four documents plus two Lean docstrings — and in five cases the §11 disposition table asserts a completeness the diff does not have:

| Row | Disposition says | Reality |
|---|---|---|
| F9 | "fixed wording **everywhere**" | 9+ surviving clock/dynamics sites, incl. the chain's own closing sentence (CORE:748) and the §15 Statement block (paper:609–613) |
| F10 | "L0 named **wherever the twelve ports are consumed**" | in the chain document L0 exists *only inside the disposition table*; every consumption site (T16 bullet, L2.6/L2.10 rows, §6 diagram, all hypothesis lists) and DOCUMENT A §1.4 still read "L1–L7" |
| F11 | "fixed wording" | the finding's **primary anchor** — the §21 Statement block, bold, theorem-labelled — survives (paper:858, :865); only the Why-block was fixed |
| F16 | "the honest sentence added to both verdicts" | added — and the precisely-flagged contradicting sentence retained (CORE:739–741) |
| F19 | "fixed — the banner now carries the asterisk" | the asterisk exists; the banner survives in 7 places, one of them (CORE:10) **rewritten by v6.1 itself and still false** |

The residue ledger (all verified verbatim at v6.1): **F9** — CORE:255, :260–263, :563, :645–646, :748–749; paper:87, :609, :610, :613; RESULTS:313; formal/README:55. **F10** — CORE:50, :167–174, :193–198, :424, :460, :462, :466, :555–557, :577, :632, :705; paper:10 vs :104/:1154 (the paper disagrees with itself about "L0–L7" vs "L1–L7"); DOC_A:144–149; RESULTS:171; `CenterZ6.lean:57–60`; the "≅ ℤ₆" prints at paper:709–711, CORE:171–172, formal/README:34 against a Lean `Equiv`. **F11** — CORE:203–204; paper:858, :865; RESULTS:285; `DeltaSBridge.lean:190`. **F15** — RESULTS:91–94; formal/README:23; `EnergyCage.lean:141–145`. **F16** — CORE:739–741. **F19** — CORE:10, :49–51, :419–424, :731; paper:1035, :1073, :1079. **F1** — paper:1071. **F8** — paper:88, :671. **F6** — DOC_B:181.

Two structural observations. First, the survivals are not random: they concentrate in the *summary layers* — overview rungs, statement blocks, diagrams, verdicts, the formal tree's own READMEs — i.e. exactly the layers a reader quotes. The corrected text lives in the commentary; the uncorrected text lives in the headlines. Second, the disposition table is itself part of the chain's documentation now, and it contains false completeness claims — the audit-response layer has reproduced the original disease: **the summary claims more than the work did.**

## Where it bites

- `proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md:874–893` (the §11 disposition table rows for F9, F10, F11, F16, F19);
- the residue ledger above (each line verified verbatim).

## What would close it

Mechanical, sentence-scale work: sweep the residue ledger (it is the complete todo list — every entry is a one-line edit already performed elsewhere in the same corpus), and reword the five table rows to what was actually done ("fixed at the audited anchors; recurrences pending" would have been honest and cheap). The deeper fix is procedural: a fix to a *claim* should be driven by grep, not by the auditor's quotation list.

## In plain language

The maintainers repaired every sentence the audit quoted — and left the same wrong sentences standing wherever the audit hadn't happened to point. It's the difference between fixing a leak and patching the spots on the ceiling the inspector circled. Worse, the repair log says "fixed everywhere" in five places where it demonstrably isn't — so the document that answers the audit now needs auditing. The repair list is above; every line is a one-sentence edit.

# 24. Computational evidence with no artifact (F22 ●)

## The hole

The v6/v6.1 revision introduces two claims of computational evidence, and the repository contains **no artifact for either** — no script, no table, no log, no Lean `decide` instance, no commit that ever contained one (verified by exhaustive search: the only executable in the repo is the schematic renderer):

1. "machine experiment at slopes 1/2, 1/3, 2/3, 1/4, 3/4 for all `n ≤ 20` finds decoding at exactly the same sharp threshold in every case" (paper:474; repeated at paper:1063 and CORE:657–660) — moreover the intermediate-slope *screen* is never defined anywhere (which cells does a slope-1/3 screen read?);
2. "The classification was confirmed computationally for all `n ≤ 28` and all strides before formalization (minimal decoding horizon `t* = ⌈n/2⌉ − 1` exactly at every coprime stride; no decoding up to `t = 80` at every non-coprime stride)" (`RESULTS.md:391–394`).

For a corpus whose brand is the receipt, "machine experiment" with no machine record is a regression — it is precisely the pattern this audit exists to catch (F17's `ProotReported` was flagged for entering as an unaccompanied literal; these claims are the same move at the evidence layer). **Both claims were therefore reproduced independently here, and both are true**: a 60-line 𝔽₂-rank checker (Appendix B2, item 5) confirms the stride claim exactly as stated for all `n ≤ 28`, and confirms the slope claim for all five slopes and all `n ≤ 20` **under the floor convention** (screen cells `{(i, ⌊s·i⌋), (i, ⌊s·i⌋+1)}`) — the convention the docs do not state.

## Where it bites

- `OPH_PROOF_CHAIN_PAPER.md:474, 1063`; `proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md:657–660`; `proof_chain/formal/RESULTS.md:391–394`;
- the absence: no matching artifact anywhere in the repository or its history.

## What would close it

Commit the checker (or this audit's reproduction — Appendix B2 carries the algorithm) next to the claims, define the slope screen it tests, and cite it. Or delete the evidential clauses and leave the conjecture bare — weaker but honest.

## In plain language

Twice, the new text says "we checked this by computer" — and the computer run is nowhere: no program, no output, not even a definition of one of the two things allegedly checked. This audit wrote the program, and the claims turn out to be true. But a project whose whole pitch is "every claim comes with a receipt" shouldn't make the reader write the receipt.

# 25. What T26's rendering imports (F23 ●)

## The hole

T26 is real and closes F8 (§9 above). Its *presentation* imports four things the honest-scope block does not fully carry:

1. **"The contracted Bianchi identity, geometry's identity" names a bare assumption.** In the continuum, `∇·G ≡ 0` is an identity *of Riemannian geometry* — free, guaranteed, not assumable-away. In `LambdaConstancy.lean` there is no metric field, no connection, and no curvature; `hdivF` is a hypothesis about an arbitrary matrix field's forward differences (`ddiv`, `:79–81`), and nothing exists for it to be an identity *of*. Calling it "geometry's identity" (paper:679) borrows the continuum's warrant for a discrete assumption that has none. (The module's own docstring is more careful — "the geometry/physics inputs" — and the paper's §26 row `:1063` says just "closed — T26" with no qualifier at all.)
2. **T26 is the flat-background shadow.** The λ-term multiplies one *globally constant* η; the paper's own proof note concedes the Leibniz step is "exact here" *because* η is constant (:681). In Jacobson's argument λ multiplies the varying metric g and exactness comes from metric-compatibility `∇g = 0`. The distance between the two is precisely the distance between "algebraic shadow" and "the step in the theorem" — fine to bridge, worth one sentence.
3. **"Connected chart" overstates.** The Lean hypothesis is directed root-reachability (`∀ q, Reachable step p₀ q`, `:188–189`, with `Reachable` the reflexive-transitive closure of *forward* steps). A ℤⁿ-style chart with forward successor maps is connected but not root-reachable from any base point, so the theorem as formalized does not cover it (trivially fixable — step-invariance is an equality, so it transports both ways — but not proven). §16a's own Statement is accurate ("every point step-reachable from a base point"); the two "connected chart" glosses (paper:659, :681) are not.
4. **Convention hybridity.** `ddiv` is the *unweighted* `∑ᵢ ∂ᵢM(i,j)` — the faithful shadow of `∂_μ M^μ{}_ν` in the mixed-index reading — while the decomposition `F = κT + λη` is written in the lower-lower reading (whose honest flat divergence carries `η^{ii}` weights). The conclusion is robust (verified by hand: the η-weighted variant forces the same constancy), so this is cosmetic; and the universality of κ across points is part of the hypothesis (visible in the statement, not hidden — noted for completeness).

## Where it bites

- `OPH_PROOF_CHAIN_PAPER.md:679` ("the contracted Bianchi identity, geometry's identity"), `:659, :681` ("connected chart"), `:1063` (the unqualified "closed");
- `LambdaConstancy.lean:79–81` (`ddiv`), `:84` (`Reachable`), `:128` (constant η in `hpoint`).

## What would close it

Three sentences in §16a and one clause in §26's row: the divergence conditions are *assumptions about the discrete fields* whose continuum counterparts are an identity (Bianchi) and a law (conservation); the chart is flat (constant η) and the continuum statement remains with the D-branch physics; "connected" means root-reachable. Optionally: generalize `Reachable` to the symmetric closure (one lemma).

## In plain language

The new cosmological-constant theorem is real, but its packaging borrows two words it hasn't paid for: it calls one of its assumptions an "identity" (in real geometry that step is free; in this model it's an assumption like any other), and it says "connected" where the machine actually requires "reachable by forward steps from a base camp" — a stronger condition. Neither changes the theorem; both change what a reader thinks was proven.

# 26. The Gauss–Bonnet clause has no surface (F24 ●)

## The hole

T16's twelve-port count is presented as surface theory: "For **any all-triangle combinatorial closed surface** with Euler characteristic 2 — vertex/edge/face counts $V − E + F = 2$, $3F = 2E$, handshake $\sum_v \deg v = 2E$ — the total defect is … 12" (paper:800), echoed as "combinatorial Gauss–Bonnet" (chain §6) and "the soccer-ball theorem of surface geometry" (paper:824). What `sphere_defect_count` (`CollarGate.lean:203–219`) actually takes: **three bare naturals `V E F : ℕ` and an arbitrary function `deg : Fin V → ℕ`**, with the three equations as hypotheses. There is no simplicial or CW structure, no incidence relation, no faces, no surface — `deg` is tied to nothing. The genuinely surface-theoretic content — that a closed all-triangle surface *satisfies* `3F = 2E` and the handshake identity — is consumed informally; what is machine-checked is the arithmetic consequence `∑(6 − deg v) = 12` of three assumed equations. The quantifier "any … closed surface" describes structure the formal object does not have. (Distinct from F10, which priced the *postulate* that the collar is such a surface; this finding is about the theorem's own advertised type. The first pass graded the clause "correct, but consuming the degree-{5,6} sphere postulate" — it did not notice there are no surfaces in it at all.)

## Where it bites

- `OPH_PROOF_CHAIN_PAPER.md:800` ("any all-triangle combinatorial closed surface"), `:824` ("the soccer-ball theorem of surface geometry");
- `proof_chain/OPH_CORE_MINIMAL_PROOF_CHAIN.md:555–557` ("twelve ports from combinatorial Gauss–Bonnet");
- `CollarGate.lean:203–219` (`sphere_defect_count` — arithmetic on bare `(V, E, F, deg)`).

## What would close it

Either the honest clause ("for any numbers V, E, F and degree list satisfying the three Euler/triangle/handshake identities — which every all-triangle closed surface does, a fact consumed informally — the defect sum is 12"), or the small formalization: a `SimplicialSurface` structure whose closed-all-triangle instances *prove* the two combinatorial identities, from which the current lemma follows. Mathlib has the pieces.

## In plain language

The "twelve pentagons like a soccer ball" step is advertised as a theorem about surfaces. The machine-checked statement never sees a surface: it's told "here are three numbers and a list satisfying these three equations" and does the arithmetic. That every soccer-ball-like surface satisfies those equations is true — and is exactly the part taken on faith. The arithmetic is checked; the geometry in the sentence is decoration.

# 27. "No schedule of moves and switches beats the toggle ledger" is proven for one schedule (F25 ●)

## The hole

The cage's summary slogan — "No schedule of moves and switches beats the toggle ledger" (paper:943; `EnergyCage.lean:20–21`) — quantifies over arbitrary schedules. The Lean covers exactly one: the two-position, four-stroke ABBA cycle (`cycleWork`, `EnergyCage.lean:72–73`, is *defined* as that cycle's work; the three theorems are about it). Multi-position tours, repeated toggles, and mixed schedules are not formalized — the natural generalization (telescoping: any closed tour's work is a signed sum of toggle costs) is easy and absent. A first-pass miss (the slogan predates v6), surfaced by the second pass's theorem-site reading.

## Where it bites

- `OPH_PROOF_CHAIN_PAPER.md:943`; `EnergyCage.lean:20–21, 72–73` (definition scope vs slogan scope).

## What would close it

One lemma (closed tours over finitely many positions; work = Σ ± toggle costs at visited positions; the same ledger bound follows), or the scoped sentence ("no ABBA cycle beats the toggle ledger; general tours follow by telescoping, unformalized").

## In plain language

"No possible sequence of moves and switch-flips beats the energy books" is the claim; the machine checked the simplest possible loop — up, flip, down, flip. Every longer trip almost certainly reduces to that one by routine bookkeeping, but "almost certainly by routine bookkeeping" is a category this project invented named hypotheses to avoid.

# 28. The disposition embeds new unformalized mathematics as fact (F26 ●)

## The hole

The F1/F2 fixes import, as flat assertions, mathematics that is not in the tree: rung 1's "on some carriers (the width-3 Rule-90 toy, provably — **and its cylinder big brother**) *no* operator can satisfy all three local laws" (paper:77), and the §11 scope note's "the width-3 in-tree theorem generalizes: `evolve` is not surjective, so some next-rows are unfixable, and T12's canonical operator can terminate on inconsistent records" (paper:462). Both claims are **true** — re-derived during this audit (the constant-1 row lies in `ker(evolve)` for every `n`, so `evolve` is never surjective; the stall witness is F2's) — but neither is formalized, and neither appears on the §26 open list. By the chain's own banner standard ("every mathematical sub-claim with a written proof is machine-checked"), the repair of F1/F2 created a new F19-class debt: written mathematics, consumed in a load-bearing scope note, formalizable in an afternoon (`evolve_not_surjective` is a three-line lemma; the stall witness is a `decide` on `rule90Cylinder 3 2`).

## Where it bites

- `OPH_PROOF_CHAIN_PAPER.md:77, 462`; absent from `:1063` (the open-mathematics list).

## What would close it

Formalize the two small lemmas (constant row ∈ `ker evolve` ⇒ non-surjectivity ⇒ the H1–H3 kill on `rule90Cylinder n t`; the `(0, δ₀, δ₁)` stall as a `decide`), or add one row to the open list ("cylinder no-repair + stall witness: checkable by hand, unformalized").

## In plain language

To describe honestly why the correction dynamics can't run in the showcase office, the fix states two mathematical facts — true ones — that the machine has never checked. In this project, that's supposed to be either a theorem or a labelled IOU. Right now it's neither: it's the old habit, recycled inside the apology for the old habit.

# 29. Three slips in the new v6 prose (F27 ●)

## The hole

The v6 additions carry three self-contained misstatements, all minor, all in explanation layers:

1. **The §13a "kaleidoscope" dichotomy is false on even loops** (paper:558): "they shove the pattern around the loop in hops of twice the separation. If those hops visit every bulb — the no-common-factor case — the pattern is trapped". Hops of `2g` visit every bulb iff `gcd(2g, n) = 1` — false for **every even n**, including the module's own kernel-checked showcase `(n, g) = (8, 3)`, where the hops visit half the bulbs and decoding nevertheless succeeds. The Proof block (paper:550) has the correct two-class mechanism; the plain-language equivalence is wrong.
2. **The hexacode self-duality sketch justifies the reduction with the wrong reason** (paper:582): "(iv) A kernel-`decide` over the 64 × 64 message pairs (the Hermitian form is bi-additive, so message-level suffices)". In `HexacodePort.lean:576–580` the reduction is by `rintro ⟨a, rfl⟩` — codewords are *by definition* encoder images, so checking message pairs *is* checking codeword pairs; bi-additivity is never used (and alone would license a 3×3 generator check, which is not what the Lean does).
3. **"The port closes the source file's own open list" is 2/3 true** (paper:568): the ported file's list (`HexacodePort.lean:119–128`) has three items; minimum distance and self-duality are closed, the hexacode→K₁₂ construction is expressly declared out of scope (`:594–596`), not closed. The section's own Why-block has the honest scoping ("every claim that file makes *about the hexacode*"); the Statement-block sentence doesn't.

## Where it bites

- `OPH_PROOF_CHAIN_PAPER.md:558, 568, 582`; `HexacodePort.lean:119–128, 576–580, 594–596`; `Rule90Stride.lean:599` (the (8,3,3) instance that falsifies the kaleidoscope sentence).

## What would close it

Three one-sentence edits: (1) "…the hops trap the even-displacement half, and the second bulb's mirror traps the other half" (the Proof block's own mechanism); (2) "codewords are encoder images by definition, so message pairs suffice"; (3) "closes the two hexacode-internal items of the source file's open list".

## In plain language

Three small slips of the pen in the newest chapters: a children's-version explanation that contradicts the theorem's own showcase example, a proof sketch that gives a clever-sounding but wrong reason for a step the machine does for a boring reason, and a "closed their whole todo list" that closed two items of three.

# 30. Version bookkeeping: headers that contradict their bodies (F28 ●)

## The hole

The v6.1 pass left the corpus's version metadata inconsistent with its content — mostly trivia, but one instance touches the pre-registration discipline:

1. **Stale counts:** CORE:57–58 "(v6: 25 modules, 198 axiom-audited declarations)" and paper:1071 "One tree, 25 modules, 198 audited declarations" — the true v6.1 numbers are 26/205 (verified by count; both files' own headers say so); DOC_B:21 and :174 say "20 modules, 132" (two campaigns stale); paper:596's Part III module list omits `LambdaConstancy.lean`; paper:1161 signs off "as an expository companion to proof-chain **v5**"; `formal/README.md:5–6` stops at v6 while listing the `[formal-v6.1]` module; CORE §§2/4/6 still carry "(v4)" headers over v6/v6.1 content.
2. **The pre-registration ledgers changed without version entries.** DOCUMENT A's §1.9 was rewritten (G10-convention restructure) and its printed battery ceiling corrected ("≲ 1×10⁻¹¹ (≈ 0.5 gf)" → "≲ 1.1×10⁻¹¹ (≈ 0.58 gf)") — both properly disclosed *in place* (a dated erratum note) — but the change log (DOC_A:26–31) still ends at v0.2.2 with the standing claim "**No number, threshold, disclosure or decision-rule text changed**," which now describes the document falsely; DOC_B:8 and DOC_C:8 likewise carry pre-v6.1 version rows over bodies with v6.1 content. For ledgers whose epistemic function is "fixed before data," silent in-place revision — however honest each individual note — is the one bookkeeping failure that matters.
3. **Stale open-item claims:** DOC_B:205–208 still lists "the odd-n gapped-screen threshold" as a successor target and says `Rule90Decoding.lean` "leaves both honestly open" — closed by T20 in v5 and re-proved by T25 in v6.

## Where it bites

- Counts/versions: CORE:57–58; paper:596, :1071, :1161; DOC_B:21, :174, :205–208; `formal/README.md:5–6`; CORE:453, :455, :517.
- Ledger changelogs: `test/DOCUMENT_A_prediction_ledger.md:26–31` (vs its §1.9), DOC_B:8, DOC_C:8.

## What would close it

A version-bump pass: one changelog entry per ledger ("v0.2.3: G10-convention naming per holes-audit F15; battery-ceiling erratum, see §1.9"), and the six count/label corrections.

## In plain language

The documents' cover pages say things their insides no longer do — "25 modules" over 26, "nothing changed" over a corrected number, "v5" under v6.1 content, "still open" over a problem solved twice. Each is one line to fix; the one that matters is the pre-registered experiment ledger, whose whole point is that changes get logged on the cover, not just in the margins.

# 31. Statement-precision nanos (F29 ●)

Collected small findings; none load-bearing, all one-line fixes. **(i)** T25's doc statement blocks omit the (necessary, doc-implied) `[NeZero n]` side condition. **(ii)** "its failure kernel is **exactly** the mirror-symmetric seeds with dark centre" (`Rule90Stride.lean:186–188`, repeated in the paper §13a and RESULTS §20): the forward inclusion is the mirror lemma; the converse is assemblable from in-file lemmas (`evolve_symmetric`, `evolve_symmetric_center`) but is not a named theorem. **(iii)** RESULTS §20 lists "nonzero" among `mirrorPair`'s named-lemma properties; it is proved inline in the lift (`Rule90Stride.lean:495–502`), not a named lemma. **(iv)** The docs' "δ₊₁ + δ₋₁" is shorthand: the Lean `mirrorPair` (`:391–392`) is the *union indicator* — the literal 𝔽₂ sum would be the zero seed at `d = 2` and the failure half would break; the Lean choice is correct, the formula is a reader trap. **(v)** `edgeRepairable_strictly_weaker` (`RepairHypotheses.lean:75–77`) is a conjunction at the named carrier; the class-inclusion properness in the docs is a one-meta-step gloss (both halves exist in Lean; the packaged statement doesn't). **(vi)** The T6-addendum separation ("H_B ∧ H_↓ ∧ H_comp ⇏ H_◇") is assembled in prose from three theorems; `H_B`-vacuity is argued (honestly, and correctly — a nontrivial boundary would be *violated*) in a docstring (`QuotientRepair.lean:512–515`), not formalized. **(vii)** `battery_coupon_bounds` (`LedgerNumerics.lean:134–138`) is conditional on a `Φ` interval proven in `EnergyCage.lean` from slightly different G values (both inside the interval — absorbed, uncomposed); the gf rendering "0.575 to 0.578 gf" (paper:984, DOC_A) corresponds to the in-proof force bracket, not the certified Δν interval it is displayed as converting (safe direction; and the adjacent "~3 %" is 2.5 % by recomputation). **(viii)** "real in the **8th** digit" (paper:907, :917) — the χ branch gap `1.51×10⁻⁷` sits in the **7th** decimal place by the paper's own digit-counting convention. **(ix)** "a one-parameter group in imaginary time" (paper:610) for an ℕ-indexed iterate — also listed under F9's residues, recorded here as the statement-block instance.

---

# 32. Verdict

## First pass (v5)

Strip this audit to what a maintainer of the chain should act on and five things remain:

1. **The formal layer is exactly as advertised — verified independently here.** Build clean, axioms standard over all 838 declarations, statements faithful. Nothing in this document disputes a single Lean theorem, and several results (T20's parity classification; T11's forensics; T23's boundary catch) are genuinely good work. The chain's *method* survives its own audit.

2. **The chain's most-quoted physical number is not theorem-grade (F15).** The 3.5 MJ per-toggle ledger — pivot of the DETECT self-refutation rule and the battery discrimination — is a zero-point convention seven orders above what the cycle theorems force and nine below the relativistic reading. This is the audit's most consequential finding because the chain markets exactly this number as "the accounting is airtight". The repair is honest re-derivation, not deletion: name the convention, state the two theorem-grade anchors, rewrite the decision rule.

3. **Two structural compositions the narrative relies on are never made (F2, F11), and one mathematical step is missing where the paper claims completeness (F8).** Consensus dynamics and the holographic screen never run on the same carrier — and provably cannot, in the local-repair reading, on the carrier exhibited; the record-counter and the collar-counter are identified by prose alone; the pointwise λ is called the cosmological constant one Bianchi identity too early. Each is fixable: a model, a bridge structure, a small formalization — worthy v6 targets that would *strengthen* the program.

4. **The conditional tower's advertised uniformity hides heterogeneous informativeness (F10, F12, F14).** Some named hypotheses buy forcing theorems (MAR → T13); others buy their own restatement (SEE → P4; unbiasedness → `uniform_gate`); the 24-bookkeeping is arithmetic decoration on an unnamed geometric postulate; the dark-sector law is the literature's fitting function with a proposed mechanism. Grading the payoffs would cost a column in one table.

5. **The exposition needs an erratum pass (F18's nine-row table), and Section 26 needs four new rows (F19).** All fixes are sentence-scale. The paper's own closing joke — "the theorems don't have any [errors]" — is confirmed; the necessary correction is that the sentences *between* the theorems carry the program's boldest claims, and nine of them currently claim more than the machine checked.

## Second pass (v6.1)

Four things, for the maintainer of v7:

1. **The adoption was real where it was hardest.** F8 — the first pass's sharpest mathematical demand — was closed by an actual theorem, correctly wired into the tree, with an honest scope block and a counterexample for its one structural clause. T25 settled the stride conjecture in sharper form than conjectured, faithfully. F15 — the most consequential finding — was renamed, re-anchored, and rewritten at every site its disposition names, down to the test ledgers. Where the chain chose to do the work, the work is good, and this pass verified all of it independently (build, axioms over both namespaces, every number, every new statement).

2. **Where the chain chose to reword, it patched anchors, not claims (F21).** Eight findings are closed-with-residue for one reason: the fix was applied at the quoted line and the same claim survives at unquoted lines — concentrated, uncomfortably, in the headline layers (overview rungs, Statement blocks, diagrams, verdicts, the formal tree's READMEs). Five disposition rows assert completeness the diff does not have; one banner was rewritten *by the fix itself* and is still false (CORE:10). The residue ledger in F21 is the complete, mechanical todo list.

3. **The second pass found what the first missed.** A machine-refutably false "exactly" at the sentence framing all of Part II (F20 — counterexample compiled against the tree); a Gauss–Bonnet clause with no surfaces in it (F24); a cage slogan proven for one schedule (F25); and the two new theorems' renderings borrowing words — "identity", "connected", "surface" — their formal objects have not paid for (F23, F24). None of these reopens a closed finding; all of them are the same species the chain now knows how to fix.

4. **The evidence discipline slipped exactly once, twice (F22, F28).** Two "machine-checked it" claims with no machine record — both true, both reproduced here, neither reproducible from the repo — and a pre-registration ledger whose cover still certifies "no number changed" over an erratum-corrected body. For this project those are not typos; they are the brand.

**In plain language, finally.** The maintainers did the honorable thing: they took a hostile audit, adopted it, proved the hardest missing theorem, renamed their headline convention, and wrote the corrections into their pre-registered ledgers. This pass checked all of it, and the substance holds. What didn't hold is the sweep: the same overclaims the audit quoted were fixed *where quoted* and left standing where not — in the summaries, statement blocks, and closing sentences readers actually quote — and the repair log itself says "everywhere" about fixes that were applied somewhere. The chain's oldest lesson keeps applying to whoever last edited it: the theorems are fine; the sentences summarizing the sentences about the theorems are where the physics leaks in. The todo list is finite, mechanical, and printed above — and this time, the receipts for every claim in it are attached.

---

# Appendix A. Finding → anchor map (first pass, v5 anchors)

| Finding | Grade | Chain anchor(s) | Formal anchor(s) | Disposition (verified) |
|---|---|---|---|---|
| F1 rung-1 misstatement | ■ | paper `:76`, `:117` | `Core/Primitives.lean:747–753, 841`; `Core/Rule90.lean:212` | ◑ |
| F2 Route A never assembled | ▲ | paper `:82`, `:119`, `:459`; CORE_MINIMAL `:126–143` | `Core/Rule90.lean:59–72, 212`; `Core/Primitives.lean:1186–1190`; `CarrierBridge.lean:127–224`; stall witness on `rule90Cylinder 3 2` from `(0, δ₀, δ₁)` (checkable by hand; not in tree) | ✳ |
| F3 hidden choice function | ▲ | paper `:270` | `Core/Primitives.lean:274, 321–322` | ✅ |
| F4 declared-order regress | ● | paper `:82, :312, :1016` | `QuotientRepair.lean:109–111`; `Core/Primitives.lean:292–296` | ✅ |
| F5 fence triviality | ● | paper `:326–338` | `NotEinsteinComplete.lean:144–162` | ✅ |
| F6 boost invariance = 2 slopes | ▲ | paper `:471, :485`; CORE_MINIMAL `:206–215` | `Rule90Decoding.lean:224–236, 326–350` | ◑ |
| F7 prior art / no bibliography | ● | paper `:399, :459` | (absence; cf. Hedlund; Boyle–Lind 1997; Kůrka) | ✅ |
| F8 λ constancy missing | ■ | paper `:618–638`; CORE_MINIMAL `:176–182`; missing from §26 | `EinsteinBranch.lean:374–396` (pointwise `∃ lam`) | ✅ **T26** |
| F9 imaginary-time "clock" | ▲ | paper `:571–578, :598, :602`; CORE_MINIMAL `:246–267` | `ModularCore.lean:59–70, 150–160, 209–227` | ◑ |
| F10 24-bookkeeping | ▲ | paper `:747–757, :773, :777`; CORE_MINIMAL `:193–198` | `CollarGate.lean:118–126, 181–189, 203–249`; `CenterZ6.lean:341–366` | ◑ |
| F11 "same counter" | ▲ | paper `:818, :839`; CORE_MINIMAL `:200–204` | `DeltaSBridge.lean:102–105, 194–199` (no cross-import) | ◑ |
| F12 SEE flatness | ● | paper `:109, :785–801` | `ScalarResponse.lean:48–64` | ✅ |
| F13 hypercharge inputs | ● | paper `:654–658, :678–682` | `Hypercharge.lean:129–135` (normalization) | ✅ |
| F14 dark sector | ● | paper `:688–733` | `DarkSector.lean` (scalar-only); `oph_dark_matter_paper.tex:92, 519, 762, 2304–2338`; MLS16 RAR fit | ✅ |
| F15 MJ convention | ■ | paper `:91, :897–898, :911, :915, :933`; CORE_MINIMAL `:406–421, :522`; DOC A `:275–284` | `EnergyCage.lean:63–103` vs `:137–153`; `LedgerNumerics.lean:126–155` | ◑ |
| F16 experiment yield | ● | paper `:825, :1010, :1016`; CORE_MINIMAL `:600–602` | (composition of chain's own concessions) | ◑ |
| F17 two-P residue | ● | CORE_MINIMAL `:387`; paper `:777, :849–874` | `PBranches.lean:57–59` (literal) | ✅ |
| F18 erratum list | ■ | paper `:9–10, :1080` + table in §19 above | — | ✅ |
| F19 "all open is physics" | ● | paper `:49, :982–1000, :1008`; CORE_MINIMAL `:10, :345–350` | — | ◑ |

Second-pass findings F20–F29 carry their anchors inline (Part VI); all are v6.1 anchors.

# Appendix B. Verification transcripts

## B1. First pass — performed 2026-07-07 against commit `b8a31c7` ("add expository paper that covers the full chain")

1. **Isolation.** `proof_chain/formal/` (7.1 GB incl. `.lake`) cloned via APFS copy-on-write to a scratch directory; the working tree's uncommitted edits (`OPHProofChain.lean` modification, untracked `Rule90Stride.lean` — a concurrent v6 session) were excluded by restoring `git show HEAD:…/OPHProofChain.lean` and deleting the untracked module. The live repository was not touched.
2. **Build.** `lake build` on the clone: **success, 8272 jobs, 0 errors, 0 warnings.** All `#print axioms` outputs emitted during replay list at most `[propext, Classical.choice, Quot.sound]` (one — `quorum_overlap_gap` — needs only `[propext, Quot.sound]`).
3. **Exhaustive axiom sweep.** A `Lean.collectAxioms` pass over every theorem/def in the OPH namespaces (an `AxiomSweep.lean` added to the clone): **838 declarations checked; 0 with non-standard axioms; 0 `sorryAx`; 0 `ofReduceBool` (no `native_decide`).** This is strictly stronger than the tree's self-audit of 172 declarations.
4. **Source hygiene grep.** No `sorry`/`admit`/`axiom `/`native_decide`/`unsafe`/`partial def`/`implemented_by` tokens outside comments and docstrings in any of the 23 modules.
5. **Statement-level cross-check.** Every module read in full (≈ 8,000 lines); each paper Statement block compared against the corresponding Lean declaration; mismatches found are exactly those documented as findings above — none affect the *truth* of a Lean theorem.
6. **Toolchain.** `leanprover/lean4:v4.29.1`, Mathlib pinned `v4.29.1`, as declared.
7. **Concurrency note.** Between the audit reads and publication of this document, the working tree advanced toward **v6**; each delta was inspected; none repairs a finding of this document (the `RepairHypotheses` delta is discussed inside F2). The v6 additions were **not** re-verified by build/axiom sweep in this pass.

## B2. Second pass — performed 2026-07-07 against commit `2ce895c` ("proof chain v6.1: adopt the adversarial audit")

1. **Isolation.** The full `chi_nu_test` tree (7.1 GB) cloned via APFS copy-on-write to a scratch directory at HEAD = `2ce895c` (working tree clean); all reads, builds, probes, and compilations ran on the clone. A concurrent session editing the live tree was never touched.
2. **Build.** `lake build` replay on the clone: **success, 8275 jobs, 0 errors**; emitted `#print axioms` lines standard-trio-only.
3. **Axiom sweep, both namespaces.** Environment-level `collectAxioms` over every theorem/def declaration: `OPHProofChain.*` — 663 declarations; `OPH.*` (the attributed core plus `RepairHypotheses`) — 172 declarations; **835 total, 0 non-standard axioms, 0 `sorryAx`, 0 `ofReduceBool`.** (An initial sweep filtered on the `OPHProofChain` root only and silently missed the `OPH.*` namespace — recorded here because tooling that greps one namespace is exactly the kind of hole this document hunts; the corrected sweep is the citable one.) The headline "205 axiom-audited declarations across 26 modules" verified by direct count of `#print axioms` lines.
4. **New-module verification.** `LambdaConstancy.lean` (T26), `Rule90Stride.lean` (T25), `RepairHypotheses.lean`, and the `QuotientRepair`/`EnergyCage`/`LedgerNumerics` deltas read line-by-line against every documentation claim (statement forms, quantifiers, side conditions, `decide` instances, docstrings); results in §1.1 items 3–5 and findings F23, F25, F29. `symmetricPair_normalForm_iff`'s axiom-freeness verified by two independent `#print axioms` probes.
5. **Independent reproduction of the artifact-free computational claims (F22).** Method: over 𝔽₂, cell `(i, j)` of the Rule-90 trajectory is a linear functional of the seed; represent each functional as an `n`-bit mask via `M₀(j) = e_j`, `M_{i+1}(j) = M_i(j−1) ⊕ M_i(j+1)`; a screen is an information set iff its cells' masks have rank `n`. Results: **strides** — for every `2 ≤ n ≤ 28` and every `0 ≤ g < n`: coprime strides decode at exactly `t* = ⌈n/2⌉ − 1` and fail at `t* − 1`; non-coprime strides fail at `t = 80`. **Slopes** — for every `2 ≤ n ≤ 20` and `s ∈ {1/2, 1/3, 2/3, 1/4, 3/4}` with screen cells `{(i, ⌊s·i⌋), (i, ⌊s·i⌋+1)}`, `0 ≤ i ≤ t`: decoding at exactly `t*`, failure at `t* − 1`. Both doc claims true as stated (the slope-screen convention being this audit's floor-convention guess, since the docs define none).
6. **F20 counterexample.** A Lean probe compiled against the tree's own oleans: on `rule90Cylinder 3 1`, the row-1 readout satisfies the `H_fib` binder of `boundary_fiber_observer_unique` verbatim (proved), while its cell set fails `IsInformationSet` (kernel `decide`; the kernel pair is the zero seed and `(1,1,1)`).
7. **Statement-level cross-check, second iteration.** Every Statement block of the current paper re-checked against the current Lean by two independent readers (Parts I–II; Parts III–V with 60-digit recomputation of every printed constant); every claimed disposition grepped at its anchor and for recurrences across all eight documents. The mismatch list is exactly Part VI.
8. **Toolchain.** As B1 (`leanprover/lean4:v4.29.1`, Mathlib pinned, cached build).
9. **Concurrency note.** Between this pass's snapshot and its publication, the working tree advanced again: an in-flight, untracked `RouteA.lean` appeared, whose header claims **T27 — Route A assembled** (local decode *transactions* on the Rule-90 cylinder with a declared, billed roster; `H_B` preservation; termination; observer uniqueness with literal equality; **and** formalizations of both negatives — the cylinder H1∧H2∧H3 impossibility and the T12 stall). That is precisely F2's "what would close it" option (a) plus F26's demanded lemmas. It was **not** verified by this pass (it postdates the audit target `2ce895c` and was still being edited); if it lands as described, F2's disposition upgrades from ✳ to closed-by-theorem and F26 largely closes — a third pass should verify it the way this pass verified T26.

---

*Written 2026-07-07 as an adversarial audit companion to proof-chain v5 and its expository paper; **second pass added the same day** against v6.1 after the chain adopted the audit. The grading discipline, the four-block format, and the honesty standard applied here are the chain's own — turned around, twice. Where this document errs, the error is its author's; the findings are stated so that each can be refuted by a single theorem, a single quotation, or a single build log, and the author would welcome all three.*
