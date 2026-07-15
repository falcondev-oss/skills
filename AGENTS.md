# Agent Instructions

This repo **is** the skills source. Skills live in `skills/<name>/SKILL.md`.

## Authoring skills

When asked to create or update a skill, always create or update it **in this repo** under `skills/<name>/`. Never write it to the agent's own config directory (e.g. `~/.claude/skills`, `~/.config/...`) — this repo is where these skills are developed and versioned.

- New skill → new folder `skills/<name>/SKILL.md`.
- Existing skill → edit the file under `skills/<name>/`.
- After adding a skill, add a row to the Skills table in `README.md`.
