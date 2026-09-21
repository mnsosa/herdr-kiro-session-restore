#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
prefix="${HERDR_KIRO_PREFIX:-$HOME/.local}"
binary="$repo_root/dist/herdr-kiro"

if [[ ! -x "$binary" ]]; then
    "$repo_root/scripts/build-local.sh"
fi

mkdir -p "$prefix/bin"
install -m 0755 "$binary" "$prefix/bin/herdr-kiro"
install -m 0755 "$repo_root/scripts/run-isolated.sh" "$prefix/bin/herdr-kiro-isolated"

printf 'installed %s\n' "$prefix/bin/herdr-kiro"
printf 'installed %s\n' "$prefix/bin/herdr-kiro-isolated"
printf 'stable /usr/bin/herdr was not modified\n'
