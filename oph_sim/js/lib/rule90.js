/* ============================================================================
   rule90.js — the Rule-90 cylinder engine, transliterated from the Lean tree
   (proof_chain/formal/OPHProofChain/). Every definition here mirrors a named
   Lean definition; every prediction mirrors a named theorem. The self-test
   battery (selftest.js) checks the mirror.

   Lean vocabulary → here:
     Row n = ZMod n → ZMod 2          → int bitmask (n ≤ 30) or Uint32Array
     evolve x = fun j => x(j−1)+x(j+1)→ evolve32 / evolveBS
     Cell n t = Fin (t+1) × ZMod n    → {i, j}
     traj x0                          → traj32 / trajBS
     colFamily / gapTube / lightTube /
     slopeTube / pairScreen / pathScreen → screen builders (cell lists)
     IsInformationSet S               → rank(readout) = n  (isInformationSet_iff_vanishing)
     Inferable S                      → closure() — the base/down/left/right fixpoint
     ringDist a b = min((a−b).val,(b−a).val)
   ========================================================================= */

import { rank32, kernel32, solve32, rankBS, kernelBS, solveBS, bsNew, bsGet, bsSet, bsXor, popcount32 } from './f2.js';

export const mod = (a, n) => ((a % n) + n) % n;

/** ringDist (Rule90Propagation.lean): min((a−b) mod n, (b−a) mod n). */
export function ringDist(a, b, n) {
  const d = mod(a - b, n);
  return Math.min(d, n - d);
}

// ------------------------------------------------------------- evolution

/** Rule 90 on ℤ/n, int path: bit j of result = x(j−1) XOR x(j+1). n ≤ 30. */
export function evolve32(x, n) {
  if (n > 30) throw new Error(`evolve32: n=${n} exceeds the int path (use the bitset path)`);
  if (n === 1) return 0;                       // x(j)+x(j) = 0 in 𝔽₂
  const m = (n === 30 ? 0x3fffffff : (1 << n) - 1) >>> 0;
  const l = ((x << 1) | (x >>> (n - 1))) & m;  // bit j = x(j−1)
  const r = ((x >>> 1) | ((x & 1) << (n - 1))) & m; // bit j = x(j+1)
  return (l ^ r) >>> 0;
}

/** Trajectory rows 0..t (int path). */
export function traj32(seed, n, t) {
  const rows = new Array(t + 1);
  rows[0] = seed >>> 0;
  for (let i = 0; i < t; i++) rows[i + 1] = evolve32(rows[i], n);
  return rows;
}

/** Rule 90, bitset path (any n). */
export function evolveBS(x, n) {
  const y = bsNew(n);
  for (let j = 0; j < n; j++) {
    const b = bsGet(x, mod(j - 1, n)) ^ bsGet(x, mod(j + 1, n));
    if (b) bsSet(y, j);
  }
  return y;
}

export function trajBS(seed, n, t) {
  const rows = new Array(t + 1);
  rows[0] = seed;
  for (let i = 0; i < t; i++) rows[i + 1] = evolveBS(rows[i], n);
  return rows;
}

// --------------------------------------------------------------- screens
// A screen is a deduplicated list of cells {i, j}, 0 ≤ i ≤ t, 0 ≤ j < n.
// Builders mirror the Lean Finset definitions exactly.

function pushCell(cells, seen, i, j, n) {
  j = mod(j, n);
  const k = i * n + j;
  if (!seen.has(k)) { seen.add(k); cells.push({ i, j }); }
}

/** colFamily t colA colB (Rule90Decoding.lean): {(i, colA i)} ∪ {(i, colB i)}. */
export function colFamily(n, t, colA, colB) {
  const cells = [], seen = new Set();
  for (let i = 0; i <= t; i++) { pushCell(cells, seen, i, colA(i), n); pushCell(cells, seen, i, colB(i), n); }
  return cells;
}

/** gapTube g t j₀ (Rule90Stride.lean): columns {j₀, j₀+g}. g=1 is tubeSet (T9). */
export function gapTube(n, t, g, j0) { return colFamily(n, t, () => j0, () => j0 + g); }

/** lightTube t j₀ (Rule90Decoding.lean): cells {(i, j₀+i), (i, j₀+i+1)}. */
export function lightTube(n, t, j0) { return colFamily(n, t, i => j0 + i, i => j0 + i + 1); }

/** slopeTube p q t j₀ (Rule90Slope.lean): col i = j₀ + ⌊i·p/q⌋ (ℕ-division; q=0 → 0). */
export function slopeTube(n, t, p, q, j0) {
  const off = i => (q === 0 ? 0 : Math.floor((i * p) / q));
  return colFamily(n, t, i => j0 + off(i), i => j0 + off(i) + 1);
}

