import type { SupabaseClient } from "npm:@supabase/supabase-js@2.111.0";
import type { HowAiPersonalContext } from "./howai-prompt-policy.ts";
import { isStoredEntitlementActive } from "./entitlement-status.ts";

type MemoryRow = Readonly<{
  memory_type: string;
  title: string;
  content: string;
}>;

type DisplayNameStatus = "unknown" | "prompted" | "known" | "declined";

export async function loadHowAiPersonalContext(
  admin: SupabaseClient,
  userId: string,
  options: Readonly<{ includeMemory?: boolean }> = {},
): Promise<HowAiPersonalContext | null> {
  const now = new Date().toISOString();
  const [
    profileResult,
    learnedResult,
    preferencesResult,
    memoriesResult,
    entitlementResult,
  ] = await Promise.all([
    admin.from("profiles")
      .select("name,name_status")
      .eq("id", userId)
      .maybeSingle(),
    admin.from("user_profiles")
      .select(
        "profile_summary,communication_style,topic_interests,preferences",
      )
      .eq("user_id", userId)
      .maybeSingle(),
    admin.from("memory_preferences")
      .select("personalization_enabled")
      .eq("user_id", userId)
      .maybeSingle(),
    admin.from("user_memories")
      .select("memory_type,title,content")
      .eq("user_id", userId)
      .eq("status", "active")
      .or(`expires_at.is.null,expires_at.gt.${now}`)
      .order("updated_at", { ascending: false })
      .limit(8),
    admin.from("app_entitlements")
      .select("tier,source,expires_at")
      .eq("user_id", userId)
      .maybeSingle(),
  ]);

  if (preferencesResult.error) {
    console.error(
      "HowAI memory preference lookup failed",
      preferencesResult.error.message,
    );
  }
  if (profileResult.error) {
    console.error("HowAI profile context lookup failed", profileResult.error);
  }
  if (learnedResult.error) {
    console.error("HowAI learned context lookup failed", learnedResult.error);
  }
  if (memoriesResult.error) {
    console.error("HowAI memory context lookup failed", memoriesResult.error);
  }
  if (entitlementResult.error) {
    console.error(
      "HowAI memory entitlement lookup failed",
      entitlementResult.error,
    );
  }

  const learned = learnedResult.data;
  const memories = (memoriesResult.data ?? []) as MemoryRow[];
  const entitlement = entitlementResult.data;
  const rawNameStatus = profileResult.data?.name_status;
  const displayNameStatus: DisplayNameStatus =
    rawNameStatus === "prompted" || rawNameStatus === "known" ||
      rawNameStatus === "declined"
      ? rawNameStatus
      : "unknown";
  // A user's explicit profile name is account data, not inferred memory.
  // Memory personalization still fails closed independently when its privacy
  // preference cannot be verified or has been disabled.
  const personalizationAllowed = options.includeMemory !== false &&
    !preferencesResult.error &&
    preferencesResult.data?.personalization_enabled !== false;
  const hasPaidPersonalization = personalizationAllowed &&
    !entitlementResult.error &&
    isStoredEntitlementActive(entitlement);
  return {
    displayName: displayNameStatus === "known"
      ? profileResult.data?.name ?? null
      : null,
    displayNameStatus,
    shouldAskPreferredName: false,
    profileSummary: hasPaidPersonalization
      ? learned?.profile_summary ?? null
      : null,
    communicationStyle: hasPaidPersonalization
      ? learned?.communication_style ?? null
      : null,
    topicInterests: hasPaidPersonalization
      ? learned?.topic_interests ?? null
      : null,
    preferences: hasPaidPersonalization ? learned?.preferences ?? null : null,
    memories: hasPaidPersonalization
      ? memories.map((memory) => ({
        type: memory.memory_type,
        title: memory.title,
        content: memory.content,
      }))
      : [],
  };
}

export async function claimHowAiPreferredNamePrompt(
  admin: SupabaseClient,
  userId: string,
  context: HowAiPersonalContext | null,
): Promise<HowAiPersonalContext | null> {
  if (!context || context.displayNameStatus !== "unknown") return context;
  const now = new Date().toISOString();
  const { data, error } = await admin.from("profiles")
    .update({
      name_status: "prompted",
      name_prompted_at: now,
      updated_at: now,
    })
    .eq("id", userId)
    .eq("name_status", "unknown")
    .select("id")
    .maybeSingle();
  if (error) {
    console.error("HowAI preferred-name prompt claim failed", error.message);
    return context;
  }
  if (!data) return { ...context, shouldAskPreferredName: false };
  return {
    ...context,
    displayName: null,
    displayNameStatus: "prompted",
    shouldAskPreferredName: true,
  };
}
