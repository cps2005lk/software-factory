# Ideas backlog

Ideas to improve the kit, not yet built. Each idea names the principle it
serves ([principles](principles.md)) and where it came from.

Sources:

- **Team comparison:** two large team repos (a Go + React repo, "team A",
  and a .NET repo, "team B") compared with kit v0.14.0 on 2026-11-23. The
  full comparison is a private page, kept outside this repo:
  https://claude.ai/artifact/Wb4w3FVpikGBwEVSDogaKS
- This repo holds no facts about those projects (AGENTS.md rule). Only the
  general patterns are written here.

## Use Claude Code's own agent features; don't rebuild a fleet

Team A built its own fleet machinery: an orchestrator, seats in tmux,
worktree scripts, a watchdog. Claude Code now has most of this built in, so
the kit uses the built-ins and adds only what they don't give: rules, gates,
proof, isolation and measured model choice.

- **Subagents:** own context, tools, model, permission mode and hooks. They
  can run in the background and in parallel, and `isolation: worktree` gives
  each one its own git worktree.
  ([sub-agents](https://code.claude.com/docs/en/sub-agents))
- **Agent teams:** a lead session, teammates, a shared task list and direct
  messages. **Experimental**, off by default
  (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`). Every teammate gets the lead's
  permission mode and can't have its own, which goes against "smallest
  world" (principle 1). No teams in headless runs (`claude -p`), so not in
  the agent box. Tokens grow with the number of teammates.
  ([agent teams](https://code.claude.com/docs/en/agent-teams))
- **Worktrees, background agents, `/loop`, cloud routines** for parallel and
  scheduled runs.
  ([common workflows](https://code.claude.com/docs/en/common-workflows))

Docs checked 2026-11-23 (the pages show no "last updated" date).

What this means:

- **Don't build:** orchestrator scripts, seat launchers, watchdog pollers,
  worktree scripts. Use subagents with `isolation: worktree`.
- **Keep building:** the kit's rules, gates and proofs, and the small ideas
  below (end states, tripwires, evals, probes).
- **Agent teams: wait, then measure.** When they leave "experimental", run
  one experiment like M11/M12: a known answer, two runs each, compared with
  subagents (principle 24).

Status: `idea` → `next` → `doing` → `done` (with the PR link) or `dropped`
(with the reason). Effort: S (an hour or two), M (a day), L (more).

## Top ideas, in order

| # | Idea | Why (principle) | Seen in | Effort | Status |
| --- | --- | --- | --- | --- | --- |
| 1 | **Stop hook:** the agent can't end its turn with uncommitted work, a failing `check.sh`, or commits on `main` that no remote has. It is sent back once, with the reason. | 12 Layer the locks | Team A | S | idea |
| 2 | **Requirement IDs from spec to review gate.** Each spec scenario gets an ID (`AC-1`). Tasks and `review.md` name it. The review gate fails if an ID has no proof. | 21 A tick is a claim | Team B | M | idea |
| 3 | **Plan reviewer role,** before any code, in a separate agent. Fixed verdicts: endorse / endorse with conditions / revise / stand down. Numbered objections, each with an alternative. Advisory only. | Review on paper first | Team A | M | idea |
| 4 | **PR template:** what changes, why, risk, proof (Red commit, checks), what was not checked. Most important first, short lines. | 21 A tick is a claim | Teams A and B | S | idea |
| 5 | **AGENTS.md word-budget check,** run on PRs and on `main` (two PRs can each pass and go over together). | 11 A check refuses | Team B | S | idea |
| 6 | **Re-test the no-CLAUDE.md rule** on today's Claude Code. Both teams use a `CLAUDE.md`. One team's is a single line, `@AGENTS.md`. Write the result with source link and date. | 9 Mark guesses | Teams A and B | S | idea |
| 7 | **Findings outside the task:** the agent asks the human ("file it?"), never files alone and never hides it in a PR body. Add an issue form with a required Evidence field. | 6 Some things stay human | Teams A and B | S | idea |
| 8 | **SessionStart hook:** reports a stale branch, a missing tool or an old kit version before the first prompt. Shows the user only what needs an answer. | 13 "Could not check" is a failure | Team A | S | idea |
| 9 | **Usage report on the PR:** attach the session's cost and hook decisions to the PR when it opens. | 17 Measure; don't guess | Team B | M | idea |
| 10 | **Nightly mutation check,** advisory, never blocks a PR. Makes "test the tests" automatic. | 19 Test the tests | Team A | L | idea |

## More ideas

| # | Idea | Why (principle) | Seen in | Effort | Status |
| --- | --- | --- | --- | --- | --- |
| 11 | **Trigger lines in AGENTS.md:** "When you do X → read Y". The root file stays an index, not a manual. Add to the AGENTS.md template. | 8 One fact, one place | Team A | S | idea |
| 12 | **ADR rule:** an agent may draft an ADR, a human makes the decision, and the ADR says who decided. Add to the brain ADR template. | 6 Some things stay human | Teams A and B | S | idea |
| 13 | **`Human-decision:` commit trailer:** one line saying what the human chose or rejected. Optional `Assisted-by:` for the model. | 7 Files are the truth | Team A | S | idea |
| 14 | **Start and finish commands** for one unit of work. Start: branch off the latest `main`, link the spec. Finish: check the PR is merged, close the issue, delete the branch. | 21 A "merged" in chat is a claim | Team A | M | idea |
| 15 | **Handoff command:** write a short, redacted summary for a fresh session. It links specs and commits and doesn't copy them. | 7 Files are the truth | Team A | S | idea |
| 16 | **PostToolUse formatter:** format each edited file right after the edit. | Smaller diffs, fewer CI bounces | Team A | S | idea |
| 17 | **Role order by hook:** for example, the implementer is refused until the plan reviewer has run in this session. | 11 A check refuses | Team A | M | idea |
| 18 | **"Read the doc before you ask" hook** on the question tool: for a topic that a doc covers, the agent must cite the doc or read it first. | 7 Files are the truth | Team A | M | idea |
| 19 | **Write down fail-open vs fail-closed per layer.** Both teams let hooks fail open and make CI strict. The kit fails closed everywhere. Decide and record which layer must fail closed, and why. | 12, 13 | Teams A and B | S | idea |
| 20 | **MCP template with the same rules as the box:** an allow-list, no secrets in the file, and a probe. Every server adds reach. | 1 Smallest world | Teams A and B | M | idea |
| 21 | **Ship the kit as a Claude Code plugin** instead of copying files with `install.sh`. Pin to a tag (not a commit SHA). | 16 Copies drift | Team B | L | idea |
| 22 | **Cross-platform hooks** (Python standard library, or PowerShell) for the legacy .NET track on Windows. | Smallest world, but complete | Team B | L | idea |
| 23 | **Test the agent files, not only the checks.** An eval corpus for `AGENTS.md`, role files and playbooks. Level A: a hard-won rule must still be in the file (delete it → red). Level B: a broken/fixed pair, so the reviewer must fail the broken one. | 19, 20 Test the tests; known answer | Team A (agent fleet) | M | idea |
| 24 | **Empty-input probe for every check:** run each check on an empty target and prove it goes red. "Checked an empty room" must never pass. | 13 "Could not check" is a failure | Team A (agent fleet) | S | idea |
| 25 | **Learning loop with a threshold:** a script finds repeated lessons in git history. A lesson becomes a rule only after 2 different incidents, and the rule names those incidents. | 9 Mark guesses; 17 Measure | Team A (agent fleet) | M | idea |
| 26 | **Tripwires for unattended runs:** pause and ask the human when token spend passes a ceiling, or when the open-task queue keeps growing over K passes. Never continue past one. | 6, 15 A block is a stop sign | Team A (agent fleet) | M | idea |
| 27 | **Three honest end states:** every task ends as `done` (through the gates), `blocked:needs-human` (with the exact ask) or `wontfix:<reason>`. Nothing else counts as finished. | 21 A "done" is a claim | Team A (agent fleet) | S | idea |
| 28 | **The test writer is not the code writer:** a third role writes the failing tests from the spec, and the implementer only makes them pass. Today the implementer writes both. Built-in: just a third subagent file (`tester.md`) with its own tools and model. | Nobody grades their own work | Team A (agent fleet) | S | idea |
| 29 | **File ownership per role:** each subagent may write only its own paths, enforced by a hook in that subagent's file (built-in per-subagent hooks), not a custom dispatcher. Needed only if the kit runs agents in parallel. | 1 Smallest world | Team A (agent fleet) | M | idea |
| 30 | **Agent teams experiment,** once they are no longer experimental: the same known-answer task with subagents vs a team. Count found bugs, tokens and time, two runs each. | 24 Choose agents by measured results | Claude Code docs | M | idea |

## Not now

- Our own fleet machinery (orchestrator, seats, watchdog, worktree scripts):
  Claude Code has it built in (see the top of this file).
- Many skills (70), fleets of parallel agents, agent-armed auto-merge. They
  fit large teams with many agents at once, and they go against "a human
  always merges" (principle 6).
