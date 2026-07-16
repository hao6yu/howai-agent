import {
  extractResponsesUsage,
  type ResponsesUsage,
} from "./openai-stream.ts";

export type AutomationModelPhase = "generation" | "verification";

export type AutomationSource = Readonly<{
  id: string;
  title: string;
  url: string;
  domain: string;
}>;

export type AutomationReportResult = Readonly<{
  status: "succeeded" | "withheld";
  messageContent: string;
  preview: string;
  report: Record<string, unknown>;
  claims: readonly Record<string, unknown>[];
  sources: readonly AutomationSource[];
  verification: Record<string, unknown>;
  generationResponseId: string | null;
  verificationResponseId: string | null;
  generationLedgerId: string | null;
  verificationLedgerId: string | null;
}>;

export class AutomationReportError extends Error {
  constructor(
    message: string,
    readonly code: string,
    readonly transient: boolean,
  ) {
    super(message);
    this.name = "AutomationReportError";
  }
}

type AutomationReportInput = Readonly<{
  runId: string;
  userId: string;
  scheduledFor: string;
  template: Record<string, unknown>;
}>;

type AutomationReportDependencies = Readonly<{
  apiKey: string;
  model: string;
  fetcher?: typeof fetch;
  reserve?: (phase: AutomationModelPhase) => Promise<{
    requestId: string;
    ledgerId: string;
  }>;
  reconcile?: (input: {
    phase: AutomationModelPhase;
    requestId: string;
    succeeded: boolean;
    usage: ResponsesUsage | null;
    failureCode: string | null;
  }) => Promise<void>;
}>;

type ModelCallResult = Readonly<{
  body: Record<string, unknown>;
  usage: ResponsesUsage;
  requestId: string | null;
  ledgerId: string | null;
}>;

type ParsedVerification = Readonly<{
  status: "pass" | "withhold";
  summary: string;
  preview: string;
  issues: string[];
  claims: Array<{
    text: string;
    supported: boolean;
    source_urls: string[];
  }>;
}>;

const OPENAI_RESPONSES_URL = "https://api.openai.com/v1/responses";
const MAX_SOURCES = 12;

export async function buildVerifiedAutomationReport(
  input: AutomationReportInput,
  dependencies: AutomationReportDependencies,
): Promise<AutomationReportResult> {
  if (!dependencies.apiKey || !dependencies.model) {
    throw new AutomationReportError(
      "Automation model access is not configured.",
      "automation_model_unconfigured",
      false,
    );
  }

  const template = parseTemplate(input.template);
  if (template.kind !== "news_briefing") {
    throw new AutomationReportError(
      "Structured market data is not enabled for this Automation.",
      "market_data_not_enabled",
      false,
    );
  }

  const searchTool = buildSearchTool(template.sourcePolicy);
  const generation = await callResponsesApi({
    phase: "generation",
    input,
    dependencies,
    payload: {
      model: dependencies.model,
      store: false,
      safety_identifier: input.userId,
      reasoning: { effort: "low" },
      max_output_tokens: 1_600,
      tools: [searchTool],
      tool_choice: "required",
      include: ["web_search_call.action.sources"],
      instructions: generationInstructions(template),
      input: generationRequest(template, input.scheduledFor),
    },
  });

  const draft = extractOutputText(generation.body).trim();
  const sources = extractSources(generation.body);
  const deterministicIssues = validateGeneration(
    draft,
    sources,
    generation.usage,
    template.sourcePolicy,
  );
  if (deterministicIssues.length > 0) {
    return withheldResult({
      template,
      reason: "The source checks did not pass.",
      issues: deterministicIssues,
      sources,
      generation,
    });
  }

  const verification = await callResponsesApi({
    phase: "verification",
    input,
    dependencies,
    payload: {
      model: dependencies.model,
      store: false,
      safety_identifier: input.userId,
      reasoning: { effort: "low" },
      max_output_tokens: 1_200,
      tools: [searchTool],
      tool_choice: "required",
      include: ["web_search_call.action.sources"],
      instructions: verificationInstructions(),
      input: JSON.stringify({
        scheduled_for: input.scheduledFor,
        title: template.title,
        requested_topics: template.config.topics,
        freshness_hours: template.sourcePolicy.freshness_hours,
        require_primary_sources:
          template.sourcePolicy.require_primary_sources,
        draft,
        sources,
      }),
      text: {
        format: {
          type: "json_schema",
          name: "automation_verification",
          strict: true,
          schema: verificationSchema(),
        },
      },
    },
  });

  const parsed = parseVerification(extractOutputText(verification.body));
  const verificationIssues = validateVerification(parsed, sources);
  const passed = parsed.status === "pass" && verificationIssues.length === 0;
  if (!passed) {
    return withheldResult({
      template,
      reason: parsed.summary,
      issues: [...parsed.issues, ...verificationIssues],
      sources,
      generation,
      verification,
      claims: parsed.claims,
    });
  }

  const messageContent = appendSources(draft, sources);
  return {
    status: "succeeded",
    messageContent,
    preview: previewText(parsed.preview || draft),
    report: {
      kind: template.kind,
      title: template.title,
      scheduled_for: input.scheduledFor,
      content: draft,
    },
    claims: parsed.claims,
    sources,
    verification: {
      status: "pass",
      summary: parsed.summary,
      issues: [],
    },
    generationResponseId: generation.usage.responseId,
    verificationResponseId: verification.usage.responseId,
    generationLedgerId: generation.ledgerId,
    verificationLedgerId: verification.ledgerId,
  };
}

