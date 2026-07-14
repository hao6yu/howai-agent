drop extension if exists "pg_net";


  create table "public"."ai_personalities" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "ai_name" text default 'HowAI'::text,
    "avatar_url" text,
    "personality" text default 'friendly'::text,
    "humor_level" text default 'dry'::text,
    "communication_style" text default 'tech-savvy'::text,
    "response_length" text default 'moderate'::text,
    "expertise" text default 'general'::text,
    "interests" text,
    "background_story" text,
    "custom_settings" jsonb default '{}'::jsonb,
    "is_active" boolean default true,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "is_master" boolean default false,
    "gender" text default 'neutral'::text,
    "age" integer default 25
      );


alter table "public"."ai_personalities" enable row level security;


  create table "public"."conversations" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "title" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "is_pinned" boolean default false
      );


alter table "public"."conversations" enable row level security;


  create table "public"."message_feedback" (
    "id" uuid not null default gen_random_uuid(),
    "message_id" uuid not null,
    "user_id" uuid not null,
    "feedback_type" text,
    "feedback_text" text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."message_feedback" enable row level security;


  create table "public"."messages" (
    "id" uuid not null default gen_random_uuid(),
    "conversation_id" uuid not null,
    "content" text not null,
    "is_ai" boolean default false,
    "created_at" timestamp with time zone default now(),
    "image_urls" text[]
      );


alter table "public"."messages" enable row level security;


  create table "public"."profile_evaluations" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "conversation_id" uuid,
    "messages_analyzed" integer,
    "evaluation_type" text,
    "insights" jsonb,
    "profile_changes" jsonb,
    "processing_time_ms" integer,
    "model_used" text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."profile_evaluations" enable row level security;


  create table "public"."profiles" (
    "id" uuid not null,
    "email" text,
    "name" text,
    "avatar_url" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."profiles" enable row level security;


  create table "public"."subscription_status" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "platform" text not null,
    "subscription_type" text not null,
    "is_active" boolean default false,
    "purchase_token" text,
    "expires_at" timestamp with time zone,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."subscription_status" enable row level security;


  create table "public"."usage_statistics" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "feature_name" text not null,
    "usage_count" integer default 0,
    "last_reset_at" timestamp with time zone default now(),
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."usage_statistics" enable row level security;


  create table "public"."user_profiles" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "preferred_language" text default 'en'::text,
    "detected_languages" text[],
    "communication_style" jsonb default '{}'::jsonb,
    "topic_interests" jsonb default '{}'::jsonb,
    "characteristics" jsonb default '{}'::jsonb,
    "behavioral_patterns" jsonb default '{}'::jsonb,
    "preferences" jsonb default '{}'::jsonb,
    "profile_summary" text,
    "last_summary_update" timestamp with time zone,
    "message_count" integer default 0,
    "total_conversations" integer default 0,
    "last_analyzed_at" timestamp with time zone,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."user_profiles" enable row level security;

CREATE UNIQUE INDEX ai_personalities_pkey ON public.ai_personalities USING btree (id);

CREATE UNIQUE INDEX conversations_pkey ON public.conversations USING btree (id);

CREATE INDEX idx_ai_personalities_user_id ON public.ai_personalities USING btree (user_id);

CREATE INDEX idx_conversations_updated_at ON public.conversations USING btree (updated_at);

CREATE INDEX idx_conversations_user_id ON public.conversations USING btree (user_id);

CREATE INDEX idx_message_feedback_message_id ON public.message_feedback USING btree (message_id);

CREATE INDEX idx_message_feedback_user_id ON public.message_feedback USING btree (user_id);

CREATE INDEX idx_messages_conversation_id ON public.messages USING btree (conversation_id);

CREATE INDEX idx_messages_created_at ON public.messages USING btree (created_at);

CREATE INDEX idx_profile_evaluations_conversation_id ON public.profile_evaluations USING btree (conversation_id);

CREATE INDEX idx_profile_evaluations_created_at ON public.profile_evaluations USING btree (created_at);

CREATE INDEX idx_profile_evaluations_user_id ON public.profile_evaluations USING btree (user_id);

CREATE INDEX idx_subscription_status_active ON public.subscription_status USING btree (is_active);

CREATE INDEX idx_subscription_status_user_id ON public.subscription_status USING btree (user_id);

CREATE UNIQUE INDEX idx_unique_master ON public.ai_personalities USING btree (is_master) WHERE (is_master = true);

CREATE INDEX idx_usage_statistics_user_id ON public.usage_statistics USING btree (user_id);

CREATE INDEX idx_user_profiles_updated_at ON public.user_profiles USING btree (updated_at);

CREATE INDEX idx_user_profiles_user_id ON public.user_profiles USING btree (user_id);

CREATE UNIQUE INDEX message_feedback_pkey ON public.message_feedback USING btree (id);

CREATE UNIQUE INDEX messages_pkey ON public.messages USING btree (id);

CREATE UNIQUE INDEX profile_evaluations_pkey ON public.profile_evaluations USING btree (id);

CREATE UNIQUE INDEX profiles_pkey ON public.profiles USING btree (id);

CREATE UNIQUE INDEX subscription_status_pkey ON public.subscription_status USING btree (id);

CREATE UNIQUE INDEX subscription_status_user_id_platform_key ON public.subscription_status USING btree (user_id, platform);

CREATE UNIQUE INDEX usage_statistics_pkey ON public.usage_statistics USING btree (id);

CREATE UNIQUE INDEX usage_statistics_user_id_feature_name_key ON public.usage_statistics USING btree (user_id, feature_name);

CREATE UNIQUE INDEX user_profiles_pkey ON public.user_profiles USING btree (id);

CREATE UNIQUE INDEX user_profiles_user_id_key ON public.user_profiles USING btree (user_id);

alter table "public"."ai_personalities" add constraint "ai_personalities_pkey" PRIMARY KEY using index "ai_personalities_pkey";

alter table "public"."conversations" add constraint "conversations_pkey" PRIMARY KEY using index "conversations_pkey";

alter table "public"."message_feedback" add constraint "message_feedback_pkey" PRIMARY KEY using index "message_feedback_pkey";

alter table "public"."messages" add constraint "messages_pkey" PRIMARY KEY using index "messages_pkey";

alter table "public"."profile_evaluations" add constraint "profile_evaluations_pkey" PRIMARY KEY using index "profile_evaluations_pkey";

alter table "public"."profiles" add constraint "profiles_pkey" PRIMARY KEY using index "profiles_pkey";

alter table "public"."subscription_status" add constraint "subscription_status_pkey" PRIMARY KEY using index "subscription_status_pkey";

alter table "public"."usage_statistics" add constraint "usage_statistics_pkey" PRIMARY KEY using index "usage_statistics_pkey";

alter table "public"."user_profiles" add constraint "user_profiles_pkey" PRIMARY KEY using index "user_profiles_pkey";

alter table "public"."ai_personalities" add constraint "ai_personalities_communication_style_check" CHECK ((communication_style = ANY (ARRAY['casual'::text, 'formal'::text, 'tech-savvy'::text, 'supportive'::text]))) not valid;

alter table "public"."ai_personalities" validate constraint "ai_personalities_communication_style_check";

alter table "public"."ai_personalities" add constraint "ai_personalities_expertise_check" CHECK ((expertise = ANY (ARRAY['general'::text, 'technology'::text, 'business'::text, 'creative'::text, 'academic'::text]))) not valid;

alter table "public"."ai_personalities" validate constraint "ai_personalities_expertise_check";

alter table "public"."ai_personalities" add constraint "ai_personalities_humor_level_check" CHECK ((humor_level = ANY (ARRAY['none'::text, 'light'::text, 'dry'::text, 'moderate'::text, 'heavy'::text]))) not valid;

alter table "public"."ai_personalities" validate constraint "ai_personalities_humor_level_check";

alter table "public"."ai_personalities" add constraint "ai_personalities_personality_check" CHECK ((personality = ANY (ARRAY['friendly'::text, 'professional'::text, 'witty'::text, 'caring'::text, 'energetic'::text]))) not valid;

alter table "public"."ai_personalities" validate constraint "ai_personalities_personality_check";

alter table "public"."ai_personalities" add constraint "ai_personalities_response_length_check" CHECK ((response_length = ANY (ARRAY['concise'::text, 'moderate'::text, 'detailed'::text]))) not valid;

alter table "public"."ai_personalities" validate constraint "ai_personalities_response_length_check";

alter table "public"."ai_personalities" add constraint "ai_personalities_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."ai_personalities" validate constraint "ai_personalities_user_id_fkey";

alter table "public"."ai_personalities" add constraint "user_or_master" CHECK ((((user_id IS NOT NULL) AND (is_master = false)) OR ((user_id IS NULL) AND (is_master = true)))) not valid;

alter table "public"."ai_personalities" validate constraint "user_or_master";

alter table "public"."conversations" add constraint "conversations_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."conversations" validate constraint "conversations_user_id_fkey";

alter table "public"."message_feedback" add constraint "message_feedback_feedback_type_check" CHECK ((feedback_type = ANY (ARRAY['helpful'::text, 'not_helpful'::text, 'too_detailed'::text, 'too_brief'::text, 'off_topic'::text, 'perfect'::text]))) not valid;

alter table "public"."message_feedback" validate constraint "message_feedback_feedback_type_check";

alter table "public"."message_feedback" add constraint "message_feedback_message_id_fkey" FOREIGN KEY (message_id) REFERENCES public.messages(id) ON DELETE CASCADE not valid;

alter table "public"."message_feedback" validate constraint "message_feedback_message_id_fkey";

alter table "public"."message_feedback" add constraint "message_feedback_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."message_feedback" validate constraint "message_feedback_user_id_fkey";

alter table "public"."messages" add constraint "messages_conversation_id_fkey" FOREIGN KEY (conversation_id) REFERENCES public.conversations(id) ON DELETE CASCADE not valid;

alter table "public"."messages" validate constraint "messages_conversation_id_fkey";

alter table "public"."profile_evaluations" add constraint "profile_evaluations_conversation_id_fkey" FOREIGN KEY (conversation_id) REFERENCES public.conversations(id) ON DELETE SET NULL not valid;

alter table "public"."profile_evaluations" validate constraint "profile_evaluations_conversation_id_fkey";

alter table "public"."profile_evaluations" add constraint "profile_evaluations_evaluation_type_check" CHECK ((evaluation_type = ANY (ARRAY['periodic'::text, 'conversation_end'::text, 'manual'::text, 'initial'::text]))) not valid;

alter table "public"."profile_evaluations" validate constraint "profile_evaluations_evaluation_type_check";

alter table "public"."profile_evaluations" add constraint "profile_evaluations_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."profile_evaluations" validate constraint "profile_evaluations_user_id_fkey";

alter table "public"."profiles" add constraint "profiles_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."profiles" validate constraint "profiles_id_fkey";

alter table "public"."subscription_status" add constraint "subscription_status_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."subscription_status" validate constraint "subscription_status_user_id_fkey";

alter table "public"."subscription_status" add constraint "subscription_status_user_id_platform_key" UNIQUE using index "subscription_status_user_id_platform_key";

alter table "public"."usage_statistics" add constraint "usage_statistics_user_id_feature_name_key" UNIQUE using index "usage_statistics_user_id_feature_name_key";

alter table "public"."usage_statistics" add constraint "usage_statistics_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."usage_statistics" validate constraint "usage_statistics_user_id_fkey";

alter table "public"."user_profiles" add constraint "user_profiles_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."user_profiles" validate constraint "user_profiles_user_id_fkey";

alter table "public"."user_profiles" add constraint "user_profiles_user_id_key" UNIQUE using index "user_profiles_user_id_key";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.create_user_personality_from_master(p_user_id uuid)
 RETURNS public.ai_personalities
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  v_master RECORD;
  v_new_personality ai_personalities;
BEGIN
  -- Get the master template
  SELECT * INTO v_master
  FROM ai_personalities
  WHERE is_master = true;

  -- If no master exists, create with defaults
  IF v_master IS NULL THEN
    INSERT INTO ai_personalities (
      user_id, is_master, ai_name, personality, humor_level,
      communication_style, response_length, expertise
    ) VALUES (
      p_user_id, false, 'HowAI', 'friendly', 'dry',
      'tech-savvy', 'moderate', 'general'
    ) RETURNING * INTO v_new_personality;
  ELSE
    -- Copy from master template
    INSERT INTO ai_personalities (
      user_id,
      is_master,
      ai_name,
      personality,
      humor_level,
      communication_style,
      response_length,
      expertise,
      interests,
      background_story,
      custom_settings
    ) VALUES (
      p_user_id,
      false, -- User personality, not master
      v_master.ai_name,
      v_master.personality,
      v_master.humor_level,
      v_master.communication_style,
      v_master.response_length,
      v_master.expertise,
      v_master.interests,
      v_master.background_story,
      v_master.custom_settings
    ) RETURNING * INTO v_new_personality;
  END IF;

  RETURN v_new_personality;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_merged_ai_context(p_user_id uuid)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  v_personality RECORD;
  v_profile RECORD;
  v_context TEXT;
BEGIN
  -- Get manual AI personality settings
  SELECT * INTO v_personality
  FROM ai_personalities
  WHERE user_id = p_user_id AND is_active = true;

  -- Get learned user profile
  SELECT * INTO v_profile
  FROM user_profiles
  WHERE user_id = p_user_id;

  v_context := '';

  -- Add AI name if customized
  IF v_personality.ai_name IS NOT NULL AND v_personality.ai_name != 'HaoGPT Assistant' THEN
    v_context := v_context || 'Your name is: ' || v_personality.ai_name || E'\n';
  END IF;

  -- Add personality traits
  IF v_personality IS NOT NULL THEN
    v_context := v_context || 'Personality Configuration:' || E'\n';
    v_context := v_context || '- Personality: ' || v_personality.personality || E'\n';
    v_context := v_context || '- Humor Level: ' || v_personality.humor_level || E'\n';
    v_context := v_context || '- Communication: ' || v_personality.communication_style || E'\n';
    v_context := v_context || '- Response Length: ' || v_personality.response_length || E'\n';
    v_context := v_context || '- Expertise: ' || v_personality.expertise || E'\n';

    IF v_personality.interests IS NOT NULL AND v_personality.interests != '' THEN
      v_context := v_context || '- Interests: ' || v_personality.interests || E'\n';
    END IF;

    IF v_personality.background_story IS NOT NULL AND v_personality.background_story != '' THEN
      v_context := v_context || '- Background: ' || v_personality.background_story || E'\n';
    END IF;
  END IF;

  -- Add learned profile context if exists
  IF v_profile IS NOT NULL AND v_profile.profile_summary IS NOT NULL THEN
    v_context := v_context || E'\nLearned User Preferences:' || E'\n';
    v_context := v_context || v_profile.profile_summary || E'\n';

    -- Merge topic interests from learned profile
    IF v_profile.topic_interests IS NOT NULL AND v_profile.topic_interests != '{}' THEN
      v_context := v_context || 'User Interests: ' || v_profile.topic_interests::TEXT || E'\n';
    END IF;
  END IF;

  RETURN v_context;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_user_profile_context(p_user_id uuid)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  v_profile RECORD;
  v_context TEXT;
BEGIN
  SELECT * INTO v_profile
  FROM user_profiles
  WHERE user_id = p_user_id;

  IF v_profile IS NULL THEN
    RETURN '';
  END IF;

  v_context := '';

  -- Add profile summary if exists
  IF v_profile.profile_summary IS NOT NULL THEN
    v_context := v_context || 'User Profile: ' || v_profile.profile_summary || E'\n';
  END IF;

  -- Add language preference
  IF v_profile.preferred_language IS NOT NULL AND v_profile.preferred_language != 'en' THEN
    v_context := v_context || 'Preferred Language: ' || v_profile.preferred_language || E'\n';
  END IF;

  -- Add communication style
  IF v_profile.communication_style IS NOT NULL AND v_profile.communication_style != '{}' THEN
    v_context := v_context || 'Communication Style: ' || v_profile.communication_style::TEXT || E'\n';
  END IF;

  -- Add top interests
  IF v_profile.topic_interests IS NOT NULL AND v_profile.topic_interests != '{}' THEN
    v_context := v_context || 'Interests: ' || v_profile.topic_interests::TEXT || E'\n';
  END IF;

  RETURN v_context;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  -- Insert into public.profiles table
  INSERT INTO public.profiles (id, email, name)
  VALUES (NEW.id, NEW.email, COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)));
  RETURN NEW;
