export type UpstreamErrorTelemetry = Readonly<{
  present: boolean;
  code: string | null;
  param: string | null;
}>;

const SAFE_CODE = /^[A-Za-z0-9_.:-]+$/;
const SAFE_PARAM = /^[A-Za-z0-9_.\[\]-]+$/;

export function extractUpstreamErrorTelemetry(
  response: Record<string, unknown>,
): UpstreamErrorTelemetry {
  const candidate = response.error;
  if (!candidate || typeof candidate !== "object") {
    return { present: false, code: null, param: null };
  }

  const error = candidate as Record<string, unknown>;
  return {
    present: true,
    code: safeValue(error.code, SAFE_CODE, 80) ??
      safeValue(error.type, SAFE_CODE, 80),
    param: safeValue(error.param, SAFE_PARAM, 160),
  };
}

export function nonJsonUpstreamErrorTelemetry(
  upstreamOk: boolean,
): UpstreamErrorTelemetry {
  return upstreamOk
    ? { present: false, code: null, param: null }
    : { present: true, code: "non_json_upstream_error", param: null };
}

function safeValue(
  value: unknown,
  pattern: RegExp,
  maxLength: number,
): string | null {
  if (
    typeof value !== "string" || value.length === 0 || value.length > maxLength
  ) return null;
  return pattern.test(value) ? value : null;
}
