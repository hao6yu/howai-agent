export type GooglePlaySubscription = Readonly<{
  subscriptionState?: unknown;
  lineItems?: unknown;
  linkedPurchaseToken?: unknown;
  externalAccountIdentifiers?: unknown;
  testPurchase?: unknown;
}>;

export type GooglePlayEntitlementDecision = Readonly<{
  active: boolean;
  expiresAt: string;
  productId: string;
  state: string;
  linkedPurchaseToken: string | null;
  obfuscatedExternalAccountId: string | null;
  testPurchase: boolean;
}>;

export class GooglePlayEntitlementValidationError extends Error {}

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
  if (selectedProductId == null || latestExpiryMs == null) {
    throw new GooglePlayEntitlementValidationError(
      "Google Play purchase does not contain the requested subscription.",
    );
  }
  return Object.freeze({
    active: latestExpiryMs > nowMs &&
      ENTITLED_STATES.has(state),
    expiresAt: new Date(latestExpiryMs).toISOString(),
    productId: selectedProductId,
    state,
    linkedPurchaseToken: boundedText(value.linkedPurchaseToken, 4 * 1024),
    obfuscatedExternalAccountId: boundedText(
      external?.obfuscatedExternalAccountId,
      512,
    ),
    testPurchase: isRecord(value.testPurchase),
  });
}

export function allowGooglePlayTestPurchases(
  value: string | null | undefined,
): boolean {
  return value?.trim().toLowerCase() === "true";
}

function boundedText(value: unknown, maximumLength: number): string | null {
  if (typeof value !== "string") return null;
  const text = value.trim();
  return text.length > 0 && text.length <= maximumLength ? text : null;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return value != null && typeof value === "object" && !Array.isArray(value);
}