EXCEPTION
  WHEN others THEN
    -- Log the error but don't fail the user creation
    RAISE WARNING 'Failed to create profile for user %: %', NEW.id, SQLERRM;
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.initialize_user_profile()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  v_user_id UUID;
  v_profile_exists BOOLEAN;
BEGIN
  -- Get the user_id from the conversation
  SELECT user_id INTO v_user_id
  FROM conversations
  WHERE id = NEW.conversation_id;

  -- Check if profile already exists
  SELECT EXISTS(
    SELECT 1 FROM user_profiles WHERE user_id = v_user_id
  ) INTO v_profile_exists;

  -- Create profile if it doesn't exist
  IF NOT v_profile_exists AND NOT NEW.is_ai THEN
    INSERT INTO user_profiles (user_id, message_count, total_conversations)
    VALUES (v_user_id, 1, 1)
    ON CONFLICT (user_id) DO NOTHING;
  END IF;

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.reset_user_personality_to_master(p_user_id uuid)
 RETURNS public.ai_personalities
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  v_master RECORD;
  v_updated_personality ai_personalities;
BEGIN
  -- Get the master template
  SELECT * INTO v_master
  FROM ai_personalities
  WHERE is_master = true;

  IF v_master IS NULL THEN
    RAISE EXCEPTION 'No master personality template found';
  END IF;

  -- Update user's personality to match master
  UPDATE ai_personalities
  SET
    ai_name = v_master.ai_name,
    personality = v_master.personality,
    humor_level = v_master.humor_level,
    communication_style = v_master.communication_style,
    response_length = v_master.response_length,
    expertise = v_master.expertise,
    interests = v_master.interests,
    background_story = v_master.background_story,
    custom_settings = v_master.custom_settings,
    updated_at = NOW()
  WHERE user_id = p_user_id AND is_master = false
  RETURNING * INTO v_updated_personality;

  RETURN v_updated_personality;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$function$
