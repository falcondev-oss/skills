---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets. Claim the tickets you are working on.

Use /ponytail as a strict guideline.
Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, review the work with /code-review and /ponytail-review. Fix every finding, then re-run each review whose findings you fixed. Leave a finding unfixed only with a reason you can state.

If the work touches UI, run /impeccable polish on the changed source files. It refines the new UI into the app's existing design language and applies its own fixes, so it belongs after the reviews above, not among them.

Commit your work to a new branch from the current base.
