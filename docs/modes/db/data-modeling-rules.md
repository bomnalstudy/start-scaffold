# Data Modeling Rules

Use these rules when shaping tables, entities, or persistent records.

## Ownership

- Every user-affecting record must have a clear owner or access rule.
- Do not leave cross-user visibility implied.
- If ownership is shared, name the join or membership model explicitly.

## Structure

- Prefer explicit entities over one giant catch-all record.
- Keep hot-path fields easy to query.
- Separate derived or computed data from canonical stored data when possible.
- Make nullable fields intentional, not accidental.
- Prefer a small number of focused models over a fake universal model that mixes domains.

## Evolution

- Prefer additive schema changes before destructive reshaping.
- Name migration concerns early if the design changes existing semantics.
- Do not overload one column or blob field with multiple unrelated responsibilities.

## Query Fit

- Model for the read and write paths you actually expect.
- Name likely indexes, filters, sort keys, and pagination anchors early.
- Avoid forcing every query through full scans or oversized payloads by default.

## Relationship Clarity

- Make one-to-one, one-to-many, and many-to-many relationships explicit.
- Prefer a real join or membership model when the relationship carries meaning or permissions.
- Keep foreign key intent understandable from the design, not hidden behind application-only conventions.
- If the relationship carries metadata, ordering, or audit meaning, the relationship should be its own model.
