// Build guard: fail if any content body mentions an excluded project.
import { readdir, readFile } from 'node:fs/promises';
import { join } from 'node:path';

const FORBIDDEN = [
  /\bMAS\b/, /MAS_codebase/i,
  /djemkati/i, /manuscript archive/i,
  /plurilateral/i, /\bOCP\b/, /\bOAP\b/,
  // water-resilience work, confirmed excluded 2026-09-15
  /water resilien/i, /lassiter/i, /water systems lab/i, /\bsalinity\b/i,
];
const ROOTS = ['src/content', 'src/pages', 'src/components', 'src/layouts'];

let hits = [];
async function walk(dir) {
  let entries;
  try { entries = await readdir(dir, { withFileTypes: true }); } catch { return; }
  for (const e of entries) {
    const p = join(dir, e.name);
    if (e.isDirectory()) { await walk(p); continue; }
    if (!/\.(md|mdx|astro|ts|js)$/.test(e.name)) continue;
    const text = await readFile(p, 'utf8');
    text.split('\n').forEach((line, i) => {
      for (const re of FORBIDDEN) {
        if (re.test(line)) hits.push(`${p}:${i + 1}  ${line.trim().slice(0, 90)}`);
      }
    });
  }
}
for (const r of ROOTS) await walk(r);

if (hits.length) {
  console.error('Excluded terms found in site content:\n' + hits.map(h => '  ' + h).join('\n'));
  process.exit(1);
}
console.log('content check: no excluded terms found');
