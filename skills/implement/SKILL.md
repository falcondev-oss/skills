---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets. Claim the tickets you are working on.

Use `$ponytail ultra` as a strict guideline.
Use `$tdd` where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, run `$implementation-review` on the work.

Commit your work to a new branch from the current base.
