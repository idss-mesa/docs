# Directory Update Log

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
