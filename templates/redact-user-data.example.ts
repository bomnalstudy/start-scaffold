type RedactableValue = string | number | null | undefined;

export function redactUserData(value: RedactableValue, visibleTail = 2): string {
  if (value === null || value === undefined) {
    return "[REDACTED]";
  }

  const text = String(value);
  if (text.length <= visibleTail) {
    return "[REDACTED]";
  }

  return `${"*".repeat(Math.max(4, text.length - visibleTail))}${text.slice(-visibleTail)}`;
}
