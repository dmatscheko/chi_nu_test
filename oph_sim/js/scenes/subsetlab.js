/* ============================================================================
   subsetlab.js — the Screen lab: THE open mathematics item, as an instrument.

   "Which arbitrary finite subsets S of Rule-90 spacetime cells are
   information sets?" is the chain's ONE remaining open math item (paper §26).
   This scene attacks it three ways:
     · build any S by clicking — live rank / kernel / ghosts / closure;
     · the SHADOW ATLAS: the maximal ghost zero-sets, which classify ALL
       subsets at once (S fails ⟺ S fits inside a maximal shadow) — with the
       two laws the atlas revealed (experiments E6/E9): on even rings the
       maximal shadows are EXACTLY the single-parity-class ghosts
       (2^{n/2+1}−2 of them); on odd rings ALL 2^n−1 zero-sets are
       pairwise incomparable;
     · Monte Carlo: how rare are tight information sets, against the random-
       matrix baseline ∏(1−2^{−k}) ≈ 0.2888.
   ========================================================================= */

import { mod, analyzeScreen, closure, traj32, makeCtx32, cellRow32,
         maximalShadows, cellsInsideMask, gapTube, lightTube } from '../lib/rule90.js';
import { kernel32, randomMatrixInvertibleProb } from '../lib/f2.js';
import { el, section, sliderRow, button, SpacetimeView, COLORS, mulberry32, fmtPct } from '../lib/ui.js';

const S = {
  n: 8, t: 3,
  sel: new Set(),             // selected cells as i*n+j keys
  view: null, mode: 'select', // select | ghost | shadow
  ghostIdx: 0, shadowIdx: 0,
  atlas: null, analysis: null, cl: null,
  mc: null, mcRunning: false,
  els: {},
};

function cellsList() { return [...S.sel].map(k => ({ i: Math.floor(k / S.n), j: k % S.n })); }

function recompute() {
  const cells = cellsList();
  S.analysis = cells.length ? analyzeScreen(S.n, S.t, cells) : { bits: 0, rank: 0, kernel: [], isInformationSet: S.n === 0 };
  S.cl = cells.length ? closure(S.n, S.t, cells) : null;
  if (S.n <= 16) {
    if (!S.atlas || S.atlas.n !== S.n || S.atlas.t !== S.t) {
      const t0 = performance.now();
      S.atlas = { n: S.n, t: S.t, ...maximalShadows(S.n, S.t), ms: performance.now() - t0 };
      S.shadowIdx = 0;
    }
  } else S.atlas = null;
  render();
}

function witnessShadow() {
  if (!S.atlas || S.analysis.isInformationSet || !S.sel.size) return null;
  const cells = cellsList();
  const idx = S.atlas.maximal.findIndex(M => cellsInsideMask(cells, M.mask, S.n));
  return idx >= 0 ? idx : null;
}

function paint(i, j) {
  const k = i * S.n + j;
  const inS = S.sel.has(k);
  let fill = COLORS.cellOff, stroke = inS ? COLORS.gold : null, glyph = null;
  if (S.mode === 'ghost' && S.analysis.kernel.length) {
    const z = S.analysis.kernel[S.ghostIdx % S.analysis.kernel.length];
    const rows = traj32(z, S.n, S.t);
    fill = ((rows[i] >>> j) & 1) ? COLORS.mag : '#140a1e';
  } else if (S.mode === 'shadow' && S.atlas && S.atlas.maximal.length) {
    const M = S.atlas.maximal[S.shadowIdx % S.atlas.maximal.length];
    const dark = (M.mask[k >>> 5] >>> (k & 31)) & 1;
    fill = dark ? '#232d55' : '#3a1220';        // dark blue = inside the shadow (ghost invisible there)
    if (!dark && inS) { stroke = COLORS.green; glyph = '!'; } // S escapes the shadow here
  } else if (S.cl && S.cl.known[i][j] && !inS) {
    fill = '#173a2c';
  }
  return { fill, stroke, strokeW: 2, glyph, glyphColor: COLORS.green };
}

