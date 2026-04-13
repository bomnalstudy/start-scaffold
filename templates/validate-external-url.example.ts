const ALLOWED_PROTOCOLS = new Set(["https:"]);

export function validateExternalUrl(input: string): URL {
  const url = new URL(input);

  if (!ALLOWED_PROTOCOLS.has(url.protocol)) {
    throw new Error("Unsupported URL protocol.");
  }

  return url;
}
