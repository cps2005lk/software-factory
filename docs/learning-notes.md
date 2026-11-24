# Learning notes

Short notes after each milestone: the concept, why it matters, the .NET
comparison, our mistakes, and what changes on a legacy project.

## M0: Harness engineering and blast radius

**Concept.** The harness is everything around the agent: instructions, tools,
checks, limits and feedback loops. Blast radius is the worst damage one mistake
can do with the access the agent has today.

**Why it matters.** An agent runs as me, and a written instruction can't stop it.
Only real limits can, and we can't choose good limits until we know its reach.

**.NET comparison.** The harness is like Roslyn analyzers, branch policies, CI and
limited service accounts. Blast radius is the question you ask of a SQL login:
`db_owner`, or only `db_datareader`?

**Mistakes we made.**

- A credential file had been committed to a private repo. We found it only because
  we scanned before going public.
- A pattern search also matched a placeholder token, so a match still needs checking.
- My first plan was a force-push. GitHub's docs say old commits can stay reachable
  by hash, so a new repo was the better choice. Read the docs before a one-way step.

**On a legacy project.** Assume years of history can hold old secrets, and run a
history scan before any agent or new person gets access. Replace any secret first;
rewriting history comes second. Moving a repo is harder when many people have
clones and many systems connect to it.

**Order when a secret leaks.** Replace the secret first, then clean the history.
Nobody knows who already copied it, and replacing the secret makes every copy
worthless. Deleting the file in a new commit does nothing, because the secret is
still in history and still works. (I first answered "rewrite history first".)

**Still to practise.** Finding reach beyond files: logins and admin rights.

## M1: Instruction loading

**Concept.** An instruction file only helps if it is loaded, and a loaded
instruction is still only a request. Tested with Claude Code v2.1.318 on Haiku,
2 runs per case (12 November 2026):

| Setup | Root `AGENTS.md` | Folder `sub/AGENTS.md` |
| --- | --- | --- |
| No `CLAUDE.md` | Loaded and followed (2 of 2) | Loaded with the file-read result, but ignored as tool output (2 of 2) |
| Thin `CLAUDE.md` with `@AGENTS.md` | Loaded by the import, followed 1 of 2 | Never loaded |

**Why it matters.** One stray `CLAUDE.md` silently switches off every
`AGENTS.md`, and nothing warns you. Folder files arrive late and look like tool
output, so they are hints, not rules.

**.NET comparison.** Like a `Directory.Build.props` that makes MSBuild skip every
nested `.editorconfig` without a warning. Our check `no-claude-md.sh` is the
analyzer that warns.

**Lock vs hook.** A lock is the goal: something that stops a bad action even when
the agent ignores the rules. A hook is one way to build it, like a guard at the
door. A Claude hook blocks only with exit code 2; exit code 1 lets the action
through. Other locks: deny rules, sandbox, git hooks, CI, branch protection.
Important rules get a reminder in the root `AGENTS.md` and a lock elsewhere.

**Mistakes we made.**

- My first result table said PAPAYA was followed. The reply only mentioned the
  word while explaining why it ignored it. Check the debug log, not the reply.
- I thought a root `CLAUDE.md` would still let folder `AGENTS.md` files load, and
  that a "never" rule belongs in `CLAUDE.md`. Both were wrong.
- A check that can't run must not return 0. That is a false green, like
  `dotnet test` finding 0 tests and showing green.

**On a legacy project.** It may already have a `CLAUDE.md`. Move its rules into
`AGENTS.md` before adding folder files, or they will be ignored.

**Still to practise.** Re-run the experiment when Claude Code updates, and once
with a stronger model.

## M2: Kit distribution

**Concept.** The kit is copied into a project's `.factory/` folder with a
`VERSION` file and a checksum for every file. The kit owns `.factory/`; the
project owns everything else. Checksums detect local edits; they don't prevent them.

**Why it matters.** Without a version, nobody knows which rules a project runs.
Without checksums, an update could silently overwrite someone's fix.

**.NET comparison.** Like a NuGet package: `VERSION` is the package version, and
`checksums.txt` is like the content hash in `packages.lock.json`.

**What the install script does.** Refuse if the project has uncommitted changes.
Stop and change nothing if `.factory/` was edited, or has a missing or extra file.
Build the new folder next to the old one, then swap. Never commit: a human
reviews and commits.

**First real install.** Brain Gym got kit v0.1.0 through PR #1 (12 November 2026).

**Mistakes we made.**

- I predicted a second install run would say "already up to date". It refused,
  because the uncommitted `.factory/` counts as unreviewed work.
