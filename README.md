# MESA

**One-line install of the CyVerse MESA MCP stack for [Claude Code](https://docs.claude.com/en/docs/claude-code/overview).**

```bash
curl -fsSL https://raw.githubusercontent.com/idss-mesa/mesa/main/install.sh | bash
```

Runs on **Linux, macOS, and Windows Subsystem for Linux (WSL)**. Anonymous public CyVerse
access works out of the box — no credentials needed to start.

📖 **Docs:** <https://idss-mesa.github.io/mesa/>

## What it installs

One installer clones, builds, and registers four CyVerse repos as local **stdio** MCP
servers in Claude Code:

| Server | Lang | Role |
|---|---|---|
| [`mesa-mcp`](https://github.com/idss-mesa/mesa-mcp) | Python | iRODS Data Store (`ds_*`) + OBO/OLS ontology AVUs + DataCite + DuckLake history |
| [`mesa-ducklake`](https://github.com/idss-mesa/mesa-ducklake) | Python | AVU metadata-history library backing `mesa-mcp` (installed with it, not a standalone server) |
| [`irods-mcp-server`](https://github.com/idss-mesa/irods-mcp-server) | Go | reference iRODS Data Store server |
| [`formation-mcp`](https://github.com/idss-mesa/formation-mcp) | Go | CyVerse Discovery Environment — launch apps, manage analyses |

After install, `claude mcp list` shows `mesa-mcp`, `irods`, and `formation`. Ask Claude Code
to *"ping the CyVerse Data Store"* to confirm.

## Requirements

- [Claude Code](https://docs.claude.com/en/docs/claude-code/overview) (`claude` on `PATH`) — the installer refuses to run without it
- `git`, `curl`
- `uv` — auto-installed if missing
- Go ≥ 1.25 — only for the two Go servers; pass `--no-go` to skip them

## Common usage

```bash
# authenticated install
CYVERSE_USERNAME=you CYVERSE_PASSWORD='••••' bash install.sh

# Python-only (no Go toolchain)
bash install.sh --no-go

# custom location
bash install.sh --prefix ~/tools/mesa

# remove everything
bash install.sh --uninstall
```

See the [install reference](https://idss-mesa.github.io/mesa/install/) for all flags and
environment variables, and [credentials](https://idss-mesa.github.io/mesa/credentials/) for
authenticating.

## Repository layout

```
mesa/
├── install.sh                 # the one-liner
├── zensical.toml              # docs site config (Zensical)
├── docs/                      # documentation source
└── .github/workflows/docs.yml # builds + deploys the docs to GitHub Pages
```

## Building the docs locally

The site is built with [Zensical](https://zensical.org), the next-gen static site generator
from the Material for MkDocs team.

```bash
uv tool run zensical serve -o     # live preview at http://localhost:8000
uv tool run zensical build        # static output in ./site
```

## License

BSD 3-Clause — see [LICENSE](LICENSE).
