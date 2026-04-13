type UserProfileInput = {
  displayName?: string;
  locale?: string;
};

export function mapRequestFields(input: Record<string, unknown>): UserProfileInput {
  return {
    displayName: typeof input.displayName === "string" ? input.displayName : undefined,
    locale: typeof input.locale === "string" ? input.locale : undefined,
  };
}
