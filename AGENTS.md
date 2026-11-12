# AGENTS.md

This repo is a reusable kit for AI agents: process, roles, guardrails and
templates. It contains no product code and no project knowledge.

## Rules

- Never add product code or facts about a specific project. Those belong in the
  project's own repo.
- Never create `CLAUDE.md` or `CLAUDE.local.md`. They switch off AGENTS.md
  loading. Check: `guardrails/checks/no-claude-md.sh`
- Never print, copy or commit secrets, tokens or credential files.
- Ask before installing software, force-pushing, or changing repo settings.

## Working here

- Every check in `guardrails/checks/` has a `.test.sh` next to it. Run the
  tests after changing a check.
- Docs use simple English. When a doc states how a tool behaves, add the
  source link and the date it was checked.
