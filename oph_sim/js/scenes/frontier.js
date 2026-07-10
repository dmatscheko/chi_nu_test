/* ============================================================================
   frontier.js — Beyond Lipschitz: the recorded frontier experiments (E1–E10,
   node/experiments.mjs) + live in-browser re-verification. This is the map
   of the country the ONE open math item lives in — everything here is
   NEW territory beyond what the Lean tree kernel-checked.
   ========================================================================= */

import DATA from '../../data/experiments.js';
import { mod, ringDist, analyzeScreen, pairScreen, makeCtx32 } from '../lib/rule90.js';
import { el, section, button, COLORS, fmtPct } from '../lib/ui.js';

function table(headers, rows) {
  const t = el('table', { class: 'data' });
  t.append(el('tr', {}, ...headers.map(h => el('th', { html: h }))));
  for (const r of rows) t.append(el('tr', {}, ...r.map(c => typeof c === 'object' ? c : el('td', { html: String(c) }))));
  return t;
}
const td = (html, cls = '') => el('td', { class: cls, html });

function drawSlack(canvas) {
  const dpr = window.devicePixelRatio || 1;
  canvas.width = canvas.clientWidth * dpr; canvas.height = canvas.clientHeight * dpr;
  const x = canvas.getContext('2d');
  x.setTransform(dpr, 0, 0, dpr, 0, 0);
  const cw = canvas.clientWidth, ch = canvas.clientHeight;
  x.clearRect(0, 0, cw, ch);
  const series = Object.entries(DATA.slack || {});
  const cols = ['#ffc84d', '#4cc9f0', '#ff4dd2'];
  const maxSlack = Math.max(...series.flatMap(([, rows]) => rows.map(r => r.slack)));
  const X = s => 40 + (cw - 60) * s / maxSlack;
  const Y = f => ch - 24 - (ch - 44) * f;
  x.strokeStyle = COLORS.border; x.strokeRect(0.5, 0.5, cw - 1, ch - 1);
  x.fillStyle = COLORS.dim; x.font = '10px sans-serif';
  for (const f of [0, 0.25, 0.5, 0.75, 1]) { x.fillText(fmtPct(f, 0), 6, Y(f) + 3); }
  x.textAlign = 'center';
  for (let s = 0; s <= maxSlack; s += 2) x.fillText(s, X(s), ch - 8);
  x.fillText('slack = 2(t+1) − n →', cw / 2, ch - 8 + 0);
  series.forEach(([name, rows], k) => {
    x.strokeStyle = cols[k % 3]; x.lineWidth = 2; x.beginPath();
    rows.forEach((r, i) => { i ? x.lineTo(X(r.slack), Y(r.fraction)) : x.moveTo(X(r.slack), Y(r.fraction)); });
    x.stroke();
    rows.forEach(r => { x.fillStyle = cols[k % 3]; x.beginPath(); x.arc(X(r.slack), Y(r.fraction), 2.5, 0, 7); x.fill(); });
    x.fillStyle = cols[k % 3]; x.textAlign = 'left';
    const lastR = rows[rows.length - 1];
    x.fillText(name.replace('n', 'n='), X(lastR.slack) - 26, Y(lastR.fraction) - 8);
  });
  x.fillStyle = COLORS.dim; x.textAlign = 'left';
  x.fillText('fraction of ALL paths that decode, vs horizon slack — universality is never reached', 40, 14);
}

