#!/usr/bin/env bash
# Installs the default skill set globally:
#   - the root ponytail skill (not its audit/review/help variants)
#   - the Matt Pocock "Mattpocock Skills" section (not the "Other" section)
#   - every skill from this repo (falcondev-oss/skills)
#
# Runs the skills CLI through the user's package manager (transient, no global
# CLI install). Detection order is pnpm, yarn, bun, npm; override with
# PM=<pnpm|yarn|bun|npm>. Any extra args (e.g. `-a claude-code,codex`) are
# forwarded to every `skills add` call, so you can target specific harnesses.
set -euo pipefail

pm="${PM:-}"
if [ -z "$pm" ]; then
  for candidate in pnpm yarn bun npm; do
    if command -v "$candidate" >/dev/null 2>&1; then pm="$candidate"; break; fi
  done
fi

case "$pm" in
  pnpm) run() { pnpm dlx skills@latest "$@"; } ;;
  yarn) run() { yarn dlx skills@latest "$@"; } ;;
  bun)  run() { bunx skills@latest "$@"; } ;;
  npm)  run() { npx --yes skills@latest "$@"; } ;;
  *)    echo "No supported package manager found (pnpm, yarn, bun, npm)." >&2; exit 1 ;;
esac

# ponytail — root skill only (repo also ships ponytail-audit, -review, -help, etc.)
run add dietrichgebert/ponytail -g -y --skill ponytail "$@"

# Matt Pocock — only the "Mattpocock Skills" section, not "Other"
run add mattpocock/skills -g -y --skill \
  ask-matt,code-review,codebase-design,diagnosing-bugs,domain-modeling,grill-me,grill-with-docs,grilling,handoff,implement,improve-codebase-architecture,prototype,research,resolving-merge-conflicts,setup-matt-pocock-skills,tdd,teach,to-spec,to-tickets,triage,wayfinder,writing-great-skills \
  "$@"

# this repo — every skill
run add falcondev-oss/skills -g -y --skill '*' "$@"