;

create or replace view "public"."user_personality_status" as  SELECT p.id AS user_id,
    p.email,
    ap.ai_name,
    ap.personality,
    ap.humor_level,
    ap.communication_style,
    ap.updated_at,
        CASE
            WHEN (ap.id IS NULL) THEN 'No personality'::text
            WHEN (ap.updated_at > COALESCE(m.updated_at, '1970-01-01 00:00:00+00'::timestamp with time zone)) THEN 'Customized'::text
            ELSE 'Using defaults'::text
        END AS status
   FROM ((public.profiles p
     LEFT JOIN public.ai_personalities ap ON (((p.id = ap.user_id) AND (ap.is_master = false))))
     LEFT JOIN public.ai_personalities m ON ((m.is_master = true)));


grant delete on table "public"."ai_personalities" to "anon";

grant insert on table "public"."ai_personalities" to "anon";

grant references on table "public"."ai_personalities" to "anon";

grant select on table "public"."ai_personalities" to "anon";

grant trigger on table "public"."ai_personalities" to "anon";

grant truncate on table "public"."ai_personalities" to "anon";

grant update on table "public"."ai_personalities" to "anon";

grant delete on table "public"."ai_personalities" to "authenticated";

grant insert on table "public"."ai_personalities" to "authenticated";

