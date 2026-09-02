---
name: implement-pr
description: Implement a change and deliver a green, review-ready pull request with explicit scope and evidence.
disable-model-invocation: true
---

# Implement PR

Own the change through a green, review-ready PR. Do not stop at code completion.

## 1. Take ownership of linked work

For every linked ticket or work item, record ownership before implementation: Use the tracker's assignee field to assign the item to the currently authenticated user. If assignment is unavailable, use the tracker's explicit ownership or in-progress mechanism.

## 2. Establish the contract

Read the request, linked tickets or spec, repository instructions, and relevant code before editing. Keep a short working contract with five parts:

- **Outcome:** observable behavior that must exist.
- **Preserve:** behavior and interfaces that must stay unchanged.
- **Scope:** files, packages, and systems the request permits changing.
- **Evidence:** focused checks that prove the outcome and preserved behavior.
- **Stop:** the PR, required CI, and requested review state that define completion.

Resolve repository facts by inspection. Choose defaults for internal, reversible decisions that follow existing patterns and are cheap to change. Ask the user only when a choice changes product behavior, visible UX, data meaning, permissions, security, cost, compatibility, is destructive or expensive to reverse, requires authority or credentials, or needs information only the user has. Include a recommended default and the boundary reason with every question.

## 3. Implement the smallest complete change

Use `$ponytail ultra`. Follow repository conventions and reuse established seams. Add only behavior required by the contract. Keep types precise from the lowest changed boundary to the highest consumer.

Add focused tests at the stable behavioral seam. Skip tests that only memorialize deleted behavior, duplicate type checks, or restate implementation details.

For visual or interactive work, use the browser, Android emulator or iOS simulator to check the affected states and responsive behavior. Capture evidence needed by the PR.

## 4. Verify

Before review, run the affected package's complete test, typecheck, lint, and build commands that the repository documents. Record commands and results for the PR.

## 5. Review against the contract

Run `$code-review` and `$ponytail-review` in parallel. Treat findings as hypotheses:

1. Verify each finding against the working contract and current code.
2. Fix every valid, in-scope finding.
3. Record false positives and out-of-scope findings without expanding the change.
4. Re-run affected checks and the relevant review until no valid in-scope finding remains.

Review feedback cannot expand the contract silently. Escalate any finding that requires a product, data, security, cost, compatibility, or destructive choice.

## 6. File and babysit the PR

Commit the complete change, push it, and use `$file-pr` to open the PR.

Use `$babysit-pr` until required CI and review automation are green. Address valid review feedback with `$address-pr-comments`, re-run the affected evidence, and continue babysitting.

Finish only when the PR is merge-ready or an external blocker remains. Report the PR URL, verified checks, review state, and the exact blocker when applicable.
