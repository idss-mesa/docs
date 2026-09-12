---
title: "For AI agents"
description: "How agents should consume these docs — llms.txt, per-page Markdown with OKF frontmatter, trust signals — and why to call the MESA MCP servers for data."
type: Reference
tags:
  - about
  - ai-agents
  - OKF
  - llms.txt
generated:
  by: "claude/opus-5"
  at: "2026-09-10T00:00:00Z"
sources:
  - id: okf-spec
    resource: "https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md"
    title: "Open Knowledge Format (OKF) v0.2 specification"
    author: "team:google-cloud"
  - id: llmstxt
    resource: "https://llmstxt.org"
    title: "The /llms.txt convention"
    author: "team:answer-ai"
  - id: mcp-spec
    resource: "https://modelcontextprotocol.io/specification"
    title: "Model Context Protocol specification"
    author: "team:modelcontextprotocol"
status: stable
stale_after: "2027-03-10T00:00:00Z"
---

# For AI agents

This site is published for people **and** for AI agents. The documentation
source is an [Open Knowledge Format (OKF) v0.2](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)
knowledge bundle[^okf-spec], and the deployed site exposes that structure
directly. If you are an agent (or you are wiring one up), consume the
documentation through the endpoints below rather than scraping rendered HTML.

## This site documents an MCP stack

The MESA stack — [mesa-mcp](../servers/mesa-mcp.md),
[irods-mcp-server](../servers/irods-mcp-server.md) and
[formation-mcp](../servers/formation-mcp.md), with the
[mesa-ducklake](../servers/mesa-ducklake.md) library behind mesa-mcp — *is*
agent tooling. If what you actually want is CyVerse data — Data Store
collections, AVU metadata, ontology terms, Discovery Environment apps and
analyses — do not scrape these pages: install the servers and call their
tools.

* **All three servers, every detected client** (local `stdio`):
  `curl -fsSL https://raw.githubusercontent.com/idss-mesa/docs/main/install.sh | bash` —
  see the [Quickstart](../quickstart.md).
