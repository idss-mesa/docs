# formation-mcp

**Repo:** [idss-mesa/formation-mcp](https://github.com/idss-mesa/formation-mcp) · **Language:** Go · **Registered as:** `formation`

Connects Claude Code to the **CyVerse Discovery Environment** through the
[Formation API](https://github.com/cyverse-de/formation). It lets you launch scientific
apps, monitor analyses, and work with Data Store files in natural language.

## How MESA runs it

```bash
( cd ~/.mesa/repos/formation-mcp && go build -o formation-mcp ./cmd/formation-mcp )
claude mcp add formation -s user -- ~/.mesa/bin/formation-mcp --transport stdio
```

Go ≥ 1.25 required. Prebuilt binaries for Linux/macOS/Windows are also published on the
repo's [GitHub Releases](https://github.com/idss-mesa/formation-mcp/releases) (built with
GoReleaser) if you'd prefer to download rather than build.

## What you can do

- **list / launch apps** and wait for completion
- **monitor and stop analyses**
- **browse, upload, and set metadata** on Data Store files
- open results in the browser

## Authentication

`formation-mcp` needs CyVerse credentials to launch anything as you. Provide them via env
vars (`FORMATION_USERNAME` / `FORMATION_PASSWORD` or `FORMATION_TOKEN`) or a
`~/.formation-mcp.yaml` file — see [Credentials](../credentials.md#formation-discovery-environment-auth).
Configuration precedence is **CLI flag > env var > config file**.

The server also supports an **SSE** transport for remote/web clients (Claude.ai) behind
nginx + TLS; the repo README has the full deployment guide.
