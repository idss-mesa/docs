---
type: Integration Guide
title: Codex CLI integration
description: How MESA registers its MCP servers with the OpenAI Codex CLI, and how to manage them there.
tags:
  - codex
  - mcp
  - registration
  - config-toml
generated:
  by: "claude-code/2.1.294"
  at: "2026-10-08T00:00:00Z"
sources:
  - id: codex-mcp
    resource: "https://developers.openai.com/codex/mcp"
    title: "Codex MCP documentation"
    author: "team:openai"
  - id: install-sh
    resource: "https://github.com/idss-mesa/docs/blob/main/install.sh"
    title: "MESA install.sh"
    author: "team:idss-mesa"
  - id: codex-source
    resource: "https://github.com/openai/codex/blob/main/codex-rs/cli/src/mcp_cmd.rs"
    title: "Codex CLI source: mcp add / login / logout"
    author: "team:openai"
  - id: formation
    resource: "https://github.com/cyverse-de/formation"
    title: "Formation source repository (README)"
    author: "team:cyverse-de"
status: stable
stale_after: "2027-04-08T00:00:00Z"
---

# Codex CLI integration

MESA registers `mesa-mcp` and `irods` as **local stdio** MCP servers via `codex mcp add`:
Codex launches each binary as a subprocess and talks to it over standard input/output.
It registers `formation` as a **streamable HTTP** server pointing at CyVerse's hosted
[Formation](servers/formation-mcp.md), which you sign in to once with your CyVerse account.
See also the sibling pages for [Claude Code](claude-code.md), [Antigravity](antigravity.md),
and [OpenCode](opencode.md).

## Scope

Codex has **no scope flag** — every registration is global, stored in
`~/.codex/config.toml` (or `$CODEX_HOME/config.toml`) under a `[mcp_servers.<name>]`
table: `command`, `args`, and `env` keys for a local server, `url` for a remote one. Unlike Claude Code there is no project or local scope; the installer's
`MCP_SCOPE` variable is ignored for Codex.

## Managing the servers

```bash
codex mcp list               # show all servers, with their sign-in status
codex mcp get mesa-mcp       # show one server's config
codex mcp remove mesa-mcp
codex mcp login formation    # sign in to Formation (add --no-browser on a remote machine; Codex 0.156+)
codex mcp logout formation   # sign out; run it before removing formation, it needs the entry
```

Inside a Codex TUI session, run `/mcp` to verify the servers and their tools loaded.
Registration changes are read at startup — **restart the session** to pick them up.

## The registration MESA creates

The installer runs `codex mcp add <name> --env K=V -- <command> <args>` for each local
server. For `formation` it writes the table itself, because `codex mcp add --url` starts
the browser sign-in straight away, which would stall an unattended install[^codex-source].
The result:

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
url = "https://de.cyverse.org/formation/mcp"
tool_timeout_sec = 600
```

The `env` table on `mesa-mcp` only appears when you installed with
[credentials](credentials.md); anonymous installs omit it. `formation` never takes
credentials. `tool_timeout_sec = 600` lets `launch_app_and_wait` wait for an app for up to
the 9 minutes Formation allows. Codex's default limit is 300 seconds from Codex 0.141, and
60 or 120 seconds in older releases, which can be shorter than a VICE app takes to start.

!!! note "mesa-ducklake is not listed here"
    `mesa-ducklake` is a **library** imported by `mesa-mcp`, not a separate MCP server. Its
    capabilities surface through `mesa-mcp`'s `mesa_ducklake_*` tools. See
    [its page](servers/mesa-ducklake.md).

## Signing in to Formation

Run `codex mcp login formation`. Codex opens the CyVerse sign-in page in your browser.
On Codex 0.156 or newer, `--no-browser` prints the address instead and takes back the
address your browser lands on; with an older Codex, update it first with
`npm install -g @openai/codex@latest`. Until you sign in, Codex tells you at startup to
run `codex mcp login formation`. Remote servers with OAuth sign-in need Codex 0.77 or
newer; the installer skips `formation` for an older Codex and says so.

CyVerse has not confirmed that its sign-in accepts Codex's callback address
(`http://127.0.0.1:<port>/callback`). If the CyVerse page says
`Invalid parameter: redirect_uri`, see
[Troubleshooting](troubleshooting.md#formation-sign-in-and-connection).

To add Formation by hand instead of through the installer, paste the
`[mcp_servers.formation]` table above into `~/.codex/config.toml` and run
`codex mcp login formation`. Or run
`codex mcp add formation --url https://de.cyverse.org/formation/mcp` (it starts the
sign-in straight away) and add `tool_timeout_sec = 600` under the
`[mcp_servers.formation]` table it writes, because the command does not set a timeout.

## Troubleshooting notes

- Servers not visible in a session → restart Codex (config is read at startup), then
  check `/mcp`.
- `/mcp` shows nothing → `codex mcp list`, then inspect `~/.codex/config.toml`.
- Re-running the installer updates the entries in place (it removes and re-adds each
  server), so a stale path after moving `~/.mesa` is fixed by a re-run. It also replaces
  the local `formation` entry older installs created with the hosted one, and keeps your
  Formation sign-in.
- `formation` needs sign-in → `codex mcp login formation`.

More in the general [Troubleshooting](troubleshooting.md) page.

[^codex-source]: Codex CLI source, `codex mcp add`, <https://github.com/openai/codex/blob/main/codex-rs/cli/src/mcp_cmd.rs>.
