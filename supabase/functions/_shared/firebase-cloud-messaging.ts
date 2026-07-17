export type FcmServiceAccount = Readonly<{
  project_id: string;
  client_email: string;
  private_key: string;
  token_uri?: string;
}>;

export type FcmSendResult = Readonly<{
  ok: boolean;
  messageId: string | null;
  errorCode: string | null;
  errorMessage: string | null;
  transient: boolean;
  invalidToken: boolean;
}>;

type CachedAccessToken = {
  token: string;
  expiresAtMs: number;
  clientEmail: string;
};

let cachedAccessToken: CachedAccessToken | null = null;

export function parseServiceAccount(value: string): FcmServiceAccount {
  let parsed: unknown;
  try {
    parsed = JSON.parse(value);
  } catch {
    throw new Error("FIREBASE_SERVICE_ACCOUNT_JSON must contain valid JSON.");
  }
  if (!isRecord(parsed)) {
    throw new Error("Firebase service account must be a JSON object.");
  }
  const projectId = requiredString(parsed.project_id, "project_id");
  const clientEmail = requiredString(parsed.client_email, "client_email");
  const privateKey = requiredString(parsed.private_key, "private_key");
  const tokenUri = parsed.token_uri == null
    ? undefined
    : requiredString(parsed.token_uri, "token_uri");
  return {
    project_id: projectId,
    client_email: clientEmail,
    private_key: privateKey,
    token_uri: tokenUri,
  };
}

export function buildReminderMessage(input: {
  token: string;
  reminderId: string;
  deliveryId: string;
  title: string;
  scheduledFor: string;
}): Record<string, unknown> {
  return {
    message: {
      token: input.token,
      notification: {
        title: "HowAI reminder",
        body: input.title,
      },
      data: {
        type: "reminder",
        reminder_id: input.reminderId,
        delivery_id: input.deliveryId,
        scheduled_for: input.scheduledFor,
      },
      android: {
        priority: "high",
        ttl: "86400s",
        notification: {
          channel_id: "howai_reminders",
          sound: "default",
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
      },
      apns: {
        headers: {
          "apns-priority": "10",
          "apns-expiration": String(
            Math.floor(Date.parse(input.scheduledFor) / 1000) + 86_400,
          ),
          "apns-collapse-id": `reminder-${input.reminderId}`,
        },
        payload: {
          aps: {
            sound: "default",
            category: "HOWAI_REMINDER",
          },
        },
      },
    },
  };
}

export function buildAutomationMessage(input: {
  token: string;
  automationRunId: string;
  deliveryId: string;
  conversationId: string;
  messageId: string;
  title: string;
  preview: string;
}): Record<string, unknown> {
  return {
    message: {
      token: input.token,
      notification: {
        title: `HowAI · ${input.title}`.slice(0, 200),
        body: input.preview.slice(0, 500),
      },
      data: {
        type: "automation",
        automation_run_id: input.automationRunId,
        delivery_id: input.deliveryId,
        conversation_id: input.conversationId,
        message_id: input.messageId,
      },
      android: {
        priority: "high",
        ttl: "86400s",
        notification: {
          channel_id: "howai_automations",
          sound: "default",
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
      },
      apns: {
        headers: {
          "apns-priority": "10",
          "apns-expiration": String(Math.floor(Date.now() / 1000) + 86_400),
          "apns-collapse-id": `automation-${input.automationRunId}`,
        },
        payload: {
          aps: {
            sound: "default",
            category: "HOWAI_AUTOMATION",
            "thread-id": input.conversationId,
          },
        },
      },
    },
  };
}

export async function sendFcmMessage(
  serviceAccount: FcmServiceAccount,
  payload: Record<string, unknown>,
  fetcher: typeof fetch = fetch,
): Promise<FcmSendResult> {
  let accessToken: string;
  try {
    accessToken = await getAccessToken(serviceAccount, fetcher);
  } catch (error) {
    return {
      ok: false,
      messageId: null,
      errorCode: "AUTHORIZATION_ERROR",
      errorMessage: safeMessage(error),
      transient: true,
      invalidToken: false,
    };
  }
  let response: Response;
  try {
    response = await fetcher(
      `https://fcm.googleapis.com/v1/projects/${
        encodeURIComponent(serviceAccount.project_id)
      }/messages:send`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json; charset=utf-8",
        },
        body: JSON.stringify(payload),
      },
    );
  } catch (error) {
    return {
      ok: false,
      messageId: null,
      errorCode: "NETWORK_ERROR",
      errorMessage: safeMessage(error),
      transient: true,
      invalidToken: false,
    };
  }

  const body = await readJson(response);
  if (response.ok) {
    return {
      ok: true,
      messageId: isRecord(body) && typeof body.name === "string"
        ? body.name
        : null,
      errorCode: null,
      errorMessage: null,
      transient: false,
      invalidToken: false,
    };
  }

  return classifyFcmError(response.status, body);
}

