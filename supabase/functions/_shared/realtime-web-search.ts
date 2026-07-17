export const REALTIME_WEB_SEARCH_TOOL_NAME = "search_current_information";

type RealtimeFunctionTool = Readonly<Record<string, unknown>>;

/**
 * Realtime does not inherit the Responses API's hosted web-search tool.
 * Expose a narrow application function instead; the authenticated mobile
 * client executes it through HowAI's existing Supabase OpenAI proxy.
 */
export function buildRealtimeWebSearchTools(
  enabled: boolean,
): readonly RealtimeFunctionTool[] {
  if (!enabled) return [];

  return [{
    type: "function",
    name: REALTIME_WEB_SEARCH_TOOL_NAME,
    description:
      "Search the live web for current, recently changed, or precisely verifiable information. Use this automatically when the answer depends on up-to-date facts such as news, weather, sports, schedules, prices, laws, product details, public figures, or recent events. Do not say live search is unavailable before calling this tool. Do not use it for timeless knowledge, casual conversation, or to perform an external action.",
    parameters: {
      type: "object",
      additionalProperties: false,
      properties: {
        query: {
          type: "string",
          minLength: 2,
          maxLength: 1000,
          description:
            "A concise, standalone search query that preserves the user's intent, names, dates, and relevant context.",
        },
      },
      required: ["query"],
    },
  }];
}