async function liveVerify(out) {
  const put = html => { out.innerHTML = html; };
  put('<span class="dimc">running (6,2) all 216 · (8,3) all 512 · (10,4) six probes…</span>');
  await new Promise(r => setTimeout(r, 30));
  let s62 = 0, ok62 = true;
  for (let a = 0; a < 6; a++) for (let b = 0; b < 6; b++) for (let c = 0; c < 6; c++) {
    const is = analyzeScreen(6, 2, pairScreen(6, 2, [a, b, c])).isInformationSet;
    if (is) s62++;
    if (is !== (ringDist(b, c, 6) <= 1)) ok62 = false;
  }
  let s83 = 0;
  for (let a = 0; a < 8; a++) for (let b = 0; b < 8; b++) for (let c = 0; c < 8; c++) {
    if (analyzeScreen(8, 3, pairScreen(8, 3, [0, a, b, c])).isInformationSet) s83++;
  }
  const probes = [[[0, 2, 4, 6, 8], false], [[0, 0, 0, 0, 5], false], [[0, 5, 0, 5, 0], false], [[0, 0, 5, 5, 0], true], [[0, 0, 0, 0, 2], false], [[0, 0, 0, 2, 2], true]];
  const okP = probes.every(([col, want]) => analyzeScreen(10, 4, pairScreen(10, 4, col)).isInformationSet === want);
  put(`<div class="badge ${ok62 && s83 === 512 && okP ? 'ok' : 'bad'}">re-verified in your browser just now: (6,2) ${s62}/216 decode with the last-step predicate ${ok62 ? 'exact ✓' : 'VIOLATED'} · (8,3) ${s83}/512 decode ${s83 === 512 ? '✓' : '✗'} · (10,4) probes ${okP ? 'all match the kernel-checked verdicts ✓' : 'MISMATCH'}</div>`);
}

async function liveT4(out) {
  out.innerHTML = '<span class="dimc">running the full (10,4) sweep — all 10,000 paths…</span>';
  await new Promise(r => setTimeout(r, 30));
  const t0 = performance.now();
  const ctx = makeCtx32(10, 4);
  let dec = 0;
  const col = [0, 0, 0, 0, 0];
  for (let a = 0; a < 10; a++) for (let b = 0; b < 10; b++) for (let c = 0; c < 10; c++) for (let d = 0; d < 10; d++) {
    col[1] = a; col[2] = b; col[3] = c; col[4] = d;
    if (analyzeScreen(10, 4, pairScreen(10, 4, col), ctx).isInformationSet) dec++;
  }
  const rec = DATA.capacity.t4;
  out.innerHTML = `<div class="badge ${dec === rec.decode ? 'ok' : 'bad'}">your browser: ${dec}/10000 decode (${(performance.now() - t0).toFixed(0)} ms) — recorded run: ${rec.decode}/10000 ${dec === rec.decode ? '✓ exact agreement' : '✗ DISAGREES'}</div>`;
}

