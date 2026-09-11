# Agent guide — MESA documentation

This repository holds the MESA umbrella installer (`install.sh`, the
one-liner that clones, builds, and registers the CyVerse MESA MCP stack in
Claude Code, Codex CLI, Antigravity, and OpenCode) and its documentation
site, https://idss-mesa.github.io/docs/, built with
[Zensical](https://zensical.org) from `docs/`. The `docs/` tree is an
**Open Knowledge Format (OKF) v0.2 knowledge bundle**
([spec](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)):
every content page carries YAML frontmatter with `type` (Guide | Reference |
Integration Guide | MCP Server | Library | Troubleshooting), `title`,
`description`, `tags`, provenance (`generated`, `sources`) and lifecycle
(`status`, `stale_after`) fields. Section `index.md` files are OKF §8
directory listings (no frontmatter); `docs/log.md` is the OKF §9 dated
change log.

## Reading the corpus

- `docs/llms.txt` — linked outline of every page with descriptions.
- `docs/llms-full.txt` — the entire corpus in one file, frontmatter included.
- Live site: any page URL + `index.md` returns that page's Markdown source
  (e.g. https://idss-mesa.github.io/docs/quickstart/index.md); the legacy
  `<path>.md` form (https://idss-mesa.github.io/docs/quickstart.md) still
  works. `robots.txt`, `sitemap.xml`, `llms.txt` and `llms-full.txt` sit at
  the site root; the agent guide is at `/about/ai-agents/`. Crawlers honour
  only the origin robots.txt, which lives in the `idss-mesa/idss-mesa.github.io`
  repository.
- Trust: pages without a `verified:` key are **unverified** (OKF §5.3);
  `status: deprecated` pages are history, `status: draft` pages need review.
  Pages with `stale_after` state installer, client, or credential facts that
  change — re-check them after that date.
- For CyVerse *data*, do not read the docs: install the servers and call
  their tools.

## Commands

```bash
pip install zensical pyyaml                     # or prefix each command with `uvx --with pyyaml`
zensical serve                                  # live preview at localhost:8000
zensical build --clean --strict                 # static site -> site/
python scripts/okf_validate.py docs             # OKF conformance (CI-enforced; 0 errors required)
python scripts/gen_llms_txt.py                  # regenerate docs/llms.txt + docs/llms-full.txt (CI checks drift)
python scripts/postbuild_agent_surface.py site  # after build: md mirror + okf:* meta + robots.txt
```

All three scripts need only PyYAML (and Python 3.11+ for `tomllib`).

## Editing rules

1. **Every content page** under `docs/` starts with OKF frontmatter: a
   non-empty `type`, plus `title`, `description` (one plain sentence — it
   becomes the meta description and the `llms.txt` entry), `tags`,
   `generated: { by, at }` and `sources` (each with `id`, `resource`,
   `title`, `author`), `status`, and `stale_after` when the page states facts
   that may change. Run `okf_validate.py` before committing — CI fails
   otherwise.
2. **`index.md` files carry no frontmatter.** A section index is a
   `# Heading` followed by `* [Title](page.md) - description` bullets listing
   every page in that directory. The one exception is the root
   `docs/index.md`, which carries `okf_version: "0.2"`, `title`,
   `description` and Zensical's `icon`, and keeps a rich homepage body
   because Zensical requires `index.md` as the homepage — a documented
   deviation; do not "fix" it.
3. **`docs/log.md`** gets a dated entry (`## YYYY-MM-DD`, newest first;
   `* **Creation**:` / `* **Update**:` / `* **Deprecation**:`) for every
   substantive documentation change.
4. **Regenerate after content changes:** `python scripts/gen_llms_txt.py`,
   then commit `docs/llms.txt` and `docs/llms-full.txt` with the change.
   Section grouping comes from the `nav` array in `zensical.toml`.
5. **New pages go in the `nav` array of `zensical.toml`** (and in their
   section's `index.md`, if they live in a subdirectory);
   `zensical build --strict` must still succeed.
6. **Changing `install.sh`?** Update `install.md`, `quickstart.md`, and the
   affected client pages in the same change, bump their `generated.at`, and
   push their `stale_after` out.
7. **Links:** internal links are relative and plain (`quickstart.md`,
   `../credentials.md`). Code belongs in fenced blocks with a language.
8. **Actors** (OKF §7): `generated.by` is `<producer>/<version>` for an
   agent or tool (e.g. `claude/opus-5`), `human:<id>` for a person,
   `process:<id>` for an automated job. Bump `generated.at` on a meaningful
   content change, not on typo or formatting fixes.
9. **Never add `verified:`.** Only a human maintainer does that, as
   `verified: { by: "human:<id>", at: <ISO 8601> }`.
