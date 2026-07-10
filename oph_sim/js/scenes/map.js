/* ============================================================================
   map.js — the honest map: what this simulation is, which theorem each scene
   shows, and where mathematics ends. Synced to corpus v9 (2026-07-09).
   ========================================================================= */

import { el } from '../lib/ui.js';

const HTML = `
<div class="pagetitle">What this simulation is</div>
<div class="card">
<p>An interactive companion to <span class="mono">chi_nu_test/OPH_PROOF_CHAIN_PAPER.md</span> (v9 corpus,
2026-07-09). It simulates the <b>machine-checked core</b> of the Observer-Patch Holography chain —
Parts I–II in full, plus the machine-checked <i>mathematics inside</i> the conditional tower
(Parts III–IV) with every named hypothesis carried on the label — and, new in v2, it is a
<b>research instrument</b> pointed at the chain's ONE remaining open mathematics item.</p>
<p style="margin-top:8px">Formal status of the corpus this build mirrors: one Lean tree, <b>35 modules,
1235 environment-swept declarations in both namespaces, 8284 build jobs — 0 <span class="mono">sorry</span>,
0 custom axioms, no <span class="mono">native_decide</span></b>; headline theorems use only
<span class="mono">propext · Classical.choice · Quot.sound</span>.</p>
</div>

<div class="pagetitle">The ladder, honestly graded</div>
<div class="card"><table class="data">
<tr><th></th><th>Rung</th><th>Status</th></tr>
<tr><td>✅</td><td><b>1 — Consensus dynamics works.</b> Local repair terminates (T1); settled = agreed exactly on Edge-Repairable carriers (T2/T12) — on some carriers repair provably stalls in disagreement.</td><td>machine-checked · Consensus scene</td></tr>
<tr><td>✅</td><td><b>2 — One objective world is NOT automatic.</b> Different repair schedules settle into different consistent worlds (T3, non-confluence) — the load-bearing negative.</td><td>machine-checked · Consensus scene (Race)</td></tr>
<tr><td>✅</td><td><b>3 — Objectivity can be earned.</b> Route B: a declared order (T6). Route A: a protected boundary pins the bulk (T4b); on the Rule-90 cylinder the minimal boundary is a width-2 tube watched long enough (T9), boost-invariant (T18a), stride-classified by gcd (T25), <b>worldline-invariant across the whole causal class (T36)</b>, with local decodability classified at every ring distance (T30 + T37) — and assembled as a transactional repair that terminates under EVERY schedule (T27 + T32).</td><td>machine-checked · Holography, Worldline, Crawl, Phase scenes</td></tr>
<tr><td>🧩/🔬</td><td><b>4 — The conditional tower.</b> Thermal time (T21) with its real-time KMS flow (T28) and Skolem–Noether genericity (T33); the Einstein branch (T14, T26); hypercharges &amp; ℤ₆ (T13); dark sector (T15); collar gate e<sup>−P/24</sup> with the twelve-port surface (T16, T35) and the channel bridge (T29); the two P's (T11); the χ_ν cage &amp; run matrix (T10, T24); QBFT safety (T23) — mathematics machine-checked <b>downstream of named physical hypotheses</b> (SEE, MAR, L0–L7, Bisognano–Wichmann, G9's channel identification and numeric S, the G10 pricing convention, P's source branch, the scaling limit, Γ).</td><td>the <i>mathematics inside</i> is simulated; the hypotheses are on the label — by T7 none of it follows from consensus alone</td></tr>
</table></div>

<div class="pagetitle">What you can watch ↔ which theorem</div>
<div class="card"><table class="data">
<tr><th>Scene / interaction</th><th>Theorem (Lean)</th></tr>
<tr><td>Width-2 tube decodes the cylinder ⇔ n ≤ 2(t+1); ghosts below capacity</td><td>T9 <span class="mono">tube_information_set_iff</span></td></tr>
<tr><td>Boosted tube: same sharp threshold</td><td>T18a <span class="mono">lightTube_isInformationSet_iff</span></td></tr>
<tr><td>Any stride g: decode ⟺ gcd(g,n) = 1 ∧ threshold (the gcd landscape in Phase maps)</td><td>T25 <span class="mono">gapTube_isInformationSet_iff</span></td></tr>
<tr><td><b>Any causal worldline</b> — zigzags, reversals: sharp threshold, closure complete (Worldline lab fan animation)</td><td><b>T36</b> <span class="mono">pathScreen_isInformationSet_iff · pathScreen_closure_complete · slopeTube_isInformationSet_iff</span></td></tr>
<tr><td><b>The gap-2 crawl</b> completes ⟺ ring odd; the wrap 2(m+1) ≡ 1 (Crawl scene ring dial)</td><td><b>T37</b> <span class="mono">gapTwo_closure_complete_iff_odd</span></td></tr>
<tr><td>Distance ≥ 3: determined yet ZERO local inferences (the violet exhibit n=8, g=3, t=3)</td><td>T30 <span class="mono">gapTube_inferable_iff · violet_exhibit</span></td></tr>
<tr><td>Readout trichotomy: ghosts / bijective at threshold / unrealizable readings below</td><td>T31 <span class="mono">readout_trichotomy · no_stall_at_threshold</span></td></tr>
<tr><td>"Scramble → Repair": tube-preserving transactions settle to the tube-pinned world under any schedule; the audit's stall witness (n=3, t=2) settles inconsistent by logic</td><td>T27/T32 <span class="mono">routeA_assembled · decodeStep_wellFounded · stallRecord_tube_unrealizable</span></td></tr>
<tr><td>Two-clerk race → two worlds; protected patch pins both rosters</td><td>T3/T4b <span class="mono">demoCarrier_not_confluent</span></td></tr>
<tr><td>Width-3 toy: good/bad boundary, gauge ghost, unfixable record</td><td>T5 <span class="mono">rule90_no_frustrationFree_repair …</span></td></tr>
<tr><td>Hexacode: any 3 of 6 shards; W = x⁶+45x²y⁴+18y⁶; Hermitian self-dual</td><td>T19/T22 <span class="mono">three_subset_information_set · hexacode_weight_distribution</span></td></tr>
<tr><td>Bloch modular clock; KMS residual ~10⁻¹⁷; the KMS strip ω(A·σ<sub>t+i</sub>B) = ω(σ<sub>t</sub>B·A) drawn live</td><td>T21/T28/T33 <span class="mono">kms · kms_boundary · algEquiv_matrix_inner</span></td></tr>
<tr><td>Rotation curves; BTFR identity; exact phantom profile M_A, ρ_A with M_A′ = 4πr²ρ_A</td><td>T15 <span class="mono">btfr · hasDerivAt_MA · phantom_bookkeeping</span></td></tr>
<tr><td>Geodesic sphere: 12 degree-5 ports counted on the mesh; 3F = 2E and the handshake now theorems of a closed surface; Jensen band; the two P's</td><td>T16/T35/T11 <span class="mono">twelve_unit_defects · TriangulatedSphere · jensen_band · chi_branch_gap</span></td></tr>
<tr><td>Channel bridge: λ_collar·(𝓛𝒩)(q) = e<sup>−P/24</sup>·S·A(q) with slots = slices by <span class="mono">rfl</span></td><td>T29 <span class="mono">channel_composite</span></td></tr>
<tr><td>ABBA cycle ledger W = τ(q₂)−τ(q₁); free toggles trip the alarm; T24 numbers incl. the erratum</td><td>T10/T24 <span class="mono">cycleWork_eq_toggleCost_diff · battery_coupon_bounds</span></td></tr>
<tr><td>Anomaly cage forces (1/6, −2/3, 1/3, −1/2, 1, 1/2); the ℤ₆ wheel</td><td>T13 <span class="mono">hypercharges_unique · kernelAddEquiv</span></td></tr>
<tr><td>Quorum dial: safety-by-counting exactly at n = 3f+1</td><td>T23 <span class="mono">qbft_safety_core · quorum_overlap_gap</span></td></tr>
</table></div>

<div class="pagetitle">Where mathematics ends (v9)</div>
<div class="card">
<p><b>Open mathematics — exactly one item:</b> the classification of <b>arbitrary</b> cell subsets
(which S decode?). The Screen-lab and Beyond-Lipschitz scenes are pointed at it: the shadow atlas
reduces it to maximal ghost zero-sets, the sweeps mapped the wild regime, and five machine-testable
conjectures (C1–C5, FINDINGS.md Part IV) are queued for the next formal campaign — the same pipeline
that turned this simulation's v1 findings into T30, T31, T36 and T37.</p>
<p style="margin-top:8px"><b>Open physics — unchanged, as it must be:</b> SEE, MAR, L0–L7, G9
(channel identification + numeric S), the G10 pricing convention, P's source branch,
Bisognano–Wichmann + the scaling limit, Γ. Each is consumed as a named hypothesis and each feeds a
machine-checked consequence theorem; none is derivable from consensus (T7, the fence). The χ_ν
experiment's expected outcome, by the chain's own grading, is <b>NULL</b>.</p>
<p style="margin-top:8px" class="dimc">Honesty notes carried from the paper: the dark-sector ν is
curve-for-curve the published RAR fit; the collar's "twelve" needs the L0 soccer-ball postulate
(its counting hypotheses became theorems in T35; Euler stays topological input); the 3.5 MJ toggle
price is a declared convention priced strictly inside the corridor 0.55 J &lt; 3.5 MJ &lt; 5×10¹⁵ J;
the battery-ceiling erratum is shown in red where it lives.</p>
</div>

<div class="pagetitle">The feedback loop, so far</div>
<div class="card"><table class="data">
<tr><th>simulation finding</th><th>became</th></tr>
<tr><td>v1 item 3 — the ring-distance phase boundary of local decodability</td><td><b>T30</b> (v8), stronger than proposed</td></tr>
<tr><td>v1 item 10 — the bits/unknowns trichotomy behind the "Corrupt tube" anticlimax</td><td><b>T31</b> (v8), sharpened</td></tr>
<tr><td>v1 item 11 — the slope-definition cross-check</td><td><span class="mono">Rule90Slope.lean</span> (v8) → <b>T36</b> (v9), the Lipschitz worldline theorem</td></tr>
<tr><td>v1 item 1 — "the crawl completes on odd rings"</td><td><b>T37</b> (v9), the crawl is provably a decoder</td></tr>
<tr><td>v2 (this build) — C1 parity-shadow law, C2 odd-ring rigidity, C3 power-of-two universality, C4 the teleport permanent ghost, C5 Lipschitz surjectivity</td><td>conjectures with evidence artifacts — <span class="mono">data/experiments.json</span>, FINDINGS.md Part IV</td></tr>
</table></div>
`;

export default {
  title: 'The map',
  panel: false,
  async mount({ stage, legend }) {
    stage.innerHTML = HTML;
    legend(null);
  },
  showAgain() {},
};