export default {
  title: 'Beyond Lipschitz',
  panel: false,
  async mount({ stage, legend }) {
    stage.innerHTML = '';
    const cap = DATA.capacity;
    const capRows = ['t2', 't3', 't4', 't5', 't6', 't7'].filter(k => cap[k]).map(k => {
      const c = cap[k];
      const frac = fmtPct(c.fraction, c.fraction === 1 || c.fraction === 0.5 ? 0 : 2);
      const note = { t2: 'kernel-checked classification: last step Lipschitz (pairScreen_class_6_2)', t3: 'ALL decode — kernel-checked instances + full sweep', t4: 'wild: last-step rule neither necessary nor sufficient', t5: 'n ≡ 0 mod 4 but NOT a power of 2 — still wild', t6: 'even richer failure zoo', t7: 'n = 2⁴: universality returns (sampled 3M)' }[k];
      return [
        td(`t = ${c.t}`), td(`n = ${c.n}${Number.isInteger(Math.log2(c.n)) ? ' = 2^' + Math.log2(c.n) : ''}`, c.n % 4 === 0 ? 'goldc' : ''),
        td(c.mode), td(c.decode.toLocaleString() + ' / ' + c.total.toLocaleString(), 'num'),
        td(`<b>${frac}</b>`, c.fraction === 1 ? 'good' : c.fraction < 0.35 ? 'badc' : ''),
        td(note, 'dimc')];
    });

    const p2 = DATA.powerOfTwo;
    const tele = DATA.teleport || [];
    const mc = DATA.monteCarlo || [];
    const lips = DATA.lipschitzSurjectivity;
    const laws = DATA.shadowLaws;
    const fam = DATA.families || [];
    const t62 = DATA.tightCensus62, t83 = DATA.tightCensus83;

    const verifyOut = el('div');
    const verifyOut2 = el('div');
    const slackCanvas = el('canvas', { class: 'block', style: 'height:200px' });

    stage.append(
      el('div', { class: 'pagetitle', html: 'Beyond Lipschitz — mapping the open country' }),
      el('div', { class: 'pagesub', html: 'T36 fences off the causal world: every ≤-light-speed worldline decodes at the sharp threshold, provably. Everything on this page lives OUTSIDE the fence — computed by <span class="mono">node/experiments.mjs</span> with the same engine that passes the 33-check theorem battery, recorded in <span class="mono">data/experiments.json</span>, re-runnable live below. Generated ' + (DATA.meta && DATA.meta.generated) + '.' }),

      el('div', { class: 'card' }, el('h3', { html: 'E1 — every worldline at exact capacity n = 2(t+1), exhaustively' }),
        table(['horizon', 'ring', 'coverage', 'decode', 'fraction', 'what it means'], capRows),
        el('div', { class: 'hint', html: 'The decode fraction is not monotone and not governed by any invariant tried (step multiset, last step, cardinality, t parity, n mod 4): 50% → <b>100%</b> → 32% → 30% → 24% → <b>100%</b>. The two islands of universality are the powers of two.' }),
        el('div', {}, button('re-verify the kernel-checked walls now', () => liveVerify(verifyOut), 'small'), button('re-run the full (10,4) sweep', () => liveT4(verifyOut2), 'small')),
        verifyOut, verifyOut2),

      el('div', { class: 'cardrow' },
        el('div', { class: 'card' }, el('h3', { html: 'E10 — conjecture C3: power-of-two universality' }),
          table(['ring', 'horizon', 'sampled', 'decode'],
            [[td('n = 8 = 2³'), td('t = 3'), td('ALL 512 (Lean, exhaustive)'), td('<b>100%</b>', 'good')],
             ...(p2 ? p2.rows.map(r => [td(`n = ${r.n} = 2^${Math.log2(r.n)}`), td(`t = ${r.t}`), td(r.samples.toLocaleString()), td(`<b>${fmtPct(r.fraction, 1)}</b>`, 'good')]) : [])]),
          el('div', { class: 'hint', html: '<b>Why (sketch):</b> on n = 2ᵏ the ring 𝔽₂[x]/(xⁿ−1) is LOCAL: u = 1+x is nilpotent, uⁿ = 0. The pair cell (i, c) ∪ (i, c+1) contributes functionals x^{c−i}u^{2i} and x^{c+1−i}u^{2i}, whose sum has u-valuation exactly 2i+1 — so ANY path fills every graded level 0…n−1 and the readout is bijective, regardless of speed. On non-2-power rings semisimple factors exist and the argument (and the universality) dies. Formalization candidate.' })),
        el('div', { class: 'card' }, el('h3', { html: 'E8 — conjecture C4: the teleporting observer\'s permanent ghost' }),
          table(['ring', 'n/2', 'verdict', 'kernel dim'],
            tele.map(r => [td(`n = ${r.n}`), td(`${r.h} (${r.hParity})`), td(r.verdict, r.firstIS === null ? 'badc' : 'good'), td(r.kernelDimWhenDark ?? '—', 'num')])),
          el('div', { class: 'hint', html: 'The worldline (0, n/2, 0, n/2, …) — maximal teleport every tick. With n/2 <b>odd</b> it NEVER decodes (tested to t = 24): the kernel holds ghosts locked in a 2-cycle <b>in antiphase with the observer</b> — at n = 6 the ghost δ₂+δ₄ ↔ δ₁+δ₅ is always dark exactly where you just looked (verified period-2 mechanism, 3-line induction). With n/2 even the same worldline decodes at capacity. The anti-T36: superluminal observers can be permanently deceived.' }))),

      el('div', { class: 'card' }, el('h3', { html: 'E2 — the slack ladder: extra horizon never buys universality' }),
        slackCanvas,
        el('div', { class: 'hint', html: 'Fraction of ALL paths (exhaustive where marked, else 3M samples) that decode, as the horizon grows past capacity. Even at slack 8, ~1% of n=6 worldlines still fail — the teleport family shows some fail at EVERY horizon. Failing step-sets concentrate on {2,3,4}-type jumps (E1 detail data).' })),

      el('div', { class: 'cardrow' },
        el('div', { class: 'card' }, el('h3', { html: 'E3 — structured families across t (exhaustive, exact)' }),
          table(['t (n=2t+2)', 'slope-2 line', 'teleport n/2', 'single +2 kink by position 1…t'],
            fam.map(f => [td(`t = ${f.t}, n = ${f.n}`), td(f.slope2 ? 'decodes' : 'fails', f.slope2 ? 'good' : 'badc'), td(f.teleportHalf ? 'decodes' : 'fails', f.teleportHalf ? 'good' : 'badc'), td(f.kinkByPosition.map(k => k ? '<span class="good">●</span>' : '<span class="badc">○</span>').join(''), 'mono')])),
          el('div', { class: 'hint', html: 'The kink family (one superluminal step of +2, Lipschitz otherwise): it fails ONLY in the last position and ONLY at even t — order-sensitivity is systematic, not an accident of (6,2). The teleport column alternates with t parity; the slope-2 line follows no simple rule at all ({3,7,8} decode).' })),
        el('div', { class: 'card' }, el('h3', { html: 'E4/E5 — how rare is decoding among ARBITRARY subsets?' }),
          table(['block', '|S|', 'P(information set)', 'closure-complete among IS'],
            mc.map(m => {
              const cs = m.closureSampled;
              const tot = cs.complete + cs.partial;
              return [td(`(${m.n}, ${m.t})`), td(m.size, 'num'), td(fmtPct(m.pIS, 2), m.pIS < 0.01 ? 'badc' : ''), td(tot ? fmtPct(cs.complete / tot, 0) : '—', 'num')];
            })),
          el('div', { class: 'hint', html: `Random-matrix baseline: 28.9%. Structure makes random reads far WORSE — the Sierpiński readout rows are heavily correlated, and deep blocks repeat rows (on 2-power rings the dynamics is nilpotent: at (16,15) rows past time 8 are all zero). Exhaustive tight censuses: (6,2) → <b>${t62 ? t62.informationSets.toLocaleString() : '—'}</b>/${t62 ? t62.subsets.toLocaleString() : '—'} = ${t62 ? fmtPct(t62.fraction, 2) : '—'} (note: 2401 = 7⁴ exactly — unexplained); (8,3) → ${t83 ? `<b>${t83.informationSets.toLocaleString()}</b>/${t83.subsets.toLocaleString()} = ${fmtPct(t83.fraction, 2)}` : 'run experiments.mjs all'}. And among random tight information sets, closure-completeness collapses with size: T36-style locality is the exception, global determination the rule.` }))),

      el('div', { class: 'card' }, el('h3', { html: 'E7/E9 — conjectures handed to the next formal campaign' }),
        table(['#', 'statement', 'evidence', 'proof idea'],
          [[td('C1'), td('even n ≤ 2(t+1): the maximal ghost shadows are exactly the 2^{n/2+1}−2 single-parity-class ghosts'), td(laws && laws.C1holds ? 'exhaustive n ≤ 14, t up to 2n ✓' : '—', 'good'), td('parity components\' trajectories never overlap ⇒ Z(z) ⊆ Z(z_parity); 3-line containment + a maximality count', 'dimc')],
           [td('C2'), td('odd n ≤ 2(t+1): all 2ⁿ−1 ghost zero-sets are pairwise incomparable (rigidity)'), td(laws && laws.C2holds ? 'exhaustive n ≤ 13 ✓' : '—', 'good'), td('open', 'dimc')],
           [td('C3'), td('n = 2ᵏ at capacity: EVERY worldline pair-screen decodes'), td('exhaustive n=8; 0 failures in 3.2M samples at n=16/32/64', 'good'), td('u-adic valuation ladder in the local ring (sketch above)', 'dimc')],
           [td('C4'), td('teleport-n/2 worldline: permanent ghost ⟺ n/2 odd; kernel dim n/2 − 1'), td('n ≤ 26, t ≤ 24; period-2 mechanism proven at n=6', 'good'), td('antiphase 2-cycle ghosts; quotient/mirror algebra', 'dimc')],
           [td('C5'), td('every 1-Lipschitz worldline readout is SURJECTIVE (rank = min(n, |cells|)) — T31 generalized to worldlines'), td(lips && lips.holds ? `${lips.trials.toLocaleString()} random worldlines, 0 violations` : '—', 'good'), td('fan argument on the image side?', 'dimc')]]),
        el('div', { class: 'hint', html: 'The pattern of this project: FINDINGS items 1/3/10/11 of the first build became theorems T30/T31/T36/T37 of the chain. These five are the next batch, each machine-testable (decidable per instance) and each with its evidence artifact in data/experiments.json.' })),
    );
    drawSlack(slackCanvas);
    legend(null);
  },
  showAgain() {},
};