const PRESETS = {
  'clear': () => new Set(),
  'adjacent tube (T9)': (n, t) => new Set(gapTube(n, t, 1, 0).map(c => c.i * n + c.j)),
  'gap-2 tube (T20/T37)': (n, t) => new Set(gapTube(n, t, 2, 0).map(c => c.i * n + c.j)),
  'light ray pair (T18a)': (n, t) => new Set(lightTube(n, t, 0).map(c => c.i * n + c.j)),
  'row 0 (identity)': (n) => new Set(Array.from({ length: n }, (_, j) => j)),
  'random tight (|S| = n)': (n, t) => {
    const rng = mulberry32((Math.random() * 1e9) | 0);
    const s = new Set();
    while (s.size < Math.min(n, (t + 1) * n)) s.add(Math.floor(rng() * (t + 1)) * n + Math.floor(rng() * n));
    return s;
  },
  'transversal (1 per column)': (n, t) => {
    const rng = mulberry32((Math.random() * 1e9) | 0);
    return new Set(Array.from({ length: n }, (_, j) => Math.floor(rng() * (t + 1)) * n + j));
  },
  'power-of-2 rows': (n, t) => {
    const s = new Set();
    for (const i of [1, 2, 4, 8]) if (i <= t) for (let j = 0; j < n; j += 2) s.add(i * n + j);
    return s;
  },
};

function runMC(size, samples = 4000) {
  if (S.mcRunning) return;
  S.mcRunning = true;
  const n = S.n, t = S.t, ctx = makeCtx32(n, t);
  const rng = mulberry32((Math.random() * 1e9) | 0);
  const hist = {}; let done = 0, isCount = 0;
  const chunk = () => {
    const N = Math.min(400, samples - done);
    for (let s = 0; s < N; s++) {
      const cells = []; const seen = new Set();
      while (cells.length < size) {
        const i = Math.floor(rng() * (t + 1)), j = Math.floor(rng() * n);
        const k = i * n + j;
        if (!seen.has(k)) { seen.add(k); cells.push({ i, j }); }
      }
      const ker = kernel32(cells.map(c => cellRow32(ctx, c.i, c.j)), n).length;
      hist[ker] = (hist[ker] || 0) + 1;
      if (ker === 0) isCount++;
    }
    done += N;
    S.mc = { size, samples: done, isCount, hist };
    renderMC();
    if (done < samples) setTimeout(chunk, 0);
    else S.mcRunning = false;
  };
  chunk();
}

function renderMC() {
  const c = S.els.mcCanvas, info = S.els.mcInfo;
  if (!S.mc) { info.innerHTML = '<span class="dimc">not run yet</span>'; return; }
  const { size, samples, isCount, hist } = S.mc;
  const base = randomMatrixInvertibleProb(S.n);
  info.innerHTML = `|S| = ${size}, ${samples} samples: <b class="goldc">P(information set) = ${fmtPct(isCount / samples, 2)}</b> vs random-matrix baseline <b>${fmtPct(base, 1)}</b> — Rule-90 structure makes random reads <i>much worse</i> than random bits (the Sierpiński rows are heavily correlated).`;
  const x = c.getContext('2d');
  const dpr = window.devicePixelRatio || 1;
  c.width = c.clientWidth * dpr; c.height = c.clientHeight * dpr;
  x.setTransform(dpr, 0, 0, dpr, 0, 0);
  const cw = c.clientWidth, ch = c.clientHeight;
  x.clearRect(0, 0, cw, ch);
  const keys = Object.keys(hist).map(Number).sort((a, b) => a - b);
  const max = Math.max(...Object.values(hist));
  const bw = Math.min(44, (cw - 20) / keys.length);
  keys.forEach((k, i) => {
    const h = (ch - 30) * hist[k] / max;
    x.fillStyle = k === 0 ? COLORS.green : COLORS.violet;
    x.fillRect(12 + i * bw, ch - 18 - h, bw - 6, h);
    x.fillStyle = COLORS.dim; x.font = '10px sans-serif'; x.textAlign = 'center';
    x.fillText(`dim ${k}`, 12 + i * bw + bw / 2 - 3, ch - 6);
    x.fillText(hist[k], 12 + i * bw + bw / 2 - 3, ch - 22 - h);
  });
}

