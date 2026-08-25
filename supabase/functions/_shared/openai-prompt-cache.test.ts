import assert from "node:assert/strict";
import test from "node:test";

import {
  conversationCacheIdentity,
  serverPromptCacheKey,
} from "./openai-prompt-cache.ts";

test("accepts a bounded conversation identity and rejects unsafe input", () => {
  assert.equal(
    conversationCacheIdentity({ howai_conversation_key: "  abc-123  " }),
    "abc-123",
  );
  assert.equal(
    conversationCacheIdentity({ howai_conversation_key: "contains space" }),
    null,
  );
  assert.equal(conversationCacheIdentity(null), null);
});

test("builds stable cache keys scoped by user and model", async () => {
  const first = await serverPromptCacheKey({
    userId: "user-a",
    model: "gpt-5.6-sol",
    conversationIdentity: "conversation-a",
  });
  const repeated = await serverPromptCacheKey({
    userId: "user-a",
    model: "gpt-5.6-sol",
    conversationIdentity: "conversation-a",
  });
  const otherUser = await serverPromptCacheKey({
    userId: "user-b",
    model: "gpt-5.6-sol",
    conversationIdentity: "conversation-a",
  });

  assert.equal(first, repeated);
  assert.equal(first?.length, 64);
  assert.notEqual(first, otherUser);
});
