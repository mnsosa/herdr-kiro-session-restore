# Draft: Resume Kiro CLI conversations after a Herdr restart

## Problem

Herdr already detects Kiro CLI panes and their visible lifecycle state. After the Herdr server or machine restarts, however, those panes return as shells instead of reopening the Kiro conversation that was active before the restart.

Kiro exposes a session identifier to standalone hooks and can resume a specific conversation with `kiro-cli chat --resume-id <id>`. Supporting that identity would give Kiro panes the same restart experience as other resumable agents.

## Why it matters

I regularly keep Kiro conversations in persistent Herdr workspaces. Restoring the layout without restoring each conversation requires manually finding and reopening the corresponding session after every reboot.

## Validation

I have validated the flow locally on Linux: a Kiro hook reports the active session ID to Herdr, Herdr persists it with the pane directory, and the restored pane launches `kiro-cli chat --resume-id <id>`.

Would native Kiro session restore fit Herdr's integration direction? The validated reference fork and local reproduction steps are available at [mnsosa/herdr-kiro-session-restore](https://github.com/mnsosa/herdr-kiro-session-restore). I can provide additional implementation details if useful.
