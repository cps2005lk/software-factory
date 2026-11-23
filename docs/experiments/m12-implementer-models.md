# Experiment: which model should implement? (M12)

**Date:** 2026-11-23. Claude Code 2.1.330, kit v0.12.0, Brain Gym, inside the
agent box.

## Question

Does the implementer need Opus, or is Sonnet or Haiku enough? The reviewer
was compared in M11; this is the same question for the role that writes code.

## Method

- **One change at a time.** The same prompt and the same fresh clone for every
  run, each in its own agent box (no host files, firewall, limited token).
  Only the model changed (`AGENT_MODEL`). No pushes: the work went to the
  outbox for scoring (`NO_PUSH=1`).
- **The task:** a new Brain Gym function, `daysPlayedThisWeek(sessions,
  kidId, nowIso)`: on how many different days of the current week a kid
  finished a game. The prompt said "a day and the week follow the project's
  rules in AGENTS.md", which name `dayKey()` (the Asia/Colombo day). Test
  first: a Red commit with tests only, then Green.
- **A known answer: 12 hidden tests**, never shown to the agents, written from
  the same spec. Three are traps where Colombo midnight and UTC midnight fall
  on different dates:

  | Case | Expected |
  | --- | --- |
  | No sessions | 0 |
  | One game today; two games the same Colombo day | 1; 1 |
  | Mon, Wed and Sun | 3 |
  | Another kid's game; a game after "now" | 0; 0 |
  | **Trap:** Mon 23:50 and Tue 00:10 Colombo (one UTC day) | 2 |
  | **Trap:** Mon 00:05 Colombo, now Mon 00:10 (UTC says Sunday) | 1 |
  | Last week's Sunday | 0 |
  | **Trap:** now Mon 00:30 Colombo, a new week (UTC still Sunday) | 0 |
  | Every day of the week | 7 |
  | Unsorted input with last week's games mixed in | 2 |

- **The hidden tests were tested first:** a correct version passed 12 of 12; a
  version that uses UTC dates instead of `dayKey()` failed 3 (the traps).
- **Scored by a script, written before the runs:** hidden tests passed,
  `dayKey()` used, the Red commit checked out and run (it must fail, with
  tests only), only the two allowed files changed, `scripts/check.sh` green,
  output tokens from the usage file.
- **Added after the first results showed a ceiling** (applied identically to
  all runs): each agent's own tests were run against 4 broken versions of the
  function (UTC dates; ignoring the kid; counting future games; a week that
  starts on Sunday).
- **Two runs per model.**

## Results

| Model | Run | Hidden tests | Rules, Red, scope, checks | Own tests catch the 4 broken versions | Output tokens | Time |
| --- | --- | --- | --- | --- | --- | --- |
| Haiku | 1 | 12/12 | all kept | 4/4 (12 tests) | 13,153 | 86 s |
| Haiku | 2 | 12/12 | all kept | 4/4 (11 tests) | 9,557 | 67 s |
| Sonnet | 1 | 12/12 | all kept | 4/4 (7 tests) | 4,172 | 78 s |
| Sonnet | 2 | 12/12 | all kept | 4/4 (10 tests) | 4,302 | 62 s |
| Opus | 1 | 12/12 | all kept | 4/4 (10 tests) | 5,700 | 109 s |
| Opus | 2 | 12/12 | all kept | 4/4 (9 tests) | 5,245 | 97 s |

Times include the fresh clone and `npm ci`.

## Findings

- **Quality: no difference.** Every run passed every check, and every run's
  own tests caught every broken version. A ceiling effect again, although
  M11 had taught us to include hard cases: the traps were real (a UTC
  version fails them), but every model avoided them.
- **Cost and speed: Sonnet wrote the least and was fastest.** Haiku wrote two
  to three times as much (but, unlike as a reviewer in M11, it was correct).
- **Each model was consistent** across its two runs.
- **A possible reason (a hypothesis, not a result):** the factory itself. The
  spec pointed at `AGENTS.md`, which names `dayKey()`, and the role demands
  test first. That may level the models. Proving it needs a control run
  without the factory's rules.
- **Money:** output tokens measure size only; prices per token differ by
  model and were not checked here.

## Decision

- **Small, well-specified tasks (the short loop): Sonnet** as implementer.
- **Features (the full loop): Opus for now.** Not measured here.

## Limits and next

One small task, one project, two runs per model, hidden tests written by the
same person who scored them. **Next (planned):** a feature-sized, somewhat
ambiguous task, and a control run without the factory's rules, to learn how
much of the quality comes from the factory and how much from the model.
