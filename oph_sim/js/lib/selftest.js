/* ============================================================================
   selftest.js — the theorem cross-check battery.

   Every entry checks an INDEPENDENT recomputation (rank, closure, count,
   enumeration, residual) against a machine-checked Lean statement. This is
   the contract that lets every scene put a theorem badge next to a live
   number. Runs in node (node/selftest.mjs) and in the browser (self-test
   scene). Nothing here assumes the theorem — disagreement renders as FAIL.
   ========================================================================= */

import {
  rank32, kernel32, rankBS, kernelBS, bsNew, bsSet, bsGet, randomMatrixInvertibleProb,
} from './f2.js';
import {
  mod, ringDist, gcd, evolve32, traj32, evolveBS, trajBS, makeCtx32, makeCtxBS,
  readoutMatrix32, readoutMatrixBS, analyzeScreen, gapTube, lightTube, slopeTube,
  pairScreen, spacelikeRow, closure, decode, isLipschitz,
  predictGapTube, predictLightTube, predictPairScreen,
  maximalShadows, cellsInsideMask, zeroSetMask,
} from './rule90.js';
import {
  derived, hexAll, hexEncode, hexWeight, hexHermInner, F4conj,
  kmsResidual, kmsStripResidual, mrandom, qubitRho, qubitRhoInv, state, modular, mmul,
  anomalyResiduals, SM_ASSIGNMENT, forcedAssignment, frac, feq, fstr,
  Z6_REPS, z6Phase, g0k, quorumMinOverlap, qbftSafe, cycleWork, toggleCost,
  lambdaCollar, chiOf,
} from './exact.js';

/* Deterministic RNG so the battery is reproducible. */
function mulberry32(a) { return function () { a |= 0; a = a + 0x6D2B79F5 | 0; let t = Math.imul(a ^ a >>> 15, 1 | a); t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t; return ((t ^ t >>> 14) >>> 0) / 4294967296; }; }

const THR = (n, t) => n <= 2 * (t + 1);

export const TESTS = [];
const test = (group, name, lean, fn) => TESTS.push({ group, name, lean, fn });

/* ======================================================== engine internals */

test('engine', 'int path ≡ bitset path (evolution)', '—', () => {
  const rng = mulberry32(1);
  for (const n of [1, 2, 3, 5, 8, 13, 24, 30]) {
    for (let trial = 0; trial < 20; trial++) {
      const seed = Math.floor(rng() * 2 ** Math.min(n, 30)) & ((n >= 30 ? 0x3fffffff : (1 << n) - 1));
      const a = traj32(seed, n, 12);
      const s0 = bsNew(n); for (let j = 0; j < n; j++) if ((seed >>> j) & 1) bsSet(s0, j);
      const b = trajBS(s0, n, 12);
      for (let i = 0; i <= 12; i++) for (let j = 0; j < n; j++) {
        if (((a[i] >>> j) & 1) !== bsGet(b[i], j)) return { pass: false, detail: `n=${n} seed=${seed} row ${i} col ${j}` };
      }
    }
  }
  return { pass: true, detail: '8 ring sizes × 20 seeds × 13 rows bit-identical' };
});

test('engine', 'readout matrix: stencil construction ≡ Lucas (Sierpiński) support', 'traj / binomial parity', () => {
  // stencil_i(k) = 1 ⟺ ∃ m ⊆ i (bitwise) with k ≡ 2m − i (mod n)
  for (const n of [5, 7, 12, 17]) {
    const ctx = makeCtx32(n, 14);
    for (let i = 0; i <= 14; i++) {
      let want = 0;
      for (let m = 0; m <= i; m++) if ((i & m) === m) want |= (1 << mod(2 * m - i, n));
      // fold duplicates: XOR is wrong here — supports can coincide mod n and cancel in 𝔽₂!
      // Correct check: stencil = Σ_m C(i,m)·δ_{2m−i} over 𝔽₂, so accumulate with XOR.
      let acc = 0;
      for (let m = 0; m <= i; m++) if ((i & m) === m) acc ^= (1 << mod(2 * m - i, n));
      if ((ctx.stencil[i] >>> 0) !== (acc >>> 0)) return { pass: false, detail: `n=${n}, i=${i}: stencil ${ctx.stencil[i].toString(2)} ≠ Lucas ${acc.toString(2)}` };
    }
  }
  return { pass: true, detail: '4 ring sizes × 15 rows: trajectory of δ₀ = 𝔽₂-folded Lucas support' };
});

