const CACHE_IDENTITY_PATTERN = /^[A-Za-z0-9][A-Za-z0-9._:-]{0,127}$/;

export function conversationCacheIdentity(
  metadata: unknown,
): string | null {
  if (!metadata || typeof metadata !== "object" || Array.isArray(metadata)) {
    return null;
  }
  const value = (metadata as Record<string, unknown>).howai_conversation_key;
  if (typeof value !== "string") return null;
  const normalized = value.trim();
  return CACHE_IDENTITY_PATTERN.test(normalized) ? normalized : null;
}

/// Produces a privacy-preserving, server-owned key. The client supplies only
/// the stable conversation identity; it cannot choose a raw OpenAI cache key
/// or collide with another user/model scope.
export async function serverPromptCacheKey(input: {
  userId: string;
  model: string;
  conversationIdentity: string | null;
}): Promise<string | null> {
  const conversationIdentity = input.conversationIdentity;
  if (!conversationIdentity) return null;

  const digest = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(
      `howai:v1:${input.userId}:${input.model}:${conversationIdentity}`,
    ),
  );
  return [...new Uint8Array(digest)]
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}