grant references on table "public"."ai_personalities" to "authenticated";

grant select on table "public"."ai_personalities" to "authenticated";

grant trigger on table "public"."ai_personalities" to "authenticated";

grant truncate on table "public"."ai_personalities" to "authenticated";

grant update on table "public"."ai_personalities" to "authenticated";

grant delete on table "public"."ai_personalities" to "service_role";

grant insert on table "public"."ai_personalities" to "service_role";

grant references on table "public"."ai_personalities" to "service_role";

grant select on table "public"."ai_personalities" to "service_role";

grant trigger on table "public"."ai_personalities" to "service_role";

grant truncate on table "public"."ai_personalities" to "service_role";

grant update on table "public"."ai_personalities" to "service_role";

grant delete on table "public"."conversations" to "anon";

grant insert on table "public"."conversations" to "anon";

grant references on table "public"."conversations" to "anon";

grant select on table "public"."conversations" to "anon";

grant trigger on table "public"."conversations" to "anon";

grant truncate on table "public"."conversations" to "anon";

grant update on table "public"."conversations" to "anon";

grant delete on table "public"."conversations" to "authenticated";

grant insert on table "public"."conversations" to "authenticated";

grant references on table "public"."conversations" to "authenticated";

grant select on table "public"."conversations" to "authenticated";

