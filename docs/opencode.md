---
type: Integration Guide
title: OpenCode integration
description: How MESA registers its MCP servers in OpenCode's global opencode.json, and how to verify them.
tags:
  - opencode
  - mcp
  - registration
generated:
  by: "claude-code/2.1.294"
  at: "2026-10-08T00:00:00Z"
sources:
  - id: opencode-mcp
    resource: "https://opencode.ai/docs/mcp-servers/"
    title: "OpenCode MCP servers documentation"
    author: "team:opencode"
  - id: install-sh
    resource: "https://github.com/idss-mesa/docs/blob/main/install.sh"
    title: "MESA install.sh"
    author: "team:idss-mesa"
  - id: opencode-source
    resource: "https://github.com/sst/opencode/blob/main/packages/opencode/src/cli/cmd/mcp.ts"
    title: "OpenCode CLI source: opencode mcp auth / add / debug"
    author: "team:opencode"
  - id: formation
    resource: "https://github.com/cyverse-de/formation"
    title: "Formation source repository (README and landing page)"
    author: "team:cyverse-de"
status: stable
stale_after: "2027-04-08T00:00:00Z"
---

# OpenCode integration

[OpenCode](https://opencode.ai) is an open-source terminal coding agent. The MESA
installer writes its global config directly, which works with every OpenCode release
(older releases have no non-interactive `opencode mcp add`). `mesa-mcp` and `irods` are
registered as local servers; `formation` is registered as a remote server pointing at
CyVerse's hosted [Formation](servers/formation-mcp.md), which you sign in to once. See also the sibling pages for [Claude Code](claude-code.md),
[Codex CLI](codex.md), and [Antigravity](antigravity.md).

## Where the config lives

`~/.config/opencode/opencode.json` (respecting `$XDG_CONFIG_HOME` if you have it set),
under the `"mcp"` key. The global file
**deep-merges** with any per-project `opencode.json`, so a project can locally override
or disable a MESA server (set `"enabled": false` in the project file) without touching
the global registration.

## Managing the servers

```bash
opencode mcp list               # verify the servers are registered
opencode mcp auth formation     # sign in to Formation with your CyVerse account
opencode mcp auth list          # sign-in status of remote servers
opencode mcp logout formation   # forget the Formation sign-in
opencode mcp debug formation    # diagnose a remote server that will not connect
```

Config is read at startup — **restart OpenCode** after changes. To remove the MESA
servers, delete their entries from the JSON — or run `install.sh --uninstall`.

## The registration MESA creates

Note the argv-array `command` on the local servers — program and arguments together,
unlike the other clients' command + args split — and the `url` on the remote one:

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
      "type": "remote",
      "url": "https://de.cyverse.org/formation/mcp",
      "enabled": true
    }
  }
}
```

The `environment` object on `mesa-mcp` only appears when you installed with
[credentials](credentials.md); `formation` never takes credentials. The installer **merges** its entries into an existing
file — other servers and settings are left untouched.

!!! note "mesa-ducklake is not listed here"
    `mesa-ducklake` is a **library** imported by `mesa-mcp`, not a separate MCP server. Its
    capabilities surface through `mesa-mcp`'s `mesa_ducklake_*` tools. See
    [its page](servers/mesa-ducklake.md).

## Signing in to Formation

Run `opencode mcp auth formation`. OpenCode registers itself with Formation automatically,
opens the CyVerse sign-in page in your browser, and waits for the sign-in to come back to
it on this computer; it stores the result in `~/.local/share/opencode/mcp-auth.json`[^opencode-source].
Until you sign in, OpenCode marks `formation` as needing authentication and tells you to
run that command.

Because the sign-in has to return to the computer OpenCode runs on, it does not complete
when OpenCode runs on a remote machine (such as a MESA app on CyVerse) and the browser on
yours. There, use Claude Code: `claude mcp login formation --no-browser` lets you paste
the sign-in result back by hand.

## Troubleshooting notes

- `opencode mcp list` missing the servers → restart OpenCode (config is read at
  startup), then inspect the global `opencode.json` (path above).
- A server present globally but absent in one project → check that project's
  `opencode.json` for a deep-merged entry overriding or disabling it.
- `formation` failing to connect → `opencode mcp auth formation`, then
  `opencode mcp debug formation`.

More in the general [Troubleshooting](troubleshooting.md) page.

[^opencode-source]: OpenCode MCP documentation and CLI source, <https://opencode.ai/docs/mcp-servers/> and <https://github.com/sst/opencode/blob/main/packages/opencode/src/cli/cmd/mcp.ts>.