/** pairScreen t col (Rule90Lipschitz.lean): cells {(i, col i), (i, col i + 1)}.
    col = array of length t+1 of ring columns. pathScreen is the ℤ-path cast:
    identical cell set once the path is reduced mod n. */
export function pairScreen(n, t, col) {
  return colFamily(n, t, i => col[i], i => col[i] + 1);
}

/** Spacelike readout: row 0 minus the cells listed in `omit` (T9 complement). */
export function spacelikeRow(n, omit = []) {
  const skip = new Set(omit.map(j => mod(j, n)));
  const cells = [];
  for (let j = 0; j < n; j++) if (!skip.has(j)) cells.push({ i: 0, j });
  return cells;
}

/** 1-Lipschitz test for a ring path (Rule90Lipschitz.lean hypothesis
    |c(i+1) − c(i)| ≤ 1 in ℤ ⟺ every ring step has ringDist ≤ 1). */
export function isLipschitz(col, n) {
  for (let i = 0; i + 1 < col.length; i++) {
    if (ringDist(col[i + 1], col[i], n) > 1) return false;
  }
  return true;
}

// -------------------------------------------------------- readout algebra
// Cell functional: by translation equivariance, cell (i,j) reads
//   Σ_k seed(k) · stencil_i(j − k),   stencil_i := traj(δ₀) row i
// (the Sierpiński row; Lucas: stencil_i ∋ (2m − i) ⟺ C(i,m) odd).

/** Precompute stencils δ₀-trajectory (int path). ctx reusable across screens. */
export function makeCtx32(n, t) {
  return { n, t, stencil: traj32(1, n, t) };            // δ₀ = bit 0
}

/** Readout matrix row for cell (i,j): bit k set ⟺ seed e_k lights the cell. */
export function cellRow32(ctx, i, j) {
  const { n, stencil } = ctx;
  const s = stencil[i];
  let r = 0;
  for (let k = 0; k < n; k++) if ((s >>> mod(j - k, n)) & 1) r |= (1 << k);
  return r >>> 0;
}

export function readoutMatrix32(ctx, cells) {
  return cells.map(c => cellRow32(ctx, c.i, c.j));
}

export function makeCtxBS(n, t) {
  const d0 = bsNew(n); bsSet(d0, 0);
  return { n, t, stencil: trajBS(d0, n, t) };
}

export function cellRowBS(ctx, i, j) {
  const { n, stencil } = ctx;
  const s = stencil[i];
  const r = bsNew(n);
  for (let k = 0; k < n; k++) if (bsGet(s, mod(j - k, n))) bsSet(r, k);
  return r;
}

export function readoutMatrixBS(ctx, cells) {
  return cells.map(c => cellRowBS(ctx, c.i, c.j));
}

/**
 * Full screen analysis. Auto-selects int/bitset path.
 * Returns {bits, rank, kernel, isInformationSet, surjective, bijective}.
 *  · isInformationSet ⟺ rank = n           (isInformationSet_iff_vanishing)
 *  · surjective (all readings realizable) ⟺ rank = bits  (T31 direction)
 *  · kernel = ghost-seed basis (int or Uint32Array per path)
 */
export function analyzeScreen(n, t, cells, ctx) {
  if (n <= 30) {
    ctx = ctx || makeCtx32(n, t);
    const M = readoutMatrix32(ctx, cells);
    const ker = kernel32(M, n);
    const rank = n - ker.length;
    return { bits: cells.length, rank, kernel: ker, isInformationSet: rank === n,
             surjective: rank === cells.length, bijective: rank === n && rank === cells.length, path: 32 };
  }
  ctx = ctx || makeCtxBS(n, t);
  const M = readoutMatrixBS(ctx, cells);
  const ker = kernelBS(M, n);
  const rank = n - ker.length;
  return { bits: cells.length, rank, kernel: ker, isInformationSet: rank === n,
           surjective: rank === cells.length, bijective: rank === n && rank === cells.length, path: 'bs' };
}

/** Realizability of a screen reading (T27.4/T31): does any seed produce it? */
export function readingRealizable32(ctx, cells, values) {
  const M = readoutMatrix32(ctx, cells);
  return solve32(M, values, ctx.n);
}