grant trigger on table "public"."conversations" to "authenticated";

grant truncate on table "public"."conversations" to "authenticated";

grant update on table "public"."conversations" to "authenticated";

grant delete on table "public"."conversations" to "service_role";

grant insert on table "public"."conversations" to "service_role";

grant references on table "public"."conversations" to "service_role";

grant select on table "public"."conversations" to "service_role";

grant trigger on table "public"."conversations" to "service_role";

grant truncate on table "public"."conversations" to "service_role";

grant update on table "public"."conversations" to "service_role";

grant delete on table "public"."message_feedback" to "anon";

grant insert on table "public"."message_feedback" to "anon";

grant references on table "public"."message_feedback" to "anon";

grant select on table "public"."message_feedback" to "anon";

grant trigger on table "public"."message_feedback" to "anon";

grant truncate on table "public"."message_feedback" to "anon";

grant update on table "public"."message_feedback" to "anon";

grant delete on table "public"."message_feedback" to "authenticated";

grant insert on table "public"."message_feedback" to "authenticated";

grant references on table "public"."message_feedback" to "authenticated";

grant select on table "public"."message_feedback" to "authenticated";

grant trigger on table "public"."message_feedback" to "authenticated";

grant truncate on table "public"."message_feedback" to "authenticated";

grant update on table "public"."message_feedback" to "authenticated";

