#!/usr/bin/env node

import { readFile } from "node:fs/promises";
import { request as httpRequest } from "node:http";
import { request as httpsRequest } from "node:https";

const suiteUrl = new URL(
  "../supabase/functions/evals/gpt56-m1-v1/fixtures.json",
  import.meta.url,
);
const suite = JSON.parse(await readFile(suiteUrl, "utf8"));
const args = parseArgs(process.argv.slice(2));
const label = args.label ?? process.env.HOWAI_EVAL_LABEL;
const proxyBaseUrl = process.env.OPENAI_PROXY_BASE_URL?.replace(/\/+$/, "");
const accessToken = process.env.HOWAI_EVAL_ACCESS_TOKEN;
const publishableKey = process.env.SUPABASE_ANON_KEY;

if (!label) fail("Pass --label baseline or --label candidate.");
if (!proxyBaseUrl || !accessToken || !publishableKey) {
  fail(
    "Set OPENAI_PROXY_BASE_URL, HOWAI_EVAL_ACCESS_TOKEN, and SUPABASE_ANON_KEY. " +
      "The evaluator never reads or prints the OpenAI API key.",
  );
}

const selected = suite.fixtures.filter((fixture) => {
  if (fixture.execution !== "automated" && !args.includeManual) return false;
  if (args.fixture && fixture.id !== args.fixture) return false;
  return true;
});
if (selected.length === 0) fail("No fixtures matched the requested filters.");

const results = [];
for (const fixture of selected) {
  if (fixture.execution === "manual") {
    results.push({
      fixture_id: fixture.id,
      status: "manual_required",
      manual_checks: fixture.expectations.manual_checks ?? [],
    });
    continue;
  }

  const instructions = [suite.default_instructions, fixture.instructions_suffix]
    .filter(Boolean)
    .join("\n\n");
  const startedAt = Date.now();
  const response = await postJson(
    `${proxyBaseUrl}/v1/responses`,
    {
      Authorization: `Bearer ${accessToken}`,
      apikey: publishableKey,
      "Content-Type": "application/json",
    },
    {
      model: "howai-chat",
      instructions,
      input: fixture.prompt,
      max_output_tokens: fixture.max_output_tokens,
      metadata: {
        howai_intent: fixture.intent,
        howai_eval_version: suite.eval_version,
        howai_eval_fixture: fixture.id,
      },
      store: false,
      stream: false,
    },
  );
  const latencyMs = Date.now() - startedAt;
  const body = response.body;

  if (response.status < 200 || response.status >= 300) {
    results.push({
      fixture_id: fixture.id,
      status: "request_failed",
      http_status: response.status,
      latency_ms: latencyMs,
      error: safeError(body),
    });
    continue;
  }

  const text = extractOutputText(body);
  const functionCalls = Array.isArray(body.output)
    ? body.output.filter((item) => item?.type === "function_call")
    : [];
  const assertions = evaluateExpectations(
    fixture.expectations,
    text,
    functionCalls,
  );
  results.push({
    fixture_id: fixture.id,
    status: assertions.every((assertion) => assertion.passed) ? "passed" : "failed",
    model: body.model ?? null,
    response_id: body.id ?? null,
    latency_ms: latencyMs,
    usage: body.usage ?? null,
    assertions,
    output_excerpt: text.slice(0, 500),
    manual_checks: fixture.expectations.manual_checks ?? [],
  });
}

const summary = {
  eval_version: suite.eval_version,
  label,
  generated_at: new Date().toISOString(),
  totals: {
    fixtures: results.length,
    passed: results.filter((result) => result.status === "passed").length,
    failed: results.filter((result) =>
      result.status === "failed" || result.status === "request_failed"
    ).length,
    manual_required: results.filter((result) => result.status === "manual_required").length,
  },
  results,
};

process.stdout.write(`${JSON.stringify(summary, null, 2)}\n`);
process.exitCode = summary.totals.failed > 0 ? 1 : 0;

function parseArgs(argv) {
  const parsed = { label: null, fixture: null, includeManual: false };
  for (let index = 0; index < argv.length; index += 1) {
    if (argv[index] === "--label") parsed.label = argv[++index] ?? null;
    else if (argv[index] === "--fixture") parsed.fixture = argv[++index] ?? null;
    else if (argv[index] === "--include-manual") parsed.includeManual = true;
    else fail(`Unknown argument: ${argv[index]}`);
  }
  return parsed;
}

function evaluateExpectations(expectations, text, functionCalls) {
  const assertions = [];
  if (expectations.output_kind === "message") {
    assertions.push({ name: "message_output", passed: text.trim().length > 0 });
  }
  if (expectations.output_kind === "function_call") {
    assertions.push({ name: "function_call_output", passed: functionCalls.length > 0 });
  }
  if (expectations.function_name) {
    assertions.push({
      name: `function_${expectations.function_name}`,
      passed: functionCalls.some((call) => call.name === expectations.function_name),
    });
  }
  for (const pattern of expectations.required_patterns ?? []) {
    assertions.push({
      name: `required_${pattern}`,
      passed: new RegExp(pattern, "iu").test(text),
    });
  }
  for (const pattern of expectations.forbidden_patterns ?? []) {
    assertions.push({
      name: `forbidden_${pattern}`,
      passed: !new RegExp(pattern, "iu").test(text),
    });
  }
  if (expectations.max_words) {
    assertions.push({
      name: `max_words_${expectations.max_words}`,
      passed: text.trim().split(/\s+/u).filter(Boolean).length <= expectations.max_words,
    });
  }
  return assertions;
}

function extractOutputText(body) {
  if (!Array.isArray(body.output)) return "";
  return body.output
    .filter((item) => item?.type === "message")
    .flatMap((item) => Array.isArray(item.content) ? item.content : [])
    .filter((part) => part?.type === "output_text" || part?.type === "refusal")
    .map((part) => part.text ?? part.refusal ?? "")
    .join("\n");
}

function safeError(body) {
  const message = body?.error?.message ?? body?.error ?? "request failed";
  return String(message).slice(0, 300);
}

function postJson(url, headers, payload) {
  const target = new URL(url);
  const request = target.protocol === "https:" ? httpsRequest : httpRequest;
  const encoded = JSON.stringify(payload);

  return new Promise((resolve, reject) => {
    const req = request(
      target,
      {
        method: "POST",
        headers: {
          ...headers,
          "Content-Length": Buffer.byteLength(encoded),
        },
      },
      (res) => {
        const chunks = [];
        res.on("data", (chunk) => chunks.push(chunk));
        res.on("end", () => {
          const responseText = Buffer.concat(chunks).toString("utf8");
          let body = {};
          try {
            body = JSON.parse(responseText);
          } catch {
            body = { error: responseText.slice(0, 300) };
          }
          resolve({ status: res.statusCode ?? 0, body });
        });
      },
    );
    req.setTimeout(180_000, () => req.destroy(new Error("Evaluation request timed out.")));
    req.on("error", reject);
    req.end(encoded);
  });
}

function fail(message) {
  process.stderr.write(`${message}\n`);
  process.exit(2);
}
