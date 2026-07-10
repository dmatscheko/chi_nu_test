/* ============================================================================
   ui.js — shared UI kit for the 2D scenes: DOM helpers, badges, sliders,
   the reusable spacetime-diagram canvas, and heatmap drawing.
   ========================================================================= */

export const COLORS = {
  bg: '#070b18', panel: '#0e1530', border: '#26305c',
  ink: '#dfe6ff', dim: '#8d97c5', gold: '#ffc84d', green: '#39e08b',
  red: '#ff5b74', violet: '#b37bff', cyan: '#4cc9f0', mag: '#ff4dd2',
  cellOn: '#e9f1ff', cellOff: '#1d2547', screenOn: '#ffd97a', screenOff: '#6b5420',
};

export function el(tag, attrs = {}, ...children) {
  const e = document.createElement(tag);
  for (const [k, v] of Object.entries(attrs)) {
    if (k === 'class') e.className = v;
    else if (k === 'style') e.style.cssText = v;
    else if (k.startsWith('on')) e.addEventListener(k.slice(2), v);
    else if (k === 'html') e.innerHTML = v;
    else e.setAttribute(k, v);
  }
  for (const c of children) e.append(c);
  return e;
}

export function badge(kind, html) {
  return el('div', { class: `badge ${kind}`, html });
}

export function section(title, ...children) {
  const s = el('div', { class: 'sec' });
  if (title) s.append(el('h2', { html: title }));
  s.append(...children);
  return s;
}

/** Labelled slider row; onInput(value) fires immediately. Returns {row, input, out, set}. */
export function sliderRow(label, { min, max, value, step = 1 }, onInput, fmt = v => v) {
  const out = el('output', { html: fmt(value) });
  const input = el('input', { type: 'range', min, max, value, step });
  input.addEventListener('input', () => { out.innerHTML = fmt(+input.value); onInput(+input.value); });
  const row = el('div', { class: 'rowc' }, el('label', { html: label }), input, out);
  return { row, input, out, set: v => { input.value = v; out.innerHTML = fmt(v); } };
}

export function button(label, onClick, cls = '') {
  return el('span', { class: `btn ${cls}`, html: label, onclick: onClick });
}

/* ------------------------------------------------------- spacetime canvas */

/**
 * A clickable (t+1)×n spacetime diagram. Row i=0 (the seed) at the BOTTOM,
 * time increasing upward — matching the 3D cylinder. Ring wrap is drawn as
 * dashed edges. All geometry in CSS pixels; devicePixelRatio handled.
 *
 * paint(i, j) must return {fill, stroke?, strokeW?, glyph?} or null (skip).
 */
export class SpacetimeView {
  constructor(canvas, { onCell = null, pad = 26 } = {}) {
    this.canvas = canvas;
    this.onCell = onCell;
    this.pad = pad;
    this.n = 1; this.t = 0;
    canvas.addEventListener('click', e => {
      if (!this.onCell) return;
      const c = this.cellAt(e);
      if (c) this.onCell(c.i, c.j, e);
    });
    canvas.addEventListener('mousemove', e => {
      if (!this.onCell) return;
      canvas.style.cursor = this.cellAt(e) ? 'pointer' : 'default';
    });
  }
  layout(n, t) {
    this.n = n; this.t = t;
    const cw = this.canvas.clientWidth || this.canvas.width;
    const ch = this.canvas.clientHeight || this.canvas.height;
    const dpr = window.devicePixelRatio || 1;
    if (this.canvas.width !== cw * dpr) { this.canvas.width = cw * dpr; this.canvas.height = ch * dpr; }
    const availW = cw - 2 * this.pad, availH = ch - 2 * this.pad;
    this.cell = Math.max(4, Math.min(Math.floor(availW / n), Math.floor(availH / (t + 1)), 34));
    this.ox = (cw - this.cell * n) / 2;
    this.oy = (ch - this.cell * (t + 1)) / 2;
    return { cw, ch, dpr };
  }
  cellXY(i, j) {   // top-left corner
    return { x: this.ox + j * this.cell, y: this.oy + (this.t - i) * this.cell };
  }
  cellAt(e) {
    const r = this.canvas.getBoundingClientRect();
    const x = e.clientX - r.left, y = e.clientY - r.top;
    const j = Math.floor((x - this.ox) / this.cell);
    const irow = Math.floor((y - this.oy) / this.cell);
    const i = this.t - irow;
    if (j < 0 || j >= this.n || i < 0 || i > this.t) return null;
    return { i, j };
  }
  draw(paint, { axes = true } = {}) {
    const { cw, ch, dpr } = this.layout(this.n, this.t);
    const ctx = this.canvas.getContext('2d');
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    ctx.clearRect(0, 0, cw, ch);
    const cs = this.cell, gap = cs >= 10 ? 1 : 0;
    for (let i = 0; i <= this.t; i++) for (let j = 0; j < this.n; j++) {
      const p = paint(i, j);
      if (!p) continue;
      const { x, y } = this.cellXY(i, j);
      ctx.fillStyle = p.fill;
      ctx.fillRect(x + gap, y + gap, cs - 2 * gap, cs - 2 * gap);
      if (p.stroke) {
        ctx.strokeStyle = p.stroke; ctx.lineWidth = p.strokeW || 2;
        ctx.strokeRect(x + 1.2, y + 1.2, cs - 2.4, cs - 2.4);
      }
      if (p.glyph && cs >= 12) {
        ctx.fillStyle = p.glyphColor || COLORS.ink;
        ctx.font = `${Math.floor(cs * 0.62)}px "SF Mono",Menlo,monospace`;
        ctx.textAlign = 'center'; ctx.textBaseline = 'middle';
        ctx.fillText(p.glyph, x + cs / 2, y + cs / 2 + 0.5);
      }
    }
    if (axes) {
      ctx.strokeStyle = COLORS.border; ctx.setLineDash([4, 4]); ctx.lineWidth = 1;
      ctx.strokeRect(this.ox - 3, this.oy - 3, cs * this.n + 6, cs * (this.t + 1) + 6);
      ctx.setLineDash([]);
      ctx.fillStyle = COLORS.dim; ctx.font = '10px sans-serif'; ctx.textAlign = 'left';
      ctx.fillText('j → (wraps)', this.ox, this.oy + cs * (this.t + 1) + 14);
      ctx.save();
      ctx.translate(this.ox - 8, this.oy + cs * (this.t + 1));
      ctx.rotate(-Math.PI / 2);
      ctx.fillText('time i ↑  (row 0 = seed)', 0, 0);
      ctx.restore();
    }
  }
}

