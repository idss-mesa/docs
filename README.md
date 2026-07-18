# MESA

**One-line install of the CyVerse MESA MCP stack for [Claude Code](https://docs.claude.com/en/docs/claude-code/overview), [Codex CLI](https://developers.openai.com/codex/cli/), [Google Antigravity](https://antigravity.google/), and [OpenCode](https://opencode.ai).**

```bash
curl -fsSL https://raw.githubusercontent.com/idss-mesa/mesa/main/install.sh | bash
```

Runs on **Linux, macOS, and Windows Subsystem for Linux (WSL)**. Anonymous public CyVerse
access works out of the box — no credentials needed to start.

📖 **Docs:** <https://idss-mesa.github.io/mesa/>

## What it installs

One installer clones and builds four CyVerse repos, then registers three of them as
local **stdio** MCP servers in every supported agent client it detects — Claude Code,
Codex CLI, Antigravity, and OpenCode. Restrict targets with
`--for claude,codex,antigravity,opencode`:

| Server | Lang | Role |
|---|---|---|
| [`mesa-mcp`](https://github.com/idss-mesa/mesa-mcp) | Python | iRODS Data Store (`ds_*`) + OBO/OLS ontology AVUs + DataCite + DuckLake history |
| [`mesa-ducklake`](https://github.com/idss-mesa/mesa-ducklake) | Python | AVU metadata-history library backing `mesa-mcp` (installed with it, not a standalone server) |
| [`irods-mcp-server`](https://github.com/idss-mesa/irods-mcp-server) | Go | reference iRODS Data Store server |
| [`formation-mcp`](https://github.com/idss-mesa/formation-mcp) | Go | CyVerse Discovery Environment — launch apps, manage analyses |

After install, `mesa-mcp`, `irods`, and `formation` are registered with each detected
client — verify with `claude mcp list` / `codex mcp list` / `opencode mcp list`, or
Antigravity's **Manage MCP Servers** panel. Ask your agent to *"ping the CyVerse Data
Store"* to confirm.

## Requirements

- at least one supported agent client — [Claude Code](https://docs.claude.com/en/docs/claude-code/overview), [Codex CLI](https://developers.openai.com/codex/cli/), [Antigravity](https://antigravity.google/), or [OpenCode](https://opencode.ai) — the installer refuses to run if none is found
- `git`, `curl`
- `uv` — auto-installed if missing
- Go ≥ 1.25 — only for the two Go servers; pass `--no-go` to skip them

## Common usage

```bash
# authenticated install
CYVERSE_USERNAME=you CYVERSE_PASSWORD='••••' bash install.sh

# Python-only (no Go toolchain)
bash install.sh --no-go

# register with specific clients only
bash install.sh --for claude,codex

# custom location
bash install.sh --prefix ~/tools/mesa

# remove everything (from all detected clients)
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

### Docs conventions

The pages under `docs/` follow the
[Open Knowledge Format v0.1](https://github.com/GoogleCloudPlatform/knowledge-catalog)
(OKF): every content page carries YAML frontmatter (`type`, `title`, `description`,
`tags`, `timestamp`), and `docs/log.md` is the OKF update log. One deliberate deviation:
`docs/index.md` keeps frontmatter and rich content instead of OKF's reserved
frontmatter-free link listing, because Zensical requires `index.md` as the site homepage.

## License

BSD 3-Clause — see [LICENSE](LICENSE).
