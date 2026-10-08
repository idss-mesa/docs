---
type: Reference
title: Install reference
description: All install.sh flags, environment overrides, on-disk layout, and manual install steps for the MESA MCP stack.
tags:
  - install
  - flags
  - environment-variables
  - uninstall
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

# Install reference

The installer is a single POSIX `bash` script,
[`install.sh`](https://github.com/idss-mesa/docs/blob/main/install.sh). You can pipe it
from `curl` or clone this repo and run it directly.

```bash
# one-liner
curl -fsSL https://raw.githubusercontent.com/idss-mesa/docs/main/install.sh | bash

# from a clone
git clone https://github.com/idss-mesa/docs.git && ./docs/install.sh
```

## Flags

| Flag | Effect |
|---|---|
| `--prefix DIR` | install location (default `~/.mesa`) |
| `--for LIST` | comma-separated client targets: `claude`, `codex`, `antigravity`, `opencode` (default: auto-detect all present) |
| `--no-go` | skip the Go server (`irods`); `mesa-mcp` and the hosted `formation` are still registered (no Go toolchain needed) |
| `--uninstall` | remove the three servers (`mesa-mcp`, `irods`, `formation`) from **all detected clients** and delete the install dir |
| `--help` | print usage |

When piping through `curl`, pass flags after `-s --`:

```bash
curl -fsSL https://raw.githubusercontent.com/idss-mesa/docs/main/install.sh | bash -s -- --no-go
```

## Environment overrides

| Variable | Default | Purpose |
|---|---|---|
| `MESA_HOME` | `~/.mesa` | install location (same as `--prefix`) |
| `MESA_GIT_ORG` | `idss-mesa` | GitHub org to clone from |
| `MESA_MCP_REF` | `main` | branch/tag for `mesa-mcp` |
| `MESA_CLIENTS` | auto-detect | same as `--for` (the flag wins when both are set) |
| `MCP_SCOPE` | `user` | **Claude Code only** — registration scope: `user`, `project`, or `local` (the other clients have no scope concept) |
| `MESA_FORMATION_URL` | `https://de.cyverse.org/formation/mcp` | the hosted [Formation](servers/formation-mcp.md) endpoint registered as `formation` |
| `CYVERSE_USERNAME` / `CYVERSE_PASSWORD` | — | applied to `mesa-mcp` (`formation` signs in through the browser instead) |
| any `MESA_MCP_*` | — | passed through verbatim to `mesa-mcp` |

## What it lays down

```
~/.mesa/
├── repos/
│   ├── mesa-mcp/            # editable Python source
│   ├── mesa-ducklake/       # editable Python source
│   ├── mesa-anyjev/         # editable Python source (plugin for mesa-mcp)
│   └── irods-mcp-server/    # Go source
├── .venv/                   # uv-managed Python 3.11 venv
│   └── bin/mesa-mcp         # stdio MCP server entry point
└── bin/
    └── irods-mcp-server     # built Go binary
```

Nothing is installed for `formation`: it is CyVerse's hosted server, registered by URL.
Older installs also built a local `bin/formation-mcp`; a re-run deletes
that binary and replaces the old registration (see
[Moving from the local formation-mcp](servers/formation-mcp.md#moving-from-the-local-formation-mcp)).
You can delete the leftover `repos/formation-mcp/` yourself.

## Idempotency

Every step is safe to repeat:

- Repos are `git pull --ff-only`'d if already present, cloned otherwise.
- The venv is recreated and packages reinstalled editable.
- The Go binary is rebuilt.
- For the CLI clients (Claude Code, Codex), each `mcp add` is preceded by an
  `mcp remove`, so re-running updates the registration in place rather than duplicating it.
  Claude Code's hosted `formation` entry is left alone when it is already right, because
  removing it would also delete your Formation sign-in. For Codex, `formation` is written
  straight into `~/.codex/config.toml`, because `codex mcp add --url` would start an
  interactive sign-in; Codex older than 0.77 is skipped with a warning.
- Config files the installer rewrites keep their permissions (a new one is created
  readable by you only), and a symlinked config is written through the link.
- For the config-file clients (Antigravity, OpenCode), the installer rewrites its own
  entries in the JSON, leaving any other servers you have configured untouched.

## Manual install

If you'd rather not use the script, the equivalent steps are:

```bash
# Python servers
uv venv --python 3.11 ~/.mesa/.venv
uv pip install --python ~/.mesa/.venv/bin/python -e ./mesa-ducklake -e ./mesa-mcp

# Go server
( cd irods-mcp-server && make build )                     # -> bin/irods-mcp-server
mkdir -p ~/.mesa/bin
cp irods-mcp-server/bin/irods-mcp-server ~/.mesa/bin/
```

Formation needs no build: register its URL and sign in.

Then register the servers with your client:

=== "Claude Code"

    ```bash
    claude mcp add mesa-mcp  -s user -- ~/.mesa/.venv/bin/mesa-mcp --transport stdio
    claude mcp add irods     -s user -- ~/.mesa/bin/irods-mcp-server -c .../config-stdio.yaml
    claude mcp add --transport http -s user formation https://de.cyverse.org/formation/mcp
    ```

    Then sign in to Formation with `/mcp` inside Claude Code or `claude mcp login formation`.

=== "Codex"

    ```bash
    codex mcp add mesa-mcp  -- ~/.mesa/.venv/bin/mesa-mcp --transport stdio
    codex mcp add irods     -- ~/.mesa/bin/irods-mcp-server -c .../config-stdio.yaml
    codex mcp add formation --url https://de.cyverse.org/formation/mcp   # signs you in now
    ```

    `codex mcp add` does not set a tool timeout. Add `tool_timeout_sec = 600` under
    `[mcp_servers.formation]` in `~/.codex/config.toml`, or launches that wait longer than
    Codex's default limit are cut off.

=== "Antigravity"

    Write the servers into `$HOME/.gemini/config/mcp_config.json` — absolute paths
    required, and `serverUrl` for `formation`. See
    [the registration MESA creates](antigravity.md#the-registration-mesa-creates).

=== "OpenCode"

    Add the servers to `~/.config/opencode/opencode.json` (respecting
    `$XDG_CONFIG_HOME`) under the `mcp` key, with `formation` as a `remote` server, then
    run `opencode mcp auth formation`. See
    [the registration MESA creates](opencode.md#the-registration-mesa-creates).
