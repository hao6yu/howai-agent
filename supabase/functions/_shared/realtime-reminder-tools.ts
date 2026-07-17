export type RealtimeReminder = Readonly<{
  id: string;
  title: string;
  notes: string | null;
  timezone: string;
  start_local: string;
  recurrence_rule: Record<string, unknown> | null;
  status: "active" | "paused" | "completed";
  version: number;
}>;

type RealtimeFunctionTool = Readonly<Record<string, unknown>>;

function recurrenceSchema(): Record<string, unknown> {
  return {
    type: ["object", "null"],
    additionalProperties: false,
    properties: {
      frequency: { type: "string", enum: ["daily", "weekly", "monthly"] },
      interval: { type: "integer", minimum: 1, maximum: 365 },
      weekdays: {
        type: "array",
        items: { type: "integer", minimum: 1, maximum: 7 },
      },
      day_of_month: { type: ["integer", "null"], minimum: 1, maximum: 31 },
      month_week: {
        type: ["integer", "null"],
        enum: [1, 2, 3, 4, -1, null],
      },
      month_weekday: {
        type: ["integer", "null"],
        minimum: 1,
        maximum: 7,
      },
      ends_at: { type: ["string", "null"] },
    },
    required: [
      "frequency",
      "interval",
      "weekdays",
      "day_of_month",
      "month_week",
      "month_weekday",
      "ends_at",
    ],
  };
}

function reminderFields(): Record<string, unknown> {
  return {
    title: {
      type: "string",
      description:
        "Short natural action label. Never append the words reminder or draft.",
    },
    notes: { type: ["string", "null"] },
    timezone: { type: "string", description: "IANA timezone." },
    start_local: {
      type: "string",
      description:
        "First local occurrence as YYYY-MM-DDTHH:mm:ss without an offset.",
    },
    recurrence: recurrenceSchema(),
  };
}

function createTool(): RealtimeFunctionTool {
  return {
    type: "function",
    name: "reminders_create",
    description:
      "Propose a one-time or recurring static reminder only when the user clearly asks to be reminded. Never use this for news, market reports, searches, or generated briefings. This creates a review proposal, not an active reminder.",
    parameters: {
      type: "object",
      additionalProperties: false,
      properties: reminderFields(),
      required: ["title", "notes", "timezone", "start_local", "recurrence"],
    },
  };
}

function updateTool(
  reminders: readonly RealtimeReminder[],
): RealtimeFunctionTool {
  return {
    type: "function",
    name: "reminders_update",
    description:
      "Propose an update to one existing reminder. Select the best matching reminder, preserve every unchanged value, and change only what the user requested. Approval is still required.",
    parameters: {
      type: "object",
      additionalProperties: false,
      properties: {
        reminder_id: {
          type: "string",
          enum: reminders.map((reminder) => reminder.id),
        },
        expected_version: { type: "integer", minimum: 1 },
        ...reminderFields(),
      },
      required: [
        "reminder_id",
        "expected_version",
        "title",
        "notes",
        "timezone",
        "start_local",
        "recurrence",
      ],
    },
  };
}

function resumeTool(
  reminders: readonly RealtimeReminder[],
): RealtimeFunctionTool {
  return {
    type: "function",
    name: "reminders_resume",
    description:
      "Propose resuming one paused reminder. Choose the best matching paused reminder. Approval is required.",
    parameters: {
      type: "object",
      additionalProperties: false,
      properties: {
        reminder_id: {
          type: "string",
          enum: reminders.map((reminder) => reminder.id),
        },
        expected_version: { type: "integer", minimum: 1 },
      },
      required: ["reminder_id", "expected_version"],
    },
  };
}

function confirmPendingActionTool(): RealtimeFunctionTool {
  return {
    type: "function",
    name: "actions_confirm_pending",
    description:
      "Confirm the exact pending action only after an action proposal returned awaiting_confirmation and the user clearly approves it in natural conversation. Never infer approval from silence, ambiguity, or an unrelated yes.",
    parameters: {
      type: "object",
      additionalProperties: false,
      properties: {
        proposal_id: {
          type: "string",
          description:
            "The exact proposal_id returned by the pending action tool.",
        },
      },
      required: ["proposal_id"],
    },
  };
}

function cancelPendingActionTool(): RealtimeFunctionTool {
  return {
    type: "function",
    name: "actions_cancel_pending",
    description:
      "Cancel the exact pending action when the user declines it or asks to revise its details. For a revision, wait for this tool result before proposing the corrected action.",
    parameters: {
      type: "object",
      additionalProperties: false,
      properties: {
        proposal_id: {
          type: "string",
          description:
            "The exact proposal_id returned by the pending action tool.",
        },
        intent: {
          type: "string",
          enum: ["cancel", "revise"],
          description:
            "Use revise when the user wants different details; otherwise cancel.",
        },
      },
      required: ["proposal_id", "intent"],
    },
  };
}

export function buildRealtimeReminderTools(
  reminders: readonly RealtimeReminder[],
): readonly RealtimeFunctionTool[] {
  const editable = reminders.filter((reminder) =>
    reminder.status !== "completed"
  );
  const paused = editable.filter((reminder) => reminder.status === "paused");
  return [
    createTool(),
    ...(editable.length > 0 ? [updateTool(editable)] : []),
    ...(paused.length > 0 ? [resumeTool(paused)] : []),
    confirmPendingActionTool(),
    cancelPendingActionTool(),
  ];
}

export function realtimeReminderContext(
  reminders: readonly RealtimeReminder[],
): string {
  const visible = reminders
    .filter((reminder) => reminder.status !== "completed")
    .map((reminder) => ({
      reminder_id: reminder.id,
      title: reminder.title,
      notes: reminder.notes,
      timezone: reminder.timezone,
      start_local: reminder.start_local,
      recurrence: reminder.recurrence_rule,
      status: reminder.status,
      version: reminder.version,
    }));
  return visible.length === 0
    ? "The user has no active or paused reminders."
    : `Existing reminders supplied by the trusted app state: ${
      JSON.stringify(visible)
    }`;
}
