---
name: implement-pr
description: "Implement a piece of work based on a spec or set of tickets, commit to a new branch and create a PR"
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets. Claim the tickets you are working on.

Use `$ponytail ultra` as a strict guideline.
Use `$tdd` where possible, at pre-agreed seams.
If doing user-facing changes always verify the entire flow end-to-end with a browser, iOS simulator or Android emulator.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, run `$implementation-review` on the work.

Commit your work to a new branch from the current base.

Fetch the base branch. If it moved, merge it in, resolve conflicts, and re-run typechecking and the full test suite before continuing.

Push the branch to origin and open a pull request using `$file-pr`.
Monitor the PR using `$babysit-pr`.