- All 12 tests passed on the first run. I broke the script on purpose (mutation
  testing) and 3 tests failed, which proved they can catch a bug.
- PR #1 showed "mergeable" with no checks, because the Vercel app could not see
  the new repo. A missing check looks the same as a passing one. Fixing access
  did not help until a new push, because GitHub does not replay old events.

**On a legacy project.** It may already have a folder named `.factory/` or its
own copies of similar scripts. The script leaves a `.factory/` without
`checksums.txt` alone, so someone must move it first.

**Still to practise.** Making a check required, so a missing check blocks a merge (M6).

**Pattern from M1 and M2.** "Could not check" must never look like "checked and
OK": exit code 2 for a missing folder, a refused install on unreviewed work, a PR
with no checks, a lost executable bit. Fix path for a kit file: change it in the
factory, bump `VERSION`, undo the local edit, reinstall.

## M3: Discovery and baselines

**Concept.** Discovery is the read-only walk-through before any change: how the
project builds, where it goes live, where its risky parts are. A baseline is
today's state, measured: do the checks pass, and what does a normal task cost
without the factory? Every finding is marked confirmed or `> Unverified:`.

**Why it matters.** Without a "before" number, we can never show the factory
helps; it would only feel like it does. Without discovery, an agent changes a
load-bearing wall it didn't know was there.

**.NET comparison.** Joining a legacy team: first run `dotnet build` and
`dotnet test` and write down "3 tests already fail, build takes 2 minutes", or
you get blamed for old failures. Measure performance before optimizing.

**What the baseline showed** (details in `docs/baselines/m3-plain-claude.md`).
Plain Claude fixed a real bug in 26 seconds with 0 corrections. All 5 checks
passed, but it wrote no test and didn't say why. Fast and cheap, but unproven.
The factory must make the agent prove its work without costing much more.

**Mistakes we made.**

- My hint made you predict a `format:check` failure. Prettier skips files it
  doesn't know, so it passed. A hint biases a prediction; measure, don't guess.
- We forgot `/usage` before the run. A step that depends on someone
  remembering will sometimes be missed. M7 adds an automatic usage log.
- The session file stores each reply several times. Summing tokens without
  `unique_by(.id)` would count some replies twice.
- Green checks looked like success, but none of them tested the bug.

**On a legacy project.** Expect logic outside the code (stored procedures, SQL
jobs, config transforms) and parts that only run on Windows. The list of open
questions for a human is as valuable as the list of facts.

**Still to practise.** Writing the failing test first (M5), and repeating the
same task with the factory (M8).

## M4: The brain

**Concept.** The brain is a project's knowledge, written so any agent or person
can work without the original developer. Two layers: `AGENTS.md` is the pocket
card (under 100 lines: commands, hard rules, surprises), loaded every session;
`docs/brain/` is the shelf, read only when a task needs it. One fact lives in
one place, and every guess is marked `> Unverified:`.

**Why it matters.** Every always-loaded line costs tokens on every task, and
general overviews don't help agents. A wrong fact is worse than a missing one.
In Brain Gym, 5 of the 6 wrong facts were in copies: a copy is a fact nobody
updates.

**.NET comparison.** `AGENTS.md` is like `Directory.Build.props`: small and
applied everywhere. `docs/brain/` is the wiki and XML docs. A hand-run migration
is like EF Core without `__EFMigrationsHistory`: nobody can tell what is applied.

**Sorting rule.** Ask two questions. Would an agent get it wrong without being
told? Put it in `AGENTS.md`. Does the code already say it reliably? Don't write
it. The rule goes in `AGENTS.md`; the reason goes in the brain.

**Mistakes we made.**

- You guessed architecture docs were missing; they were in the README. Look
  everywhere before calling something missing.
- I put "0001–0006 applied" in two files while writing the brain. I broke our
  own rule within an hour; the freshness check in M6–M7 must catch this.
- A template named `AGENTS.md` would load as a real folder instruction. It is
  `AGENTS.md.template`.
- Nobody knew if migration 0006 was applied. Generated types were evidence;
  a read-only query was proof.
- I thought a personal `~/.claude/CLAUDE.md` might switch off `AGENTS.md`.
  Tested on Claude Code v2.1.325 (2 of 2): both load. Re-test after updates.
- In the quiz, things that sounded important went into the brain even when
  the code already said them.

**On a legacy project.** The code tells you *what*; only a human knows *why*.
Write the what as fact, the why as `> Unverified:`, and keep a list of open
questions. Never invent a reason that sounds right. Check whether migrations
are tracked, and look for logic outside the repo.

**Still to practise.** A check that keeps the brain fresh (M6–M7), and the
personal files for Codex and Copilot if we add those tools.

