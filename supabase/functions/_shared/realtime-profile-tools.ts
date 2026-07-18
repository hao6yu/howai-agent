export const REALTIME_PROFILE_NAME_TOOL_NAME = "profiles_update_display_name";

export function buildRealtimeProfileTools(
  enabled: boolean,
): readonly Readonly<Record<string, unknown>>[] {
  if (!enabled) return [];
  return [{
    type: "function",
    name: REALTIME_PROFILE_NAME_TOOL_NAME,
    description:
      "Update how the signed-in user wants HowAI to address them. Call action=set only after the user clearly identifies their own preferred name or explicitly asks to be called something. Call action=decline only when the user clearly declines to share a name or asks not to be prompted again. Never infer a name from another person, a document, an email address, or uncertain context.",
    parameters: {
      type: "object",
      additionalProperties: false,
      properties: {
        action: {
          type: "string",
          enum: ["set", "decline"],
        },
        display_name: {
          type: ["string", "null"],
          description:
            "The user's explicitly stated preferred name for action=set; null for action=decline.",
        },
      },
      required: ["action", "display_name"],
    },
  }];
}