export function classifyFcmError(
  httpStatus: number,
  body: unknown,
): FcmSendResult {
  const error = isRecord(body) && isRecord(body.error) ? body.error : {};
  const details = Array.isArray(error.details) ? error.details : [];
  const detailCode = details
    .filter(isRecord)
    .map((item) => item.errorCode)
    .find((value): value is string => typeof value === "string");
  const statusCode = typeof error.status === "string" ? error.status : null;
  const code = detailCode ?? statusCode ?? `HTTP_${httpStatus}`;
  const invalidToken = code === "UNREGISTERED";
  const transientCodes = new Set([
    "INTERNAL",
    "UNAVAILABLE",
    "QUOTA_EXCEEDED",
    "THIRD_PARTY_AUTH_ERROR",
    "NETWORK_ERROR",
  ]);
  return {
    ok: false,
    messageId: null,
    errorCode: code,
    errorMessage: typeof error.message === "string"
      ? error.message.slice(0, 500)
      : `FCM request failed with HTTP ${httpStatus}.`,
    transient: !invalidToken &&
      (httpStatus === 408 || httpStatus === 429 || httpStatus >= 500 ||
        transientCodes.has(code)),
    invalidToken,
  };
}

async function getAccessToken(
  serviceAccount: FcmServiceAccount,
  fetcher: typeof fetch,
): Promise<string> {
  const now = Date.now();
  if (
    cachedAccessToken &&
    cachedAccessToken.clientEmail === serviceAccount.client_email &&
    cachedAccessToken.expiresAtMs > now + 60_000
  ) {
    return cachedAccessToken.token;
  }

  const issuedAt = Math.floor(now / 1000);
  const header = base64UrlJson({ alg: "RS256", typ: "JWT" });
  const claims = base64UrlJson({
    iss: serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: serviceAccount.token_uri ?? "https://oauth2.googleapis.com/token",
    iat: issuedAt,
    exp: issuedAt + 3600,
  });
  const unsignedJwt = `${header}.${claims}`;
  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToArrayBuffer(serviceAccount.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsignedJwt),
  );
  const assertion = `${unsignedJwt}.${
    base64UrlBytes(new Uint8Array(signature))
  }`;

  const response = await fetcher(
    serviceAccount.token_uri ?? "https://oauth2.googleapis.com/token",
    {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({
        grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
        assertion,
      }),
    },
  );
  const body = await readJson(response);
  if (
    !response.ok || !isRecord(body) || typeof body.access_token !== "string"
  ) {
    throw new Error("Unable to authorize the Firebase service account.");
  }
  const expiresIn = typeof body.expires_in === "number"
    ? body.expires_in
    : 3600;
  cachedAccessToken = {
    token: body.access_token,
    expiresAtMs: now + expiresIn * 1000,
    clientEmail: serviceAccount.client_email,
  };
  return body.access_token;
}

function pemToArrayBuffer(pem: string): ArrayBuffer {
  const base64 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/g, "")
    .replace(/-----END PRIVATE KEY-----/g, "")
    .replace(/\s+/g, "");
  if (!base64) throw new Error("Firebase private key is empty.");
  const binary = atob(base64);
  return Uint8Array.from(
    binary,
    (character) => character.charCodeAt(0),
  ).buffer;
}

function base64UrlJson(value: Record<string, unknown>): string {
  return base64UrlBytes(new TextEncoder().encode(JSON.stringify(value)));
}

function base64UrlBytes(value: Uint8Array): string {
  let binary = "";
  for (const byte of value) binary += String.fromCharCode(byte);
  return btoa(binary)
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");
}

async function readJson(response: Response): Promise<unknown> {
  try {
    return await response.json();
  } catch {
    return null;
  }
}

function requiredString(value: unknown, field: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error(`Firebase service account ${field} is required.`);
  }
  return value;
}

function safeMessage(error: unknown): string {
  return error instanceof Error ? error.message.slice(0, 500) : "Network error";
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return !!value && typeof value === "object" && !Array.isArray(value);
}
