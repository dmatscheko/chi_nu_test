/* ============================================================================
   app.js — the showroom shell: scene registry, sidebar nav, lazy loading,
   shared banner/legend/panel chrome. Each scene module exports
   { title, subtitle?, panel: bool, mount(ctx), unmount?() } — mount receives
   { stage, panel, banner, legend, setActive } and is called once per
   activation (scenes may cache their DOM in module scope and re-show).
   ========================================================================= */

const SCENES = [
  { group: 'The cylinder' },
  { id: 'holo', label: 'Holography 3D', tag: 'T9·25·27·36', wing: 'holo' },
  { id: 'worldline', label: 'Worldline lab', tag: 'T36', mod: './scenes/worldline.js' },
  { id: 'crawl', label: 'The crawl', tag: 'T37·T30', mod: './scenes/crawl.js' },
  { id: 'phase', label: 'Phase maps', tag: 'T9…T37', mod: './scenes/phase.js' },
  { group: 'The open frontier' },
  { id: 'subsetlab', label: 'Screen lab', tag: 'open item', mod: './scenes/subsetlab.js' },
  { id: 'frontier', label: 'Beyond Lipschitz', tag: 'experiments', mod: './scenes/frontier.js' },
  { group: 'Foundations' },
  { id: 'cons', label: 'Consensus', tag: 'T0–T4·T12', wing: 'cons' },
  { id: 'toys', label: 'Toys', tag: 'T5·T8', wing: 'toys' },
  { group: 'The tower' },
  { id: 'hex', label: 'Hexacode', tag: 'T19·T22', wing: 'hex' },
  { id: 'thermal', label: 'Thermal time', tag: 'T21·T28', wing: 'thermal' },
  { id: 'dark', label: 'Dark sector', tag: 'T15', wing: 'dark' },
  { id: 'cage', label: 'Collar & cage', tag: 'T16·T10·T24', wing: 'cage' },
  { id: 'hyper', label: 'Hypercharge & ℤ₆', tag: 'T13', mod: './scenes/hypercharge.js' },
  { id: 'qbft', label: 'Quorums', tag: 'T23', mod: './scenes/qbft.js' },
  { group: 'Meta' },
  { id: 'map', label: 'The map', tag: 'v10', mod: './scenes/map.js' },
  { id: 'selftest', label: 'Self-tests', tag: '38 checks', mod: './scenes/selftest.js' },
];

const $ = id => document.getElementById(id);
const stageHost = $('stage'), panelHost = $('panelwrap'), nav = $('nav');

export function banner(kind, html) {
  const b = $('banner');
  if (!kind) { b.className = ''; b.classList.remove('show'); b.innerHTML = ''; return; }
  b.className = 'show ' + kind; b.innerHTML = html;
}
export function legend(html) {
  const L = $('legend');
  if (!html) { L.classList.remove('show'); L.innerHTML = ''; return; }
  L.innerHTML = html; L.classList.add('show');
}

const pages = {}, panels = {}, mounted = {};
let current = null, wingModule = null;

function ensurePage(id, is3d) {
  if (!pages[id]) {
    const d = document.createElement('div');
    d.className = is3d ? 'stage3d' : 'stagepage';
    stageHost.appendChild(d);
    pages[id] = d;
  }
  if (!panels[id]) {
    const p = document.createElement('div');
    p.className = 'scenepanel';
    panelHost.appendChild(p);
    panels[id] = p;
  }
  return { page: pages[id], panel: panels[id] };
}

async function activate(id) {
  const entry = SCENES.find(s => s.id === id);
  if (!entry) return activate('holo');
  if (current === id) return;
  banner(null); legend(null);

  // hide old
  if (current) {
    const old = SCENES.find(s => s.id === current);
    const oldPage = old && old.wing ? 'wing3d' : current;
    pages[oldPage] && pages[oldPage].classList.remove('active');
    panels[current] && panels[current].classList.remove('active');
    if (old && !old.wing && mounted[current] && mounted[current].hide) mounted[current].hide();
    if (old && old.wing && wingModule) wingModule.hideAll();
  }
  current = id;
  location.hash = '#/' + id;
  for (const el of nav.querySelectorAll('.navitem')) el.classList.toggle('active', el.dataset.id === id);

  const wing3d = !!entry.wing;
  const { page, panel } = ensurePage(wing3d ? 'wing3d' : id, wing3d);
  // 3D wing shares one page div but per-mode panels
  if (wing3d) {
    ensurePage(id, true);                       // ensure panel div for this id exists
    pages.wing3d.classList.add('active');
    if (!wingModule) {
      $('boot').style.display = 'flex';
      wingModule = await import('./wing3d.js');
      await wingModule.init({ stage: pages.wing3d, panelFor: mid => { ensurePage(mid, true); return panels[mid]; }, banner, legend });
      $('boot').style.display = 'none';
    }
    panels[id].classList.add('active');
    panelHost.classList.remove('hidden');
    stageHost.classList.add('withpanel');
    wingModule.show(entry.wing);
    return;
  }

  page.classList.add('active');
  if (!mounted[id]) {
    $('boot').style.display = 'flex';
    try {
      const mod = await import(entry.mod);
      mounted[id] = mod.default;
      await mounted[id].mount({ stage: page, panel, banner, legend });
    } catch (e) {
      page.innerHTML = `<div class="badge bad">scene failed to load: ${e && e.message}</div>`;
      console.error(e);
    }
    $('boot').style.display = 'none';
  } else if (mounted[id].showAgain) {
    mounted[id].showAgain();
  }
  const hasPanel = mounted[id] && mounted[id].panel !== false && panels[id].childNodes.length;
  panels[id].classList.toggle('active', !!hasPanel);
  panelHost.classList.toggle('hidden', !hasPanel);
  stageHost.classList.toggle('withpanel', !!hasPanel);
}

/* ------------------------------------------------------------- boot */
for (const s of SCENES) {
  if (s.group) {
    const g = document.createElement('div');
    g.className = 'navgroup'; g.textContent = s.group;
    nav.appendChild(g);
    continue;
  }
  const a = document.createElement('div');
  a.className = 'navitem'; a.dataset.id = s.id;
  a.innerHTML = s.label + (s.tag ? ` <span class="tag">${s.tag}</span>` : '');
  a.addEventListener('click', () => activate(s.id));
  nav.appendChild(a);
}

const initial = (location.hash.match(/^#\/([\w-]+)/) || [])[1] || 'holo';
$('boot').style.display = 'none';
activate(initial);
window.addEventListener('hashchange', () => {
  const id = (location.hash.match(/^#\/([\w-]+)/) || [])[1];
  if (id && id !== current) activate(id);
});
