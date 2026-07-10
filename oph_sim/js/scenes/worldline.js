/* ============================================================================
   worldline.js — the T36 Lipschitz worldline lab.

   Draw ANY observer worldline on the ring (click cells / presets); the scene
   shows the adjacent-pair screen along it, the theorem verdict (T36 for
   1-Lipschitz paths; the kernel-checked walls beyond), the live 𝔽₂ rank, the
   fan-closure animation (the actual induction of inferable_fan_of_pairs),
   and the ghosts when decoding fails — including the PERMANENT ghost of the
   teleporting observer on n ≡ 2 (mod 4) rings (experiment E8).
   ========================================================================= */

import { mod, ringDist, analyzeScreen, pairScreen, closure, decode, isLipschitz,
         predictPairScreen, traj32, makeCtx32 } from '../lib/rule90.js';
import { el, badge, section, sliderRow, button, SpacetimeView, COLORS, mulberry32 } from '../lib/ui.js';

const S = {
  n: 12, t: 5, j0shift: 0,
  col: [],                    // the worldline: col[i] ∈ ℤ/n
  view: null, mode: 'values', // values | closure | ghost
  seed: 0, ghostIdx: 0,
  cl: null, shownRound: -1, animTimer: null,
  analysis: null, pred: null,
  els: {},
};

function defaultCol() { S.col = Array.from({ length: S.t + 1 }, () => Math.floor(S.n / 3)); }

const PRESETS = {
  'straight tube': (n, t) => Array.from({ length: t + 1 }, () => Math.floor(n / 3)),
  'light ray': (n, t) => Array.from({ length: t + 1 }, (_, i) => mod(i, n)),
  'slope 1/2': (n, t) => Array.from({ length: t + 1 }, (_, i) => mod(Math.floor(i / 2), n)),
  'slope 2/3': (n, t) => Array.from({ length: t + 1 }, (_, i) => mod(Math.floor(2 * i / 3), n)),
  'zigzag': (n, t) => Array.from({ length: t + 1 }, (_, i) => mod(Math.floor(n / 3) + (i % 2), n)),
  'drunken walk': (n, t) => { const rng = mulberry32((Math.random() * 1e9) | 0); const c = [Math.floor(n / 2)]; for (let i = 0; i < t; i++) c.push(mod(c[i] + Math.floor(rng() * 3) - 1, n)); return c; },
  'slope-2 line ⚡': (n, t) => Array.from({ length: t + 1 }, (_, i) => mod(2 * i, n)),
  'late jump ⚡': (n, t) => Array.from({ length: t + 1 }, (_, i) => (i === t ? 2 : 0)),
  'early jump ⚡': (n, t) => Array.from({ length: t + 1 }, (_, i) => (i >= t - 1 ? 2 : 0)),
  'teleport n/2 ⚡': (n, t) => Array.from({ length: t + 1 }, (_, i) => (i % 2 ? Math.floor(n / 2) : 0)),
  'random wild ⚡': (n, t) => { const rng = mulberry32((Math.random() * 1e9) | 0); return Array.from({ length: t + 1 }, () => Math.floor(rng() * n)); },
};

function cells() { return pairScreen(S.n, S.t, S.col); }

function recompute() {
  stopAnim();
  S.cl = null; S.shownRound = -1;
  S.analysis = analyzeScreen(S.n, S.t, cells());
  S.pred = predictPairScreen(S.n, S.t, S.col);
  if (S.mode === 'ghost' && S.analysis.kernel.length === 0) S.mode = 'values';
  if (S.seed === 0) S.seed = 1 << Math.floor(S.n / 2);
  S.seed &= (1 << S.n) - 1;
  render();
}

function stopAnim() { if (S.animTimer) { clearInterval(S.animTimer); S.animTimer = null; } }

function runFan() {
  stopAnim();
  S.mode = 'closure';
  S.cl = closure(S.n, S.t, cells());
  S.shownRound = 0;
  render();
  S.animTimer = setInterval(() => {
    S.shownRound++;
    if (S.shownRound > S.cl.rounds) { stopAnim(); }
    render();
  }, 380);
}

function paint(i, j) {
  const scr = new Set(cells().map(c => c.i * S.n + c.j));
  const onScreen = scr.has(i * S.n + j);
  const onPath = S.col[i] === j;
  let fill = COLORS.cellOff, stroke = null, glyph = null;
  if (S.mode === 'values') {
    const rows = traj32(S.seed, S.n, S.t);
    fill = ((rows[i] >>> j) & 1) ? COLORS.cellOn : COLORS.cellOff;
  } else if (S.mode === 'closure' && S.cl) {
    const r = S.cl.round[i][j];
    const known = S.cl.known[i][j] && r <= S.shownRound;
    if (known) {
      if (r === 0) fill = '#6b5420';
      else {
        const f = Math.min(1, r / Math.max(1, S.cl.rounds));
        fill = `rgb(${20 + 20 * (1 - f)}, ${120 + 100 * (1 - f) | 0}, ${90 + 30 * f | 0})`;
      }
    } else if (S.shownRound >= S.cl.rounds) {
      fill = S.analysis.rank === S.n ? '#3b2a5e' : '#4a1620';
    }
    if (S.cl.prov[i][j] && S.cl.prov[i][j].rule !== 'base' && S.cl.round[i][j] === S.shownRound) stroke = COLORS.green;
  } else if (S.mode === 'ghost') {
    const z = S.analysis.kernel[S.ghostIdx % S.analysis.kernel.length];
    const rows = traj32(z, S.n, S.t);
    fill = ((rows[i] >>> j) & 1) ? COLORS.mag : '#140a1e';
  }
  if (onScreen) stroke = stroke || COLORS.gold;
  if (onPath) glyph = '•';
  return { fill, stroke, strokeW: onScreen ? 2 : 1.4, glyph, glyphColor: '#0b0f22' };
}

