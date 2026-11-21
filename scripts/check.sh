#!/usr/bin/env bash
# The factory's own checks. The pre-push hook runs this file, as in any
# project that uses the kit: the factory follows its own rules.
set -euo pipefail
cd "$(dirname "$0")/.."

scripts/test-all.sh
kit/guardrails/checks/no-claude-md.sh .
kit/guardrails/checks/claude-settings-in-sync.sh .
