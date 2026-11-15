# Onboarding playbook

How to bring an existing project into the factory. Follow the steps in order.
Each step lists what to find, why, and what it produces.

Steps: 1. Discovery · 2. Brain · 3. Safety net (M5) · 4. Guardrails (M6–M7)
· 5. Trust ladder (M6) · 6. Onboarding report. Steps 1 and 2 are written so far.

## 1. Discovery

**Goal:** know enough to work safely, and record today's state before anything
changes. Like a builder's walk-through with photos: later nobody argues about
whether a crack was already there.

**Rules**

- **Read-only.** Don't edit, install, commit, push or deploy. Running the
  project's own build and test commands is allowed.
- **Mark every finding** as *confirmed* (you ran it or read the code) or
  *unverified* (a guess). Write unverified facts as `> Unverified: ...`.
- **Project facts stay in the project.** Write the results in the project's
  repo, never in the factory.

### What to find

| # | Find | How | Why it matters |
| --- | --- | --- | --- |
| 1 | Structure and stack, with versions | Folder tree, package and project files | Each stack version needs different commands and rules |
| 2 | Build, test, type-check, lint and format commands | Package scripts, build files, CI files, README | Agents must check their own work |
| 3 | Health baseline: does each check pass, and how long does it take? | Run each one and record the result and time | Old failures are not ours; slow checks will be skipped |
| 4 | Entry points | `main`, startup files, routes, jobs, handlers | Where execution starts and where input comes in |
| 5 | Data flow and storage | Database schema, migrations, API calls | Shows where a bug can reach real data or users |
| 6 | Config and secrets | Config files, env files, secret stores; scan git history | A secret in history still works until it is replaced |
| 7 | Deploy path | CI/CD files, hosting settings | What makes code go live is the biggest blast radius |
| 8 | Load-bearing walls | Auth, money, personal or children's data, time and time zones, external services | Mistakes here hurt most and are hard to undo |
| 9 | Existing docs and agent files | README, docs, `AGENTS.md`, `CLAUDE.md` | Check they are still true; a `CLAUDE.md` turns off `AGENTS.md` in Claude Code |
| 10 | CI and git hooks | `.github/workflows`, hook configs | Without them, nothing runs the checks automatically |
| 11 | Git history hot spots | Files changed most, recent fixes | Often the riskiest code |

Count files changed most often:

```sh
git log --since=1.year --name-only --format= | sort | uniq -c | sort -rn | head -20
```

### Legacy .NET: also find

- **Solution and projects:** `.sln`, `.csproj`; old-style or SDK-style project files.
- **Target framework:** .NET Framework 4.x or modern .NET. Many tools and
  analyzers work only on modern .NET.
- **Config transforms:** `web.config` / `app.config` and their
  `*.Release.config` versions. The real settings may only exist after a transform.
- **Logic in the database:** stored procedures, triggers, views, SQL Agent jobs.
  This logic is not in the code repo, so agents can't see it.
- **Windows-only parts:** IIS settings, COM, the registry, Windows services,
  scheduled tasks. These may not build or run on a Mac.
- **Package sources:** private NuGet feeds in `NuGet.config`, and DLLs committed
  to the repo with no source.

### Output

A discovery section in the project's onboarding report: one short line per
finding, marked confirmed or unverified, plus the health baseline table. List
risky areas and open questions for a human.

**Next:** step 2, the brain, turns these findings into project knowledge.

## 2. Brain

**Goal:** turn what discovery found into project knowledge that any agent or
person can use without the original developer in the room.

**Templates:** copy `.factory/templates/brain/` into the project. Rename
`AGENTS.md.template` to `AGENTS.md`.

### Rules

- **One fact, one place.** A copy is a fact nobody updates. Link to the fact
  instead of repeating it.
- **`AGENTS.md` is a pocket card.** Under 100 lines. Only commands, hard rules
  and surprises: things an agent would get wrong without being told. General
  overviews cost tokens on every task and don't help.
- **A wrong fact is worse than a missing one.** Mark every guess.
- **Personal preferences are not project knowledge.** How one person likes to
  work goes in their own personal instructions, not in the repo.
- **Status is not knowledge.** Milestone lists and "where we are now" go stale
  fast; git history already records them.

### Existing docs: move or map?

- **Move into `docs/brain/` (default).** Same paths in every project, so
  agents and checks always know where to look. Use `git mv` to keep history.
- **Map in place.** Keep the docs where they are and write only
  `docs/brain/README.md` as a map. Use this when the docs are big, owned by
  other teams, or live in a wiki.

### Gap analysis

Compare every existing doc with the brain structure. Sort each finding:

| Kind | Question | Example |
| --- | --- | --- |
| Missing | Which brain file would be empty? | No known issues written anywhere |
| Wrong or out of date | Does the code agree with the doc? | Doc lists a migration as not applied |
| Duplicated | Is the same fact in two places? | A decisions table copied into the instructions file |
| Not brain | Is it personal, status or history? | A milestone table, all rows "done" |

Then check: do the copies hold most of the wrong facts? They usually do.

### Confirmed or unverified

A fact is **confirmed** when someone ran it, read the code that does it, or
checked the live system. Write the date for live-system facts:
`(checked 2026-11-15)`. Everything else is a guess:

```markdown
> Unverified: the nightly job deletes sessions older than 90 days.
> Seen in `CleanupJob.cs`; not checked against the live schedule.
```

Look for **evidence that is cheap to check** before asking a human. For
example, types generated from a live database show what that database had
when they were generated. Evidence is not proof; ask a human to confirm with a
read-only check.

### What code can tell you, and what only a human knows

| An agent can infer from code and git | Only a human can confirm |
| --- | --- |
| What the code does today | Whether it is *meant* to do that |
| Structure, data model, dependencies | Why it was built this way |
| Which files change often and with which | What runs in production, and its config |
| Commit messages and linked tickets | Business rules nobody wrote down |
| Tests, and what they cover | What users actually rely on, including bugs |

For a legacy app where nobody remembers why: write what the code does as
confirmed, write the "why" as `> Unverified:`, and keep a list of open
questions for a human. Never invent a reason that sounds right.

### Legacy .NET: also check

- Settings that exist only after a `web.config` transform, or only on the server.
- Logic in stored procedures, triggers and SQL Agent jobs. Document it in
  `architecture.md`, because agents can't see it in the repo.
- Whether migrations are tracked (`__EFMigrationsHistory`) or run by hand.
  If by hand, nobody can know which are applied; record it as a known issue.

### Keeping it fresh

When code changes, update the matching brain file in the same pull request.
(A check that enforces this comes in M6–M7.)

### Output

- `AGENTS.md` and `docs/brain/`, filled in.
- The gap list and open questions, in the onboarding report.
