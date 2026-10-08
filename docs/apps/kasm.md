---
type: Guide
title: MESA KASM Ubuntu Desktop
description: The MESA KASM Ubuntu Desktop app — a full Ubuntu 24.04 XFCE desktop in the browser on CyVerse VICE, with web browsers, VS Code, AI coding agents, and the MESA MCP servers.
tags:
  - apps
  - vice
  - kasm
  - desktop
  - ubuntu
  - gpu
  - opengl
generated:
  by: "claude-code/2.1.294"
  at: "2026-10-08T00:00:00Z"
sources:
  - id: repo
    resource: "https://github.com/idss-mesa/kasm"
    title: "MESA KASM Ubuntu Desktop image source repository"
    author: "team:idss-mesa"
  - id: kasmvnc
    resource: "https://kasmweb.com/kasmvnc"
    title: "KasmVNC"
    author: "team:kasm-technologies"
status: stable
stale_after: "2027-04-08T00:00:00Z"
---

# MESA KASM Ubuntu Desktop

**Repo:** [idss-mesa/kasm](https://github.com/idss-mesa/kasm) ·
**Image:** `harbor.cyverse.org/vice/mesa-kasm:latest` (GPU: `:gpu`) ·
**In the portal:** Applications → MESA Apps → **MESA KASM Ubuntu Desktop**

A complete Ubuntu 24.04 desktop (XFCE) in a browser tab, streamed with
[KasmVNC](https://kasmweb.com/kasmvnc)[^repo]. Use it for software that needs a
graphical interface — desktop GIS, 3D viewers, or anything you install yourself — next to
the MESA AI coding agents and CyVerse Data Store tools.

## What's inside

| Category | Tools |
|---|---|
| **Desktop** | XFCE with a terminal, Chrome, Firefox, VS Code, and the rest of the Kasm desktop app set |
| **AI agents and MCP** | Claude Code, Codex, OpenCode, Antigravity, Claude Code Router; the `irods`, `mesa`, `formation`, and `filesystem` MCP servers — see [AI agents in the MESA apps](agents.md) |
| **CyVerse data** | GoCommands, iRODS configuration, S3/OSN mounts, AWS CLI |
| **Developer tools** | GitHub CLI, Git Credential Manager, Go 1.25, Node.js 22 |

## Start it

1. In the [MESA Portal](https://mesa.cyverse.org/applications/), open **Applications →
   MESA Apps**.
2. On **MESA KASM Ubuntu Desktop**, click **Instant Launch** or **Launch with Options**.
   See [Starting applications](../portal/applications.md).
3. The desktop opens in a new tab. Your Data Store is in `~/data-store`.

You can also start it from the [Discovery Environment](https://de.cyverse.org) by
searching for *MESA KASM Ubuntu Desktop*.

## First steps

1. Open a terminal from the desktop.
2. Run `cyverse-login` to give the tools and agents your CyVerse access.
3. Optionally run `aiverde-setup` to connect AI Verde models.
4. Start an agent: `claude`, `codex`, `opencode`, or `agy`.

See [AI agents in the MESA apps](agents.md). Save files you want to keep under
`~/data-store`; the rest of the desktop is deleted when the analysis ends.

## GPU build

`harbor.cyverse.org/vice/mesa-kasm:gpu` runs the desktop on an NVIDIA GPU. It adds:

| Adds | Details |
|---|---|
| **Desktop graphics** | OpenGL on the GPU for the whole desktop (browsers, VS Code, Qt apps, and 3D apps you install such as Blender); `mesa-gl-run <app>` (VirtualGL) for heavy 3D; `glxinfo`, `vulkaninfo`, `glmark2`; **GPU Monitor**, **GPU Check**, and **GLX Spheres** in the menu |
| **PyTorch** | PyTorch 2.14 (CUDA 12.6) in the conda environment `pytorch`: run `conda activate pytorch` |
| **Local LLMs** | An Ollama server on the GPU — see [Local models on a GPU](agents.md#local-models-on-a-gpu) |
| **GPU tools** | `mesa-gpu-check`, `nvtop`, `nvitop` |

If a 3D app is slow or draws incorrectly, start it with `mesa-gl-run <app>` instead, or
with `__GLX_VENDOR_LIBRARY_NAME=mesa <app>` to fall back to software rendering for that
app only.

## Run it on your own computer

```bash
docker run --rm --shm-size=512m -p 6901:6901 -e IPLANT_USER=$USER harbor.cyverse.org/vice/mesa-kasm:latest
```

Open <http://localhost:6901>. Outside CyVerse there is no password, so publish the port
only on your own machine. The image is built for `linux/amd64`.

[^repo]: MESA KASM Ubuntu Desktop README, <https://github.com/idss-mesa/kasm>.
