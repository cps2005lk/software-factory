#!/usr/bin/env bash
# Starts the reviewer: a separate, read-only Claude run that reviews a
# finished feature branch against its spec. The implementer doesn't write
# the reviewer's prompt; this script does, the same way every time.
#
# Usage: review.sh [--base <ref>] [--check "<command>"] [--another-round] <spec-folder>
#   --base           branch to compare with (default: main)
#   --check          the project's checks, run before the review (default: scripts/check.sh)
#   --another-round  a human allows a review after 3 rounds of CHANGES NEEDED
#
# Rounds: each review after a CHANGES NEEDED is the next round. After round 3
# still says CHANGES NEEDED, the script stops: a human decides, not another loop.
# Writes:  <spec-folder>/review.md (not committed: a human reads and commits it)
# Exit:    0 = Verdict: APPROVE
#          1 = Verdict: CHANGES NEEDED
#          2 = could not review (bad input, uncommitted changes, no verdict)
#
# The reviewer gets only Read, Grep and Glob (see agents/reviewer.md). This
# script also removes Bash, Edit and Write, so the role can't be widened.

set -uo pipefail

stop() { echo "review: $1" >&2; exit 2; }

base=main; check="scripts/check.sh"; spec=""; another=0; max_rounds=3
while (( $# )); do
  case "$1" in
    --base) base="${2:-}"; shift 2 ;;
    --check) check="${2:-}"; shift 2 ;;
    --another-round) another=1; shift ;;
    -*) stop "unknown option $1" ;;
    *) spec="${1%/}"; shift ;;
  esac
done

root="$(git rev-parse --show-toplevel 2>/dev/null)" || stop "not in a git repo."
cd "$root" || stop "can't open $root."
[[ -n "$spec" && -f "$spec/spec.md" ]] || stop "no spec.md in '${spec:-<none>}'. Usage: review.sh [--base main] <spec-folder>"
[[ -f .claude/agents/reviewer.md ]] || stop "no .claude/agents/reviewer.md. Copy it from .factory/adapters/claude/agents/."
command -v claude >/dev/null || stop "claude not found."
git rev-parse --verify -q "$base^{commit}" >/dev/null || stop "base '$base' not found."
[[ -z "$(git status --porcelain)" ]] || stop "uncommitted changes. Commit first: the reviewer only reviews committed work."

# Which round is this? A review after CHANGES NEEDED is the next round.
round=1
if [[ -f "$spec/review.md" ]]; then
  prev_round="$(sed -n 's/^Round: *\([0-9]*\).*/\1/p' "$spec/review.md" | head -1)"
  prev_verdict="$(grep -v '^[[:space:]]*$' "$spec/review.md" | tail -1 | sed 's/[[:space:]]*$//')"
  [[ "$prev_verdict" == "Verdict: CHANGES NEEDED" ]] && round=$(( ${prev_round:-1} + 1 ))
fi
if (( round > max_rounds && ! another )); then
  stop "$max_rounds reviews in a row said CHANGES NEEDED. A human decides now: read $spec/review.md, then fix it yourself, change the spec, or run again with --another-round."
fi

commits="$(git log --stat --format='%h %s' "$base"..HEAD)"
[[ -n "$commits" ]] || stop "no commits on this branch since '$base': nothing to review."

if [[ -n "$check" ]] && command -v "${check%% *}" >/dev/null 2>&1; then
  check_out="$(bash -c "$check" 2>&1)"; check_code=$?
  checks="Command: $check
Exit code: $check_code
Output (last 60 lines):
$(tail -60 <<<"$check_out")"
else
  checks="No checks ran: '${check:-<none>}' was not found. Treat this as a finding."
fi

files=""
for f in plan.md tasks.md; do [[ -f "$spec/$f" ]] && files="$files
- $spec/$f"; done

prompt="Review this feature branch. Follow your instructions in full.

Feature files:
- $spec/spec.md$files

Branch: $(git branch --show-current), at $(git rev-parse --short HEAD). Base: $base.

## Commits since $base
$commits

## Checks, run just before this review
$checks

## Full diff ($base...HEAD)
$(git diff "$base"...HEAD)"

err="$(mktemp)"; trap 'rm -f "$err"' EXIT
review="$(printf '%s\n' "$prompt" | claude -p --agent reviewer --disallowedTools Bash Edit Write NotebookEdit 2>"$err")" \
  || stop "the reviewer run failed: $(tail -3 "$err")"

{
  echo "# Review: $spec"
  echo
  echo "Reviewer: \`.claude/agents/reviewer.md\` (read-only). Branch $(git branch --show-current), base $base, $(date -u +%Y-%m-%dT%H:%MZ)."
  echo
  echo "Reviewed-commit: $(git rev-parse HEAD)"
  echo "Round: $round"
  echo
  printf '%s\n' "$review"
} >"$spec/review.md"

verdict="$(grep -v '^[[:space:]]*$' <<<"$review" | tail -1 | sed 's/[[:space:]]*$//')"
case "$verdict" in
  "Verdict: APPROVE") echo "review: APPROVE. See $spec/review.md"; exit 0 ;;
  "Verdict: CHANGES NEEDED") echo "review: CHANGES NEEDED. See $spec/review.md"; exit 1 ;;
  *) stop "no verdict on the last line, so the review is not complete. See $spec/review.md" ;;
esac
