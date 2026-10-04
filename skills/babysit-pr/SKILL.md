---
name: babysit-pr
description: Monitor a pull request through review and CI. Use when the user asks you to monitor, watch or babysit a PR.
---

# Babysit PR

Wait on events, not the clock. If your harness offers a PR watcher (e.g. `watch_pull_request`), start it and end your turn: it wakes you when checks finish, comments arrive, or the branch falls behind. Otherwise run one blocking command in the background (`gh pr checks <number> --watch`, `gh run watch --exit-status`) and act when it exits. Reserve a bare status read for the first look and the final confirmation.

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
