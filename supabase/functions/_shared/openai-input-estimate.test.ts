import assert from "node:assert/strict";
import test from "node:test";

import { estimateResponsesInputTokens } from "./openai-input-estimate.ts";

test("counts ordinary request text", () => {
  const estimate = estimateResponsesInputTokens({
    model: "howai-chat",
    instructions: "a".repeat(4_000),
    input: "hello",
  });

  assert.ok(estimate >= 1_000);
  assert.ok(estimate < 1_100);
});

test("does not price inline image base64 as text tokens", () => {
  const small = estimateResponsesInputTokens({
    input: [{
      role: "user",
      content: [{
        type: "input_image",
        image_url: `data:image/jpeg;base64,${"a".repeat(100)}`,
        detail: "high",
      }],
    }],
  });
  const phonePhoto = estimateResponsesInputTokens({
    input: [{
      role: "user",
      content: [{
        type: "input_image",
        image_url: `data:image/jpeg;base64,${"a".repeat(1_900_000)}`,
        detail: "high",
      }],
    }],
  });

  assert.equal(phonePhoto, small);
  assert.ok(phonePhoto >= 2_500);
  assert.ok(phonePhoto < 2_600);
});

test("reserves more image tokens when an older client omits detail", () => {
  const highDetail = estimateResponsesInputTokens({
    input: [{
      type: "input_image",
      image_url: "https://example.com/a.jpg",
      detail: "high",
    }],
  });
  const originalDetail = estimateResponsesInputTokens({
    input: [{ type: "input_image", image_url: "https://example.com/a.jpg" }],
  });

  assert.ok(originalDetail > highDetail);
  assert.ok(originalDetail >= 10_000);
});

test("does not price inline file base64 as text tokens", () => {
  const estimate = estimateResponsesInputTokens({
    input: [{
      type: "input_file",
      filename: "report.pdf",
      file_data: `data:application/pdf;base64,${"b".repeat(2_000_000)}`,
    }],
  });

  assert.ok(estimate >= 20_000);
  assert.ok(estimate < 20_100);
});
