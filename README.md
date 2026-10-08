# MESA

**One-line install of the CyVerse MESA MCP stack for [Claude Code](https://docs.claude.com/en/docs/claude-code/overview), [Codex CLI](https://developers.openai.com/codex/cli/), [Google Antigravity](https://antigravity.google/), and [OpenCode](https://opencode.ai).**

```bash
curl -fsSL https://raw.githubusercontent.com/idss-mesa/docs/main/install.sh | bash
```

Runs on **Linux, macOS, and Windows Subsystem for Linux (WSL)**. Anonymous public CyVerse
access works out of the box — no credentials needed to start.

📖 **Docs:** <https://idss-mesa.github.io/docs/>

Prefer a browser? The **MESA Portal** at <https://mesa.cyverse.org> manages your CyVerse
data, apps, and analyses, and launches the MESA featured apps (JupyterLab, RStudio,
VS Code, a terminal, and a Linux desktop) with the same MCP servers already registered —
see the [portal guide](https://idss-mesa.github.io/docs/portal/) and the
[featured apps](https://idss-mesa.github.io/docs/apps/).

## What it installs

One installer clones and builds four CyVerse repos, then registers three of them as
local **stdio** MCP servers in every supported agent client it detects — Claude Code,
Codex CLI, Antigravity, and OpenCode. Restrict targets with
`--for claude,codex,antigravity,opencode`:

| Server | Lang | Role |
|---|---|---|
| [`mesa-mcp`](https://github.com/idss-mesa/mesa-mcp) | Python | iRODS Data Store (`ds_*`) + OBO/OLS ontology AVUs + DataCite + DuckLake history |
| [`mesa-ducklake`](https://github.com/idss-mesa/mesa-ducklake) | Python | AVU metadata-history library backing `mesa-mcp` (installed with it, not a standalone server) |
| [`mesa-anyjev`](https://github.com/idss-mesa/mesa-anyjev) | Python | Calibrated ontology/schema decisions; a plugin that adds the `mesa_decide_*` tools to `mesa-mcp` (installed with it) |
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

See the [install reference](https://idss-mesa.github.io/docs/install/) for all flags and
environment variables, and [credentials](https://idss-mesa.github.io/docs/credentials/) for
authenticating.

## Repository layout

```
docs/
├── install.sh                 # the one-liner
├── zensical.toml              # docs site config (Zensical)
├── docs/                      # documentation source (an OKF v0.2 bundle)
├── scripts/                   # OKF validator, llms.txt generator, post-build agent surface
├── AGENTS.md                  # rules for AI coding agents editing this repo
└── .github/workflows/docs.yml # validates, builds, and deploys the docs to GitHub Pages
```

## Building the docs locally

The site is built with [Zensical](https://zensical.org), the next-gen static site generator
from the Material for MkDocs team.

```bash
uv tool run zensical serve -o     # live preview at http://localhost:8000
uv tool run zensical build        # static output in ./site
```

### Docs conventions

The pages under `docs/` form an
[Open Knowledge Format v0.2](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)
(OKF) bundle: every content page carries YAML frontmatter (`type`, `title`,
`description`, `tags`, provenance in `generated` and `sources`, lifecycle in `status`
and `stale_after`), section `index.md` files are frontmatter-free listings, and
`docs/log.md` is the OKF update log. One deliberate deviation: `docs/index.md` carries
`okf_version` plus `title`, `description`, and `icon`, and keeps rich content instead of a
plain link listing, because Zensical requires `index.md` as the site homepage. The full
rules, for people and coding agents alike, are in [AGENTS.md](AGENTS.md).

```bash
uvx --with pyyaml python scripts/okf_validate.py docs   # OKF conformance (CI-enforced)
uvx --with pyyaml python scripts/gen_llms_txt.py        # regenerate docs/llms.txt + llms-full.txt (CI checks drift)
```

The deployed site is agent-readable: every page's Markdown is served at its URL plus
`index.md`, and `llms.txt`, `llms-full.txt`, and the
[For AI agents](https://idss-mesa.github.io/docs/about/ai-agents/) guide sit alongside it.

## License

BSD 3-Clause, © 2026 The Regents of the University of New Mexico — see
[LICENSE](LICENSE).
