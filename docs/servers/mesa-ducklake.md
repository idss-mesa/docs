---
type: Library
title: mesa-ducklake
description: The AVU metadata-history library that backs mesa-mcp — DuckLake-pattern snapshots, provenance, and time-travel.
tags:
  - mesa-ducklake
  - python
  - ducklake
  - metadata-history
generated:
  by: "claude/opus-5.5"
  at: "2026-11-24T00:00:00Z"
sources:
  - id: repo
    resource: "https://github.com/idss-mesa/mesa-ducklake"
    title: "mesa-ducklake source repository"
    author: "team:idss-mesa"
  - id: mesa-mcp-tools
    resource: "https://github.com/idss-mesa/mesa-mcp/tree/main/src/mesa_mcp/ducklake/tools"
    title: "mesa-mcp mesa_ducklake_* tool modules"
    author: "team:idss-mesa"
status: stable
stale_after: "2027-03-10T00:00:00Z"
---

# mesa-ducklake

**Repo:** [idss-mesa/mesa-ducklake](https://github.com/idss-mesa/mesa-ducklake) · **Language:** Python 3.11+ · **Registered as:** *(none — it's a library)*

`mesa-ducklake` is **not a standalone MCP server.** It is the metadata-history library that
[mesa-mcp](mesa-mcp.md) imports in-process. The installer installs it editable into the same
venv so `mesa-mcp` resolves it, but it is never registered with any client on its own.

## What it does

It records the full history of AVU (attribute/value/unit) changes for a project as an
append-only series of snapshots. It follows the DuckDB **DuckLake** lakehouse *pattern*:

- a **catalog** — either a local DuckDB file (`duckdb:///path/catalog.duckdb`) or Postgres —
  holds projects, snapshots, and provenance;
- **Parquet** data files, one `snapshot_<id>.parquet` per snapshot, hold the AVU change
  records at `<project>/.mesa/ducklake/` inside iRODS, so metadata travels with the data.

Every AVU write through `mesa-mcp` is mirrored here as a change record with provenance
(actor, source, ticket, rule), enabling **time-travel** reads: *"what were this object's AVUs
as of last Tuesday?"*

## It is not the `ducklake` extension

mesa-ducklake uses its own catalog and plain Parquet. It does **not** use the DuckDB
`ducklake` extension, so `.mesa/ducklake/` is not something you can `ATTACH 'ducklake:…'`.

- **Reading the history.** Every Parquet row carries its `project_id`, `snapshot_id`, `ts`,
  `actor`, `source` and `op`, so `read_parquet` over the files gives the full history with no
  catalog. The catalog itself is not stored in iRODS.
- **Writing.** Files are written to a local cache first, because DuckDB can't write to iRODS.
  Each file is pushed to iRODS with a checksum check before its catalog row is committed.
- **Porting.** Moving the history to the real extension is an open design item. The
  constraints a port must keep are listed in the repo's
  [architecture doc](https://github.com/idss-mesa/mesa-ducklake/blob/main/docs/dev/architecture.md#porting-the-history-to-the-ducklake-extension).

A MESA project can *also* hold a real, extension-format DuckLake of its science data. For
example, [neon-ducklake](https://github.com/idss-mesa/neon-ducklake) has
`ducklake/neon_catalog.ducklake` plus `ducklake/data/`. That lake belongs to the project.
mesa-ducklake only records the AVUs placed on its files. The two share a name and nothing else.

How to read a project's history read-only, in place or from a copy, is in
[Reading a project's history without the catalog](https://github.com/idss-mesa/mesa-ducklake/blob/main/docs/deploy/per-project-storage.md#reading-a-projects-history-without-the-catalog).

## How you use it

Through `mesa-mcp`'s `mesa_ducklake_*` tools — there's nothing to install or run separately:

| Tool | Purpose |
|---|---|
| `mesa_ducklake_init_project` | enable history for an iRODS collection |
| `mesa_ducklake_history` | list the AVU changes recorded for a path |
| `mesa_ducklake_time_travel` | the AVU set on a path as of a timestamp |

Diffs between snapshots are available from the Python API (`DuckLakeClient.diff`), not as an
MCP tool.

## Programmatic API

The library's only public entry point is the `DuckLakeClient` facade. A `mesa-ducklake`
CLI (`record` / `recover` / `migrate`) also exists for iRODS rule callbacks and operators.
Both are documented in the repo under
[`docs/`](https://github.com/idss-mesa/mesa-ducklake/tree/main/docs).

!!! info "Snapshots are immutable"
    Snapshots are append-only; corrections are new snapshots, never rewrites.
