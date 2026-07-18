export type ResponseProfile = "quick" | "standard" | "research";
export type WebSearchMode = "auto" | "force" | "disabled";
export type ReasoningEffort = "minimal" | "none" | "low" | "medium" | "high";

export type AppliedResponseProfile = Readonly<{
  profile: ResponseProfile;
  webSearchMode: WebSearchMode;
  reasoningEffort: ReasoningEffort;
  maxOutputTokens: number;
}>;

export type ResponseProfileOptions = Readonly<{
  allowReasoningOverride?: boolean;
  requiredFunctionName?: string | null;
}>;

const WEB_SEARCH_OUTPUT_GUIDANCE = `<web_search_output_guidance>
When web search is used, keep every inline citation immediately after the claim it supports. Do not add a separate Sources or References section because the client renders the inline citations. If the user requests an exact number of items, provide exactly that many complete items and verify the count before finishing. If fewer verified items exist, state the smaller verified count instead of claiming the requested count.
</web_search_output_guidance>`;

const PROFILE_MAX_OUTPUT_TOKENS: Readonly<Record<ResponseProfile, number>> =
  Object.freeze({
    quick: 800,
    standard: 1_200,
    research: 3_000,
  });
const PRIMARY_CHAT_MIN_OUTPUT_TOKENS = 800;
const IMAGE_CAPABLE_CHAT_MIN_OUTPUT_TOKENS = 1_200;

/**
 * Applies HowAI's latency and cost controls after model/tool entitlements have
 * been resolved. Client metadata is treated only as a request for a stricter
 * profile; this function always clamps output and controls tool choice.
 */
export function applyResponseProfile(
  payload: Record<string, unknown>,
  resolvedModel: string,
  options: ResponseProfileOptions = {},
): AppliedResponseProfile {
  const metadata = payload.metadata && typeof payload.metadata === "object"
    ? payload.metadata as Record<string, unknown>
    : {};
  const requestedProfile = metadata.howai_response_profile;
  const isResearch = metadata.howai_intent === "research" ||
    requestedProfile === "research";
  const requestedForcedSearch = metadata.howai_web_search === "force";
  const requestedReasoningEffort = options.allowReasoningOverride
    ? paidReasoningEffort(metadata.howai_reasoning_effort)
    : null;

  let profile: ResponseProfile = isResearch
    ? "research"
    : requestedProfile === "quick"
    ? "quick"
    : "standard";

  // Web search requires a reasoning-capable profile. A user's explicit search
  // request must never be downgraded to the minimal/none quick path.
  if (requestedForcedSearch && profile === "quick") profile = "standard";
  // Explicit paid reasoning also needs the standard token and verbosity
  // profile, even when the message itself looks like quick small talk.
  if (requestedReasoningEffort && profile === "quick") profile = "standard";

  const tools = Array.isArray(payload.tools)
    ? payload.tools.filter((tool) =>
      tool && typeof tool === "object"
    ) as Record<string, unknown>[]
    : [];
  const nonSearchTools = tools.filter((tool) => !isWebSearchTool(tool));
  const hasWebSearch = tools.some(isWebSearchTool);
  const hasImageGeneration = tools.some((tool) =>
    tool.type === "image_generation"
  );
  const requiredFunctionTool = options.requiredFunctionName
    ? tools.find((tool) =>
      tool.type === "function" && tool.name === options.requiredFunctionName
    )
    : undefined;
  let webSearchMode: WebSearchMode = hasWebSearch ? "auto" : "disabled";

  // Action proposals are safe to force because the function only creates a
  // reviewable draft. Keep this server-authorized and expose exactly one tool.
  if (requiredFunctionTool && profile === "quick") profile = "standard";

  if (requiredFunctionTool) {
    payload.tools = [requiredFunctionTool];
    payload.tool_choice = "required";
    webSearchMode = "disabled";
  } else if (profile === "quick") {
    payload.tools = nonSearchTools;
    delete payload.tool_choice;
    webSearchMode = "disabled";
  } else if (requestedForcedSearch && hasWebSearch) {
    // `required` guarantees a call because search is the only exposed tool.
    // This avoids relying on a model-specific hosted-tool choice shape.
    payload.tools = [normalizedWebSearchTool()];
    payload.tool_choice = "required";
    webSearchMode = "force";
  } else if (hasWebSearch) {
    payload.tools = [
      ...nonSearchTools,
      normalizedWebSearchTool(),
    ];
    payload.tool_choice = "auto";
  }

  if (Array.isArray(payload.tools) && payload.tools.length === 0) {
    delete payload.tools;
    delete payload.tool_choice;
  } else if (
    !requiredFunctionTool && webSearchMode !== "force" && !hasWebSearch
  ) {
    // Never trust a client-supplied required choice after its requested tool
    // has been removed by entitlement or profile controls.
    delete payload.tool_choice;
  }

  // Image-capable quick turns still use low verbosity and low reasoning, but
  // the hosted tool can consume enough reasoning/output budget to leave its
  // short trailing caption incomplete. Give these turns the standard token
  // ceiling without upgrading the whole response profile.
  const maxOutputTokens = hasImageGeneration && profile === "quick"
    ? IMAGE_CAPABLE_CHAT_MIN_OUTPUT_TOKENS
    : PROFILE_MAX_OUTPUT_TOKENS[profile];
  const requestedMax = typeof payload.max_output_tokens === "number"
    ? payload.max_output_tokens
    : maxOutputTokens;
  const cappedRequestedMax = Math.min(requestedMax, maxOutputTokens);
  // max_output_tokens includes hidden reasoning as well as visible text. Older
  // clients requested 400 tokens for some primary-chat turns, which allowed a
  // reasoning model to terminate in the middle of the user-visible sentence.
  // Keep lightweight/title calls strict, but give every real chat enough room
  // to finish even when a stale client requests the old cap.
  const primaryChatMinimum = hasImageGeneration
    ? IMAGE_CAPABLE_CHAT_MIN_OUTPUT_TOKENS
    : PRIMARY_CHAT_MIN_OUTPUT_TOKENS;
  payload.max_output_tokens = metadata.howai_intent === "primary_chat"
    ? Math.max(
      cappedRequestedMax,
      Math.min(primaryChatMinimum, maxOutputTokens),
    )
    : cappedRequestedMax;

  const reasoningEffort = requestedReasoningEffort ??
    reasoningFor(profile, resolvedModel, hasImageGeneration);
  payload.reasoning = { effort: reasoningEffort };

  const text = payload.text && typeof payload.text === "object"
    ? { ...(payload.text as Record<string, unknown>) }
    : {};
  text.verbosity = profile === "quick"
    ? "low"
    : profile === "research"
    ? "high"
    : "medium";
  payload.text = text;

  return {
    profile,
    webSearchMode,
    reasoningEffort,
    maxOutputTokens: payload.max_output_tokens as number,
  };
}

