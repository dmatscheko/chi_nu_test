# OPH proof chain — the simulation showroom (v2)

An interactive companion to [`../OPH_PROOF_CHAIN_PAPER.md`](../OPH_PROOF_CHAIN_PAPER.md)
(corpus **v10**, 2026-07-10: 38 Lean modules, 1284 swept declarations, 0 `sorry`,
standard axioms only) — and, new in v2, a **research instrument** pointed at the
chain's one remaining open mathematics item (the arbitrary-subset
classification). Sixteen scenes: the machine-checked core simulated live, the
conditional tower with every named hypothesis on the label, and a frontier wing
whose experiments have already produced five machine-testable conjectures
(C1–C5, [`FINDINGS.md`](FINDINGS.md) Part IV).

## Run

ES modules need a server (any static server works):

```sh
python3 -m http.server 8123 --directory oph_sim    # from chi_nu_test/
# → http://localhost:8123
```

Headless (same engine, no browser):

```sh
node node/selftest.mjs          # the 38-check theorem cross-check battery
node node/experiments.mjs quick # frontier experiments (E1–E10) → data/experiments.json
node node/experiments.mjs all   # + the multi-minute exhaustive jobs
```

## The scenes

**The cylinder**
- **Holography 3D** — the Rule-90 spacetime block as a cylinder; timelike /
  lightlike / sloped (now a theorem: T36) / spacelike screens; theorem badge +
  live 𝔽₂ rank on every slider; decode animation (green = local propagation,
  violet = determined-but-global, now the theorem T30a); ghost seeds; **Route A
  assembled** (T27) with rank/random schedules, T32's universal termination on
  the label, and the audit's exact stall witness (n=3, t=2) as a button.
- **Worldline lab (T36)** — draw ANY observer path; 1-Lipschitz paths get the
  theorem (sharp threshold, closure complete — the fan animation is the
  induction of `inferable_fan_of_pairs`); superluminal paths get the honest
  open-territory treatment, the kernel-checked (6,2)/(8,3)/(10,4) walls, and
  the teleporting observer's permanent ghost.
- **The crawl (T37)** — the gap-2 closure staged live: enclosed middle column →
  pair fans fill row 1 → row-0 hops of two wrap the odd ring (the ring dial
  shows the crawl crawling); even rings keep row 0 half-dark with the
  checkerboard ghost; the full T30+T37 distance trichotomy; the violet exhibit.
- **Phase maps** — live-computed landscapes: the jewel's exact staircase
  n = 2(t+1) (all green: T30b), the stride×ring gcd pattern with the violet
  T30a country, and the T36 worldline-invariance map (no deviations, by
  theorem).

**The open frontier**
- **Screen lab** — build arbitrary subsets; live rank/kernel/ghosts/closure;
  the **shadow atlas** (maximal ghost zero-sets = the classification itself)
  with the C1 even-ring parity law and C2 odd-ring rigidity checked live;
  Monte Carlo against the random-matrix baseline.
- **Beyond Lipschitz** — the recorded experiment suite (E1–E10): exhaustive
  capacity sweeps t ≤ 6, the power-of-two universality (C3, with the u-adic
  proof sketch), the teleport permanent-ghost law (C4), kink/slope-2/slack
  families, Lipschitz surjectivity (C5), tight-subset censuses — with live
  re-verification buttons that re-run the walls in your browser.

**Foundations** — Consensus (T0–T4, T12: Φ descent, the two-clerk race,
protection = Route A) and Toys (T5 width-3 witnesses, T8 layered sweep).

**The tower** (machine-checked mathematics downstream of named hypotheses) —
Hexacode (T19/T22, all enumerations live), Thermal time (T21/T28/T33 with the
KMS boundary strip drawn numerically), Dark sector (T15 with the exact Lean
phantom profile M_A, ρ_A), Collar & cage (T16/T35/T11/T10/T24 + the T29
channel-composite law computed live), Hypercharge & ℤ₆ (T13 in exact
rationals; the ℤ₆ wheel), Quorums (T23, the 3f+1 boundary).

**Meta** — The map (the graded ladder, scene↔theorem table, where mathematics
ends, the feedback-loop record) and Self-tests (the full battery in-browser).

## Fidelity contract

- One engine (`js/lib/f2.js`, `rule90.js`, `exact.js`) serves every scene, the
  battery, and the headless experiments. Definitions are transliterated from
  the Lean tree (`Inferable`'s exact rules, `colFamily`/`gapTube`/`slopeTube`/
  `pathScreen`, `ringDist`, the T24/T11 interval brackets, HexacodePort's 𝔽₄
  tables, Hypercharge's constraints in exact rationals).
- Every theorem badge is paired with an independent live computation; the
  38-check battery (`node/selftest.mjs` = Self-tests scene) is the acceptance
  gate. 38/38 at build time, in node and in the browser — five checks are
  anchored to the v10 theorems this simulation's own findings became
  (T38–T41; FINDINGS.md Part V).
- Discrete math is exact (bitmask/bitset 𝔽₂; int path n ≤ 30, Uint32Array
  beyond). Real-valued scenes use doubles against Lean's interval brackets.
- Part III/IV scenes simulate mathematics *inside* named hypotheses (SEE, MAR,
  L0–L7, D3, G9, G10…), never physics from consensus (T7's fence). The χ_ν
  experiment's expected outcome, per the chain's own grading: **NULL**.

## Files

```
index.html            the showroom shell (sidebar, stage, panel, banner)
js/app.js             scene registry / lazy router
js/lib/               f2.js · rule90.js · exact.js · ui.js · selftest.js
js/wing3d.js          the three.js wing (7 scenes)
js/scenes/            worldline · crawl · phase · subsetlab · frontier ·
                      hypercharge · qbft · selftest · map
node/                 selftest.mjs · experiments.mjs (headless drivers)
data/experiments.js(on)  the recorded frontier results (E1–E10)
three.min.js          three.js r147 (MIT, bundled)
```

See [`FINDINGS.md`](FINDINGS.md) for everything the simulation has taught the
theory so far — Parts I–III (v1: the items that became T30, T31, T36, T37) and
Part IV (v2: the shadow-atlas laws, power-of-two universality, the permanent
ghost, and the conjecture list C1–C5 handed to the next formal campaign).
