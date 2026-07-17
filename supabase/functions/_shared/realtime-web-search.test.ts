import {
  assert,
  assertEquals,
} from "https://deno.land/std@0.224.0/assert/mod.ts";

import {
  buildRealtimeWebSearchTools,
  REALTIME_WEB_SEARCH_TOOL_NAME,
} from "./realtime-web-search.ts";

Deno.test("voice search is exposed as a narrow read-only function", () => {
  const tools = buildRealtimeWebSearchTools(true);
  assertEquals(tools.length, 1);
  assertEquals(tools[0].name, REALTIME_WEB_SEARCH_TOOL_NAME);
  assertEquals(tools[0].type, "function");

  const parameters = tools[0].parameters as Record<string, unknown>;
  assertEquals(parameters.additionalProperties, false);
  assertEquals(parameters.required, ["query"]);
  assert(JSON.stringify(tools[0]).includes("live web"));
});

Deno.test("voice search is omitted for ineligible sessions", () => {
  assertEquals(buildRealtimeWebSearchTools(false), []);
});
