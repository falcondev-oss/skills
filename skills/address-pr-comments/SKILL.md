---
name: address-pr-comments
description: Work through the review comments on a pull request — implement the requested changes, and reply to every comment. Use when the user wants to address PR feedback, respond to review comments, act on reviewer requests, or "handle the comments on my PR".
---

# Address PR comments

Every review comment is a **thread**. Your job is done when every open thread has reached a terminal state — either **fixed** (a change plus a reply naming it) or **answered** (a reply, then resolved) — and the repo's instructed check scripts pass locally. No thread is left untouched.

A comment is **not always a change request.** Triage each thread before acting:

- **Change** — the reviewer wants a code change. Implement it, then reply describing what you changed.
- **Answer** — the reviewer is asking a question, wanting your opinion, or flagging something for discussion. Reply with the answer or your take; do not invent a code change. If it genuinely needs the author's call, say so in the reply and leave the thread for them.

When a thread's intent is ambiguous, treat it as **Answer** and ask in the reply rather than guessing at a change.

## Steps

1. **Collect every open thread.** Fetch all unresolved review threads on the PR (see Mechanics). List each one: file, line, comment body, and your triage verdict (Change / Answer). Completion: every open thread appears in the list with a verdict — none skimmed over.

2. **Implement the Change threads.** Hand the collected Change threads to `/implement` as the spec. It runs typecheck/tests, `/code-review`, and commits. Completion: every Change thread has a corresponding change in the commit(s).

3. **Reply to and resolve every thread.** For each thread: post a reply — what you changed (Change) or the answer/opinion (Answer) — then resolve it, unless you deliberately left it for the author (say why in the reply). Completion: every thread from step 1 has a reply; each is resolved or explicitly left open with a reason.

4. **Run the instructed checks locally.** Run whatever check scripts this repo tells you to run — the commands named in `CLAUDE.md`, `AGENTS.md`, the README, or the project's scripts (lint, typecheck, test, build). Not CI/workflow checks. If any fail because of your changes, fix them and loop back through the relevant thread. Completion: the instructed checks pass locally, or the only failures are demonstrably unrelated to your changes (state which).

## Mechanics

`gh` against the current branch's PR. Get owner/repo/number from `gh pr view --json number,headRepositoryOwner,headRepository`.

List open threads with the IDs needed to reply and resolve (one GraphQL call covers collect + resolution state):

```bash
gh api graphql -f query='
{ repository(owner:"OWNER", name:"REPO") { pullRequest(number:N) {
    reviewThreads(first:100) { nodes {
      id isResolved
      comments(first:20) { nodes { databaseId path line body author { login } } }
} } } } }'
```

Reply to a comment (`COMMENT_ID` = a comment's `databaseId`):

```bash
gh api --method POST repos/OWNER/REPO/pulls/N/comments/COMMENT_ID/replies -f body='...'
```

Resolve a thread (`THREAD_ID` = the thread node `id`):

```bash
gh api graphql -f query='mutation { resolveReviewThread(input:{threadId:"THREAD_ID"}) { thread { isResolved } } }'
```