// ------------------------------------------------ the propagation closure
// Inferable S (Rule90Propagation.lean), value-free form. Rules, with time
// i ∈ [0, t−1] (Lean's Fin t; castSucc = i, succ = i+1):
//   base :  p ∈ S
//   down :  (i, j−1), (i, j+1)  ⊢ (i+1, j)
//   left :  (i+1, j), (i, j+1)  ⊢ (i, j−1)
//   right:  (i+1, j), (i, j−1)  ⊢ (i, j+1)
// The fixpoint is computed in rounds; provenance is recorded for animation.

/**
 * Closure of a screen. Returns:
 *  {known: Uint8Array[(t+1)][n], round, prov, complete, count, rounds}
 *  prov[i][j] = {rule, parents:[[i,j],..]} for inferred cells (null for base/unknown).
 */
export function closure(n, t, cells) {
  const known = [], round = [], prov = [];
  for (let i = 0; i <= t; i++) {
    known.push(new Uint8Array(n));
    round.push(new Int16Array(n).fill(-1));
    prov.push(new Array(n).fill(null));
  }
  for (const c of cells) { known[c.i][c.j] = 1; round[c.i][c.j] = 0; prov[c.i][c.j] = { rule: 'base', parents: [] }; }
  let rd = 1, changed = true, count = cells.length;
  while (changed) {
    changed = false;
    const buf = [];
    for (let i = 0; i < t; i++) for (let j = 0; j < n; j++) {
      const jl = mod(j - 1, n), jr = mod(j + 1, n);
      const kd = known[i + 1][j], kl = known[i][jl], kr = known[i][jr];
      if (kl && kr && !kd) buf.push([i + 1, j, 'down', [[i, jl], [i, jr]]]);
      if (kd && kr && !kl) buf.push([i, jl, 'left', [[i + 1, j], [i, jr]]]);
      if (kd && kl && !kr) buf.push([i, jr, 'right', [[i + 1, j], [i, jl]]]);
    }
    for (const [i, j, rule, parents] of buf) {
      if (!known[i][j]) { known[i][j] = 1; round[i][j] = rd; prov[i][j] = { rule, parents }; changed = true; count++; }
    }
    if (changed) rd++;
  }
  const total = (t + 1) * n;
  return { known, round, prov, complete: count === total, count, total, rounds: rd - 1 };
}

/** Valued decode along the closure (uses the same three rules with XOR). */
export function decode(n, t, cells, trajRows, bitAt) {
  const known = [], round = [], val = [];
  for (let i = 0; i <= t; i++) { known.push(new Uint8Array(n)); round.push(new Int16Array(n).fill(-1)); val.push(new Uint8Array(n)); }
  for (const c of cells) { known[c.i][c.j] = 1; round[c.i][c.j] = 0; val[c.i][c.j] = bitAt(trajRows[c.i], c.j); }
  let rd = 1, changed = true;
  while (changed) {
    changed = false;
    const buf = [];
    for (let i = 0; i < t; i++) for (let j = 0; j < n; j++) {
      const jl = mod(j - 1, n), jr = mod(j + 1, n);
      const kd = known[i + 1][j], kl = known[i][jl], kr = known[i][jr];
      if (kl && kr && !kd) buf.push([i + 1, j, val[i][jl] ^ val[i][jr]]);
      else if (kd && kr && !kl) buf.push([i, jl, val[i + 1][j] ^ val[i][jr]]);
      else if (kd && kl && !kr) buf.push([i, jr, val[i + 1][j] ^ val[i][jl]]);
    }
    for (const [i, j, v] of buf) if (!known[i][j]) { known[i][j] = 1; round[i][j] = rd; val[i][j] = v; changed = true; }
    if (changed) rd++;
  }
  let unknown = 0;
  for (let i = 0; i <= t; i++) for (let j = 0; j < n; j++) if (!known[i][j]) unknown++;
  return { known, round, val, maxRound: rd - 1, unknown };
}

// ------------------------------------------------------------ predictions
// Each returns {is: bool|null, closure: 'complete'|'screen-only'|'partial'|null,
//               name, lean, why, open?:bool} — null means "no theorem covers
//               this; the live rank is the authority".

export const gcd = (a, b) => { a = Math.abs(a); b = Math.abs(b); while (b) [a, b] = [b, a % b]; return a; };

