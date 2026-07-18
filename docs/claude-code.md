---
type: Integration Guide
title: Claude Code integration
description: How MESA registers its MCP servers with Claude Code — scopes, management commands, and the registration it creates.
tags:
  - claude-code
  - mcp
  - registration
  - scopes
timestamp: "2026-07-18T00:00:00Z"
---

# Claude Code integration

MESA registers each server as a **local stdio** MCP server: Claude Code launches the
binary as a subprocess and talks to it over standard input/output. No network ports, no
hosted service required. Claude Code is one of four clients MESA supports — see also
[Codex CLI](codex.md), [Antigravity](antigravity.md), and [OpenCode](opencode.md).

## Scopes

The installer uses **user scope** (`-s user`) so the servers are available in every Claude
Code project on your machine. The three scopes Claude Code supports:

| Scope | Stored in | Visible to |
|---|---|---|
| `local` | your user config, keyed to the current project | just you, just this project |
| `user` | your user config | you, every project *(MESA default)* |
| `project` | `.mcp.json` committed in the repo | everyone who clones the repo |

Override with `MCP_SCOPE`, e.g. `MCP_SCOPE=project` to drop a shareable `.mcp.json` into the
current directory instead.

## Managing the servers

```bash
claude mcp list                 # show all servers + health
claude mcp get mesa-mcp         # show one server's config
claude mcp remove mesa-mcp -s user
```

## The registration MESA creates

User-scope registrations live in `~/.claude.json`; project scope lands in a `.mcp.json`
committed at the repo root.

```jsonc
{
  "mcpServers": {
    "mesa-mcp":  { "type": "stdio", "command": "~/.mesa/.venv/bin/mesa-mcp",
                   "args": ["--transport", "stdio"], "env": {} },
    "irods":     { "type": "stdio", "command": "~/.mesa/bin/irods-mcp-server",
                   "args": ["-c", "~/.mesa/repos/irods-mcp-server/config-stdio.yaml"], "env": {} },
    "formation": { "type": "stdio", "command": "~/.mesa/bin/formation-mcp",
                   "args": ["--transport", "stdio"], "env": {} }
  }
}
```

!!! note "mesa-ducklake is not listed here"
    `mesa-ducklake` is a **library** imported by `mesa-mcp`, not a separate MCP server. Its
    capabilities surface through `mesa-mcp`'s `mesa_ducklake_*` tools. See
    [its page](servers/mesa-ducklake.md).

## Conflicting scopes

If `claude mcp list` warns that a server is *"defined in multiple scopes"*, you have the
same name registered more than once (e.g. an older hand-rolled entry plus the MESA one).
Keep the one you want and remove the rest:

```bash
claude mcp remove mesa-mcp -s user
claude mcp remove mesa-mcp -s local
```

## Alternative: hosted / remote servers

Local stdio is the default and needs no auth for public data. CyVerse also runs **hosted**
MCP endpoints you can connect to instead of building locally — for example the public
iRODS server at `https://mcp.cyverse.ai/mcp`:

```bash
claude mcp add --transport http cyverse-irods https://mcp.cyverse.ai/mcp
```

Hosted `mesa-mcp` (Streamable HTTP / SSE behind CyVerse Keycloak OIDC) is documented in the
[mesa-mcp repo](https://github.com/idss-mesa/mesa-mcp); it requires authentication. The MESA
installer focuses on the local build because it works offline-of-auth and gives you live,
editable source.
