export function authorizeOwnedResource(currentUserId: string, ownerUserId: string): void {
  if (currentUserId !== ownerUserId) {
    throw new Error("Not authorized to access this resource.");
  }
}
