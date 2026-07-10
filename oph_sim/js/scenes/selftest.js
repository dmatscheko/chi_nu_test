/* ============================================================================
   selftest.js — runs the full theorem cross-check battery (lib/selftest.js)
   in the browser and renders the report. The same battery gates the headless
   experiments (node/selftest.mjs). Nothing assumes the theorems: every row
   is an independent recomputation compared against a Lean-checked statement.
   ========================================================================= */

import { TESTS, runAll } from '../lib/selftest.js';
import { el } from '../lib/ui.js';

let ran = false;

export default {
  title: 'Self-tests',
  panel: false,
  async mount({ stage, legend }) {
    stage.innerHTML = '';
    const summary = el('div', { class: 'pagesub', html: `running ${TESTS.length} checks…` });
    const tbl = el('table', { class: 'data' });
    tbl.append(el('tr', {}, ...['', 'group', 'check', 'anchors (Lean)', 'result', 'ms'].map(h => el('th', { html: h }))));
    stage.append(
      el('div', { class: 'pagetitle', html: 'The theorem cross-check battery' }),
      el('div', { class: 'pagesub', html: 'The contract behind every badge in this simulation: an independent JavaScript recomputation (rank, closure, enumeration, residual, interval) is compared against the machine-checked Lean statement it mirrors. Agreement is computed, never assumed — a red row here would mean either a simulation bug or (far more interesting) a real discrepancy with the tree.' }),
      summary,
      el('div', { class: 'card' }, tbl),
    );
    legend(null);
    // chunked run so the page paints progressively (several per tick — background
    // tabs clamp setTimeout to ~1s, so one-per-tick would crawl)
    let pass = 0, fail = 0, totalMs = 0;
    const queue = [...TESTS];
    const step = () => {
      const deadline = performance.now() + 120;
      while (queue.length && performance.now() < deadline) {
        const t = queue.shift();
        let r;
        const t0 = performance.now();
        try { r = t.fn(); } catch (e) { r = { pass: false, detail: 'EXCEPTION: ' + (e && e.message) }; }
        const ms = Math.round(performance.now() - t0);
        totalMs += ms;
        r.pass ? pass++ : fail++;
        tbl.append(el('tr', {},
          el('td', { html: r.pass ? '<span class="good">✓</span>' : '<span class="badc">✗</span>' }),
          el('td', { html: t.group, class: 'dimc' }),
          el('td', { html: `<b>${t.name}</b><br><span class="dimc" style="font-size:11px">${r.detail}</span>` }),
          el('td', { html: `<span class="leanref">${t.lean}</span>` }),
          el('td', { html: r.pass ? 'pass' : 'FAIL', class: r.pass ? 'good' : 'badc' }),
          el('td', { html: String(ms), class: 'num dimc' })));
      }
      if (queue.length) {
        summary.innerHTML = `${pass + fail}/${TESTS.length} — ${pass} passed, ${fail} failed`;
        setTimeout(step, 0);
      } else {
        summary.innerHTML = `<b class="${fail ? 'badc' : 'good'}">${pass} passed, ${fail} failed</b> · ${totalMs} ms total · engine: js/lib/{f2, rule90, exact}.js — the same modules that generated data/experiments.json`;
        ran = true;
      }
    };
    step();
  },
  showAgain() {},
};
