# Experiment: which model should review? (M11)

**Date:** 2026-11-23. Claude Code 2.1.330, kit v0.8.0, Brain Gym.

## Question

Does the reviewer role need Opus, or is Sonnet or Haiku enough? Until M11 we
chose Sonnet by feel.

## Method

- **One change at a time.** The same branch, diff, fixed prompt (`review.sh`)
  and checks for every run. Only the model changed (`--model`), confirmed
  from each run's usage file.
- **A known answer.** On a local branch (never pushed), 4 bugs were planted
  in the finished Odd One Out game. Each kept `scripts/check.sh` green, so a
  reviewer could only find it by reading:
  1. a circle may be turned, so the odd shape can look identical (FR-016); one
     test deleted, one changed to match;
  2. the 300 ms tap pause set to 0 (FR-017); one test changed, three deleted;
  3. a `Red:` commit that also changes code (test first);
  4. the kid's name saved in every game result (FR-015, kids' data).
- **Two runs per model**, because AI answers vary.
- Each run in its own temporary checkout, so the project's `review.md` was
  never touched (approved by the owner after the agent hook blocked the first
  method).

## Results

| Model | Run | Planted bugs found | Kid's name rated as | Invented or confused findings | Output tokens | Time |
| --- | --- | --- | --- | --- | --- | --- |
| Haiku | 1 | 4 of 4 | major | 2 | 6,172 | 34 s |
| Haiku | 2 | 4 of 4 | major | 1 | 7,753 | 39 s |
| Sonnet | 1 | 4 of 4 | major | 0 | 2,409 | 23 s |
| Sonnet | 2 | 4 of 4 | major | 0 | 2,580 | 24 s |
| Opus | 1 | 4 of 4 | critical (cites FR-015) | 0 | 3,270 | 35 s |
| Opus | 2 | 4 of 4 | critical | 0 | 3,743 | 38 s |

An unplanned fifth problem was found by all six: the Red proof failed with
`tsc: command not found` (the branch was built on a `main` without
`scripts/review-setup.sh`, because a PR said to be merged was not).

## Findings

- **Finding bugs: no difference.** Every run found all 4. The test was too
  easy to separate the models (a ceiling effect).
- **Precision: Haiku was worse.** It invented findings in both runs and wrote
  the most output. Cheaper per token is not cheaper per review: each false
  finding costs a human's time.
- **Judgement: Opus was stricter where it matters.** Both Opus runs rated the
  kid's name in every game row as critical; Sonnet said major both times.
- **Each model was consistent** across its two runs.
- **Money:** output tokens measure size only; prices per token differ by
  model and were not checked here.

## Decision

- Default reviewer: **Sonnet** (accurate, fastest, fewest tokens).
- Reviews touching **kids' data, money, access or time**: **Opus**
  (`review.sh --model opus`).
- **Not Haiku** as a reviewer.

## Limits

One task, one project, two runs per model, bugs planted by the same person
who scored them. Next time: include hard bugs (a ceiling hides differences)
and compare implementers too.
