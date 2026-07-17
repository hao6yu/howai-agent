export type AutomationToolAuthorization = Readonly<{
  generatedAutomations: boolean;
  marketAutomations: boolean;
}>;

export const NO_AUTOMATION_TOOL_AUTHORIZATION: AutomationToolAuthorization =
  Object.freeze({
    generatedAutomations: false,
    marketAutomations: false,
  });

export const NEWS_AUTOMATION_FUNCTION = "automations_create_news_briefing";
export const MARKET_AUTOMATION_FUNCTION = "automations_create_market_briefing";
export const PROFILE_NAME_FUNCTION = "profiles_update_display_name";

const ALLOWED_TOOL_TYPES = new Set([
  "web_search",
  "web_search_preview",
  "image_generation",
  "function",
]);

const BASE_ALLOWED_FUNCTION_NAMES = new Set([
  "generate_pptx",
  PROFILE_NAME_FUNCTION,
  "reminders_create",
  "reminders_update",
  "reminders_resume",
]);

/**
 * Returns whether the client requested either of HowAI's generated Automation
 * proposal functions. This is used only to decide whether the proxy needs a
 * trusted database capability lookup; it never infers intent from prompt text.
 */
export function requestsAutomationFunction(tools: unknown): boolean {
  if (!Array.isArray(tools)) return false;
  return tools.some((tool) => {
    const name = functionName(tool);
    return name === NEWS_AUTOMATION_FUNCTION ||
      name === MARKET_AUTOMATION_FUNCTION;
  });
}

export function requestsProfileNameFunction(tools: unknown): boolean {
  if (!Array.isArray(tools)) return false;
  return tools.some((tool) => functionName(tool) === PROFILE_NAME_FUNCTION);
}

/**
 * Keeps only built-in tools and explicitly authorized HowAI function tools.
 * Client-supplied function definitions are never trusted on their own.
 */
export function sanitizeResponseTools(
  tools: unknown,
  automationAuthorization: AutomationToolAuthorization =
    NO_AUTOMATION_TOOL_AUTHORIZATION,
): unknown {
  if (!Array.isArray(tools)) return tools;

  return tools.filter((tool) => {
    if (!tool || typeof tool !== "object") return false;

    const candidate = tool as Record<string, unknown>;
    const toolType = typeof candidate.type === "string" ? candidate.type : "";
    if (!ALLOWED_TOOL_TYPES.has(toolType)) return false;
    if (toolType !== "function") return true;

    const name = functionName(candidate);
    if (BASE_ALLOWED_FUNCTION_NAMES.has(name)) return true;
    if (name === NEWS_AUTOMATION_FUNCTION) {
      return automationAuthorization.generatedAutomations;
    }
    if (name === MARKET_AUTOMATION_FUNCTION) {
      return automationAuthorization.generatedAutomations &&
        automationAuthorization.marketAutomations;
    }
    return false;
  });
}

function functionName(tool: unknown): string {
  if (!tool || typeof tool !== "object") return "";
  const candidate = tool as Record<string, unknown>;
  if (typeof candidate.name === "string") return candidate.name;
  const nested = candidate.function;
  return nested && typeof nested === "object" &&
      typeof (nested as Record<string, unknown>).name === "string"
    ? String((nested as Record<string, unknown>).name)
    : "";
}
