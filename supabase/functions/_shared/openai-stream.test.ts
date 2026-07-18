import assert from "node:assert/strict";
import test from "node:test";

import {
  ResponsesSseUsageCollector,
  responsesUsageHasDeliveredResult,
} from "./openai-stream.ts";

const encoder = new TextEncoder();

test("collects usage when an SSE event is split across byte chunks", () => {
  const collector = new ResponsesSseUsageCollector();
  const event = [
    "event: response.completed",
    'data: {"type":"response.completed","response":{"id":"resp_1","model":"gpt-5.6-sol-2026-07-01","output":[{"type":"message","content":[{"type":"output_text","text":"Done"}]}],"usage":{"input_tokens":120,"input_tokens_details":{"cached_tokens":20},"output_tokens":30,"total_tokens":150}}}',
    "",
    "",
  ].join("\r\n");
  const bytes = encoder.encode(event);

  assert.equal(collector.push(bytes.slice(0, 37)), null);
  assert.deepEqual(collector.push(bytes.slice(37)), {
    responseId: "resp_1",
    model: "gpt-5.6-sol-2026-07-01",
    inputTokens: 120,
    cachedInputTokens: 20,
    outputTokens: 30,
    totalTokens: 150,
    hasFinalOutput: true,
    webSearchCalls: 0,
    imageGenerationCalls: 0,
    hasWebSearchCitations: false,
    terminalEvent: "response.completed",
  });
});

test("ignores delta events and malformed telemetry without throwing", () => {
  const collector = new ResponsesSseUsageCollector();
  collector.push(
    encoder.encode('data: {"type":"response.output_text.delta"}\n\n'),
  );
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
    model: null,
    inputTokens: 2,
    cachedInputTokens: null,
    outputTokens: 3,
    totalTokens: 5,
    hasFinalOutput: false,
    webSearchCalls: 0,
    imageGenerationCalls: 0,
    hasWebSearchCitations: false,
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
    model: null,
    inputTokens: 7,
    cachedInputTokens: null,
    outputTokens: 1,
    totalTokens: 8,
    hasFinalOutput: false,
    webSearchCalls: 0,
    imageGenerationCalls: 0,
    hasWebSearchCitations: false,
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

test("counts completed web searches and detects URL citations", () => {
  const collector = new ResponsesSseUsageCollector();
  collector.push(encoder.encode(
    'data: {"type":"response.completed","response":{"id":"resp_5","output":[{"type":"web_search_call","status":"completed"},{"type":"web_search_call","status":"in_progress"},{"type":"message","content":[{"type":"output_text","text":"Current answer","annotations":[{"type":"url_citation","url":"https://example.test"}]}]}],"usage":{"input_tokens":9,"output_tokens":4}}}\n\n',
  ));

  const usage = collector.finish();
  assert.equal(usage?.webSearchCalls, 1);
  assert.equal(usage?.hasWebSearchCitations, true);
  assert.equal(usage?.hasFinalOutput, true);
});

test("does not treat incomplete web-search calls as billable completions", () => {
  const collector = new ResponsesSseUsageCollector();
  collector.push(encoder.encode(
    'data: {"type":"response.failed","response":{"id":"resp_6","output":[{"type":"web_search_call","status":"in_progress"}],"usage":{"input_tokens":2,"output_tokens":0}}}\n\n',
  ));

  assert.equal(collector.finish()?.webSearchCalls, 0);
});

test("counts a completed image result as a final answer", () => {
  const collector = new ResponsesSseUsageCollector();
  collector.push(encoder.encode(
    'data: {"type":"response.completed","response":{"id":"resp_7","output":[{"type":"image_generation_call","status":"completed","result":"aW1hZ2U="}],"usage":{"input_tokens":3,"output_tokens":1}}}\n\n',
  ));

  const usage = collector.finish();
  assert.equal(usage?.imageGenerationCalls, 1);
  assert.equal(usage?.hasFinalOutput, true);
});

test("counts a terminal image result even when its status still says generating", () => {
  const collector = new ResponsesSseUsageCollector();
  collector.push(
    encoder.encode(
      'data: {"type":"response.completed","response":{"id":"resp_7b","output":[{"type":"image_generation_call","status":"generating","result":"aW1hZ2U="}],"usage":{"input_tokens":3,"output_tokens":1}}}\n\n',
    ),
  );

  assert.equal(collector.finish()?.imageGenerationCalls, 1);
  assert.equal(collector.finish()?.hasFinalOutput, true);
});

test("does not count incomplete image generation as a completed image", () => {
  const collector = new ResponsesSseUsageCollector();
  collector.push(encoder.encode(
    'data: {"type":"response.incomplete","response":{"id":"resp_8","output":[{"type":"image_generation_call","status":"in_progress"}],"usage":{"input_tokens":3,"output_tokens":0}}}\n\n',
  ));

  const usage = collector.finish();
  assert.equal(usage?.imageGenerationCalls, 0);
  assert.equal(usage?.hasFinalOutput, false);
});

test("recovers an output-limited terminal response with a delivered image", () => {
  const collector = new ResponsesSseUsageCollector();
  collector.push(encoder.encode(
    'data: {"type":"response.incomplete","response":{"id":"resp_9","output":[{"type":"image_generation_call","status":"generating","result":"aW1hZ2U="},{"type":"message","content":[{"type":"output_text","text":"Here is your"}]}],"usage":{"input_tokens":8,"output_tokens":753}}}\n\n',
  ));

  const usage = collector.finish();
  assert.equal(usage?.imageGenerationCalls, 1);
  assert.equal(usage?.hasFinalOutput, true);
  assert.equal(
    responsesUsageHasDeliveredResult(usage, usage?.terminalEvent ?? null),
    true,
  );
});

test("does not recover incomplete responses without a delivered image", () => {
  const collector = new ResponsesSseUsageCollector();
  collector.push(encoder.encode(
    'data: {"type":"response.incomplete","response":{"id":"resp_10","output":[{"type":"message","content":[{"type":"output_text","text":"Cut off"}]}],"usage":{"input_tokens":4,"output_tokens":800}}}\n\n',
  ));

  const usage = collector.finish();
  assert.equal(
    responsesUsageHasDeliveredResult(usage, usage?.terminalEvent ?? null),
    false,
  );
});
