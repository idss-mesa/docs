---
type: Integration Guide
title: Antigravity integration
description: How MESA registers its MCP servers with Google Antigravity (IDE and agy CLI) by writing mcp_config.json.
tags:
  - antigravity
  - gemini
  - mcp
  - registration
timestamp: "2026-07-18T00:00:00Z"
---

# Antigravity integration

[Google Antigravity](https://antigravity.google/) is Google's agentic IDE, paired with
the `agy` CLI. Antigravity has **no non-interactive `add` command**, so the MESA
installer writes its MCP config file directly. See also the sibling pages for
[Claude Code](claude-code.md), [Codex CLI](codex.md), and [OpenCode](opencode.md).

## Where the config lives

The installer targets `$HOME/.gemini/config/mcp_config.json` — the Antigravity 2.0
unified config read by **both** the IDE and the `agy` CLI — with a top-level
`"mcpServers"` object. Antigravity does not expand `~` or `$HOME`, so every path in the
file is **absolute**.

Older releases read `~/.gemini/antigravity/mcp_config.json` (IDE) and
`~/.gemini/antigravity-cli/mcp_config.json` (CLI) instead. The installer updates
**every one of these files that already exists**; the unified path is created only when
none of them exist yet. The install summary prints exactly which files were written.

## Managing the servers

There is no CLI to list or remove servers. Open the IDE's **Manage MCP Servers** panel
to view and refresh them, or restart `agy`. To remove the MESA servers, delete their
entries from the JSON — or run `install.sh --uninstall`, which does it for you.

## The registration MESA creates

```json
{
  "mcpServers": {
    "mesa-mcp": {
      "command": "/home/you/.mesa/.venv/bin/mesa-mcp",
      "args": ["--transport", "stdio"],
      "env": { "MESA_MCP_IRODS__USER": "you", "MESA_MCP_IRODS__PASSWORD": "••••••" }
    },
    "irods": {
      "command": "/home/you/.mesa/bin/irods-mcp-server",
      "args": ["-c", "/home/you/.mesa/repos/irods-mcp-server/config-stdio.yaml"]
    },
    "formation": {
      "command": "/home/you/.mesa/bin/formation-mcp",
      "args": ["--transport", "stdio"],
      "env": { "FORMATION_USERNAME": "you", "FORMATION_PASSWORD": "••••••" }
    }
  }
}
```

The `env` objects only appear when you installed with [credentials](credentials.md).
The installer **merges** its entries into an existing file — any other MCP servers you
have configured are left untouched.

!!! note "mesa-ducklake is not listed here"
    `mesa-ducklake` is a **library** imported by `mesa-mcp`, not a separate MCP server. Its
    capabilities surface through `mesa-mcp`'s `mesa_ducklake_*` tools. See
    [its page](servers/mesa-ducklake.md).

## Troubleshooting notes

- Servers not appearing → refresh via **Manage MCP Servers** in the IDE, or restart
  `agy` (the config is not hot-reloaded).
- Launch failures that look like "command not found" → confirm the `command` paths in
  the JSON are absolute (`/home/you/...`, never `~`).
- Nothing at `~/.gemini/config/mcp_config.json` → the installer found and updated a
  legacy config instead — check the paths above (the install summary lists which files
  were written).

More in the general [Troubleshooting](troubleshooting.md) page.
