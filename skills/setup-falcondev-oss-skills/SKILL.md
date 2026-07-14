---
name: setup-falcondev-oss-skills
description: One-time machine setup for these skills — install ponytail, the Matt Pocock collection, and every skill from this repo, then wire the standing-orders line into every agent harness's root config. Run once per machine.
disable-model-invocation: true
---

# Setup falcondev-oss/skills

Set up this machine to reach for the right skill by default. Four things happen — **explain each to the user and get a yes before touching anything:**

1. Install the **root ponytail** skill — laziest-solution discipline for any coding work. (The ponytail repo also ships `ponytail-audit`, `-review`, `-help`, etc.; setup installs only the root `ponytail`.)
2. Install the **Matt Pocock** skills — only the repo's "Mattpocock Skills" section, not its "Other" section.
3. Install **all skills from this repo** (`falcondev-oss/skills`) — standing-orders, conventional-commits, and the rest.
4. Wire **standing-orders** into every agent harness's root config, so every conversation defaults to ponytail on code and conventional-commits before git.

This is prompt-driven, not a script: detect, present the plan, confirm, then act. Every step is idempotent — re-running changes nothing already in place.

## 1. Detect

- Which of the skills below are already installed? (`pnpm dlx skills@latest ls -g`, or your package manager's equivalent.)
- Which harnesses does the user have? Check for each config dir: `~/.claude` (Claude Code), `~/.codex` (Codex), `~/.gemini` (Gemini CLI), `~/.cursor` (Cursor), `~/.config/opencode` (opencode). The standing-orders line goes into every one present.

## 2. Present the plan

Tell the user what will happen, then confirm. Skip the install if those skills are already installed.

- [`install.sh`](./install.sh) installs the root `ponytail` skill, the 22 skills in the Matt Pocock "Mattpocock Skills" section (not "Other"), and every skill from this repo — all globally. It pins the exact skill names with `--skill`, so the interactive category picker is bypassed. It runs the skills CLI through the user's package manager (`pnpm`/`yarn`/`bun`/`npm`), so nothing is installed globally on the system.
- Step 4 adds the standing-orders line to each detected harness root config.

## 3. Install

Run this skill's [`install.sh`](./install.sh):

```sh
bash install.sh                          # install to all detected agents
bash install.sh -a claude-code -a codex  # or target specific harnesses (one -a each, from step 1)
PM=pnpm bash install.sh                  # force a package manager (default: auto-detect)
```

Extra args are forwarded to every `skills add`. Done when the three groups above are installed.

## 4. Wire standing-orders into each harness

For every harness detected in step 1, ensure its root config contains this line, on its own line:

```
In every conversation, follow the `standing-orders` skill.
```

Root config per harness:

| Harness | Root config |
|---|---|
| Claude Code | `~/.claude/CLAUDE.md` |
| Gemini CLI | `~/.gemini/GEMINI.md` |
| Codex, Cursor, opencode, other agents | `AGENTS.md` in the agent's config dir (e.g. `~/.codex/AGENTS.md`) |

Create the file if it is absent; if the line is already present, leave it; keep every other instruction in the file untouched.

## 5. Done

Tell the user which skills are now installed and which harness configs now carry the line. From here, ponytail fires on any coding work and conventional-commits before any git naming — in every conversation.
