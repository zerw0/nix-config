import test from 'node:test';
import assert from 'node:assert/strict';
import { installOwnershipFallback } from '../modules/homelab/services/epicgames-freegames/ownership.mjs';

const failure = 'Entitlements/cartOffersValidation: Request failed with status code 401';
function setup({ original = async () => { throw new Error(failure); }, rows = [], items = [{ id: 'item', namespace: 'ns' }], status = 200, auth = { account_id: 'account', access_token: 'test' } } = {}) {
  class Games { email = 'test'; L = { info() {} }; }
  Games.prototype.canPurchase = original;
  let calls = 0;
  installOwnershipFallback(Games, async () => auth, async url => {
    calls++;
    return { ok: status === 200, status, json: async () => url.includes('/entitlements?') ? rows : { items } };
  });
  const games = new Games();
  return { games, calls: () => calls };
}

test('preserves successful upstream validation', async () => {
  const { games, calls } = setup({ original: async () => false });
  assert.equal(await games.canPurchase('offer', 'ns'), false);
  assert.equal(calls(), 0);
});
test('does not suppress unrelated errors', async () => {
  const { games, calls } = setup({ original: async () => { throw new Error('network failure'); } });
  await assert.rejects(games.canPurchase('offer', 'ns'), /network failure/);
  assert.equal(calls(), 0);
});
test('filters owned items and shares inventory across concurrent offers', async () => {
  const { games, calls } = setup({ rows: [{ namespace: 'ns', catalogItemId: 'item', active: true, status: 'ACTIVE' }] });
  assert.deepEqual(await Promise.all([games.canPurchase('a', 'ns'), games.canPurchase('b', 'ns')]), [false, false]);
  assert.equal(calls(), 3);
});
test('includes unowned and partially owned offers', async () => {
  const { games } = setup({ rows: [{ namespace: 'ns', catalogItemId: 'item', active: true, status: 'ACTIVE' }], items: [{ namespace: 'ns', id: 'item' }, { namespace: 'ns', id: 'other' }] });
  assert.equal(await games.canPurchase('offer', 'ns'), true);
});
test('ignores inactive entitlements', async () => {
  const { games } = setup({ rows: [{ namespace: 'ns', catalogItemId: 'item', active: false, status: 'REVOKED' }] });
  assert.equal(await games.canPurchase('offer', 'ns'), true);
});
test('fails on API errors instead of claiming everything is unowned', async () => {
  const { games } = setup({ status: 403 });
  await assert.rejects(games.canPurchase('offer', 'ns'), /HTTP 403/);
});
test('rejects malformed catalog and inventory responses', async () => {
  await assert.rejects(setup({ items: [] }).games.canPurchase('offer', 'ns'), /ownership items/);
  await assert.rejects(setup({ rows: {} }).games.canPurchase('offer', 'ns'), /entitlement response/);
});
test('requires saved account auth', async () => {
  await assert.rejects(setup({ auth: null }).games.canPurchase('offer', 'ns'), /cartOffersValidation/);
});

test('loads later entitlement pages before deciding ownership', async () => {
  class Games {
    email = 'test';
    L = { info() {} };
    async canPurchase() { throw new Error(failure); }
  }
  const offsets = [];
  installOwnershipFallback(Games, async () => ({ account_id: 'account', access_token: 'test' }), async url => {
    let result;
    if (url.includes('/entitlements?')) {
      const start = Number(new URL(url).searchParams.get('start'));
      offsets.push(start);
      result = start === 0
        ? Array.from({ length: 1000 }, (_, i) => ({ namespace: 'ns', catalogItemId: `old-${i}`, active: true, status: 'ACTIVE' }))
        : [{ namespace: 'ns', catalogItemId: 'item', active: true, status: 'ACTIVE' }];
    } else {
      result = { items: [{ namespace: 'ns', id: 'item' }] };
    }
    return { ok: true, json: async () => result };
  });
  assert.equal(await new Games().canPurchase('offer', 'ns'), false);
  assert.deepEqual(offsets, [0, 1000]);
});

test('preload does not initialize the checker in logging workers', async () => {
  const { readFile, mkdtemp, writeFile, rm } = await import('node:fs/promises');
  const { tmpdir } = await import('node:os');
  const { join } = await import('node:path');
  const { pathToFileURL } = await import('node:url');
  const { Worker } = await import('node:worker_threads');
  const source = await readFile(new URL('../modules/homelab/services/epicgames-freegames/default.nix', import.meta.url), 'utf8');
  const loader = source.match(/ownershipPreload = pkgs.writeText "epic-ownership-preload.mjs" ''\n([\s\S]*?)\n  '';/)?.[1];
  assert.ok(loader);
  const dir = await mkdtemp(join(tmpdir(), 'epic-loader-test-'));
  try {
    const file = join(dir, 'preload.mjs');
    await writeFile(file, loader);
    const code = `process.argv[1] = '/usr/app/dist/src/index.js'; await import(${JSON.stringify(pathToFileURL(file).href)});`;
    await new Promise((resolve, reject) => {
      const worker = new Worker(new URL(`data:text/javascript,${encodeURIComponent(code)}`));
      worker.on('error', reject);
      worker.on('exit', code => code === 0 ? resolve() : reject(new Error(`Worker exited ${code}`)));
    });
  } finally {
    await rm(dir, { recursive: true, force: true });
  }
});
