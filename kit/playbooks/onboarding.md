# Onboarding playbook

How to bring an existing project into the factory. Follow the steps in order.
Each step lists what to find, why, and what it produces.

Steps: 1. Discovery · 2. Brain · 3. Safety net · 4. Guardrails (M6–M7)
· 5. Trust ladder (M6) · 6. Onboarding report. Steps 1 to 4 are written so far.

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

## 3. Safety net

**Goal:** before an agent changes an area, that area has tests that would
notice if it broke. Agents change code faster than a human can read it.

### Two kinds of test

| | Unit test | Characterization test |
| --- | --- | --- |
| Says | The code *should* do X | The code *does* X today |
| Written from | A spec or a rule | Running the code and recording the answer |
| Fails when | The code is wrong | The behaviour changed, right or wrong |
| Use for | New code, known rules, bug fixes | Code nobody fully remembers; legacy code |

**A bug fix starts with a failing test.** Red on today's code proves the bug;
green after the fix proves the fix. An agent that fixes without this has
proven nothing, even if every check is green.

### Steps

1. **Measure coverage.** It shows which lines no test runs. It does not show
   whether tests check the right thing. A coverage report only knows its own
   test runner: SQL tests or end-to-end tests run elsewhere are invisible.
2. **Choose where first:** risk × how often it changes × how uncovered it is.
   Use evidence, not feeling:

   ```sh
   git log --since=1.year --name-only --format= -- src | grep -v test \
     | sort | uniq -c | sort -rn | head
   ```

   High risk: money, personal or children's data, access rights, time and
   dates. Low risk: code that only draws what well-tested logic decides.
3. **Write characterization tests.**
   - Fake the edges (database, network, clock) and record every call.
   - Let the code fill the snapshots, then **read every one**. A snapshot
     nobody read only proves the code does *something*.
   - Snapshot what a user or caller sees (visible text, return values), not
     internals like HTML or CSS classes, so harmless refactors don't fail.
   - **Don't fix odd behaviour while recording.** Write it down: a comment
     on the test, and a line in `docs/brain/known-issues.md`.
4. **Prove the tests can fail (mutation check).** Break the code on purpose:
   flip a condition, change a sort order. At least one test must fail *for
   that reason*, not by accident. If none fails, the net has a hole.
5. **Record the result** in the onboarding report: coverage before and after,
   areas still uncovered, and odd behaviour found.

**Trust rule (used by the trust ladder, M6):** an agent may change an area only
when that area has tests that pass a mutation check.

### Legacy .NET track

Michael Feathers defines legacy code as code without tests. The order is
always: **characterize, then change.**

