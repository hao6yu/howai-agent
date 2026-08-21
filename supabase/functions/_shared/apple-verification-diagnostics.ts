export type AppleTransactionJwsDiagnostic = Readonly<{
  certificate_chain_length: number | null;
  compact_parts: number;
  header_algorithm: string | null;
  payload_bundle_id: string | null;
  payload_environment: string | null;
  payload_has_expiration: boolean;
  payload_has_original_transaction_id: boolean;
  payload_has_transaction_id: boolean;
  payload_product_id: string | null;
  bundle_id_matches_expected: boolean | null;
  product_id_allowed: boolean | null;
  signed_transaction_length: number;
}>;

export function summarizeAppleTransactionJws(
  signedTransaction: string,
  expectedBundleId: string,
  allowedProductIds: ReadonlySet<string>,
): AppleTransactionJwsDiagnostic {
  const parts = signedTransaction.split(".");
  const header = decodeBase64UrlJson(parts[0]);
  const payload = decodeBase64UrlJson(parts[1]);
  const bundleId = boundedText(payload?.bundleId);
  const productId = boundedText(payload?.productId);

  return Object.freeze({
    certificate_chain_length: Array.isArray(header?.x5c)
      ? header.x5c.length
      : null,
    compact_parts: parts.length,
    header_algorithm: boundedText(header?.alg),
    payload_bundle_id: bundleId,
    payload_environment: boundedText(payload?.environment),
    payload_has_expiration: isPositiveSafeInteger(payload?.expiresDate),
    payload_has_original_transaction_id:
      boundedText(payload?.originalTransactionId) != null,
    payload_has_transaction_id: boundedText(payload?.transactionId) != null,
    payload_product_id: productId,
    bundle_id_matches_expected: bundleId == null
      ? null
      : bundleId === expectedBundleId,
    product_id_allowed: productId == null
      ? null
      : allowedProductIds.has(productId),
    signed_transaction_length: signedTransaction.length,
  });
}

function decodeBase64UrlJson(
  value: string | undefined,
): Record<string, unknown> | null {
  if (!value || value.length > 32 * 1024) return null;

  try {
    const base64 = value.replaceAll("-", "+").replaceAll("_", "/");
    const padded = base64.padEnd(Math.ceil(base64.length / 4) * 4, "=");
    const decoded = JSON.parse(atob(padded));
    return decoded && typeof decoded === "object" && !Array.isArray(decoded)
      ? decoded as Record<string, unknown>
      : null;
  } catch {
    return null;
  }
}

function boundedText(value: unknown): string | null {
  if (typeof value !== "string") return null;
  const result = value.trim();
  return result.length > 0 && result.length <= 256 ? result : null;
}

function isPositiveSafeInteger(value: unknown): boolean {
  return typeof value === "number" && Number.isSafeInteger(value) && value > 0;
}
