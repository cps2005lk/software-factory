# Retro: M10, the first end-to-end feature (Odd One Out)

**Run:** 2026-11-22 to 2026-11-23, Brain Gym PR #9. A new game, built by the
factory from spec to merge. Trust: rung 2 (the owner read every line).

## Measured

| | M3: plain Claude, one bug | M10: the factory, one game |
| --- | --- | --- |
| Output tokens | 2,456 | about 162,000 (about 65 times) |
| Time | 26 s | 22 active minutes, 12 agent sessions |
| Tests | 0 | 634 lines; every Red step proven to fail |
| Proof | none | Red proof, mutation check, 3 reviews, play tests |
| Corrections by the owner | 0 | 0 |

Not like for like (a bug against a whole feature), but the direction is
clear: the factory costs much more per change and buys proof.

## Keep (each caught something real)

- **Review on paper:** a critical rule-narrowing and a false coverage claim,
  found before any code.
- **Read-only reviewer:** found a factory bug (review.md broke the format
  check) nobody else saw.
- **Red commits plus the script's Red proof:** every Red step verified.
- **Mutation check:** a test that missed a bug 3 times in 8.
- **Review gate:** blocked an unfinished feature and a stale review.
- **Loop bound:** the review ended at exactly round 3.
- **Agents stop at blocks:** three times, never a way around.
- **Human checks:** "subtle but fair" and "a kid understands it" need a person.

## Changed (kit v0.8.0)

| Problem | Change | Principle |
| --- | --- | --- |
| Red-proof checkouts had no `node_modules` | `review.sh` runs the project's `scripts/review-setup.sh` in each checkout | A proof must run where the real thing runs |
| The reviewer judged unticked human tasks | It leaves ticks to the gate; human tasks go under "Waiting for the human" | Facts for the script, judgement for the AI |
| `review.md` broke the project's formatter | Onboarding lists every tool-written file for the formatter's ignore list | Tool-written files stay out of project tools |
| The implementer stopped 3 times on permissions | Permission sets per role; "one command per call" | Smallest world, but complete |
| `--allowedTools` swallowed a prompt | Prompts go on stdin | (small, cost one run) |
| 65 times the cost | "How much process?" table by risk | Match the weight of the process to the risk |

## Dropped

Nothing big: every part caught something at least once. One rule was
replaced: the reviewer no longer counts unticked tasks.

## Trust

Brain Gym game logic: PR #9 merged with no correction after review. Record:
1 of 5 toward rung 3.
