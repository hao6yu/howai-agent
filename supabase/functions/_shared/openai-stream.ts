export type ResponsesUsage = Readonly<{
  responseId: string | null;
  model: string | null;
  inputTokens: number | null;
  cachedInputTokens: number | null;
  outputTokens: number | null;
  totalTokens: number | null;
  hasFinalOutput: boolean;
  webSearchCalls: number;
  imageGenerationCalls: number;
  hasWebSearchCitations: boolean;
  terminalEvent?:
    | "response.completed"
    | "response.failed"
    | "response.incomplete";
}>;

export class ResponsesSseUsageCollector {
  #decoder = new TextDecoder();
  #buffer = "";
  #completedUsage: ResponsesUsage | null = null;
  #sawVisibleOutputDelta = false;

  get sawVisibleOutputDelta(): boolean {
    return this.#sawVisibleOutputDelta;
  }

  push(chunk: Uint8Array): ResponsesUsage | null {
    this.#buffer += this.#decoder.decode(chunk, { stream: true });
    this.#drainCompleteEvents();
    return this.#completedUsage;
  }

  finish(): ResponsesUsage | null {
    this.#buffer += this.#decoder.decode();
    this.#drainCompleteEvents();
    if (this.#buffer.trim()) {
      this.#inspectEvent(this.#buffer);
      this.#buffer = "";
    }
    return this.#completedUsage;
  }

  #drainCompleteEvents(): void {
    let boundary = this.#buffer.search(/\r?\n\r?\n/);
    while (boundary >= 0) {
      const event = this.#buffer.slice(0, boundary);
      const match = this.#buffer.slice(boundary).match(/^\r?\n\r?\n/);
      this.#buffer = this.#buffer.slice(boundary + (match?.[0].length ?? 2));
      this.#inspectEvent(event);
      boundary = this.#buffer.search(/\r?\n\r?\n/);
    }
  }

  #inspectEvent(event: string): void {
    const data = event
      .split(/\r?\n/)
      .filter((line) => line.startsWith("data:"))
      .map((line) => line.slice(5).trimStart())
      .join("\n");

    if (!data || data === "[DONE]") return;

    try {
      const parsed = JSON.parse(data) as Record<string, unknown>;
      if (
        (parsed.type === "response.output_text.delta" ||
          parsed.type === "response.refusal.delta") &&
        typeof parsed.delta === "string" &&
        parsed.delta.length > 0
      ) {
        this.#sawVisibleOutputDelta = true;
      }
      if (
        parsed.type !== "response.completed" &&
        parsed.type !== "response.failed" &&
        parsed.type !== "response.incomplete"
      ) return;

      const response = parsed.response && typeof parsed.response === "object"
        ? parsed.response as Record<string, unknown>
        : null;
      if (response) {
        this.#completedUsage = extractResponsesUsage(
          response,
          parsed.type,
        );
      }
    } catch {
      // The upstream stream remains authoritative; malformed telemetry events
      // must never alter or interrupt bytes sent to the client.
    }
  }
}

export function extractResponsesUsage(
  response: Record<string, unknown>,
  terminalEvent?:
    | "response.completed"
    | "response.failed"
    | "response.incomplete",
): ResponsesUsage {
  const usage = response.usage && typeof response.usage === "object"
    ? response.usage as Record<string, unknown>
    : {};
  const inputDetails = usage.input_tokens_details &&
      typeof usage.input_tokens_details === "object"
    ? usage.input_tokens_details as Record<string, unknown>
    : {};

  const inputTokens = numberOrNull(usage.input_tokens ?? usage.prompt_tokens);
  const outputTokens = numberOrNull(
    usage.output_tokens ?? usage.completion_tokens,
  );
  const totalTokens = numberOrNull(usage.total_tokens) ??
    (inputTokens != null && outputTokens != null
      ? inputTokens + outputTokens
      : null);

  return {
    responseId: typeof response.id === "string" ? response.id : null,
    model: typeof response.model === "string" ? response.model : null,
    inputTokens,
    cachedInputTokens: numberOrNull(inputDetails.cached_tokens),
    outputTokens,
    totalTokens,
    hasFinalOutput: responseHasFinalOutput(response.output),
    webSearchCalls: completedWebSearchCallCount(response.output),
    imageGenerationCalls: completedImageGenerationCallCount(response.output),
    hasWebSearchCitations: responseHasWebSearchCitations(response.output),
    ...(terminalEvent ? { terminalEvent } : {}),
  };
}

/**
 * Treat a terminal response as delivered when it completed normally, or when
 * an output-limited response already contains a finished image result. In the
 * latter case only the optional trailing prose is incomplete.
 */
export function responsesUsageHasDeliveredResult(
  usage: ResponsesUsage | null,
  status: string | null | undefined,
): boolean {
  if (!usage || !status) return false;
  const normalizedStatus = status.startsWith("response.")
    ? status.slice("response.".length)
    : status;
  return normalizedStatus === "completed" ||
    (normalizedStatus === "incomplete" && usage.imageGenerationCalls > 0);
}

function completedWebSearchCallCount(output: unknown): number {
  if (!Array.isArray(output)) return 0;
  return output.reduce((count, item) => {
    if (!item || typeof item !== "object") return count;
    const record = item as Record<string, unknown>;
    return record.type === "web_search_call" && record.status === "completed"
      ? count + 1
      : count;
  }, 0);
}

function completedImageGenerationCallCount(output: unknown): number {
  if (!Array.isArray(output)) return 0;
  return output.reduce((count, item) => {
    if (!item || typeof item !== "object") return count;
    const record = item as Record<string, unknown>;
    // The Responses API can include the complete base64 result in the
    // terminal response while the image-call status still reads "generating".
    // A delivered nonempty result is the authoritative billable signal.
    return record.type === "image_generation_call" &&
        typeof record.result === "string" &&
        record.result.length > 0
      ? count + 1
      : count;
  }, 0);
}

function responseHasWebSearchCitations(output: unknown): boolean {
  if (!Array.isArray(output)) return false;
  return output.some((item) => {
    if (!item || typeof item !== "object") return false;
    const record = item as Record<string, unknown>;
    if (record.type !== "message" || !Array.isArray(record.content)) {
      return false;
    }
    return record.content.some((content) => {
      if (!content || typeof content !== "object") return false;
      const annotations = (content as Record<string, unknown>).annotations;
      return Array.isArray(annotations) &&
        annotations.some((annotation) =>
          annotation && typeof annotation === "object" &&
          (annotation as Record<string, unknown>).type === "url_citation"
        );
    });
  });
}

function responseHasFinalOutput(output: unknown): boolean {
  if (!Array.isArray(output)) return false;
  if (completedImageGenerationCallCount(output) > 0) return true;
  return output.some((item) => {
    if (!item || typeof item !== "object") return false;
    const record = item as Record<string, unknown>;
    if (record.type !== "message" || !Array.isArray(record.content)) {
      return false;
    }
    return record.content.some((content) => {
      if (!content || typeof content !== "object") return false;
      const part = content as Record<string, unknown>;
      return (part.type === "output_text" &&
        typeof part.text === "string" && part.text.length > 0) ||
        (part.type === "refusal" &&
          typeof part.refusal === "string" && part.refusal.length > 0);
    });
  });
}

function numberOrNull(value: unknown): number | null {
  return typeof value === "number" && Number.isFinite(value) ? value : null;
}
