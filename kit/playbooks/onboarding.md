# Onboarding playbook

How to bring an existing project into the factory. Follow the steps in order.
Each step lists what to find, why, and what it produces.

Steps: 1. Discovery · 2. Brain (M4) · 3. Safety net (M5) · 4. Guardrails (M6–M7)
· 5. Trust ladder (M6) · 6. Onboarding report. Only step 1 is written so far.

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
