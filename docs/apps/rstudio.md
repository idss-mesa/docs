---
type: Guide
title: MESA RStudio Geospatial
description: The MESA RStudio Geospatial app — RStudio Server on the Rocker geospatial stack (sf, terra, stars, GDAL) on CyVerse VICE, with AI coding agents and the MESA MCP servers.
tags:
  - apps
  - vice
  - rstudio
  - r
  - geospatial
  - gpu
generated:
  by: "claude-code/2.1.294"
  at: "2026-10-08T00:00:00Z"
sources:
  - id: repo
    resource: "https://github.com/idss-mesa/rstudio"
    title: "MESA RStudio Geospatial image source repository"
    author: "team:idss-mesa"
  - id: rocker
    resource: "https://rocker-project.org/images/versioned/rstudio.html"
    title: "Rocker geospatial images"
    author: "team:rocker-project"
status: stable
stale_after: "2027-04-08T00:00:00Z"
---

# MESA RStudio Geospatial

**Repo:** [idss-mesa/rstudio](https://github.com/idss-mesa/rstudio) ·
**Image:** `harbor.cyverse.org/vice/mesa-rstudio:latest` (GPU: `:gpu`) ·
**In the portal:** Applications → MESA Apps → **MESA RStudio Geospatial**

[RStudio Server](https://posit.co/products/open-source/rstudio-server/) on the
[Rocker geospatial](https://rocker-project.org/images/versioned/rstudio.html) stack, with
the MESA AI coding agents and CyVerse Data Store tools added[^repo]. There is no RStudio
login: CyVerse signs you in when the app opens.

## What's inside

| Category | Tools |
|---|---|
| **IDE** | RStudio Server |
| **Science** | R with the tidyverse, sf, terra, and stars; GDAL, PROJ, and GEOS |
| **AI agents and MCP** | Claude Code, Codex, OpenCode, Antigravity, Claude Code Router; the `irods`, `mesa`, `formation`, and `filesystem` MCP servers — see [AI agents in the MESA apps](agents.md) |
| **CyVerse data** | GoCommands, iRODS configuration, S3/OSN mounts, AWS CLI |
| **Developer tools** | GitHub CLI, Git Credential Manager, Go 1.25, Node.js 22 |

The agent CLIs are on the `PATH` both in RStudio's **Terminal** tab and in R, for example
`system("claude --version")`.

## Start it

1. In the [MESA Portal](https://mesa.cyverse.org/applications/), open **Applications →
   MESA Apps**.
2. On **MESA RStudio Geospatial**, click **Instant Launch** or **Launch with Options**. See
   [Starting applications](../portal/applications.md).
3. RStudio opens in a new tab with `~/data-store` (your Data Store) as the working folder.

You can also start it from the [Discovery Environment](https://de.cyverse.org) by
searching for *MESA RStudio Geospatial*.

## First steps

1. Open the **Terminal** tab in RStudio.
2. Run `cyverse-login` to give the tools and agents your CyVerse access.
3. Optionally run `aiverde-setup` to connect AI Verde models.
4. Start an agent in the terminal: `claude`, `codex`, `opencode`, or `agy`.

See [AI agents in the MESA apps](agents.md). Save scripts, projects, and outputs under
`~/data-store`; the rest of the container is deleted when the analysis ends.

## GPU build

`harbor.cyverse.org/vice/mesa-rstudio:gpu` adds GPU computing to the same workbench. It
adds:

| Adds | Details |
|---|---|
| **Deep learning in R** | [torch](https://torch.mlverse.org) with its CUDA runtime, luz, torchvision, tabnet, brulee, tidymodels |
| **GPU xgboost** | xgboost built for the GPU (`device = "cuda"`); lightgbm on the CPU |
| **Local LLMs** | An Ollama server on the GPU, with the `ollamar`, `ellmer`, and `mall` R packages — see [Local models on a GPU](agents.md#local-models-on-a-gpu) |
| **Python from R** | reticulate, keras3, and tensorflow; the first `library(keras3)` downloads TensorFlow and its CUDA libraries (about 13 GB, about a minute; kept until the analysis ends) |
| **GPU tools** | `mesa-gpu-check`, `nvtop`, `nvitop` |

Try it in R:

```r
library(torch); cuda_is_available()           # TRUE on a GPU node
ollamar::generate("qwen3.5:9b", "Summarise this abstract: ...", output = "text")   # after ollama-setup
```

Two cautions:

- `install.packages("torch")` or `install.packages("xgboost")` replaces the GPU builds with
  CPU-only ones. Leave those two packages as they are.
- Load keras3 or tensorflow **before** `library(torch)` in a session; R torch and Python
  torch cannot be loaded in the same R session.

## Run it on your own computer

```bash
docker run --rm -p 8787:80 -e IPLANT_USER=$USER -e REDIRECT_URL=http://localhost:8787 \
  harbor.cyverse.org/vice/mesa-rstudio:latest
```

Open <http://localhost:8787>. If a new browser lands on a "not found" page, open
<http://localhost:8787/auth-sign-in> once and then <http://localhost:8787/> again. Outside
CyVerse there is no password, so publish the port only on your own machine. The image is
built for `linux/amd64`.

[^repo]: MESA RStudio Geospatial README, <https://github.com/idss-mesa/rstudio>.
