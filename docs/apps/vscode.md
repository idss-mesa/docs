---
type: Guide
title: MESA VS Code
description: The MESA VS Code app — VS Code in the browser (code-server) on CyVerse VICE with Python, Jupyter, and Cline extensions, AI coding agents, and the MESA MCP servers.
tags:
  - apps
  - vice
  - vscode
  - code-server
  - cline
  - gpu
  - cuda
generated:
  by: "claude-code/2.1.294"
  at: "2026-10-08T00:00:00Z"
sources:
  - id: repo
    resource: "https://github.com/idss-mesa/vscode"
    title: "MESA VS Code image source repository"
    author: "team:idss-mesa"
  - id: code-server
    resource: "https://github.com/coder/code-server"
    title: "code-server (VS Code in the browser)"
    author: "team:coder"
status: stable
stale_after: "2027-04-08T00:00:00Z"
---

# MESA VS Code

**Repo:** [idss-mesa/vscode](https://github.com/idss-mesa/vscode) ·
**Image:** `harbor.cyverse.org/vice/mesa-vscode:latest` (GPU: `:gpu`) ·
**In the portal:** Applications → MESA Apps → **MESA VS Code**

Visual Studio Code in the browser ([code-server](https://github.com/coder/code-server)),
with the MESA AI coding agents and CyVerse Data Store tools added[^repo]. The
[Cline](https://github.com/cline/cline) extension comes with the MESA MCP servers already
configured, so you can use an agent from the editor's side bar as well as from the
terminal.

## What's inside

| Category | Tools |
|---|---|
| **IDE** | code-server with the Python, Jupyter, vscode-icons, and Cline extensions |
| **Science** | Miniconda and Mamba (`/opt/conda`) |
| **Transfer** | Globus Connect Server 5.4 |
| **AI agents and MCP** | Claude Code, Codex, OpenCode, Antigravity, Claude Code Router; the `irods`, `mesa`, `formation`, and `filesystem` MCP servers, for the CLIs and for Cline — see [AI agents in the MESA apps](agents.md) |
| **CyVerse data** | GoCommands, iRODS configuration, S3/OSN mounts, AWS CLI |
| **Developer tools** | GitHub CLI, Git Credential Manager, Go 1.25, Node.js 22 |

## Start it

1. In the [MESA Portal](https://mesa.cyverse.org/applications/), open **Applications →
   MESA Apps**.
2. On **MESA VS Code**, click **Instant Launch** or **Launch with Options**. See
   [Starting applications](../portal/applications.md).
3. VS Code opens in a new tab on your Data Store home folder.

You can also start it from the [Discovery Environment](https://de.cyverse.org) by
searching for *MESA VS Code*.

## First steps

1. Open a terminal: **Terminal → New Terminal** (or <kbd>Ctrl</kbd>+<kbd>`</kbd>).
2. Run `cyverse-login` to give the tools and agents your CyVerse access.
3. Optionally run `aiverde-setup` to connect AI Verde models.
4. Start an agent: `claude`, `codex`, `opencode`, or `agy`, or open **Cline** in the side
   bar and choose a model provider.

See [AI agents in the MESA apps](agents.md). Keep your work in the Data Store folder VS
Code opened; the rest of the container is deleted when the analysis ends.

## GPU build

For GPU work, launch the **GPU** build (`harbor.cyverse.org/vice/mesa-vscode:gpu`). It adds:

| Adds | Details |
|---|---|
| **CUDA** | The CUDA 12.5 toolkit (`nvcc`, `cuda-gdb`, `compute-sanitizer`, Nsight command-line tools) |
| **PyTorch environment** | `/opt/conda/envs/pytorch` (Python 3.13): PyTorch 2.14 (CUDA 12.6), transformers, accelerate, datasets, peft, sentence-transformers, bitsandbytes, Lightning, timm, CuPy, and more. It is the default VS Code interpreter and a Jupyter kernel named **PyTorch 2.14 (CUDA 12.6)** |
| **Local LLMs** | An Ollama server on the GPU — see [Local models on a GPU](agents.md#local-models-on-a-gpu); the [Continue](https://continue.dev) extension is set up for the local model |
| **Extensions** | NVIDIA Nsight (CUDA debugging), clangd for C++/CUDA, CMake Tools |
| **GPU tools** | `mesa-gpu-check`, `nvtop`, `nvitop` |

Compile CUDA code for the A16 GPUs with, for example,
`nvcc -gencode arch=compute_86,code=sm_86 kernel.cu`. When you install Python packages
that depend on PyTorch, add `--extra-index-url https://download.pytorch.org/whl/cu126` so
pip keeps the CUDA 12.6 build.

## Run it on your own computer

```bash
docker run --rm -p 8080:8080 -e IPLANT_USER=$USER harbor.cyverse.org/vice/mesa-vscode:latest
```

Open <http://localhost:8080>. Outside CyVerse there is no password, so publish the port
only on your own machine. The image is built for `linux/amd64`.

[^repo]: MESA VS Code README, <https://github.com/idss-mesa/vscode>.
