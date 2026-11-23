#!/usr/bin/env bash
# Starts the factory's agent box (a Docker container) from your Mac.
#
# Usage: run.sh build              build the image
#        run.sh probe owner/repo   prove the box (forbidden blocked, the job works)
#        run.sh login              log Claude Code in, inside the box (once)
#        run.sh shell              a shell inside the box, for looking around
#
# The agent's GitHub token comes from the Mac keychain (item
# "factory-agents-gh") and is handed over as an environment variable, never
# written to a file. Claude Code's login is kept in the Docker volume
# "factory-agent-home", not on the Mac.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
image="factory-agent:0.1"
box=(--rm --cap-add NET_ADMIN --cap-add NET_RAW -e GH_TOKEN -v factory-agent-home:/home/node)
token() { security find-generic-password -a "$USER" -s factory-agents-gh -w; }

case "${1:-}" in
  build) docker build -t "$image" "$here" ;;
  probe) GH_TOKEN="$(token)" docker run "${box[@]}" -e PROBE_REPO="${2:?usage: run.sh probe owner/repo}" "$image" probe.sh ;;
  login) docker run -it "${box[@]}" "$image" claude ;;
  shell) GH_TOKEN="$(token)" docker run -it "${box[@]}" "$image" bash ;;
  *) sed -n 2,13p "$0"; exit 2 ;;
esac