function render() {
  S.view.n = S.n; S.view.t = S.t;
  S.view.draw(paint);
  const a = S.analysis, cells = cellsList();
  let html = '<h2>Verdict on S</h2>';
  if (!cells.length) html += '<div class="badge info">click cells to build a screen S</div>';
  else {
    const bound = cells.length >= S.n;
    html += `<div class="badge ${a.isInformationSet ? 'ok' : 'bad'}">|S| = <b>${cells.length}</b> · rank <b>${a.rank}/${S.n}</b> → <b>${a.isInformationSet ? 'INFORMATION SET' : `fails — kernel dim ${S.n - a.rank}`}</b>${cells.length === S.n && a.isInformationSet ? ' · <b>tight</b> (minimum possible size)' : ''}</div>`;
    if (!bound) html += `<div class="badge bad kv">counting bound: |S| = ${cells.length} &lt; n = ${S.n} — can never decode <span class="leanref">card_lt_not_informationSet</span></div>`;
    if (S.cl) {
      html += `<div class="badge info kv">closure: <b>${S.cl.count}/${S.cl.total}</b> cells locally derivable${S.cl.complete ? ' — complete' : a.isInformationSet ? ' — determined-but-global for the rest (the generic situation: experiment E4 found closure-completeness is nearly measure-zero among random tight information sets)' : ''}</div>`;
    }
    const w = witnessShadow();
    if (w !== null) html += `<div class="badge open kv">S fits inside maximal shadow #${w + 1} — one ghost is invisible on ALL of S. <span class="mono">view it in shadow mode →</span></div>`;
  }
  if (S.atlas) {
    const parity = S.n % 2 === 0;
    const expected = parity ? 2 * (2 ** (S.n / 2) - 1) : 2 ** S.n - 1;
    const lawOK = S.n <= 2 * (S.t + 1) ? (S.atlas.maximal.length === expected) : null;
    html += `<h2>The shadow atlas (${S.n}, ${S.t})</h2>`;
    html += `<div class="badge ${lawOK === false ? 'warn' : 'open'} kv"><b>${S.atlas.maximal.length}</b> maximal ghost shadows (of ${S.atlas.distinctZeroSets} distinct zero-sets, ${S.atlas.ms.toFixed(0)} ms). <b>S is an information set ⟺ S escapes every one of them.</b><br>` +
      (S.n <= 2 * (S.t + 1)
        ? (parity
          ? `<b>the even-ring law (E9/C1):</b> the maximal shadows are exactly the ${expected} single-parity-class ghosts ${lawOK ? '✓' : '✗ (!)'} — proof sketch: parity components' trajectories never overlap, so Z(z) ⊆ Z(z_even) always. The classification COMPRESSES from 2ⁿ−1 ghosts to 2^{n/2+1}−2.`
          : `<b>the odd-ring law (E9/C2):</b> ALL ${expected} zero-sets are pairwise incomparable ${lawOK ? '✓' : '✗ (!)'} — no ghost's blindness contains another's. The classification does not compress at all: odd rings are rigid.`)
        : 'below the screen threshold (n > 2(t+1)) — the laws above are stated at/above threshold')
      + '</div>';
  } else html += `<div class="badge info kv">shadow atlas available for n ≤ 16 (2ⁿ ghost enumeration)</div>`;
  S.els.badges.innerHTML = html;
  for (const [m, b] of Object.entries(S.els.modeBtns)) b.classList.toggle('toggled', S.mode === m);
  const shadowInfo = S.els.shadowInfo;
  if (S.mode === 'shadow' && S.atlas && S.atlas.maximal.length) {
    const M = S.atlas.maximal[S.shadowIdx % S.atlas.maximal.length];
    shadowInfo.innerHTML = `shadow <b>${(S.shadowIdx % S.atlas.maximal.length) + 1}/${S.atlas.maximal.length}</b> · ghost seed <span class="mono">${M.seed.toString(2).padStart(S.n, '0')}</span> · ${M.size} dark cells — any S inside the blue region is blind to this ghost`;
  } else if (S.mode === 'ghost' && S.analysis.kernel.length) {
    shadowInfo.innerHTML = `ghost ${(S.ghostIdx % S.analysis.kernel.length) + 1}/${S.analysis.kernel.length} · seed <span class="mono">${S.analysis.kernel[S.ghostIdx % S.analysis.kernel.length].toString(2).padStart(S.n, '0')}</span> — magenta trajectory is invisible on all of S`;
  } else shadowInfo.innerHTML = '';
}

