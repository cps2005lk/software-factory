#!/usr/bin/env bash
# Runs every *.test.sh in this repository and fails if any of them fails.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
failed=0 count=0
while IFS= read -r test; do
  count=$((count + 1))
  if bash "$test" >/dev/null 2>&1; then echo "PASS  ${test#"$root"/}"; else echo "FAIL  ${test#"$root"/}"; failed=$((failed + 1)); fi
done < <(find "$root" -name '*.test.sh' -not -path '*/.git/*' | sort)
echo
if [[ $count == 0 ]]; then echo "No tests found: nothing was checked."; exit 2; fi
[[ $failed == 0 ]] && echo "All $count test files passed." || { echo "$failed of $count test files failed."; exit 1; }