## M5: Safety nets

**Concept.** Before an agent changes an area, that area needs tests that would
notice a break. A unit test says what the code *should* do; a characterization
test records what it *does* today, right or wrong. A bug fix starts with a
failing test. Coverage shows what ran, not what was checked; a mutation check
(break the code on purpose) shows whether tests notice.

**Why it matters.** Agents change code faster than a human can read it. In M3,
plain Claude fixed a bug with every check green and no proof. In M5 the same
fix got a test that was red on the old code and green on the new.

**.NET comparison.** Characterization tests are Verify snapshots
(`.received.` → `.verified.`). Coverage is coverlet. Mutation testing is
Stryker.NET. Fake time is `FakeTimeProvider`.

**What each layer found in Brain Gym.**

| Layer | Found |
| --- | --- |
| Failing test first | The midnight bug is real, and the fix works |
| Characterization | `removeParent` deletes by user id, safe only while one family per person |
| Mutation check | One parent-screen case covered only by accident |
| Browser agent | Stop throws the game away, and its time isn't counted (written down nowhere) |

**Mistakes we made.**

- My `sed` rename used `\b`, which macOS `sed` doesn't support. Half the names
  changed, and it still compiled. Read the diff; use `perl` for portable edits.
- One big jump of the fake clock ran only the first countdown tick. Move fake
  time in steps, the way real time moves.
- I almost let a test pass because of a crash in another test. A test must
  fail for the *right reason*.
- npm blocked an install script (`fsevents`) until approved: a lock, not a
  request. We didn't approve it, because nothing needed it.
- The dev server would have used the live database. We blanked the Supabase
  settings so the browser agent could only touch a device-only copy.

**On a legacy project.** Characterize before changing anything, starting
where risk × churn × missing coverage is highest. Expect no seams: test from
the outside first, then add the smallest seam. Check tool licences (Verify
now has a maintenance fee for companies).

**Still to practise.** Browser tests that run without me watching (Playwright,
maybe in CI), and a mutation tool instead of breaking code by hand.

## M6: Request vs enforcement and the trust ladder

**Concept.** A rule in `AGENTS.md` is a request; a check that refuses is
enforcement. There are three levels: a written rule (asks), a local git hook
(stops accidents, in seconds), and a server rule (branch protection with a
required CI check: stops decisions, for everyone). The kit owns *when* checks
run (the hooks); the project owns *what* runs (`scripts/check.sh`). The trust
ladder decides how much an agent may do: read-only → small PRs → features,
climbing by proof (5 PRs in a row with no correction), per area, and
dropping one rung after a serious slip.

**Why it matters.** Agents are fast and confident, and they slip in ways a
written rule can't stop. In this milestone I slipped twice myself (see
below). Only the locks would have caught it.

**.NET comparison.** Git hooks are like a pre-build step on your own machine.
Branch protection with a required check is Azure DevOps branch policies with
**Build validation**: the PR can't complete until the pipeline is green. The
trust ladder is how a team treats a new junior developer.

**What each lock does.**

| Lock | Stops | Skipped by |
| --- | --- | --- |
| `AGENTS.md` rule | Nothing; it asks | Forgetting |
| Pre-commit hook | Commit on `main`, `CLAUDE.md`, staged secrets | `--no-verify`, a clone without hooks |
| Pre-push hook | Push to `main`; failing `scripts/check.sh` | `--no-verify`, a clone without hooks |
| Branch protection + required `check` | Direct push to `main`; merging a PR with red checks | An admin turning it off |

**Mistakes we made.**

- **Hooks silently off.** `core.hooksPath` pointed at a folder in the working
  tree. On `main`, which didn't have that folder yet, git ran nothing and
  said nothing: a commit on `main` passed with exit 0. You found it by
  testing in your own terminal. Fix: a launcher in `.git/hooks/` that
  *blocks* when the kit is missing (kit v0.2.1). Lesson: could not check must
  fail, never pass.
- **I used `--no-verify`** for a Brain Gym commit. I redid the commit with the
  hooks on. A written rule didn't stop me; an agent hook will (M7).
- **I stated facts I hadn't checked:** I said the factory repo was public and
  Brain Gym was private. It was the other way round. `gh repo list` settled
  it. Evidence first, then the claim.
- **`!` commands that didn't seem to work.** `git switch` and `git config`
  run with `!` in the session seemed to fail; the reflog showed no switch.
  Cause unknown. You ran them in your own terminal instead.
  > Unverified: why the `!` commands failed.
- **Prettier wanted to reformat the kit** in `.factory/`, which would break
  the checksums. Fix: `.factory` in `.prettierignore`. A project's tools
  must leave the kit's folder alone.
