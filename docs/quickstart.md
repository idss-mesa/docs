# Quickstart

## 1. Prerequisites

The installer checks for these and helps you install the missing ones:

| Tool | Needed for | Notes |
|---|---|---|
| `git`, `curl` | cloning + downloading | usually preinstalled |
| `claude` | the integration target | install [Claude Code](https://docs.claude.com/en/docs/claude-code/overview) first — the installer refuses to run without it |
| `uv` | Python servers | auto-installed from [astral.sh/uv](https://docs.astral.sh/uv/) if missing |
| Go ≥ 1.25 | the two Go servers | only needed for `irods` + `formation`; pass `--no-go` to skip them |

!!! tip "Windows users"
    Run everything inside **WSL** (Ubuntu or similar). The installer detects WSL and
    treats it as Linux. Native PowerShell / `cmd` are not supported.

## 2. Install

```bash
curl -fsSL https://raw.githubusercontent.com/idss-mesa/mesa/main/install.sh | bash
```

This will:

1. Detect your platform (Linux / macOS / WSL).
2. Clone the four repos from `idss-mesa` into `~/.mesa/repos/`.
3. Create a Python venv at `~/.mesa/.venv` and install `mesa-ducklake` + `mesa-mcp`.
4. Build the Go servers into `~/.mesa/bin/`.
5. Register `mesa-mcp`, `irods`, and `formation` with Claude Code at **user scope**.

## 3. Verify

```bash
claude mcp list
```

You should see `mesa-mcp`, `irods`, and `formation` reported as **connected**. Then, in a
Claude Code session, try:

> *Ping the CyVerse Data Store and list what's in the shared directory.*

That exercises `mesa-mcp`'s `ds_ping` and `ds_list_directory` tools against the public
`data.cyverse.org` zone — no login needed.

## 4. (Optional) Authenticate

Anonymous access is read-only on public collections. To act as yourself, re-run with your
[CyVerse](https://cyverse.org) credentials:

```bash
CYVERSE_USERNAME=you CYVERSE_PASSWORD='••••••' \
  curl -fsSL https://raw.githubusercontent.com/idss-mesa/mesa/main/install.sh | bash
```

See [Credentials](credentials.md) for all the options (env vars, `~/.irods`, per-server config).

## Updating & uninstalling

Re-running the one-liner pulls the latest code and rebuilds — it is safe to run again.

```bash
# clone the repo first, or use your existing ~/.mesa checkout
~/.mesa/repos/.. # (the installer is also fetched fresh each run via curl)
curl -fsSL https://raw.githubusercontent.com/idss-mesa/mesa/main/install.sh | bash -s -- --uninstall
```