/** T25 / T9 / T20+T37 / T30 for the two-column screen at stride g. */
export function predictGapTube(n, t, g) {
  const thr = n <= 2 * (t + 1);
  if (n === 1) return { is: true, closure: 'complete', d: 0, name: 'n = 1', lean: 'gapTube_isInformationSet_iff (T25)',
    closureLean: '—', closureWhy: 'one-column ring: every cell is a screen cell',
    why: 'gcd(g, 1) = 1 and 1 ≤ 2(t+1): the degenerate ring decodes trivially' };
  const gg = mod(g, n);
  const d = gg === 0 ? 0 : ringDist(0, gg, n);
  const isIS = gcd(gg, n) === 1 && thr;                  // gapTube_isInformationSet_iff
  let cl, clLean, clWhy;
  if (n === 1) { cl = 'complete'; clLean = '—'; clWhy = 'one-column ring: every cell is a screen cell'; }
  else if (d === 0) { cl = null; clLean = '—'; clWhy = 'single column (g ≡ 0): no theorem needed — never an information set for n ≥ 2 (single_column_not_information_set)'; }
  else if (d === 1) { cl = thr ? 'complete' : 'partial'; clLean = 'adjacent_closure_complete (T30b)'; clWhy = 'adjacent columns: the sideways sweep fills the whole block at the sharp threshold'; }
  else if (d === 2) {
    cl = thr ? (n % 2 === 1 ? 'complete' : 'partial') : 'partial';
    clLean = 'gapTwo_closure_complete_iff_odd (T37)';
    clWhy = n % 2 === 1
      ? 'odd ring: middle column enclosed → two pair-fans fill row 1 → the crawl wraps row 0 in steps of 2 (2·(m+1) ≡ 1 mod 2m+1)'
      : 'even ring: rows ≥ 1 fill, but the row-0 crawl only reaches even offsets — and the checkerboard ghost certifies the screen fails anyway';
  } else {
    cl = 'screen-only'; clLean = 'gapTube_inferable_iff (T30a)';
    clWhy = `ring-distance ${d} ≥ 3: no Rule-90 constraint touches two screen cells — the closure is the screen itself, zero bulk inferences at every horizon`;
  }
  return {
    is: isIS, closure: cl, closureLean: clLean, closureWhy: clWhy, d,
    name: gg === 0 ? 'width-1' : (d === 1 ? 'T9' : d === 2 ? 'T20 · T37' : 'T25'),
    lean: gg === 0 ? 'single_column_not_information_set' : 'gapTube_isInformationSet_iff (T25)',
    why: gg === 0
      ? 'the two read columns coincide; a mirror-pair ghost is dark on one column forever'
      : (gcd(gg, n) === 1
        ? (thr ? 'gcd(g,n) = 1 and n ≤ 2(t+1): two dark columns are two mirrors whose composition walks the ring and traps the seed'
               : 'coprime, but the horizon is too short: |S| = 2(t+1) < n cells cannot pin n unknowns (counting bound)')
        : `gcd(${gg}, ${n}) = ${gcd(gg, n)} ≠ 1: the ring folds onto a ${gcd(gg, n)}-quotient where both columns coincide — the lifted mirror-pair ghost is never visible`),
  };
}

/** T18a: the boosted tube keeps the exact threshold. */
export function predictLightTube(n, t) {
  const thr = n <= 2 * (t + 1);
  return { is: thr, closure: thr ? 'complete' : 'partial', name: 'T18a',
    lean: 'lightTube_isInformationSet_iff',
    closureLean: 'pathScreen_closure_complete (T36, c(i) = i)',
    why: 'the boosted screen is the 1-Lipschitz worldline c(i) = i: same sharp threshold n ≤ 2(t+1), one sweep front at double speed' };
}

/** T36: any 1-Lipschitz worldline. col = ring path array. */
export function predictPairScreen(n, t, col) {
  if (isLipschitz(col, n)) {
    const thr = n <= 2 * (t + 1);
    return { is: thr, closure: thr ? 'complete' : 'partial', name: 'T36',
      lean: 'pathScreen_isInformationSet_iff · pathScreen_closure_complete',
      closureLean: 'pathScreen_closure_complete (T36a)',
      why: thr
        ? '1-Lipschitz worldline at the sharp threshold: the two-chain fan fills every level of the light-cone interval — completely locally decodable, uniformly in the path'
        : '1-Lipschitz, but n > 2(t+1): the screen has fewer cells than unknowns (counting bound)' };
  }
  // Beyond Lipschitz: no general theorem. Kernel-checked walls at (6,2), (8,3), (10,4).
  const wall = beyondLipschitzWall(n, t, col);
  return { is: null, closure: null, name: 'beyond T36', open: true,
    lean: wall ? wall.lean : 'no theorem — live rank is the authority',
    why: wall ? wall.why
      : 'superluminal worldline: outside the Lipschitz class the landscape is provably wild — the live 𝔽₂ rank below is the authority (this is the ONE open mathematics item: arbitrary subsets)' };
}

