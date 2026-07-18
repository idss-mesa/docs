---
type: Library
title: mesa-ducklake
description: The AVU metadata-history library that backs mesa-mcp — DuckLake snapshots, provenance, and time-travel.
tags:
  - mesa-ducklake
  - python
  - ducklake
  - metadata-history
timestamp: "2026-07-18T00:00:00Z"
---

# mesa-ducklake

**Repo:** [idss-mesa/mesa-ducklake](https://github.com/idss-mesa/mesa-ducklake) · **Language:** Python 3.11+ · **Registered as:** *(none — it's a library)*

`mesa-ducklake` is **not a standalone MCP server.** It is the metadata-history library that
[mesa-mcp](mesa-mcp.md) imports in-process. The installer installs it editable into the same
venv so `mesa-mcp` resolves it, but it is never registered with any client on its own.

## What it does

It records the full history of AVU (attribute/value/unit) changes for a project as an
append-only series of snapshots, using the DuckDB **DuckLake** lakehouse pattern:

- a **catalog** — either a local DuckDB file (`duckdb:///path/catalog.duckdb`) or Postgres —
  holds projects, snapshots, and provenance;
- **Parquet** data files hold the AVU change records and can live at
  `<project>/.mesa/ducklake/` inside iRODS, so metadata travels with the data.

Every AVU write through `mesa-mcp` is mirrored here as a change record with provenance
(actor, source, ticket, rule), enabling **time-travel** reads: *"what were this object's AVUs
as of last Tuesday?"*

## How you use it

Through `mesa-mcp`'s `mesa_ducklake_*` tools — there's nothing to install or run separately:

| Tool | Purpose |
|---|---|
| `mesa_ducklake_init_project` | enable history for an iRODS collection |
| `mesa_ducklake_snapshot` | capture current AVU state |
| `mesa_ducklake_history` | list AVU changes over time |
| `mesa_ducklake_time_travel` | AVU set as of a timestamp |
| `mesa_ducklake_diff` | diff two snapshots |

## Programmatic API

The library's only public entry point is the `DuckLakeClient` facade. A `mesa-ducklake`
CLI (`record` / `recover`) also exists for iRODS rule callbacks and operators. Both are
documented in the repo under
[`docs/`](https://github.com/idss-mesa/mesa-ducklake/tree/main/docs).

!!! info "Snapshots are immutable"
    DuckLake snapshots are append-only; corrections are new snapshots, never rewrites.