function stepChips() {
  const parts = [];
  for (let i = 0; i < S.t; i++) {
    const d = ringDist(S.col[i + 1], S.col[i], S.n);
    parts.push(`<span style="color:${d <= 1 ? 'var(--green)' : 'var(--red)'}">${d}</span>`);
  }
  return parts.join(' ');
}

function render() {
  S.view.n = S.n; S.view.t = S.t;
  S.view.draw(paint);
  const P = S.els.panelBadges;
  const a = S.analysis, p = S.pred;
  const lip = isLipschitz(S.col, S.n);
  const thr = S.n <= 2 * (S.t + 1);
  let html = '<h2>Theorem verdict</h2>';
  const okTxt = p.is === null ? 'no theorem covers this worldline' : (p.is ? 'INFORMATION SET — completely locally decodable' : 'NOT an information set');
  html += `<div class="badge ${p.open ? 'open' : (p.is ? 'ok' : 'bad')}"><b>${p.name}</b>: <b>${okTxt}</b><br><span class="leanref">${p.lean}</span><br><span style="opacity:.85">${p.why}</span></div>`;
  const match = p.is === null ? null : (p.is === a.isInformationSet);
  html += `<div class="badge ${match === false ? 'warn' : 'ok'}">Live 𝔽₂ rank: <b>${a.rank}/${S.n}</b> ${a.isInformationSet ? '→ decodes' : `→ kernel dim ${S.n - a.rank} (ghosts exist)`} — ${match === null ? '<b>the rank is the authority</b> (this is the open arbitrary-subset territory)' : match ? 'matches the theorem ✓' : '⚠ MISMATCH (bug!)'}</div>`;
  html += `<div class="badge info kv">worldline steps (ringDist): ${stepChips()} → <b>${lip ? '1-Lipschitz (causal)' : 'superluminal'}</b> · n ${thr ? '≤' : '>'} 2(t+1) = ${2 * (S.t + 1)}</div>`;
  if (p.expectedNote) html += p.expectedNote;
  // beyond-Lipschitz wall instances
  const wallHits = [];
  if (S.n === 6 && S.t === 2) wallHits.push('you are AT the kernel-checked (6,2) wall: decode ⟺ the LAST step is Lipschitz (all 216 triples, pairScreen_class_6_2)');
  if (S.n === 8 && S.t === 3) wallHits.push('you are AT (8,3): ALL 512 paths decode — try any wild preset');
  if (S.n === 10 && S.t === 4) wallHits.push('you are AT (10,4): universality dies — slope-2 line and late jumps fail at exact capacity');
  if (wallHits.length) html += `<div class="badge open kv">${wallHits[0]}</div>`;
  // teleport permanent ghost
  const isTeleport = S.col.every((c, i) => c === (i % 2 ? mod(S.col[0] + S.n / 2, S.n) : S.col[0]));
  if (S.n % 2 === 0 && S.t >= 1 && isTeleport) {
    html += `<div class="badge ${(S.n / 2) % 2 === 1 ? 'bad' : 'ok'} kv"><b>the teleporting observer</b> (experiment E8): on rings with n/2 <b>odd</b> this worldline NEVER decodes at any horizon tried (kernel dim n/2 − 1) — at n=6 the ghost is the period-2 seed δ₂+δ₄ whose 2-cycle sits in antiphase with your jumps: <i>it is always dark exactly where you just looked</i>. With n/2 even it decodes at capacity. Here n/2 = ${S.n / 2} (${(S.n / 2) % 2 ? 'odd — permanently dark' : 'even — decodes at threshold'}).</div>`;
  }
  if (S.mode === 'closure' && S.cl) {
    const done = S.shownRound >= S.cl.rounds;
    html += `<h2>The fan (local propagation closure)</h2><div class="badge info kv">round <b>${Math.min(S.shownRound, S.cl.rounds)}</b>/${S.cl.rounds} · inferred <b>${S.cl.count - cells().length}</b> bulk cells${done ? (S.cl.complete ? ' · <b style="color:var(--green)">closure = the ENTIRE block ✓</b>' + (lip && thr ? ' — exactly T36a\'s pathScreen_closure_complete' : ' — beyond the theorem, observed live') : (a.isInformationSet ? ' · <b style="color:var(--violet)">stalled with the bulk determined</b> — determination without local derivability (the T30 split)' : ' · <b style="color:var(--red)">stalled; ghosts live in the dark cells</b>')) : ''}</div>`;
  }
  P.innerHTML = html;
  // mode buttons
  for (const [m, b] of Object.entries(S.els.modeBtns)) b.classList.toggle('toggled', S.mode === m);
  S.els.ghostBtn.classList.toggle('disabled', S.analysis.kernel.length === 0);
  S.els.ghostBtn.innerHTML = `ghost view ${S.analysis.kernel.length ? `(${S.analysis.kernel.length} basis ghost${S.analysis.kernel.length > 1 ? 's' : ''})` : '(none — decodes)'}`;
}