/** The kernel-checked beyond-Lipschitz instances (Rule90Lipschitz.lean §Instances). */
export function beyondLipschitzWall(n, t, col) {
  if (n === 6 && t === 2) {
    const ok = ringDist(col[2], col[1], 6) <= 1;
    return { lean: 'pairScreen_class_6_2 (kernel-checked, all 216 triples)',
      expected: ok,
      why: `(6,2) is completely classified: decodes ⟺ ringDist(c₁, c₂) ≤ 1 — the LAST step must be Lipschitz, the first is free. Here ringDist = ${ringDist(col[2], col[1], 6)} → ${ok ? 'decodes' : 'fails'}.` };
  }
  if (n === 8 && t === 3) {
    return { lean: 'pairScreen_slope2_8_3 · pairScreen_teleport_8_3 (+ sweep: all 8³ paths)',
      expected: true,
      why: '(8,3): ALL paths decode at exact capacity — even teleports. The (6,2) last-step rule does not generalize.' };
  }
  if (n === 10 && t === 4) {
    return { lean: 'pairScreen_slope2_fails_10_4 · pairScreen_late_jump_fails_10_4 · pairScreen_early_jump_10_4',
      expected: null,
      why: '(10,4): the (8,3) universality dies — the slope-2 line and late jumps FAIL at exact capacity while the early jump decodes. Order matters; no coarse invariant survives.' };
  }
  return null;
}

/** T9 complement: proper subsets of row 0 never decode; the full row is the identity. */
export function predictSpacelike(n, omittedCount) {
  if (omittedCount === 0) return { is: true, closure: 'complete', name: 'row 0', lean: '—', why: 'the full seed row is the identity readout' };
  return { is: false, closure: 'partial', name: 'T9 complement', lean: 'spacelike_proper_subset_fails',
    why: 'a proper subset of one row is never an information set — a δ-ghost lives at any omitted cell' };
}

/** Universal counting bound (Rule90Decoding.lean). */
export function countingBound(n, cellCount) { return cellCount >= n; }

// ------------------------------------------------------------ shadow atlas
// S fails ⟺ S ⊆ Z(z) for some ghost z ≠ 0, Z(z) = the zero-set of z's
// trajectory. The MAXIMAL Z(z) form an antichain that IS the arbitrary-subset
// classification for (n,t). Exact enumeration for n ≤ ~16 (int path).

/** Zero-set of seed z as an array of Uint32Array bitmask over cells (row-major i*n+j). */
export function zeroSetMask(n, t, z) {
  const rows = traj32(z, n, t);
  const total = (t + 1) * n;
  const m = new Uint32Array((total + 31) >>> 5);
  for (let i = 0; i <= t; i++) for (let j = 0; j < n; j++) {
    if (!((rows[i] >>> j) & 1)) m[(i * n + j) >>> 5] |= (1 << ((i * n + j) & 31));
  }
  return m;
}

const maskSubset = (a, b) => { for (let i = 0; i < a.length; i++) if ((a[i] & ~b[i]) !== 0) return false; return true; };
const maskEq = (a, b) => { for (let i = 0; i < a.length; i++) if (a[i] !== b[i]) return false; return true; };

/**
 * All maximal ghost zero-sets for (n, t), n ≤ 20 (2^n − 1 seeds enumerated).
 * Returns array of {mask, seeds: [one representative seed], size}.
 * S ⊆ some maximal zero-set ⟺ S is NOT an information set.
 */
export function maximalShadows(n, t) {
  const total = (t + 1) * n;
  const items = [];
  const seen = new Map();
  for (let z = 1; z < (1 << n); z++) {
    const m = zeroSetMask(n, t, z);
    const key = Array.from(m).join(',');
    const e = seen.get(key);
    if (e) { e.count++; continue; }
    const it = { mask: m, seed: z, count: 1, size: 0 };
    for (let w = 0; w < m.length; w++) it.size += popcount32(m[w]);
    seen.set(key, it); items.push(it);
  }
  // antichain of maximal masks (sorted by size desc, a subset can only follow
  // its superset; exact duplicates were already merged via `seen`)
  items.sort((a, b) => b.size - a.size);
  const maximal = [];
  outer: for (const it of items) {
    for (const M of maximal) if (maskSubset(it.mask, M.mask)) continue outer;
    maximal.push(it);
  }
  return { maximal, distinctZeroSets: items.length, totalCells: total };
}

/** Does the cell set (list of {i,j}) fit inside the given shadow mask? */
export function cellsInsideMask(cells, mask, n) {
  for (const c of cells) {
    const k = c.i * n + c.j;
    if (!((mask[k >>> 5] >>> (k & 31)) & 1)) return false;
  }
  return true;
}