test('engine', 'int path ≡ bitset path (rank/kernel on screens)', '—', () => {
  const rng = mulberry32(2);
  for (let trial = 0; trial < 60; trial++) {
    const n = 2 + Math.floor(rng() * 22), t = Math.floor(rng() * 10);
    const g = Math.floor(rng() * n);
    const cells = gapTube(n, t, g, 0);
    const a32 = analyzeScreen(n, t, cells, makeCtx32(n, t));
    const M = readoutMatrixBS(makeCtxBS(n, t), cells);
    const rk = rankBS(M, n);
    if (a32.rank !== rk) return { pass: false, detail: `n=${n} t=${t} g=${g}: rank32 ${a32.rank} ≠ rankBS ${rk}` };
  }
  return { pass: true, detail: '60 random screens: identical rank on both paths' };
});

/* ================================================================ theorems */

test('theorems', 'T9 — width-2 tube: information set ⟺ n ≤ 2(t+1)', 'tube_information_set_iff', () => {
  let checked = 0;
  for (let n = 1; n <= 20; n++) for (let t = 0; t <= 12; t++) {
    const a = analyzeScreen(n, t, gapTube(n, t, 1, 0));
    if (a.isInformationSet !== THR(n, t)) return { pass: false, detail: `n=${n} t=${t}` };
    checked++;
  }
  return { pass: true, detail: `${checked} configs, 0 mismatches` };
});

test('theorems', 'T18a — lightlike tube keeps the exact threshold', 'lightTube_isInformationSet_iff', () => {
  let checked = 0;
  for (let n = 1; n <= 20; n++) for (let t = 0; t <= 12; t++) {
    const a = analyzeScreen(n, t, lightTube(n, t, 0));
    if (a.isInformationSet !== THR(n, t)) return { pass: false, detail: `n=${n} t=${t}` };
    checked++;
  }
  return { pass: true, detail: `${checked} configs, 0 mismatches` };
});

test('theorems', 'T25 — stride classification: IS ⟺ gcd(g,n)=1 ∧ threshold', 'gapTube_isInformationSet_iff', () => {
  let checked = 0;
  for (let n = 1; n <= 18; n++) for (let t = 0; t <= 10; t++) for (let g = 0; g <= 8; g++) {
    const a = analyzeScreen(n, t, gapTube(n, t, g, 0));
    const want = n === 1 ? true : (gcd(g, n) === 1 && THR(n, t));
    if (a.isInformationSet !== want) return { pass: false, detail: `n=${n} t=${t} g=${g}: got ${a.isInformationSet}` };
    const p = predictGapTube(n, t, g);
    if (p.is !== want) return { pass: false, detail: `prediction fn wrong at n=${n} t=${t} g=${g}` };
    checked++;
  }
  return { pass: true, detail: `${checked} configs incl. the prediction function, 0 mismatches` };
});

test('theorems', 'T20 — gap-2 parity: IS ⟺ odd ∧ threshold; checkerboard ghost on even rings', 'gapTwoTube_isInformationSet_iff_parity', () => {
  for (let n = 2; n <= 20; n++) for (let t = 0; t <= 10; t++) {
    const a = analyzeScreen(n, t, gapTube(n, t, 2, 0));
    const want = (n % 2 === 1) && THR(n, t);
    if (a.isInformationSet !== want) return { pass: false, detail: `n=${n} t=${t}` };
    if (!want && n % 2 === 0 && n >= 4) {
      // altSeed j₀ (Lean): bit j = (j − j₀) mod 2 — ones on the ODD offsets,
      // dark on the even screen columns {j₀, j₀+2}. Verify it is a ghost.
      let alt = 0; for (let j = 1; j < n; j += 2) alt |= (1 << j);
      const rows = traj32(alt, n, t);
      const dark = gapTube(n, t, 2, 0).every(c => (((rows[c.i] >>> c.j) & 1) === 0));
      if (!dark) return { pass: false, detail: `checkerboard not dark on screen at n=${n} t=${t}` };
    }
  }
  return { pass: true, detail: 'parity classification + altSeed ghost verified' };
});

test('theorems', 'T30a — ring-distance ≥ 3: the closure is the screen itself (zero inferences)', 'gapTube_inferable_iff / spread_screen_inferable_iff', () => {
  let checked = 0;
  for (let n = 6; n <= 16; n++) for (let g = 2; g < n - 1; g++) {
    const d = ringDist(0, g, n);
    if (d < 3) continue;
    for (let t = 0; t <= 8; t += 2) {
      const cells = gapTube(n, t, g, 0);
      const cl = closure(n, t, cells);
      if (cl.count !== cells.length) return { pass: false, detail: `n=${n} g=${g} t=${t}: ${cl.count - cells.length} bulk inferences` };
      checked++;
    }
  }
  return { pass: true, detail: `${checked} spread configs, zero bulk inferences everywhere` };
});

