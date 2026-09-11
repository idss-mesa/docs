#!/usr/bin/env python3
"""Generate llms.txt and llms-full.txt from the MESA docs/ OKF bundle.

llms.txt      — linked outline of the site (llmstxt.org convention): every
                concept page with its frontmatter description, grouped by
                section, with absolute URLs derived from site_url.
llms-full.txt — the entire corpus concatenated as Markdown, frontmatter
                included, so an agent can ingest the whole bundle in one file.

Grouping and order follow the `nav` array in zensical.toml, since this site
keeps most pages at the docs/ root: top-level nav pages are listed under
TOP_LEVEL_HEADING and every nested nav section becomes its own heading.
Section index.md files (OKF §8 listings) are skipped; log.md is listed under
Meta. Pages on disk but missing from the nav are reported and listed last.

Both files are written into docs/ so the static build ships them at the site
root (https://idss-mesa.github.io/docs/llms.txt). They are committed; CI fails
when they drift from the sources (`git diff --exit-code`). Needs PyYAML and
Python 3.11+ (tomllib).

Usage: python scripts/gen_llms_txt.py      (from the repository root)
"""

from __future__ import annotations

import re
import sys
import tomllib
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
DOCS = ROOT / "docs"

# Heading for the pages that sit directly in the nav rather than in a section.
TOP_LEVEL_HEADING = "Install and configure"


def load_project() -> dict:
    return tomllib.loads((ROOT / "zensical.toml").read_text(encoding="utf-8"))["project"]


def frontmatter(path: Path):
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---"):
        return {}, text
    m = re.match(r"^---\s*\n(.*?)\n---\s*\n?", text, re.DOTALL)
    if not m:
        return {}, text
    try:
        data = yaml.safe_load(m.group(1)) or {}
    except yaml.YAMLError:
        data = {}
    return (data if isinstance(data, dict) else {}), text[m.end() :]


def page_url(base: str, rel: str) -> str:
    # use_directory_urls-style pretty URLs
    path = Path(rel)
    if path.name == "index.md":
        tail = str(path.parent) + "/" if str(path.parent) != "." else ""
    else:
        tail = str(path.with_suffix("")) + "/"
    return base + tail.replace("\\", "/")


def nav_leaves(items) -> list[str]:
    out: list[str] = []
    for item in items:
        if isinstance(item, str):
            out.append(item)
            continue
        for value in item.values():
            out.extend([value] if isinstance(value, str) else nav_leaves(value))
    return out


def nav_sections(nav) -> list[tuple[str, list[str]]]:
    """(heading, [page paths]) in nav order."""
    top: list[str] = []
    sections: list[tuple[str, list[str]]] = [(TOP_LEVEL_HEADING, top)]
    for item in nav:
        if isinstance(item, str):
            top.append(item)
            continue
        for label, value in item.items():
            if isinstance(value, str):
                top.append(value)
            else:
                sections.append((label, nav_leaves(value)))
    return sections


def is_listing(rel: str) -> bool:
    return rel == "log.md" or (rel.endswith("/index.md"))


def main():
    project = load_project()
    base = project["site_url"].rstrip("/") + "/"
    sections = nav_sections(project.get("nav", []))

    in_nav = {rel for _, pages in sections for rel in pages}
    on_disk = {
        str(p.relative_to(DOCS))
        for p in DOCS.rglob("*.md")
        if p.relative_to(DOCS).parts[0] not in ("assets", "stylesheets")
    }
    missing = sorted(rel for rel in on_disk - in_nav if not is_listing(rel))
    for rel in missing:
        print(f"warning: {rel} is not in the zensical.toml nav", file=sys.stderr)
    if missing:
        sections.append(("Other pages", missing))

    lines = [
        f"# {project['site_name']} documentation",
        "",
        f"> {project['site_description']} This documentation covers the "
        "installer, per-client registration, CyVerse credentials, the four "
        "servers, and troubleshooting. The source repository is an Open "
        "Knowledge Format (OKF v0.2) bundle: every page carries YAML "
        "frontmatter with type, provenance (generated/sources), and lifecycle "
        "(status/stale_after) fields.",
        "",
        f"Full corpus for ingestion: {base}llms-full.txt",
        "",
        "Every page's Markdown source (OKF frontmatter included) is served at "
        "its URL plus `index.md` — for example "
        f"{base}quickstart/index.md (the legacy form {base}quickstart.md also "
        f"works). Agent guide: {base}about/ai-agents/",
        "",
        "If you want CyVerse data rather than documentation, install the MESA "
        "MCP servers (or connect to a hosted endpoint) and call their tools; "
        "the agent guide explains how.",
        "",
    ]
    full = [
        f"# {project['site_name']} documentation — full corpus",
        "",
        "Each page below begins with its canonical URL followed by its "
        "original Markdown, OKF frontmatter included.",
        "",
    ]

    n = 0
    for heading, pages in sections:
        pages = [rel for rel in pages if not is_listing(rel) and (DOCS / rel).exists()]
        if not pages:
            continue
        lines += [f"## {heading}", ""]
        for rel in pages:
            path = DOCS / rel
            fm, _ = frontmatter(path)
            url = page_url(base, rel)
            title = fm.get("title") or path.stem.replace("-", " ").title()
            desc = str(fm.get("description", "")).strip()
            suffix = ""
            if fm.get("status") == "deprecated":
                suffix = " (deprecated; kept for history)"
            elif fm.get("status") == "draft":
                suffix = " (draft)"
            lines.append(f"- [{title}]({url}): {desc}{suffix}")
            full += [f"---8<--- {url}", "", path.read_text(encoding="utf-8").rstrip(), ""]
            n += 1
        lines.append("")

    lines += [
        "## Meta",
        "",
        f"- [Documentation update log]({base}log/): dated history of changes to this bundle.",
        "- [MESA project site](https://idss-mesa.github.io/llms.txt): origin-level "
        "llms.txt indexing the MESA site, this documentation, and the MESA "
        "software repositories.",
        "",
    ]
    log = DOCS / "log.md"
    if log.exists():
        full += [f"---8<--- {base}log/", "", log.read_text(encoding="utf-8").rstrip(), ""]

    (DOCS / "llms.txt").write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8")
    (DOCS / "llms-full.txt").write_text("\n".join(full).rstrip() + "\n", encoding="utf-8")
    print(
        f"llms.txt: {n} pages indexed; llms-full.txt: "
        f"{(DOCS / 'llms-full.txt').stat().st_size // 1024} KB"
    )


if __name__ == "__main__":
    sys.exit(main())
