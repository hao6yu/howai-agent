import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const fixtureUrl = new URL("../evals/gpt56-m1-v1/fixtures.json", import.meta.url);

test("GPT-5.6 M1 fixtures are versioned, synthetic, and structurally valid", async () => {
  const suite = JSON.parse(
    await readFile(decodeURIComponent(fixtureUrl.pathname), "utf8"),
  ) as Record<string, unknown>;

  assert.equal(suite.schema_version, 1);
  assert.equal(suite.eval_version, "gpt56-m1-v1");
  assert.equal(suite.privacy, "synthetic_only");
  assert.equal(typeof suite.default_instructions, "string");
  assert.ok(String(suite.default_instructions).length > 20);

  const fixtures = suite.fixtures as Array<Record<string, unknown>>;
  assert.ok(Array.isArray(fixtures));
  assert.ok(fixtures.length >= 10);

  const ids = new Set<string>();
  const categories = new Set<string>();
  for (const fixture of fixtures) {
    assert.match(String(fixture.id), /^[a-z0-9]+(?:-[a-z0-9]+)*-\d{3}$/);
    assert.equal(ids.has(String(fixture.id)), false, `duplicate fixture ${fixture.id}`);
    ids.add(String(fixture.id));
    categories.add(String(fixture.category));
    assert.ok(fixture.execution === "automated" || fixture.execution === "manual");
    assert.ok(["primary_chat", "lightweight", "title", "research"].includes(String(fixture.intent)));
    assert.ok(String(fixture.prompt).length > 10);
    assert.ok(Number.isInteger(fixture.max_output_tokens));
    assert.ok(Number(fixture.max_output_tokens) >= 1 && Number(fixture.max_output_tokens) <= 3_000);
    assert.equal(typeof fixture.expectations, "object");
  }

  for (const required of [
    "casual_conversation",
    "multilingual",
    "privacy",
    "reminder_approval",
    "research_routing",
    "safety",
    "web_search",
    "function_calling",
    "multi_turn",
    "image_file_input",
  ]) {
    assert.equal(categories.has(required), true, `missing ${required} coverage`);
  }
});
