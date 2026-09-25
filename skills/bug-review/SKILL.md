---
name: bug-review
description: Cold review of a diff for merge-blocking bugs, each with a way to demonstrate the failure. Use when asked to find bugs in a branch, PR or local changes, or when another skill dispatches a correctness review.
---

# Bug review

Review the diff you were handed against its base, with its contract or ticket if one came along. Report only issues that block merging: wrong behavior, data loss, permission or tenant holes, races, broken error paths, type holes that reach runtime. Other reviews cover style, structure and over-engineering.

For each issue:

- `file:line`
- why it is wrong, in one or two sentences
- how to demonstrate the failure: the input and steps, or a sketch of a test that goes red

Mark every issue you suspect but couldn't confirm, and say where you looked. If nothing blocks merging, say so in one line.

Completion: every changed hunk read, and every reported issue carries all three parts.
