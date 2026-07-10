/* ============================================================================
   exact.js — physics-wing mathematics, transcribed from the Lean tree.
   Every constant carries the module it comes from and (in BRACKETS) the
   theorem-form interval the Lean file proves; the self-test battery checks
   each recomputed value against its bracket.

   Sources: LedgerNumerics.lean (T24), EnergyCage.lean (G10/T10), PBranches
   (T11), CollarGate (T16), DarkSector (T15), HexacodePort (T19/T22),
   ModularCore/ModularFlow (T21/T28/T33), Hypercharge (T13), CenterZ6,
   ConsensusSafety (T23), ChannelBridge (T29), DeltaSBridge (T17).
   ========================================================================= */

// --------------------------------------------------------------- constants

export const CONST = {
  // LedgerNumerics.lean declared inputs
  g: 9.80665,            // m/s² (ledger)
  G: 6.67430e-11,        // ledger G
  A: 4.8e-3,             // m² device area
  Fmin: 5e-8,            // N lock-in floor input
  Ebatt: 3.6e4,          // J battery coupon
  sigma1: 1e-6, neff: 1800,
  // EnergyCage.lean §5 inputs (note: cage uses 9.81 and 6.674e-11)
  gCage: 9.81, GCage: 6.674e-11,
  ME: 5.972e24, RE: 6.371e6,
  dM: 0.056,             // kg phantom-mass cap at design point
  c: 2.99792458e8,
  // PBranches.lean
  alphaInv: 137.035999177,
  Proot: 1.63097209569,  // the executed solver's root (literal in the tree)
  // Dark sector display scale (RAR a₀; the Lean theorems are scale-free)
  a0: 1.2e-10,
  MSUN: 1.989e30, KPC: 3.0857e19,
};

/** All derived quantities, each with its Lean bracket [lo, hi] and name. */
export function derived() {
  const C = CONST;
  const Cgeom = C.g ** 2 / (4 * Math.PI * C.G);
  const CgeomA = Cgeom * C.A;
  const PhiN = C.GCage * C.ME / C.RE;
  const phi = (1 + Math.sqrt(5)) / 2;
  const Ppub = phi + Math.sqrt(Math.PI) / C.alphaInv;
  const out = {
    Cgeom:      { v: Cgeom, br: [1.146636e11, 1.146638e11], lean: 'Cgeom_bounds', unit: 'N/m² per unit Δν·g', desc: 'C_geom = g²/4πG' },
    CgeomA:     { v: CgeomA, br: [5.5038e8, 5.5039e8], lean: 'CgeomA_bounds', unit: 'N per unit Δν', desc: 'one-zone C_geom·A' },
    dnuMin:     { v: C.Fmin / CgeomA, br: [9.084e-17, 9.085e-17], lean: 'dnu_min_bounds', unit: '', desc: 'null bound Δν_min = F_min/(C_geom·A) — printed 9.1e-17 rounds the safe way' },
    designF:    { v: CgeomA * 1e-9, br: [0.55038, 0.55039], lean: 'design_force_bounds', unit: 'N', desc: 'design force at Δν = 1e-9' },
    designGf:   { v: CgeomA * 1e-9 * 1000 / C.g, br: [56.12, 56.13], lean: 'design_gf_bounds', unit: 'gf', desc: 'design force in gram-force' },
    designSNR:  { v: CgeomA * 1e-9 / C.Fmin, br: [1.100e7, 1.101e7], lean: 'design_snr_bounds', unit: '', desc: 'design SNR vs the 5e-8 N floor' },
    lockin:     { v: C.sigma1 * Math.sqrt(2 / C.neff), br: [1e-6 / 30 - 1e-22, 1e-6 / 30 + 1e-22], lean: 'lockin_stat_exact', unit: 'N', desc: 'σ_F = 1e-6·√(2/1800) = 1e-6/30 exactly' },
    batteryLo:  { v: C.Ebatt / 6.26e7 * C.g / CgeomA, br: [1.02e-11, 1.03e-11], lean: 'battery_coupon_bounds (Φ high end)', unit: '', desc: 'battery-coupon Δν ceiling — the ERRATUM row (printed ≲1e-11 was ~3% low, unsafe direction)' },
    batteryHi:  { v: C.Ebatt / 6.24e7 * C.g / CgeomA, br: [1.02e-11, 1.03e-11], lean: 'battery_coupon_bounds (Φ low end)', unit: '', desc: 'battery ceiling, other Φ endpoint' },
    sigmaPh:    { v: (1e-9 * C.gCage) / (4 * Math.PI * C.GCage), br: [11.6, 11.8], lean: 'sigma_ph_value', unit: 'kg/m²', desc: 'phantom areal density at Δν = 1e-9' },
    PhiN:       { v: PhiN, br: [6.24e7, 6.26e7], lean: 'phi_N_value', unit: 'J/kg', desc: 'Earth-surface potential Φ_N = GM_E/R_E' },
    toggleE:    { v: C.dM * PhiN, br: [3.49e6, 3.52e6], lean: 'toggle_energy_value', unit: 'J', desc: 'G10-convention toggle price ΔM·Φ_N (≈ 3.5 MJ) — a declared convention' },
    benchW:     { v: C.dM * C.gCage * 1, br: [0.549, 0.550], lean: 'bench_cycle_work_value', unit: 'J', desc: 'theorem-forced cycle work ΔM·g·Δh (1 m stroke)' },
    massE:      { v: C.dM * C.c ** 2, br: [5.03e15, 5.04e15], lean: 'mass_energy_value', unit: 'J', desc: 'creation ceiling ΔM·c²' },
    Ppub:       { v: Ppub, br: [1.630968209403959, 1.630968209403960], lean: 'Ppub_bounds', unit: '', desc: 'P_pub = φ + √π/137.035999177 (CODATA-α by definition)' },
    ProotGap:   { v: C.Proot - Ppub, br: [3.8e-6, 4.0e-6], lean: 'Proot_gap', unit: '', desc: 'the two P branches differ (~300 ppm in α-space)' },
    chiPub:     { v: Math.exp(-Ppub / 24), br: [0.934300639, 0.93430064], lean: 'chiCanPub_bounds', unit: '', desc: 'χ_can^pub = e^{−P_pub/24} — the L2.10 falsification target' },
    chiRoot:    { v: Math.exp(-C.Proot / 24), br: [0.934300487, 0.934300489], lean: 'chiCanRoot_bounds', unit: '', desc: 'χ_can^root = e^{−P_root/24}' },
    chiGap:     { v: Math.exp(-Ppub / 24) - Math.exp(-C.Proot / 24), br: [1.4e-7, 1.6e-7], lean: 'chi_branch_gap', unit: '', desc: 'Δχ between the branches — 8th digit, immaterial for the experiment, decisive against "zero fitted parameters"' },
  };
  return out;
}

