# Directory Update Log

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
