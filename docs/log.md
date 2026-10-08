# Directory Update Log

## 2026-10-08

* **Update**: Rewrote [Formation](servers/formation-mcp.md) (formerly formation-mcp) for
  CyVerse's hosted Formation MCP server at <https://de.cyverse.org/formation/mcp>: per-client
  setup (claude.ai and Claude Desktop, Claude Code, Codex, OpenCode, Antigravity), browser
  sign-in with a CyVerse account, the 12 tools and their limits, and how to move off the
  local `formation-mcp`. CyVerse has since removed the REST API that server called
  (Formation source change of 2026-06-11, first released in Formation v2026.07.07), so it no
  longer works.
* **Creation**: Added [claude.ai and Claude Desktop](claude-ai.md), adding Formation as a
  custom connector (Free, Pro and Max; Team and Enterprise owners and members), the optional
  public Data Store connector, using it in chats and in Claude Code.
* **Update**: `install.sh` keeps the permissions of the client configs it rewrites (a new
  one is created readable by you only) and writes through a symlinked config; leaves an
  identical Claude Code `formation` entry alone so a re-run keeps the sign-in; skips
  `formation` for Codex older than 0.77; signs Codex and OpenCode out of Formation on
  `--uninstall`; and its summary matches `--no-go` and `CODEX_HOME`. The pages now note
  that Codex's `--no-browser` needs 0.156, Codex's default tool timeout by version, that
  `codex mcp add` sets no timeout, that Codex, OpenCode, and Antigravity sign-in to
  Formation is not yet confirmed by CyVerse, and that OpenCode and Goose cannot sign in
  inside the MESA apps. The authenticated-install one-liner in [Quickstart](quickstart.md)
  and [Credentials](credentials.md) now passes the credentials to `bash`, not `curl`.
* **Update**: `install.sh` now registers `formation` by URL with every client (Claude Code
  `--transport http`, Codex `url` with `tool_timeout_sec = 600`, OpenCode `remote`,
  Antigravity `serverUrl`) instead of building `formation-mcp`, even with `--no-go`; a re-run
  replaces the old local entry and deletes `~/.mesa/bin/formation-mcp`. New override
  `MESA_FORMATION_URL`. [Install reference](install.md), [Quickstart](quickstart.md) (new
  "Sign in to Formation" step), [Credentials](credentials.md), the four client pages,
  [Troubleshooting](troubleshooting.md), the [home page](index.md), and `README.md` match.
* **Update**: [Claude Code](claude-code.md) has a new "Hosted servers and connectors"
  section; its hosted iRODS commands now match the MESA app images (public
  `mcp-public.cyverse.ai`, authenticated `mcp.cyverse.ai` with the `mcp-client` OAuth client).
* **Update**: [AI agents in the MESA apps](apps/agents.md) no longer says `cyverse-login`
  signs agents in to Formation; it adds a "Sign in to Formation" step for each agent, and the
  five app pages point to it.
* **Creation**: Added the [MESA Portal](portal/index.md) section, end-user guides for
  <https://mesa.cyverse.org>: [Overview](portal/overview.md) (signing in, navigation,
  dashboard, themes), [Managing data](portal/data.md) (Data Browser views, upload, move,
  trash, sharing, AVU metadata, search), [Starting applications](portal/applications.md)
  (catalog sections, filters, Instant Launch, Launch with Options, CPU or GPU builds), and
  [Managing analyses](portal/analyses.md) (statuses, Open App, Extend Time, Monitor, Save &
  Exit, Terminate, results). Adapted from the portal's own user guides, with 21
  screenshots in `assets/portal/` rendered from the portal's sample data.
* **Creation**: Added the [Featured apps](apps/index.md) section with a page for each MESA
  VICE app — [MESA CLI (Cloud Shell)](apps/cli.md), [MESA JupyterLab](apps/jupyterlab.md),
  [MESA RStudio Geospatial](apps/rstudio.md), [MESA VS Code](apps/vscode.md), and
  [MESA KASM Ubuntu Desktop](apps/kasm.md) — and [AI agents in the MESA apps](apps/agents.md)
  for the agent CLIs, `cyverse-login`, AI Verde, and local Ollama models they share.
