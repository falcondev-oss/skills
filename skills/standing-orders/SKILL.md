---
name: standing-orders
description: "Standing orders — the default skills to reach for on this machine: ponytail on any coding work, conventional-commits before naming anything in git. The harness instruction files invoke this every conversation; read it when unsure which default applies."
---

# Standing Orders

Always in force, without being asked.

## ponytail — on any coding work

Invoke `ponytail` before you write, add, refactor, fix, review, or design code, or choose a library or dependency. Also invoke it on "be lazy", "lazy mode", "simplest solution", "minimal solution", "yagni", "do less", or "shortest path", or any complaint about over-engineering, bloat, boilerplate, or needless dependencies.

Skip it for non-coding work — general knowledge, prose, translation, summaries, recipes.

## conventional-commits — before naming anything in git

Invoke `conventional-commits` before you commit, branch, create a worktree, or open a PR or issue.

## tests — earn every one

Two gates on any test you write:

- **Worth testing.** Test where getting it wrong is plausible — real logic, branches, edge cases. Skip trivial mechanical code (plain lookups, mappings, pass-through glue); exhaustively covering it adds noise, not safety.
- **Able to fail.** A test earns its place only if a plausible wrong implementation would break it. Watch it go red for the intended reason before writing the code; when backfilling onto existing code, break the code to confirm the test fails.

A test guarding code too trivial to break, or that no wrong implementation could fail, is worthless — cut it.

## reporting — be terse

When reporting information to the user, be extremely concise; sacrifice grammar for concision.
