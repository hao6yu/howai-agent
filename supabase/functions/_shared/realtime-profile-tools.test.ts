import {
  assertEquals,
  assertStringIncludes,
} from "https://deno.land/std@0.224.0/assert/mod.ts";

import {
  buildRealtimeProfileTools,
  REALTIME_PROFILE_NAME_TOOL_NAME,
} from "./realtime-profile-tools.ts";

Deno.test("voice preferred-name tool is unavailable to anonymous sessions", () => {
  assertEquals(buildRealtimeProfileTools(false), []);
});

Deno.test("voice preferred-name tool accepts only explicit set or decline", () => {
  const tools = buildRealtimeProfileTools(true);
  assertEquals(tools.length, 1);
  assertEquals(tools[0].name, REALTIME_PROFILE_NAME_TOOL_NAME);
  assertEquals(tools[0].strict, true);

  const parameters = tools[0].parameters as Record<string, unknown>;
  const properties = parameters.properties as Record<string, unknown>;
  const action = properties.action as Record<string, unknown>;
  assertEquals(action.enum, ["set", "decline"]);
  assertEquals(parameters.required, ["action", "display_name"]);
  assertEquals(parameters.additionalProperties, false);
  assertStringIncludes(
    String(tools[0].description),
    "Never infer a name",
  );
});
