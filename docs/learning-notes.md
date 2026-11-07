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
