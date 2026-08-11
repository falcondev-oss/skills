---
name: implementation-review
description: "Review completed work against the spec and code-quality standards."
---

Run `$code-review` and fix every finding. Re-run each review whose findings you fixed. Repeat until all reviews come back without findings.

Once done, run `$ponytail-review` with `$ponytail ultra` as the strict guideline in a **parallel sub-agent**.
Fix every finding, even if it differs from the spec, and re-run `$ponytail-review` until it comes back without findings.
