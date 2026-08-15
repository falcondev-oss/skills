---
name: file-pr
description: File a PR from the current branch. Use when the user asks to file, open or create a PR.
---

# File PR

Before filing, check whether a PR for this branch already exists.

Make sure the title follows `$conventional-commits`. Prefer a concise, human-readable title that explains why the change matters:

BAD
> ❌ perf(server): negotiate permessage-deflate on the websocket

GOOD
> ✅ perf(server): cut websocket frame size by 70%+ with gzipping

Open the description with a simple explanation of the problem based on the user's original prompt, then briefly explain the solution. Do not lead with an implementation inventory:

BAD
> ❌ Removed implicit workspace carry-over from every "new thread" entry point (cmd+n / cmd+shift+o, sidebar v1/v2 buttons, command palette). New threads inherit only the project from context; branch, worktree, and env mode always come from the configured defaults. Delete buildContextualThreadOptions, startNewThreadInProjectFromContext, and the v1 sidebar's seed-context machinery.

GOOD
> ✅ My "new worktree" default was ignored when starting new threads on existing worktrees. Super unintuitive. Now your preferences always apply.

The description must list every review that ran, with the number of issues it found and how many of those you fixed. Include reviews that found nothing, and name any finding you left unfixed with its reason:

| Review   | Found   | Fixed   |
| -------- | ------- | ------- |
| <review> | <count> | <count> |

Link all tickets it closes and always attach screenshots for any visual changes.

Open a real PR, not a draft.
