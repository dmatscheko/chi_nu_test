/* ============================================================================
   hypercharge.js — T13 + CenterZ6: the anomaly cage and the ℤ₆ wheel.
   Exact rational arithmetic throughout (lib/exact.js mirrors
   Hypercharge.lean's five constraint families and CenterZ6.lean's phases).
   ========================================================================= */

import { anomalyResiduals, SM_ASSIGNMENT, forcedAssignment, frac, fadd, feq, fstr, fval,
         Z6_REPS, z6Phase, g0k } from '../lib/exact.js';
import { el, section, sliderRow, button, COLORS } from '../lib/ui.js';

const S = { a: { ...SM_ASSIGNMENT }, k: 1, custom: { a: 1, b: 0, theta: 0 }, useCustom: false, els: {} };

const FIELDS = [['YQ', 'Y(Q)'], ['Yu', 'Y(u̅)'], ['Yd', 'Y(d̅)'], ['YL', 'Y(L)'], ['Ye', 'Y(e̅)'], ['YH', 'Y(H)']];
const SIXTH = frac(1, 6);

function residualTable() {
  const res = anomalyResiduals(S.a);
  const rows = [
    ['yukawaUp', 'Y_Q + Y_H + Y_u = 0', 'up-Yukawa gauge invariance'],
    ['yukawaDown', 'Y_Q − Y_H + Y_d = 0', 'down-Yukawa'],
    ['yukawaLep', 'Y_L − Y_H + Y_e = 0', 'lepton Yukawa'],
    ['su2', 'N·Y_Q + Y_L = 0', '[SU(2)]²·U(1) anomaly'],
    ['grav', 'N(2Y_Q+Y_u+Y_d) + 2Y_L + Y_e = 0', 'grav²·U(1) anomaly'],
    ['su3', '2Y_Q + Y_u + Y_d = 0', '[SU(3)]²·U(1) — implied by Yukawa alone'],
    ['cubic', 'N(2Y_Q³+Y_u³+Y_d³) + 2Y_L³ + Y_e³ = 0', '[U(1)]³ — holds identically on the ratio solution'],
  ];
  let html = '<table class="data"><tr><th>constraint</th><th>residual</th><th></th></tr>';
  let allOK = true;
  for (const [key, eq, name] of rows) {
    const ok = feq(res[key], frac(0));
    if (!ok) allOK = false;
    html += `<tr><td><span class="mono">${eq}</span><br><span class="dimc" style="font-size:10px">${name}</span></td><td class="num ${ok ? 'good' : 'badc'}">${fstr(res[key])}</td><td>${ok ? '✓' : '✗'}</td></tr>`;
  }
  html += '</table>';
  return { html, allOK };
}

function isSM() { return FIELDS.every(([k]) => feq(S.a[k], SM_ASSIGNMENT[k])); }

function drawWheel() {
  const c = S.els.wheel;
  const dpr = window.devicePixelRatio || 1;
  c.width = c.clientWidth * dpr; c.height = c.clientHeight * dpr;
  const x = c.getContext('2d');
  x.setTransform(dpr, 0, 0, dpr, 0, 0);
  const cw = c.clientWidth, ch = c.clientHeight;
  x.clearRect(0, 0, cw, ch);
  const R = Math.min(cw, ch) / 2 - 34, cx0 = cw / 2, cy0 = ch / 2;
  const g = S.useCustom ? S.custom : g0k(S.k);
  x.strokeStyle = COLORS.border; x.beginPath(); x.arc(cx0, cy0, R, 0, 7); x.stroke();
  const cols = ['#ffc84d', '#4cc9f0', '#39e08b', '#ff5b74', '#b37bff', '#ff4dd2'];
  let allZero = true;
  Z6_REPS.forEach((r, i) => {
    const ph = z6Phase(g.a, g.b, g.theta, r);
    const dist = Math.min(ph, 1 - ph);
    if (dist > 1e-9) allZero = false;
    const baseA = i / 6 * 2 * Math.PI - Math.PI / 2;
    const a2 = baseA + ph * 2 * Math.PI;
    // anchor dot at base angle, arrow to rotated angle
    x.strokeStyle = cols[i]; x.lineWidth = 2.4;
    x.beginPath(); x.moveTo(cx0 + 0.35 * R * Math.cos(baseA), cy0 + 0.35 * R * Math.sin(baseA));
    x.lineTo(cx0 + R * 0.92 * Math.cos(a2), cy0 + R * 0.92 * Math.sin(a2)); x.stroke();
    x.fillStyle = cols[i];
    x.beginPath(); x.arc(cx0 + R * 0.92 * Math.cos(a2), cy0 + R * 0.92 * Math.sin(a2), 4.5, 0, 7); x.fill();
    x.font = '11px sans-serif'; x.textAlign = 'center';
    x.fillText(r.name + (dist > 1e-9 ? ` (${ph.toFixed(2)})` : ''), cx0 + (R + 18) * Math.cos(baseA), cy0 + (R + 18) * Math.sin(baseA) + 4);
  });
  x.fillStyle = allZero ? COLORS.green : COLORS.red;
  x.font = '12px sans-serif'; x.textAlign = 'center';
  x.fillText(allZero ? 'acts trivially on every multiplet' : 'moves at least one multiplet', cx0, ch - 8);
  return allZero;
}

