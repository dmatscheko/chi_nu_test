# What surfaced while building the OPH simulation

*Notes from implementing and testing `oph_sim/` against `chi_nu_test/OPH_PROOF_CHAIN_PAPER.md`, 2026-07-07.*

**Status of everything in this document.** The simulation is an independent
re-implementation of the chain's discrete mathematics in JavaScript (bitmask 𝔽₂ linear
algebra, exhaustive enumeration, floating point only where the objects are real-valued).
Nothing here is Lean-checked. Each item is graded: **[replication]** = an independent
computation agreeing with a machine-checked theorem; **[observation]** = an empirical
finding from sweeps, true of the code as implemented; **[argument]** = an elementary
proof sketch written here, not in the chain; **[doc]** = an observation about the
paper's text, not its mathematics. Where an item might be worth feeding back into the
corpus, it says so — subject to the corpus's own verification discipline.

---

## Part I — What surfaced in the first iteration

### 1. The decoder was accidentally stronger than the paper's sweeps — and that exposed a real distinction **[observation → argument]**

The simulation's decoder is *local constraint propagation*: the Rule-90 constraint
`traj(i+1, j) = traj(i, j−1) ⊕ traj(i, j+1)` couples three cells; whenever two are
known, infer the third, in any direction, until fixpoint.

