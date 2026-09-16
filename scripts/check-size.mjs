// Build guard: fail if any file in public/ or dist/ exceeds 50 MB.
import { readdir, stat } from 'node:fs/promises';
import { join } from 'node:path';
const LIMIT = 50 * 1024 * 1024;
let big = [];
async function walk(dir) {
  let entries;
  try { entries = await readdir(dir, { withFileTypes: true }); } catch { return; }
  for (const e of entries) {
    const p = join(dir, e.name);
    if (e.isDirectory()) { await walk(p); continue; }
    const s = await stat(p);
    if (s.size > LIMIT) big.push(`${p}  ${(s.size / 1048576).toFixed(1)} MB`);
  }
}
await walk('public'); await walk('dist');
if (big.length) {
  console.error('Files over 50 MB:\n' + big.map(b => '  ' + b).join('\n'));
  process.exit(1);
}
console.log('size check: no file over 50 MB');
