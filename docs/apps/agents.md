---
type: Guide
title: AI agents in the MESA apps
description: Use the AI coding agents and MESA MCP servers built into every MESA featured app — sign in to CyVerse, connect AI Verde or local Ollama models, and reach your Data Store.
tags:
  - apps
  - vice
  - agents
  - claude-code
  - codex
  - opencode
  - antigravity
  - ai-verde
  - ollama
generated:
  by: "claude-code/2.1.294"
  at: "2026-10-08T00:00:00Z"
sources:
  - id: jupyterlab
    resource: "https://github.com/idss-mesa/jupyterlab"
    title: "MESA JupyterLab image (README: Sign in to CyVerse, Connect AI Verde LLMs, GPU variant)"
    author: "team:idss-mesa"
  - id: cli
    resource: "https://github.com/idss-mesa/cli"
    title: "MESA CLI image (README)"
    author: "team:idss-mesa"
  - id: ai-verde
    resource: "https://aiverde-docs.cyverse.ai/"
    title: "CyVerse AI Verde documentation"
    author: "team:cyverse"
status: stable
stale_after: "2027-04-08T00:00:00Z"
---

# AI agents in the MESA apps

All five [featured apps](index.md) share the same *MESA agentic stack*: AI coding-agent
command-line tools, the MESA MCP servers already registered with each of them, and the
CyVerse Data Store tools[^jupyterlab]. This page covers what is the same in every app;
each app's page covers what is different.

## What every app includes

