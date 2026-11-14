# Baseline: plain Claude, no factory (M3)

This is the "before" number. M8 to M11 compare against it.

## Method

- **Task:** fix one real bug in a practice project. The bug was not yet
  confirmed, so a good run proves it with a failing test before fixing it.
- **Setup:** a fresh `claude --model sonnet` session in the project, on its own
  branch. No factory files were used. The project's existing `CLAUDE.md` stayed.
- **Prompt:** one bug report in the human's own words. It described the symptom
  and gave no hint about the cause.
- **Measured:** time, tokens, human corrections, the project's checks after the
  run, and a human review of the change.
- **Tokens:** summed from the session file, counting each reply once:

  ```sh
  jq -s '[.[] | select(.message.role=="assistant" and .message.usage)
          | {id: .message.id, u: .message.usage}] | unique_by(.id)
        | {replies: length,
           cache_write: (map(.u.cache_creation_input_tokens // 0) | add),
           cache_read:  (map(.u.cache_read_input_tokens // 0) | add),
           output:      (map(.u.output_tokens) | add)}' <session>.jsonl
  ```

  Each reply appears several times in the file (once per content block), so
  `unique_by(.id)` stops double counting.

## Result (14 November 2026, Claude Code v2.1.318, Sonnet 5.5)

| Measure | Result |
| --- | --- |
| Prompts / corrections | 1 / 0 |
| Time | 26 seconds |
| Replies | 6 |
| New input tokens (cache write) | 24,163 |
| Cache read tokens | 260,284 |
| Output tokens | 2,456 |
| `/usage` | 2% after; the "before" value was not recorded |
| Project checks after the run | 5 of 5 pass |
| Files changed | 1 source file, 0 test files |

## Review

- **Proof skipped.** No failing test before the fix and no test after it. The
  project had no setup for this kind of test, and the agent did not say so or
  ask. A later change can bring the bug back with every check still green.
- **Green checks proved less than they seemed.** They showed nothing old broke,
  not that the bug was fixed.
- **Small quality issue.** A variable kept a name that no longer matches its
  meaning.
- **The design of the fix was sound.**

## What the factory must beat

Plain Claude was fast and cheap but did not prove its work and stayed quiet
about it. The factory is worth it only if it makes the agent prove its work
(or say clearly why it can't) without costing much more than this.

## Limits

- One run on one task is weak evidence.
- The human already suspected the cause, which may have made the prompt better.
  The M10 run has the same human, so the bias is the same on both sides.
- `/usage` is shared with other sessions, so only the token counts are exact.
