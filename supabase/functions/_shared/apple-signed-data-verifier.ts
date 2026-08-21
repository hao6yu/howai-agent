import "npm:reflect-metadata@0.2.2";
import {
  BasicConstraintsExtension,
  X509Certificate,
} from "npm:@peculiar/x509@1.14.3";

import type { AppleTransactionPayload } from "./apple-entitlement.ts";

const APPLE_LEAF_REQUIRED_OID = "1.2.840.113635.100.6.11.1";
const APPLE_INTERMEDIATE_REQUIRED_OID = "1.2.840.113635.100.6.2.1";
const CERTIFICATE_DATE_SKEW_MS = 60_000;
const MAX_CERTIFICATE_BYTES = 16 * 1024;
const MAX_HEADER_BYTES = 16 * 1024;
const MAX_PAYLOAD_BYTES = 8 * 1024;

export type AppleSignedDataVerificationCode =
  | "invalid_algorithm"
  | "invalid_certificate"
  | "invalid_certificate_chain"
  | "invalid_certificate_date"
  | "invalid_certificate_purpose"
  | "invalid_chain_length"
  | "invalid_header"
  | "invalid_payload"
  | "invalid_signature"
  | "malformed_jws";

export class AppleSignedDataVerificationError extends Error {
  constructor(readonly code: AppleSignedDataVerificationCode) {
    super("App Store signed transaction verification failed.");
    this.name = "AppleSignedDataVerificationError";
  }
}

/**
 * Verifies an App Store compact JWS without relying on Node's X509Certificate.
 * The checks mirror Apple's offline SignedDataVerifier path: a three-entry x5c
 * header, a leaf/intermediate chain anchored to a configured Apple root, the
 * Apple certificate-purpose OIDs, certificate dates at signedDate, and the
 * ES256 JWS signature.
 */
export async function verifyAndDecodeAppleTransaction(
  signedTransaction: string,
  trustedRootCertificates: readonly string[],
): Promise<AppleTransactionPayload> {
  const parts = signedTransaction.split(".");
  if (parts.length !== 3 || parts.some((part) => part.length === 0)) {
    throw new AppleSignedDataVerificationError("malformed_jws");
  }

  const header = decodeJsonSegment(
    parts[0],
    MAX_HEADER_BYTES,
    "invalid_header",
  );
  if (header.alg !== "ES256") {
    throw new AppleSignedDataVerificationError("invalid_algorithm");
  }

  const chain = header.x5c;
  if (!Array.isArray(chain) || chain.length !== 3) {
    throw new AppleSignedDataVerificationError("invalid_chain_length");
  }
  if (chain.some((certificate) => typeof certificate !== "string")) {
    throw new AppleSignedDataVerificationError("invalid_certificate");
  }

  const payload = decodeJsonSegment(
    parts[1],
    MAX_PAYLOAD_BYTES,
    "invalid_payload",
  ) as AppleTransactionPayload;
  const signedDate = requiredSignedDate(payload.signedDate);

  let leaf: X509Certificate;
  let intermediate: X509Certificate;
  let roots: X509Certificate[];
  try {
    leaf = new X509Certificate(decodeCertificate(chain[0] as string));
    intermediate = new X509Certificate(decodeCertificate(chain[1] as string));
    // Decode the third x5c entry to enforce a bounded, well-formed certificate
    // header. Trust still comes exclusively from the configured root set.
    new X509Certificate(decodeCertificate(chain[2] as string));
    roots = trustedRootCertificates.map((certificate) =>
      new X509Certificate(decodeCertificate(certificate))
    );
  } catch (error) {
    if (error instanceof AppleSignedDataVerificationError) throw error;
    throw new AppleSignedDataVerificationError("invalid_certificate");
  }

  if (roots.length === 0) {
    throw new AppleSignedDataVerificationError("invalid_certificate_chain");
  }

  const root = await findSigningRoot(intermediate, roots);
  if (
    root == null ||
    leaf.issuer !== intermediate.subject ||
    !await leaf.verify({
      publicKey: intermediate.publicKey,
      signatureOnly: true,
    })
  ) {
    throw new AppleSignedDataVerificationError("invalid_certificate_chain");
  }

  const intermediateConstraints = intermediate.getExtension(
    BasicConstraintsExtension,
  );
  if (
    intermediateConstraints?.ca !== true ||
    leaf.getExtension(APPLE_LEAF_REQUIRED_OID) == null ||
    intermediate.getExtension(APPLE_INTERMEDIATE_REQUIRED_OID) == null
  ) {
    throw new AppleSignedDataVerificationError("invalid_certificate_purpose");
  }

  if (
    !certificateValidAt(leaf, signedDate) ||
    !certificateValidAt(intermediate, signedDate) ||
    !certificateValidAt(root, signedDate)
  ) {
    throw new AppleSignedDataVerificationError("invalid_certificate_date");
  }

  const leafAlgorithm = leaf.publicKey.algorithm as EcKeyAlgorithm;
  if (
    leafAlgorithm.name !== "ECDSA" || leafAlgorithm.namedCurve !== "P-256"
  ) {
    throw new AppleSignedDataVerificationError("invalid_certificate");
  }

  const signature = decodeBase64Url(parts[2], 64, "invalid_signature");
  if (signature.byteLength !== 64) {
    throw new AppleSignedDataVerificationError("invalid_signature");
  }

  let publicKey: CryptoKey;
  try {
    publicKey = await leaf.publicKey.export(
      { name: "ECDSA", namedCurve: "P-256" },
      ["verify"],
    );
  } catch {
    throw new AppleSignedDataVerificationError("invalid_certificate");
  }

  const signatureValid = await crypto.subtle.verify(
    { name: "ECDSA", hash: "SHA-256" },
    publicKey,
    signature,
    new TextEncoder().encode(`${parts[0]}.${parts[1]}`),
  );
  if (!signatureValid) {
    throw new AppleSignedDataVerificationError("invalid_signature");
  }

  return Object.freeze(payload);
}

