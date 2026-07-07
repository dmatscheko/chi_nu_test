# OPH proof chain — interactive 3D simulation

A three.js companion to [`chi_nu_test/OPH_PROOF_CHAIN_PAPER.md`](../chi_nu_test/OPH_PROOF_CHAIN_PAPER.md)
(v6.1 with the v7 theorems T26–T29). Seven interactive scenes covering Parts I–II in
full and the machine-checked mathematics inside the conditional tower (Parts III–IV),
every named hypothesis carried on the label.

## Run

Open `index.html` in any browser — fully self-contained, works from `file://`
(three.js r147 bundled, no network). Or serve it:

```sh
python3 -m http.server 8123 --directory oph_sim   # → http://localhost:8123
```

## The tabs

### Holography (T9 · T18 · T20 · T25 · T27 · open slopes)
The Rule-90 spacetime block as a 3D cylinder of bits; gold frames = the screen.
- Screen geometries: timelike tube (any stride), lightlike/boosted tube, **sloped
  screens** (slopes 1/2, 1/3, 2/3, 1/4, 3/4 — honestly badged as the chain's *open
  conjecture*; the live 𝔽₂ rank is the authority), spacelike partial row.
- Theorem badge + live rank check on every slider move (verified against the
  classification on 1536 + 1170 configurations during development; zero mismatches).
- **▶ Decode**: local constraint propagation floods the bulk (green); for strides ≥ 3
  it provably stalls and the violet cells are pinned only by T25's global mirror
  argument. **Ghost seeds** (magenta) when the screen fails.
- **11a · Route A assembled (T27)**: scramble the bulk (or corrupt the tube too), then
  run the decode-repair — local tube-preserving transactions under the declared rank
  roster or a random schedule. Realizable tubes settle to *the* world the tube pins
  (a second independent scramble is settled and compared, live); unrealizable tubes
  settle in disagreement *by logic, not weakness* (T27.4). Random-schedule termination
  is the chain's named open leftover, and the panel says so.

### Consensus (T0–T4 · T12)
Patches, mismatch Φ, greedy Postulate-2 repair. Two-clerk T3 race (reproduces the Lean
example verbatim), icosahedron office, frustrated ring ("settled ≠ agreed"), Route-A
boundary protection by clicking patches, live Φ descent chart.

### Toys (T5 · T8)
- **Width-3 Rule-90**: the good boundary {0,1} vs the bad {0,2} (Hfib checked live over
  all 8 seeds), the gauge-ghost pair (0,0,0)/(1,0,1), and the unfixable record (0,0,1)
  that kills frustration-free repair.
- **Layered sweep**: a feed-forward circuit; scramble the interior, run the staged
  sweep, always land on E(B(a)); Hfib-singleton checked by enumerating all 32 states.

### Hexacode (T19 · T22)
Six 𝔽₄ crystal pillars around the 3-symbol message. Click pillars to reveal/hide: any
3 reconstruct the rest (candidates counted live over all 64 codewords), 2 never do
(the weight-4 witness). Weight enumerator x⁶ + 45x²y⁴ + 18y⁶, MDS/Singleton, and
Hermitian self-duality — all enumerated live. The geometry-blind foil to the cylinder.

### Thermal time (T21 · T28)
Bloch-sphere modular clock: Hermitian operators precess under σₜ = e^{itH}(·)e^{−itH},
H = −log ρ. Slider for ρ's eigenvalue p: rate ω = ln(p/(1−p)), frozen exactly at the
tracial p = ½. Live numerical KMS check (residual ~10⁻¹⁷), the qubit witness
Δ_ρ(E₀₁) = ½E₀₁ at p = ⅓, rescaling invariance, and the honest fence: the clock is
proven; *boosts* are named Bisognano–Wichmann physics.

### Dark sector (T15)
A galaxy of test stars orbiting at v(r) under ν_OPH(x) = 1/(1−e^{−λ√x}). Toggle
Newtonian vs OPH and watch the curve flatten; sliders for M_b and λ. Live badges:
Newtonian limit, deep-MOND scaling, BTFR v∞⁴ = GMa_eff as an identity, the phantom
halo labelled as bookkeeping (L2.7), and the full honesty block (Poisson premises
named; ν is curve-for-curve the MLS 2016 RAR fit; spherical-only; χ sits between the
two data-preferred values).

### Collar & cage (T16 · T11 · T10 · T24)
- **Collar gate**: a geodesic sphere whose 12 degree-5 ports are counted live from the
  mesh (V−E+F = 2, Σ(6−deg) = 12); the L0 postulate named; Jensen-band slice sliders
  (uniform ⇒ exactly e^{−P/24}); the two P's with the CODATA-by-definition finding.
- **The cage**: the χ_ν bench. Run the ABBA cycle and watch the ledger obey
  W_cyc = τ(q₂) − τ(q₁) identically; "claim free toggles" trips the perpetual-motion
  alarm (T10.2); T24's run-matrix numbers with the battery-ceiling **erratum**; the
  3.5 MJ G10 pricing badged as the named convention it is. Expected outcome: NULL.

### The map
The graded ladder (✅/🧩/🔬), the scene↔theorem table with Lean names, honesty notes.

## Fidelity notes
- All discrete mathematics (Rule-90, ranks, kernels, rosters, codewords, Euler counts)
  is computed exactly; theorem badges are *predictions* checked live against it.
- The T27 repair implements the paper's responsibility roster verbatim (right/left
  light-cone sweeps + downward territory; stratified one-pass).
- Part III/IV scenes simulate mathematics downstream of hypotheses that are shown
  on-screen as hypotheses — nothing geometric is derived from consensus (T7).

Files: `index.html` (all app code), `three.min.js` (three.js r147, MIT, bundled).

See [`FINDINGS.md`](FINDINGS.md) for what surfaced while building and testing this —
the stride-3 local-decodability phase boundary, the threshold trichotomy, the slope
replication, the v7 update landing mid-session, and the graded check inventory.
