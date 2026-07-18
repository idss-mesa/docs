---
type: MCP Server
title: mesa-mcp
description: The flagship MESA server — iRODS Data Store tools, OBO/OLS ontology AVUs, DataCite, and DuckLake metadata history.
tags:
  - mesa-mcp
  - python
  - irods
  - ontology
  - datacite
  - ducklake
timestamp: "2026-07-18T00:00:00Z"
---

# mesa-mcp

**Repo:** [idss-mesa/mesa-mcp](https://github.com/idss-mesa/mesa-mcp) · **Language:** Python 3.11+ · **Registered as:** `mesa-mcp`

The flagship MESA server. It bridges the CyVerse Data Store (iRODS) with ontology-driven
metadata management and exposes everything as MCP tools.

## Tool groups

| Prefix | What it does |
|---|---|
| `ds_*` | iRODS Data Store: list/read/write/move files, directories, AVUs, ACLs, tickets, rules, policies (drop-in compatible with [irods-mcp-server](irods-mcp-server.md)) |
| `mesa_ols_*` | Browse OBO/OLS ontologies: search terms, fetch hierarchies, generate AVU templates |
| `mesa_avu_*` | Apply ontology terms and DataCite fields as AVUs (with the CURIE in the `unit` slot) |
| `mesa_datacite_*` | DataCite metadata: template, validate, export, apply |
| `mesa_ducklake_*` | Metadata history: init a project, snapshot, list history, time-travel, diff (backed by [mesa-ducklake](mesa-ducklake.md)) |

## How MESA runs it

The installer creates a uv venv and installs `mesa-mcp` editable (alongside
`mesa-ducklake`), then registers the stdio entry point:

```bash
~/.mesa/.venv/bin/mesa-mcp --transport stdio
```

It is registered under the name `mesa-mcp` with every detected client — see
[Claude Code](../claude-code.md), [Codex CLI](../codex.md),
[Antigravity](../antigravity.md), or [OpenCode](../opencode.md) for the exact
registration each one gets.

## The AVU contract

Metadata is written as `(attribute, value, unit)` triples, where `unit` is reserved for the
ontology CURIE when the AVU came from OBO/OLS. Provenance (actor, source, ticket, rule) is
recorded in DuckLake columns, never folded into the triple.

## Configuration

Configuration precedence is **CLI flag > environment variable > YAML file > defaults**. The
defaults target anonymous public CyVerse access. See [Credentials](../credentials.md) and
[`.env.example`](https://github.com/idss-mesa/mesa-mcp/blob/main/.env.example) for the full set.

Full documentation lives in the repo under
[`docs/`](https://github.com/idss-mesa/mesa-mcp/tree/main/docs) (user / dev / deploy guides).