| Category | Tools |
|---|---|
| **AI agent CLIs** | Claude Code (`claude`), OpenAI Codex (`codex`), OpenCode (`opencode`), Antigravity (`agy`), and Claude Code Router (`ccr`). The [MESA CLI](cli.md) also has Goose (`goose`). |
| **MCP servers** | `irods` (CyVerse Data Store), `mesa` ([mesa-mcp](../servers/mesa-mcp.md) with [mesa-ducklake](../servers/mesa-ducklake.md)), `formation` (CyVerse's hosted [Formation](../servers/formation-mcp.md) server for the Discovery Environment), and `filesystem`, registered for every agent CLI |
| **CyVerse data** | GoCommands (`gocmd`), an iRODS configuration, `osn-mount.sh` for Open Storage Network and other S3 buckets, the AWS CLI |
| **Developer tools** | GitHub CLI (`gh`), Git Credential Manager, Go 1.25, Node.js 22 |

The agents are command-line tools: open a terminal in the app (a JupyterLab or VS Code
terminal, the RStudio **Terminal** tab, a terminal on the KASM desktop, or the MESA CLI
itself) and type `claude`, `codex`, `opencode`, or `agy`.

## Your Data Store inside the app

When the app starts from the portal or the Discovery Environment, your Data Store is
mounted under `~/data-store`, and the app opens there. Save work you want to keep under
`~/data-store`: everything else lives on the container's disk and is gone when the
analysis ends.

At start-up each app also copies `.gitconfig`, `.aws/`, and `.ssh/` from your Data Store
home folder (`/iplant/home/<username>/`) into the app's home folder, so Git and AWS
settings you keep there follow you into every session.

## 1. Sign in to CyVerse

```bash
cyverse-login          # your CyVerse username and password
```

`cyverse-login` writes the standard iRODS credentials (`~/.irods/`), so GoCommands, the
local `mesa` and `irods` MCP servers, and the agents act as **you**, with access to your
home folder and to what is shared with you. Without it they have anonymous, read-only
access to public data. Restart an agent after signing in so its MCP servers pick up the
credentials. `cyverse-login` does not cover `formation`; see the next step.

**Claude Code** also registers the hosted CyVerse Data Store MCP servers: `irods` (the
anonymous public endpoint, which works at once) and `irods-auth` (the authenticated
endpoint). To reach your private home folder through `irods-auth`, sign in once per
session:

```bash
claude mcp login irods-auth --no-browser   # opens a kc.cyverse.org URL; paste the redirect back
```

Codex and Antigravity run a local `irods` server, and every agent runs a local `mesa`
server; these and `gocmd` read the `~/.irods` credentials that `cyverse-login` wrote.
OpenCode's `irods` is the hosted public endpoint, which reads public data only.

### Sign in to Formation

`formation` is CyVerse's hosted [Formation](../servers/formation-mcp.md) server at
<https://de.cyverse.org/formation/mcp>, already registered for every agent. It does not
use `~/.irods`: each agent signs in to it with your CyVerse account the first time. The
app's home folder is not kept between analyses, so sign in again in each new analysis.

| Agent | Sign in |
|---|---|
| Claude Code | `claude mcp login formation --no-browser`, then open the printed address in your browser and paste the address you land on back into the terminal |
| Codex | `codex mcp login formation --no-browser`, then the same: open the address, and paste the address you land on back |
| Antigravity (KASM desktop) | from the IDE's MCP servers panel |

OpenCode cannot finish this sign-in from your own browser: it waits for the browser to
come back to the container, which your browser cannot reach. Use another agent for
Formation there. On the [KASM desktop](kasm.md) the browser runs inside the app, so you can
also sign in normally by opening the address in the desktop's Chrome or Firefox.

## 2. Connect a language model

The images contain no API keys: each person brings their own.

### CyVerse AI Verde

[AI Verde](https://aiverde-docs.cyverse.ai/) is CyVerse's hosted LLM service[^ai-verde].
Get an API key from <https://chat.cyverse.ai> (**Course → API Key**), then in a terminal:

```bash
aiverde-setup          # paste your AI Verde key
```

It checks the key, lists the models your course can use, and saves the settings to
`~/.config/aiverde/env` (readable only by you). Then:

| Agent | How it uses AI Verde |
|---|---|
| **OpenCode** | Through its `aiverde` provider |
| **Claude Code** | Through Claude Code Router: `ccr code` (or directly, if your course serves Anthropic models) |
| **Goose** (MESA CLI) | Through its OpenAI-compatible provider: `goose` |
| **Codex** | Not supported: Codex uses its own OpenAI sign-in |

### Your own accounts

Each agent can also use its vendor's own sign-in, for example `claude` with an Anthropic
account or `codex` with an OpenAI account. Follow the prompts the first time you start it.

### Local models on a GPU

The GPU builds of every app run an [Ollama](https://ollama.com) server inside the
container, so agents can use an open model on the GPU with no API key and nothing leaving
the analysis:

```bash
ollama-setup                                   # pulls qwen3.5:9b (the default) and prints these commands
ollama launch claude --model qwen3.5:9b        # Claude Code on the local model
codex --oss --local-provider ollama -m qwen3.5:9b
opencode -m ollama/qwen3.5:9b
```

One 16 GB NVIDIA A16 GPU fits `qwen3.5:9b`, `gpt-oss:20b`, `gemma4:12b`, or `qwen3:4b`
(`ollama-setup --help` lists them); larger models spill onto the CPU. Models are stored in
`~/.ollama/models` on the container's disk and are deleted when the analysis ends.
`ollama stop <model>` frees the GPU memory for PyTorch or other work.

`mesa-gpu-check` (`mesa-gpu-check --ollama` for a short model test) checks the GPU, the
driver, CUDA, PyTorch, and Ollama.

## 3. Ask

With credentials in place, ask an agent for things such as:

- *"List the folders in my CyVerse home and tell me which ones have AVU metadata."*
- *"Find NEON soil-moisture data in the MESA community folder and load it into a pandas
  DataFrame."*
- *"Launch a MESA JupyterLab analysis and tell me when it is running."* (needs the
  Formation sign-in above)

The agent calls the MESA MCP servers to do the work; see [Servers](../servers/index.md)
for what each one can do.

[^jupyterlab]: MESA JupyterLab README, <https://github.com/idss-mesa/jupyterlab>; the same sections appear in the README of each MESA app repository.
[^ai-verde]: CyVerse AI Verde documentation, <https://aiverde-docs.cyverse.ai/>.