This is strictly stronger than the one-directional sweeps used in the proofs of
T9/T20. First consequence, caught during testing: my first caption claimed the gap-2
screen "provably cannot finish locally" (echoing T20's *"the fans can never reach time
0 — the seed dies by algebra"*). **The claim was false for the propagation decoder**:
on odd rings at threshold, propagation *completed*, seed row included.

Why: T20's proof-final "global" step — `ev(z) = 0` forces `z` constant along the
distance-2 walk — turns out to be *locally realizable*. The screen's columns bracket
the middle column (times ≥ 1); the fans supply row-1 cells sideways; and then the seed
row fills in by repeated local inferences that hop `j → j+2` around the ring, each hop
consuming one fan-supplied row-1 cell. The sharp threshold `n ≤ 2(t+1)` supplies
exactly the horizon budget the crawl needs. So the T20 proof structure
(middle column → fans → global algebra) is *one* decoding strategy; the full local
closure is another, and for gap 2 the local closure already suffices.

The corrected caption matters beyond cosmetics, because of what the next scan found.

### 2. The stall scan: local decodability has a phase boundary in stride **[observation]**

Sweep: all `n ∈ [3,20]`, strides `g ∈ [1,6]`, horizons `t ∈ [0,12]`, plus lightlike
screens — asking for configs where the screen **is** an information set (𝔽₂ rank = n)
but local propagation **stalls**.

Result: **212 such configs**, and every one has stride of ring-distance ≥ 3
(first witnesses: `n=7, g=3, t=3` with 20 cells stranded; `n=8, g=3, t=3` with 24;
also `g=4, 5` families). No adjacent, gap-2, or lightlike config stalled — in the
scanned range those always complete locally when the rank is full.

The extreme case is the sharpest exhibit in the whole simulation:
**`n=8, g=3, t=3`** — exactly at threshold (8 = 2·4), gcd(3,8) = 1, rank **8/8**,
T25 certifies unique reconstruction… and local propagation infers
**zero cells, ever**. The entire bulk is determined and none of it is locally
derivable. In the UI those cells render violet: *pinned by global algebra*.

### 3. Why the boundary sits at ring-distance 3 **[argument — two lines, not in the chain]**

The constraint's three cells occupy three *consecutive* columns `{j−1, j, j+1}` —
at most one cell per column. So a single constraint can touch **both** screen columns
iff their ring-distance `d(g, n) = min(g mod n, n − g mod n)` is ≤ 2:

- `d = 1` (adjacent): constraints spanning both columns drive T9's sideways sweep.
- `d = 2` (gap): the columns bracket a middle cell — T20's squeeze — and the crawl
  of item 1 finishes the job.
- `d ≥ 3`: **no constraint contains two screen cells.** Every constraint starts with
  at most one known cell, so the known set can never grow: local propagation infers
  *nothing*, unconditionally, at every horizon. Each column in isolation is a width-1
  screen, and a lone column never feeds a constraint two knowns.

So T25's coprimality classification lives, computationally, in two regimes: for
`d ≤ 2` the information set is locally decodable; for `d ≥ 3` determination is a
purely global fact — the mirror lemma's two reflections composing to a translation —
with literally zero local footholds. The paper proves the *information-set*
classification; the simulation surfaced that the *decoding-complexity* classification
underneath it is different, and cleanly split.

**Possible feedback to the corpus:** the `d ≥ 3` half is a two-line lemma
("the propagation closure of a distance-≥3 two-column screen is the screen itself")
and would formalize in an afternoon; the `d ≤ 2` half ("closure = everything, at the
sharp threshold") is the constructive content of the T9/T20 proofs read as algorithms.
Together they would make the violet/green split in the simulation a theorem.

### 4. Ghost seeds came out physically meaningful for free **[observation]**

The ghosts are computed as 𝔽₂ nullspace basis vectors of the readout map — pure
algebra, no geometric input. Yet the algebra kept handing back causal stories:

- At `n=12, t=4` (below threshold), the kernel basis vector was `δ₆` — a single pulse
  at the cell **antipodal to the screen**, whose light cone cannot reach either screen
  column within the horizon. The kernel *is* the causal shadow, and the readout-rank
  deficit counts exactly the cells the sideways light cones cannot cover.
- On even rings with the gap-2 screen, the generic nullspace element is T18b's
  alternating checkerboard — the ghost that additionally dies after one tick
  (`ev(z_alt) = 0`), so the bulk display shows one glowing bottom row and darkness
  above: never visible on the screen, and gone from the world after one step anyway.

### 5. The verification sweeps — what they establish and what they don't **[replication]**

Iteration-1 sweep, 1,536 configs (`n ∈ [3,18]`, all four geometries, `g ∈ [1,6]`,
`t ∈ {0,2,…,10}`, two base columns), checking four properties per config:

1. theorem-badge prediction (T9/T18a/T18b/T20/T25/spacelike complement, as
   implemented from the paper's statements) ⟺ live 𝔽₂ rank — **0 mismatches**;
2. every kernel ghost is dark on every screen cell — **0 violations**;
3. every propagation-inferred bit equals the true trajectory bit — **0 violations**;
4. propagation completes ⇒ rank is full — **0 violations**.

What this establishes: a from-scratch implementation, in a different language, with
independently written linear algebra, reproduces the machine-checked classification
across the whole slider space. What it does **not** establish: anything about the Lean
proofs themselves (they need no help), or anything outside `n ≤ 24, t ≤ 24`.

### 6. A meta-note: captions are claims **[observation about the process]**

Item 1's bug is worth recording as a pattern: the *simulation-side prose* overclaimed
("the sweep provably cannot finish") while the *simulation-side computation* was
correct and quietly contradicting it. This is the same defect class the corpus's
adversarial audits hunt in the papers (claims drifting above their anchors), appearing
in a satellite artifact within hours of its creation. The fix was also the same:
an adversarial scan (item 2) rather than trust in the narrative. Every caption in the
final build is either backed by a live check or labeled as the hypothesis/convention
it is.

### 7. Consensus scenes: the theorems appeared without being staged **[replication / observation]**

- The greedy best-response repair on the two-clerk carrier *is* neighbour-copy, so the
  race between ascending and descending rosters reproduces the Lean witness verbatim:
  `A → (1,1)`, `B → (0,0)` — `demoCarrier_not_confluent` as an animation, including
  "not gauge-equivalent" (the two settled worlds differ observably).
- Protecting clerk 0 (Route A) sends **both** rosters to `(0,0)` — the
  `demoCarrier_dir_observer_unique_under_seed` mechanism, interactively.
- The frustrated ring (odd cycle, "differ" edges) settled with Φ = 1 **at step 0** on
  a random start — rung 1's "settled ≠ agreed" honesty is generic behavior, not a
  contrived demo: local minima with frozen disagreement are simply where greedy
  repair lives when no consistent record exists.

---

## Part II — What surfaced in the second ("three times more") iteration

### 8. The paper moved underneath the session: v6.1 → v7 in real time **[doc]**

Between my first read of the paper and the second (hours apart, same day), the file
changed on disk: §11a appeared at the line where §12 used to start, and with it
**T27 (Route A assembled, `RouteA.lean`), T28 (real-time modular flow), T29 (channel
bridge)** — the audit items F2, F9, F11 closed by theorem, alongside F8 → T26. The
project memory I carried in ("T27 in flight, needs third-pass verification") was stale
within the session, and so was the simulation's own Map-tab honesty note ("the joint
Route-A composition has no machine-checked instance"), which I had written faithfully
from the paper a few hours earlier and then had to rewrite.

Two doc-sync observations for the corpus's audit genre (cf. F29, "stale changelog"):

- The paper's **header block** still says *"26 modules, 205 axiom-audited
  declarations"* and *"v6, 2026-07-07"* while **§27** says *"29 modules, 1426
  environment-swept declarations"* and §1/§26 speak of the v7 campaign in the past
  tense. The two counts may well have different bases (axiom-audited vs
  environment-swept), but the header predates the content it fronts.
- §26's open-mathematics list still contains the sentence structure of "three of four
  now closed" while the header table's adversarial-companion row already lists all
  four closures — consistent, but the same fact is now stated at three freshness
  levels in one document.

### 9. T27's proof sketch is directly executable — and one pass really does settle **[replication]**

§11a's proof paragraph is constructive enough to implement verbatim: the
**responsibility roster** assigns every non-tube column at right-offset `u ≤ R =
min(t, n−2)` to the right sweep (rows `i ≤ t − u`), the rest to the mirrored left
sweep (`ℓ ≤ L = (n−2) − R`), and everything below the light cones to downward
territory; the formulas are the CA constraint solved sideways/downward; and the roster
exists iff `n ≤ 2(t+1)` — the screen threshold again.

Implemented exactly so, with strata ordered by offset then by row:

- **one pass in rank order settles every scrambled record** (the paper's
  stratification lemma `pass_spec`, observed on every run);
- on realizable fibers the settled record **equals the original block** — the world
  the tube pins;
- **observer uniqueness is probed at runtime**: after every settle, the simulation
  re-scrambles the bulk independently (same tube), settles the second record, and
  compares — equality held on every run, including on **unrealizable** fibers, which
  is T27.3's striking "no realizability assumed" clause made visible;
- on unrealizable fibers the settled record keeps broken edges — and the banner can
  honestly say *"by logic, not weakness"* because the realizability check (rank of
  the augmented system) certifies the fiber is empty.

The chain's own open leftover is honored rather than papered over: **arbitrary-schedule
termination** is not proven in the chain (§26); the simulation's random scheduler
terminated on every run tried, and the panel labels exactly that — uniqueness covers
every schedule that terminates, termination beyond the rank schedule is the named
leftover.

### 10. The threshold trichotomy: ghosts / bijective / unrealizable **[argument — elementary, surfaced by a UX bug]**

The "Corrupt tube too" button initially produced an anticlimax: at `n=12, t=6` the
corrupted tube was *realizable* 25% of the time and the demo showed a cheerful
"settled, consistent" instead of T27.4's dichotomy. The reason is a counting fact the
paper leaves implicit. With `B = 2(t+1)` screen bits and `n` unknowns:

| regime | readout map | consequence |
|---|---|---|
| `n > B` | kernel ≠ 0 | **ghosts** exist; screen fails (T9 converse) |
| `n = B`, rank `n` | **bijective** | every tube reading realizable; *no* unrealizable-fiber demo possible; the reading itself has zero redundancy |
| `n < B`, rank `n` | injective, not surjective | `2^B − 2^n` unrealizable readings — T27.4's regime, and where the audit's stall witness lives (`n=3, t=2`: 6 bits vs 3 unknowns) |

The exact threshold is thus a *double* extreme: the screen saturates the information
bound (paper's point) **and** its reading carries no redundancy at all — consistent
with §11's honest note that the code corrects erasures of the bulk given the screen,
never erasures of the screen. The fixed button now searches for an unrealizable
corruption (guaranteed to exist iff `n < 2(t+1)`) and explains the bijective corner
when it can't.

### 11. The slope conjecture replicates under an independently chosen definition **[replication of a machine experiment / observation]**

The paper reports (§12/§26): intermediate-slope screens are *definable*, the
slope-invariance theorem is *open*, and a machine experiment at slopes 1/2, 1/3, 2/3,
1/4, 3/4 for all `n ≤ 20` found decoding at exactly the sharp threshold. The paper
does not print the screen definition.

I guessed the natural one — cells `(i, j₀ + ⌊i·p/q⌋)` and its right neighbour — and
swept all five slopes × `n ∈ [3,20]` × `t ∈ [0,12]`: **1,170 configs, zero deviations**
from `information set ⟺ n ≤ 2(t+1)`.

This is weak-but-real evidence of definition-robustness: two independently written
screen definitions (theirs and mine, floor-based) produce the same empirical
classification over the tested range. If the chain's Lean definition differs from
mine, cross-checking the two at `n ≤ 20` is nearly free and would either merge them
or surface an interesting sensitivity. In the UI the slope geometry is badged **OPEN**
with the live rank as the authority — the one scene where the badge deliberately
outranks no theorem.

### 12. The hexacode's uniform fibers **[replication]**

Beyond re-checking the headline numbers live (min weight 4; weight enumerator
`x⁶ + 45x²y⁴ + 18y⁶`, counts 1/45/18 over the 64 codewords; Hermitian self-duality),
two things showed up:

- **Exhaustive MDS:** all 20 three-subsets × all 64 codewords → candidate count
  exactly 1, every time (1,280 uniqueness checks). The paper proves this by the
  support-counting argument; the simulation brute-confirms it and animates it.
- **Uniform ambiguity below k:** revealing `|S|` coordinates always leaves exactly
  `64 / 4^|S|` candidates (4 at two shards, 16 at one, 64 at none) — the MDS
  uniform-fiber property, visible as "how many worlds still fit". Two shards never
  suffice *and* they always miss by exactly the same amount — the geometry-blindness
  is total in both directions.

### 13. The ledger's two scales, in one chart **[observation / presentation]**

Putting T10's theorem-forced quantities and the G10 convention in a single energy
ledger makes the paper's central honesty point physical. At the design point
(Δν = 10⁻⁹, ΔM = 0.056 kg, 1 m stroke):

- cycle work `W = τ(q₂) − τ(q₁) = 0.549 J`, and the theorem's floor puts
  `|τ| ≥ W/2 = 0.275 J` at an endpoint — bars you can see;
- the G10-convention price is `ΔM·Φ_N ≈ 3.50 MJ` per toggle — a factor of
  **~6.4 × 10⁶** above the theorem's minimum, and the chart cannot even show both to
  scale. That gap *is* the difference between "law" and "declared audit convention",
  rendered.
- "Claim free toggles" (τ ≡ 0 with W > 0) trips the perpetual-motion alarm — T10.2's
  contrapositive as an interaction.
- Transcribing T24 into badges forced re-reading the exact bracket statements: the
  lock-in floor really is the exact rational `10⁻⁶/30` (the accidental perfect square
  `2/1800 = 1/900`), the headline null-bound rounding really does lean conservative,
  and the battery-ceiling **erratum** (printed 0.5 gf vs true 0.575–0.578 gf — the
  unsafe direction) is the natural thing to show in red next to the corrected value.

### 14. The soccer ball, counted on an actual mesh **[replication]**

The collar scene builds a frequency-2 geodesic sphere (icosahedron, one subdivision:
V = 42, E = 120, F = 80) and counts on the mesh itself: `V − E + F = 2`,
`Σ(6 − deg v) = 12`, exactly 12 degree-5 vertices. That is T16's combinatorial
Gauss–Bonnet — and building it clarified where the honesty line sits: the *count* is
checkable arithmetic on any such complex; the physics is entirely in **L0**, the named
postulate that the collar's transverse structure *is* such a complex. The panel keeps
the paper's own phrasing: "assuming the soccer ball is precisely the numerology-shaped
step, now written on the label."

### 15. Thermal time reduces to something you can watch **[replication]**

On a qubit, the whole T21/T28 apparatus collapses to: Hermitian operators precess
about ρ's eigenaxis at rate `ω = ln(p/(1−p))`. The scene checks the KMS identity
numerically on random complex matrix pairs each time p changes — residuals ~10⁻¹⁷,
displayed next to `kms`/`kms_unique` — and the two conceptual clauses became
interaction design almost by themselves:

- **traciality ⇔ frozen time** is a slider position (p = ½): the arrows stop, the
  badge flips — *every non-tracial state ticks*;
- **normalization invariance** (`modular_smul_rho`) is a button labelled "ρ → 2ρ"
  whose entire observable effect is a banner saying *nothing moved* — the honest way
  to demo an invariance is a control that does nothing;
- at p = 1/3 the eigenvalue badge reads ½ — the paper's own qubit witness
  `Δ_ρ(E₀₁) = ½·E₀₁` sitting at the default slider position.

The fence stays visible: the clock is proven; that it is the *boost* clock is D3's
named physics, and the badge says so in amber.

### 16. Dark sector: show the values, not the limits **[observation / presentation]**

Two small honesty lessons from rendering T15:

- The **deep-MOND limit converges slowly** (the kernel is in `λ√x`): at the default
  `M = 10^10.7 M☉`, the outermost displayed ratio `g_obs/√(a_eff·g_b)` is ≈ 1.13, not
  1.00. The badge prints the actual value with "→ 1" rather than claiming arrival —
  the limit is a theorem, the 30-kpc galaxy is not yet in it.
- The **BTFR identity** `v∞⁴ = G·M·a_eff` checks to 1.000 live — and precisely because
  it is a two-line identity, the badge inherits the paper's F14 caveat: items like
  these test the *mechanism not at all*; the ν curve is, curve for curve, the
  published RAR fit. The "phantom halo" toggle renders ρ_A(r) as translucent shells
  labelled **bookkeeping** — a visualization whose caption's job is to deny it
  evidential weight (L2.7).

---

## Part III — Method notes

**The badge-vs-check architecture.** Every scene pairs a *theorem badge* (the chain's
claim, with Lean names) with an *independent live computation* (rank, enumeration,
residual, count). The display logic never assumes the theorem: agreement is computed
and shown, disagreement would render as a warning. During development this
architecture caught exactly one discrepancy — item 1, where the failure was in my
caption, not in either computation. That is the intended failure mode.

**Totals.** Independent checks run during development: 1,536 (classification sweep) +
1,170 (slope sweep) + 1,280 (hexacode MDS) + 212 stall-configs characterized + per-run
T27 probes (settle, uniqueness, realizability) + per-frame identities (Φ descent,
ledger identity, BTFR, KMS residuals, Euler counts). Zero unresolved disagreements
with the chain's stated theorems.

**Limits.** Bitmask 𝔽₂ algebra caps the cylinder at n ≤ 24 (int32); sweeps ran to
n = 20. Real-valued scenes (thermal, dark, cage) use doubles — residual-scale checks,
not Lean-style interval brackets; T24's brackets are transcribed, not re-derived.
JS `Math.random()` schedules are not seeded, so "every run tried" means exactly that.
None of this touches the Lean tree, which needs nothing from a satellite toy.

**Candidate feedback into the corpus** (each needs the corpus's own two-pass check):
1. the ring-distance dichotomy of item 3 as two small formalizable lemmas;
2. the bits/unknowns trichotomy of item 10 as a remark beside T27.4 (unrealizable
   fibers exist iff `n < 2(t+1)`; the sharp threshold is bijective);
3. a definition cross-check for sloped screens (item 11) — cheap, and either merges
   two independent definitions or finds a sensitivity;
4. header/§27 freshness sync in the paper (item 8) — F29's genre.

---

---

## Postscript (2026-07-07, later the same day): the feedback landed

The proof chain's **v8 campaign** took up the candidate-feedback list —
with the corpus's own verification discipline (each item became a Lean
theorem, sorry-free, standard axioms; anchors in
`../proof_chain/formal/RESULTS.md` §§27–32):

1. **Item 3 (ring-distance dichotomy) → T30** (`Rule90Propagation.lean`),
   *stronger than proposed*: the `d ≥ 3` no-inference half is proven for
   arbitrary spread column sets (not just two columns), the `d = 1` half
   is the full closure-completeness statement at the sharp threshold, the
   closure is proven sound, T9 re-derives through it, and item 2's
   flagship exhibit (`n = 8, g = 3, t = 3`: full rank, zero locally
   derivable cells) is the theorem `violet_exhibit`. The `d = 2` crawl
   (item 1) was the module's named leftover — exactly as this document
   scoped it — **and is closed in v9 by T37** (`Rule90Crawl.lean`):
   "the crawl completes on odd rings at threshold" is now the theorem
   `gapTwoTube_closure_complete_odd` (and it completes **only** on odd
   rings: `gapTwo_closure_complete_iff_odd`), with the odd `g = 2`
   decode re-derived through propagation — the crawl this simulation
   implements is, provably, a decoder.
2. **Item 10 (bits/unknowns trichotomy) → T31** (`Rule90Readout.lean` +
   Route-A corollaries), *sharpened*: the `n > B` row now says every
   reading is realizable (surjectivity via a kernel count the sim's table
   left open), bijectivity is exactly `n = 2(t+1)`, and "unrealizable
   corruption exists" is proven ⟺ `n < 2(t+1)` (`exists_unrealizable_tube_iff`,
   `no_stall_at_threshold`).
3. **Item 11 (slope definition cross-check) → `Rule90Slope.lean`**: the
   in-tree definition `slopeTube` uses the same floor convention this
   simulation guessed; the two independently written definitions now
   provably coincide at slope 0 with T9's tube, the failure half is a
   theorem at every slope, and threshold instances at slopes 1/2, 1/3,
   2/3 are kernel-checked. The general slope-invariance theorem remained
   open (and precisely posed) at v8 — **and fell in v9**: T36
   (`Rule90Lipschitz.lean`) proves the sharp threshold invariant across
   every 1-Lipschitz worldline (all slopes `≤ 1`, zigzags, reversals),
   with complete local decodability — i.e. the "local constraint
   propagation" decoder THIS simulation implements provably suffices
   along every causal observer path, not just the static tube. The
   simulation's slope-sweep observation is now the corollary
   `slopeTube_isInformationSet_iff`.
4. **Item 8 (header/§27 freshness) —** the paper header was already
   synced in the v7 commit; v8 additionally documents the sweep-count
   *filter* (`RESULTS.md` §33) so the count-mismatch genre (F28/item 8)
   cannot recur.

---

## Part IV — The v2 rebuild (2026-07-10): the simulation as a research instrument

*The corpus reached v9 (T36 + T37 closed; open mathematics = the arbitrary-subset
classification alone). The simulation was rebuilt around that boundary: a shared
theorem-exact engine (`js/lib/`), a 33-check cross-check battery gating everything
(`node node/selftest.mjs` and the in-browser Self-tests scene — 33/33 in both), a
scene showroom (`index.html` + lazy `js/scenes/`), and a headless experiment
driver (`node/experiments.mjs` → `data/experiments.json`) pointed at the open
item. Everything below was found by that driver on 2026-07-10; every claim has
its numbers in the data file and is re-runnable. Grading discipline as in Part I.*

### 17. The shadow atlas: the open item has a normal form **[observation → conjectures C1, C2]**

A subset S fails to be an information set iff S fits inside the zero-set Z(z) of
some nonzero ghost seed z. So the **maximal** zero-sets — an antichain — ARE the
arbitrary-subset classification for the block (n, t). Enumerating them exactly
(all 2ⁿ−1 ghosts, n ≤ 14, several horizons):

| n | maximal shadows at/above threshold | pattern |
|---|---|---|
| 3, 5, 7, 9, 11, 13 | 7, 31, 127, 511, 2047, 8191 | **2ⁿ − 1 — every ghost is maximal** |
| 4, 6, 8, 10, 12, 14 | 6, 14, 30, 62, 126, 254 | **2^{n/2+1} − 2 — exactly the single-parity-class ghosts** |

and the counts are **horizon-independent** once n ≤ 2(t+1) (checked to t = 2n).

**C1 (even-ring shadow law).** For even n at/above the screen threshold: the
maximal ghost shadows are exactly the zero-sets of the 2^{n/2+1}−2 nonzero
seeds supported on a single parity class; equivalently, *S is an information
set ⟺ S sees every nonzero single-parity seed*. The containment half has a
three-line proof: Rule 90 flips parity classes each tick, so the parity
components z_e, z_o of any seed have trajectories with disjoint supports —
hence traj(z) agrees with traj(z_e) on the cells where z_e can be nonzero and
Z(z) ⊆ Z(z_e) (and ⊆ Z(z_o)). What remains for a theorem: distinctness and
pairwise incomparability of the parity shadows.

**C2 (odd-ring rigidity).** For odd n at/above threshold: Z(z) ⊆ Z(z′) ⟹
z = z′ — ALL ghost blindness patterns are incomparable; the classification
does not compress at all. (Exhaustive n ≤ 13; no counterexample.)

**A recursion worth writing down** *[argument]*: on even n, a parity-class seed
observed every two ticks evolves by (pair-sum)² = Rule 90 on the half-ring
ℤ/(n/2). So C1 telescopes the even-ring classification toward odd cores, where
C2 says the structure is rigid. If C1 and C2 both hold, "arbitrary subsets"
reduces to a parity-peeling recursion plus one rigid base case per odd ring.

### 18. Capacity worldline sweeps: the wildness is not any invariant we tried — but powers of two are exactly tame **[observation → conjecture C3]**

Exhaustive sweeps of ALL adjacent-pair worldline screens at exact capacity
n = 2(t+1) (c(0) = 0 by translation invariance):

| t | n | paths | decode |
|---|---|---|---|
| 2 | 6 | 36 | **50%** — classification = "last step Lipschitz" (kernel-checked, `pairScreen_class_6_2`) |
| 3 | 8 = 2³ | 512 | **100%** |
| 4 | 10 | 10,000 | **31.60%** — last-step rule now neither necessary nor sufficient |
| 5 | 12 | 248,832 | **29.98%** — kills the "t odd ⇒ all decode" reading of the Lean probes |
| 6 | 14 | 7,529,536 | **24.05%** |
| 7 | 16 = 2⁴ | 3M sampled | **100.000%** |

plus samples at n = 32 (40k) and n = 64 (4k): **100%** both.

**C3 (power-of-two universality).** On n = 2ᵏ at the capacity horizon,
*every* worldline pair-screen decodes — any speed, any teleporting. Proof
sketch *[argument]*: for n = 2ᵏ the ring 𝔽₂[x]/(xⁿ−1) is local with maximal
ideal (u), u = 1+x, uⁿ = 0; the two cells at time i contribute functionals
x^{c−i}u^{2i} and x^{c+1−i}u^{2i} whose *sum* has u-valuation exactly 2i+1
(x^{a}+x^{a+1} = x^{a}u), so the 2(t+1) functionals hit every graded level
0…n−1 regardless of the path, and the readout is bijective. On non-2-power
rings semisimple factors exist and both the argument and the universality die
— which is precisely the (6,2)/(10,4) wildness.

### 19. The teleporting observer's permanent ghost **[observation → conjecture C4]**

The maximal-teleport worldline (0, n/2, 0, n/2, …): for **n/2 odd** it *never*
decodes (every horizon tried, t ≤ 24, n ≤ 26), with kernel dimension exactly
n/2 − 1; for n/2 even it decodes exactly at capacity. At n = 6 the mechanism
is verified cell-by-cell: the ghost δ₂+δ₄ ↔ δ₁+δ₅ is 2-periodic **in
antiphase with the observer** — the world's hidden 2-cycle is always dark
exactly where the observer just looked. The anti-T36: causal observers can
always decode (theorem); some superluminal observers can be deceived forever.

### 20. The fine structure of wildness **[observation]**

- **Kink family** (Lipschitz except one +2 step at position m): decodes for
  every m < t at every t, and at m = t (the "late jump") fails ⟺ t is even.
  Order sensitivity is systematic, not a (6,2) accident.
- **Slope-2 line**: decodes at t ∈ {3, 7, 8} of t ≤ 10, fails otherwise — no
  simple law found; enshrined as data.
- **Slack ladders**: above capacity the failing fraction decays (n = 6:
  50% → 0.8% at slack 8) but **universality is never reached** — consistent
  with item 19's permanent ghosts. Extra horizon does not buy back wild
  observers.

### 21. Lipschitz surjectivity **[observation → conjecture C5]**

20,000 random 1-Lipschitz worldlines across n ≤ 29, t ≤ 13: the pathScreen
readout always has full rank min(n, |cells|) — i.e. *every* reading of a
causal worldline screen is realizable (T31's surjectivity half, generalized
from the straight tube to the whole Lipschitz class). Zero violations.

### 22. Random subsets almost never decode — and locality is exceptional **[observation]**

Monte Carlo over uniform random size-n subsets (30k samples per config):
P(information set) = 4.8% at (8,3), 1.4% at (12,5), 0.23% at (16,7), ~0% at
(16,15) — far below the uniform-random-matrix baseline ∏(1−2⁻ᵏ) ≈ 28.9%, and
collapsing with depth (on 2-power rings the dynamics is nilpotent: cells past
time n/2 are identically zero and random picks waste themselves there). Among
the random subsets that DO decode, the fraction whose closure is complete
falls to zero as (n,t) grows: **T36-style local decodability is the
exception; generic determination is global** — the quantitative face of T30's
split. Exhaustive tight censuses: (6,2): 2,401 of 18,564 size-6 subsets decode
(12.93% — and 2401 = 7⁴ exactly, unexplained); (8,3): 502,681 of 10,518,300
(4.78%).

### 23. Method note: the engine is gated, and the gate caught a bug **[method]**

The v2 engine (`js/lib/f2.js`, `rule90.js`, `exact.js`) is accepted only when
the 33-check battery passes — every check an independent recomputation against
a named Lean statement (T9/T18/T20/T25/T30/T31/T36/T37, the v9 probes, the
physics brackets of T24/T11, hexacode enumeration, KMS residuals, T13 exact
rationals, ℤ₆, QBFT counting). During the sweeps the battery's discipline
caught one real bug before it shipped a false finding: an ad-hoc n = 32 probe
silently overflowed 32-bit masks and reported 0% decode at (32,15); the
"straight tube must decode (T9)" sanity check flagged it, and the bitset path
gave the true answer (100%). Part I item 6 ("captions are claims") has a v2
sequel: *probes need their own theorem checks*.

### 24. Addendum (same day): R1 — the parity/Rule-60 splitting. The even-ring half of the open item reduces exactly **[argument — verified three ways; formalization-ready]**

Chasing item 17's parity mechanism to its normal form gives a clean
structural identity. For **even n**, put every cell (i, j) in sector
s = (j − i) mod 2 and give it the coordinate u = (j − i − s)/2 ∈ ℤ/(n/2).
Then:

- **every Rule-90 constraint lies inside one sector** — for the constraint
  {(i+1, j), (i, j−1), (i, j+1)} all three cells share (j − i − 1) mod 2;
- in sector coordinates the dynamics is **Rule 60 on the half-ring**:
  y_{i+1}(u) = y_i(u) + y_i(u+1), i.e. multiplication by (1+x) on
  𝔽₂[x]/(x^{n/2} − 1), with sector seed y^{(s)}_0(u) = x_0(2u + s);
- so the block, its readout, and its propagation closure all split:
  **x_i(j) = y^{(s)}_i(u)** cell-for-cell (verified: 23,600 cells across
  n = 6…14, zero mismatches), and for ANY subset S,
  **kernel(S) = kernel₀(S₀) ⊕ kernel₁(S₁)** where S_s is the sector
  restriction (verified: 300 random subsets, exact every time).

Consequences, immediately:

- **C1's containment half is now proven** (modulo transcription): S fails ⟺
  some sector kernel is nonzero ⟺ a single-parity-class ghost is dark on S.
  C1's *exactness* half (those shadows are exactly the maximal ones) reduces
  to a **Rule-60 rigidity statement on the half-ring** (distinct Rule-60
  ghosts have incomparable zero-sets) — call it R2; it is C2's sibling in an
  even simpler system.
- **C4 refined, and item 19's mechanism corrected**: the n = 6 antiphase
  period-2 ghost is special to n = 6. In general the teleport ghost space is
  evolve²-invariant (that is the right invariant statement) and splits across
  sectors with dimension (n/2 − 1)/2 each (verified n = 10: 2+2 of 4;
  n = 14: 3+3 of 6). Under R1 the teleporting observer reads each sector
  through ONE cell per row along a slope-2 path in ℤ/(n/2) — so C4 reduces to
  the kernel of a *single-cell-per-row slope-2 reader of Rule 60 on an odd
  half-ring*. A strictly smaller, cleaner problem.
- **C3 consistency**: n = 2ᵏ splits into two nilpotent Rule-60 systems on
  ℤ/2^{k−1} ((1+x)^{2^{k−1}} = 0 there) — the valuation argument of item 18
  and the splitting tell one story.
- **T20/T37's parity phenomena get a one-line cause**: propagation can never
  change sector, and on even rings the checkerboard ghost is just "the other
  sector". (On odd n the sector map is not defined — j − i mod 2 is not
  translation-stable around an odd ring — which is exactly where C2's
  rigidity, and the odd-ring wildness, live.)

**Formalization candidates handed to the next campaign, updated order:**
**R1** (the splitting — a one-line induction per direction, biggest
downstream yield), **C1 = R1 + R2** (Rule-60 rigidity on the half-ring),
**C3** (valuation ladder, self-contained), **C4** (via R1: slope-2 Rule-60
readers on odd rings), **C5** (fan argument on the image side), **C2**
(Rule-90 odd rigidity — hardest, no sketch; R2 is its warm-up).

*Simulation: [`index.html`](index.html) · usage: [`README.md`](README.md) ·
experiments: [`node/experiments.mjs`](node/experiments.mjs) →
[`data/experiments.json`](data/experiments.json) · battery:
[`node/selftest.mjs`](node/selftest.mjs) · paper:
[`../OPH_PROOF_CHAIN_PAPER.md`](../OPH_PROOF_CHAIN_PAPER.md)*