grant delete on table "public"."message_feedback" to "service_role";

grant insert on table "public"."message_feedback" to "service_role";

grant references on table "public"."message_feedback" to "service_role";

grant select on table "public"."message_feedback" to "service_role";

grant trigger on table "public"."message_feedback" to "service_role";

grant truncate on table "public"."message_feedback" to "service_role";

grant update on table "public"."message_feedback" to "service_role";

grant delete on table "public"."messages" to "anon";

grant insert on table "public"."messages" to "anon";

grant references on table "public"."messages" to "anon";

grant select on table "public"."messages" to "anon";

grant trigger on table "public"."messages" to "anon";

grant truncate on table "public"."messages" to "anon";

grant update on table "public"."messages" to "anon";

grant delete on table "public"."messages" to "authenticated";

grant insert on table "public"."messages" to "authenticated";

grant references on table "public"."messages" to "authenticated";

grant select on table "public"."messages" to "authenticated";

grant trigger on table "public"."messages" to "authenticated";

grant truncate on table "public"."messages" to "authenticated";

grant update on table "public"."messages" to "authenticated";

grant delete on table "public"."messages" to "service_role";

grant insert on table "public"."messages" to "service_role";

grant references on table "public"."messages" to "service_role";

grant select on table "public"."messages" to "service_role";

grant trigger on table "public"."messages" to "service_role";

grant truncate on table "public"."messages" to "service_role";

grant update on table "public"."messages" to "service_role";

grant delete on table "public"."profile_evaluations" to "anon";

grant insert on table "public"."profile_evaluations" to "anon";

grant references on table "public"."profile_evaluations" to "anon";

grant select on table "public"."profile_evaluations" to "anon";

grant trigger on table "public"."profile_evaluations" to "anon";

grant truncate on table "public"."profile_evaluations" to "anon";

grant update on table "public"."profile_evaluations" to "anon";

grant delete on table "public"."profile_evaluations" to "authenticated";

grant insert on table "public"."profile_evaluations" to "authenticated";

grant references on table "public"."profile_evaluations" to "authenticated";

grant select on table "public"."profile_evaluations" to "authenticated";

grant trigger on table "public"."profile_evaluations" to "authenticated";

grant truncate on table "public"."profile_evaluations" to "authenticated";

grant update on table "public"."profile_evaluations" to "authenticated";

grant delete on table "public"."profile_evaluations" to "service_role";

grant insert on table "public"."profile_evaluations" to "service_role";

grant references on table "public"."profile_evaluations" to "service_role";

grant select on table "public"."profile_evaluations" to "service_role";

grant trigger on table "public"."profile_evaluations" to "service_role";

grant truncate on table "public"."profile_evaluations" to "service_role";

grant update on table "public"."profile_evaluations" to "service_role";

grant delete on table "public"."profiles" to "anon";

grant insert on table "public"."profiles" to "anon";

grant references on table "public"."profiles" to "anon";

grant select on table "public"."profiles" to "anon";

grant trigger on table "public"."profiles" to "anon";

grant truncate on table "public"."profiles" to "anon";

grant update on table "public"."profiles" to "anon";

grant delete on table "public"."profiles" to "authenticated";

grant insert on table "public"."profiles" to "authenticated";

grant references on table "public"."profiles" to "authenticated";

grant select on table "public"."profiles" to "authenticated";

grant trigger on table "public"."profiles" to "authenticated";

grant truncate on table "public"."profiles" to "authenticated";

grant update on table "public"."profiles" to "authenticated";

grant delete on table "public"."profiles" to "service_role";

grant insert on table "public"."profiles" to "service_role";

grant references on table "public"."profiles" to "service_role";

grant select on table "public"."profiles" to "service_role";

grant trigger on table "public"."profiles" to "service_role";

grant truncate on table "public"."profiles" to "service_role";

grant update on table "public"."profiles" to "service_role";

grant delete on table "public"."subscription_status" to "anon";

grant insert on table "public"."subscription_status" to "anon";

grant references on table "public"."subscription_status" to "anon";

grant select on table "public"."subscription_status" to "anon";

grant trigger on table "public"."subscription_status" to "anon";

