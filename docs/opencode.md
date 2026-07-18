---
type: Integration Guide
title: OpenCode integration
description: How MESA registers its MCP servers in OpenCode's global opencode.json, and how to verify them.
tags:
  - opencode
  - mcp
  - registration
timestamp: "2026-07-18T00:00:00Z"
---

# OpenCode integration

[OpenCode](https://opencode.ai) is an open-source terminal coding agent. Its
`opencode mcp add` command is **interactive-only**, so the MESA installer writes the
global config directly. See also the sibling pages for [Claude Code](claude-code.md),
[Codex CLI](codex.md), and [Antigravity](antigravity.md).

## Where the config lives

`~/.config/opencode/opencode.json` (respecting `$XDG_CONFIG_HOME` if you have it set),
under the `"mcp"` key. The global file
**deep-merges** with any per-project `opencode.json`, so a project can locally override
or disable a MESA server (set `"enabled": false` in the project file) without touching
the global registration.

## Managing the servers

```bash
opencode mcp list         # verify the servers are registered
```

Config is read at startup — **restart OpenCode** after changes. To remove the MESA
servers, delete their entries from the JSON — or run `install.sh --uninstall`.

## The registration MESA creates

Note the argv-array `command` — program and arguments together, unlike the other
clients' command + args split:

```json
{
  "mcp": {
    "mesa-mcp": {
      "type": "local",
      "command": ["/home/you/.mesa/.venv/bin/mesa-mcp", "--transport", "stdio"],
      "enabled": true,
      "environment": { "MESA_MCP_IRODS__USER": "you", "MESA_MCP_IRODS__PASSWORD": "••••••" }
    },
    "irods": {
      "type": "local",
      "command": ["/home/you/.mesa/bin/irods-mcp-server", "-c", "/home/you/.mesa/repos/irods-mcp-server/config-stdio.yaml"],
      "enabled": true
    },
    "formation": {
      "type": "local",
      "command": ["/home/you/.mesa/bin/formation-mcp", "--transport", "stdio"],
      "enabled": true,
      "environment": { "FORMATION_USERNAME": "you", "FORMATION_PASSWORD": "••••••" }
    }
  }
}
```

The `environment` objects only appear when you installed with
[credentials](credentials.md). The installer **merges** its entries into an existing
file — other servers and settings are left untouched.

!!! note "mesa-ducklake is not listed here"
    `mesa-ducklake` is a **library** imported by `mesa-mcp`, not a separate MCP server. Its
    capabilities surface through `mesa-mcp`'s `mesa_ducklake_*` tools. See
    [its page](servers/mesa-ducklake.md).

## Troubleshooting notes

- `opencode mcp list` missing the servers → restart OpenCode (config is read at
  startup), then inspect the global `opencode.json` (path above).
- A server present globally but absent in one project → check that project's
  `opencode.json` for a deep-merged entry overriding or disabling it.

More in the general [Troubleshooting](troubleshooting.md) page.
