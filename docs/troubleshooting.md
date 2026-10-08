---
type: Troubleshooting
title: Troubleshooting
description: Fixes for common MESA install, registration, and Formation sign-in problems across Claude Code, Codex, Antigravity, and OpenCode.
tags:
  - troubleshooting
  - errors
  - faq
generated:
  by: "claude-code/2.1.294"
  at: "2026-10-08T00:00:00Z"
sources:
  - id: install-sh
    resource: "https://github.com/idss-mesa/docs/blob/main/install.sh"
    title: "MESA install.sh"
    author: "team:idss-mesa"
status: stable
stale_after: "2027-04-08T00:00:00Z"
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

## Go server was skipped

If you see *"Go toolchain not found"* or *"Go 1.x is older than the required 1.25"*,
`irods` was not installed; `mesa-mcp` and the hosted `formation` were registered anyway.
Install [Go ≥ 1.25](https://go.dev/dl/) and re-run, or pass `--no-go` to skip `irods`
on purpose.

## `uv` not found after install

The installer fetches `uv` from astral.sh into `~/.local/bin`. If a fresh shell still can't
find it, add that directory to your `PATH`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

then re-run the installer.

## `claude mcp list` shows "Needs authentication" or "Failed to connect"

- **Needs authentication** on a *hosted* (`https://…`) server such as `formation` is
  expected until you sign in: run `/mcp` and choose **Authenticate**, or
  `claude mcp login formation`. It does not affect the local stdio servers.
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

## Formation sign-in and connection

[Formation](servers/formation-mcp.md) is hosted by CyVerse at
<https://de.cyverse.org/formation/mcp>; each client signs in to it with your CyVerse
account.

- **`Configuration error: FORMATION_BASE_URL is required`**, or tools failing with
  **`login failed with status 404`**: this is the local `formation-mcp` that older
  installs built. It stopped working when CyVerse moved Formation to the hosted server.
  Re-run the installer to replace it, or follow
  [Moving from the local formation-mcp](servers/formation-mcp.md#moving-from-the-local-formation-mcp).
- **`MCP server formation already exists in user config`** when adding the hosted server
  to Claude Code: remove the old entry first, `claude mcp remove formation -s user`.
- **The CyVerse sign-in page says `Invalid parameter: redirect_uri`**: CyVerse does not
  accept that client's sign-in callback yet. CyVerse documents claude.ai's callback and
  `http://localhost…` (Claude Code); Codex and OpenCode call back to
  `http://127.0.0.1…`, which that list does not cover. Report the client and its version
  to [CyVerse support](https://user.cyverse.org/support) and use Claude Code or the
  [claude.ai connector](claude-ai.md) meanwhile.
- **OpenCode's (or Goose's) sign-in never finishes on a remote machine**: they wait for
  the browser to return to the machine they run on. Sign in from Claude Code there
  instead (`claude mcp login formation --no-browser`).
- **`codex mcp login` says `unexpected argument '--no-browser'`**: that option needs
  Codex 0.156 or newer. Update with `npm install -g @openai/codex@latest`.
- **The installer says Codex is older than 0.77 and `formation` was not registered**:
  update Codex (`npm install -g @openai/codex@latest`) and re-run with `--for codex`.
- **`authentication error`** (HTTP 500) from Formation: its connection to CyVerse's
  sign-in service failed. Try again later and check <https://status.cyverse.org>.
- **A launch times out in Codex**: Codex stops waiting for a tool after its default limit
  (300 seconds from Codex 0.141, 60 or 120 seconds before); add `tool_timeout_sec = 600`
  under `[mcp_servers.formation]` in `~/.codex/config.toml` (the installer sets it;
  `codex mcp add` does not).

## iRODS calls return permission errors

Anonymous access is read-only on public collections. To write AVUs or read private data,
[authenticate](credentials.md) — either re-run with `CYVERSE_USERNAME` / `CYVERSE_PASSWORD`,
or run `iinit` to set up `~/.irods`.

## `grep: /etc/os-release: No such file or directory`

Harmless. It comes from the `irods-mcp-server` Makefile probing the OS on macOS; the build
still succeeds.

## Starting over

```bash
curl -fsSL https://raw.githubusercontent.com/idss-mesa/docs/main/install.sh | bash -s -- --uninstall
```

removes the three servers from every detected client and (after confirmation) deletes `~/.mesa`.
