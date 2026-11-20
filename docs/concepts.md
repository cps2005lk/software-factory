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
| Trust ladder | An agent starts read-only and earns more access by proving things | M6 |

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

## Packaging

| Concept | In one line | Learned |
| --- | --- | --- |
| Kit distribution | The kit is copied into `.factory/` with a `VERSION` and a checksum per file | [M2](learning-notes.md#m2-kit-distribution) |
| Ownership boundary | The kit owns `.factory/`; the project owns the rest, and its tools must leave `.factory/` alone | [M2](learning-notes.md#m2-kit-distribution), M6 |
| Checksums detect, don't prevent | A local edit is found at the next install, not stopped | [M2](learning-notes.md#m2-kit-distribution) |
| Fix in the factory | A kit bug is fixed in the factory, with a new version, then reinstalled | [M2](learning-notes.md#m2-kit-distribution) |
| Dogfooding | The factory installs and obeys its own kit | M6 |

## Measuring and testing

| Concept | In one line | Learned |
| --- | --- | --- |
| Discovery | A read-only walk-through before any change | [M3](learning-notes.md#m3-discovery-and-baselines) |
| Baseline | Today's state, measured: the control group for every later claim | [M3](learning-notes.md#m3-discovery-and-baselines) |
| Measure, don't guess | A hint biases a prediction; only a measurement counts | [M3](learning-notes.md#m3-discovery-and-baselines) |
| Counting tokens | Sum the session `.jsonl` file once per reply (`unique_by(.id)`) | [M3](learning-notes.md#m3-discovery-and-baselines) |
| Spec-driven development | Write what (spec), how (plan) and steps (tasks) as files before code; mistakes are cheapest on paper | M3 (side question); practice in M8 |
| Unit vs characterization test | "It should do X" vs "it does X today" | [M5](learning-notes.md#m5-safety-nets) |
| Failing test first | Red on old code proves the bug; green proves the fix | [M5](learning-notes.md#m5-safety-nets) |
| Coverage limits | Shows what ran, not what was checked; only sees one test runner | [M5](learning-notes.md#m5-safety-nets) |
| Where to test first | Risk × how often it changes × how uncovered it is | [M5](learning-notes.md#m5-safety-nets) |
| Snapshots | Let the code fill them, then read every one | [M5](learning-notes.md#m5-safety-nets) |
| Mutation check | Break the code on purpose; a test must fail, for the right reason. It tests the tests | [M2](learning-notes.md#m2-kit-distribution), [M5](learning-notes.md#m5-safety-nets), M6 |
| Fake time | Tests control the clock; move it in steps, like real time | [M5](learning-notes.md#m5-safety-nets) |
| Browser agent | An agent that uses the app finds what unit tests can't: how parts behave together | [M5](learning-notes.md#m5-safety-nets) |

## Guardrails

| Concept | In one line | Learned |
| --- | --- | --- |
| Request vs enforcement | A written rule can be ignored; a hook, check or permission refuses | [M1](learning-notes.md#m1-instruction-loading), M6 |
| Lock vs hook | A lock is the goal; a hook is one way to build it | [M1](learning-notes.md#m1-instruction-loading) |
| Claude hook exit codes | Only exit code 2 blocks; 1 lets the action through | [M1](learning-notes.md#m1-instruction-loading) |
| Could not check ≠ OK | A missing check, folder, hook or executable bit must fail, never pass | [M1](learning-notes.md#m1-instruction-loading), [M2](learning-notes.md#m2-kit-distribution), M6 |
| Missing check looks like a pass | A PR with no checks shows "mergeable", like one with green checks | [M2](learning-notes.md#m2-kit-distribution) |
| Local vs server enforcement | A git hook stops accidents (`--no-verify` skips it); a required server check stops decisions | M6 |
| Hooks aren't cloned | Git never copies hooks, so a clone can't run a stranger's code; each clone turns them on | M6 |
| Kit owns when, project owns what | The hook decides when checks run; `scripts/check.sh` decides what | M6 |
| Should-block and should-allow | A check that blocks everything is as useless as one that blocks nothing | M6 |
| Install-script lock | npm blocks a package's install scripts until approved: supply-chain protection | [M5](learning-notes.md#m5-safety-nets) |
