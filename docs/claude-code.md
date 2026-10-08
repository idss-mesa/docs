---
type: Integration Guide
title: Claude Code integration
description: How MESA registers its MCP servers with Claude Code — scopes, management commands, the registration it creates, and the hosted Formation server and claude.ai connectors.
tags:
  - claude-code
  - mcp
  - registration
  - scopes
generated:
  by: "claude-code/2.1.294"
  at: "2026-10-08T00:00:00Z"
sources:
  - id: claude-code-mcp
    resource: "https://code.claude.com/docs/en/mcp"
    title: "Claude Code MCP documentation"
    author: "team:anthropic"
  - id: install-sh
    resource: "https://github.com/idss-mesa/docs/blob/main/install.sh"
    title: "MESA install.sh"
    author: "team:idss-mesa"
  - id: formation
    resource: "https://github.com/cyverse-de/formation"
    title: "Formation source repository (README and landing page)"
    author: "team:cyverse-de"
  - id: mesa-apps
    resource: "https://github.com/idss-mesa/cli/blob/main/bash/configs/claude.json"
    title: "MESA app images: Claude Code MCP config"
    author: "team:idss-mesa"
status: stable
stale_after: "2027-04-08T00:00:00Z"
---

# Claude Code integration

MESA registers `mesa-mcp` and `irods` as **local stdio** MCP servers: Claude Code
launches each binary as a subprocess and talks to it over standard input/output. It
registers `formation` as a **remote HTTP** server: [Formation](servers/formation-mcp.md)
is hosted by CyVerse at <https://de.cyverse.org/formation/mcp>, and you sign in to it once
with your CyVerse account. Claude Code is one of four clients MESA supports — see also
[Codex CLI](codex.md), [Antigravity](antigravity.md), and [OpenCode](opencode.md), and
[claude.ai and Claude Desktop](claude-ai.md) for connectors.

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
    "formation": { "type": "http", "url": "https://de.cyverse.org/formation/mcp" }
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

## Hosted servers and connectors

### Formation

Formation runs only as CyVerse's hosted server; the installer registers it for you. To
add it by hand (in every project, at user scope):

```bash
claude mcp add --transport http --scope user formation https://de.cyverse.org/formation/mcp
```

`claude mcp list` shows it as **Needs authentication** until you sign in. Run `/mcp` inside
Claude Code, pick **formation**, and choose **Authenticate**; or run
`claude mcp login formation` from a shell (add `--no-browser` on a remote machine and paste
the redirect URL back). Claude Code stores the sign-in and refreshes it[^claude-code-mcp].

Upgrading from an older MESA install? Its `formation` entry was a local server that no
longer works, and `claude mcp add` at user scope fails while that entry exists. Re-run the
installer, or run `claude mcp remove formation -s user` first. See
[Moving from the local formation-mcp](servers/formation-mcp.md#moving-from-the-local-formation-mcp).

### claude.ai connectors

If you are signed in to Claude Code with a claude.ai subscription, connectors you added on
claude.ai — such as a [CyVerse Formation connector](claude-ai.md) — are available in
Claude Code automatically. A server you registered in Claude Code itself takes precedence
over a connector with the same URL, so the connector is hidden rather than listed twice.
Connectors are not loaded when Claude Code runs with an API key or another model provider.

### CyVerse Data Store (iRODS)

CyVerse also hosts Data Store MCP endpoints, which the MESA featured apps register
alongside the local servers[^mesa-apps]:

```bash
# public data under /iplant/home/shared, no sign-in
claude mcp add --transport http --scope user irods-public https://mcp-public.cyverse.ai/mcp

# your own data: CyVerse's pre-registered OAuth client, then sign in
claude mcp add --transport http --scope user --client-id mcp-client --callback-port 8990 \
  irods-auth https://mcp.cyverse.ai/mcp
claude mcp login irods-auth
```

The names avoid a clash with the installer's local `irods`. Hosted `mesa-mcp`
(Streamable HTTP / SSE behind CyVerse Keycloak OIDC) is documented in the
[mesa-mcp repo](https://github.com/idss-mesa/mesa-mcp); it requires authentication. The
MESA installer builds `mesa-mcp` and `irods` locally because they work without signing in
and give you live, editable source.

[^claude-code-mcp]: Claude Code MCP documentation, <https://code.claude.com/docs/en/mcp>.
[^mesa-apps]: MESA app images, Claude Code MCP config, <https://github.com/idss-mesa/cli/blob/main/bash/configs/claude.json>.
