---
name: implement-pr
description: "Implement a piece of work based on a spec or set of tickets, commit to a new branch and create a PR"
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use /code-review to review the work.

Commit your work to a new branch from the current base.

Push the branch to origin and open a pull request with `gh pr create`. Give it a body covering what changed and why (drawn from the spec or tickets) and linking any tickets it closes (`Closes #123`)
