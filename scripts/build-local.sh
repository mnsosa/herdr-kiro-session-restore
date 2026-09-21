#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
output_dir="$repo_root/dist"
image="rust:1.96.1-bookworm@sha256:a339861ae23e9abb272cea45dfafde21760d2ce6577a70f8a926153677902663"
zig_url="https://ziglang.org/download/0.16.0/zig-x86_64-linux-0.16.0.tar.xz"
zig_sha256="70e49664a74374b48b51e6f3fdfbf437f6395d42509050588bd49abe52ba3d00"

command -v docker >/dev/null 2>&1 || {
    printf 'error: docker is required\n' >&2
    exit 1
}
if [[ "$(uname -s)" != "Linux" || "$(uname -m)" != "x86_64" ]]; then
    printf 'error: this reproducible build currently supports Linux x86_64 only\n' >&2
    exit 1
fi
mkdir -p "$output_dir"

docker run --rm \
    -e CARGO_TARGET_DIR=/tmp/herdr-target \
    -e HOST_UID="$(id -u)" \
    -e HOST_GID="$(id -g)" \
    -e ZIG_URL="$zig_url" \
    -e ZIG_SHA256="$zig_sha256" \
    -v "$repo_root:/work" \
    -v "$output_dir:/out" \
    -w /work \
    "$image" \
    sh -c '
        set -eu
        curl -fsSL "$ZIG_URL" -o /tmp/zig.tar.xz
        printf "%s  %s\n" "$ZIG_SHA256" /tmp/zig.tar.xz | sha256sum -c -
        tar -xJf /tmp/zig.tar.xz -C /tmp
        export PATH="/tmp/zig-x86_64-linux-0.16.0:/usr/local/cargo/bin:/usr/local/rustup/bin:$PATH"
        cargo build --release --locked
        install -m 0755 "$CARGO_TARGET_DIR/release/herdr" /out/herdr-kiro
        chown "$HOST_UID:$HOST_GID" /out/herdr-kiro
    '

printf 'built %s\n' "$output_dir/herdr-kiro"
