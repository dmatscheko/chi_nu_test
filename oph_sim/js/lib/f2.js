/* ============================================================================
   f2.js — exact 𝔽₂ linear algebra for the OPH simulation.

   Two representations, one API contract:
   · int path  (n ≤ 30): a row is a JS number bitmask — used by the hot sweep
     loops (experiments, Monte Carlo) and by every scene with display-sized n.
   · bitset path (any n): a row is a Uint32Array — used by large-n scenes.

   Everything here is exact integer arithmetic; the two paths are
   cross-checked against each other in the self-test battery.
   ========================================================================= */

// ---------------------------------------------------------------- int path

/** Rank of a list of n-column rows (ints). Destructive on a copy. */
export function rank32(rows, n) {
  const a = Array.from(rows);
  let r = 0;
  for (let col = 0; col < n && r < a.length; col++) {
    const m = 1 << col;
    let p = -1;
    for (let k = r; k < a.length; k++) if (a[k] & m) { p = k; break; }
    if (p < 0) continue;
    [a[r], a[p]] = [a[p], a[r]];
    for (let k = 0; k < a.length; k++) if (k !== r && (a[k] & m)) a[k] ^= a[r];
    r++;
  }
  return r;
}

/**
 * RREF with pivot bookkeeping.
 * Returns {rank, pivots: [{row, col}], rref: int[]} for n-column int rows.
 */
export function rref32(rows, n) {
  const a = Array.from(rows);
  const pivots = [];
  let r = 0;
  for (let col = 0; col < n && r < a.length; col++) {
    const m = 1 << col;
    let p = -1;
    for (let k = r; k < a.length; k++) if (a[k] & m) { p = k; break; }
    if (p < 0) continue;
    [a[r], a[p]] = [a[p], a[r]];
    for (let k = 0; k < a.length; k++) if (k !== r && (a[k] & m)) a[k] ^= a[r];
    pivots.push({ row: r, col });
    r++;
  }
  return { rank: r, pivots, rref: a };
}

/** Right-kernel basis (seeds x with Mx = 0) as ints, one per free column. */
export function kernel32(rows, n) {
  const { pivots, rref } = rref32(rows, n);
  const pivotCols = new Set(pivots.map(p => p.col));
  const basis = [];
  for (let f = 0; f < n; f++) {
    if (pivotCols.has(f)) continue;
    let v = 1 << f;
    for (const { row, col } of pivots) if (rref[row] & (1 << f)) v |= (1 << col);
    basis.push(v >>> 0);
  }
  return basis;
}

/**
 * Solve M x = b over 𝔽₂ (int rows, rhs = array of 0/1 per row).
 * Returns {consistent, x} — x one solution (int) when consistent.
 */
export function solve32(rows, rhs, n) {
  const a = rows.map((m, i) => ({ m, b: rhs[i] & 1 }));
  let r = 0;
  const pivots = [];
  for (let col = 0; col < n && r < a.length; col++) {
    const msk = 1 << col;
    let p = -1;
    for (let k = r; k < a.length; k++) if (a[k].m & msk) { p = k; break; }
    if (p < 0) continue;
    [a[r], a[p]] = [a[p], a[r]];
    for (let k = 0; k < a.length; k++) if (k !== r && (a[k].m & msk)) { a[k].m ^= a[r].m; a[k].b ^= a[r].b; }
    pivots.push({ row: r, col });
    r++;
  }
  for (const row of a) if (row.m === 0 && row.b === 1) return { consistent: false, x: 0 };
  let x = 0;
  for (const { row, col } of pivots) if (a[row].b) x |= (1 << col);
  return { consistent: true, x: x >>> 0 };
}

export function popcount32(x) {
  x = x - ((x >> 1) & 0x55555555);
  x = (x & 0x33333333) + ((x >> 2) & 0x33333333);
  return (((x + (x >> 4)) & 0x0f0f0f0f) * 0x01010101) >> 24;
}

// ------------------------------------------------------------- bitset path

export const W = n => (n + 31) >>> 5;

export function bsNew(n) { return new Uint32Array(W(n)); }
export function bsGet(v, j) { return (v[j >>> 5] >>> (j & 31)) & 1; }
export function bsSet(v, j) { v[j >>> 5] |= (1 << (j & 31)); }
export function bsFlip(v, j) { v[j >>> 5] ^= (1 << (j & 31)); }
export function bsXor(a, b) { for (let i = 0; i < a.length; i++) a[i] ^= b[i]; }
export function bsCopy(a) { return a.slice(); }
export function bsIsZero(a) { for (let i = 0; i < a.length; i++) if (a[i]) return false; return true; }
export function bsPopcount(a) { let s = 0; for (let i = 0; i < a.length; i++) s += popcount32(a[i]); return s; }
export function bsFromInt(x, n) { const v = bsNew(n); v[0] = x >>> 0; if (W(n) > 1) v[1] = Math.floor(x / 2 ** 32) >>> 0; return v; }
export function bsToInt(v) { return (v[0] >>> 0) + (v.length > 1 ? v[1] * 2 ** 32 : 0); }

/** RREF for Uint32Array rows with n columns. Same contract as rref32. */
export function rrefBS(rows, n) {
  const a = rows.map(bsCopy);
  const pivots = [];
  let r = 0;
  for (let col = 0; col < n && r < a.length; col++) {
    let p = -1;
    for (let k = r; k < a.length; k++) if (bsGet(a[k], col)) { p = k; break; }
    if (p < 0) continue;
    [a[r], a[p]] = [a[p], a[r]];
    for (let k = 0; k < a.length; k++) if (k !== r && bsGet(a[k], col)) bsXor(a[k], a[r]);
    pivots.push({ row: r, col });
    r++;
  }
  return { rank: r, pivots, rref: a };
}

export function rankBS(rows, n) { return rrefBS(rows, n).rank; }

export function kernelBS(rows, n) {
  const { pivots, rref } = rrefBS(rows, n);
  const pivotCols = new Set(pivots.map(p => p.col));
  const basis = [];
  for (let f = 0; f < n; f++) {
    if (pivotCols.has(f)) continue;
    const v = bsNew(n);
    bsSet(v, f);
    for (const { row, col } of pivots) if (bsGet(rref[row], f)) bsSet(v, col);
    basis.push(v);
  }
  return basis;
}

/** Solve for bitset rows; rhs = array of 0/1. */
export function solveBS(rows, rhs, n) {
  const a = rows.map((m, i) => ({ m: bsCopy(m), b: rhs[i] & 1 }));
  let r = 0;
  const pivots = [];
  for (let col = 0; col < n && r < a.length; col++) {
    let p = -1;
    for (let k = r; k < a.length; k++) if (bsGet(a[k].m, col)) { p = k; break; }
    if (p < 0) continue;
    [a[r], a[p]] = [a[p], a[r]];
    for (let k = 0; k < a.length; k++) if (k !== r && bsGet(a[k].m, col)) { bsXor(a[k].m, a[r].m); a[k].b ^= a[r].b; }
    pivots.push({ row: r, col });
    r++;
  }
  for (const row of a) if (bsIsZero(row.m) && row.b === 1) return { consistent: false, x: null };
  const x = bsNew(n);
  for (const { row, col } of pivots) if (a[row].b) bsSet(x, col);
  return { consistent: true, x };
}

/** Probability a uniform random n×n 𝔽₂ matrix is invertible: ∏ (1 − 2^{−k}). */
export function randomMatrixInvertibleProb(n) {
  let p = 1;
  for (let k = 1; k <= n; k++) p *= 1 - 2 ** -k;
  return p;
}
