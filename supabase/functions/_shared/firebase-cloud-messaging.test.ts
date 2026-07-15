import assert from "node:assert/strict";
import test from "node:test";

import {
  buildReminderMessage,
  classifyFcmError,
  parseServiceAccount,
  sendFcmMessage,
} from "./firebase-cloud-messaging.ts";

test("builds a cross-platform reminder message without notes", () => {
  const payload = buildReminderMessage({
    token: "device-token",
    reminderId: "reminder-id",
    deliveryId: "delivery-id",
    title: "Call Mom",
    scheduledFor: "2026-07-15T18:00:00.000Z",
  });
  const message = payload.message as Record<string, unknown>;
  assert.equal(message.token, "device-token");
  assert.deepEqual(message.notification, {
    title: "HowAI reminder",
    body: "Call Mom",
  });
  assert.equal((message.data as Record<string, unknown>).type, "reminder");
});

test("classifies unregistered tokens as permanent and invalid", () => {
  const result = classifyFcmError(404, {
    error: {
      status: "NOT_FOUND",
      message: "Requested entity was not found.",
      details: [{ errorCode: "UNREGISTERED" }],
    },
  });
  assert.equal(result.invalidToken, true);
  assert.equal(result.transient, false);
});

test("classifies quota and provider authentication failures for retry", () => {
  assert.equal(
    classifyFcmError(429, {
      error: { status: "RESOURCE_EXHAUSTED", details: [] },
    }).transient,
    true,
  );
  assert.equal(
    classifyFcmError(401, {
      error: {
        status: "UNAUTHENTICATED",
        details: [{ errorCode: "THIRD_PARTY_AUTH_ERROR" }],
      },
    }).transient,
    true,
  );
});

test("validates the service account fields without exposing the key", () => {
  const account = parseServiceAccount(JSON.stringify({
    project_id: "test-project",
    client_email: "sender@example.test",
    private_key: "private-key-value",
  }));
  assert.equal(account.project_id, "test-project");
  assert.equal(account.client_email, "sender@example.test");
  assert.throws(() => parseServiceAccount("{}"), /project_id/);
});

test("turns service-account authorization failures into retryable results", async () => {
  const result = await sendFcmMessage({
    project_id: "test-project",
    client_email: "sender@example.test",
    private_key: "not-a-valid-private-key",
  }, { message: {} });

  assert.equal(result.ok, false);
  assert.equal(result.errorCode, "AUTHORIZATION_ERROR");
  assert.equal(result.transient, true);
  assert.equal(result.invalidToken, false);
});
