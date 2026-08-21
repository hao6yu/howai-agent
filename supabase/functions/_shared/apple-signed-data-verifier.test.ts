import "npm:reflect-metadata@0.2.2";
import assert from "node:assert/strict";
import {
  BasicConstraintsExtension,
  Extension,
  X509Certificate,
  X509CertificateGenerator,
} from "npm:@peculiar/x509@1.14.3";

import {
  AppleSignedDataVerificationError,
  verifyAndDecodeAppleTransaction,
} from "./apple-signed-data-verifier.ts";

const APPLE_LEAF_REQUIRED_OID = "1.2.840.113635.100.6.11.1";
const APPLE_INTERMEDIATE_REQUIRED_OID = "1.2.840.113635.100.6.2.1";
const SIGNED_DATE = Date.parse("2026-08-20T12:00:00.000Z");

type TestChain = Readonly<{
  intermediate: X509Certificate;
  leaf: X509Certificate;
  leafPrivateKey: CryptoKey;
  root: X509Certificate;
}>;

type TestChainOptions = Readonly<{
  includeIntermediatePurpose?: boolean;
  includeLeafPurpose?: boolean;
  notAfter?: Date;
  notBefore?: Date;
}>;

Deno.test("verifies a valid Apple-style ES256 transaction chain", async () => {
  const chain = await createTestChain();
  const payload = transaction();
  const signedTransaction = await signTransaction(chain, payload);

  assert.deepEqual(
    await verifyAndDecodeAppleTransaction(signedTransaction, [
      certificateBase64(chain.root),
    ]),
    payload,
  );
});

Deno.test("rejects a transaction whose signed payload was tampered", async () => {
  const chain = await createTestChain();
  const signedTransaction = await signTransaction(chain, transaction());
  const parts = signedTransaction.split(".");
  parts[1] = base64UrlJson(transaction({ productId: "attacker.product" }));

  await assertVerificationCode(
    () =>
      verifyAndDecodeAppleTransaction(parts.join("."), [
        certificateBase64(chain.root),
      ]),
    "invalid_signature",
  );
});

Deno.test("rejects a certificate chain not anchored to a trusted root", async () => {
  const chain = await createTestChain();
  const otherChain = await createTestChain();
  const signedTransaction = await signTransaction(chain, transaction());

  await assertVerificationCode(
    () =>
      verifyAndDecodeAppleTransaction(signedTransaction, [
        certificateBase64(otherChain.root),
      ]),
    "invalid_certificate_chain",
  );
});

Deno.test("requires Apple's leaf and intermediate certificate-purpose OIDs", async () => {
  for (
    const options of [
      { includeLeafPurpose: false },
      { includeIntermediatePurpose: false },
    ]
  ) {
    const chain = await createTestChain(options);
    const signedTransaction = await signTransaction(chain, transaction());

    await assertVerificationCode(
      () =>
        verifyAndDecodeAppleTransaction(signedTransaction, [
          certificateBase64(chain.root),
        ]),
      "invalid_certificate_purpose",
    );
  }
});

Deno.test("checks certificate validity at the transaction signed date", async () => {
  const chain = await createTestChain({
    notAfter: new Date(SIGNED_DATE - 2 * 60_000),
    notBefore: new Date(SIGNED_DATE - 24 * 60 * 60_000),
  });
  const signedTransaction = await signTransaction(chain, transaction());

  await assertVerificationCode(
    () =>
      verifyAndDecodeAppleTransaction(signedTransaction, [
        certificateBase64(chain.root),
      ]),
    "invalid_certificate_date",
  );
});

Deno.test("requires ES256 and exactly three x5c certificates", async () => {
  const chain = await createTestChain();
  const trustedRoots = [certificateBase64(chain.root)];

  await assertVerificationCode(
    async () =>
      verifyAndDecodeAppleTransaction(
        await signTransaction(chain, transaction(), { algorithm: "ES384" }),
        trustedRoots,
      ),
    "invalid_algorithm",
  );
  await assertVerificationCode(
    async () =>
      verifyAndDecodeAppleTransaction(
        await signTransaction(chain, transaction(), { chainLength: 2 }),
        trustedRoots,
      ),
    "invalid_chain_length",
  );
});