/**
 * Replaces any client-supplied copy with the server-owned search guidance.
 * The block is removed again if search is stripped by policy or quota.
 */
export function applyWebSearchOutputGuidance(
  payload: Record<string, unknown>,
  mode: WebSearchMode,
): void {
  const current = typeof payload.instructions === "string"
    ? payload.instructions
    : "";
  const withoutGuidance = current.replace(
    /\n*<web_search_output_guidance>[\s\S]*?<\/web_search_output_guidance>\n*/g,
    "\n",
  ).trim();

  if (mode === "disabled") {
    if (withoutGuidance) payload.instructions = withoutGuidance;
    else delete payload.instructions;
    return;
  }

  payload.instructions = withoutGuidance
    ? `${withoutGuidance}\n\n${WEB_SEARCH_OUTPUT_GUIDANCE}`
    : WEB_SEARCH_OUTPUT_GUIDANCE;
}

function isWebSearchTool(tool: Record<string, unknown>): boolean {
  return tool.type === "web_search" || tool.type === "web_search_preview";
}

function normalizedWebSearchTool(): Record<string, unknown> {
  return {
    type: "web_search",
    search_context_size: "low",
  };
}

function reasoningFor(
  profile: ResponseProfile,
  model: string,
  hasImageGeneration: boolean,
): ReasoningEffort {
  if (profile === "research") return "high";
  if (profile === "standard") return "low";
  // GPT-5 Nano rejects the hosted image-generation tool at minimal effort.
  // Keep the low-verbosity quick profile, but use the lowest supported effort
  // whenever the model is being allowed to decide whether to draw.
  if (hasImageGeneration) return "low";

  const normalizedModel = model.toLowerCase();
  if (normalizedModel.includes("gpt-5-nano")) return "minimal";
  if (normalizedModel.includes("gpt-5.6")) return "none";
  return "low";
}

function paidReasoningEffort(value: unknown): "low" | "medium" | "high" | null {
  return value === "low" || value === "medium" || value === "high"
    ? value
    : null;
}