test('theorems', 'T30b — adjacent tube: closure complete at the sharp threshold', 'adjacent_closure_complete', () => {
  let checked = 0;
  for (let n = 1; n <= 20; n++) for (let t = 0; t <= 12; t++) {
    if (!THR(n, t)) continue;
    const cl = closure(n, t, gapTube(n, t, 1, 0));
    if (!cl.complete) return { pass: false, detail: `n=${n} t=${t}` };
    checked++;
  }
  return { pass: true, detail: `${checked} threshold configs, closure = whole block` };
});

test('theorems', 'T37 — gap-2 crawl: at threshold, closure complete ⟺ ring odd', 'gapTwo_closure_complete_iff_odd', () => {
  let checked = 0;
  for (let n = 2; n <= 21; n++) for (let t = 0; t <= 12; t++) {
    if (!THR(n, t)) continue;
    const cl = closure(n, t, gapTube(n, t, 2, 0));
    if (cl.complete !== (n % 2 === 1)) return { pass: false, detail: `n=${n} t=${t}: complete=${cl.complete}` };
    checked++;
  }
  return { pass: true, detail: `${checked} threshold configs: complete exactly on odd rings` };
});

test('theorems', 'T37b — even rings: rows ≥ 1 fill but row 0 stays half-dark', 'gapTwoTube_closure_incomplete_even + gapTwo_row1', () => {
  for (let n = 4; n <= 16; n += 2) {
    const t = Math.ceil(n / 2);            // n ≤ 2t+1 ⟺ t ≥ (n−1)/2 → t = ⌈n/2⌉ works
    const cl = closure(n, t, gapTube(n, t, 2, 0));
    for (let x = 0; x < n; x++) if (!cl.known[1][x]) return { pass: false, detail: `n=${n}: row 1 cell ${x} not inferred` };
    let row0known = 0; for (let x = 0; x < n; x++) row0known += cl.known[0][x];
    if (row0known !== n / 2) return { pass: false, detail: `n=${n}: row 0 has ${row0known} known cells, want ${n / 2} (even offsets only)` };
  }
  return { pass: true, detail: 'even rings: full row 1, exactly the even-offset half of row 0' };
});

test('theorems', 'T36 — Lipschitz worldlines: IS ⟺ threshold, closure complete at threshold', 'pathScreen_isInformationSet_iff · pathScreen_closure_complete', () => {
  const rng = mulberry32(36);
  let checked = 0;
  for (let n = 2; n <= 20; n++) for (const t of [0, 1, 2, 3, 5, 8, 12]) {
    for (let trial = 0; trial < 6; trial++) {
      const col = [Math.floor(rng() * n)];
      for (let i = 0; i < t; i++) col.push(mod(col[i] + (Math.floor(rng() * 3) - 1), n));
      const cells = pairScreen(n, t, col);
      const a = analyzeScreen(n, t, cells);
      if (a.isInformationSet !== THR(n, t)) return { pass: false, detail: `n=${n} t=${t} col=[${col}]` };
      if (THR(n, t)) {
        const cl = closure(n, t, cells);
        if (!cl.complete) return { pass: false, detail: `closure incomplete at n=${n} t=${t} col=[${col}]` };
      }
      const p = predictPairScreen(n, t, col);
      if (p.is !== THR(n, t)) return { pass: false, detail: `prediction fn at n=${n} t=${t}` };
      checked++;
    }
  }
  return { pass: true, detail: `${checked} random 1-Lipschitz worldlines (zigzags, reversals): sharp threshold, complete closure` };
});

test('theorems', 'T36c — slopeTube p/q ≤ 1: sharp threshold at every slope', 'slopeTube_isInformationSet_iff', () => {
  let checked = 0;
  for (let q = 1; q <= 5; q++) for (let p = 0; p <= q; p++) {
    for (let n = 2; n <= 18; n++) for (const t of [0, 1, 2, 4, 7, 10]) {
      const a = analyzeScreen(n, t, slopeTube(n, t, p, q, 0));
      if (a.isInformationSet !== THR(n, t)) return { pass: false, detail: `p/q=${p}/${q} n=${n} t=${t}` };
      checked++;
    }
  }
  return { pass: true, detail: `${checked} slope configs (all p ≤ q ≤ 5), 0 mismatches` };
});

test('theorems', 'T31 — readout trichotomy: surjective ⟺ 2(t+1) ≤ n; bijective at equality', 'tubeData_surjective_iff · readout_trichotomy', () => {
  for (let n = 2; n <= 20; n++) for (let t = 0; t <= 10; t++) {
    const a = analyzeScreen(n, t, gapTube(n, t, 1, 0));
    const wantSurj = 2 * (t + 1) <= n;
    if (a.surjective !== wantSurj) return { pass: false, detail: `surj at n=${n} t=${t}: got ${a.surjective}` };
    if (a.bijective !== (n === 2 * (t + 1))) return { pass: false, detail: `bij at n=${n} t=${t}` };
  }
  return { pass: true, detail: 'ghosts above threshold, bijection exactly at it, empty fibers below' };
});