async function createTestChain(
  options: TestChainOptions = {},
): Promise<TestChain> {
  const notBefore = options.notBefore ??
    new Date(SIGNED_DATE - 24 * 60 * 60_000);
  const notAfter = options.notAfter ?? new Date(SIGNED_DATE + 24 * 60 * 60_000);
  // Deno 2.1 (the release-gate runtime) cannot sign P-384 test
  // certificates. P-256 still exercises the same chain-validation path.
  const rootKeys = await generateEcKeys("P-256");
  const root = await X509CertificateGenerator.createSelfSigned({
    name: "CN=Test Apple Root",
    keys: rootKeys,
    notBefore,
    notAfter,
    extensions: [new BasicConstraintsExtension(true, 1, true)],
  });

  const intermediateKeys = await generateEcKeys("P-256");
  const intermediateExtensions: Extension[] = [
    new BasicConstraintsExtension(true, 0, true),
  ];
  if (options.includeIntermediatePurpose !== false) {
    intermediateExtensions.push(
      purposeExtension(APPLE_INTERMEDIATE_REQUIRED_OID),
    );
  }
  const intermediate = await X509CertificateGenerator.create({
    subject: "CN=Test Apple Intermediate",
    issuer: root.subject,
    publicKey: intermediateKeys.publicKey,
    signingKey: rootKeys.privateKey,
    notBefore,
    notAfter,
    extensions: intermediateExtensions,
  });

  const leafKeys = await generateEcKeys("P-256");
  const leafExtensions: Extension[] = [];
  if (options.includeLeafPurpose !== false) {
    leafExtensions.push(purposeExtension(APPLE_LEAF_REQUIRED_OID));
  }
  const leaf = await X509CertificateGenerator.create({
    subject: "CN=Test Apple Signing",
    issuer: intermediate.subject,
    publicKey: leafKeys.publicKey,
    signingKey: intermediateKeys.privateKey,
    notBefore,
    notAfter,
    extensions: leafExtensions,
  });

  return {
    intermediate,
    leaf,
    leafPrivateKey: leafKeys.privateKey,
    root,
  };
}

async function signTransaction(
  chain: TestChain,
  payload: Record<string, unknown>,
  options: Readonly<{ algorithm?: string; chainLength?: number }> = {},
): Promise<string> {
  const x5c = [chain.leaf, chain.intermediate, chain.root]
    .slice(0, options.chainLength ?? 3)
    .map(certificateBase64);
  const header = base64UrlJson({
    alg: options.algorithm ?? "ES256",
    x5c,
  });
  const encodedPayload = base64UrlJson(payload);
  const signingInput = `${header}.${encodedPayload}`;
  const signature = await crypto.subtle.sign(
    { name: "ECDSA", hash: "SHA-256" },
    chain.leafPrivateKey,
    new TextEncoder().encode(signingInput),
  );
  return `${signingInput}.${base64UrlBytes(new Uint8Array(signature))}`;
}

function transaction(overrides: Record<string, unknown> = {}) {
  return {
    bundleId: "com.hyu.HaoGPT",
    environment: "Production",
    expiresDate: SIGNED_DATE + 30 * 24 * 60 * 60_000,
    originalTransactionId: "2000000123456789",
    productId: "com.haoyu.HaoGPT.premium.yearly",
    signedDate: SIGNED_DATE,
    transactionId: "2000000123456790",
    type: "Auto-Renewable Subscription",
    ...overrides,
  };
}

function purposeExtension(oid: string): Extension {
  return new Extension(oid, false, new Uint8Array([0x05, 0x00]));
}

async function generateEcKeys(
  namedCurve: "P-256" | "P-384",
): Promise<CryptoKeyPair> {
  return await crypto.subtle.generateKey(
    { name: "ECDSA", namedCurve },
    true,
    ["sign", "verify"],
  );
}

function certificateBase64(certificate: X509Certificate): string {
  return base64Bytes(new Uint8Array(certificate.rawData));
}

function base64UrlJson(value: Record<string, unknown>): string {
  return base64UrlBytes(new TextEncoder().encode(JSON.stringify(value)));
}

function base64UrlBytes(value: Uint8Array): string {
  return base64Bytes(value)
    .replaceAll("+", "-")
    .replaceAll("/", "_")
    .replaceAll("=", "");
}

function base64Bytes(value: Uint8Array): string {
  let result = "";
  for (const byte of value) result += String.fromCharCode(byte);
  return btoa(result);
}

async function assertVerificationCode(
  operation: () => Promise<unknown>,
  code: AppleSignedDataVerificationError["code"],
): Promise<void> {
  await assert.rejects(
    operation,
    (error: unknown) =>
      error instanceof AppleSignedDataVerificationError && error.code === code,
  );
}
