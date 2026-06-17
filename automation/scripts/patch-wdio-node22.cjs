/**
 * patch-wdio-node22.cjs
 *
 * Postinstall patch for @wdio/local-runner/build/worker.js
 *
 * Problem: On Node 22+, the ESM hooks API requires all resolve hooks to either
 * call nextResolve() or return { shortCircuit: true }. The ts-node/esm loader
 * (version compatible with wdio 8) does not do this, causing every worker to
 * crash immediately with:
 *   Error: "ts-node/esm/transpile-only 'resolve'" did not call the next hook
 *          in its chain and did not explicitly signal a short circuit.
 *
 * Fix: Add a Node major version guard so the ts-node loader is never injected
 * into worker NODE_OPTIONS when running on Node >= 22.
 *
 * This script is idempotent — safe to run multiple times.
 */

'use strict';

const fs = require('fs');
const path = require('path');

const workerPath = path.join(
    __dirname,
    '..',
    'node_modules',
    '@wdio',
    'local-runner',
    'build',
    'worker.js'
);

if (!fs.existsSync(workerPath)) {
    console.warn('[patch-wdio-node22] worker.js not found, skipping patch:', workerPath);
    process.exit(0);
}

const original = fs.readFileSync(workerPath, 'utf8');

// Guard: don't re-apply if already patched
if (original.includes('/* patch-wdio-node22 */')) {
    console.log('[patch-wdio-node22] Patch already applied, skipping.');
    process.exit(0);
}

// Target: the condition block that injects the ts-node ESM loader into worker env.
// We insert a Node version guard so it is skipped on Node >= 22.
const TARGET = `!(process.env.NODE_OPTIONS || '').includes('--loader ts-node/esm')) {`;
const REPLACEMENT = `!(process.env.NODE_OPTIONS || '').includes('--loader ts-node/esm') &&
            /* patch-wdio-node22 */ parseInt(process.versions.node.split('.')[0], 10) < 22) {`;

if (!original.includes(TARGET)) {
    console.warn('[patch-wdio-node22] Target string not found in worker.js — the package may have changed. Skipping patch.');
    process.exit(0);
}

const patched = original.replace(TARGET, REPLACEMENT);
fs.writeFileSync(workerPath, patched, 'utf8');
console.log('[patch-wdio-node22] ✅ Patch applied: ts-node ESM loader disabled for Node >= 22 in @wdio/local-runner worker.js');
