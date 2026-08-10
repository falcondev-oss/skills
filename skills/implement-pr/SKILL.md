---
name: implement-pr
description: "Implement a piece of work based on a spec or set of tickets, commit to a new branch and create a PR"
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets. Claim the tickets you are working on.

Use `$ponytail ultra` as a strict guideline.
Use `$tdd` where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, fetch and merge the latest base branch into your working branch. Resolve any conflicts with `$resolving-merge-conflicts`.

Then review the work with `$code-review` and `$ponytail-review ultra`. If the work touches UI run `$impeccable polish`.
Fix **all** findings even if they differ from the spec, then re-run each review whose findings you fixed.

Commit your work to a new branch from the current base.

Fetch the base branch again. If it moved, merge it in, resolve conflicts, and re-run typechecking and the full test suite before continuing.

Push the branch to origin and open a pull request with `gh pr create`. Give it a body covering what changed and why (drawn from the spec or tickets) and linking any tickets it closes (`Closes #123`). Always attach screenshots for any visual changes.

The body must also list every review that ran, with the number of issues it found and how many of those you fixed. Include reviews that found nothing, and name any finding you left unfixed with its reason:

| Review   | Found   | Fixed   |
| -------- | ------- | ------- |
| <review> | <count> | <count> |