test('theorems', 'T9 complement — proper spacelike subsets never decode', 'spacelike_proper_subset_fails', () => {
  for (let n = 2; n <= 16; n++) {
    const a = analyzeScreen(n, 6, spacelikeRow(n, [0]));
    if (a.isInformationSet) return { pass: false, detail: `n=${n}` };
  }
  return { pass: true, detail: 'row 0 minus one cell: always a δ-ghost' };
});

test('theorems', 'counting bound — |S| < n is never an information set', 'card_lt_not_informationSet', () => {
  const rng = mulberry32(7);
  for (let trial = 0; trial < 200; trial++) {
    const n = 4 + Math.floor(rng() * 16), t = 1 + Math.floor(rng() * 8);
    const size = 1 + Math.floor(rng() * (n - 1));
    const cells = [], seen = new Set();
    while (cells.length < size) {
      const i = Math.floor(rng() * (t + 1)), j = Math.floor(rng() * n);
      const k = i * n + j; if (!seen.has(k)) { seen.add(k); cells.push({ i, j }); }
    }
    if (analyzeScreen(n, t, cells).isInformationSet) return { pass: false, detail: `n=${n} t=${t} |S|=${size}` };
  }
  return { pass: true, detail: '200 random undersized subsets, none decode' };
});

test('theorems', 'violet exhibit — n=8, g=3, t=3: full rank AND zero local inferences', 'IsInformationSet (gapTube 3 3 0) + gapTube_inferable_iff', () => {
  const cells = gapTube(8, 3, 3, 0);
  const a = analyzeScreen(8, 3, cells);
  const cl = closure(8, 3, cells);
  const pass = a.isInformationSet && cl.count === cells.length;
  return { pass, detail: `rank ${a.rank}/8, closure adds ${cl.count - cells.length} cells (want: rank 8, add 0) — determination and local derivability provably split` };
});

/* ==================================================== soundness / ghosts */

test('soundness', 'closure soundness — every inferred value equals the true trajectory', 'inferable_sound', () => {
  const rng = mulberry32(11);
  for (let trial = 0; trial < 80; trial++) {
    const n = 2 + Math.floor(rng() * 16), t = 1 + Math.floor(rng() * 8);
    const g = 1 + Math.floor(rng() * 3);
    const seed = Math.floor(rng() * (1 << n)) & ((1 << n) - 1);
    const rows = traj32(seed, n, t);
    const cells = gapTube(n, t, g, 0);
    const dc = decode(n, t, cells, rows, (r, j) => (r >>> j) & 1);
    for (let i = 0; i <= t; i++) for (let j = 0; j < n; j++) {
      if (dc.known[i][j] && dc.val[i][j] !== ((rows[i] >>> j) & 1)) return { pass: false, detail: `n=${n} t=${t} g=${g} cell (${i},${j})` };
    }
  }
  return { pass: true, detail: '80 random decodes, every inferred bit correct' };
});

test('soundness', 'ghosts — every kernel basis seed is dark on every screen cell', 'isInformationSet_iff_vanishing', () => {
  const rng = mulberry32(13);
  for (let trial = 0; trial < 80; trial++) {
    const n = 3 + Math.floor(rng() * 16), t = Math.floor(rng() * 8);
    const g = Math.floor(rng() * n);
    const cells = gapTube(n, t, g, 0);
    const ker = kernel32(readoutMatrix32(makeCtx32(n, t), cells), n);
    for (const z of ker) {
      const rows = traj32(z, n, t);
      for (const c of cells) if ((rows[c.i] >>> c.j) & 1) return { pass: false, detail: `n=${n} t=${t} g=${g} ghost ${z.toString(2)} visible at (${c.i},${c.j})` };
    }
  }
  return { pass: true, detail: '80 random screens: all ghost seeds identically dark' };
});

test('soundness', 'shadow atlas — S decodes ⟺ S fits inside no maximal ghost shadow', 'isInformationSet_iff_vanishing (contrapositive)', () => {
  const n = 6, t = 2;
  const atlas = maximalShadows(n, t);
  const ctx = makeCtx32(n, t);
  const rng = mulberry32(17);
  for (let trial = 0; trial < 400; trial++) {
    const size = 3 + Math.floor(rng() * 8);
    const cells = [], seen = new Set();
    while (cells.length < size) {
      const i = Math.floor(rng() * (t + 1)), j = Math.floor(rng() * n);
      const k = i * n + j; if (!seen.has(k)) { seen.add(k); cells.push({ i, j }); }
    }
    const isIS = analyzeScreen(n, t, cells, ctx).isInformationSet;
    const shadowed = atlas.maximal.some(M => cellsInsideMask(cells, M.mask, n));
    if (isIS !== !shadowed) return { pass: false, detail: `(6,2) subset ${JSON.stringify(cells)}: IS=${isIS} shadowed=${shadowed}` };
  }
  return { pass: true, detail: `400 random subsets at (6,2): rank verdict ≡ shadow-atlas verdict (${atlas.maximal.length} maximal shadows)` };
});

