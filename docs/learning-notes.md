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
