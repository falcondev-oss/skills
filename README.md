# skills

## Install

Add this repo's skills to your coding agent:

```sh
npx skills@latest add falcondev-oss/skills -g
```

Then run the [`setup-falcondev-oss-skills`](skills/setup-falcondev-oss-skills/SKILL.md) skill in your agent (e.g. `/setup-falcondev-oss-skills`). It installs the recommended skill set — [`ponytail`](https://github.com/dietrichgebert/ponytail), the [Matt Pocock](https://github.com/mattpocock/skills) skills, and every skill from this repo — and wires the `standing-orders` line into each agent harness's root config, so the right skill fires in every conversation.

## Skills

| Skill | What it does |
|---|---|
| [`conventional-commits`](skills/conventional-commits/SKILL.md) | Formats commit messages, branch names, PR titles, and issue titles to the [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) spec. Splits oversized diffs into atomic commits and verifies every message against the spec before it lands. |
| [`address-pr-comments`](skills/address-pr-comments/SKILL.md) | Works through the review comments on a pull request: triages each into a change request vs. a question/opinion, implements the changes, replies to and resolves every thread, and confirms the PR's checks pass. |
| [`implement-pr`](skills/implement-pr/SKILL.md) | Wraps the `implement` skill in a feature-branch workflow: cuts a fresh branch, delegates the build to `implement`, then pushes and opens a pull request — branch name and PR title formatted via `conventional-commits`. |
| [`standing-orders`](skills/standing-orders/SKILL.md) | The default skills to reach for every conversation: `ponytail` on any coding work, `conventional-commits` before naming anything in git. Wired into each harness's root config by `setup-falcondev-oss-skills`. |
| [`setup-falcondev-oss-skills`](skills/setup-falcondev-oss-skills/SKILL.md) | One-time machine setup: installs `ponytail`, the Matt Pocock skills, and every skill from this repo, then adds the `standing-orders` line to every agent harness's root config. Explains each step and confirms before acting. |