- **A weak test, found by a mutation check.** The "never prints the secret"
  test compared output with the whole file, so it caught only 2 of 7 broken
  versions. Fix: check for the secret itself.
- **Our own hook blocked the factory's first push of `main`.** You pushed it
  with `--no-verify`: a deliberate human exception, made in a terminal.
- **A stale brain fact.** Brain Gym's known issues said branch protection was
  "not set up yet", but you had already turned it on. Found by reading the
  settings with `gh api`, not by remembering.

**What we proved.** From a fresh clone (no hooks), a push straight to
`main` was refused by GitHub: "Changes must be made through a pull request"
and "Required status check "check" is expected". CI ran on Linux and showed
232 Brain Gym tests and 7 factory test files actually ran.

**On a legacy project.** `scripts/check.sh` runs `dotnet build` and
`dotnet test`; the hooks don't care about the language. Azure DevOps has
Build validation and "bypass policies" permissions; give the bypass to as
few people as possible. Most legacy areas start on rung 1, because they have
few tests.

**Still to practise.** Agent hooks that block `--no-verify` and risky `gh`
commands (M7). Watching a PR with a failing check stay blocked: I can't show
this as an agent without `--no-verify`, so it's a human exercise.

## M7: Agent hooks, adapters and the usage log

**Concept.** A git hook only sees git, and only at commit or push. An
*agent hook* sees every action an agent is about to take. Claude Code's
`PreToolUse` hook gets the command as JSON and answers: **block** (exit 2,
with a reason the agent reads), **ask** (a permission prompt for the human),
or no objection. Our check (`risky-command.sh`) knows nothing about Claude;
a small *adapter* translates Claude's JSON into a command string and the
check's answer back. A `SessionEnd` hook writes a *usage file* per session,
and a *sync check* fails when the project's copy of the hook settings drifts
from the kit.

**Why it matters.** In M6 I used `--no-verify` and no written rule stopped
me. Now the same command is refused before it runs. And the trust ladder's
"5 PRs with no correction" now comes from records, not from memory.

**.NET comparison.** An agent hook is ASP.NET middleware or an action
filter: it runs before the action and can short-circuit it. The adapter is
`ILogger` with a Serilog provider. The usage log is structured logging, one
record per request. The sync check is like `dotnet restore --locked-mode`:
CI fails when config no longer matches what it should be.

**What each piece proved.**

