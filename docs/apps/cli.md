---
type: Guide
title: MESA CLI (Cloud Shell)
description: The MESA CLI app, listed as MESA Cloud Shell — a browser terminal on CyVerse VICE with five AI coding-agent CLIs, the MESA MCP servers, CyVerse Data Store tools, and a geospatial conda environment.
tags:
  - apps
  - vice
  - cli
  - cloud-shell
  - terminal
  - agents
  - gpu
generated:
  by: "claude-code/2.1.294"
  at: "2026-10-08T00:00:00Z"
sources:
  - id: repo
    resource: "https://github.com/idss-mesa/cli"
    title: "MESA CLI image source repository"
    author: "team:idss-mesa"
  - id: ttyd
    resource: "https://github.com/tsl0922/ttyd"
    title: "ttyd (terminal in the browser)"
    author: "team:tsl0922"
status: stable
stale_after: "2027-04-08T00:00:00Z"
---

# MESA CLI (Cloud Shell)

**Repo:** [idss-mesa/cli](https://github.com/idss-mesa/cli) ·
**Image:** `harbor.cyverse.org/vice/mesa-cli:latest` (GPU: `:gpu`; Apple Silicon:
`:arm64`) · **In the portal:** Applications → MESA Apps → **MESA Cloud Shell**

A terminal in your browser — `bash` inside `tmux`, served by
[ttyd](https://github.com/tsl0922/ttyd) — with everything MESA needs for working from the
command line[^repo]. It is the lightest MESA app and the quickest way to put an AI coding
agent next to your CyVerse data.

## What's inside

| Category | Tools |
|---|---|
| **AI agent CLIs** | Claude Code (`claude`), Codex (`codex`), OpenCode (`opencode`), Goose (`goose`), Antigravity (`agy`), Claude Code Router (`ccr`) |
| **MCP servers** | `irods`, `mesa`, `formation`, and `filesystem`, registered for every agent — see [AI agents in the MESA apps](agents.md) |
| **Science** | A `geospatial` conda environment (GDAL, PDAL, GeoPandas, NumPy, SciPy, …); Miniconda and Mamba |
| **CyVerse data** | GoCommands, iRODS configuration, S3/OSN mounts, AWS CLI |
| **Developer tools** | GitHub CLI, Git Credential Manager, Go 1.25, Node.js 22 |

## Start it

1. In the [MESA Portal](https://mesa.cyverse.org/applications/), open **Applications →
   MESA Apps**.
2. On **MESA Cloud Shell**, click **Instant Launch** or **Launch with Options**. See
   [Starting applications](../portal/applications.md).
3. The terminal opens in a new tab, in `~/data-store` (your Data Store), with a MESA
   welcome screen.

## First steps

```bash
cyverse-login          # give the tools and agents your CyVerse access
aiverde-setup          # optional: connect AI Verde models
claude                 # or codex, opencode, goose, agy
```

See [AI agents in the MESA apps](agents.md) for what each step does. Save files you want
to keep under `~/data-store`; the rest of the container is deleted when the analysis ends.

**tmux.** The terminal runs inside `tmux`, so a dropped connection does not stop your
work: reopen the app from the [Analyses](../portal/analyses.md) page and you are back in
the same session. `Ctrl-b c` opens a new window and `Ctrl-b %` or `Ctrl-b "` splits the
current one.

## GPU build

`harbor.cyverse.org/vice/mesa-cli:gpu` is the same terminal on an NVIDIA A16 GPU. It adds:

| Adds | Details |
|---|---|
| **PyTorch** | `torch` 2.14 and `torchvision` 0.29 (CUDA 12.6) in the conda **base** environment, which the first terminal window uses |
| **ML libraries** | transformers, accelerate, `huggingface_hub` (`hf`) |
| **Local LLMs** | An Ollama server on the GPU — see [Local models on a GPU](agents.md#local-models-on-a-gpu) |
| **GPU tools** | `mesa-gpu-check`, `nvtop`, `nvitop` |

```bash
python -c 'import torch; print(torch.cuda.is_available(), torch.cuda.get_device_name(0))'
```

New `tmux` windows and panes start in the `geospatial` environment, which has no PyTorch.
Run `conda activate base` there (check with `which python`) to get back to the GPU
PyTorch.

## Run it on your own computer

```bash
docker run --rm -p 7681:7681 harbor.cyverse.org/vice/mesa-cli:latest
```

Open <http://localhost:7681>. `:latest` is built for `linux/amd64`; on an Apple Silicon Mac
use `:arm64`. Outside CyVerse the terminal has no password, so publish the port only on
your own machine.

[^repo]: MESA CLI README, <https://github.com/idss-mesa/cli>.