// -------------------------------------------------- collar gate (T16/T29)

/** lambdaCollar (CollarGate.lean): Σ w·e^{−ε}. */
export const lambdaCollar = (w, eps) => w.reduce((s, wi, i) => s + wi * Math.exp(-eps[i]), 0);

/** uniform_gate: all ε = P/24 ⇒ λ = e^{−P/24}. jensen_band: mean ε = P/24 ⇒ e^{−P/24} ≤ λ ≤ 1. */
export const chiOf = P => Math.exp(-P / 24);

/** channel_composite (ChannelBridge.lean, T29):
    λ_collar·(𝓛𝒩)(q) = e^{−P/24}·S·A(q) under slice-wise unbiasedness.
    Here for a finite register: active(q,e) booleans, weights a_e, footprint b_e, strength S. */
export function channelComposite({ w, eps, a, b, S, active }) {
  const lam = lambdaCollar(w, eps);
  // (𝓛𝒩)(q) = S·Σ_e b_e·(𝒩(activate q e) − 𝒩(q)) = S·Σ_e b_e·a_e·(1 − active_e)  (gen_count, B.7)
  const genN = S * b.reduce((s, be, e) => s + be * a[e] * (active[e] ? 0 : 1), 0);
  const avail = b.reduce((s, be, e) => s + be * a[e] * (active[e] ? 0 : 1), 0);
  return { lam, genN, lhs: lam * genN, availA: avail, rhs: null, S };
}

// ---------------------------------------------------- dark sector (T15)

export const activation = (lam, x) => 1 - Math.exp(-(lam * Math.sqrt(x)));
export const nuOPH = (lam, x) => 1 / activation(lam, x);
/** Point-source phantom cumulative mass M_A(r) = M_b/(e^{λ r_M/r} − 1). */
export const MA = (Mb, lam, rM, r) => Mb / (Math.exp(lam * rM / r) - 1);
/** Its density: M_A′(r) = 4π r² ρ_A(r) (hasDerivAt_MA). */
export const rhoA = (Mb, lam, rM, r) => {
  const e = Math.exp(lam * rM / r);
  return Mb * lam * rM * e / (4 * Math.PI * r ** 4 * (e - 1) ** 2);
};

// ------------------------------------------------------ hexacode (T19/T22)

/* 𝔽₄ = {0, 1, ω, ω̄} as 0..3; ω·ω = ω̄, ω·ω̄ = 1; conj = Frobenius x². */
export const F4mul = (a, b) => { if (!a || !b) return 0; const lg = [, 0, 1, 2], ex = [1, 2, 3]; return ex[(lg[a] + lg[b]) % 3]; };
export const F4add = (a, b) => a ^ b;
export const F4conj = a => (a < 2 ? a : (a === 2 ? 3 : 2));
export const F4NAME = ['0', '1', 'ω', 'ω̄'];