- **Coverage:** [coverlet](https://github.com/coverlet-coverage/coverlet).
  `dotnet test --collect:"XPlat Code Coverage"` writes a
  `coverage.cobertura.xml`. The page says it needs the .NET 8 SDK and, on .NET
  10 with Microsoft Testing Platform, the `coverlet.MTP` package instead.
  > Unverified: whether it works on old-style .NET Framework projects. Its page
  > says both "works with .NET Framework on Windows" and "only supports modern
  > .NET SDK-style projects". Try it on the real project.
- **Characterization (snapshots):** [Verify](https://github.com/VerifyTests/Verify).
  Writes a `.received.` file; you accept it as `.verified.` and commit it.
  Supports NUnit, xUnit v3, MSTest and .NET Framework 4.6.2–4.8. From
  1 September 2026, new versions carry a maintenance fee for
  revenue-generating organisations: check before adopting.
- **Mutation testing:** [Stryker.NET](https://stryker-mutator.io/docs/stryker-net/introduction/).
  `dotnet tool install -g dotnet-stryker`, then `dotnet stryker` in the test
  project. Supports .NET Framework and modern .NET; needs the .NET 10 runtime
  to run the tool.
- **Time:** replace `DateTime.Now` with
  [`TimeProvider`](https://learn.microsoft.com/en-us/dotnet/standard/datetime/timeprovider-overview)
  (built into .NET 8+, NuGet `Microsoft.Bcl.TimeProvider` for .NET Framework
  4.6.2+). Tests use `FakeTimeProvider` from
  `Microsoft.Extensions.TimeProvider.Testing`.
- **Logic in the database:** [tSQLt](https://tsqlt.org/) runs T-SQL tests
  inside SQL Server, each in a transaction, and can fake tables and spy on
  stored procedures.
- **No seams?** Code that calls `new SqlConnection` or `DateTime.Now` deep
  inside can't be faked. Characterize from the outside first (HTTP responses,
  database rows after a call), then add a seam (an interface or a parameter)
  as the first, smallest change.

Tool facts checked on 2026-11-16 against the linked pages.

## 4. Guardrails

**Goal:** the rules that matter most are *enforced*, not only written. A rule
in `AGENTS.md` is a request; an agent can forget it or misread it. A check
that refuses can't be forgotten.

### Three levels

| | Written rule | Local git hook | Server rule |
| --- | --- | --- | --- |
| Where | `AGENTS.md` | `.git/hooks/` on each machine | GitHub branch protection + CI |
| Stops | Nothing; it asks | Accidents, before code leaves the machine | Decisions, for everyone |
| Skipped by | Forgetting | `--no-verify`, or a clone without hooks | An admin turning it off |
| Feedback | None | Seconds | Minutes |

Use all three: the written rule explains, the hook gives fast feedback, the
server rule is the lock nobody gets past.

### Steps

1. **Choose what to enforce.** For each rule in `AGENTS.md`, ask: how bad is
   it if this is broken once? Enforce the ones with a big blast radius first:
   secrets, `main`, `CLAUDE.md`. Leave matters of taste as written rules.
2. **Write `scripts/check.sh`** in the project: build, tests, lint, format,
   and the kit's checks. **The kit owns *when* checks run (the hooks); the
   project owns *what* runs (this file).** One file means the hook, CI and a
   human all run exactly the same checks.
3. **Turn on the local hooks**, once per clone:
   `.factory/guardrails/setup-hooks.sh`. Git never copies hooks into a clone,
   so a clone can't run a stranger's code; the price is that every clone
   must turn them on. Put the command in `AGENTS.md`.
   - The setup installs a small *launcher* in `.git/hooks/`. On a branch that
     doesn't have the kit, the launcher **blocks** with a message. Pointing
     `core.hooksPath` at a folder in the working tree instead fails
     *silently*: on a branch without that folder git runs nothing and says
     nothing.
4. **Keep the project's tools out of `.factory/`.** A formatter that rewrites
   kit files breaks the checksums. Example: add `.factory` to
   `.prettierignore`.
5. **Add CI** that runs `scripts/check.sh` on every pull request and on
   `main`. Minimal GitHub Actions file:

   ```yaml
   name: check
   on:
     pull_request:
     push:
       branches: [main]
   permissions:
     contents: read          # read-only token
   jobs:
     check:                  # this name becomes the required check
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@<full commit SHA> # vX.Y.Z
         - run: scripts/check.sh
   ```

   - **No secrets in CI** unless a check truly needs one. The smallest world
     again: an app with no database settings should still build and test.
   - **Pin actions to a full commit SHA**, with the version in a comment. A
     tag can be moved to other code later; a SHA can't.
   - **Read the first log.** Green is not proof: confirm the tests actually
     ran (for example "232 tests passed"), not zero of them.
6. **Turn on branch protection for `main`.** This changes repo settings, so
   the owner decides. Settings that worked for a one-person repo:
   - require a pull request (0 approvals: GitHub doesn't count your approval
     of your own PR);
   - include administrators;
   - block force pushes and deletion;
   - require the CI check, tied to the app that runs it (GitHub Actions), so
     a status posted by hand doesn't count; branch must be up to date.
   - Watch out: a required check that nothing runs makes every PR wait
     forever. Add the CI first, let it run once, then require it.
7. **Prove every lock, both ways.** A check that blocks everything is as
   useless as one that blocks nothing. For each one: show it **blocks** the
   bad case and **allows** the good case. The server lock: from a fresh clone
   (no hooks), push a commit straight to `main`. It must be refused.

### Rules for agents

- **Never use `--no-verify`.** A blocked hook is a stop sign: report what it
  said and fix the cause. Skipping a hook is a human decision, made in a
  terminal, never by an agent.
- **Never change branch protection or CI settings** without asking.
- **Could not check is not OK.** A missing script, folder or tool must fail,
  never pass quietly.

### Known gaps

- `--no-verify` skips the local hooks. The server rule catches it at the PR.
- An admin can switch the server rule off. That is on purpose (a broken CI
  must not lock everyone out), but it means the owner holds the last key.
- Git hooks only see git. Commands an agent runs (`gh`, deleting files,
  calling an API) need agent hooks: M7.

### Legacy .NET track

- **Hooks and `check.sh` don't care about the language.** `scripts/check.sh`
  runs `dotnet build` and `dotnet test` instead of npm.
  > Unverified: how the bash hooks run on Windows. Git for Windows ships its
  > own bash, which should run them. Try it on a Windows clone.
- **Azure DevOps** has the same server lock as
  [branch policies](https://learn.microsoft.com/en-us/azure/devops/repos/git/branch-policies):
  **Build validation** runs a pipeline before a PR can complete. Under
  "Require a minimum number of reviewers", the option "Allow requestors to
  approve their own changes" decides whether your own vote counts. People
  with the "bypass policies" permissions skip everything: give it to as few
  people as possible.

### Output

- `scripts/check.sh`, the hooks turned on, CI, branch protection.
- In the onboarding report: which rules are enforced and where, and the proof
  that each lock blocks and allows.

Sources:
- GitHub, [About protected branches](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  and [Available rules for rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets),
  checked 2026-11-21.
- Microsoft Learn, [Branch policies](https://learn.microsoft.com/en-us/azure/devops/repos/git/branch-policies),
  checked 2026-11-21.
- Hooks not cloned, silent `core.hooksPath` pass, server refusal: tested with
  git 2.52.0 and GitHub, 2026-11-20 and 2026-11-21.
