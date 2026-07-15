export type AppleTransactionPayload = Readonly<{
  appAccountToken?: string | null;
  bundleId?: string | null;
  environment?: string | null;
  expiresDate?: number | null;
  originalTransactionId?: string | null;
  productId?: string | null;
  purchaseDate?: number | null;
  revocationDate?: number | null;
  signedDate?: number | null;
  transactionId?: string | null;
  type?: string | null;
}>;

export type AppleEntitlementConfig = Readonly<{
  bundleId: string;
  environment: "Production" | "Sandbox";
  productIds: ReadonlySet<string>;
}>;

export type AppleEntitlementDecision = Readonly<{
  active: boolean;
  appAccountToken: string | null;
  environment: "Production" | "Sandbox";
  expiresAt: string;
  originalTransactionId: string;
  productId: string;
  revoked: boolean;
  signedAt: string | null;
  transactionId: string;
}>;

export class AppleEntitlementValidationError extends Error {}

export function evaluateAppleTransaction(
  payload: AppleTransactionPayload,
  config: AppleEntitlementConfig,
  nowMs = Date.now(),
): AppleEntitlementDecision {
  if (payload.bundleId !== config.bundleId) {
    throw new AppleEntitlementValidationError("Unexpected App Store bundle identifier.");
  }

  if (payload.environment !== config.environment) {
    throw new AppleEntitlementValidationError("Unexpected App Store environment.");
  }

  const productId = requiredText(payload.productId, "product identifier");
  if (!config.productIds.has(productId)) {
    throw new AppleEntitlementValidationError("Unexpected App Store product identifier.");
  }

  const originalTransactionId = requiredText(
    payload.originalTransactionId,
    "original transaction identifier",
  );
  const transactionId = requiredText(payload.transactionId, "transaction identifier");
  const expiresDate = requiredTimestamp(payload.expiresDate, "expiration date");
  const revocationDate = optionalTimestamp(payload.revocationDate, "revocation date");
  const signedDate = optionalTimestamp(payload.signedDate, "signed date");

  if (signedDate != null && signedDate > nowMs + 10 * 60 * 1_000) {
    throw new AppleEntitlementValidationError("App Store transaction is signed in the future.");
  }

  return Object.freeze({
    active: revocationDate == null && expiresDate > nowMs,
    appAccountToken: optionalText(payload.appAccountToken),
    environment: config.environment,
    expiresAt: new Date(expiresDate).toISOString(),
    originalTransactionId,
    productId,
    revoked: revocationDate != null,
    signedAt: signedDate == null ? null : new Date(signedDate).toISOString(),
    transactionId,
  });
}

function requiredText(value: unknown, label: string): string {
  const result = optionalText(value);
  if (result == null) {
    throw new AppleEntitlementValidationError(`Missing App Store ${label}.`);
  }
  return result;
}

function optionalText(value: unknown): string | null {
  if (typeof value !== "string") return null;
  const result = value.trim();
  return result.length > 0 && result.length <= 256 ? result : null;
}

function requiredTimestamp(value: unknown, label: string): number {
  const result = optionalTimestamp(value, label);
  if (result == null) {
    throw new AppleEntitlementValidationError(`Missing App Store ${label}.`);
  }
  return result;
}

function optionalTimestamp(value: unknown, label: string): number | null {
  if (value == null) return null;
  if (typeof value !== "number" || !Number.isSafeInteger(value) || value <= 0) {
    throw new AppleEntitlementValidationError(`Invalid App Store ${label}.`);
  }
  return value;
}
