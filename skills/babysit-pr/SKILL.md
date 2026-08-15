---
name: babysit-pr
description: Monitor a pull request through review and CI. Use when the user asks you to monitor, watch or babysit a PR.
---

# Babysit PR

If your harness offers tools to monitor a PR, use them so you can respond when comments arrive. Otherwise, poll the PR for new comments and checks.

Some repos we work in have AI review bots. They're helpful, even if they are not always right.

Only act on checks and comments newer than the latest push. Verify every bot finding against the source before changing code. Fix real findings and CI failures, distinguish repository failures from infrastructure flakes, and reply with a written reason when dismissing false positives.

Keep an eye on changes to the base branch and rebase when needed.

If a review bot leaves feedback you believe is not worth addressing, reply and resolve the comment. Format comments left on the user's behalf as:

```
[MODEL-SLUG] RESPONDING ON BEHALF OF [USER NAME]

[actual reply]
```

Do not let review feedback expand the PR beyond the user's original goal.
Address real shortcomings, but avoid scope creep.

If nothing has changed, stay quiet rather than posting filler comments. Stop when the review bots and required checks are green on the latest commit.
Merge only when the user explicitly requested it; otherwise report that the PR is ready.
