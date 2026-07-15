---
name: implement-pr
description: Implement work from a spec or set of tickets on a fresh branch, then push and open a pull request. Use when the user wants to implement a spec/tickets and open a PR, build a feature end-to-end on its own branch, or ship completed work as a pull request.
---

# Implement + PR

Wrap the `implement` skill in a feature-branch workflow: branch first, pull request last.

## Steps

1. **Branch.** Cut a new branch from the current base, named per `conventional-commits`. Completion: you are on the new branch.
2. **Implement.** Run the `implement` skill to build the work.
3. **Push & PR.** Push the branch to origin and open a pull request with `gh pr create`, title per `conventional-commits`. Give it a body covering what changed and why (drawn from the spec or tickets) and linking any tickets it closes (`Closes #123`). Completion: the PR URL is returned to the user.