/** Generator matrix G (HexacodePort.lean): rows over 𝔽₄, ω = 2. */
export const HEXG = [
  [1, 0, 0, 1, 1, 2],
  [0, 1, 0, 1, 2, 1],
  [0, 0, 1, 2, 1, 1],
];

export function hexEncode(m) {
  const c = [0, 0, 0, 0, 0, 0];
  for (let j = 0; j < 6; j++) for (let i = 0; i < 3; i++) c[j] ^= F4mul(m[i], HEXG[i][j]);
  return c;
}

export function hexAll() {
  const all = [];
  for (let a = 0; a < 4; a++) for (let b = 0; b < 4; b++) for (let c = 0; c < 4; c++) all.push(hexEncode([a, b, c]));
  return all;
}

export const hexWeight = w => w.filter(x => x !== 0).length;
export const hexHermInner = (x, y) => { let s = 0; for (let j = 0; j < 6; j++) s ^= F4mul(x[j], F4conj(y[j])); return s; };

// ------------------------------------- modular core / flow (T21/T28/T33)

/* Complex scalars as [re, im]; 2×2 complex matrices as [[c,c],[c,c]]. */
export const cx = (re, im = 0) => [re, im];
export const cadd = (a, b) => [a[0] + b[0], a[1] + b[1]];
export const csub = (a, b) => [a[0] - b[0], a[1] - b[1]];
export const cmul = (a, b) => [a[0] * b[0] - a[1] * b[1], a[0] * b[1] + a[1] * b[0]];
export const cabs = a => Math.hypot(a[0], a[1]);
export const cexp = a => { const r = Math.exp(a[0]); return [r * Math.cos(a[1]), r * Math.sin(a[1])]; };

export const m2 = () => [[cx(0), cx(0)], [cx(0), cx(0)]];
export function mmul(A, B) {
  const C = m2();
  for (let i = 0; i < 2; i++) for (let j = 0; j < 2; j++) for (let k = 0; k < 2; k++) C[i][j] = cadd(C[i][j], cmul(A[i][k], B[k][j]));
  return C;
}
export const mtrace = A => cadd(A[0][0], A[1][1]);
export const mdiag = (a, b) => [[a, cx(0)], [cx(0), b]];
export function mrandom(rng = Math.random) {
  const r = () => cx(rng() - 0.5, rng() - 0.5);
  return [[r(), r()], [r(), r()]];
}

/** ω(A) = tr(ρA); Δ_ρ(A) = ρAρ⁻¹ for ρ = diag(p, 1−p). */
export function qubitRho(p) { return mdiag(cx(p), cx(1 - p)); }
export function qubitRhoInv(p) { return mdiag(cx(1 / p), cx(1 / (1 - p))); }
export const state = (rho, A) => mtrace(mmul(rho, A));
export const modular = (rho, rhoInv, A) => mmul(rho, mmul(A, rhoInv));

/** σ_z(B) = e^{izH} B e^{−izH}, H = −log ρ = diag(−log p, −log(1−p)); z complex. */
export function qubitFlow(p, z, B) {
  const h = [-Math.log(p), -Math.log(1 - p)];
  const u = k => cexp(cmul(cx(0, 1), cmul(z, cx(h[k]))));  // e^{iz h_k}
  const ui = k => cexp(cmul(cx(0, -1), cmul(z, cx(h[k])))); // e^{−iz h_k}
  const C = m2();
  for (let i = 0; i < 2; i++) for (let j = 0; j < 2; j++) C[i][j] = cmul(u(i), cmul(B[i][j], ui(j)));
  return C;
}

/** KMS boundary residual |ω(A·σ_{t+i}(B)) − ω(σ_t(B)·A)| (kms_boundary, T28). */
export function kmsStripResidual(p, t, A, B) {
  const rho = qubitRho(p);
  const lhs = state(rho, mmul(A, qubitFlow(p, cx(t, 1), B)));
  const rhs = state(rho, mmul(qubitFlow(p, cx(t, 0), B), A));
  return cabs(csub(lhs, rhs));
}

/** Imaginary-time KMS residual |ω(A·Δρ(B)) − ω(BA)| (kms, T21). */
export function kmsResidual(p, A, B) {
  const rho = qubitRho(p), rhoInv = qubitRhoInv(p);
  const lhs = state(rho, mmul(A, modular(rho, rhoInv, B)));
  const rhs = state(rho, mmul(B, A));
  return cabs(csub(lhs, rhs));
}

// ----------------------------------------------------- hypercharge (T13)