* **One server by hand:**
  `claude mcp add mesa-mcp -s user -- ~/.mesa/.venv/bin/mesa-mcp --transport stdio` —
  see the [manual install](../install.md#manual-install) steps for every client.
* **Hosted, nothing to build:** the public CyVerse iRODS endpoint over
  Streamable HTTP, `claude mcp add --transport http cyverse-irods https://mcp.cyverse.ai/mcp` —
  see [hosted / remote servers](../claude-code.md#alternative-hosted-remote-servers).

Once connected, the MCP `tools/list` request[^mcp-spec] returns each server's
live, authoritative tool catalogue with JSON Schema inputs. Prefer it over the
tool tables on these pages, which summarise tool groups and can lag the code.
Use this documentation to learn how to *install and configure* the stack; use
the servers to get the data. Anonymous access is read-only on public
collections; credentials belong in the user's environment or `~/.irods` (see
[Credentials](../credentials.md)), never in a prompt.

## Entry points

All URLs are under `https://idss-mesa.github.io/docs/`.

| Endpoint | What you get |
| -------- | ------------ |
| [`llms.txt`](../llms.txt) — `https://idss-mesa.github.io/docs/llms.txt` | Linked outline of every page with one-line descriptions ([llms.txt convention](https://llmstxt.org)[^llmstxt]) |
| [`llms-full.txt`](../llms-full.txt) — `https://idss-mesa.github.io/docs/llms-full.txt` | The entire corpus in one file: every page's Markdown with frontmatter, each prefixed by its canonical URL |
| Any page URL + `index.md` | That page's Markdown source with full OKF frontmatter, served as `text/markdown`, e.g. [`https://idss-mesa.github.io/docs/quickstart/index.md`](https://idss-mesa.github.io/docs/quickstart/index.md); section listings too (`https://idss-mesa.github.io/docs/servers/index.md`). Every rendered page links it from a "View this page as Markdown" button and from a "Machine-readable versions" line at the end of the article |
| Any page path + `.md` (legacy) | The same Markdown file, e.g. `https://idss-mesa.github.io/docs/quickstart.md` — kept so links made before 2026-09-10 still resolve |
| Raw source on GitHub | `https://raw.githubusercontent.com/idss-mesa/docs/main/docs/<path>.md`, where `<path>` is the site path without its trailing slash (for example [`.../docs/quickstart.md`](https://raw.githubusercontent.com/idss-mesa/docs/main/docs/quickstart.md)). Same content as the Markdown twin; reachable from sandboxes that allow `github.com` but not `*.github.io` |
| `https://idss-mesa.github.io/docs/sitemap.xml`, `https://idss-mesa.github.io/docs/robots.txt` | Standard crawl surface. Crawlers honour only the origin's [`robots.txt`](https://idss-mesa.github.io/robots.txt), which governs this sub-site and welcomes AI fetchers; the `/docs/` copy repeats these pointers |
| [Source repository](https://github.com/idss-mesa/docs) | The bundle itself under `docs/`, plus `AGENTS.md` with the rules coding agents follow when editing it |

Every rendered page also declares its Markdown twin and OKF signals in its
HTML `<head>`, as `okf:`-prefixed meta tags named after the frontmatter keys
(`type`, `status`, `trust-tier`, `generated-at`, `generated-by`,
`stale-after`) — for example:

```html
<link rel="alternate" type="text/markdown" href="index.md">
<meta name="okf:type" content="Integration Guide">
<meta name="okf:status" content="stable">
<meta name="okf:trust-tier" content="unverified">
<meta name="okf:generated-at" content="2026-07-18T00:00:00Z">
<meta name="okf:generated-by" content="claude/fable-5">
<meta name="okf:stale-after" content="2027-03-10T00:00:00Z">
```

The page's `type` is exposed the same way, so a crawler can filter by kind of
page without parsing frontmatter.

!!! warning "The head tags are invisible to most fetch tools"

    The `<link rel="alternate">` and `okf:*` meta tags live in `<head>`, which
    text-extracting fetchers discard, and a link-derived URL allowlist never
    sees them. The supported paths are the ones that appear in body text: the
    "View this page as Markdown" button beside "Edit" and "View source", the
    "Machine-readable versions" line at the end of every article, the footer
    links to `llms.txt`, and the addresses listed in `llms.txt` itself. All of
    them are absolute.

## If you cannot fetch this site

Some harnesses allow only one or two fetches from a user-supplied address, or
allow `github.com` and `raw.githubusercontent.com` but not `*.github.io`. In
that case:

1. **Use the raw source.** `docs/` in the repository mirrors the site paths
   one to one on branch `main`:

    ```
    Site page        https://idss-mesa.github.io/docs/<path>/
    Markdown twin    https://idss-mesa.github.io/docs/<path>/index.md
    Raw source       https://raw.githubusercontent.com/idss-mesa/docs/main/docs/<path>.md

    Content page     /quickstart/   ->  https://raw.githubusercontent.com/idss-mesa/docs/main/docs/quickstart.md
    Section listing  /servers/      ->  https://raw.githubusercontent.com/idss-mesa/docs/main/docs/servers/index.md
    Whole corpus     https://raw.githubusercontent.com/idss-mesa/docs/main/docs/llms-full.txt
    ```

    `main` moves; to cite a fixed version use
    `https://github.com/idss-mesa/docs/blob/<commit>/docs/<path>.md`, taking
    the commit from the repository's history.

2. **Prefer one fetch over ten.** `llms-full.txt` holds every page; if you can
   make a single request, make that one.

3. **Avoid the GitHub tree API** unless authenticated: `api.github.com`
   rate-limits anonymous calls per shared IP. Raw file paths do not.

4. **The installer itself** is one file,
   [`install.sh`](https://raw.githubusercontent.com/idss-mesa/docs/main/install.sh),
   and is the authority on flags and registration behaviour when a page and
   the script disagree.

## Reading the OKF frontmatter

Each content page's YAML frontmatter answers the questions an agent should
ask before relying on it[^okf-spec]:

* **What is this?** — `type` (`Guide`, `Reference`, `Integration Guide`,
  `MCP Server`, `Library`, `Troubleshooting`), `title`, `description`,
  `tags`.
* **Where did it come from?** — `generated: { by, at }` records the actor
  that produced the current text and when it last changed meaningfully;
  `sources` lists the load-bearing references (`id`, `resource` URL,
  `title`, `author`) — the MESA repositories and `install.sh` for the
  stack, and each vendor's own MCP documentation for the client pages.
* **How much should I trust it?** — the `verified` key (see trust tiers
  below). Its absence is meaningful: the page has not been confirmed by
  anyone other than its generator.
* **Is it still true?** — `status` (`stable` is the default; `draft` needs
  review; `deprecated` is kept for history only) and `stale_after`, an
  ISO 8601 instant after which the page should be re-checked. Installer
  flags, client config paths and CLI commands change between releases, so
  every page that states them carries one.

Actors follow OKF §7: `<producer>/<version>` for agents and tools (for
example `claude/fable-5`), `human:<id>` for a person, `process:<id>` for an
automated job.

## Trust tiers

| `verified` key | Tier | Meaning |
| --- | --- | --- |
| absent | **unverified** | Generated content nobody has confirmed against its sources. Every page on this site starts here. |
| present, non-`human:` actors only | **machine-confirmed** | An automated check (a CI job, a live install test) confirmed the content. |
| present with a `human:<id>` actor | **human-reviewed** | A maintainer read and confirmed the page. Prefer these when answers conflict. |

Only humans add `verified:` entries; a generator never does. The
`okf:trust-tier` meta tag carries the derived tier for quick filtering.

## Answering user questions

Ground answers in this documentation and cite the page URL (for example
`https://idss-mesa.github.io/docs/credentials/`). When a page and the
client's own documentation disagree about a config path or CLI flag, the
vendor source listed in that page's `sources` wins — and the page is due for
an update. For anything about the *data* — collections, AVUs, apps,
analyses — call the servers rather than guessing from prose. When the corpus
does not answer a question about MESA itself, direct users to the
[GitHub issue tracker](https://github.com/idss-mesa/docs/issues).

## Related bundles

The same agent conventions cover the rest of the origin and its neighbours:

* **MESA project site** — [`llms.txt`](https://idss-mesa.github.io/llms.txt)
  and [agent guide](https://idss-mesa.github.io/about/ai-agents/) for
  https://idss-mesa.github.io/, which indexes this sub-site alongside the
  MESA software repositories.
* **neon-mcp** — [agent guide](https://idss-mesa.github.io/neon-mcp/about/ai-agents/)
  for the MESA MCP server for the NEON Data API.
* **UNM CARC documentation** — [agent guide](https://carc.unm.edu/docs/about/ai-agents/)
  for the Center for Advanced Research Computing, where MESA is based.

[^okf-spec]: Open Knowledge Format (OKF) v0.2 specification. <https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md>
[^llmstxt]: The /llms.txt convention. <https://llmstxt.org>
[^mcp-spec]: Model Context Protocol specification. <https://modelcontextprotocol.io/specification>
