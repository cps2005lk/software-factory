# Task loop playbook

How an agent builds a feature: in small loops, with every step written to a
file, so any session (or any agent) can stop and another can continue.

The loop: **spec** (what and why) → **plan** (how) → **tasks** (small ordered
steps) → **one task**: failing test, code, checks green, commit, tick it →
next task.

Like a hospital shift change: the night nurse doesn't rely on memory. The
chart says what was done, what is next, and what to watch.

## Rules

- **Files are the truth, not memory.** A fresh session knows only what is in
  the files it reads. An instruction given only in chat doesn't exist for it.
- **A session's memory can go stale.** If a human edits the spec, plan or
  tasks, start a fresh session, so the agent reads the new version.
- **Review on paper first.** Mistakes are cheapest before any code exists.
- **A tick or a commit message is a claim.** Check the important ones.
- **When a rule is wrong, change it in the open** (a new version of the rule),
  never by reading it differently each time.

## Tool: Spec Kit

[Spec Kit](https://github.com/github/spec-kit) gives the loop a fixed shape:
templates for spec, plan and tasks, and Claude Code skills to fill them.

### Install (once per machine; ask the owner first)

```sh
brew install uv
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@v<version>
```

- **Pin the version, with a cooldown.** Spec Kit is released very often (12
  releases in one month). Use a release that is about two weeks old: if a
  release has a serious problem, others usually find it within days.
- It brings its own Python (3.11+ needed); the system Python is not touched.
- The command lands in `~/.local/bin`, which may not be on `PATH`. Adding it
  (`uv tool update-shell`) edits the shell config: ask first.

### Set up a project (once per project, on a branch)

```sh
specify init --here --integration claude --script sh \
  --integration-options="--no-model-invocation"
```

- `--no-model-invocation` sets `disable-model-invocation: true` on every
  skill, so a skill runs only when a human types its command. Without it,
  the agent may start `/speckit-implement` on its own.
- **Read what it wrote before committing** (`git status`). In version 1.3.2 it
  added `.claude/skills/` and `.specify/` and changed nothing else: no
  `CLAUDE.md`, no `AGENTS.md`, no `.claude/settings.json`, no network calls in
  its scripts, no skill that grants itself permissions. Newer versions may
  add event hooks to `.claude/settings.json`; the sync check allows extra
  hooks, but read them.
- **The constitution links, it doesn't copy.** `/speckit-constitution` writes
  project rules to `.specify/memory/constitution.md`. Rules already in
  `AGENTS.md` or `docs/brain/` are linked from there, not repeated: one fact,
  one place.
- **Put "failing test first" in the constitution.** Spec Kit's tasks template
  says tests are optional.

### One feature

| Step | Who | What to check |
| --- | --- | --- |
| 0. Branch | Human or agent | Create the feature branch first, so the spec's "Feature Branch" line is true |
| 1. `/speckit-specify <what and why>` | Agent | Human reads `spec.md`: every scenario testable? Out of scope written down? No false statements? |
| 2. `/speckit-clarify` | Agent asks, human answers | Only when the spec has `[NEEDS CLARIFICATION]` markers |
| 3. `/speckit-plan` | Agent | Human reads `plan.md`: passes the constitution check? Any decision the spec didn't ask for? |
| 4. `/speckit-tasks` | Agent | Human reads `tasks.md`: every test fails before its code? |
| 5. `/speckit-analyze` | Agent (read-only) | A second reviewer. Fix the critical findings in the files, then start a **fresh** session |
| 6. `/speckit-implement` | Agent | One task at a time: Red, Green, commit, tick |
| 7. Verify | Human or reviewer | Check out a Red commit: its tests fail. Break the code on purpose: the right tests fail |

**Handoff test.** To prove the files carry the work: stop after half the
tasks, end the session, start a fresh one and type only `/speckit-implement`.
It must continue at the first unticked task.

**What the files carry, and what they don't.** `specs/<feature>/` (spec,
plan, tasks with ticks) is committed and travels. `.specify/feature.json`
(which feature is active) is git-ignored: it stays on one machine.

## What we found the first time

- **The agent bent its own rule.** A task said its tests would "PASS already
  … This is allowed by Principle I", against a rule that every test fails
  first. The fix: write all tests before the code (`/speckit-analyze` found
  this too).
- **Tests that fail for the same reason prove little.** Before any code, every
  test fails because there is no output at all. A mutation check after Green
  (for example `wc -w` → `wc -l`) shows which tests have teeth.
- **`/speckit-analyze` and a human found different problems.** Use both.
- **The personal file travels.** `~/.claude/CLAUDE.md` ("stop after each
  step", "commit after each step") applied in a sandbox project too.

## Legacy .NET track

The loop is the same; the commands in the plan are `dotnet build` and
`dotnet test`. Spec Kit has PowerShell scripts (`--script ps`) for Windows.
On legacy code, start the tasks with characterization tests (onboarding step
3) before the first change.

Sources: Spec Kit [README](https://github.com/github/spec-kit) and
[docs](https://github.github.io/spec-kit/) (last updated 2026-11-04), checked
2026-11-21. Behaviour of version 1.3.2 (files written,
`--no-model-invocation`, handoff) tested on 2026-11-21.
