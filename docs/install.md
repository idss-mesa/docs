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
| `--no-go` | skip the Go servers; install only `mesa-mcp` (no Go toolchain needed) |
| `--uninstall` | remove the three servers from Claude Code and delete the install dir |
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
| `MESA_MCP_REF` | `feat/datacite-support` | branch/tag for `mesa-mcp` (the DataCite tools live here until merged to `main`) |
| `MCP_SCOPE` | `user` | Claude Code scope: `user`, `project`, or `local` |
| `CYVERSE_USERNAME` / `CYVERSE_PASSWORD` | — | applied to `mesa-mcp` and `formation` |
| any `MESA_MCP_*` / `FORMATION_*` | — | passed through verbatim to the matching server |

## What it lays down

```
~/.mesa/
├── repos/
│   ├── mesa-mcp/            # editable Python source (branch: feat/datacite-support)
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
- Each `claude mcp add` is preceded by a `claude mcp remove`, so re-running updates the
  registration in place rather than duplicating it.

## Manual install

If you'd rather not use the script, the equivalent steps are:

```bash
# Python servers
uv venv --python 3.11 ~/.mesa/.venv
uv pip install --python ~/.mesa/.venv/bin/python -e ./mesa-ducklake -e ./mesa-mcp

# Go servers
( cd irods-mcp-server && make build )                     # -> bin/irods-mcp-server
( cd formation-mcp && go build -o formation-mcp ./cmd/formation-mcp )

# Register with Claude Code (user scope, stdio)
claude mcp add mesa-mcp  -s user -- ~/.mesa/.venv/bin/mesa-mcp --transport stdio
claude mcp add irods     -s user -- ~/.mesa/bin/irods-mcp-server -c .../config-stdio.yaml
claude mcp add formation -s user -- ~/.mesa/bin/formation-mcp --transport stdio
```
