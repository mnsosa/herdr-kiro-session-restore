#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
binary="${HERDR_KIRO_BIN:-$repo_root/dist/herdr-kiro}"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

[[ -x "$binary" ]] || {
    printf 'error: missing %s; run scripts/build-local.sh first\n' "$binary" >&2
    exit 1
}
mkdir -p "$tmp/home/.kiro" "$tmp/config"
printf 'onboarding = false\n' >"$tmp/config/config.toml"

HOME="$tmp/home" HERDR_CONFIG_PATH="$tmp/config/config.toml" \
    "$binary" integration install kiro >/dev/null
HOME="$tmp/home" HERDR_CONFIG_PATH="$tmp/config/config.toml" \
    "$binary" integration status | grep -F 'kiro (experimental): current (v1)' >/dev/null
python3 - "$tmp/home/.kiro/hooks/herdr-agent-session.json" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    config = json.load(handle)
assert config["version"] == "v1"
assert {hook["trigger"] for hook in config["hooks"]} == {
    "SessionStart",
    "UserPromptSubmit",
    "Stop",
}
PY
HOME="$tmp/home" HERDR_CONFIG_PATH="$tmp/config/config.toml" \
    "$binary" integration uninstall kiro >/dev/null
[[ ! -e "$tmp/home/.kiro/hooks/herdr-agent-session.sh" ]]
[[ ! -e "$tmp/home/.kiro/hooks/herdr-agent-session.json" ]]

printf 'verification passed for %s\n' "$binary"