grant truncate on table "public"."subscription_status" to "anon";

grant update on table "public"."subscription_status" to "anon";

grant delete on table "public"."subscription_status" to "authenticated";

grant insert on table "public"."subscription_status" to "authenticated";

grant references on table "public"."subscription_status" to "authenticated";

grant select on table "public"."subscription_status" to "authenticated";

grant trigger on table "public"."subscription_status" to "authenticated";

grant truncate on table "public"."subscription_status" to "authenticated";

grant update on table "public"."subscription_status" to "authenticated";

grant delete on table "public"."subscription_status" to "service_role";

grant insert on table "public"."subscription_status" to "service_role";

grant references on table "public"."subscription_status" to "service_role";

grant select on table "public"."subscription_status" to "service_role";

grant trigger on table "public"."subscription_status" to "service_role";

grant truncate on table "public"."subscription_status" to "service_role";

grant update on table "public"."subscription_status" to "service_role";

grant delete on table "public"."usage_statistics" to "anon";

grant insert on table "public"."usage_statistics" to "anon";

grant references on table "public"."usage_statistics" to "anon";

grant select on table "public"."usage_statistics" to "anon";

grant trigger on table "public"."usage_statistics" to "anon";

grant truncate on table "public"."usage_statistics" to "anon";

grant update on table "public"."usage_statistics" to "anon";

grant delete on table "public"."usage_statistics" to "authenticated";

grant insert on table "public"."usage_statistics" to "authenticated";

grant references on table "public"."usage_statistics" to "authenticated";

grant select on table "public"."usage_statistics" to "authenticated";

grant trigger on table "public"."usage_statistics" to "authenticated";

grant truncate on table "public"."usage_statistics" to "authenticated";

grant update on table "public"."usage_statistics" to "authenticated";

grant delete on table "public"."usage_statistics" to "service_role";

grant insert on table "public"."usage_statistics" to "service_role";

grant references on table "public"."usage_statistics" to "service_role";

grant select on table "public"."usage_statistics" to "service_role";

grant trigger on table "public"."usage_statistics" to "service_role";

grant truncate on table "public"."usage_statistics" to "service_role";

grant update on table "public"."usage_statistics" to "service_role";

grant delete on table "public"."user_profiles" to "anon";

grant insert on table "public"."user_profiles" to "anon";

grant references on table "public"."user_profiles" to "anon";

grant select on table "public"."user_profiles" to "anon";

grant trigger on table "public"."user_profiles" to "anon";

grant truncate on table "public"."user_profiles" to "anon";

grant update on table "public"."user_profiles" to "anon";

grant delete on table "public"."user_profiles" to "authenticated";

grant insert on table "public"."user_profiles" to "authenticated";

grant references on table "public"."user_profiles" to "authenticated";

grant select on table "public"."user_profiles" to "authenticated";

grant trigger on table "public"."user_profiles" to "authenticated";

grant truncate on table "public"."user_profiles" to "authenticated";

grant update on table "public"."user_profiles" to "authenticated";

grant delete on table "public"."user_profiles" to "service_role";

grant insert on table "public"."user_profiles" to "service_role";

grant references on table "public"."user_profiles" to "service_role";

grant select on table "public"."user_profiles" to "service_role";

grant trigger on table "public"."user_profiles" to "service_role";

grant truncate on table "public"."user_profiles" to "service_role";

grant update on table "public"."user_profiles" to "service_role";


  create policy "All users can view master personality"
  on "public"."ai_personalities"
  as permissive
  for select
  to public
using ((is_master = true));



  create policy "Users can create own AI personality"
  on "public"."ai_personalities"
  as permissive
  for insert
  to public
with check (((auth.uid() = user_id) AND (is_master = false)));



  create policy "Users can delete own AI personality"
  on "public"."ai_personalities"
  as permissive
  for delete
  to public
using ((auth.uid() = user_id));



  create policy "Users can update own AI personality"
  on "public"."ai_personalities"
  as permissive
  for update
  to public
using (((auth.uid() = user_id) AND (is_master = false)));



  create policy "Users can view own AI personality"
  on "public"."ai_personalities"
  as permissive
  for select
  to public
using (((auth.uid() = user_id) AND (is_master = false)));



  create policy "Users can delete own conversations"
  on "public"."conversations"
  as permissive
  for delete
  to public
using ((auth.uid() = user_id));



  create policy "Users can insert own conversations"
  on "public"."conversations"
  as permissive
  for insert
  to public
