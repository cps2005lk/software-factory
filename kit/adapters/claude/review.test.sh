#!/usr/bin/env bash
# Tests for review.sh, with a fake `claude` on PATH that records how it was
# called and answers with a chosen verdict.
set -uo pipefail

script="$(cd "$(dirname "$0")" && pwd)/review.sh"
fails=0
pass() { echo "PASS  $1"; }
fail() { echo "FAIL  $1${2:+ ($2)}"; fails=$((fails + 1)); }

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin"
cat >"$tmp/bin/claude" <<'SH'
#!/usr/bin/env bash
printf '%s\n' "$@" >"$FAKE_DIR/args"
cat >"$FAKE_DIR/prompt"
printf 'Findings: none\n\n%b\n' "${FAKE_LAST:-Verdict: APPROVE}"
SH
chmod +x "$tmp/bin/claude"
export FAKE_DIR="$tmp" PATH="$tmp/bin:$PATH"

# A project with a spec, a reviewer file, a check, and one commit on a branch.
p="$tmp/proj"
git init -q -b main "$p" && cd "$p" || exit 1
git config user.email t@example.com && git config user.name t
mkdir -p specs/001-x .claude/agents scripts
echo "# Spec: x" >specs/001-x/spec.md; echo "# Tasks" >specs/001-x/tasks.md
echo "reviewer" >.claude/agents/reviewer.md
printf '#!/usr/bin/env bash\necho "ALL CHECKS PASSED"\n' >scripts/check.sh; chmod +x scripts/check.sh
git add -A && git commit -q -m base
git switch -q -c feature && echo "echo hello" >hello.sh && git add hello.sh && git commit -q -m "Add hello"

run() { "$script" "$@" >"$tmp/out" 2>&1; echo $?; }

[[ "$(run specs/001-x)" == 0 ]] && pass "APPROVE: exit 0" || fail "APPROVE: exit 0" "$(cat "$tmp/out")"
grep -q "^--agent$" "$tmp/args" && grep -qx reviewer "$tmp/args" && pass "runs the reviewer agent" || fail "runs the reviewer agent"
for t in Bash Edit Write; do grep -qx "$t" "$tmp/args" || fail "removes $t"; done && pass "removes Bash, Edit and Write"
grep -q "specs/001-x/spec.md" "$tmp/prompt" && grep -q "specs/001-x/tasks.md" "$tmp/prompt" && pass "prompt names the spec and tasks" || fail "prompt names the spec and tasks"
grep -q "+echo hello" "$tmp/prompt" && pass "prompt has the diff" || fail "prompt has the diff"
grep -q "Add hello" "$tmp/prompt" && pass "prompt has the commits" || fail "prompt has the commits"
grep -q "hello.sh" "$tmp/prompt" && grep -q "Add hello" "$tmp/prompt" && grep -q "1 file changed" "$tmp/prompt" && pass "each commit lists its files" || fail "each commit lists its files"
grep -q "ALL CHECKS PASSED" "$tmp/prompt" && grep -q "Exit code: 0" "$tmp/prompt" && pass "prompt has the check output" || fail "prompt has the check output"
grep -q "^Verdict: APPROVE" specs/001-x/review.md && pass "writes review.md" || fail "writes review.md"
rm -f specs/001-x/review.md

FAKE_LAST="Verdict: CHANGES NEEDED"; export FAKE_LAST
[[ "$(run specs/001-x)" == 1 ]] && pass "CHANGES NEEDED: exit 1" || fail "CHANGES NEEDED: exit 1"; rm -f specs/001-x/review.md
FAKE_LAST="Looks fine to me."
[[ "$(run specs/001-x)" == 2 ]] && pass "no verdict line: could not review (2)" || fail "no verdict line"; rm -f specs/001-x/review.md
FAKE_LAST="Verdict: APPROVE\nVerdict: CHANGES NEEDED"
[[ "$(run specs/001-x)" == 1 ]] && pass "only the last line counts" || fail "only the last line counts"; rm -f specs/001-x/review.md
unset FAKE_LAST

printf '#!/usr/bin/env bash\necho "2 tests FAILED"; exit 1\n' >scripts/check.sh && git commit -qam "failing check"
run specs/001-x >/dev/null
grep -q "Exit code: 1" "$tmp/prompt" && grep -q "2 tests FAILED" "$tmp/prompt" && pass "a failing check is shown to the reviewer" || fail "failing check shown"
rm -f specs/001-x/review.md
run --check "no-such-command" specs/001-x >/dev/null
grep -q "No checks ran" "$tmp/prompt" && pass "a missing check is a finding, not a pass" || fail "missing check"
rm -f specs/001-x/review.md

# Refusals: claude must not be called at all.
rm -f "$tmp/prompt"
echo dirty >>hello.sh
[[ "$(run specs/001-x)" == 2 && ! -e "$tmp/prompt" ]] && pass "uncommitted changes: refused" || fail "uncommitted changes"
git checkout -q -- hello.sh
[[ "$(run specs/nope)" == 2 ]] && pass "no spec: refused" || fail "no spec"
git switch -q main
[[ "$(run specs/001-x)" == 2 ]] && pass "no commits since base: refused" || fail "no commits since base"
git switch -q feature
[[ "$(run --base nowhere specs/001-x)" == 2 ]] && pass "unknown base: refused" || fail "unknown base"
mv .claude/agents/reviewer.md "$tmp/r.md"
[[ "$(run specs/001-x)" == 2 && ! -e "$tmp/prompt" ]] && pass "no reviewer agent file: refused" || fail "no reviewer file"
mv "$tmp/r.md" .claude/agents/reviewer.md

echo
[[ $fails == 0 ]] && echo "All tests passed." || { echo "$fails test(s) failed."; exit 1; }
