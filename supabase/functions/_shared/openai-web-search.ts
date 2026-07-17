import type { ModelRole, RequestIntent, UserCohort } from "./openai-policy.ts";

export type FreeWebSearchMode = "off" | "internal" | "on";

export type FreeWebSearchRollout = Readonly<{
  active: boolean;
  mode: FreeWebSearchMode;
}>;

export type FreeWebSearchRolloutInput = Readonly<{
  environmentEnabled: boolean;
  flagEnabled: boolean;
  payload: unknown;
  internalCanary: boolean;
}>;

export type FreeWebSearchEligibility = Readonly<{
  rolloutActive: boolean;
  cohort: UserCohort;
  modelRole: ModelRole;
  intent: RequestIntent;
}>;

export type FreeWebSearchReservationEligibility = Readonly<{
  cohort: UserCohort;
  modelRole: ModelRole;
  webSearchMode: "auto" | "force" | "disabled";
}>;

export const WEB_SEARCH_TOOL_CALL_MICROUSD = 10_000;
export const DEFAULT_FREE_WEB_SEARCH_RESERVATION_MICROUSD = 40_000;

export function resolveFreeWebSearchRollout(
  input: FreeWebSearchRolloutInput,
): FreeWebSearchRollout {
  const mode = parseMode(input.payload);
  if (!input.environmentEnabled || !input.flagEnabled || mode === "off") {
    return { active: false, mode };
  }

  if (mode === "internal") {
    return { active: input.internalCanary, mode };
  }

  return { active: true, mode };
}

export function shouldOfferFreeWebSearch(
  input: FreeWebSearchEligibility,
): boolean {
  return input.rolloutActive &&
    input.cohort === "free" &&
    input.modelRole === "luna" &&
    input.intent === "primary_chat";
}

export function shouldReserveFreeWebSearch(
  input: FreeWebSearchReservationEligibility,
): boolean {
  return input.cohort === "free" &&
    input.modelRole === "luna" &&
    input.webSearchMode !== "disabled";
}

export function webSearchToolCostMicrousd(callCount: number): number {
  return nonNegativeInteger(callCount) * WEB_SEARCH_TOOL_CALL_MICROUSD;
}

export function webSearchAccountedCostMicrousd(
  callCount: number,
  reservationMicrousd: number,
  actualRequestCostMicrousd: number | null = null,
): number {
  const calls = nonNegativeInteger(callCount);
  if (calls === 0) return 0;
  const reconciledCost = actualRequestCostMicrousd == null
    ? nonNegativeInteger(reservationMicrousd)
    : nonNegativeInteger(actualRequestCostMicrousd);
  return Math.max(
    webSearchToolCostMicrousd(calls),
    reconciledCost,
  );
}

function parseMode(payload: unknown): FreeWebSearchMode {
  if (!payload || typeof payload !== "object") return "off";
  const mode = (payload as Record<string, unknown>).mode;
  return mode === "internal" || mode === "on" ? mode : "off";
}

function nonNegativeInteger(value: number): number {
  if (!Number.isFinite(value)) return 0;
  return Math.max(0, Math.floor(value));
}
