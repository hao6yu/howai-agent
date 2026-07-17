import type { SupabaseClient } from "npm:@supabase/supabase-js@2";
import type { HowAiPersonalContext } from "./howai-prompt-policy.ts";
import { isStoredEntitlementActive } from "./entitlement-status.ts";

type MemoryRow = Readonly<{
  memory_type: string;
  title: string;
  content: string;
}>;

export async function loadHowAiPersonalContext(
  admin: SupabaseClient,
  userId: string,
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
      .select("name")
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
    // Privacy controls fail closed. A missing row still uses the documented
    // default, but a failed lookup must never bypass an existing opt-out.
    return null;
  }
  if (preferencesResult.data?.personalization_enabled === false) {
    return null;
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
  const hasPaidPersonalization = !entitlementResult.error &&
    isStoredEntitlementActive(entitlement);
  return {
    displayName: profileResult.data?.name ?? null,
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
