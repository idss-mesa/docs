---
type: Reference
title: Credentials
description: Authenticating the MESA servers to CyVerse — env vars at install time and native iRODS auth for mesa-mcp and irods, and browser sign-in for the hosted Formation server.
tags:
  - credentials
  - authentication
  - cyverse
  - irods
  - formation
generated:
  by: "claude-code/2.1.294"
  at: "2026-10-08T00:00:00Z"
sources:
  - id: install-sh
    resource: "https://github.com/idss-mesa/docs/blob/main/install.sh"
    title: "MESA install.sh"
    author: "team:idss-mesa"
  - id: mesa-mcp-env
    resource: "https://github.com/idss-mesa/mesa-mcp/blob/main/.env.example"
    title: "mesa-mcp .env.example"
    author: "team:idss-mesa"
  - id: formation
    resource: "https://github.com/cyverse-de/formation"
    title: "Formation source repository (README)"
    author: "team:cyverse-de"
  - id: icommands
    resource: "https://learning.cyverse.org/ds/icommands/"
    title: "CyVerse iCommands guide"
    author: "team:cyverse"
status: stable
stale_after: "2027-04-08T00:00:00Z"
---

# Credentials

By default the two local MESA servers, `mesa-mcp` and `irods`, connect **anonymously** to
public CyVerse infrastructure (`data.cyverse.org`, zone `iplant`, user `anonymous`). That
is enough to read public collections. To write metadata or reach private data as
yourself, give them your CyVerse credentials as described below.

`formation`, the hosted Discovery Environment server, works differently: it has no
anonymous access and takes no credentials from you or the installer. Each client signs in
to it with your CyVerse account in the browser — see
[formation](#formation-sign-in-with-your-cyverse-account) below.

## Quickest path — env vars at install time

```bash
CYVERSE_USERNAME=you CYVERSE_PASSWORD='••••••' \
  curl -fsSL https://raw.githubusercontent.com/idss-mesa/docs/main/install.sh | bash
```

The installer threads these into the `mesa-mcp` registration of **every client** it
configures, as `MESA_MCP_IRODS__USER` and `MESA_MCP_IRODS__PASSWORD`.

!!! warning "Where the password ends up"
    These land in plaintext in each client's config file: `~/.claude.json` (Claude Code
    user scope), `~/.codex/config.toml`, `$HOME/.gemini/config/mcp_config.json`, and
    `${XDG_CONFIG_HOME:-~/.config}/opencode/opencode.json`. Prefer the `~/.irods` method below if you don't
    want the password stored there, and never commit a `project`-scope `.mcp.json`
    containing secrets.

## mesa-mcp & irods — native iRODS auth

Both iRODS servers honor a standard iRODS environment. If you use the CyVerse
[iCommands](https://learning.cyverse.org/ds/icommands/), run `iinit` once to create:

```
~/.irods/irods_environment.json   # host, zone, user
~/.irods/.irodsA                  # scrambled password
```

`mesa-mcp` reads these automatically in stdio mode — no env vars needed.

For `irods-mcp-server`, edit its stdio config to add credentials:

```yaml
# ~/.mesa/repos/irods-mcp-server/config-stdio.yaml
irods_host: data.cyverse.org
irods_zone_name: iplant
irods_user_name: you
irods_user_password: ••••••
```

## mesa-mcp — full env reference

`mesa-mcp` uses `MESA_MCP_` env vars (double underscore for nesting). The most useful:

| Variable | Default | Meaning |
|---|---|---|
| `MESA_MCP_IRODS__HOST` | `data.cyverse.org` | iRODS host |
| `MESA_MCP_IRODS__ZONE` | `iplant` | iRODS zone |
| `MESA_MCP_IRODS__USER` | `anonymous` | username |
| `MESA_MCP_IRODS__PASSWORD` | — | password |
| `MESA_MCP_DUCKLAKE__CATALOG_DSN` | — | DuckLake catalog (`duckdb:///path` or `postgresql://…`); blank disables history |

Any `MESA_MCP_*` variable set in your shell at install time is passed through to the server.
The full list is in [`mesa-mcp/.env.example`](https://github.com/idss-mesa/mesa-mcp/blob/main/.env.example).

## formation — sign in with your CyVerse account

[Formation](servers/formation-mcp.md) is hosted by CyVerse at
<https://de.cyverse.org/formation/mcp> and uses the standard MCP sign-in: OAuth 2.1 with
PKCE against CyVerse's Keycloak[^formation]. The first time a client connects, it opens the
CyVerse sign-in page in your browser; the client then stores the sign-in and refreshes it.

| Client | Sign in |
|---|---|
| Claude Code | `/mcp` inside Claude Code, or `claude mcp login formation` (`--no-browser` on a remote machine) |
| Codex | `codex mcp login formation` |
| OpenCode | `opencode mcp auth formation` |
| Antigravity | the IDE's MCP servers panel |
| claude.ai and Claude Desktop | **Connect** on the connector — see [claude.ai and Claude Desktop](claude-ai.md) |

No password is stored in any config file, and `CYVERSE_USERNAME`, `~/.irods`, and
`cyverse-login` do not apply. Only personal CyVerse accounts can sign in.

The `~/.formation-mcp.yaml` file and the `FORMATION_*` variables belonged to the old local
`formation-mcp` server and are no longer used; see
[Moving from the local formation-mcp](servers/formation-mcp.md#moving-from-the-local-formation-mcp).

## DataCite (optional)

DataCite DOI tools in `mesa-mcp` only need credentials when you mint/publish DOIs. See the
[mesa-mcp docs](https://github.com/idss-mesa/mesa-mcp) for the DataCite configuration.

[^formation]: Formation README, <https://github.com/cyverse-de/formation>.
