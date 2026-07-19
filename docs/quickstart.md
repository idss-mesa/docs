---
type: Guide
title: Quickstart
description: Install the MESA MCP stack and register it with your agent client in a few minutes.
tags:
  - quickstart
  - install
  - claude-code
  - codex
  - antigravity
  - opencode
timestamp: "2026-07-18T00:00:00Z"
---

# Quickstart

## 1. Prerequisites

The installer checks for these and helps you install the missing ones:

| Tool | Needed for | Notes |
|---|---|---|
| `git`, `curl` | cloning + downloading | usually preinstalled |
| an agent client | the integration target | any of the four below — the installer auto-detects the ones present and refuses to run if it finds none |
| `uv` | Python servers | auto-installed from [astral.sh/uv](https://docs.astral.sh/uv/) if missing |
| Go ≥ 1.25 | the two Go servers | only needed for `irods` + `formation`; pass `--no-go` to skip them |

Supported agent clients:

| Client | Detected via | Integration page |
|---|---|---|
| Claude Code | `claude` on `PATH` | [Claude Code](claude-code.md) |
| Codex CLI | `codex` on `PATH` | [Codex CLI](codex.md) |
| Antigravity | `agy` on `PATH`, the IDE app, or a `~/.gemini` config dir | [Antigravity](antigravity.md) |
| OpenCode | `opencode` on `PATH` | [OpenCode](opencode.md) |

Other clients[^openclaw] can reuse the [manual install](install.md#manual-install) steps.

[^openclaw]: OpenClaw support is deferred until its MCP interface can be verified.

!!! tip "Windows users"
    Run everything inside **WSL** (Ubuntu or similar). The installer detects WSL and
    treats it as Linux. Native PowerShell / `cmd` are not supported.

## 2. Install

```bash
curl -fsSL https://raw.githubusercontent.com/idss-mesa/docs/main/install.sh | bash
```

This will:

1. Detect your platform (Linux / macOS / WSL).
2. Clone the four repos from `idss-mesa` into `~/.mesa/repos/`.
3. Create a Python venv at `~/.mesa/.venv` and install `mesa-ducklake` + `mesa-mcp`.
4. Build the Go servers into `~/.mesa/bin/`.
5. Register `mesa-mcp`, `irods`, and `formation` with **every detected client** —
   Claude Code at user scope, Codex globally, Antigravity and OpenCode via their config
   files. Restrict targets with `--for`, e.g. `bash -s -- --for claude,codex`.

## 3. Verify

=== "Claude Code"

    ```bash
    claude mcp list
    ```

=== "Codex"

    ```bash
    codex mcp list      # or /mcp inside a Codex session
    ```

=== "Antigravity"

    Open the IDE's **Manage MCP Servers** panel (or restart `agy`) and confirm the
    three servers are listed.

=== "OpenCode"

    ```bash
    opencode mcp list
    ```

You should see `mesa-mcp`, `irods`, and `formation` listed. Then, in your agent
session, try:

> *Ping the CyVerse Data Store and list what's in the shared directory.*

That exercises `mesa-mcp`'s `ds_ping` and `ds_list_directory` tools against the public
`data.cyverse.org` zone — no login needed.

## 4. (Optional) Authenticate

Anonymous access is read-only on public collections. To act as yourself, re-run with your
[CyVerse](https://cyverse.org) credentials:

```bash
CYVERSE_USERNAME=you CYVERSE_PASSWORD='••••••' \
  curl -fsSL https://raw.githubusercontent.com/idss-mesa/docs/main/install.sh | bash
```

The credentials are threaded into **every** client registration the installer creates.
See [Credentials](credentials.md) for all the options (env vars, `~/.irods`, per-server config).

## Updating & uninstalling

Re-running the one-liner pulls the latest code and rebuilds — it is safe to run again.
Uninstalling removes the three servers from every detected client and (after
confirmation) deletes `~/.mesa`:

```bash
curl -fsSL https://raw.githubusercontent.com/idss-mesa/docs/main/install.sh | bash -s -- --uninstall
```