/* --------------------------------------------------------------- heatmap */

/**
 * Draw a discrete heatmap: value(ix, iy) → color string (or null = empty).
 * xs, ys are the tick values (arrays). Labels drawn on the axes.
 */
export function drawHeatmap(canvas, xs, ys, value, { xLabel = '', yLabel = '', cellText = null } = {}) {
  const dpr = window.devicePixelRatio || 1;
  const cw = canvas.clientWidth || canvas.width, ch = canvas.clientHeight || canvas.height;
  canvas.width = cw * dpr; canvas.height = ch * dpr;
  const ctx = canvas.getContext('2d');
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  ctx.clearRect(0, 0, cw, ch);
  const padL = 34, padB = 26, padT = 8, padR = 8;
  const cellW = (cw - padL - padR) / xs.length, cellH = (ch - padT - padB) / ys.length;
  for (let iy = 0; iy < ys.length; iy++) for (let ix = 0; ix < xs.length; ix++) {
    const col = value(ix, iy);
    if (!col) continue;
    const x = padL + ix * cellW, y = padT + (ys.length - 1 - iy) * cellH;
    ctx.fillStyle = col;
    ctx.fillRect(x + 0.5, y + 0.5, cellW - 1, cellH - 1);
    if (cellText && cellW > 18) {
      const txt = cellText(ix, iy);
      if (txt) {
        ctx.fillStyle = 'rgba(10,14,30,0.85)'; ctx.font = '9px sans-serif';
        ctx.textAlign = 'center'; ctx.textBaseline = 'middle';
        ctx.fillText(txt, x + cellW / 2, y + cellH / 2);
      }
    }
  }
  ctx.fillStyle = COLORS.dim; ctx.font = '10px sans-serif'; ctx.textAlign = 'center';
  const xStep = Math.ceil(xs.length / 16);
  for (let ix = 0; ix < xs.length; ix += xStep) ctx.fillText(xs[ix], padL + (ix + 0.5) * cellW, ch - padB + 12);
  ctx.textAlign = 'right';
  const yStep = Math.ceil(ys.length / 12);
  for (let iy = 0; iy < ys.length; iy += yStep) ctx.fillText(ys[iy], padL - 5, padT + (ys.length - 1 - iy + 0.6) * cellH);
  ctx.textAlign = 'center';
  ctx.fillText(xLabel, padL + (cw - padL - padR) / 2, ch - 4);
  ctx.save(); ctx.translate(10, padT + (ch - padT - padB) / 2); ctx.rotate(-Math.PI / 2);
  ctx.fillText(yLabel, 0, 0); ctx.restore();
}

/* ------------------------------------------------------------- misc */

export function mulberry32(a) { return function () { a |= 0; a = a + 0x6D2B79F5 | 0; let t = Math.imul(a ^ a >>> 15, 1 | a); t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t; return ((t ^ t >>> 14) >>> 0) / 4294967296; }; }

export const fmtPct = (x, d = 1) => (100 * x).toFixed(d) + '%';
