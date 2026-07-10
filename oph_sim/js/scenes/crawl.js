/* ============================================================================
   crawl.js — T37: the gap-2 crawl, classified — plus T30's full ring-distance
   trichotomy. The spacetime diagram shows the closure filling in rounds; the
   ring dial shows row 0 as the crawl actually walks it: hops of two columns,
   wrapping the whole ring exactly when n is odd (2·(m+1) ≡ 1 mod 2m+1).
   ========================================================================= */

import { mod, ringDist, gcd, analyzeScreen, gapTube, closure, traj32,
         predictGapTube } from '../lib/rule90.js';
import { el, badge, section, sliderRow, button, SpacetimeView, COLORS } from '../lib/ui.js';

const S = {
  n: 11, g: 2, tAuto: true, t: 5,
  view: null, ring: null, cl: null, shownRound: -1, animTimer: null,
  analysis: null, els: {},
};

function threshT(n) { return Math.max(1, Math.ceil(n / 2) - 1); }
function curT() { return S.tAuto ? threshT(S.n) : S.t; }
function cells() { return gapTube(S.n, curT(), S.g, 0); }

function recompute() {
  stopAnim();
  const t = curT();
  S.cl = closure(S.n, t, cells());
  S.shownRound = S.cl.rounds;             // show final state by default
  S.analysis = analyzeScreen(S.n, t, cells());
  render();
}
function stopAnim() { if (S.animTimer) { clearInterval(S.animTimer); S.animTimer = null; } }
function runAnim() {
  stopAnim();
  S.shownRound = 0;
  render();
  S.animTimer = setInterval(() => {
    S.shownRound++;
    if (S.shownRound >= S.cl.rounds) stopAnim();
    render();
  }, 300);
}

function paint(i, j) {
  const t = curT();
  const scr = new Set(cells().map(c => c.i * S.n + c.j));
  const onScreen = scr.has(i * S.n + j);
  let fill = COLORS.cellOff, stroke = null;
  const r = S.cl.round[i][j];
  const known = S.cl.known[i][j] && r <= S.shownRound;
  if (known) {
    if (r === 0) fill = '#6b5420';
    else if (i === 0) fill = '#2a8a5e';                       // the crawl itself
    else fill = j === mod(S.g === 2 ? 1 : -1, S.n) && S.g === 2 && false ? '' : '#1f6b4a';
    if (r === S.shownRound && r > 0) stroke = COLORS.green;
  } else if (S.shownRound >= S.cl.rounds) {
    fill = S.analysis.isInformationSet ? '#3b2a5e' : '#3a1220';
  }
  if (onScreen) stroke = COLORS.gold;
  return { fill, stroke, strokeW: onScreen ? 2 : 1.6 };
}

function drawRing() {
  const c = S.els.ringCanvas;
  const dpr = window.devicePixelRatio || 1;
  const cw = c.clientWidth, ch = c.clientHeight;
  c.width = cw * dpr; c.height = ch * dpr;
  const x = c.getContext('2d');
  x.setTransform(dpr, 0, 0, dpr, 0, 0);
  x.clearRect(0, 0, cw, ch);
  const R = Math.min(cw, ch) / 2 - 26, cx0 = cw / 2, cy0 = ch / 2;
  const t = curT();
  // hop arrows first (behind)
  if (S.g === 2) {
    for (let j = 0; j < S.n; j++) {
      const r0 = S.cl.round[0][j], r2 = S.cl.round[0][mod(j + 2, S.n)];
      if (r0 >= 0 && r2 > 0 && r2 <= S.shownRound && r2 > r0) {
        const a0 = j / S.n * 2 * Math.PI - Math.PI / 2, a1 = mod(j + 2, S.n) / S.n * 2 * Math.PI - Math.PI / 2;
        x.strokeStyle = '#2a8a5e88'; x.lineWidth = 2;
        x.beginPath();
        x.arc(cx0, cy0, R - 14, a0, a1, false);
        x.stroke();
      }
    }
  }
  for (let j = 0; j < S.n; j++) {
    const a = j / S.n * 2 * Math.PI - Math.PI / 2;
    const px = cx0 + R * Math.cos(a), py = cy0 + R * Math.sin(a);
    const r = S.cl.round[0][j];
    const known = S.cl.known[0][j] && r <= S.shownRound;
    const isScreen = j === 0 || j === mod(S.g, S.n);
    x.beginPath(); x.arc(px, py, 10, 0, 2 * Math.PI);
    x.fillStyle = known ? (r === 0 ? '#6b5420' : '#2a8a5e') : (S.shownRound >= S.cl.rounds ? (S.analysis.isInformationSet ? '#3b2a5e' : '#3a1220') : '#1d2547');
    x.fill();
    if (isScreen) { x.strokeStyle = COLORS.gold; x.lineWidth = 2; x.stroke(); }
    x.fillStyle = '#8d97c5'; x.font = '9px sans-serif'; x.textAlign = 'center';
    x.fillText(j, px, py + 2.8);
  }
  x.fillStyle = '#8d97c5'; x.font = '10px sans-serif'; x.textAlign = 'center';
  x.fillText('row 0 — the seed ring; hops of 2 wrap ⟺ n odd', cw / 2, ch - 6);
}

