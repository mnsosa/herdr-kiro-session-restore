# Kiro session restore fork

This fork adds native Kiro CLI conversation restore to Herdr without changing the frozen generation-1 integration endpoint.

## Behavior

The CLI-only experimental integration installs two dedicated files under `~/.kiro/hooks/`. Kiro reports its active session ID to the Herdr pane on session start, prompt submission, and turn completion. Herdr persists that ID and resumes the conversation after a server or machine restart with:

```bash
kiro-cli chat --resume-id <id>
```

Kiro lifecycle state remains screen-detected. The integration only owns session identity.

## Local build

Requirements: Linux x86_64, Docker, Git, Bash, Python 3, and Kiro CLI. The reproducible build currently emits a Linux x86_64 binary using pinned Rust 1.96.1 and Zig 0.16.0 inputs inside Docker. The Kiro integration itself is also documented for macOS upstream, but this fork's build script does not yet produce macOS or ARM64 artifacts.

```bash
./scripts/build-local.sh
./scripts/verify.sh
./scripts/install-local.sh
```

The installed binaries are:

```text
~/.local/bin/herdr-kiro
~/.local/bin/herdr-kiro-isolated
```

`/usr/bin/herdr` is not modified.

## Isolated trial

Start an isolated Herdr session. The launcher sets dedicated XDG roots, so its configuration and sessions live under `~/.config/herdr-kiro/herdr/` and runtime state under `~/.local/state/herdr-kiro/herdr/`, outside stable Herdr's paths:

```bash
herdr-kiro-isolated
```

Inside that Herdr session, install the Kiro hook once:

```bash
herdr-kiro integration install kiro
```

Then start `kiro-cli chat` in a pane, complete at least one turn, and confirm the pane has a native session reference:

```bash
herdr-kiro pane get <pane-id>
```

To simulate a machine restart, stop only the isolated server and reopen it:

```bash
herdr-kiro-isolated server stop
herdr-kiro-isolated
```

The Kiro pane should reopen the same conversation automatically.

## Remove the local trial

```bash
herdr-kiro integration uninstall kiro
rm -f ~/.local/bin/herdr-kiro ~/.local/bin/herdr-kiro-isolated
```

Removing `~/.config/herdr-kiro` and `~/.local/state/herdr-kiro` deletes only the isolated Herdr trial data. Do that manually after confirming they contain nothing you need.

## Upstream proposal

Herdr's contribution policy directs feature proposals to GitHub Discussions. A short draft is available at `docs/github-discussion-draft.md`. Do not open an implementation PR unless a maintainer explicitly makes the account eligible under Herdr's current contribution policy.
