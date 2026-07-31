# Prisma Coding Standards

For repos using Prisma, on top of `CODING_STANDARDS.md`. The Standards axis of `/code-review` checks the diff against both; a review that leaves one rule unflagged is incomplete.

## `@default(...)`

A schema default converts a **slot** into an **offer** (`CODING_STANDARDS.md` → Optionality): the caller may now omit the field, and the default stands in for a decision they never made.

Business values are slots — status, role, `isActive`, quotas, flags. Omit the default so the generated create type requires them.

Defaults are for the cases where exactly one value is ever correct and it isn't the caller's to choose:

- DB/ORM-managed columns — `@default(cuid())` / `@default(uuid())` / `@default(autoincrement())`, `@default(now())`, `@updatedAt`. The value is derived, not something a caller could sensibly pass.
- Context-independent constants carrying no business meaning (rare — e.g. a `schemaVersion` marker).
