# User guide: working with the software factory

For someone new to agentic development. Follow the parts in order the first
time. Every step says **what to do** and **how you know it worked**
(*Check:*). Commands assume a Mac, and that the factory repo is cloned at
`~/Dev/software-factory`.

- [What the factory is](#what-the-factory-is)
- [Part 1: Set up your Mac (once)](#part-1-set-up-your-mac-once)
- [Part 2: Start a new application](#part-2-start-a-new-application)
- [Part 3: Onboard an existing application](#part-3-onboard-an-existing-application)
- [Part 4: Everyday work: choose the loop](#part-4-everyday-work-choose-the-loop)
- [Part 5: Run work in the box](#part-5-run-work-in-the-box)
- [Part 6: Keep it healthy](#part-6-keep-it-healthy)
- [Troubleshooting](#troubleshooting)
- [Cheat sheet](#cheat-sheet)

## What the factory is

An AI agent (here: Claude Code) can read code, run commands and change files
on its own. That's powerful and risky: it forgets everything between
sessions, it reinterprets rules, and it can break what it can reach. The
factory is the set of **rules, checks and roles** around the agent, so it can
do real work safely.

Six words you'll meet:

| Word | Meaning |
| --- | --- |
| **Kit** | The factory's files, copied into each project as `.factory/`. Never edit them there; change them in the factory and reinstall |
| **Brain** | The project's knowledge for agents: a short `AGENTS.md` plus `docs/brain/` |
| **Check** | A script that refuses: it blocks a commit, a push, a merge or a command |
| **Role** | An agent with a job: the *implementer* builds, the *reviewer* checks (read-only) |
| **Box** | A Docker container where unattended agents work, with no access to your Mac |
| **Rung** | How much an agent may do in one area of a project: 1 read-only, 2 small PRs, 3 features |

The rules behind all of it are in [principles.md](principles.md). The five
that matter most: a written rule asks, a check refuses; files are the truth,
not memory; every claim needs proof; nobody grades their own work; match the
weight of the process to the risk.

## Part 1: Set up your Mac (once)

1. **Install the tools.**
   - Git, the GitHub CLI and Node: `brew install git gh node` (Homebrew).
   - Claude Code: follow the official install page, then log in with
     `claude` (your Claude subscription).
   - Docker Desktop (for the box): install it from Docker's site and start it.
   - Spec Kit (for features): `brew install uv`, then
     `uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@v<version>`.
     Pick a release about two weeks old.

   *Check:* `git --version`, `gh --version`, `claude --version` and
   `docker info` all answer.

2. **Log the GitHub CLI in:** `gh auth login`. This is *your* login, with full
   rights. Agents won't use it.

3. **Get the factory:** `git clone https://github.com/cps2005lk/software-factory ~/Dev/software-factory`.

4. **Create the agent's GitHub token** (a limited one, so agents can never
   change settings or CI):
   - GitHub → your picture → **Settings** → **Developer settings** →
     **Personal access tokens** → **Fine-grained tokens** → **Generate new
     token**.
   - Name `factory-agents`, expiry 90 days, **only the repositories the agents
     work on**.
   - Permissions: **Contents: Read and write**, **Pull requests: Read and
     write**. Everything else **No access** (especially Administration and
     Workflows).
   - Save it in the keychain (paste it when asked; it isn't shown):
     `security add-generic-password -a "$USER" -s factory-agents-gh -w`
   - Put the expiry date in your calendar.

   *Check:* `security find-generic-password -s factory-agents-gh >/dev/null && echo ok`.

5. **Add the launcher** to `~/.zshrc`, then open a new terminal:
   ```sh
   alias claude-agent="$HOME/Dev/software-factory/.factory/adapters/claude/claude-agent.sh"
   ```
   `claude-agent` starts Claude with the agent token. Use it for agent work;
   use plain `claude` only when *you* need your full rights.

   *Check:* in a `claude-agent` session, type `! gh auth status`: it says
   "Logged in … (GH_TOKEN)".

6. **Secrets stay out of projects.** Tokens with real power (a database
   management token, cloud keys) live in your password manager, never in a
   project's `.env` files: agents work in the project folder.

## Part 2: Start a new application

1. **Create the repository** on GitHub, then clone it into `~/Dev/<app>`.
   Branch protection (step 10) is free on public repositories; private ones
   need a paid plan.

2. **Make a first commit** on `main` (for example a one-line `README.md`),
   and push it. This is the last time anyone pushes to `main` directly.

3. **Install the kit:** `~/Dev/software-factory/scripts/install.sh .`, then
   commit `.factory/`. The install refuses if you have uncommitted changes.

   *Check:* `cat .factory/VERSION` shows the factory's version.

4. **Write the brain.** Copy the templates, then fill them in (you can ask
   Claude to help, from your description of the app):
   ```sh
   cp ~/Dev/software-factory/kit/templates/brain/AGENTS.md.template AGENTS.md
   cp -R ~/Dev/software-factory/kit/templates/brain/docs .
   ```
   Keep `AGENTS.md` short: only what an agent would get wrong without it. The
   reasons and details go in `docs/brain/`. **Never create a `CLAUDE.md`**: it
   switches off `AGENTS.md`.

   Write the first **standards and guidelines** in `docs/brain/standards/`
   (each rule gets an ID like `STD-001`, a level `must` or `should`, and a
   why; see its `README.md`). Record each big decision as an ADR in
   `docs/brain/decisions/`. The implementer reads both before any code, and
   the reviewer judges every change against them. You change them through a
   pull request; agents only propose.

   *Check:* `docs/brain/standards/` has at least one real rule, not only the
   template's example.

5. **Write `scripts/check.sh`** from `~/Dev/software-factory/kit/templates/check.sh.template`
   (your build, tests, lint, format, plus the two factory lines), and
   `chmod +x scripts/check.sh`.

   *Check:* `scripts/check.sh` passes.

6. **Turn on the git hooks and the identity** (once per clone):
   ```sh
   .factory/guardrails/setup-hooks.sh
   .factory/adapters/claude/setup-identity.sh
   ```
   *Check:* a commit on `main` is refused ("you are on 'main'. Make a branch first").

7. **Turn on the agent hook and the roles:**
   ```sh
   mkdir -p .claude/agents .claude/skills
   cp .factory/adapters/claude/settings.json .claude/settings.json
   cp .factory/adapters/claude/agents/*.md .claude/agents/
   cp -R .factory/adapters/claude/skills/. .claude/skills/
   ```
   *Check:* in a Claude session, ask it to run `git push --dry-run --no-verify`:
   it is blocked with "factory: risky-command: blocked".

8. **Keep tool-written files out of your formatter.** Add to its ignore file
   (for Prettier, `.prettierignore`): `.factory`, `specs/*/review.md`, and
   later Spec Kit's own files (listed in the onboarding playbook, step 4).

9. **Add CI:** copy `~/Dev/software-factory/kit/templates/ci/check.yml` to
   `.github/workflows/check.yml` (adjust the setup steps for your language).
   From now on, work on a branch and open a pull request:
   ```sh
   git switch -c setup && git add -A && git commit -m "Factory setup" && git push -u origin setup
   gh pr create --fill
   ```
   *Check:* the PR shows a green **check**. Merge it on GitHub.

10. **Turn on branch protection** (GitHub → repository **Settings** →
    **Branches**; a human step): require a pull request, include
    administrators, block force pushes and deletion, and require the status
    check **check**, with the branch up to date.

    *Check:* from a fresh clone, `git push origin main` is refused by GitHub.

11. **Set up Spec Kit** (for features), on a branch:
    `specify init --here --integration claude --script sh --integration-options="--no-model-invocation"`.
    Read what it wrote (`git status`) before committing. Replace
    `.specify/memory/constitution.md` with one that **links** to `AGENTS.md`
    instead of copying it, and says "test first".

12. **Fill in `docs/brain/trust.md`**: every area starts on rung 1, and
    climbs to rung 2 once it has tests that pass a mutation check.

You're ready for [Part 4](#part-4-everyday-work-choose-the-loop).

## Part 3: Onboard an existing application

The order matters: **look, then write down, then protect, then change.** The
full method is in `.factory/playbooks/onboarding.md` (after step 1 below).

1. **Install the kit** (Part 2, step 3) on a branch.
2. **Discovery (read-only).** Start Claude and ask for a read-only walk
   through the project: build and test commands, what passes today, config,
   database, entry points, where secrets are. Nothing may change. Mark every
   guess as "Unverified".
3. **Baseline.** Measure today's state (does the build pass, which tests
   fail, how long a small task takes) so later claims can be compared.
4. **The brain** (Part 2, step 4): move what's true into `AGENTS.md` and
   `docs/brain/`, link to existing docs instead of copying them, and delete
   any `CLAUDE.md`. Existing coding rules (a wiki page, an `.editorconfig`
   comment, "how we do it here") become rules in `docs/brain/standards/`;
   existing decisions become ADRs.
5. **The safety net.** Before agents change an area, it needs tests that
   would notice a break. For code nobody fully remembers, write
   *characterization tests* (record what the code does today). Then break the
   code on purpose: a test must fail (a mutation check). Start where risk ×
   change × missing tests is highest.
6. **Guardrails:** Part 2, steps 5 to 10.
7. **The trust ladder:** fill in `docs/brain/trust.md`. Areas with a
   mutation-checked safety net start on rung 2; the rest stay on rung 1.

Legacy .NET: the same steps, with `dotnet build` and `dotnet test` in
`check.sh`, characterization tests with Verify, coverage with coverlet,
mutation tests with Stryker.NET (details in the onboarding playbook). The
box's image is Node-based today; a .NET project needs a .NET SDK base image
in `.factory/container/Dockerfile` (change it in the factory, not there).

## Part 4: Everyday work: choose the loop

**Match the weight of the process to the risk.** Always on a branch, always a
pull request, always a human merge.

| Change | Loop |
| --- | --- |
| Docs, a typo | Branch, commit, PR. You read it, CI is green, merge |
| A small fix in a tested area | **The short loop** below |
| A feature, or anything risky (money, kids' data, access, time) | **The full loop** below |
| Database migrations, settings, deploys | Always human. Agents may draft |

**The short loop** (rung 2):

1. `git switch -c fix-<name>`, then `claude-agent --agent implementer`.
2. Describe the fix. The implementer writes a failing test first (a `Red:`
   commit with tests only), then the fix (`Green:`).
3. Check its proof yourself for anything important: break the code on
   purpose, and the new test must fail.
4. Push, open a PR, read every line, merge.

**The full loop** (features):

1. `git switch -c <nnn-feature>`, then `claude-agent`.
2. `/speckit-specify <what and why>`. **Stop and read `spec.md`**: you decide
   the product questions it lists. Mistakes are cheapest here.
3. `/speckit-plan`, then `/speckit-tasks`; read both.
4. `/speckit-analyze` (a second reviewer, read-only). Fix the critical
   findings on paper, in a **fresh** session.
5. Build: `claude-agent --agent implementer`, then "Do the tasks in
   tasks.md". Or run it in the box (Part 5).
6. Review with the read-only reviewer, one of two ways:
   - **In Claude:** push the branch, open a draft PR, then type
     `/review-pr <PR number>` (add `--model opus` for risky areas). It
     checks that your checkout is that PR, runs the reviewer and reports
     the findings.
   - **In the terminal:** `.factory/adapters/claude/review.sh specs/<nnn-feature>`.

   Commit `review.md`. On CHANGES NEEDED, the implementer fixes and you
   review again; after 3 rounds, you decide (only you can run
   `review.sh --another-round`).
7. Your checks: the human tasks in `tasks.md` (play tests, checks by eye).
8. Push, open the PR. CI's review gate passes only with an approved review
   of exactly this code and every task ticked. Read every line, merge.

After a merge with no corrections, add it to that area's record in
`trust.md` (5 in a row to climb a rung).

## Part 5: Run work in the box

The box is for work nobody watches: a fresh clone, a firewall, the agent
token, and nothing from your Mac. Docker Desktop must be running.

1. **Build it** (once, and after kit updates): `.factory/container/run.sh build`.
2. **Log Claude in, inside the box** (once): `.factory/container/run.sh login`.
3. **Prove it** (after every build):
   ```sh
   PROBE_REPO=<owner>/<repo> GH_TOKEN="$(security find-generic-password -a "$USER" -s factory-agents-gh -w)" .factory/container/probe.sh --control
   .factory/container/run.sh probe <owner>/<repo>
   ```
   *Check:* the first (on your Mac) says "Control as expected"; the second
   (in the box) says "Isolation holds". If not, don't use the box.
4. **Give it a task:** write the task in a file, then
   ```sh
   .factory/container/run.sh task <owner>/<repo> <branch> "PR title" < task.txt
   ```
   The agent writes and proves the change; the script checks it, pushes the
   branch and opens a **draft** PR. You mark it ready, read every line and
   merge.
5. **If the push failed,** the work is safe: `.factory/container/run.sh outbox`
   copies it to `~/factory-outbox`.

Which model: `AGENT_MODEL=sonnet` for small, well-specified tasks; the
default (Opus) for features (from the factory's experiments, M11 and M12).

## Part 6: Keep it healthy

- **Update the kit** when the factory changes: pull the factory, then on a
  branch run `~/Dev/software-factory/scripts/install.sh .`. If a hook or role
  changed, copy `settings.json` and the agents again: `scripts/check.sh`
  tells you ("missing or edited in .claude/settings.json").
  - **From kit 0.15.0:** `docs/brain/conventions.md` became
    `docs/brain/standards/`. Copy `README.md`, `coding.md` and `testing.md`
    from `.factory/templates/brain/docs/brain/standards/`, move your rules
    from `conventions.md` into them with IDs, and delete `conventions.md`.
    Copy `decisions/README.md` too, and copy the agents again.
  - **From kit 0.17.0:** the `/review-pr` command. Copy it once:
    `mkdir -p .claude/skills && cp -R .factory/adapters/claude/skills/. .claude/skills/`.
  - **From kit 0.18.0:** the Stop hook. Copy `settings.json` again (or
    merge its new `Stop` part into yours); `scripts/check.sh` tells you.
- **Change a standard or an ADR** through a pull request, never inside a
  feature's code change. Small change: edit in place. A real change of a
  decision: a new ADR that replaces the old one
  (`docs/brain/decisions/README.md`).
- **Usage log:** each session writes `docs/usage/<date>-<session>.yml`.
  Commit them with your PRs, and add `task` and `corrections`.
  `.factory/usage/report.sh` shows what's missing.
- **Retro** after a big feature: keep, change, drop, with evidence. Change
  the factory (not the project's copy) and reinstall.
- **Renew** the agent token before it expires, and re-run `run.sh login` if
  the box says it isn't logged in.

## Troubleshooting

| You see | It means | Do |
| --- | --- | --- |
| "factory: risky-command: blocked" | A guard stopped the agent | Good. Read the reason; don't work around it |
| A permission prompt about "your full login" | A GitHub write in a session without the agent token | Say yes only if *you* meant it; next time start with `claude-agent` |
| "you are on 'main'. Make a branch first" | The git hook works | Make a branch |
| "factory stop-check: before you stop, there is unfinished work" | The Stop hook sent the agent back once: uncommitted changes, commits on `main`, or failing checks | Let it finish. If the changes are yours, say so; the second stop is always allowed. Claude Code shows the whole hook command first, including its "this branch has no … stop.sh" fallback text; that part only runs on old branches |
| "missing or edited in .claude/settings.json" | The project's copy drifted from the kit | Copy `.factory/adapters/claude/settings.json` again |
| `review-gate: … the review does not approve` / `tasks not done` | CI wants a current, approved review and every task ticked | Run `review.sh` again; finish or tick the tasks |
| "install: uncommitted changes" | The install wants a clean start | Commit or stash first |
| "firewall: … Stopping." | The box couldn't prove its firewall | Don't use it; check Docker and the network |
| "the push failed 3 times" | GitHub unreachable from the box | `run.sh outbox`; your work is in `~/factory-outbox` |

## Cheat sheet

```sh
# Once per Mac: tools, gh auth login, the agent token in the keychain, the alias.
# Once per project:
~/Dev/software-factory/scripts/install.sh .            # install / update the kit
.factory/guardrails/setup-hooks.sh                     # git hooks (once per clone)
.factory/adapters/claude/setup-identity.sh             # git follows the session's token
# Every day:
claude-agent                                           # a session with the agent token
claude-agent --agent implementer                       # the builder role
.factory/adapters/claude/review.sh specs/<feature>     # the read-only reviewer
/review-pr <PR number>                                 # the same, from inside Claude
scripts/check.sh                                       # everything must pass
.factory/usage/report.sh                               # what agents cost, what's unfilled
# The box:
.factory/container/run.sh build | login | probe <owner/repo> | task … < task.txt | outbox
```
