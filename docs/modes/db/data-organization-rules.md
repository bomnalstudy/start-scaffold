# Data Organization Rules

Use these rules when deciding how to group, name, and separate related data.

## Group By Domain Meaning

- Group records by business meaning and lifecycle, not only by screen or endpoint convenience.
- Keep data that changes together and is governed by the same ownership rules close in the model.
- Split data when retention, permissions, volatility, or query shape are meaningfully different.

## Canonical Vs Derived Data

- Keep one canonical source for a fact when possible.
- Separate cached, denormalized, or derived data from canonical records.
- If derived data is stored, name how it is refreshed and which canonical fields it depends on.

## Relationship Structure

- Make join or membership models explicit when the relationship has metadata, permissions, ordering, or audit meaning.
- Use simpler implicit relationships only when the relationship itself has no additional meaning.
- Do not hide a meaningful many-to-many relationship in a generic array or blob field.

## Naming And Namespaces

- Keep model, table, and DTO names readable and stable.
- Use schema or folder namespaces only when they clarify domain separation, not to look architectural.
- If multiple domains share a database, define where each domain begins and ends before adding cross-domain joins.

## Reuse Boundaries

- Reuse shared identifiers and reference patterns consistently.
- Reuse API schema components when contracts truly match, but do not force unrelated entities into one generic payload shape.
- Prefer a small number of clear types over one oversized "universal" record.