| Piece | Proof |
| --- | --- |
| Block | `git push --dry-run --no-verify` refused before it ran, here and in a Brain Gym session |
| Ask | A dry-run force-push waited 2 h 13 min for a human yes (transcript timestamps) |
| Usage log | A headless `claude -p` run wrote its file: `SessionEnd` runs for `-p` too (the docs don't say) |
| Sync check | Deleting a hook from `.claude/settings.json` made `scripts/check.sh` exit 1 |
| Every check | Mutation checks: bugs put back on purpose, each caught by a test |

**Mistakes we made.**

- **A Perl `$18`.** I meant "group 1, then 8"; Perl read group 18 (empty) and
  deleted part of the playbook. Found by reading the diff.
- **A bullet split in two.** My new `AGENTS.md` line went between a bullet
  and its second line, so a git-hook sentence described the agent hook.
  Found by reading the output. Lesson for both: read every scripted edit.
- **A temporary file in `/tmp`** instead of the session's scratchpad.
- **macOS bash 3.2** has no `declare -A`. CI (bash 5) would have passed
  while the Mac failed. Run kit scripts on the Mac, not only in CI.
- **A trailing space** after empty YAML fields. Brain Gym's Prettier check
  would have failed on every usage file. Now tested.
- **A wrong expected value in my own test** (the date). Before fixing the
  code, ask whether the test is right.
- **Tests that all passed on the first run had holes.** Mutation checks
  found five: a Perl precedence bug (`$x // "" eq "api"`), heredoc removal,
  a rule nothing needed, and two report cases.
- **An "ask" you don't remember answering.** The force-push prompt was
  approved two hours later. An ask is only as strong as the attention of
  the person who answers (prompt fatigue). Never-break rules are blocks.
- **A PR looked for in the wrong repo.** PR numbers are per repo: factory
  #4 and Brain Gym #5 are different PRs. And a "merged" PR that wasn't:
  check the state, not the memory.

**Things we learned about the tools.**

- Claude Code runs the hooks of the project the *session started in*, not
  of the folder a command touches.
- `.claude/settings.json` is cloned, unlike git hooks: every clone has the
  agent hook at once.
- `SessionEnd` hooks share a 1.5-second budget unless a hook sets its own
  `timeout` ([hooks reference](https://code.claude.com/docs/en/hooks),
  checked 2026-11-21).
  > Unverified: whether agent hooks run for `!` commands typed by a human.

**On a legacy project.** The check and the hooks don't care about the
language. A Windows team needs Git for Windows' bash for the scripts
(unverified, see the playbook). Most of the value is in the order: an agent
hook first, so the agent can't take shortcuts while the safety net is thin.

**Still to practise.** Size and freshness checks for the brain (does
`AGENTS.md` stay under 100 lines; is a brain doc older than the code it
describes?). Filling in task and corrections after real sessions, so the
trust ladder has data.

## M8: The task loop and handoffs

**Concept.** An agent builds a feature in small loops: spec (what and why) →
plan (how) → tasks (small ordered steps) → one task at a time (failing test,
code, commit, tick) → next. Everything is written to files, so a session can
stop and a fresh one, with no memory, can continue. Spec Kit gives the loop a
fixed shape: templates plus Claude Code skills (`/speckit-specify`, `plan`,
`tasks`, `analyze`, `implement`).

**Why it matters.** Sessions end, context fills up, and agents get replaced.
Whatever isn't in a file is lost. This conversation itself was summarized
several times; the files and memory notes carried the work.

**.NET comparison.** A work item in Azure Boards with acceptance criteria and
child tasks: anyone can pick up a task, because everything needed is written
on it. The constitution is like `.editorconfig` plus analyzer rules: change
a rule in the file, don't sprinkle `#pragma warning disable`.

**What we proved (sandbox, word counter).**

| Claim | Proof |
| --- | --- |
| Files carry the work | A fresh session, given only `/speckit-implement`, said "T001–T006 are already done. Next is T007" |
| Red was real | Checking out the Red commit: 0 passed, 7 failed |
| Tests have teeth | Changing `wc -w` to `wc -l`: 6 of 7 tests fail (an empty file has 0 lines and 0 words) |
| Spec Kit 1.3.2 is safe with our kit | `specify init` wrote only `.claude/skills/` and `.specify/`: no `CLAUDE.md`, no `AGENTS.md`, no settings, no network calls |

**Mistakes and surprises.**

- **The agent bent its own rules, twice.** A task said its tests would "PASS
  already … This is allowed by Principle I" (every test must fail first).
  And it read the `set -e` rule as "only for the program" instead of saying
  the rule was wrong. Fix: write all tests before the code, and change a
  wrong rule in the open (constitution 1.0.0 → 1.0.1).
- **The spec stated something false:** a feature branch that didn't exist.
  Create the branch before `/speckit-specify`.
- **`/speckit-analyze` found four problems I missed** (for example `$(cat …)`
  drops trailing newlines, and `wc -w` splits on `\r`), and I found a hole in
  its fix (all tests failing for the same reason). Two reviewers beat one.
- **I assumed the agent would run to the end.** It stopped after one task,
  because the personal `~/.claude/CLAUDE.md` says "stop after each step". My
  instruction was only in our chat, so it didn't exist for that agent.
- **I amended the constitution by hand,** although it says amendments go
  through `/speckit-constitution`. Recorded in its change log.
- **`~/.local/bin` is not on `PATH`** after installing with `uv`. Fixing it
  edits the shell config, so it waits for the owner.

**On a legacy project.** The loop is the same; tasks start with
characterization tests before the first change, and Spec Kit has PowerShell
scripts for Windows (`--script ps`).

**Still to practise.** Spec Kit in Brain Gym with a constitution that links
to `AGENTS.md` (M10, Odd One Out). Roles: a separate implementer and
reviewer (M9).

## M9: Implementer and reviewer roles

**Concept.** Nobody grades their own work. One role builds (the implementer),
another checks (the reviewer), with different instructions, fewer
permissions and a fresh context. A plain script gathers the facts (tests,
the Red proof, the diff); the reviewer only judges. A gate in CI makes the
review a lock: no merge without a current, approved review of exactly this
code.

**Why it matters.** An agent that reviews its own work shares its own blind
spots: in M8 it wrote "allowed by Principle I" and believed it. A second
reviewer found problems the first missed, in every round.

**.NET comparison.** Maker-checker in a bank; a required reviewer on a pull
request; Azure DevOps build validation. Facts go to tests and analyzers;
code review is for judgement.

**The principles, with the evidence.**

| Principle | What showed it |
| --- | --- |
| The checker can't change what it checks | The reviewer has only Read, Grep and Glob. Edits and shell writes to `review.md` are blocked by the hook |
| Test the checker with a known answer | Given a half-done feature, the reviewer said CHANGES NEEDED and named the missing requirement |
| Facts for the script, judgement for the AI | Round 2 approved an unfinished feature (severity drifted from major to minor). Now the gate counts unticked tasks, and the script proves each Red step |
| Don't trust an instruction to be followed; put the input in front of it | "Don't skim" was ignored twice. Now every feature file and the project rules go into the prompt in full |
| An approval belongs to an exact version | The gate checks that no code changed after the reviewed commit |
| The rules of the process are part of the product | The reviewer noticed its own instructions changing in the branch; now `.claude/` files need a fresh review |
| Bound the loop | After 3 rounds of CHANGES NEEDED, a human decides |
| Honest gaps beat hidden ones | Every review lists "Not checked"; that is how we caught the skimming |
| A block is a stop sign | The implementer stopped when it couldn't create a branch, and left T017 unticked rather than work around a block |

**Mistakes and surprises.**

- **My setup broke our own rule.** The sandbox worked on `main` with no
  branch, and I gave the implementer no permission to create one. It
  stopped and asked; I created the branch.
- **"Used other ways" when a command was denied.** Harmless here (read-only
  commands), but it is the pattern we don't want. A denial is a stop sign.
- **Wrong blame.** The implementer said "the factory hook" blocked it; it
  was Claude Code's own permission check. Check which layer said no.
- **A false positive in our hook:** reading `core.hooksPath` was blocked.
  Fixed: only changing it is blocked.
- **zsh is not bash:** `echo ======` is a special expansion, and an unquoted
  `$args` is not split into words. Two of my own checks were wrong; the
  code was right.
- **A useless speed test:** macOS `base64` writes one long "word". Check
  that a test can fail before trusting it passes.
- **Approval without a re-review:** after T015–T017 only Markdown changed,
  so the old approval still counted. That is the rule as designed (docs
  aren't re-reviewed), but it showed the `.claude/` gap.

**On a legacy project.** The roles work the same: the reviewer reads the
spec, the rules and the diff; the script runs `dotnet test` at each Red
commit. The gate needs the feature's tasks and review in the repo, so start
using the task loop before expecting the gate to protect anything.

**Still to practise.** The whole loop on a real Brain Gym feature (M10).
Different models as reviewer (does Opus find what Sonnet misses?) in M11.

## M10: The first end-to-end feature, and the retro

**Concept.** Parts that work alone can fail where they join. M10 ran the
whole factory on real work (a new Brain Gym game, from spec to merge) and
ended with a retro: keep, change, drop, each with evidence. The answers
changed the kit and the principles. The factory improves from its own use.
Details: [retro](retros/m10-odd-one-out.md).

**Why it matters.** Only a real run shows the joins: proofs that ran in the
wrong place, a tool that broke the project's own checks, permissions that
stopped every run, a reviewer judging what the gate already counts.

**.NET comparison.** A sprint retrospective in Azure DevOps, but the action
items change the pipeline itself, not only the team's habits.

**What we learned (all in [principles](principles.md)).**

- The factory cost about 65 times a plain fix, and bought proof. Match the
  weight of the process to the risk.
- A proof must run where the real thing runs.
- A test that depends on chance proves nothing reliably (3 misses in 8).
- Smallest world, but complete: missing permissions stop agents, or worse.
- Agents narrowed a rule to fit their plan, for the second time.
- Tool-written files stay out of project tools (third time).

**Mistakes and surprises.**

- The constitution's links worked: the spec used the corrected Stop rule
  without being told.
- `AGENTS.md` had copied a wrong rule from `games.md`: a copy kept an error
  alive in two places (one fact, one place).
- I passed a prompt after `--allowedTools`, which swallowed it.
- The implementer twice needed my help to finish a proof (a combined command
  needed approval); I did the proof myself, which is stronger evidence.

**On a legacy project.** Start with the short loop (a failing test, the fix,
the reviewer) and earn the record on small fixes; use the full loop for
features once an area has tests.

**Still to practise.** M11: compare agents and models on the same task
(fleet comparison), using the usage log.

## M11: Fleet comparison (which model for which role)

**Concept.** Choose agents by evidence. A fair comparison changes one thing
(the model), keeps everything else fixed (task, prompt, checks), scores
against a known answer (planted bugs), and repeats each run, because AI
answers vary. Details: [experiment](experiments/m11-reviewer-models.md).

**Why it matters.** Until M11 the reviewer was Sonnet by feel. Now it is
Sonnet by evidence, with Opus for risky areas, and a method to check again
when models change.

**.NET comparison.** BenchmarkDotNet: the same code and input, several
iterations, compare the results, not one lucky run.

**What we found.**

- All three models found all 4 planted bugs: the test was too easy to tell
  them apart (a ceiling effect). Include hard bugs next time.
- Haiku invented findings in both runs and wrote the most: cheaper per token
  is not cheaper per review.
- Opus rated the kids'-data bug critical both times; Sonnet said major.
- Each model was consistent with itself across two runs.

**Mistakes and surprises.**

- **I built on a PR that wasn't merged.** "Merged" in chat was about the
  factory's PR #10, not Brain Gym's PR #10, and I didn't check. The
  experiment was still fair (every run had the same broken Red proof), and
  all six reviewers flagged that as an unplanned fifth problem.
- **Our own hook blocked me** when I wanted to copy reviews out and restore
  them between runs. I stopped and asked; the owner chose a method where the
  project's review was never touched. The hook also had a false positive
  (copying *from* `review.md`), now fixed.
- **Planting bugs was hard:** Brain Gym's tests caught both logic bugs, and
  hiding them needed six test changes. The safety net works.
- **macOS bash 3.2:** an empty array is an error under `set -u`; the
  `--model` option uses the safe form.

**On a legacy project.** Compare before you commit a team to a model:
plant known bugs in a copy of a real change, and measure.

**Still to practise.** Compare implementers (cost and corrections per
task), with harder planted bugs.

## After M11: Isolation

**Concept.** The box decides, not the words. Our agent hook reads command
text; isolation removes secrets, the network and the home folder from the
agent's world. Claude Code's sandbox (macOS Seatbelt) does this for shell
commands, and deny rules do it for the Read tool.

**Why it matters.** Before this, agents ran with my GitHub login (enough to
turn off branch protection) and could read the live database token in
`.env.local`. Only a written rule and an "ask" stood in the way.

**.NET comparison.** Running a service under a low-privilege account with no
access to the production connection string, instead of trusting the code not
to use it.

**What we proved, as a pair.**

| | Outside the box (control) | Inside the box |
| --- | --- | --- |
| `.env.local`, GitHub config and token | reachable | blocked |
| Unknown website, GitHub API | reachable | blocked |
| Writing in the home folder | reachable | blocked |
| Writing in the project, running programs | works | works |
| Read tool on a decoy `.env.local` | read | refused |

**Mistakes and surprises.**

- My first probe **skipped** `.env.local` because, inside the box, the file
  looked missing. A skipped check must never look like a pass: now there's
  no skip, and the control run proves each secret exists.
- The reviewer's Read tool could have read `.env.local`. `review.sh` now
  always passes the sandbox settings and refuses to run without them.
- The Read-tool rule was tested on a decoy, never on the real token: if the
  rule had failed, the test itself would have leaked the secret.

**Still to do.** The owner moves the database token out of `.env.local` and
creates a limited GitHub token for agents. A full box (dev container or
cloud sessions) for unattended runs.

**Phase 3: the box (Docker container).** The Mac sandbox looked complete
until the probe found its missing wall: sandboxed commands could still read
the Mac keychain. The container has no keychain at all. Probe pair: on the
Mac, 5 of 5 forbidden things reachable; in the box, 5 of 5 blocked, while
GitHub, npm and Claude's API work. The first real task in the box wrote and
proved its tests, then could not push (the firewall had looked up GitHub's
address once), and the box deleted itself with the work inside. Now the box
allows GitHub's published ranges, refreshes the other names, and keeps the
commits until the push is confirmed. The second run opened Brain Gym PR #12;
I repeated its proof by breaking the code myself, and each test caught
exactly its own bug.

**More mistakes and surprises.**

- A quiet build (`-q`) hid a 19-minute hang; only a build log showed the step.
- The slim base image had no certificates, so packages came over plain HTTP,
  which timed out. The full image plus HTTPS fixed both.
- The GitHub CLI's package server keeps only recent versions, so it couldn't
  be pinned; it now comes from GitHub's release, checked against its
  checksum.

**Your own sessions.** Git used to take your full login from the Mac
keychain, whatever token the session had. Now git asks `gh`, which follows
the session's `GH_TOKEN`: the agent token when Claude is started with
`claude-agent.sh`, your login in your own terminal. A guard asks before a
GitHub write in a session without the agent token. Mistake on the way: my
first check printed nothing, because macOS `sed` doesn't understand `\|`
(the same macOS-versus-GNU trap as `\b` in M5).

## M12: Which model should implement?

**Concept.** The M11 method for builders: the same task and fresh clone for
every run (the agent box makes that easy), a known answer as **hidden tests**
the agents never see, scoring by a script written before the runs, and two
runs per model. Details: [experiment](experiments/m12-implementer-models.md).

**Why it matters.** The implementer writes the code. Choosing its model by
feel would waste money, or quality.

**.NET comparison.** Acceptance tests kept by QA, not shown to the developer,
so the code meets the spec instead of the tests.

**What we found.** Haiku, Sonnet and Opus all passed 12 of 12 hidden tests,
kept the `dayKey()` rule, made a real Red step, and wrote tests that caught
all 4 broken versions. Sonnet used the fewest tokens and was fastest; Haiku
wrote two to three times as much. Decision: Sonnet for small, well-specified
tasks; Opus for features until a feature-sized test says otherwise.

**Mistakes and surprises.**

- **The ceiling effect again**, one milestone after writing it down. The
  traps were real (a UTC version fails them), but too easy for every model.
  Knowing a principle isn't the same as designing for it.
- I added a second measure (each agent's tests against broken versions)
  after seeing the first results. It was applied identically to all runs,
  and said so in the write-up.
- My scoring script first looked for the work under the branch name; the
  bundle stores it as `HEAD`. Fixed before any result existed.
- The box's outbox would have landed inside `.factory/` in a project, which
  breaks the kit's checksums; it now goes to `~/factory-outbox`.

**Still to practise.** A feature-sized, somewhat ambiguous task, with a
control run without the factory's rules: does the factory, not the model,
make the difference?

## After M12: Project standards

**Concept.** Each project keeps its coding standards and guidelines in
`docs/brain/standards/`, next to the architecture and the ADRs. Every rule
has an ID (`STD-012`), a level (`must` = standard, `should` = guideline) and
a why. The implementer reads them before any code; `review.sh` puts them in
the reviewer's prompt every time, and findings name the rule. ADRs have a
status, and only `accepted` ones are followed. A small change is edited in
place; a real change of mind is a new ADR that replaces the old one.

**Why it matters.** Without this, "follow our standards" depends on the
agent choosing to open a file. With the rules in the reviewer's prompt, a
broken `must` rule blocks APPROVE every time (principle 30: put the input in
front of it).

**.NET comparison.** Rule IDs work like compiler error codes (`CS0168`):
short, searchable, the same everywhere. An analyzer with
`TreatWarningsAsErrors` is the strong version of a `must` rule; that is where
a rule should end up once a tool can check it.

**Where it came from.** A comparison with two large team repos (a Go + React
repo and a .NET repo; details stay out of this repo). Both keep a short root
file that points to rules elsewhere, and a decision log of ADRs. The .NET
team loads its C# and test conventions as skills. The Go team built its own
agent fleet (orchestrator, seats, a red-team for plans); the .NET team copied
it and later removed the machinery. Claude Code now has subagents, worktrees
and agent teams built in, so the kit builds rules and proof on top
(principle 43). The ideas are tracked in `docs/ideas.md`.

**Mistakes and surprises.**

- I said I had compared the repos when I had read only parts of some
  folders (the fleet tooling, `.agents`, `.claude`). Each time you asked
  "have you read …?", the honest answer was "partly". Say what was read and
  what wasn't, up front.
- Twice I added table rows above the row they should follow. Check the
  order after an edit, not only that the edit applied.
- A test that "leaves out" non-accepted ADRs passed before the code
  existed, because nothing was listed at all. A mutation (removing the
  status filter) proved it has teeth.

**The known-answer test** ([experiment](experiments/standards-known-answer.md),
2026-11-24). Three planted mistakes in Brain Gym, two runs each: the
reviewer named the broken rule by its ID every time, including one that only
the standards file states. Two weaknesses: it never opened an ADR from the
list (it caught the Stop mistake through `AGENTS.md`), and once it rated a
broken `must` rule as minor, against its own instructions. Lesson: a list
is a request, the content in the prompt is a fact; and a severity rule the
AI applies is judgement, so the script must check it (ideas 38 and 39).
The agent hook also blocked me from moving a `review.md` to start a clean
run. It was right; the owner moved it, and the next runs used fresh
checkouts.

**Role commands (idea 31).** `/review-pr <N>` lets the human order a review
in Claude instead of typing the script's path. Facts stay in a script
(`review-pr.sh` checks the checkout is the PR, at the same commit as on
GitHub); the skill only starts it and reports. The name came from a check
of the docs: `/review` is the alias of the built-in `/code-review`, and a
project skill doesn't replace an alias. Mutations caught two weak tests on
the way: one read a file left over from an earlier run, one searched line
by line for words split over two lines.

**Still to practise.** Does the implementer really read the standards when
nothing forces it?