/* ============================================ beyond-Lipschitz probes (v9) */

test('probes', '(6,2) — kernel-checked classification: decode ⟺ last step Lipschitz', 'pairScreen_class_6_2', () => {
  let dec = 0, fail = 0;
  for (let a = 0; a < 6; a++) for (let b = 0; b < 6; b++) for (let c = 0; c < 6; c++) {
    const is = analyzeScreen(6, 2, pairScreen(6, 2, [a, b, c])).isInformationSet;
    if (is !== (ringDist(b, c, 6) <= 1)) return { pass: false, detail: `[${a},${b},${c}]` };
    is ? dec++ : fail++;
  }
  return { pass: (dec === 108 && fail === 108), detail: `all 216 triples: ${dec} decode / ${fail} fail, predicate exact (order-sensitive: [0,0,2] fails, [0,2,2] decodes)` };
});

test('probes', '(8,3) — ALL 512 paths decode at exact capacity', 'pairScreen_slope2_8_3 · pairScreen_teleport_8_3 + sweep record', () => {
  let ok = 0;
  for (let a = 0; a < 8; a++) for (let b = 0; b < 8; b++) for (let c = 0; c < 8; c++) {
    if (analyzeScreen(8, 3, pairScreen(8, 3, [0, a, b, c])).isInformationSet) ok++;
  }
  return { pass: ok === 512, detail: `${ok}/512 decode — including slope-2 line, slope-3 line, teleports` };
});

test('probes', '(10,4) — the six named probes match the kernel-checked verdicts', 'pairScreen_slope2_fails_10_4 · late_jump_fails · early_jump', () => {
  const probes = [
    [[0, 2, 4, 6, 8], false, 'slope-2 line'],
    [[0, 0, 0, 0, 5], false, 'late jump 5'],
    [[0, 5, 0, 5, 0], false, 'teleport 5'],
    [[0, 0, 5, 5, 0], true, 'jump up+back'],
    [[0, 0, 0, 0, 2], false, 'late jump 2'],
    [[0, 0, 0, 2, 2], true, 'early jump 2'],
  ];
  for (const [col, want, name] of probes) {
    const got = analyzeScreen(10, 4, pairScreen(10, 4, col)).isInformationSet;
    if (got !== want) return { pass: false, detail: `${name}: got ${got}, Lean says ${want}` };
  }
  return { pass: true, detail: 'all six (10,4) probes reproduce the Lean verdicts' };
});

/* ================================================================= physics */

test('physics', 'T24/T10/T11 — every ledger constant inside its Lean bracket', 'Cgeom_bounds … chi_branch_gap (17 brackets)', () => {
  const d = derived();
  const bad = [];
  for (const [k, e] of Object.entries(d)) if (!(e.v > e.br[0] && e.v < e.br[1])) bad.push(`${k}=${e.v}`);
  return { pass: bad.length === 0, detail: bad.length ? bad.join(', ') : `${Object.keys(d).length} recomputed constants, all inside their theorem-form intervals` };
});

test('physics', 'T19/T22 — hexacode: 64 codewords, weights 1/45/18, min 4, all 3-subsets reconstruct', 'hexacode_weight_distribution · three_subset_information_set', () => {
  const all = hexAll();
  if (all.length !== 64) return { pass: false, detail: 'codeword count' };
  const wd = {}; for (const w of all) wd[hexWeight(w)] = (wd[hexWeight(w)] || 0) + 1;
  if (wd[0] !== 1 || wd[4] !== 45 || wd[6] !== 18 || Object.keys(wd).length !== 3) return { pass: false, detail: JSON.stringify(wd) };
  // Hermitian self-duality
  for (const u of all) for (const w of all) if (hexHermInner(u, w) !== 0) return { pass: false, detail: 'self-duality' };
  // every 3-subset determines: 20 subsets × 64 codewords, candidate count 1
  let checks = 0;
  for (let s0 = 0; s0 < 6; s0++) for (let s1 = s0 + 1; s1 < 6; s1++) for (let s2 = s1 + 1; s2 < 6; s2++) {
    for (const w of all) {
      const cands = all.filter(v => v[s0] === w[s0] && v[s1] === w[s1] && v[s2] === w[s2]);
      if (cands.length !== 1) return { pass: false, detail: `subset {${s0},${s1},${s2}}` };
      checks++;
    }
  }
  // two shards leave exactly 4 candidates (uniform MDS fibers)
  const w0 = hexEncode([1, 1, 0]);
  const c23 = all.filter(v => v[2] === w0[2] && v[3] === w0[3]).length;
  return { pass: c23 === 4, detail: `1280 three-subset reconstructions exact; two shards always leave 4 candidates (got ${c23})` };
});

