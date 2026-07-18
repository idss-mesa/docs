---
type: Troubleshooting
title: Troubleshooting
description: Fixes for common MESA install and registration problems across Claude Code, Codex, Antigravity, and OpenCode.
tags:
  - troubleshooting
  - errors
  - faq
timestamp: "2026-07-18T00:00:00Z"
---

# Troubleshooting

## `no supported agent client found`

The installer auto-detects [Claude Code](claude-code.md), [Codex CLI](codex.md),
[Antigravity](antigravity.md), and [OpenCode](opencode.md), and refuses to run when none
is present — or when `--for` names a client that isn't installed. Install at least one,
open a new shell, and re-run.

## `native Windows shells are not supported`

You're running in PowerShell, `cmd`, Git Bash, or MSYS. Install
[WSL](https://learn.microsoft.com/windows/wsl/install), open an Ubuntu (or similar) shell,
and run the one-liner there. The installer auto-detects WSL and treats it as Linux.

## Go servers were skipped

If you see *"Go toolchain not found"* or *"Go 1.x is older than the required 1.25"*, only
`mesa-mcp` was installed. Install [Go ≥ 1.25](https://go.dev/dl/) and re-run, or pass
`--no-go` if you only want `mesa-mcp`.

## `uv` not found after install

The installer fetches `uv` from astral.sh into `~/.local/bin`. If a fresh shell still can't
find it, add that directory to your `PATH`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

then re-run the installer.

## `claude mcp list` shows "Needs authentication" or "Failed to connect"

- **Needs authentication** on a *hosted* (`https://…`) server is expected until you log in;
  it does not affect the local stdio servers MESA installs.
- **Failed to connect** on a local server usually means the binary moved or the venv broke.
  Re-run the installer to rebuild and re-register.

## Codex doesn't see the servers

Codex reads registrations at startup — restart the session, then verify with `/mcp`
inside the TUI or `codex mcp list`. If the servers are missing entirely, inspect
`~/.codex/config.toml` for the `[mcp_servers.*]` tables.

## Antigravity doesn't see the servers

Refresh via the IDE's **Manage MCP Servers** panel or restart `agy` — the config is not
hot-reloaded. Confirm `$HOME/.gemini/config/mcp_config.json` exists and that every
`command` path is **absolute** (no `~`). Older releases read
`~/.gemini/antigravity/mcp_config.json` or `~/.gemini/antigravity-cli/mcp_config.json`
instead.

## OpenCode doesn't see the servers

Restart OpenCode (config is read at startup) and run `opencode mcp list`. If a server
shows globally but not in one project, that project's `opencode.json` is deep-merged on
top — check it for an entry overriding or disabling the server.

## Conflicting scopes

*(Claude Code only — the other clients have a single scope.)*

A warning that a server is *"defined in multiple scopes"* means the same name is registered
more than once (e.g. an older manual entry plus MESA's). Remove the ones you don't want:

```bash
claude mcp remove mesa-mcp -s user
claude mcp remove mesa-mcp -s local
```

## iRODS calls return permission errors

Anonymous access is read-only on public collections. To write AVUs or read private data,
[authenticate](credentials.md) — either re-run with `CYVERSE_USERNAME` / `CYVERSE_PASSWORD`,
or run `iinit` to set up `~/.irods`.

## `grep: /etc/os-release: No such file or directory`

Harmless. It comes from the `irods-mcp-server` Makefile probing the OS on macOS; the build
still succeeds.

## Starting over

```bash
curl -fsSL https://raw.githubusercontent.com/idss-mesa/mesa/main/install.sh | bash -s -- --uninstall
```

removes the three servers from every detected client and (after confirmation) deletes `~/.mesa`.