async function findSigningRoot(
  intermediate: X509Certificate,
  roots: readonly X509Certificate[],
): Promise<X509Certificate | null> {
  for (const root of roots) {
    if (
      intermediate.issuer === root.subject &&
      await intermediate.verify({
        publicKey: root.publicKey,
        signatureOnly: true,
      })
    ) {
      return root;
    }
  }
  return null;
}

function certificateValidAt(
  certificate: X509Certificate,
  date: Date,
): boolean {
  const time = date.getTime();
  return certificate.notBefore.getTime() <= time + CERTIFICATE_DATE_SKEW_MS &&
    certificate.notAfter.getTime() >= time - CERTIFICATE_DATE_SKEW_MS;
}

function requiredSignedDate(value: unknown): Date {
  if (typeof value !== "number" || !Number.isSafeInteger(value) || value <= 0) {
    throw new AppleSignedDataVerificationError("invalid_payload");
  }
  const result = new Date(value);
  if (!Number.isFinite(result.getTime())) {
    throw new AppleSignedDataVerificationError("invalid_payload");
  }
  return result;
}

function decodeJsonSegment(
  value: string,
  maxBytes: number,
  code: "invalid_header" | "invalid_payload",
): Record<string, unknown> {
  try {
    const bytes = decodeBase64Url(value, maxBytes, code);
    const decoded = JSON.parse(
      new TextDecoder("utf-8", { fatal: true }).decode(bytes),
    );
    if (
      decoded == null || typeof decoded !== "object" || Array.isArray(decoded)
    ) {
      throw new Error("Expected a JSON object.");
    }
    return decoded as Record<string, unknown>;
  } catch (error) {
    if (error instanceof AppleSignedDataVerificationError) throw error;
    throw new AppleSignedDataVerificationError(code);
  }
}

function decodeBase64Url(
  value: string,
  maxBytes: number,
  code: AppleSignedDataVerificationCode,
): Uint8Array<ArrayBuffer> {
  if (
    value.length === 0 || value.length > maxEncodedLength(maxBytes) ||
    !/^[A-Za-z0-9_-]+$/.test(value) || value.length % 4 === 1
  ) {
    throw new AppleSignedDataVerificationError(code);
  }
  return decodeBase64(
    value.replaceAll("-", "+").replaceAll("_", "/"),
    maxBytes,
    code,
  );
}

function decodeCertificate(value: string): Uint8Array<ArrayBuffer> {
  if (
    value.length === 0 ||
    value.length > maxEncodedLength(MAX_CERTIFICATE_BYTES) ||
    !/^[A-Za-z0-9+/]+={0,2}$/.test(value)
  ) {
    throw new AppleSignedDataVerificationError("invalid_certificate");
  }
  return decodeBase64(
    value.replace(/=+$/, ""),
    MAX_CERTIFICATE_BYTES,
    "invalid_certificate",
  );
}

function decodeBase64(
  unpadded: string,
  maxBytes: number,
  code: AppleSignedDataVerificationCode,
): Uint8Array<ArrayBuffer> {
  try {
    const padded = unpadded.padEnd(Math.ceil(unpadded.length / 4) * 4, "=");
    const binary = atob(padded);
    const decoded = new Uint8Array(new ArrayBuffer(binary.length));
    for (let index = 0; index < binary.length; index++) {
      decoded[index] = binary.charCodeAt(index);
    }
    if (decoded.byteLength === 0 || decoded.byteLength > maxBytes) {
      throw new AppleSignedDataVerificationError(code);
    }
    return decoded;
  } catch (error) {
    if (error instanceof AppleSignedDataVerificationError) throw error;
    throw new AppleSignedDataVerificationError(code);
  }
}

function maxEncodedLength(maxBytes: number): number {
  return Math.ceil(maxBytes / 3) * 4;
}