test('physics', 'T21/T28 — KMS: imaginary-time identity and the real-time boundary condition', 'kms · kms_boundary', () => {
  const rng = mulberry32(21);
  let worst = 0;
  for (const p of [0.2, 1 / 3, 0.5, 0.71]) {
    for (let trial = 0; trial < 4; trial++) {
      const A = mrandom(rng), B = mrandom(rng);
      worst = Math.max(worst, kmsResidual(p, A, B));
      for (const t of [-1.3, 0, 0.7, 2.2]) worst = Math.max(worst, kmsStripResidual(p, t, A, B));
    }
  }
  return { pass: worst < 1e-16 * 200, detail: `max residual ${worst.toExponential(2)} over 4 states × 4 pairs × strip points (double-precision zero)` };
});

test('physics', 'T21 — qubit witness: Δ_ρ(E₀₁) = ½·E₀₁ at ρ ∝ diag(1,2)', 'qubitState_modular_ne_id', () => {
  const p = 1 / 3; // diag(1,2)/3
  const E01 = [[[0, 0], [1, 0]], [[0, 0], [0, 0]]];
  const D = modular(qubitRho(p), qubitRhoInv(p), E01);
  const ok = Math.abs(D[0][1][0] - 0.5) < 1e-12 && Math.abs(D[0][1][1]) < 1e-12
    && Math.abs(D[0][0][0]) < 1e-12 && Math.abs(D[1][1][0]) < 1e-12 && Math.abs(D[1][0][0]) < 1e-12;
  return { pass: ok, detail: `Δ_ρ(E₀₁)₀₁ = ${D[0][1][0]} (want ½)` };
});

test('physics', 'T16 — collar gate: uniform reserves give exactly e^{−P/24}; Jensen band', 'uniform_gate · jensen_band', () => {
  const d = derived();
  const P = d.Ppub.v;
  const w = Array(6).fill(1 / 6);
  const lamU = lambdaCollar(w, Array(6).fill(P / 24));
  if (Math.abs(lamU - chiOf(P)) > 1e-15) return { pass: false, detail: 'uniform gate' };
  // skewed reserves with the same mean: band e^{−P/24} ≤ λ ≤ 1
  const eps = [0, P / 24 / 2, P / 24, P / 24, P / 24 * 1.5, P / 12].map((e, i, arr) => e);
  const mean = eps.reduce((s, e) => s + e / 6, 0);
  const eps2 = eps.map(e => e * (P / 24) / mean);
  const lam = lambdaCollar(w, eps2);
  const ok = lam >= chiOf(P) - 1e-12 && lam <= 1;
  return { pass: ok, detail: `uniform: λ = χ = ${lamU.toFixed(9)}; skewed same-mean: ${chiOf(P).toFixed(7)} ≤ ${lam.toFixed(7)} ≤ 1 ✓` };
});

test('physics', 'T13 — hypercharge: the constraints force exactly smAssignment (exact rationals)', 'hypercharges_unique', () => {
  const res = anomalyResiduals(SM_ASSIGNMENT);
  for (const [k, v] of Object.entries(res)) if (!feq(v, frac(0))) return { pass: false, detail: `${k} = ${fstr(v)}` };
  const forced = forcedAssignment(frac(1, 6));
  for (const k of ['YQ', 'Yu', 'Yd', 'YL', 'Ye', 'YH']) {
    if (!feq(forced[k], SM_ASSIGNMENT[k])) return { pass: false, detail: `forced ${k} = ${fstr(forced[k])} ≠ ${fstr(SM_ASSIGNMENT[k])}` };
  }
  return { pass: true, detail: 'all 7 residuals ≡ 0 exactly; ratio theorem reproduces (1/6, −2/3, 1/3, −1/2, 1, 1/2)' };
});

test('physics', 'CenterZ6 — the trivially-acting center is exactly {g₀ᵏ} ≅ ℤ₆', 'actsTrivially_iff · kernel_bijection', () => {
  for (let k = 0; k < 6; k++) {
    const g = g0k(k);
    for (const r of Z6_REPS) {
      const ph = z6Phase(g.a, g.b, g.theta, r);
      if (Math.min(ph, 1 - ph) > 1e-12) return { pass: false, detail: `g₀^${k} moves ${r.name} by ${ph}` };
    }
  }
  // a non-kernel probe must move something
  const probes = [[1, 0, 0], [0, 1, 1 / 6], [2, 1, 1 / 3]];
  for (const [a, b, th] of probes) {
    const moved = Z6_REPS.some(r => { const ph = z6Phase(a, b, th, r); return Math.min(ph, 1 - ph) > 1e-9; });
    if (!moved) return { pass: false, detail: `probe (${a},${b},${th}) acts trivially but is not g₀ᵏ` };
  }
  return { pass: true, detail: 'g₀ᵏ (k=0..5) fix all six multiplets; off-kernel probes move at least one' };
});