export default {
  title: 'Worldline lab (T36)',
  async mount({ stage, panel, banner, legend }) {
    defaultCol();
    stage.innerHTML = '';
    stage.append(
      el('div', { class: 'pagetitle', html: 'The Lipschitz worldline theorem — and the wild country beyond it' }),
      el('div', { class: 'pagesub', html: 'T36 (<span class="mono">Rule90Lipschitz.lean</span>): every observer moving at or below the lattice light speed — any zigzag, any reversal — reads the whole universe through the two cells at its feet, at the sharp threshold n ≤ 2(t+1), and can decode it by <i>local propagation alone</i>. Faster observers leave the theorem: click cells to bend the worldline (each row i has one path column c(i); the screen reads (i, c(i)) and (i, c(i)+1)) and watch the verdict machinery.' }),
    );
    const cnv = el('canvas', { class: 'block', style: 'height:56vh;min-height:340px;' });
    stage.append(el('div', { class: 'card' }, cnv));
    S.view = new SpacetimeView(cnv, {
      onCell: (i, j) => { S.col[i] = j; S.mode = S.mode === 'ghost' ? 'values' : S.mode; recompute(); },
    });

    // panel
    panel.innerHTML = '';
    const nS = sliderRow('ring size n', { min: 3, max: 28, value: S.n }, v => { S.n = v; S.col = S.col.map(c => mod(c, v)); recompute(); });
    const tS = sliderRow('horizon t', { min: 1, max: 16, value: S.t }, v => {
      const old = S.t; S.t = v;
      if (v > old) for (let i = old + 1; i <= v; i++) S.col[i] = S.col[old];
      S.col = S.col.slice(0, v + 1);
      recompute();
    });
    const presetSel = el('select', { style: 'width:100%' });
    for (const k of Object.keys(PRESETS)) presetSel.append(el('option', { value: k, html: k }));
    presetSel.value = 'straight tube';
    presetSel.addEventListener('change', () => { S.col = PRESETS[presetSel.value](S.n, S.t); recompute(); });
    const badges = el('div');
    const modeBtns = {
      values: button('values', () => { S.mode = 'values'; stopAnim(); render(); }, 'small'),
      closure: button('closure', () => { S.mode = 'closure'; if (!S.cl) { S.cl = closure(S.n, S.t, cells()); S.shownRound = S.cl.rounds; } render(); }, 'small'),
    };
    const ghostBtn = button('ghost view', () => {
      if (!S.analysis.kernel.length) return;
      if (S.mode === 'ghost') S.ghostIdx++;
      S.mode = 'ghost'; render();
    }, 'small ghostbtn');
    S.els = { panelBadges: badges, modeBtns, ghostBtn };
    panel.append(
      section('Worldline', el('div', { class: 'rowc' }, el('label', { html: 'preset' }), presetSel),
        el('div', { class: 'hint', html: '⚡ = superluminal presets. Click any cell in the diagram to move the path column of that row.' })),
      section('Parameters', nS.row, tS.row),
      badges,
      section('Run',
        button('▶ Run the fan', runFan, 'primary'),
        modeBtns.values, modeBtns.closure, ghostBtn,
        button('flip a seed bit', () => { S.seed ^= 1 << Math.floor(Math.random() * S.n); S.mode = 'values'; render(); }, 'small')),
      el('div', { class: 'hint', html: 'The fan animation IS the proof mechanism of <span class="mono">inferable_fan_of_pairs</span>: each round, any constraint with two known cells yields its third (down/left/right = the three directed readings of cell ← left ⊕ right). For 1-Lipschitz paths at threshold it provably fills the block (T36a); beyond Lipschitz you are in the open arbitrary-subset country — the Frontier scene maps it.' }),
    );
    legend('<span class="swatch" style="background:#ffc84d"></span>screen (gold frame) · <b>•</b> = path column c(i) · <span class="swatch" style="background:#39e08b"></span>inferred (closure) · <span class="swatch" style="background:#b37bff"></span>determined but not locally derivable · <span class="swatch" style="background:#ff4dd2"></span>ghost world');
    recompute();
  },
  showAgain() { recompute(); },
};