* **Update**: The [home page](index.md), the site description, and [llms.txt](llms.txt)
  now cover the portal and the featured apps alongside the MCP stack;
  [For AI agents](about/ai-agents.md) points to the new sections.

## 2026-09-12

* **Update**: Made the Markdown easier for agents to find, following
  [DUST 2026](https://unm-carc.github.io/dust-2026/about/ai-agents/). Every rendered page
  now carries two *visible* pointers, because text-extracting fetchers and URL allowlists
  never see `<head>`: a "View this page as Markdown" button beside Edit and View source,
  and a "Machine-readable versions" line at the end of the article linking the Markdown
  twin, the raw GitHub source, `llms.txt`, and `llms-full.txt`. The site footer carries the
  same three links on every page.
* **Update**: [llms.txt](llms.txt) now lists three addresses per page — rendered page,
  Markdown twin, and raw source on `raw.githubusercontent.com` — because sandboxed agents
  often reach github.com when they cannot reach `*.github.io`, and its Meta section states
  the corpus size and token estimate. [llms-full.txt](llms-full.txt) and the per-page
  Markdown mirror now rewrite relative links to absolute URLs, so links survive being read
  away from their source directory.
* **Update**: [For AI agents](about/ai-agents.md) documents the raw-source convention, adds
  an "If you cannot fetch this site" section, and warns that the `<head>` signals are
  invisible to most fetch tools. The [home page](index.md) lists the same addresses.
* **Update**: The three scripts now share `scripts/okf_common.py` (config, frontmatter,
  URL, and link-rewriting helpers, ported from UNM-CARC/dust-2026) and read `site_url`,
  `repo_url`, `edit_uri`, and `nav` from `zensical.toml` instead of hard-coding them.

## 2026-09-10

* **Update**: Migrated the bundle to [Open Knowledge Format v0.2](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md).
  Every content page replaces v0.1's `timestamp` with `generated: { by, at }` and gains
  `sources` (the MESA repositories and `install.sh`, and each client vendor's MCP
  documentation), `status`, and `stale_after`. The root [index](index.md) now declares
  `okf_version: "0.2"`.
* **Creation**: Added the [About](about/index.md) section with [For AI agents](about/ai-agents.md) —
  how agents should consume this site and why they should call the MESA servers for data —
  and a [Servers](servers/index.md) section listing.
* **Update**: Replaced `scripts/agent_markdown.py` with the UNM-CARC/neon-mcp agent surface:
  `scripts/okf_validate.py` (CI-enforced conformance), `scripts/gen_llms_txt.py` (committed
  `llms.txt` and `llms-full.txt` grouped by the site nav, CI drift-checked), and
  `scripts/postbuild_agent_surface.py` (page URL + `index.md` Markdown mirror alongside the
  legacy `<path>.md` copies, `okf:*` head metadata, and `robots.txt`). Added `AGENTS.md` and
  `CLAUDE.md` for coding agents.

## 2026-07-19

* **Update**: Changed the copyright holder to The Regents of the University of New
  Mexico (site footer, `LICENSE`, and README).

## 2026-07-18

* **Update**: Generalized MESA from a Claude-Code-only installer to four agent clients — added
  [Codex CLI](codex.md), [Antigravity](antigravity.md), and [OpenCode](opencode.md) integration
  pages alongside [Claude Code](claude-code.md), documented the new `--for` installer flag and
  client auto-detection, and added per-client tabs to the [Quickstart](quickstart.md) and
  [Install reference](install.md).
* **Update**: Adopted the [Open Knowledge Format v0.1](https://github.com/GoogleCloudPlatform/knowledge-catalog)
  across `docs/` — frontmatter (`type`, `title`, `description`, `tags`, `timestamp`) on every
  content page, plus this update log. [index.md](index.md) intentionally deviates from the
  reserved-index rule because Zensical requires it as the site homepage.

## 2026-06-18

* **Update**: Defaulted `mesa-mcp` to `main` now that the DataCite tools are merged
  ([bba04fd](https://github.com/idss-mesa/docs/commit/bba04fd)).
* **Creation**: Initial MESA umbrella repo — one-liner `install.sh` plus Zensical docs
  ([27360b8](https://github.com/idss-mesa/docs/commit/27360b8)).
