/* ============================================================================
   qbft.js — T23 (ConsensusSafety.lean): quorum-intersection safety and the
   exact n = 3f+1 boundary, as a two-quorum dial.
   ========================================================================= */

import { quorumMinOverlap } from '../lib/exact.js';
import { el, section, sliderRow, button, COLORS } from '../lib/ui.js';

const S = { f: 1, n: 4, els: {} };

function q() { return 2 * S.f + 1; }

function worstQuorums() {
  // adversarially minimal overlap: Qa = first q nodes, Qb = last q nodes
  const n = S.n, qq = Math.min(q(), n);
  const Qa = new Set(Array.from({ length: qq }, (_, i) => i));
  const Qb = new Set(Array.from({ length: qq }, (_, i) => n - 1 - i));
  const overlap = [...Qa].filter(v => Qb.has(v));
  return { Qa, Qb, overlap };
}

function draw() {
  const c = S.els.canvas;
  const dpr = window.devicePixelRatio || 1;
  c.width = c.clientWidth * dpr; c.height = c.clientHeight * dpr;
  const x = c.getContext('2d');
  x.setTransform(dpr, 0, 0, dpr, 0, 0);
  const cw = c.clientWidth, ch = c.clientHeight;
  x.clearRect(0, 0, cw, ch);
  const R = Math.min(cw, ch) / 2 - 44, cx0 = cw / 2, cy0 = ch / 2;
  const { Qa, Qb, overlap } = worstQuorums();
  const byz = new Set(overlap.slice(0, S.f));     // adversary corrupts overlap first
  for (let v = 0; v < S.n; v++) {
    const a = v / S.n * 2 * Math.PI - Math.PI / 2;
    const px = cx0 + R * Math.cos(a), py = cy0 + R * Math.sin(a);
    if (Qa.has(v)) { x.strokeStyle = COLORS.gold; x.lineWidth = 3.5; x.beginPath(); x.arc(px, py, 19, 0, 7); x.stroke(); }
    if (Qb.has(v)) { x.strokeStyle = COLORS.cyan; x.lineWidth = 3.5; x.beginPath(); x.arc(px, py, 24, 0, 7); x.stroke(); }
    x.beginPath(); x.arc(px, py, 13, 0, 7);
    x.fillStyle = byz.has(v) ? COLORS.red : '#2a3564';
    x.fill();
    x.fillStyle = '#dfe6ff'; x.font = '11px sans-serif'; x.textAlign = 'center';
    x.fillText(byz.has(v) ? '☠' : v, px, py + 4);
  }
  x.font = '11px sans-serif'; x.textAlign = 'center';
  x.fillStyle = COLORS.gold; x.fillText(`Q_a votes "a" (|Q| = ${Math.min(q(), S.n)})`, cx0, 16);
  x.fillStyle = COLORS.cyan; x.fillText(`Q_b votes "b"`, cx0, 32);
}

function render() {
  draw();
  const { overlap } = worstQuorums();
  const need = S.f + 1;
  const worst = quorumMinOverlap(S.n, Math.min(q(), S.n), Math.min(q(), S.n));
  const safe = worst >= need;
  const boundary = 3 * S.f + 1;
  S.els.badges.innerHTML =
    `<div class="badge ${safe ? 'ok' : 'bad'}">n = <b>${S.n}</b>, f = <b>${S.f}</b>, quorum size 2f+1 = <b>${q()}</b> → worst-case overlap <b>${worst}</b> ${safe ? '≥' : '&lt;'} f+1 = ${need}: <b>${safe ? 'SAFE — the overlap must contain an honest node, so no two quorums can certify different values' : 'UNSAFE-BY-COUNTING — the adversary can own the whole overlap; two quorums can certify contradictory values'}</b><br><span class="leanref">qbft_safety_core · quorum_intersection_exact</span></div>` +
    `<div class="badge info kv">the exact boundary: with quorums of 2f+1, counting gives safety <b>iff n ≤ 3f+1</b> (overlap = 2q − n = ${worst}); liveness needs n ≥ 3f+1 — so <b>n = 3f+1 = ${boundary}</b> is the unique sweet spot. The Lean module also pins the folklore gap: at n = 3f+2 two (2f+1)-quorums can overlap in just ${quorumMinOverlap(3 * S.f + 2, q(), q())} node(s) — the "guaranteed by A3" clause of the appendix is false above 3f+1 <span class="leanref">quorum_overlap_gap</span></div>` +
    `<div class="badge warn kv"><b>scope, honestly:</b> T23 formalizes the SAFETY core (two conflicting certificates ⇒ contradiction through the honest overlap node) and the counting boundary. Liveness and view-change are cited, not proven. In the chain this is corpus-extension material (appendix B), not proof-chain-critical.</div>`;
}

export default {
  title: 'Quorums (T23)',
  async mount({ stage, panel, legend }) {
    stage.innerHTML = '';
    const canvas = el('canvas', { class: 'block', style: 'height:52vh;min-height:320px' });
    stage.append(
      el('div', { class: 'pagetitle', html: 'Byzantine quorums — why 3f+1, exactly' }),
      el('div', { class: 'pagesub', html: 'T23 (<span class="mono">ConsensusSafety.lean</span>): two quorums that both certify a value must share an honest node — and with quorums of size 2f+1 that is a pure counting fact exactly when n = 3f+1. The dial shows the adversarially worst pair of quorums; ☠ = the f nodes the adversary corrupts (it always spends them on the overlap).' }),
      el('div', { class: 'card' }, canvas),
    );
    panel.innerHTML = '';
    const badges = el('div');
    const nS = sliderRow('nodes n', { min: 3, max: 13, value: S.n }, v => { S.n = v; render(); });
    const fS = sliderRow('faults f', { min: 1, max: 3, value: S.f }, v => { S.f = v; render(); });
    S.els = { canvas, badges };
    panel.append(
      section('Parameters', nS.row, fS.row,
        button('n := 3f+1 (the boundary)', () => { S.n = 3 * S.f + 1; nS.set(S.n); render(); }, 'small'),
        button('the gap witness (n=5, f=1)', () => { S.f = 1; S.n = 5; fS.set(1); nS.set(5); render(); }, 'small')),
      badges,
    );
    legend(null);
    render();
  },
  showAgain() { render(); },
};
