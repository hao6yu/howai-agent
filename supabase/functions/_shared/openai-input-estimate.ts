const APPROXIMATE_UTF8_BYTES_PER_TOKEN = 4;
const LOW_DETAIL_IMAGE_TOKENS = 256;
const HIGH_DETAIL_IMAGE_TOKENS = 2_500;
const ORIGINAL_DETAIL_IMAGE_TOKENS = 10_000;
const INLINE_FILE_TOKENS = 20_000;

/**
 * Estimates model-visible input instead of pricing the raw JSON transport.
 *
 * Base64 is a transport encoding, not text presented to the model. Images and
 * files are therefore replaced with small markers and charged separately
 * using conservative token allowances. The proxy's independent byte limit
 * still protects the Edge Function from oversized request bodies.
 */
export function estimateResponsesInputTokens(
  payload: Record<string, unknown>,
): number {
  let attachmentTokens = 0;

  const sanitize = (value: unknown): unknown => {
    if (Array.isArray(value)) return value.map(sanitize);
    if (!value || typeof value !== "object") return value;

    const record = value as Record<string, unknown>;
    const type = record.type;
    if (type === "input_image") {
      attachmentTokens += imageTokenAllowance(record.detail);
    } else if (type === "input_file") {
      attachmentTokens += INLINE_FILE_TOKENS;
    }

    return Object.fromEntries(
      Object.entries(record).map(([key, nestedValue]) => {
        if (
          type === "input_image" &&
          key === "image_url" &&
          isInlineDataUrl(nestedValue)
        ) {
          return [key, "[inline-image]"];
        }
        if (
          type === "input_file" &&
          key === "file_data" &&
          isInlineDataUrl(nestedValue)
        ) {
          return [key, "[inline-file]"];
        }
        return [key, sanitize(nestedValue)];
      }),
    );
  };

  const modelVisiblePayload = sanitize(payload);
  const transportIndependentBytes = new TextEncoder().encode(
    JSON.stringify(modelVisiblePayload),
  ).byteLength;
  return Math.ceil(
    transportIndependentBytes / APPROXIMATE_UTF8_BYTES_PER_TOKEN +
      attachmentTokens,
  );
}

function imageTokenAllowance(detail: unknown): number {
  if (detail === "low") return LOW_DETAIL_IMAGE_TOKENS;
  if (detail === "high") return HIGH_DETAIL_IMAGE_TOKENS;
  // GPT-5.6 treats omitted/auto detail like original and does not resize to a
  // finite patch budget. Reserve more for older clients that omit `detail`.
  return ORIGINAL_DETAIL_IMAGE_TOKENS;
}

function isInlineDataUrl(value: unknown): boolean {
  return typeof value === "string" &&
    /^data:[^,]*;base64,/i.test(value);
}
