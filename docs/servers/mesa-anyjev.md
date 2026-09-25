---
type: Library
title: mesa-anyjev
description: Calibrated, declarative ontology and schema decisions for MESA — a plugin that adds the mesa_decide_* tools to mesa-mcp and records every decision next to the DuckLake history.
tags:
  - mesa-anyjev
  - python
  - anyjev
  - decisions
  - calibration
generated:
  by: "claude/fable-5.1"
  at: "2026-09-25T00:00:00Z"
sources:
  - id: repo
    resource: "https://github.com/idss-mesa/mesa-anyjev"
    title: "mesa-anyjev source repository"
    author: "team:idss-mesa"
status: draft
stale_after: "2027-03-31T00:00:00Z"
---

# mesa-anyjev

**Repo:** [idss-mesa/mesa-anyjev](https://github.com/idss-mesa/mesa-anyjev) · **Language:** Python 3.11+ · **Registered as:** *(none — it is a plugin inside mesa-mcp)*

`mesa-anyjev` is **not a standalone MCP server.** It turns the choices MESA makes on the way
to an AVU (which ontology, which candidate term, which value, keep or drop) into fixed
[AnyJev](https://github.com/nokia-applied-research/AnyJev) questions answered from one prefill
of an open model's logits, with a calibrated probability and an explicit level (`raw`, `L0`,
`L1`, `L2`) per decision. A reasoning model only plans; code does everything deterministic;
every decision is written to a sidecar next to the [mesa-ducklake](mesa-ducklake.md) AVU
history before anything reaches iRODS.

## What the installer does

It clones the repository into `~/.mesa/repos/mesa-anyjev` and installs it editable into the
same venv as `mesa-mcp`, with AnyJev pinned to the commit the design was verified against.
mesa-mcp loads the plugin's tools through the `mesa_mcp.tools` entry point, so once
mesa-mcp's loader is merged the tools appear in every registered client without further
configuration:

| Tool | What it does |
|---|---|
| `mesa_decide_annotate` | decide and propose AVUs for a dataset card (no writes) |
| `mesa_decide_apply` | write accepted AVUs to iRODS and mirror them into the DuckLake; asks one question per open candidate group |
| `mesa_decide_explain` | every decision of a run with level, calibration and probability |
| `mesa_decide_feedback` | a curator's pick, reject or decline (authoritative; becomes labels) |
| `mesa_decide_health` | questions lock, provenance store, backend, promoted artifacts |

The default backend is the synthetic one (no model). To decide with a real model, point it at
the CARC gateway (`MESA_ANYJEV_BACKEND__KIND=gateway` and the tunnel; the `gateway` extra) or
at local weights on a CUDA host (the `hf` extra). See the
[mesa-anyjev documentation](https://idss-mesa.github.io/mesa-anyjev/) for the configuration,
the decision graph, levels and policy, and the bench numbers.

```bash
~/.mesa/.venv/bin/mesa-anyjev doctor
~/.mesa/.venv/bin/mesa-anyjev annotate --card <dataset-card.md>
```
