---
name: file-pr
description: File a PR from the current branch. Use when the user asks to file, open or create a PR.
---

# File PR

Before filing, check whether a PR for this branch already exists.

PR title and body must be in american english. Use the `$show-me` skill to improve PR readability.

Make sure the title follows the `$conventional-commits` skill. Prefer a concise, human-readable title that explains why the change matters:

BAD

> ❌ perf(server): negotiate permessage-deflate on the websocket

GOOD

> ✅ perf(server): cut websocket frame size by 70%+ with gzipping

Open the description with a simple explanation of the problem based on the user's original prompt, then briefly explain the solution. Do not lead with an implementation inventory:

BAD

> ❌ Removed implicit workspace carry-over from every "new thread" entry point (cmd+n / cmd+shift+o, sidebar v1/v2 buttons, command palette). New threads inherit only the project from context; branch, worktree, and env mode always come from the configured defaults. Delete buildContextualThreadOptions, startNewThreadInProjectFromContext, and the v1 sidebar's seed-context machinery.

GOOD

> ✅ My "new worktree" default was ignored when starting new threads on existing worktrees. Super unintuitive. Now your preferences always apply.

Use the applicable sections from this body structure in this exact order. Replace every placeholder and omit sections that have no content:

```markdown
## 📝 Summary

<Explain the problem, then the solution in plain language.>

## 📦 Scope

- <Name the user-visible behavior and main areas changed.>

## ✅ Verification

- `<command>`: <result>

## 🔍 Reviews

| Review   | Found   | Fixed   |
| -------- | ------- | ------- |
| <review> | <count> | <count> |

<If any finding remains unfixed, name it and explain why.>

## 📸 Screenshots

<Attach screenshots for every visual change. Always inline images instead of linking to them.>

## 🔗 Issues

<Write "Closes #123" for every ticket the PR closes.>

## ⚠️ Needs attention

<List follow-up work, known limitations, or other issues that need the user's attention.>
```

List every review that ran, including reviews that found nothing. Never claim a check or review ran unless it did.

Open a real PR, not a draft. Add the `skip-ci` and `skip-deploy` labels to the PR, if the user requests to skip ci and the labels exist.