test('physics', 'T23 — QBFT: overlap f+1 at n=3f+1, and the n=3f+2 gap witness', 'quorum_intersection_exact · quorum_overlap_gap', () => {
  for (let f = 1; f <= 4; f++) {
    const n = 3 * f + 1, q = 2 * f + 1;
    if (quorumMinOverlap(n, q, q) !== f + 1) return { pass: false, detail: `f=${f}` };
    if (!qbftSafe(n, q, f)) return { pass: false, detail: `safety at f=${f}` };
  }
  // n = 5, f = 1, quorums of 3: {0,1,2} ∩ {2,3,4} = {2} — safety-by-counting fails
  if (quorumMinOverlap(5, 3, 3) !== 1) return { pass: false, detail: 'gap witness' };
  return { pass: true, detail: 'n=3f+1 gives exactly f+1 overlap (f ≤ 4); n=5,f=1 overlaps in 1 < f+1' };
});

test('physics', 'T10 — cage cycle: W_cyc = τ(q₁) − τ(q₂) identically', 'cycleWork_eq_toggleCost_diff', () => {
  const rng = mulberry32(10);
  for (let trial = 0; trial < 50; trial++) {
    const E = (q, on) => Math.sin(q * 3 + (on ? 1.7 : 0)) * rng() * 0 + (q * q + (on ? 2.3 * q + 1 : 0.4 * q)); // arbitrary smooth-ish ledger
    const q1 = rng() * 4 - 2, q2 = rng() * 4 - 2;
    const lhs = cycleWork(E, q1, q2), rhs = toggleCost(E, q1) - toggleCost(E, q2);
    if (Math.abs(lhs - rhs) > 1e-12) return { pass: false, detail: `q1=${q1} q2=${q2}` };
  }
  return { pass: true, detail: '50 arbitrary ledgers: the identity holds to double precision' };
});

test('physics', 'baseline — random n×n 𝔽₂ matrix invertibility ∏(1−2⁻ᵏ) → 0.28879…', 'reference for the subset-lab Monte Carlo', () => {
  const p = randomMatrixInvertibleProb(50);
  return { pass: Math.abs(p - 0.2887880950866) < 1e-10, detail: `∏ = ${p.toFixed(10)}` };
});

/* =============================================== v10 formal campaign (Lean) */

test('theorems', 'T38 parity classification — even-ring failure ⟺ single-parity ghost', 'Rule90Parity.lean: not_isInformationSet_iff_single_parity_shadow', () => {
  // IS(S) ⟺ the readout is injective on EACH parity class of seeds separately
  // (readout matrix columns restricted to a class; rank must be n/2).
  const rng = mulberry32(38);
  for (const n of [6, 10, 12]) {
    const t = 3, ctx = makeCtx32(n, t);
    const classMask = p => { let m = 0; for (let j = p; j < n; j += 2) m |= 1 << j; return m; };
    for (let trial = 0; trial < 40; trial++) {
      const size = 2 + Math.floor(rng() * (n + 3));
      const seen = new Set(); const cells = [];
      while (cells.length < Math.min(size, (t + 1) * n)) {
        const i = Math.floor(rng() * (t + 1)), j = Math.floor(rng() * n);
        const k = i * 64 + j; if (!seen.has(k)) { seen.add(k); cells.push({ i, j }); }
      }
      const M = readoutMatrix32(ctx, cells);
      const is = analyzeScreen(n, t, cells, ctx).isInformationSet;
      const ok0 = rank32(M.map(r => r & classMask(0)), n) === n / 2;
      const ok1 = rank32(M.map(r => r & classMask(1)), n) === n / 2;
      if (is !== (ok0 && ok1)) return { pass: false, detail: `n=${n} |S|=${cells.length}: IS=${is} classes=(${ok0},${ok1})` };
    }
  }
  return { pass: true, detail: '3 even rings × 40 random subsets: failure ⟺ a parity class drops rank' };
});

