/* ============================================================================
   phase.js — the phase diagrams: every classification theorem of the chain
   drawn as a live-computed map. Nothing here is baked — every pixel is a
   rank/closure computation running in your browser, with the theorem
   boundary drawn on top.
   ========================================================================= */

import { mod, ringDist, gcd, analyzeScreen, gapTube, pairScreen, closure, makeCtx32 } from '../lib/rule90.js';
import { el, section, sliderRow, drawHeatmap, COLORS, mulberry32 } from '../lib/ui.js';

const S = { strideT: 9, els: {} };

const C_LOCAL = '#2a8a5e', C_GLOBAL = '#7a5bd6', C_FAIL = '#5a1a28', C_EMPTY = '#131a38';

function drawNT() {
  const ns = Array.from({ length: 26 }, (_, i) => i + 2);   // n = 2..27
  const ts = Array.from({ length: 14 }, (_, i) => i);       // t = 0..13
  const grid = {};
  for (const t of ts) for (const n of ns) {
    const cells = gapTube(n, t, 1, 0);
    const a = analyzeScreen(n, t, cells);
    if (!a.isInformationSet) { grid[`${n},${t}`] = C_FAIL; continue; }
    const cl = closure(n, t, cells);
    grid[`${n},${t}`] = cl.complete ? C_LOCAL : C_GLOBAL;
  }
  drawHeatmap(S.els.nt, ns, ts, (ix, iy) => grid[`${ns[ix]},${ts[iy]}`], { xLabel: 'ring size n', yLabel: 'horizon t' });
  // theorem boundary n = 2(t+1): drawn as a note in the caption (cells left of it green)
}

function drawStride() {
  const t = S.strideT;
  const ns = Array.from({ length: 25 }, (_, i) => i + 3);   // n = 3..27
  const gs = Array.from({ length: 13 }, (_, i) => i + 1);   // g = 1..13
  const grid = {};
  for (const g of gs) for (const n of ns) {
    const cells = gapTube(n, t, g, 0);
    const a = analyzeScreen(n, t, cells);
    if (!a.isInformationSet) { grid[`${n},${g}`] = C_FAIL; continue; }
    const cl = closure(n, t, cells);
    grid[`${n},${g}`] = cl.complete ? C_LOCAL : C_GLOBAL;
  }
  drawHeatmap(S.els.stride, ns, gs, (ix, iy) => grid[`${ns[ix]},${gs[iy]}`], { xLabel: 'ring size n', yLabel: 'stride g' });
}

function drawWorldline() {
  const ns = Array.from({ length: 24 }, (_, i) => i + 2);
  const ts = Array.from({ length: 13 }, (_, i) => i);
  const rng = mulberry32(99);
  const grid = {};
  for (const t of ts) for (const n of ns) {
    const thr = n <= 2 * (t + 1);
    let allMatch = true;
    for (let k = 0; k < 4; k++) {
      const col = [Math.floor(rng() * n)];
      for (let i = 0; i < t; i++) col.push(mod(col[i] + Math.floor(rng() * 3) - 1, n));
      const a = analyzeScreen(n, t, pairScreen(n, t, col));
      if (a.isInformationSet !== thr) { allMatch = false; break; }
    }
    grid[`${n},${t}`] = allMatch ? (thr ? C_LOCAL : C_FAIL) : '#c9a227';
  }
  drawHeatmap(S.els.world, ns, ts, (ix, iy) => grid[`${ns[ix]},${ts[iy]}`], { xLabel: 'ring size n', yLabel: 'horizon t' });
}

export default {
  title: 'Phase maps',
  panel: false,
  async mount({ stage, legend }) {
    stage.innerHTML = '';
    const nt = el('canvas', { class: 'block', style: 'height:300px' });
    const stride = el('canvas', { class: 'block', style: 'height:300px' });
    const world = el('canvas', { class: 'block', style: 'height:300px' });
    S.els = { nt, stride, world };
    const strideSlider = sliderRow('horizon t', { min: 1, max: 14, value: S.strideT }, v => { S.strideT = v; drawStride(); });
    stage.append(
      el('div', { class: 'pagetitle', html: 'Phase maps — the classifications as landscapes' }),
      el('div', { class: 'pagesub', html: 'Every pixel = a live 𝔽₂ rank + a propagation closure in your browser. <span style="color:#2a8a5e">■</span> information set, locally decodable · <span style="color:#7a5bd6">■</span> information set, pinned only by global algebra (T30\'s split) · <span style="color:#5a1a28">■</span> not an information set.' }),
      el('div', { class: 'cardrow' },
        el('div', { class: 'card' }, el('h3', { html: 'the jewel: adjacent tube over (n, t) — T9 / T30b' }), nt,
          el('div', { class: 'hint', html: 'The boundary is the exact line n = 2(t+1) (tube_information_set_iff), and everything inside is green: for the adjacent tube, determination and local decodability coincide (adjacent_closure_complete). No violet anywhere — that is a theorem, not luck.' })),
        el('div', { class: 'card' }, el('h3', { html: 'stride g vs ring n — T25 / T30a / T37' }), stride, strideSlider.row,
          el('div', { class: 'hint', html: 'Red rows/columns = gcd(g, n) ≠ 1 (the coprimality classification, T25). Green = locally decodable: exactly ring-distance d(g,n) ≤ 1, or d = 2 on odd rings (T37). Violet = the T30a country: determined, but the closure is provably the screen itself — look at g = 3, n = 8 (the violet exhibit). The pattern IS number theory made visible.' })),
        el('div', { class: 'card' }, el('h3', { html: 'random 1-Lipschitz worldlines over (n, t) — T36' }), world,
          el('div', { class: 'hint', html: 'Four fresh random causal worldlines per pixel. Gold would mean "a worldline deviated from the straight tube\'s threshold" — there is none: the threshold is provably worldline-invariant across the whole Lipschitz class (pathScreen_isInformationSet_iff). This uniformity — not the individual verdicts — is T36\'s content.' }))),
    );
    drawNT(); drawStride(); drawWorldline();
    legend(null);
  },
  showAgain() { drawNT(); drawStride(); drawWorldline(); },
};
