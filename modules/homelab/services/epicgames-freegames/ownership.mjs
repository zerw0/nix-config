export function installOwnershipFallback(PuppetFreeGames, getAccountAuth, request = fetch) {
  const original = PuppetFreeGames.prototype.canPurchase;
  const inventories = new WeakMap();

  async function json(url, token) {
    const response = await request(url, {
      headers: { Authorization: `Bearer ${token}` },
      signal: AbortSignal.timeout(30000),
    });
    if (!response.ok) throw new Error(`Epic ownership API returned HTTP ${response.status}`);
    return response.json();
  }

  async function inventory(instance, auth) {
    if (!inventories.has(instance)) {
      inventories.set(instance, (async () => {
        const owned = new Set();
        const count = 1000;
        for (let start = 0; ; start += count) {
          const rows = await json(
            `https://entitlement-public-service-prod08.ol.epicgames.com/entitlement/api/account/${encodeURIComponent(auth.account_id)}/entitlements?start=${start}&count=${count}`,
            auth.access_token,
          );
          if (!Array.isArray(rows)) throw new Error('Invalid Epic entitlement response');
          for (const row of rows) {
            if (row.active === true && row.status === 'ACTIVE' && row.namespace && row.catalogItemId) {
              owned.add(`${row.namespace}:${row.catalogItemId}`);
            }
          }
          if (rows.length < count) return owned;
          if (start >= 100000) throw new Error('Epic entitlement pagination limit exceeded');
        }
      })());
    }
    return inventories.get(instance);
  }

  PuppetFreeGames.prototype.canPurchase = async function (offerId, namespace) {
    try {
      return await original.call(this, offerId, namespace);
    } catch (error) {
      if (!/Entitlements\/cartOffersValidation: Request failed with status code 401/.test(error.message)) {
        throw error;
      }
      const auth = await getAccountAuth(this.email);
      if (!auth?.access_token || !auth.account_id) throw error;
      const [owned, offer] = await Promise.all([
        inventory(this, auth),
        json(
          `https://catalog-public-service-prod06.ol.epicgames.com/catalog/api/shared/namespace/${encodeURIComponent(namespace)}/offers/${encodeURIComponent(offerId)}?country=US&locale=en-US`,
          auth.access_token,
        ),
      ]);
      if (!Array.isArray(offer.items) || !offer.items.length || offer.items.some(item => !item.id || !item.namespace)) {
        throw new Error('Epic offer has no valid ownership items');
      }
      const unowned = !offer.items.every(item => owned.has(`${item.namespace}:${item.id}`));
      this.L.info({ offerId, unowned }, 'Used account entitlements for ownership; checkout validates purchase eligibility');
      return unowned;
    }
  };
}
