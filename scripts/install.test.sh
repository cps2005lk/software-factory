#!/usr/bin/env bash
# Tests for install.sh. Each case uses a fake kit and a fake project in a temp folder.
set -uo pipefail

install="$(cd "$(dirname "$0")" && pwd)/install.sh"
fails=0
work=""

setup() { # fresh temp folder with kit v1 and an empty committed project
  [[ -n "$work" ]] && rm -rf "$work"
  work="$(mktemp -d)"
  mkdir -p "$work/kit/checks" "$work/proj"
  echo "0.1.0" > "$work/kit/VERSION"
  echo "check a" > "$work/kit/checks/a.sh"
  echo "check b" > "$work/kit/checks/b.sh"
  git -C "$work/proj" init -q
  echo "app" > "$work/proj/app.txt"
  commit
}
commit() { git -C "$work/proj" add -A && git -C "$work/proj" -c user.name=t -c user.email=t@t commit -qm x; }
kit_v2() { echo "0.2.0" > "$work/kit/VERSION"; echo "check a v2" > "$work/kit/checks/a.sh"; }
run() { KIT_DIR="$work/kit" "$install" "${1:-$work/proj}" >/dev/null 2>&1; echo $?; }
expect() { # name, condition result (0 = true)
  if [[ "$2" == 0 ]]; then echo "PASS  $1"; else echo "FAIL  $1"; fails=$((fails + 1)); fi
}
snapshot() { (cd "$work/proj" && find .factory -type f | sort | xargs shasum 2>/dev/null); }

# 1. Fresh install
setup; code=$(run)
[[ $code == 0 && -f $work/proj/.factory/checks/a.sh && $(cat $work/proj/.factory/VERSION) == 0.1.0 && -f $work/proj/.factory/checksums.txt ]]
expect "fresh install creates .factory with VERSION and checksums" $?

# 2. Run again with no changes
commit; code=$(run)
[[ $code == 0 && -z $(git -C "$work/proj" status --porcelain) ]]
expect "second run is up to date and changes nothing" $?

# 3. Update with no local edits
kit_v2; code=$(run)
[[ $code == 0 && $(cat $work/proj/.factory/VERSION) == 0.2.0 && $(cat $work/proj/.factory/checks/a.sh) == "check a v2" ]]
expect "update replaces files and VERSION" $?

# 4. Kit removed a file
setup; run >/dev/null; commit; rm "$work/kit/checks/b.sh"; code=$(run)
[[ $code == 0 && ! -e $work/proj/.factory/checks/b.sh ]]
expect "file removed from kit is removed from project" $?

# 5. Local edit -> stop, change nothing
setup; run >/dev/null; echo "my fix" >> "$work/proj/.factory/checks/a.sh"; commit
before=$(snapshot); kit_v2; code=$(run)
[[ $code == 1 && "$(snapshot)" == "$before" ]]
expect "local edit stops the update and changes nothing" $?

# 6. Local delete -> stop
setup; run >/dev/null; rm "$work/proj/.factory/checks/b.sh"; commit; kit_v2; code=$(run)
[[ $code == 1 ]]
expect "deleted kit file stops the update" $?

# 7. Extra file added inside .factory -> stop
setup; run >/dev/null; echo x > "$work/proj/.factory/checks/mine.sh"; commit; kit_v2; code=$(run)
[[ $code == 1 && -e $work/proj/.factory/checks/mine.sh ]]
expect "extra file in .factory stops the update and is kept" $?

# 8. Uncommitted changes in the project -> refuse
setup; echo "wip" >> "$work/proj/app.txt"; code=$(run)
[[ $code == 1 && ! -e $work/proj/.factory ]]
expect "uncommitted changes refuse the install" $?

# 9. .factory exists but not made by us
setup; mkdir "$work/proj/.factory"; echo x > "$work/proj/.factory/x"; commit; code=$(run)
[[ $code == 1 && -e $work/proj/.factory/x ]]
expect ".factory without checksums.txt is left alone" $?

# 10. Missing folder / not a git repo
setup; code=$(run "$work/nope"); [[ $code == 2 ]]; expect "missing folder exits 2" $?
mkdir "$work/plain"; code=$(run "$work/plain"); [[ $code == 2 ]]; expect "not a git repo exits 2" $?

# 11. Folder name with a space
setup; mv "$work/proj" "$work/my proj"; code=$(run "$work/my proj")
[[ $code == 0 && -f "$work/my proj/.factory/VERSION" ]]
expect "project path with a space works" $?

rm -rf "$work"
echo
[[ $fails == 0 ]] && echo "All tests passed." || { echo "$fails test(s) failed."; exit 1; }