/* Exact rational arithmetic on small fractions [num, den], den > 0. */
export const frac = (n, d = 1) => { if (d < 0) { n = -n; d = -d; } const g = gcdInt(Math.abs(n), d); return [n / g, d / g]; };
const gcdInt = (a, b) => { while (b) [a, b] = [b, a % b]; return a || 1; };
export const fadd = (a, b) => frac(a[0] * b[1] + b[0] * a[1], a[1] * b[1]);
export const fmul = (a, b) => frac(a[0] * b[0], a[1] * b[1]);
export const fneg = a => [-a[0], a[1]];
export const feq = (a, b) => a[0] * b[1] === b[0] * a[1];
export const fval = a => a[0] / a[1];
export const fstr = a => (a[1] === 1 ? `${a[0]}` : `${a[0]}/${a[1]}`);

/** The five constraints of Hypercharge.lean, N = colour count (rationals). */
export function anomalyResiduals(a, N = frac(3)) {
  const { YQ, Yu, Yd, YL, Ye, YH } = a;
  const s = (...xs) => xs.reduce(fadd, frac(0));
  const cube = x => fmul(fmul(x, x), x);
  return {
    yukawaUp:   s(YQ, YH, Yu),                                   // YQ + YH + Yu = 0
    yukawaDown: s(YQ, fneg(YH), Yd),                             // YQ − YH + Yd = 0
    yukawaLep:  s(YL, fneg(YH), Ye),                             // YL − YH + Ye = 0
    su2:        s(fmul(N, YQ), YL),                              // N·YQ + YL = 0
    grav:       s(fmul(N, s(fmul(frac(2), YQ), Yu, Yd)), fmul(frac(2), YL), Ye),
    su3:        s(fmul(frac(2), YQ), Yu, Yd),                    // 2YQ + Yu + Yd = 0
    cubic:      s(fmul(N, s(fmul(frac(2), cube(YQ)), cube(Yu), cube(Yd))), fmul(frac(2), cube(YL)), cube(Ye)),
  };
}

/** smAssignment (Hypercharge.lean): the unique solution at N=3, Y_L = −1/2. */
export const SM_ASSIGNMENT = {
  YQ: frac(1, 6), Yu: frac(-2, 3), Yd: frac(1, 3), YL: frac(-1, 2), Ye: frac(1), YH: frac(1, 2),
};

/** The ratio theorem: given YQ and N, the forced tuple. */
export function forcedAssignment(YQ, N = frac(3)) {
  return {
    YQ,
    YL: fneg(fmul(N, YQ)),
    YH: fmul(N, YQ),
    Yu: fneg(fmul(fadd(N, frac(1)), YQ)),
    Yd: fmul(fadd(N, frac(-1)), YQ),
    Ye: fmul(fmul(frac(2), N), YQ),
  };
}

// --------------------------------------------------------- ℤ₆ center

/** The six SM multiplets as (triality t, duality d, q = 6Y) — CenterZ6.lean. */
export const Z6_REPS = [
  { name: 'Q',  t: 1, d: 1, q: 1 },
  { name: 'u̅',  t: 2, d: 0, q: -4 },
  { name: 'd̅',  t: 2, d: 0, q: 2 },
  { name: 'L',  t: 0, d: 1, q: -3 },
  { name: 'e̅',  t: 0, d: 0, q: 6 },
  { name: 'H',  t: 0, d: 1, q: 3 },
];

/** phase(g, rep) for g = (a ∈ ℤ₃, b ∈ ℤ₂, θ ∈ ℝ/ℤ): t·a/3 + d·b/2 + q·θ mod 1. */
export const z6Phase = (a, b, theta, rep) => {
  const x = rep.t * a / 3 + rep.d * b / 2 + rep.q * theta;
  return x - Math.floor(x);
};
/** The generator g₀ᵏ = (k mod 3, k mod 2, k/6): kernel of the action ≅ ℤ₆. */
export const g0k = k => ({ a: mod6(k, 3), b: mod6(k, 2), theta: mod6(k, 6) / 6 });
const mod6 = (k, n) => ((k % n) + n) % n;

// -------------------------------------------------------------- QBFT (T23)

/** Two quorums of sizes qa, qb among nV nodes overlap in ≥ qa+qb−nV nodes (tight). */
export const quorumMinOverlap = (nV, qa, qb) => Math.max(0, qa + qb - nV);
/** qbft_safety needs overlap ≥ f+1 honest-containing: at n=3f+1, q=2f+1 → overlap f+1 exactly. */
export const qbftSafe = (nV, q, f) => quorumMinOverlap(nV, q, q) >= f + 1;

// ---------------------------------------------------------- energy cage

/** toggleCost/cycleWork identities (EnergyCage.lean). E: (pos, on) → ℝ. */
export const toggleCost = (E, q) => E(q, true) - E(q, false);
export const cycleWork = (E, q1, q2) => (E(q1, true) - E(q2, true)) + (E(q2, false) - E(q1, false));
