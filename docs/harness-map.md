# Harness map: what an agent can reach

**Why this file exists:** an agent runs as me, so its mistakes can reach whatever
I can reach. Without this map, we would add guardrails by guessing.

Checked on my Mac on 5 November 2026 with Claude Code v2.1.318.
Re-check it when a new login, tool or credential is added.

## Reach today

| Reach | What we saw | Worst mistake | Planned control |
| --- | --- | --- | --- |
| Home folder files | Desktop, Documents, all projects in `~/Dev`, and the private backup bundle. macOS may ask permission for some folders | Reads or changes unrelated files | Sandbox limits and deny rules (M6-M7) |
| GitHub through `gh` | Token scopes: `repo`, `workflow`, `gist`, `read:org` | Changes any of my repos, merges a PR, or changes branch protection or visibility | Hook that blocks risky `gh` commands (M7). Review the token scopes |
| Other tool logins | `~/.docker/config.json` and `~/.supabase` exist. Contents not read | Uses a saved login | Deny reads on these paths (M7) |
| Network | No sandbox, so no limit | Sends data out or downloads bad code | Sandbox network allowlist (M7) |
| Installing software | `brew install` worked in this session | Changes the Mac for all projects | Require approval (M7) |

## What is on today

- Claude sandbox: **off**
- Permission deny rules: **none**
- Claude hooks: **none**
- Git hooks: **none**

## A sandbox is not a full wall

Claude's sandbox wraps Bash and the programs it starts. Claude's own file tools,
hooks and MCP servers run outside it. So we need layers:

1. **Sandbox:** limits Bash.
2. **Permission deny rules and hooks:** limit the file tools and risky commands.
3. **Git hooks:** catch mistakes from any agent, and from me.
4. **Server rules:** branch protection on GitHub.
5. **A human gate:** I approve the risky steps.

Even layer 4 has a gap: my `gh` login has admin rights, so an agent using it can
change the rule itself.

## Questions to answer for each project

Answers go in the project's own brain, not in this repo.

1. Which secrets are on disk, and what can each one do? Test this; don't trust a note.
2. Have secrets or personal data ever been committed? Scan all of git history.
3. What is the shortest path from an agent's change to real users?
4. Which steps change production data, and who runs them?
5. Who can change the rules that protect the project?

## Sources

- [Claude Code sandboxing](https://code.claude.com/docs/en/sandboxing), checked 5 November 2026
- [Removing sensitive data from a repository](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository), checked 5 November 2026
