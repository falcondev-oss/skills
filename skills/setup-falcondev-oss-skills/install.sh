#!/usr/bin/env bash
# Installs the default skill set:
#   - the root ponytail skill (not its audit/review/help variants)
#   - the Matt Pocock "Mattpocock Skills" section (not the "Other" section)
#   - every skill from this repo (falcondev-oss/skills)
# All globally. Any extra args (e.g. `-a claude-code,codex`) are forwarded to
# every `skills add` call, so you can target specific harnesses.
set -euo pipefail

# ponytail — root skill only (repo also ships ponytail-audit, -review, -help, etc.)
skills add dietrichgebert/ponytail -g -y --skill ponytail "$@"

# Matt Pocock — only the "Mattpocock Skills" section, not "Other"
skills add mattpocock/skills -g -y --skill \
  ask-matt,code-review,codebase-design,diagnosing-bugs,domain-modeling,grill-me,grill-with-docs,grilling,handoff,implement,improve-codebase-architecture,prototype,research,resolving-merge-conflicts,setup-matt-pocock-skills,tdd,teach,to-spec,to-tickets,triage,wayfinder,writing-great-skills \
  "$@"

# this repo — every skill
skills add falcondev-oss/skills -g -y --skill '*' "$@"