export default {
  title: 'Screen lab',
  async mount({ stage, panel, legend }) {
    stage.innerHTML = '';
    stage.append(
      el('div', { class: 'pagetitle', html: 'The screen lab — the one open mathematics item, as an instrument' }),
      el('div', { class: 'pagesub', html: 'Everything the chain still leaves open in mathematics is a single question (paper §26): <b>which arbitrary cell subsets decode?</b> The decidable criterion is machine-checked (<span class="mono">isInformationSet_iff_vanishing</span>); the classification is not. Build any S — the lab shows the live verdict, the ghosts that defeat it, and the <b>shadow atlas</b>: the maximal ghost zero-sets that classify every subset at once. Two laws found by this lab\'s sweeps (E6/E9) are recorded as conjectures C1/C2 in FINDINGS.md.' }),
    );
    const row = el('div', { class: 'cardrow' });
    const cnv = el('canvas', { class: 'block', style: 'height:44vh;min-height:300px;' });
    const mcCanvas = el('canvas', { class: 'block', style: 'height:120px;' });
    const mcInfo = el('div', { class: 'hint' });
    row.append(
      el('div', { class: 'card', style: 'flex:2 1 480px' }, el('h3', { html: 'the block — click to toggle cells of S' }), cnv, el('div', { class: 'hint', id: 'shadowinfo' })),
      el('div', { class: 'card', style: 'flex:1 1 320px' }, el('h3', { html: 'Monte Carlo — how rare are tight information sets?' }), mcCanvas, mcInfo,
        el('div', {},
          button('sample 4000 at |S| = n', () => runMC(S.n), 'small'),
          button('|S| = n+2', () => runMC(S.n + 2), 'small')),
        el('div', { class: 'hint', html: 'Recorded at scale in the Beyond-Lipschitz scene: at (16,7) only 0.23% of random tight subsets decode; at (16,15) effectively none — depth hurts, because trajectories repeat and rows correlate. Baseline for uniform random 𝔽₂ matrices: 28.9%.' })),
    );
    stage.append(row);
    S.view = new SpacetimeView(cnv, {
      onCell: (i, j) => {
        if (S.mode !== 'select') { S.mode = 'select'; }
        const k = i * S.n + j;
        S.sel.has(k) ? S.sel.delete(k) : S.sel.add(k);
        recompute();
      },
    });

    panel.innerHTML = '';
    const badges = el('div');
    const shadowInfo = document.createElement('div'); // filled via els
    const nS = sliderRow('ring size n', { min: 3, max: 20, value: S.n }, v => { S.n = v; S.sel = new Set(); recompute(); });
    const tS = sliderRow('horizon t', { min: 0, max: 12, value: S.t }, v => { S.t = v; S.sel = new Set([...S.sel].filter(k => Math.floor(k / S.n) <= v)); recompute(); });
    const presetSel = el('select', { style: 'width:100%' });
    for (const k of Object.keys(PRESETS)) presetSel.append(el('option', { value: k, html: k }));
    presetSel.addEventListener('change', () => { S.sel = PRESETS[presetSel.value](S.n, S.t); S.mode = 'select'; recompute(); });
    const modeBtns = {
      select: button('build S', () => { S.mode = 'select'; render(); }, 'small'),
      ghost: button('ghosts', () => { if (S.analysis.kernel.length) { if (S.mode === 'ghost') S.ghostIdx++; S.mode = 'ghost'; render(); } }, 'small ghostbtn'),
      shadow: button('shadow atlas', () => { if (S.atlas && S.atlas.maximal.length) { if (S.mode === 'shadow') S.shadowIdx++; S.mode = 'shadow'; render(); } }, 'small'),
    };
    S.els = { badges, modeBtns, mcCanvas, mcInfo, shadowInfo: stage.querySelector('#shadowinfo') };
    panel.append(
      section('Parameters', nS.row, tS.row,
        el('div', { class: 'rowc' }, el('label', { html: 'preset' }), presetSel)),
      section('View', modeBtns.select, modeBtns.ghost, modeBtns.shadow,
        el('div', { class: 'hint', html: 'ghosts: cycle the kernel basis of YOUR S. shadow atlas: cycle the maximal blindness patterns of the whole (n,t) block — click again for the next one.' })),
      badges,
    );
    legend('<span class="swatch" style="background:#ffc84d"></span>cell of S · <span class="swatch" style="background:#173a2c"></span>in the closure of S · <span class="swatch" style="background:#ff4dd2"></span>ghost trajectory · <span class="swatch" style="background:#232d55"></span>inside a maximal shadow · <span style="color:var(--green)">!</span> = S escapes the shadow here');
    recompute();
  },
  showAgain() { recompute(); },
};