function render() {
  const { html, allOK } = residualTable();
  S.els.residuals.innerHTML = html;
  const sm = isSM();
  S.els.verdict.innerHTML =
    `<div class="badge ${allOK ? (sm ? 'ok' : 'warn') : 'bad'}">${allOK
      ? (sm ? '<b>All seven constraints hold — and this is exactly smAssignment</b>: with N = 3 and the normalization Y_L = −1/2, the constraints force (1/6, −2/3, 1/3, −1/2, 1, 1/2) uniquely <span class="leanref">hypercharges_unique</span>'
            : '<b>consistent</b> — you are on the SM ray (the constraints fix hypercharges only up to overall scale; Y_L = −1/2 is the electroweak normalization Q = T₃ + Y)')
      : '<b>anomalous / Yukawa-broken</b> — this assignment cannot be a consistent chiral gauge theory with these Yukawas. The red rows say which law you broke.'}</div>`;
  let fields = '';
  for (const [k, label] of FIELDS) {
    fields += `<div class="rowc"><label>${label}</label>
      <span class="btn small" data-f="${k}" data-d="-1">−1/6</span>
      <output style="flex:1;text-align:center">${fstr(S.a[k])}</output>
      <span class="btn small" data-f="${k}" data-d="1">+1/6</span></div>`;
  }
  S.els.fields.innerHTML = fields;
  for (const b of S.els.fields.querySelectorAll('.btn')) {
    b.addEventListener('click', () => {
      const k = b.dataset.f, d = +b.dataset.d;
      S.a[k] = fadd(S.a[k], frac(d, 6));
      render();
    });
  }
  const allZero = drawWheel();
  S.els.wheelBadge.innerHTML = `<div class="badge ${allZero ? 'ok' : 'info'} kv">${S.useCustom
    ? `probe (a=${S.custom.a}, b=${S.custom.b}, θ=${S.custom.theta.toFixed(3)}): ${allZero ? 'in the kernel (it must be some g₀ᵏ!)' : 'NOT in the kernel — it moves a multiplet'}`
    : `g₀<sup>${S.k}</sup> = (ω₃<sup>${S.k}</sup>, (−1)<sup>${S.k}</sup>, e<sup>iπ·${S.k}/3</sup>) — kernel element ${S.k}/6`}
    <br>the trivially-acting center of SU(3)×SU(2)×U(1) on the SM multiplets is <b>exactly ⟨g₀⟩ ≅ ℤ₆</b> (phase condition 2t + 3d + q ≡ 0 mod 6) — so the faithful gauge group is SU(3)×SU(2)×U(1)/ℤ₆ <span class="leanref">actsTrivially_iff · kernelAddEquiv (F10c)</span></div>`;
}

export default {
  title: 'Hypercharge & ℤ₆',
  async mount({ stage, panel, legend }) {
    stage.innerHTML = '';
    const residuals = el('div');
    const wheel = el('canvas', { class: 'block', style: 'height:340px' });
    const wheelBadge = el('div');
    stage.append(
      el('div', { class: 'pagetitle', html: 'Why these hypercharges — the anomaly cage and the ℤ₆ wheel' }),
      el('div', { class: 'pagesub', html: 'T13 (<span class="mono">Hypercharge.lean</span>, exact rationals): Yukawa closure + the two linear anomaly conditions force every hypercharge ratio; the cubic anomaly then holds <i>identically</i>. Nudge any charge by 1/6 and watch which law breaks. CenterZ6.lean: the part of the gauge group that acts on nothing is exactly ℤ₆.' }),
      el('div', { class: 'cardrow' },
        el('div', { class: 'card' }, el('h3', { html: 'the seven constraints, evaluated exactly' }), residuals),
        el('div', { class: 'card' }, el('h3', { html: 'the ℤ₆ wheel — center phases on the six multiplets' }), wheel, wheelBadge)),
    );
    panel.innerHTML = '';
    const fields = el('div');
    const verdict = el('div');
    const kSlider = sliderRow('kernel power k', { min: 0, max: 5, value: S.k }, v => { S.k = v; S.useCustom = false; render(); });
    S.els = { residuals, wheel, wheelBadge, fields, verdict };
    panel.append(
      section('Hypercharges (step ±1/6)', fields,
        button('reset to smAssignment', () => { S.a = { ...SM_ASSIGNMENT }; render(); }, 'small'),
        button('scale ×2 (stay on the ray)', () => { for (const [k] of FIELDS) S.a[k] = fadd(S.a[k], S.a[k]); render(); }, 'small')),
      verdict,
      section('ℤ₆ probe', kSlider.row,
        button('probe (1, 0, 0) — bare ω₃', () => { S.useCustom = true; S.custom = { a: 1, b: 0, theta: 0 }; render(); }, 'small'),
        button('probe (0, 1, 1/6)', () => { S.useCustom = true; S.custom = { a: 0, b: 1, theta: 1 / 6 }; render(); }, 'small'),
        button('back to g₀ᵏ', () => { S.useCustom = false; render(); }, 'small')),
      el('div', { class: 'hint', html: 'The wheel anchors each multiplet at its own spoke; the dot slides by the phase the chosen center element gives it. Kernel elements leave every dot at its anchor. That ℤ₆ is what the collar gate\'s 6 = #ℤ₆ bookkeeping refers to (reserve_split · six_is_card_z6).' }),
    );
    legend(null);
    render();
  },
  showAgain() { render(); },
};
