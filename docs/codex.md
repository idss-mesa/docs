---
type: Integration Guide
title: Codex CLI integration
description: How MESA registers its MCP servers with the OpenAI Codex CLI, and how to manage them there.
tags:
  - codex
  - mcp
  - registration
  - config-toml
timestamp: "2026-07-18T00:00:00Z"
---

# Codex CLI integration

MESA registers each server as a **local stdio** MCP server via `codex mcp add`: Codex
launches the binary as a subprocess and talks to it over standard input/output. See also
the sibling pages for [Claude Code](claude-code.md), [Antigravity](antigravity.md), and
[OpenCode](opencode.md).

## Scope

Codex has **no scope flag** — every registration is global, stored in
`~/.codex/config.toml` under a `[mcp_servers.<name>]` table with `command`, `args`, and
`env` keys. Unlike Claude Code there is no project or local scope; the installer's
`MCP_SCOPE` variable is ignored for Codex.

## Managing the servers

```bash
codex mcp list            # show all servers
codex mcp get mesa-mcp    # show one server's config
codex mcp remove mesa-mcp
```

Inside a Codex TUI session, run `/mcp` to verify the servers and their tools loaded.
Registration changes are read at startup — **restart the session** to pick them up.

## The registration MESA creates

The installer runs `codex mcp add <name> --env K=V -- <command> <args>` for each server,
which writes:

```toml
# ~/.codex/config.toml
[mcp_servers.mesa-mcp]
command = "/home/you/.mesa/.venv/bin/mesa-mcp"
args = ["--transport", "stdio"]
env = { MESA_MCP_IRODS__USER = "you", MESA_MCP_IRODS__PASSWORD = "••••••" }

[mcp_servers.irods]
command = "/home/you/.mesa/bin/irods-mcp-server"
args = ["-c", "/home/you/.mesa/repos/irods-mcp-server/config-stdio.yaml"]

[mcp_servers.formation]
command = "/home/you/.mesa/bin/formation-mcp"
args = ["--transport", "stdio"]
env = { FORMATION_USERNAME = "you", FORMATION_PASSWORD = "••••••" }
```

The `env` tables only appear when you installed with
[credentials](credentials.md); anonymous installs omit them.

!!! note "mesa-ducklake is not listed here"
    `mesa-ducklake` is a **library** imported by `mesa-mcp`, not a separate MCP server. Its
    capabilities surface through `mesa-mcp`'s `mesa_ducklake_*` tools. See
    [its page](servers/mesa-ducklake.md).

## Troubleshooting notes

- Servers not visible in a session → restart Codex (config is read at startup), then
  check `/mcp`.
- `/mcp` shows nothing → `codex mcp list`, then inspect `~/.codex/config.toml`.
- Re-running the installer updates the entries in place (it removes and re-adds each
  server), so a stale path after moving `~/.mesa` is fixed by a re-run.

More in the general [Troubleshooting](troubleshooting.md) page.