with check ((auth.uid() = user_id));



  create policy "Users can update own conversations"
  on "public"."conversations"
  as permissive
  for update
  to public
using ((auth.uid() = user_id));



  create policy "Users can view own conversations"
  on "public"."conversations"
  as permissive
  for select
  to public
using ((auth.uid() = user_id));



  create policy "Users can insert own feedback"
  on "public"."message_feedback"
  as permissive
  for insert
  to public
with check ((auth.uid() = user_id));



  create policy "Users can update own feedback"
  on "public"."message_feedback"
  as permissive
  for update
  to public
using ((auth.uid() = user_id));



  create policy "Users can view own feedback"
  on "public"."message_feedback"
  as permissive
  for select
  to public
using ((auth.uid() = user_id));



  create policy "Users can insert messages in own conversations"
  on "public"."messages"
  as permissive
  for insert
  to public
with check ((auth.uid() IN ( SELECT conversations.user_id
   FROM public.conversations
  WHERE (conversations.id = messages.conversation_id))));



  create policy "Users can view messages in own conversations"
  on "public"."messages"
  as permissive
  for select
  to public
using ((auth.uid() IN ( SELECT conversations.user_id
   FROM public.conversations
  WHERE (conversations.id = messages.conversation_id))));



  create policy "System can insert evaluations"
  on "public"."profile_evaluations"
  as permissive
  for insert
  to public
with check (true);



  create policy "Users can view own evaluations"
  on "public"."profile_evaluations"
  as permissive
  for select
  to public
using ((auth.uid() = user_id));



  create policy "Service role can manage profiles"
  on "public"."profiles"
  as permissive
  for all
  to public
using ((auth.role() = 'service_role'::text));



  create policy "Users can insert own profile"
  on "public"."profiles"
  as permissive
  for insert
  to public
with check (((auth.uid() = id) OR (auth.role() = 'service_role'::text)));



  create policy "Users can update own profile"
  on "public"."profiles"
  as permissive
  for update
  to public
using (((auth.uid() = id) OR (auth.role() = 'service_role'::text)));



  create policy "Users can view own profile"
  on "public"."profiles"
  as permissive
  for select
  to public
using (((auth.uid() = id) OR (auth.role() = 'service_role'::text)));



  create policy "Users can insert own subscription status"
  on "public"."subscription_status"
  as permissive
  for insert
  to public
with check ((auth.uid() = user_id));



  create policy "Users can update own subscription status"
  on "public"."subscription_status"
  as permissive
  for update
  to public
using ((auth.uid() = user_id));



  create policy "Users can view own subscription status"
  on "public"."subscription_status"
  as permissive
  for select
  to public
using ((auth.uid() = user_id));



  create policy "Users can insert own usage statistics"
  on "public"."usage_statistics"
  as permissive
  for insert
  to public
with check ((auth.uid() = user_id));



  create policy "Users can update own usage statistics"
  on "public"."usage_statistics"
  as permissive
  for update
  to public
using ((auth.uid() = user_id));



  create policy "Users can view own usage statistics"
  on "public"."usage_statistics"
  as permissive
  for select
  to public
using ((auth.uid() = user_id));



  create policy "Users can insert own user profile"
  on "public"."user_profiles"
  as permissive
  for insert
  to public
with check ((auth.uid() = user_id));



  create policy "Users can update own user profile"
  on "public"."user_profiles"
  as permissive
  for update
  to public
using ((auth.uid() = user_id));



  create policy "Users can view own user profile"
  on "public"."user_profiles"
  as permissive
  for select
  to public
using ((auth.uid() = user_id));


CREATE TRIGGER update_ai_personalities_updated_at BEFORE UPDATE ON public.ai_personalities FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_conversations_updated_at BEFORE UPDATE ON public.conversations FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER on_first_message_create_profile AFTER INSERT ON public.messages FOR EACH ROW EXECUTE FUNCTION public.initialize_user_profile();

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_subscription_status_updated_at BEFORE UPDATE ON public.subscription_status FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_usage_statistics_updated_at BEFORE UPDATE ON public.usage_statistics FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON public.user_profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


  create policy "authenticated upload own generated images"
  on "storage"."objects"
  as permissive
  for insert
  to authenticated
with check (((bucket_id = 'generated-images'::text) AND ((storage.foldername(name))[1] = (auth.uid())::text)));



  create policy "public read generated images"
  on "storage"."objects"
  as permissive
  for select
  to public
using ((bucket_id = 'generated-images'::text));
