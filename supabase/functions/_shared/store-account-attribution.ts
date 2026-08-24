export class StoreAccountAttributionError extends Error {}

/**
 * New purchases carry the HowAI account UUID supplied at checkout. Legacy
 * purchases may omit it and remain restorable, but a present identifier must
 * never be silently transferred to another account.
 */
export function assertStoreAccountAttribution(
  expectedUserId: string,
  storeAccountId: string | null,
  storeLabel: string,
): void {
  if (
    storeAccountId != null &&
    normalizeAccountId(storeAccountId) !== normalizeAccountId(expectedUserId)
  ) {
    throw new StoreAccountAttributionError(
      `${storeLabel} purchase belongs to another HowAI account.`,
    );
  }
}

export function assertAuthenticatedAccountRequest(
  authenticatedUserId: string,
  requestedAccountId: unknown,
): void {
  // Released clients predate this request field. Keep them working while all
  // new clients send it; once present it must match the authenticated session.
  if (requestedAccountId == null) {
    return;
  }

  if (
    typeof requestedAccountId !== "string" ||
    normalizeAccountId(requestedAccountId) !==
      normalizeAccountId(authenticatedUserId)
  ) {
    throw new StoreAccountAttributionError(
      "The purchase request account changed. Please try again.",
    );
  }
}

function normalizeAccountId(value: string): string {
  return value.trim().toLowerCase();
}