function render() {
  const t = curT();
  S.view.n = S.n; S.view.t = t;
  S.view.draw(paint);
  drawRing();
  const p = predictGapTube(S.n, t, S.g);
  const a = S.analysis, cl = S.cl;
  const d = S.g === 0 ? 0 : ringDist(0, mod(S.g, S.n), S.n);
  const m = (S.n - 1) / 2;
  let html = '<h2>The classification, live</h2>';
  html += `<div class="badge ${p.is ? 'ok' : 'bad'}"><b>${p.name}</b> predicts: <b>${p.is ? 'information set' : 'NOT an information set'}</b> — live rank <b>${a.rank}/${S.n}</b> ${p.is === a.isInformationSet ? '✓' : '⚠ MISMATCH'}<br><span class="leanref">${p.lean}</span></div>`;
  html += `<div class="badge ${cl.complete ? 'ok' : (a.isInformationSet ? 'warn' : 'bad')}"><b>closure:</b> ${cl.complete ? 'COMPLETE — every cell locally derivable' : `${cl.count}/${cl.total} cells (${cl.count - cells().length} inferred)`}<br><span class="leanref">${p.closureLean || ''}</span><br><span style="opacity:.85">${p.closureWhy || ''}</span></div>`;
  if (d === 2 && S.n % 2 === 1 && S.n <= 2 * (t + 1)) {
    html += `<div class="badge info kv"><b>the wrap arithmetic</b> (gapTwo_row0): n = ${S.n} = 2·${m}+1, and 2·(${m}+1) = ${2 * (m + 1)} ≡ 1 (mod ${S.n}) — so hops of two generate the ring: every seed cell is an even offset from j₀. The crawl consumes one row-1 cell per hop; row 1 was filled by the two pair-fans riding the enclosed middle column.</div>`;
  }
  if (d === 2 && S.n % 2 === 0) {
    html += `<div class="badge bad kv"><b>even ring:</b> rows ≥ 1 still fill completely (gapTwo_row1 needs no parity!) but the row-0 crawl only reaches even offsets — and the checkerboard seed (ones on odd offsets) is a ghost: dark on the screen forever and dead after one tick. <span class="leanref">gapTwoTube_closure_incomplete_even · altSeed</span></div>`;
  }
  html += `<div class="badge info kv"><b>T30 + T37, the full trichotomy at threshold:</b><br>d = 1 → closure complete (T30b) · d = 2 → complete ⟺ n odd (T37) · d ≥ 3 → closure = the screen itself, zero inferences (T30a)<br>currently d = <b>${d}</b>, n ${S.n % 2 ? 'odd' : 'even'}, t = ${t}${S.tAuto ? ' (threshold)' : ''}</div>`;
  S.els.badges.innerHTML = html;
}

export default {
  title: 'The crawl (T37)',
  async mount({ stage, panel, legend }) {
    stage.innerHTML = '';
    stage.append(
      el('div', { class: 'pagetitle', html: 'The gap-2 crawl — a decoder exactly on odd rings' }),
      el('div', { class: 'pagesub', html: 'T37 (<span class="mono">Rule90Crawl.lean</span>) closed T30\'s named leftover: at the sharp threshold, the distance-2 screen\'s local propagation closure is the ENTIRE block <b>iff the ring is odd</b>. The mechanism — this simulation\'s own observed crawl, made into a proof: the two screen columns enclose the middle column (downward rule), three known columns carry two adjacent pairs, T36\'s fans fill row 1, and row 0 falls to hops of two that wrap precisely when gcd(2, n) = 1.' }),
    );
    const row = el('div', { class: 'cardrow' });
    const cnv = el('canvas', { class: 'block', style: 'height:46vh;min-height:300px;' });
    const ring = el('canvas', { class: 'block', style: 'height:46vh;min-height:300px;' });
    row.append(el('div', { class: 'card', style: 'flex:2 1 480px' }, el('h3', { html: 'spacetime block (closure rounds)' }), cnv),
               el('div', { class: 'card', style: 'flex:1 1 300px' }, el('h3', { html: 'the seed ring — where the crawl crawls' }), ring));
    stage.append(row);
    S.view = new SpacetimeView(cnv);
    S.els.ringCanvas = ring;

    panel.innerHTML = '';
    const badges = el('div');
    S.els.badges = badges;
    const nS = sliderRow('ring size n', { min: 3, max: 27, value: S.n }, v => { S.n = v; recompute(); }, v => `${v}${v % 2 ? ' (odd)' : ' (even)'}`);
    const gS = sliderRow('stride g', { min: 1, max: 9, value: S.g }, v => { S.g = v; recompute(); });
    const tS = sliderRow('horizon t', { min: 1, max: 20, value: threshT(S.n) }, v => { S.t = v; S.tAuto = false; recompute(); });
    panel.append(
      section('Parameters', nS.row, gS.row, tS.row,
        button('t := threshold', () => { S.tAuto = true; tS.set(threshT(S.n)); recompute(); }, 'small'),
        button('odd/even flip', () => { S.n = S.n % 2 ? S.n + 1 : S.n - 1; nS.set(S.n); recompute(); }, 'small')),
      section('Run', button('▶ Animate the crawl', runAnim, 'primary'),
        button('the violet exhibit (n=8, g=3, t=3)', () => { S.n = 8; S.g = 3; S.tAuto = false; S.t = 3; nS.set(8); gS.set(3); tS.set(3); recompute(); }, 'small')),
      badges,
      el('div', { class: 'hint', html: 'The violet exhibit is T30\'s machine-checked splitting witness: at n=8, g=3, t=3 the screen IS an information set (rank 8/8, T25) yet local propagation infers exactly ZERO bulk cells — determination and local derivability are provably different things. <span class="leanref">gapTube_inferable_iff · violet_exhibit</span>' }),
    );
    legend('<span class="swatch" style="background:#6b5420"></span>screen (round 0) · <span class="swatch" style="background:#1f6b4a"></span>inferred, rows ≥ 1 · <span class="swatch" style="background:#2a8a5e"></span>inferred, row 0 (the crawl) · <span class="swatch" style="background:#3b2a5e"></span>determined but never locally derivable · <span class="swatch" style="background:#3a1220"></span>ghost territory');
    recompute();
  },
  showAgain() { recompute(); },
};
