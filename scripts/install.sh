#!/usr/bin/env bash
# Installs or updates the factory kit in a project's .factory/ folder.
#
# Usage: scripts/install.sh <project-folder>
# Exit:  0 = installed, updated or already up to date
#        1 = stopped for a human (uncommitted changes or local edits); nothing changed
#        2 = could not run (bad folder, not a git repo)
#
# Rule: the kit owns .factory/, the project owns everything else.
# The script never commits. A human reviews and commits the change.

set -euo pipefail

kit="${KIT_DIR:-$(cd "$(dirname "$0")/.." && pwd)/kit}"   # KIT_DIR is for tests
project="${1:-}"

fail() { echo "install: $2" >&2; exit "$1"; }

[[ -n "$project" && -d "$project" ]] || fail 2 "project folder not found: ${project:-<none>}"
git -C "$project" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || fail 2 "not a git repo: $project (we need git so every change can be undone)"
[[ -z "$(git -C "$project" status --porcelain)" ]] \
  || fail 1 "uncommitted changes in $project. Commit or stash them first, so this install is one clean change."

dest="$project/.factory"
new_version="$(cat "$kit/VERSION")"

# Fingerprint every file in a folder, except checksums.txt itself.
# Output: "<sha256>  <path>", sorted, so two lists can be compared exactly.
fingerprints() {
  (cd "$1" && find . -type f ! -path ./checksums.txt | sed 's|^\./||' | LC_ALL=C sort |
    while IFS= read -r f; do shasum -a 256 "$f"; done)
}

if [[ -d "$dest" ]]; then
  [[ -f "$dest/checksums.txt" ]] \
    || fail 1 ".factory/ exists but has no checksums.txt, so it was not made by this script. Move it away first."

  # 1. Has anyone edited, deleted or added files inside .factory/?
  if [[ "$(fingerprints "$dest")" != "$(cat "$dest/checksums.txt")" ]]; then
    echo "install: .factory/ was changed locally. Nothing was updated." >&2
    echo "Changed files (- recorded at install, + now):" >&2
    diff <(cat "$dest/checksums.txt") <(fingerprints "$dest") | grep '^[<>]' \
      | sed 's/^</-/; s/^>/+/' >&2 || true
    echo >&2
    echo "Compare a file with the new kit version:  diff -u \"$kit/<file>\" \"$dest/<file>\"" >&2
    echo "Then either move the change into the kit, or undo it with git." >&2
    exit 1
  fi

  # 2. Same files as the kit already?
  if [[ "$(fingerprints "$dest")" == "$(fingerprints "$kit")" ]]; then
    echo "install: already up to date (v$new_version)."
    exit 0
  fi
  old_version="$(cat "$dest/VERSION" 2>/dev/null || echo unknown)"
else
  old_version="none"
fi

# 3. Build the new .factory/ next to the old one, then swap.
#    Files the kit removed disappear too, because the whole folder is replaced.
tmp="$project/.factory.new"
rm -rf "$tmp"
cp -R "$kit/." "$tmp"
fingerprints "$tmp" > "$tmp/checksums.txt"
rm -rf "$dest"
mv "$tmp" "$dest"

echo "install: kit v$new_version installed (was: $old_version)."
echo "Review and commit it:  git -C \"$project\" add .factory && git -C \"$project\" commit"
