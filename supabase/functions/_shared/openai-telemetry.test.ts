import assert from "node:assert/strict";
import test from "node:test";

import {
  extractUpstreamErrorTelemetry,
  nonJsonUpstreamErrorTelemetry,
} from "./openai-telemetry.ts";

test("captures bounded upstream codes and parameter paths without the message", () => {
  const telemetry = extractUpstreamErrorTelemetry({
    error: {
      message: "Rejected prompt text that must never enter telemetry",
      type: "invalid_request_error",
      code: "unsupported_value",
      param: "input[0].content[0].type",
    },
  });

  assert.deepEqual(telemetry, {
    present: true,
    code: "unsupported_value",
    param: "input[0].content[0].type",
  });
  assert.equal("message" in telemetry, false);
});

test("drops unsafe upstream fields instead of persisting arbitrary text", () => {
  assert.deepEqual(
    extractUpstreamErrorTelemetry({
      error: {
        message: "private input",
        code: "bad value: private input",
        param: "input; select secret",
      },
    }),
    { present: true, code: null, param: null },
  );
});

test("classifies non-JSON upstream failures without retaining the body", () => {
  assert.deepEqual(nonJsonUpstreamErrorTelemetry(false), {
    present: true,
    code: "non_json_upstream_error",
    param: null,
  });
  assert.deepEqual(nonJsonUpstreamErrorTelemetry(true), {
    present: false,
    code: null,
    param: null,
  });
});
