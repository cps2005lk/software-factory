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
