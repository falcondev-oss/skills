---
name: quick-implement-pr
description: "Implement a small piece of work which doesn't need a detailed spec, commit to a new branch and create a PR"
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets. Claim the tickets you are working on.

Use `$ponytail ultra` as a strict guideline.
If doing user-facing changes always verify the entire flow end-to-end with a browser, iOS simulator or Android emulator.

Run the full check suite (typechecking, linting, tests) once at the end as per repository guidelines.

Once done, run `$ponytail-review` with `$ponytail ultra` as the strict guideline in a **parallel sub-agent**.
Fix every finding and re-run `$ponytail-review` until it comes back without findings.

Commit your work to a new branch from the current base.

Push the branch to origin, open a pull request using `$file-pr` and skip ci.