async function callResponsesApi(input: {
  phase: AutomationModelPhase;
  input: AutomationReportInput;
  dependencies: AutomationReportDependencies;
  payload: Record<string, unknown>;
}): Promise<ModelCallResult> {
  const reservation = input.dependencies.reserve
    ? await input.dependencies.reserve(input.phase)
    : null;
  const fetcher = input.dependencies.fetcher ?? fetch;
  let response: Response;
  try {
    response = await fetcher(OPENAI_RESPONSES_URL, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${input.dependencies.apiKey}`,
        "Content-Type": "application/json",
        "X-Client-Request-Id": `${input.input.runId}-${input.phase}`,
      },
      body: JSON.stringify(input.payload),
    });
  } catch (error) {
    await reconcileSafely(input, reservation?.requestId ?? null, false, null, "network_error");
    throw new AutomationReportError(
      safeErrorMessage(error),
      "openai_network_error",
      true,
    );
  }

  const body = await readJson(response);
  if (!response.ok || !isRecord(body)) {
    const code = `openai_http_${response.status}`;
    await reconcileSafely(input, reservation?.requestId ?? null, false, null, code);
    throw new AutomationReportError(
      upstreamErrorMessage(body, response.status),
      code,
      response.status === 408 || response.status === 409 ||
        response.status === 429 || response.status >= 500,
    );
  }

  const usage = extractResponsesUsage(body);
  if (!usage.hasFinalOutput) {
    await reconcileSafely(
      input,
      reservation?.requestId ?? null,
      false,
      usage,
      "missing_final_output",
    );
    throw new AutomationReportError(
      "The model did not return a completed report.",
      "missing_final_output",
      true,
    );
  }
  await reconcileSafely(
    input,
    reservation?.requestId ?? null,
    true,
    usage,
    null,
  );
  return {
    body,
    usage,
    requestId: reservation?.requestId ?? null,
    ledgerId: reservation?.ledgerId ?? null,
  };
}

async function reconcileSafely(
  input: Parameters<typeof callResponsesApi>[0],
  requestId: string | null,
  succeeded: boolean,
  usage: ResponsesUsage | null,
  failureCode: string | null,
): Promise<void> {
  if (!requestId || !input.dependencies.reconcile) return;
  await input.dependencies.reconcile({
    phase: input.phase,
    requestId,
    succeeded,
    usage,
    failureCode,
  });
}

function generationInstructions(template: ParsedTemplate): string {
  const language = template.config.language === "auto"
    ? "Use the language or natural language mix that best fits the request. Do not force a single language."
    : `Prefer ${template.config.language}, while preserving names and necessary source wording.`;
  return [
    "You prepare a scheduled HowAI briefing using live web search.",
    "Never invent a fact, date, quotation, price, or source.",
    "Use exact dates and clearly distinguish reporting from analysis.",
    "Prefer primary and authoritative sources; corroborate material claims.",
    `Keep the result ${template.config.summary_style} and useful on a phone.`,
    language,
    "Write the briefing only. Do not add a Sources section; the service adds verified links.",
  ].join("\n");
}

function generationRequest(
  template: ParsedTemplate,
  scheduledFor: string,
): string {
  const topics = template.config.topics.join(", ");
  const region = template.config.region ? ` Region: ${template.config.region}.` : "";
  return `As of ${scheduledFor}, prepare “${template.title}”. Cover ${topics}.${region} Return the ${template.config.item_count} most important fresh items from roughly the last ${template.sourcePolicy.freshness_hours} hours. Each item needs a concise headline, what happened, and why it matters.`;
}

function verificationInstructions(): string {
  return [
    "You are the independent verification pass for a scheduled briefing.",
    "Use live web search to check the draft's material claims, dates, and source quality.",
    "Fail closed: choose withhold if a meaningful claim is stale, conflicting, unsupported, misleading, or only backed by an untrustworthy source.",
    "A pass requires at least two credible sources overall and at least one cited source URL for every returned material claim.",
    "Return only the requested JSON schema. Never rewrite unsupported content into a pass.",
  ].join("\n");
}

function verificationSchema(): Record<string, unknown> {
  return {
    type: "object",
    additionalProperties: false,
    required: ["status", "summary", "preview", "issues", "claims"],
    properties: {
      status: { type: "string", enum: ["pass", "withhold"] },
      summary: { type: "string", maxLength: 500 },
      preview: { type: "string", maxLength: 220 },
      issues: {
        type: "array",
        maxItems: 10,
        items: { type: "string", maxLength: 300 },
      },
      claims: {
        type: "array",
        minItems: 1,
        maxItems: 20,
        items: {
          type: "object",
          additionalProperties: false,
          required: ["text", "supported", "source_urls"],
          properties: {
            text: { type: "string", maxLength: 500 },
            supported: { type: "boolean" },
            source_urls: {
              type: "array",
              maxItems: 6,
              items: { type: "string", maxLength: 2_000 },
            },
          },
        },
      },
    },
  };
}

function buildSearchTool(
  sourcePolicy: Record<string, unknown>,
): Record<string, unknown> {
  const preferred = stringArray(sourcePolicy.preferred_domains);
  return {
    type: "web_search",
    search_context_size: "medium",
    external_web_access: true,
    ...(preferred.length > 0
      ? { filters: { allowed_domains: preferred } }
      : {}),
  };
}

function extractOutputText(response: Record<string, unknown>): string {
  if (typeof response.output_text === "string") return response.output_text;
  if (!Array.isArray(response.output)) return "";
  const chunks: string[] = [];
  for (const item of response.output) {
    if (!isRecord(item) || item.type !== "message" || !Array.isArray(item.content)) continue;
    for (const content of item.content) {
      if (isRecord(content) && content.type === "output_text" && typeof content.text === "string") {
        chunks.push(content.text);
      }
    }
  }
  return chunks.join("\n");
}

function extractSources(response: Record<string, unknown>): AutomationSource[] {
  const candidates: Array<{ title: string; url: string }> = [];
  if (Array.isArray(response.output)) {
    for (const item of response.output) {
      if (!isRecord(item)) continue;
      if (item.type === "web_search_call" && isRecord(item.action) && Array.isArray(item.action.sources)) {
        for (const source of item.action.sources) {
          if (!isRecord(source) || typeof source.url !== "string") continue;
          candidates.push({
            url: source.url,
            title: typeof source.title === "string" ? source.title : source.url,
          });
        }
      }
      if (item.type === "message" && Array.isArray(item.content)) {
        for (const content of item.content) {
          if (!isRecord(content) || !Array.isArray(content.annotations)) continue;
          for (const annotation of content.annotations) {
            if (!isRecord(annotation) || annotation.type !== "url_citation" || typeof annotation.url !== "string") continue;
            candidates.push({
              url: annotation.url,
              title: typeof annotation.title === "string" ? annotation.title : annotation.url,
            });
          }
        }
      }
    }
  }
  const seen = new Set<string>();
  const result: AutomationSource[] = [];
  for (const candidate of candidates) {
    let parsed: URL;
    try {
      parsed = new URL(candidate.url);
    } catch {
      continue;
    }
    const normalized = parsed.toString();
    if (seen.has(normalized)) continue;
    seen.add(normalized);
    result.push({
      id: `source_${result.length + 1}`,
      title: candidate.title.trim().slice(0, 300) || parsed.hostname,
      url: normalized,
      domain: parsed.hostname.toLowerCase(),
    });
    if (result.length >= MAX_SOURCES) break;
  }
  return result;
}

function validateGeneration(
  draft: string,
  sources: readonly AutomationSource[],
  usage: ResponsesUsage,
  sourcePolicy: Record<string, unknown>,
): string[] {
  const issues: string[] = [];
  if (draft.length < 80) issues.push("briefing_too_short");
  if (usage.webSearchCalls < 1) issues.push("web_search_not_completed");
  if (!usage.hasWebSearchCitations) issues.push("citations_missing");
  if (sources.length < 2) issues.push("insufficient_sources");
  const excluded = stringArray(sourcePolicy.excluded_domains);
  for (const source of sources) {
    if (!source.url.startsWith("https://")) issues.push("non_https_source");
    if (excluded.some((domain) => source.domain === domain || source.domain.endsWith(`.${domain}`))) {
      issues.push("excluded_source_domain");
    }
  }
  return [...new Set(issues)];
}

function parseVerification(value: string): ParsedVerification {
  let parsed: unknown;
  try {
    parsed = JSON.parse(value);
  } catch {
    throw new AutomationReportError(
      "The verification response was not valid JSON.",
      "invalid_verification_output",
      true,
    );
  }
  if (!isRecord(parsed) || (parsed.status !== "pass" && parsed.status !== "withhold") ||
    typeof parsed.summary !== "string" || typeof parsed.preview !== "string" ||
    !Array.isArray(parsed.issues) || !Array.isArray(parsed.claims)) {
    throw new AutomationReportError(
      "The verification response did not match its contract.",
      "invalid_verification_output",
      true,
    );
  }
  const claims = parsed.claims.map((claim) => {
    if (!isRecord(claim) || typeof claim.text !== "string" ||
      typeof claim.supported !== "boolean" || !Array.isArray(claim.source_urls) ||
      claim.source_urls.some((url) => typeof url !== "string")) {
      throw new AutomationReportError(
        "The verification claims did not match their contract.",
        "invalid_verification_output",
        true,
      );
    }
    return {
      text: claim.text,
      supported: claim.supported,
      source_urls: claim.source_urls as string[],
    };
  });
  return {
    status: parsed.status,
    summary: parsed.summary,
    preview: parsed.preview,
    issues: parsed.issues.filter((issue): issue is string => typeof issue === "string"),
    claims,
  };
}

function validateVerification(
  verification: ParsedVerification,
  sources: readonly AutomationSource[],
): string[] {
  const known = new Set(sources.map((source) => source.url));
  const issues: string[] = [];
  if (verification.claims.length === 0) issues.push("verification_claims_missing");
  if (verification.issues.length > 0) issues.push("verification_reported_issues");
  for (const claim of verification.claims) {
    if (!claim.supported) issues.push("unsupported_claim");
    if (claim.source_urls.length === 0) issues.push("claim_source_missing");
    if (claim.source_urls.some((url) => !known.has(url))) issues.push("claim_source_not_in_generation");
  }
  return [...new Set(issues)];
}

function appendSources(
  draft: string,
  sources: readonly AutomationSource[],
): string {
  const links = sources.map((source) =>
    `- [${escapeMarkdown(source.title)}](${source.url})`
  );
  return `${draft.trim()}\n\n### Sources\n\n${links.join("\n")}`;
}

function withheldResult(input: {
  template: ParsedTemplate;
  reason: string;
  issues: readonly string[];
  sources: readonly AutomationSource[];
  generation: ModelCallResult;
  verification?: ModelCallResult;
  claims?: readonly Record<string, unknown>[];
}): AutomationReportResult {
  const message = `I ran “${input.template.title}”, but I couldn't verify the results well enough to send them confidently. I’ll try again at the next scheduled time.`;
  return {
    status: "withheld",
    messageContent: message,
    preview: previewText(message),
    report: {
      kind: input.template.kind,
      title: input.template.title,
      withheld: true,
    },
    claims: input.claims ?? [],
    sources: input.sources,
    verification: {
      status: "withhold",
      summary: input.reason.slice(0, 500),
      issues: [...new Set(input.issues)].slice(0, 20),
    },
    generationResponseId: input.generation.usage.responseId,
    verificationResponseId: input.verification?.usage.responseId ?? null,
    generationLedgerId: input.generation.ledgerId,
    verificationLedgerId: input.verification?.ledgerId ?? null,
  };
}

type ParsedTemplate = Readonly<{
  kind: "news_briefing" | "market_briefing";
  title: string;
  config: Record<string, unknown> & {
    topics: string[];
    item_count: number;
    region: string | null;
    language: string;
    summary_style: string;
  };
  sourcePolicy: Record<string, unknown>;
}>;

function parseTemplate(value: Record<string, unknown>): ParsedTemplate {
  const kind = value.kind;
  const config = isRecord(value.config) ? value.config : {};
  const sourcePolicy = isRecord(value.source_policy) ? value.source_policy : {};
  if ((kind !== "news_briefing" && kind !== "market_briefing") ||
    typeof value.title !== "string") {
    throw new AutomationReportError(
      "The stored Automation template is invalid.",
      "invalid_automation_template",
      false,
    );
  }
  return {
    kind,
    title: value.title,
    config: {
      ...config,
      topics: stringArray(config.topics),
      item_count: integerOr(config.item_count, 5),
      region: typeof config.region === "string" ? config.region : null,
      language: typeof config.language === "string" ? config.language : "auto",
      summary_style: config.summary_style === "balanced" ? "balanced" : "concise",
    },
    sourcePolicy,
  };
}

function previewText(value: string): string {
  const compact = value.replace(/\[([^\]]+)\]\([^)]+\)/g, "$1")
    .replace(/[#*_`>\-]+/g, " ")
    .replace(/\s+/g, " ")
    .trim();
  return compact.length <= 180 ? compact : `${compact.slice(0, 177).trimEnd()}…`;
}

function escapeMarkdown(value: string): string {
  return value.replace(/[\\[\]]/g, "\\$&");
}

function integerOr(value: unknown, fallback: number): number {
  return Number.isInteger(value) ? Number(value) : fallback;
}

function stringArray(value: unknown): string[] {
  return Array.isArray(value)
    ? value.filter((item): item is string => typeof item === "string")
    : [];
}

async function readJson(response: Response): Promise<unknown> {
  try {
    return await response.json();
  } catch {
    return null;
  }
}

function upstreamErrorMessage(body: unknown, status: number): string {
  if (isRecord(body) && isRecord(body.error) && typeof body.error.message === "string") {
    return body.error.message.slice(0, 500);
  }
  return `OpenAI request failed with HTTP ${status}.`;
}

function safeErrorMessage(error: unknown): string {
  return error instanceof Error ? error.message.slice(0, 500) : "Network request failed.";
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
