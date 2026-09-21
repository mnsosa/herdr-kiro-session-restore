#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." 2>/dev/null && pwd || true)"
xdg_config_root="${HERDR_KIRO_CONFIG_ROOT:-$HOME/.config/herdr-kiro}"
xdg_state_root="${HERDR_KIRO_STATE_ROOT:-$HOME/.local/state/herdr-kiro}"
session="${HERDR_KIRO_SESSION:-kiro-test}"

if [[ -n "${HERDR_KIRO_BIN:-}" ]]; then
    binary="$HERDR_KIRO_BIN"
elif [[ -x "$script_dir/herdr-kiro" ]]; then
    binary="$script_dir/herdr-kiro"
elif [[ -n "$repo_root" && -x "$repo_root/dist/herdr-kiro" ]]; then
    binary="$repo_root/dist/herdr-kiro"
else
    binary="${HOME}/.local/bin/herdr-kiro"
fi

[[ -x "$binary" ]] || {
    printf 'error: herdr-kiro binary not found; run scripts/build-local.sh or scripts/install-local.sh\n' >&2
    exit 1
}

export XDG_CONFIG_HOME="$xdg_config_root"
export XDG_STATE_HOME="$xdg_state_root"
export HERDR_CONFIG_PATH="$XDG_CONFIG_HOME/herdr/config.toml"

mkdir -p "$(dirname -- "$HERDR_CONFIG_PATH")" "$XDG_STATE_HOME"
if [[ ! -e "$HERDR_CONFIG_PATH" ]]; then
    printf 'onboarding = false\n' >"$HERDR_CONFIG_PATH"
fi

exec "$binary" --session "$session" "$@"
