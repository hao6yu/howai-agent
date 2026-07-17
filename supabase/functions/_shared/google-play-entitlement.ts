export type GooglePlaySubscription = Readonly<{
  subscriptionState?: unknown;
  lineItems?: unknown;
  linkedPurchaseToken?: unknown;
  externalAccountIdentifiers?: unknown;
  testPurchase?: unknown;
}>;

export type GooglePlayEntitlementDecision = Readonly<{
  active: boolean;
  expiresAt: string | null;
  productId: string | null;
  state: string;
  linkedPurchaseToken: string | null;
  obfuscatedExternalAccountId: string | null;
  testPurchase: boolean;
}>;

const ENTITLED_STATES = new Set([
  "SUBSCRIPTION_STATE_ACTIVE",
  "SUBSCRIPTION_STATE_IN_GRACE_PERIOD",
  // A canceled auto-renewing subscription remains entitled through its paid
  // expiration. The line-item expiry remains the final authority.
  "SUBSCRIPTION_STATE_CANCELED",
]);

export function evaluateGooglePlaySubscription(
  value: GooglePlaySubscription,
  productIds: ReadonlySet<string>,
  expectedProductId: string,
  nowMs = Date.now(),
): GooglePlayEntitlementDecision {
  const state = typeof value.subscriptionState === "string"
    ? value.subscriptionState
    : "SUBSCRIPTION_STATE_UNSPECIFIED";
  const items = Array.isArray(value.lineItems) ? value.lineItems : [];

  let selectedProductId: string | null = null;
  let latestExpiryMs: number | null = null;
  for (const raw of items) {
    if (!isRecord(raw)) continue;
    const productId = typeof raw.productId === "string" ? raw.productId : null;
    const expiryTime = typeof raw.expiryTime === "string"
      ? Date.parse(raw.expiryTime)
      : Number.NaN;
    if (
      productId == null || !productIds.has(productId) ||
      productId !== expectedProductId || !Number.isFinite(expiryTime)
    ) {
      continue;
    }
    if (latestExpiryMs == null || expiryTime > latestExpiryMs) {
      selectedProductId = productId;
      latestExpiryMs = expiryTime;
    }
  }

  const external = isRecord(value.externalAccountIdentifiers)
    ? value.externalAccountIdentifiers
    : null;
  return Object.freeze({
    active: selectedProductId != null &&
      latestExpiryMs != null &&
      latestExpiryMs > nowMs &&
      ENTITLED_STATES.has(state),
    expiresAt: latestExpiryMs == null
      ? null
      : new Date(latestExpiryMs).toISOString(),
    productId: selectedProductId,
    state,
    linkedPurchaseToken: boundedText(value.linkedPurchaseToken),
    obfuscatedExternalAccountId: boundedText(
      external?.obfuscatedExternalAccountId,
    ),
    testPurchase: isRecord(value.testPurchase),
  });
}

function boundedText(value: unknown): string | null {
  if (typeof value !== "string") return null;
  const text = value.trim();
  return text.length > 0 && text.length <= 512 ? text : null;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return value != null && typeof value === "object" && !Array.isArray(value);
}
