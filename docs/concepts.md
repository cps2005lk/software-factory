# Concept index

Every concept learned so far, in one line each. The full story (why it
matters, the .NET comparison, our mistakes) is in the
[learning notes](learning-notes.md), linked by milestone.

Updated at the end of every milestone.

## Agents and their reach

| Concept | In one line | Learned |
| --- | --- | --- |
| Harness | Everything around the agent: instructions, tools, checks, limits and feedback loops | [M0](learning-notes.md#m0-harness-engineering-and-blast-radius) |
| Blast radius | The worst damage one mistake can do with the access an agent has today | [M0](learning-notes.md#m0-harness-engineering-and-blast-radius) |
| Smallest world | Give an agent the least access that still does the job, like a device-only app instead of the live database | [M0](learning-notes.md#m0-harness-engineering-and-blast-radius), [M5](learning-notes.md#m5-safety-nets) |
| Leaked secret order | Replace the secret first, then clean history; deleting the file does nothing | [M0](learning-notes.md#m0-harness-engineering-and-blast-radius) |
| Trust ladder | An agent starts read-only and earns more by proof: read-only → small PRs → features (5 PRs in a row with no correction to climb) | [M6](learning-notes.md#m6-request-vs-enforcement-and-the-trust-ladder) |
| Trust per area | One agent can be on different rungs in different parts of a project; an area without mutation-checked tests stays read-only | [M6](learning-notes.md#m6-request-vs-enforcement-and-the-trust-ladder) |
| Going down | One serious slip (getting around a guardrail, a guess stated as fact) drops that area one rung until a check or rule fixes the cause | [M6](learning-notes.md#m6-request-vs-enforcement-and-the-trust-ladder) |
| Always human | Merging, repo settings, deploying, the live database, secrets, installing software: on every rung | [M6](learning-notes.md#m6-request-vs-enforcement-and-the-trust-ladder) |

## Instructions and knowledge

| Concept | In one line | Learned |
| --- | --- | --- |
| Instruction loading | A rule only helps if the file is loaded; check the debug log, not the reply | [M1](learning-notes.md#m1-instruction-loading) |
| `CLAUDE.md` switch-off | One project `CLAUDE.md` silently stops Claude Code from loading `AGENTS.md` (a personal `~/.claude/CLAUDE.md` does not) | [M1](learning-notes.md#m1-instruction-loading), [M4](learning-notes.md#m4-the-brain) |
| Folder instruction files | Arrive late and look like tool output: hints, not rules | [M1](learning-notes.md#m1-instruction-loading) |
| The brain | A project's knowledge, written so anyone can work without its author | [M4](learning-notes.md#m4-the-brain) |
| Pocket card vs shelf | `AGENTS.md` is short and always loaded; `docs/brain/` is read on demand | [M4](learning-notes.md#m4-the-brain) |
| Sorting rule | Would an agent get it wrong? → `AGENTS.md`. Does the code already say it? → don't write it | [M4](learning-notes.md#m4-the-brain) |
| Rule vs reason | The rule goes in `AGENTS.md`; the reason goes in the brain | [M4](learning-notes.md#m4-the-brain) |
| One fact, one place | A copy is a fact nobody updates; link instead | [M4](learning-notes.md#m4-the-brain) |
| `> Unverified:` | Mark every guess; a wrong fact is worse than a missing one | [M4](learning-notes.md#m4-the-brain) |
| Evidence vs proof | Generated types suggested a migration ran; a read-only query proved it | [M4](learning-notes.md#m4-the-brain) |
| ADR | One decision per file: context, decision, consequences, alternatives | [M4](learning-notes.md#m4-the-brain), [M5](learning-notes.md#m5-safety-nets) |
| Personal vs project | How one person likes to work goes in their personal file, not the repo | [M4](learning-notes.md#m4-the-brain) |
| Freshness rule | Code and its brain doc change in the same pull request | [M4](learning-notes.md#m4-the-brain) |

## Task loop and handoffs

| Concept | In one line | Learned |
| --- | --- | --- |
| Task loop | Spec → plan → tasks → one task (failing test, code, commit, tick) → next | [M8](learning-notes.md#m8-the-task-loop-and-handoffs) |
| Handoff | A fresh session knows only what is in files; chat-only instructions don't exist for it | [M8](learning-notes.md#m8-the-task-loop-and-handoffs) |
| Stale memory | After a human edits the plan, start a fresh session so the agent reads the new version | [M8](learning-notes.md#m8-the-task-loop-and-handoffs) |
| Handoff test | Stop halfway, start a fresh session with no hint: it must continue at the first unticked task | [M8](learning-notes.md#m8-the-task-loop-and-handoffs) |
| Constitution | Project rules for Spec Kit; it links to `AGENTS.md` instead of copying it | [M8](learning-notes.md#m8-the-task-loop-and-handoffs) |
| Rule bending | Agents reinterpret rules to fit their plan; change a wrong rule in the open instead | [M8](learning-notes.md#m8-the-task-loop-and-handoffs) |
| Two reviewers | A human and `/speckit-analyze` found different problems | [M8](learning-notes.md#m8-the-task-loop-and-handoffs) |
| Same-reason failures | Tests that all fail because there's no output prove little; a mutation check shows which have teeth | [M8](learning-notes.md#m8-the-task-loop-and-handoffs) |
| Version cooldown | Pin a release about two weeks old, so others find its problems first | [M8](learning-notes.md#m8-the-task-loop-and-handoffs) |
| Tick is a claim | Verify: check out the Red commit, re-run the mutation | [M8](learning-notes.md#m8-the-task-loop-and-handoffs) |

## Roles and review

| Concept | In one line | Learned |
| --- | --- | --- |
| Separation of duties | One role builds, another checks; nobody grades their own work | [M9](learning-notes.md#m9-implementer-and-reviewer-roles) |
| Read-only checker | A reviewer that can edit becomes a second implementer; give it no shell and no edit tools | [M9](learning-notes.md#m9-implementer-and-reviewer-roles) |
| Facts vs judgement | If a computer can check it exactly, a script checks it; AI judgement drifts between rounds | [M9](learning-notes.md#m9-implementer-and-reviewer-roles) |
| Evidence by script | The script proves Red steps and runs checks, then hands the results to the reviewer as facts | [M9](learning-notes.md#m9-implementer-and-reviewer-roles) |
| Put the input in front of it | An instruction like "don't skim" is a request; putting the files in the prompt makes it so | [M9](learning-notes.md#m9-implementer-and-reviewer-roles) |
| Known-answer test | Test a checker on work whose problems you already know | [M9](learning-notes.md#m9-implementer-and-reviewer-roles) |
| Approval is per version | A review approves one exact commit; code changed after it needs a new review | [M9](learning-notes.md#m9-implementer-and-reviewer-roles) |
| Guard the guards | Changing the reviewer's instructions needs a fresh review, like code | [M9](learning-notes.md#m9-implementer-and-reviewer-roles) |
| Bounded loop | After 3 rounds of changes needed, a human decides | [M9](learning-notes.md#m9-implementer-and-reviewer-roles) |
| Review gate | CI fails a feature without a current, approved review and with open tasks | [M9](learning-notes.md#m9-implementer-and-reviewer-roles) |
| End-to-end run | Parts that work alone can fail where they join; run the whole factory on real work | [M10](learning-notes.md#m10-the-first-end-to-end-feature-and-the-retro) |
| Retro | Keep, change, drop, each with evidence; the answers change the kit and the principles | [M10](learning-notes.md#m10-the-first-end-to-end-feature-and-the-retro) |
| Process weight | The full loop cost about 65 times a plain fix; match the process to the risk | [M10](learning-notes.md#m10-the-first-end-to-end-feature-and-the-retro) |
| Proof environment | A proof must run where the real thing runs (dependencies included) | [M10](learning-notes.md#m10-the-first-end-to-end-feature-and-the-retro) |
| Chance-dependent test | A test that uses real randomness can miss a bug; feed it fixed numbers | [M10](learning-notes.md#m10-the-first-end-to-end-feature-and-the-retro) |
| Complete permissions | Smallest world, but complete: give a headless role every permission its job needs | [M10](learning-notes.md#m10-the-first-end-to-end-feature-and-the-retro) |
| Fleet comparison | Choose models per role by measured results, not by feel | [M11](learning-notes.md#m11-fleet-comparison-which-model-for-which-role) |
| One change at a time | Same task, prompt and checks; only the model differs | [M11](learning-notes.md#m11-fleet-comparison-which-model-for-which-role) |
| Planted bugs | A known answer: bugs you put in on purpose, each keeping the checks green | [M11](learning-notes.md#m11-fleet-comparison-which-model-for-which-role) |
| Ceiling effect | If everyone finds everything, the test can't tell them apart; add hard cases | [M11](learning-notes.md#m11-fleet-comparison-which-model-for-which-role) |
| Cost per job | Cheaper per token isn't cheaper per review when false findings cost human time | [M11](learning-notes.md#m11-fleet-comparison-which-model-for-which-role) |

## Packaging

| Concept | In one line | Learned |
| --- | --- | --- |
| Kit distribution | The kit is copied into `.factory/` with a `VERSION` and a checksum per file | [M2](learning-notes.md#m2-kit-distribution) |
| Ownership boundary | The kit owns `.factory/`; the project owns the rest, and its tools must leave `.factory/` alone | [M2](learning-notes.md#m2-kit-distribution), [M6](learning-notes.md#m6-request-vs-enforcement-and-the-trust-ladder) |
| Checksums detect, don't prevent | A local edit is found at the next install, not stopped | [M2](learning-notes.md#m2-kit-distribution) |
| Fix in the factory | A kit bug is fixed in the factory, with a new version, then reinstalled | [M2](learning-notes.md#m2-kit-distribution) |
| Dogfooding | The factory installs and obeys its own kit | [M6](learning-notes.md#m6-request-vs-enforcement-and-the-trust-ladder) |

## Measuring and testing

| Concept | In one line | Learned |
| --- | --- | --- |
| Discovery | A read-only walk-through before any change | [M3](learning-notes.md#m3-discovery-and-baselines) |
| Baseline | Today's state, measured: the control group for every later claim | [M3](learning-notes.md#m3-discovery-and-baselines) |
| Measure, don't guess | A hint biases a prediction; only a measurement counts | [M3](learning-notes.md#m3-discovery-and-baselines) |
| Counting tokens | Sum the session `.jsonl` file once per reply (`unique_by(.id)`) | [M3](learning-notes.md#m3-discovery-and-baselines) |
| Spec-driven development | Write what (spec), how (plan) and steps (tasks) as files before code; mistakes are cheapest on paper | M3 (side question), [M8](learning-notes.md#m8-the-task-loop-and-handoffs) |
| Unit vs characterization test | "It should do X" vs "it does X today" | [M5](learning-notes.md#m5-safety-nets) |
| Failing test first | Red on old code proves the bug; green proves the fix | [M5](learning-notes.md#m5-safety-nets) |
| Coverage limits | Shows what ran, not what was checked; only sees one test runner | [M5](learning-notes.md#m5-safety-nets) |
| Where to test first | Risk × how often it changes × how uncovered it is | [M5](learning-notes.md#m5-safety-nets) |
| Snapshots | Let the code fill them, then read every one | [M5](learning-notes.md#m5-safety-nets) |
| Mutation check | Break the code on purpose; a test must fail, for the right reason. It tests the tests | [M2](learning-notes.md#m2-kit-distribution), [M5](learning-notes.md#m5-safety-nets), [M6](learning-notes.md#m6-request-vs-enforcement-and-the-trust-ladder) |
| Fake time | Tests control the clock; move it in steps, like real time | [M5](learning-notes.md#m5-safety-nets) |
| Browser agent | An agent that uses the app finds what unit tests can't: how parts behave together | [M5](learning-notes.md#m5-safety-nets) |
| Usage log | One record per agent session: time, model, tokens by script; task and corrections by a human | [M7](learning-notes.md#m7-agent-hooks-adapters-and-the-usage-log) |
| One file per session | New files never conflict between branches; one shared file would | [M7](learning-notes.md#m7-agent-hooks-adapters-and-the-usage-log) |
| Active vs wall time | Leave out long gaps (waiting for a human), or a 2-hour wait counts as work | [M7](learning-notes.md#m7-agent-hooks-adapters-and-the-usage-log) |
| Fake tools on PATH | A fake `gh` first on `PATH` makes a test independent of the network | [M7](learning-notes.md#m7-agent-hooks-adapters-and-the-usage-log) |
| Portability | macOS ships bash 3.2; CI's bash 5 can pass what the Mac fails | [M7](learning-notes.md#m7-agent-hooks-adapters-and-the-usage-log) |

## Guardrails

| Concept | In one line | Learned |
| --- | --- | --- |
| Request vs enforcement | A written rule can be ignored; a hook, check or permission refuses | [M1](learning-notes.md#m1-instruction-loading), [M6](learning-notes.md#m6-request-vs-enforcement-and-the-trust-ladder) |
| Lock vs hook | A lock is the goal; a hook is one way to build it | [M1](learning-notes.md#m1-instruction-loading) |
| Claude hook exit codes | Only exit code 2 blocks; 1 lets the action through | [M1](learning-notes.md#m1-instruction-loading) |
| Could not check ≠ OK | A missing check, folder, hook or executable bit must fail, never pass | [M1](learning-notes.md#m1-instruction-loading), [M2](learning-notes.md#m2-kit-distribution), [M6](learning-notes.md#m6-request-vs-enforcement-and-the-trust-ladder) |
| Missing check looks like a pass | A PR with no checks shows "mergeable", like one with green checks | [M2](learning-notes.md#m2-kit-distribution) |
| Local vs server enforcement | A git hook stops accidents (`--no-verify` skips it); a required server check stops decisions | [M6](learning-notes.md#m6-request-vs-enforcement-and-the-trust-ladder) |
| Hooks aren't cloned | Git never copies hooks, so a clone can't run a stranger's code; each clone turns them on | [M6](learning-notes.md#m6-request-vs-enforcement-and-the-trust-ladder) |
| Kit owns when, project owns what | The hook decides when checks run; `scripts/check.sh` decides what | [M6](learning-notes.md#m6-request-vs-enforcement-and-the-trust-ladder) |
| Should-block and should-allow | A check that blocks everything is as useless as one that blocks nothing | [M6](learning-notes.md#m6-request-vs-enforcement-and-the-trust-ladder) |
| Hook launcher | A small script in `.git/hooks/` that blocks when a branch has no kit, instead of git silently running nothing | [M6](learning-notes.md#m6-request-vs-enforcement-and-the-trust-ladder) |
| Required check | Branch protection names a CI job (here `check`) that must pass before a PR can merge; add the CI first, or every PR waits forever | [M6](learning-notes.md#m6-request-vs-enforcement-and-the-trust-ladder) |
| CI's smallest world | A read-only token and no secrets; the app must build and test without a database | [M6](learning-notes.md#m6-request-vs-enforcement-and-the-trust-ladder) |
| Pin actions by SHA | A tag can be moved to other code; a commit SHA can't | [M6](learning-notes.md#m6-request-vs-enforcement-and-the-trust-ladder) |
| Green is not proof | Read the log: did the tests actually run, and how many? | [M6](learning-notes.md#m6-request-vs-enforcement-and-the-trust-ladder) |
| Install-script lock | npm blocks a package's install scripts until approved: supply-chain protection | [M5](learning-notes.md#m5-safety-nets) |
| Agent hook | Claude Code runs a script before every action (`PreToolUse`); exit 2 blocks it and the agent reads the reason | [M7](learning-notes.md#m7-agent-hooks-adapters-and-the-usage-log) |
| Block vs ask | Block what must never happen; ask (a permission prompt) only where a quick human look is enough | [M7](learning-notes.md#m7-agent-hooks-adapters-and-the-usage-log) |
| Prompt fatigue | After many prompts, yes becomes automatic: an ask is only as strong as the attention behind it | [M7](learning-notes.md#m7-agent-hooks-adapters-and-the-usage-log) |
| Adapter | The check knows nothing about any tool; a small adapter plugs it into one tool (here Claude Code) | [M7](learning-notes.md#m7-agent-hooks-adapters-and-the-usage-log) |
| Text is not command | Ignore quoted text and heredoc bodies, so a commit message may mention a forbidden flag | [M7](learning-notes.md#m7-agent-hooks-adapters-and-the-usage-log) |
| Agent hooks are cloned | `.claude/settings.json` is committed, so every clone is protected at once (git hooks are not) | [M7](learning-notes.md#m7-agent-hooks-adapters-and-the-usage-log) |
| Which hooks run | The hooks of the project the session started in, not of the folder a command touches | [M7](learning-notes.md#m7-agent-hooks-adapters-and-the-usage-log) |
| Sync check | A copy drifts; a check fails when the kit's hooks are missing or edited in the project's settings | [M7](learning-notes.md#m7-agent-hooks-adapters-and-the-usage-log) |
