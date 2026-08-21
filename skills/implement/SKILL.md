---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets. Claim the tickets you are working on.

Use `$ponytail ultra` as a strict guideline.
Use `$tdd` where possible, at pre-agreed seams.
If doing user-facing changes always verify the entire flow end-to-end with a browser, iOS simulator or Android emulator.

Run the full check suite (typechecking, linting, tests) once at the end as per repository guidelines.

Once done, run `$implementation-review` on the work.

Commit your work to a new branch from the current base.
