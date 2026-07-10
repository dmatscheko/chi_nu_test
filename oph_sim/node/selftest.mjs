/* Headless runner for the theorem cross-check battery: node node/selftest.mjs */
import { runAll } from '../js/lib/selftest.js';

let pass = 0, fail = 0;
runAll(r => {
  const mark = r.pass ? '\x1b[32m✓\x1b[0m' : '\x1b[31m✗ FAIL\x1b[0m';
  console.log(`${mark} [${r.group}] ${r.name} (${r.ms} ms)`);
  console.log(`   ${r.lean}`);
  console.log(`   ${r.detail}`);
  r.pass ? pass++ : fail++;
});
console.log(`\n${pass} passed, ${fail} failed`);
process.exit(fail ? 1 : 0);