test('theorems', 'T39 two-power universality — every worldline decodes on n = 2ᵏ', 'Rule90TwoPower.lean: pairScreen_isInformationSet_iff_two_pow', () => {
  const rng = mulberry32(39);
  for (let trial = 0; trial < 40; trial++) { // n=8 at capacity, arbitrary cols
    const col = Array.from({ length: 4 }, () => Math.floor(rng() * 8));
    if (!analyzeScreen(8, 3, pairScreen(8, 3, col)).isInformationSet) {
      return { pass: false, detail: `(8,3) col=[${col}]` };
    }
  }
  for (let trial = 0; trial < 8; trial++) { // n=16 at capacity
    const col = Array.from({ length: 8 }, () => Math.floor(rng() * 16));
    if (!analyzeScreen(16, 7, pairScreen(16, 7, col)).isInformationSet) {
      return { pass: false, detail: `(16,7) col=[${col}]` };
    }
  }
  // contrast anchor: the same wildness FAILS off two-powers (T36 wall at (10,4))
  if (analyzeScreen(10, 4, slopeTube(10, 4, 2, 1, 0)).isInformationSet) {
    return { pass: false, detail: '(10,4) slope-2 decoded — contrast anchor broken' };
  }
  return { pass: true, detail: '48 arbitrary worldlines decode on 2ᵏ rings; slope-2 still fails at (10,4)' };
});

test('theorems', 'T40 lone lightlike diagonal — odd: IS ⟺ n ≤ t+1 (counting-tight); even: never', 'Rule90Diagonal.lean: diagScreen_isInformationSet_iff_odd / _not_…_even', () => {
  const diag = (n, t, j0) => Array.from({ length: t + 1 }, (_, i) => ({ i, j: mod(j0 + i, n) }));
  for (const n of [3, 5, 7, 9, 11]) {
    const at = analyzeScreen(n, n - 1, diag(n, n - 1, 1));
    if (!at.isInformationSet || at.bits !== n) return { pass: false, detail: `odd n=${n} t=n−1: rank ${at.rank}, bits ${at.bits}` };
    if (n > 1 && analyzeScreen(n, n - 2, diag(n, n - 2, 1)).isInformationSet) {
      return { pass: false, detail: `odd n=${n} t=n−2 decoded below the counting bound` };
    }
  }
  for (const n of [4, 6, 8, 10]) {
    const a = analyzeScreen(n, 3 * n, diag(n, 3 * n, 0));
    if (a.isInformationSet || a.rank !== n / 2) return { pass: false, detail: `even n=${n}: rank ${a.rank} (want n/2, never IS)` };
  }
  return { pass: true, detail: 'odd 3..11: one cell/row decodes exactly at t+1=n; even 4..10: plateau rank n/2 forever' };
});

test('theorems', 'T41 diagonal pairs on even rings — opposite parity ⟺ IS at n ≤ 2(t+1), any offset', 'Rule90Diagonal.lean: diagScreen_pair_isInformationSet_iff_even', () => {
  const diag = (n, t, j0) => Array.from({ length: t + 1 }, (_, i) => ({ i, j: mod(j0 + i, n) }));
  for (const n of [6, 8, 10]) {
    const t = n / 2 - 1;
    for (const off of [1, 3, 5]) {
      if (off >= n) continue;
      const cells = [...diag(n, t, 0), ...diag(n, t, off)];
      if (!analyzeScreen(n, t, cells).isInformationSet) return { pass: false, detail: `n=${n} off=${off} at capacity` };
    }
    const same = [...diag(n, n, 0), ...diag(n, n, 2)];
    if (analyzeScreen(n, n, same).isInformationSet) return { pass: false, detail: `n=${n} same-parity pair decoded` };
  }
  return { pass: true, detail: 'offsets 1/3/5 decode at t=n/2−1; same-parity pairs stay blind at t=n' };
});

test('probes', 'F5 odd-ring diagonal-pair offset window — decode ⟺ n−t−1 ≤ 2⁻¹Δ ≤ t+1', 'oph_sim probe law (paper-proved sufficiency; unformalized)', () => {
  const diag = (n, t, j0) => Array.from({ length: t + 1 }, (_, i) => ({ i, j: mod(j0 + i, n) }));
  const n = 9, inv2 = 5; // 2·5 ≡ 1 (mod 9)
  for (let t = 4; t <= 6; t++) {
    const ctx = makeCtx32(n, t);
    for (let off = 1; off < n; off++) {
      const dec = analyzeScreen(n, t, [...diag(n, t, 0), ...diag(n, t, off)], ctx).isInformationSet;
      const delta = mod(off * inv2, n);
      const want = (n - t - 1 <= delta) && (delta <= t + 1);
      if (dec !== want) return { pass: false, detail: `t=${t} off=${off} δ=${delta}: got ${dec}, law says ${want}` };
    }
  }
  return { pass: true, detail: 'n=9, t=4..6, all 8 offsets: the reindexed-offset window is exact' };
});

/* ------------------------------------------------------------------ runner */

export function runAll(onResult) {
  const results = [];
  for (const t of TESTS) {
    const t0 = Date.now();
    let r;
    try { r = t.fn(); } catch (e) { r = { pass: false, detail: 'EXCEPTION: ' + (e && e.message) }; }
    r.ms = Date.now() - t0;
    const entry = { group: t.group, name: t.name, lean: t.lean, ...r };
    results.push(entry);
    if (onResult) onResult(entry);
  }
  return results;
}
