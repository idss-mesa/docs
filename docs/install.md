---
type: Reference
title: Install reference
description: All install.sh flags, environment overrides, on-disk layout, and manual install steps for the MESA MCP stack.
tags:
  - install
  - flags
  - environment-variables
  - uninstall
timestamp: "2026-07-18T00:00:00Z"
---

# Install reference

The installer is a single POSIX `bash` script,
[`install.sh`](https://github.com/idss-mesa/mesa/blob/main/install.sh). You can pipe it
from `curl` or clone this repo and run it directly.

```bash
# one-liner
curl -fsSL https://raw.githubusercontent.com/idss-mesa/mesa/main/install.sh | bash

# from a clone
git clone https://github.com/idss-mesa/mesa.git && ./mesa/install.sh
```

## Flags

| Flag | Effect |
|---|---|
| `--prefix DIR` | install location (default `~/.mesa`) |
| `--for LIST` | comma-separated client targets: `claude`, `codex`, `antigravity`, `opencode` (default: auto-detect all present) |
| `--no-go` | skip the Go servers; install only `mesa-mcp` (no Go toolchain needed) |
| `--uninstall` | remove the three servers from **all detected clients** and delete the install dir |
| `--help` | print usage |

When piping through `curl`, pass flags after `-s --`:

```bash
curl -fsSL https://raw.githubusercontent.com/idss-mesa/mesa/main/install.sh | bash -s -- --no-go
```

## Environment overrides

| Variable | Default | Purpose |
|---|---|---|
| `MESA_HOME` | `~/.mesa` | install location (same as `--prefix`) |
| `MESA_GIT_ORG` | `idss-mesa` | GitHub org to clone from |
| `MESA_MCP_REF` | `main` | branch/tag for `mesa-mcp` |
| `MESA_CLIENTS` | auto-detect | same as `--for` (the flag wins when both are set) |
| `MCP_SCOPE` | `user` | **Claude Code only** — registration scope: `user`, `project`, or `local` (the other clients have no scope concept) |
| `CYVERSE_USERNAME` / `CYVERSE_PASSWORD` | — | applied to `mesa-mcp` and `formation` |
| any `MESA_MCP_*` / `FORMATION_*` | — | passed through verbatim to the matching server |

## What it lays down

```
~/.mesa/
├── repos/
│   ├── mesa-mcp/            # editable Python source
│   ├── mesa-ducklake/       # editable Python source
│   ├── irods-mcp-server/    # Go source
│   └── formation-mcp/       # Go source
├── .venv/                   # uv-managed Python 3.11 venv
│   └── bin/mesa-mcp         # stdio MCP server entry point
└── bin/
    ├── irods-mcp-server     # built Go binary
    └── formation-mcp        # built Go binary
```

## Idempotency

Every step is safe to repeat:

- Repos are `git pull --ff-only`'d if already present, cloned otherwise.
- The venv is recreated and packages reinstalled editable.
- Go binaries are rebuilt.
- For the CLI clients (Claude Code, Codex), each `mcp add` is preceded by an
  `mcp remove`, so re-running updates the registration in place rather than duplicating it.
- For the config-file clients (Antigravity, OpenCode), the installer rewrites its own
  entries in the JSON, leaving any other servers you have configured untouched.

## Manual install

If you'd rather not use the script, the equivalent steps are:

```bash
# Python servers
uv venv --python 3.11 ~/.mesa/.venv
uv pip install --python ~/.mesa/.venv/bin/python -e ./mesa-ducklake -e ./mesa-mcp

# Go servers
( cd irods-mcp-server && make build )                     # -> bin/irods-mcp-server
( cd formation-mcp && go build -o formation-mcp ./cmd/formation-mcp )
mkdir -p ~/.mesa/bin
cp irods-mcp-server/bin/irods-mcp-server ~/.mesa/bin/
cp formation-mcp/formation-mcp ~/.mesa/bin/
```

Then register the servers with your client:

=== "Claude Code"

    ```bash
    claude mcp add mesa-mcp  -s user -- ~/.mesa/.venv/bin/mesa-mcp --transport stdio
    claude mcp add irods     -s user -- ~/.mesa/bin/irods-mcp-server -c .../config-stdio.yaml
    claude mcp add formation -s user -- ~/.mesa/bin/formation-mcp --transport stdio
    ```

=== "Codex"

    ```bash
    codex mcp add mesa-mcp  -- ~/.mesa/.venv/bin/mesa-mcp --transport stdio
    codex mcp add irods     -- ~/.mesa/bin/irods-mcp-server -c .../config-stdio.yaml
    codex mcp add formation -- ~/.mesa/bin/formation-mcp --transport stdio
    ```

=== "Antigravity"

    Write the servers into `$HOME/.gemini/config/mcp_config.json` — absolute paths
    required. See [the registration MESA creates](antigravity.md#the-registration-mesa-creates).

=== "OpenCode"

    Add the servers to `~/.config/opencode/opencode.json` (respecting
    `$XDG_CONFIG_HOME`) under the `mcp` key. See
    [the registration MESA creates](opencode.md#the-registration-mesa-creates).
