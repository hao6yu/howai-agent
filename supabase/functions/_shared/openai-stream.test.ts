import assert from "node:assert/strict";
import test from "node:test";

import { ResponsesSseUsageCollector } from "./openai-stream.ts";

const encoder = new TextEncoder();

test("collects usage when an SSE event is split across byte chunks", () => {
  const collector = new ResponsesSseUsageCollector();
  const event = [
    "event: response.completed",
    'data: {"type":"response.completed","response":{"id":"resp_1","output":[{"type":"message","content":[{"type":"output_text","text":"Done"}]}],"usage":{"input_tokens":120,"input_tokens_details":{"cached_tokens":20},"output_tokens":30,"total_tokens":150}}}',
    "",
    "",
  ].join("\r\n");
  const bytes = encoder.encode(event);

  assert.equal(collector.push(bytes.slice(0, 37)), null);
  assert.deepEqual(collector.push(bytes.slice(37)), {
    responseId: "resp_1",
    inputTokens: 120,
    cachedInputTokens: 20,
    outputTokens: 30,
    totalTokens: 150,
    hasFinalOutput: true,
    terminalEvent: "response.completed",
  });
});

test("ignores delta events and malformed telemetry without throwing", () => {
  const collector = new ResponsesSseUsageCollector();
  collector.push(encoder.encode('data: {"type":"response.output_text.delta"}\n\n'));
  collector.push(encoder.encode("data: {bad json}\n\n"));

  assert.equal(collector.finish(), null);
});

test("detects the first visible output-text delta", () => {
  const collector = new ResponsesSseUsageCollector();
  collector.push(encoder.encode(
    'data: {"type":"response.created"}\n\ndata: {"type":"response.output_text.delta","delta":"Hi"}\n\n',
  ));

  assert.equal(collector.sawVisibleOutputDelta, true);
});

test("treats a refusal delta as visible output", () => {
  const collector = new ResponsesSseUsageCollector();
  collector.push(encoder.encode(
    'data: {"type":"response.refusal.delta","delta":"I can’t help with that."}\n\n',
  ));

  assert.equal(collector.sawVisibleOutputDelta, true);
});

test("parses a final event even when no blank-line terminator arrives", () => {
  const collector = new ResponsesSseUsageCollector();
  collector.push(encoder.encode(
    'data: {"type":"response.completed","response":{"id":"resp_2","usage":{"input_tokens":2,"output_tokens":3}}}',
  ));

  assert.deepEqual(collector.finish(), {
    responseId: "resp_2",
    inputTokens: 2,
    cachedInputTokens: null,
    outputTokens: 3,
    totalTokens: 5,
    hasFinalOutput: false,
    terminalEvent: "response.completed",
  });
});

test("captures billed usage from a failed terminal response", () => {
  const collector = new ResponsesSseUsageCollector();
  collector.push(encoder.encode(
    'data: {"type":"response.failed","response":{"id":"resp_3","usage":{"input_tokens":7,"output_tokens":1}}}\n\n',
  ));

  assert.deepEqual(collector.finish(), {
    responseId: "resp_3",
    inputTokens: 7,
    cachedInputTokens: null,
    outputTokens: 1,
    totalTokens: 8,
    hasFinalOutput: false,
    terminalEvent: "response.failed",
  });
});

test("does not count a tool-only completion as a final answer", () => {
  const collector = new ResponsesSseUsageCollector();
  collector.push(encoder.encode(
    'data: {"type":"response.completed","response":{"id":"resp_4","output":[{"type":"function_call","name":"generate_pptx"}],"usage":{"input_tokens":5,"output_tokens":2}}}\n\n',
  ));

  assert.equal(collector.finish()?.hasFinalOutput, false);
});
