import assert from "node:assert/strict";
import test from "node:test";

import { buildVerifiedAutomationReport } from "./automation-report.ts";

const SOURCE_ONE = "https://example.com/news/one";
const SOURCE_TWO = "https://primary.test/report/two";

test("builds a verified conversation message with visible sources", async () => {
  const payloads: Record<string, unknown>[] = [];
  const reconciled: Array<{ succeeded: boolean; requestId: string }> = [];
  let call = 0;
  const result = await buildVerifiedAutomationReport(baseInput(), {
    apiKey: "test-key",
    model: "gpt-5.6-sol",
    fetcher: async (_url, init) => {
      payloads.push(JSON.parse(String(init?.body)));
      call += 1;
      return jsonResponse(call === 1 ? generationResponse() : verificationResponse("pass"));
    },
    reserve: async (phase) => ({
      requestId: `request-${phase}`,
      ledgerId: `ledger-${phase}`,
    }),
    reconcile: async (value) => {
      reconciled.push({ succeeded: value.succeeded, requestId: value.requestId });
    },
  });

  assert.equal(result.status, "succeeded");
  assert.match(result.messageContent, /### Sources/);
  assert.match(result.messageContent, /\[Primary report\]\(https:\/\/primary\.test/);
  assert.equal(result.sources.length, 2);
  assert.equal(result.generationLedgerId, "ledger-generation");
  assert.equal(result.verificationLedgerId, "ledger-verification");
  assert.deepEqual(reconciled, [
    { succeeded: true, requestId: "request-generation" },
    { succeeded: true, requestId: "request-verification" },
  ]);
  assert.equal(payloads[0].tool_choice, "required");
  assert.deepEqual(payloads[0].include, ["web_search_call.action.sources"]);
  assert.equal(
    ((payloads[1].text as Record<string, unknown>).format as Record<string, unknown>).strict,
    true,
  );
});

test("withholds a briefing before verification when sources fail deterministic checks", async () => {
  let calls = 0;
  const response = generationResponse();
  const output = response.output as Record<string, unknown>[];
  const search = output[0].action as Record<string, unknown>;
  search.sources = [{ title: "Blocked", url: "https://blocked.test/item" }];
  const message = output[1];
  const content = message.content as Record<string, unknown>[];
  content[0].annotations = [{
    type: "url_citation",
    title: "Blocked",
    url: "https://blocked.test/item",
  }];

  const input = baseInput();
  const sourcePolicy = input.template.source_policy as Record<string, unknown>;
  sourcePolicy.excluded_domains = ["blocked.test"];
  const result = await buildVerifiedAutomationReport(input, {
    apiKey: "test-key",
    model: "gpt-5.6-sol",
    fetcher: async () => {
      calls += 1;
      return jsonResponse(response);
    },
  });

  assert.equal(calls, 1);
  assert.equal(result.status, "withheld");
  assert.deepEqual(result.verification.issues, [
    "insufficient_sources",
    "excluded_source_domain",
  ]);
  assert.doesNotMatch(result.messageContent, /blocked\.test/);
});

test("withholds a draft when the independent verifier rejects a claim", async () => {
  let call = 0;
  const result = await buildVerifiedAutomationReport(baseInput(), {
    apiKey: "test-key",
    model: "gpt-5.6-sol",
    fetcher: async () => {
      call += 1;
      return jsonResponse(call === 1 ? generationResponse() : verificationResponse("withhold"));
    },
  });
  assert.equal(result.status, "withheld");
  assert.match(String(result.verification.summary), /conflict/i);
});

function baseInput(): {
  runId: string;
  userId: string;
  scheduledFor: string;
  template: Record<string, unknown>;
} {
  return {
    runId: "run-1",
    userId: "user-1",
    scheduledFor: "2026-07-16T12:00:00.000Z",
    template: {
      kind: "news_briefing",
      title: "Morning technology briefing",
      config: {
        topics: ["AI", "robotics"],
        item_count: 3,
        region: "US",
        language: "auto",
        summary_style: "concise",
      },
      source_policy: {
        preferred_domains: [],
        excluded_domains: [],
        freshness_hours: 24,
        require_primary_sources: true,
      },
    },
  };
}

function generationResponse(): Record<string, unknown> {
  return {
    id: "resp-generation",
    model: "gpt-5.6-sol",
    output: [
      {
        type: "web_search_call",
        status: "completed",
        action: {
          sources: [
            { title: "News report", url: SOURCE_ONE },
            { title: "Primary report", url: SOURCE_TWO },
          ],
        },
      },
      {
        type: "message",
        content: [{
          type: "output_text",
          text: "### Today's briefing\n\nA significant and independently reported technology update happened today. The development matters because it changes how teams can use reliable automation in production.",
          annotations: [
            { type: "url_citation", title: "News report", url: SOURCE_ONE },
            { type: "url_citation", title: "Primary report", url: SOURCE_TWO },
          ],
        }],
      },
    ],
    usage: {
      input_tokens: 100,
      output_tokens: 80,
      input_tokens_details: { cached_tokens: 0 },
    },
  };
}

function verificationResponse(status: "pass" | "withhold"): Record<string, unknown> {
  return {
    id: "resp-verification",
    model: "gpt-5.6-sol",
    output: [
      { type: "web_search_call", status: "completed", action: { sources: [] } },
      {
        type: "message",
        content: [{
          type: "output_text",
          text: JSON.stringify({
            status,
            summary: status === "pass" ? "All material claims are supported." : "Sources conflict on a material claim.",
            preview: "Your verified morning technology briefing is ready.",
            issues: status === "pass" ? [] : ["Conflicting publication details"],
            claims: [{
              text: "A material technology update was reported today.",
              supported: status === "pass",
              source_urls: [SOURCE_ONE, SOURCE_TWO],
            }],
          }),
          annotations: [],
        }],
      },
    ],
    usage: {
      input_tokens: 220,
      output_tokens: 90,
      input_tokens_details: { cached_tokens: 0 },
    },
  };
}

function jsonResponse(body: Record<string, unknown>): Response {
  return new Response(JSON.stringify(body), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
}
