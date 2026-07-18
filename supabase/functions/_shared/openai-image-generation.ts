import type { RequestIntent, UserCohort } from "./openai-policy.ts";

export const DEFAULT_TRIAL_IMAGE_RESERVATION_MICROUSD = 10_000;
export const TRIAL_IMAGE_WEEK_SECONDS = 7 * 24 * 60 * 60;
const TRIAL_IMAGE_AVAILABILITY_TAG = "image_generation_availability";

type TrialImageEligibility = Readonly<{
  masterEnabled: boolean;
  anonymousEnabled: boolean;
  freeEnabled: boolean;
  cohort: UserCohort;
  intent: RequestIntent;
}>;

export function trialImageWeeklyQuota(
  cohort: Extract<UserCohort, "anonymous" | "free">,
  anonymousLimit: number,
  freeLimit: number,
): Readonly<{ userLimit: number; windowSeconds: number }> {
  return {
    userLimit: cohort === "anonymous" ? anonymousLimit : freeLimit,
    windowSeconds: TRIAL_IMAGE_WEEK_SECONDS,
  };
}

export function shouldOfferTrialImageGeneration(
  eligibility: TrialImageEligibility,
): boolean {
  if (!eligibility.masterEnabled || eligibility.intent !== "primary_chat") {
    return false;
  }
  if (eligibility.cohort === "anonymous") {
    return eligibility.anonymousEnabled;
  }
  if (eligibility.cohort === "free") {
    return eligibility.freeEnabled;
  }
  return false;
}

export function hasImageGenerationTool(tools: unknown): boolean {
  return Array.isArray(tools) &&
    tools.some((tool) =>
      tool && typeof tool === "object" &&
      (tool as Record<string, unknown>).type === "image_generation"
    );
}

/**
 * Free trials always use one low-quality square image. The proxy owns these
 * cost controls; client-supplied quality and size values are not trusted.
 */
export function constrainTrialImageGenerationTools(
  tools: unknown,
): unknown {
  if (!Array.isArray(tools)) return tools;
  return tools.map((tool) => {
    if (
      !tool || typeof tool !== "object" ||
      (tool as Record<string, unknown>).type !== "image_generation"
    ) {
      return tool;
    }
    return {
      type: "image_generation",
      quality: "low",
      size: "1024x1024",
    };
  });
}

export function removeImageGenerationTools(
  payload: Record<string, unknown>,
): void {
  if (!Array.isArray(payload.tools)) return;
  const remainingTools = payload.tools.filter((tool) =>
    !tool || typeof tool !== "object" ||
    (tool as Record<string, unknown>).type !== "image_generation"
  );
  payload.tools = remainingTools;
  delete payload.max_tool_calls;
  if (remainingTools.length === 0) {
    delete payload.tools;
    delete payload.tool_choice;
  }
}

export function imageGenerationToolCostMicrousd(
  completedCalls: number,
  perCallMicrousd = DEFAULT_TRIAL_IMAGE_RESERVATION_MICROUSD,
): number {
  const calls = Number.isFinite(completedCalls)
    ? Math.max(0, Math.floor(completedCalls))
    : 0;
  const perCall = Number.isFinite(perCallMicrousd)
    ? Math.max(0, Math.floor(perCallMicrousd))
    : DEFAULT_TRIAL_IMAGE_RESERVATION_MICROUSD;
  return calls * perCall;
}

/**
 * Trial images have their own quota/cost ledger. Remove that tool cost from
 * the general AI ledger so one anonymous image does not also exhaust the much
 * smaller text-chat budget. Request telemetry still retains the total cost.
 */
export function requestCostExcludingTrialImageMicrousd(
  totalRequestCostMicrousd: number | null,
  completedCalls: number,
  trialReservationMicrousd: number,
): number | null {
  if (totalRequestCostMicrousd == null) return null;
  const total = Number.isFinite(totalRequestCostMicrousd)
    ? Math.max(0, Math.floor(totalRequestCostMicrousd))
    : 0;
  return Math.max(
    0,
    total -
      imageGenerationToolCostMicrousd(
        completedCalls,
        trialReservationMicrousd,
      ),
  );
}

/**
 * Gives the model truthful availability context after a quota denial without
 * trying to infer image intent from prompt keywords.
 */
export function applyTrialImageAvailabilityGuidance(
  payload: Record<string, unknown>,
  cohort: UserCohort | null,
  quotaDenied: boolean,
): void {
  const current = typeof payload.instructions === "string"
    ? payload.instructions
    : "";
  const withoutGuidance = current.replace(
    new RegExp(
      `\\n*<${TRIAL_IMAGE_AVAILABILITY_TAG}>[\\s\\S]*?</${TRIAL_IMAGE_AVAILABILITY_TAG}>\\n*`,
      "g",
    ),
    "\n",
  ).trim();

  if (!quotaDenied) {
    if (withoutGuidance) payload.instructions = withoutGuidance;
    else delete payload.instructions;
    return;
  }

  const nextStep = cohort === "anonymous"
    ? "The user can sign in for the larger Free allowance, wait for the anonymous allowance to reset, or upgrade."
    : "The user can wait for the Free allowance to reset or upgrade.";
  const guidance = `<${TRIAL_IMAGE_AVAILABILITY_TAG}>\n` +
    "The image-generation trial allowance is currently exhausted, so the image tool is unavailable for this request. " +
    "Only mention this if the user asks to create or edit an image. Do not claim that HowAI can never generate images. " +
    `${nextStep}\n` +
    `</${TRIAL_IMAGE_AVAILABILITY_TAG}>`;
  payload.instructions = withoutGuidance
    ? `${withoutGuidance}\n\n${guidance}`
    : guidance;
}
