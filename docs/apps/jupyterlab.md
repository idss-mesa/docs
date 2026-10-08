---
type: Guide
title: MESA JupyterLab
description: The MESA JupyterLab app — a Python, R, and Julia data-science workbench on CyVerse VICE with RStudio, Shiny, VS Code, AI coding agents, and the MESA MCP servers.
tags:
  - apps
  - vice
  - jupyterlab
  - python
  - r
  - julia
  - gpu
generated:
  by: "claude-code/2.1.294"
  at: "2026-10-08T00:00:00Z"
sources:
  - id: repo
    resource: "https://github.com/idss-mesa/jupyterlab"
    title: "MESA JupyterLab image source repository"
    author: "team:idss-mesa"
  - id: docker-stacks
    resource: "https://github.com/jupyter/docker-stacks"
    title: "Jupyter Docker Stacks (datascience-notebook base image)"
    author: "team:project-jupyter"
status: stable
stale_after: "2027-04-08T00:00:00Z"
---

# MESA JupyterLab

**Repo:** [idss-mesa/jupyterlab](https://github.com/idss-mesa/jupyterlab) ·
**Image:** `harbor.cyverse.org/vice/mesa-jupyterlab:latest` (GPU: `:gpu`) ·
**In the portal:** Applications → MESA Apps → **MESA JupyterLab**

A [JupyterLab](https://jupyterlab.readthedocs.io/) workbench for Python, R, and Julia,
built on the Project Jupyter *datascience-notebook* image[^repo]. RStudio Server, Shiny
Server, and VS Code open from the JupyterLab **Launcher**, and the AI coding agents and
MESA MCP servers are ready in every terminal.

## What's inside

| Category | Tools |
|---|---|
| **IDEs** | JupyterLab; RStudio Server, Shiny Server, and VS Code (code-server) as Launcher cards |
| **Science** | Python 3.13, R, and Julia with the datascience stack (NumPy, SciPy, pandas, tidyverse, …); Miniconda and Mamba |
| **AI agents and MCP** | Claude Code, Codex, OpenCode, Antigravity, Claude Code Router; the `irods`, `mesa`, `formation`, and `filesystem` MCP servers — see [AI agents in the MESA apps](agents.md) |
| **CyVerse data** | GoCommands, iRODS configuration, S3/OSN mounts, AWS CLI |
| **Developer tools** | GitHub CLI, Git Credential Manager, Go 1.25, Node.js 22 |

## Start it

1. In the [MESA Portal](https://mesa.cyverse.org/applications/), open **Applications →
   MESA Apps**.
2. On **MESA JupyterLab**, click **Instant Launch**, or **Launch with Options** to pick
   CPU cores, memory, the time limit, or the **GPU** build. See
   [Starting applications](../portal/applications.md).
3. The app opens in a new tab at the JupyterLab interface, in `~/data-store` (your Data
   Store).

You can also start it from the [Discovery Environment](https://de.cyverse.org) by
searching for *MESA JupyterLab*.

## First steps

1. Open a **Terminal** from the Launcher.
2. Run `cyverse-login` to give the tools and agents your CyVerse access.
3. Optionally run `aiverde-setup` to connect AI Verde models.
4. Start an agent: `claude`, `codex`, `opencode`, or `agy`.

The details are in [AI agents in the MESA apps](agents.md). Keep notebooks and results
under `~/data-store`: the rest of the container is deleted when the analysis ends.

**RStudio inside JupyterLab.** Click the **RStudio** card in the Launcher to open RStudio
Server in a new tab, with the same files and R installation.

## GPU build

`harbor.cyverse.org/vice/mesa-jupyterlab:gpu` is the same workbench on an NVIDIA GPU.
Choose **GPU** on the app's card in the portal. It adds:

| Adds | Details |
|---|---|
| **PyTorch** | `torch` 2.14 and `torchvision` 0.29 (CUDA 12.6) in the default **Python 3** kernel |
| **ML libraries** | transformers, accelerate, peft, sentence-transformers, safetensors, bitsandbytes, Lightning, timm, torchmetrics, TorchGeo, CuPy, `huggingface_hub` |
| **JupyterLab** | **GPU Dashboards** (NVDashboard) in the left sidebar; Jupyter AI chat with an `@OpenCode` persona |
| **Local LLMs** | An Ollama server on the GPU — see [Local models on a GPU](agents.md#local-models-on-a-gpu) |
| **GPU tools** | `nvidia-smi`, `nvtop`, `nvitop`, `mesa-gpu-check` |

Check the GPU from a notebook or terminal:

```bash
python -c 'import torch; print(torch.cuda.is_available(), torch.cuda.get_device_name(0))'
mesa-gpu-check
```

Jupyter AI's `@OpenCode` starts on an AI Verde model, which cannot read the key that
`aiverde-setup` saves. To chat with the local model instead, run `ollama-setup` in a
terminal, then pick `ollama/qwen3.5:9b` in `@OpenCode`'s model picker.

## Run it on your own computer

```bash
docker run --rm -p 8888:8888 -e IPLANT_USER=$USER harbor.cyverse.org/vice/mesa-jupyterlab:latest
```

Open <http://localhost:8888/lab>; RStudio is at <http://localhost:8888/rstudio/>. Outside
CyVerse there is no password, so publish the port only on your own machine. The image is
built for `linux/amd64`.

[^repo]: MESA JupyterLab README, <https://github.com/idss-mesa/jupyterlab>.
