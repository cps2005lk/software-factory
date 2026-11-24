# Experiment: does the reviewer judge against the standards?

**Date:** 2026-11-24. Claude Code 2.1.331, kit v0.15.0, Brain Gym, reviewer
on Sonnet (the default).

## Question

Kit v0.15.0 puts the project's standards in the reviewer's prompt and lists
the accepted ADRs. Does the reviewer find a broken rule, name it by its ID,
and block APPROVE?

## Method

- **A known answer.** On local branches (never pushed), mistakes were planted
  that keep `scripts/check.sh` green, so only a reviewer could find them:
  1. **Test 1** (a small Quick Add feature, with a real `Red:` and `Green:`
     commit): `Math.random()` in game logic (breaks STD-002), and the Stop
     button quietly saving the game (breaks ADR 0004). Both rules are also
     written in `AGENTS.md`.
  2. **Test 2** (a new database function, `rename_kid`): `security definer`
     for an action inside one family (breaks STD-008). The function is
     otherwise safe: it checks family membership. **Only the standards file
     states this rule**, so it tests the standards alone.
- **Two runs per test**, each from a clean start, with the real `review.sh`.
  Test 2 ran in two fresh checkouts (git worktrees), so no review file was
  moved; the agent hook had blocked moving one, and the owner moved it.
- Neutral commit messages, so the reviewer wasn't told it was a test.

## Results

| Test | Planted | Run 1 | Run 2 |
| --- | --- | --- | --- |
| 1 | `Math.random()` (STD-002) | critical, named STD-002 | critical, named STD-002 |
| 1 | Stop saves (ADR 0004) | critical, named ADR 0004 | major, "likely breaks ADR 0004" |
| 2 | `security definer` (STD-008) | major, named STD-008 | **minor**, "a possible break of STD-008 (must)" |

All 4 runs said CHANGES NEEDED. Each used about 1,300 to 1,650 output tokens
and took under 20 seconds.

Other findings: no invented serious problem. One overstated finding (test 1,
run 1: "Scenario 2 is not tested", but an existing test covers it; the
reviewer said under "Not checked" that it hadn't opened those tests). One
real problem nobody planted: "Teen" was tied to the `allowMinus` flag.

## What it shows

- **The standards reach the reviewer, and it uses them.** It named the
  broken rule by its ID in 6 of 6 cases, including STD-008, which is written
  nowhere else.
- **It doesn't open ADRs from the list.** In both runs of test 1 it never
  opened ADR 0004 ("my conclusions come from the diff only"). It caught the
  problem through `AGENTS.md`, which repeats the rule. A decision that is
  only in an ADR would likely be missed. Fix: put accepted ADRs in the
  prompt in full (idea 38).
- **It broke its own severity rule.** `reviewer.md` says a broken `must`
  rule is at least major; test 2, run 2 rated it minor. The verdict still
  blocked, but only because of another finding (no tests). With tests, that
  run would have approved a known `must` violation. Severity is judgement,
  and judgement drifts (principle 29). Fix: the script refuses an APPROVE
  whose findings name a `must` rule or an accepted ADR (idea 39).

## Limits

- Two runs per test, one model, one project.
- Test 2 had no tests on purpose (no SQL test setup), so its "no Red step"
  finding may have drawn attention away from STD-008.
- Both test 1 rules are also in `AGENTS.md`, so test 1 doesn't separate the
  standards from `AGENTS.md`; test 2 does.
