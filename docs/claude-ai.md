---
type: Integration Guide
title: claude.ai and Claude Desktop
description: Add CyVerse's hosted Formation MCP server (and, optionally, CyVerse's public Data Store server) to claude.ai and Claude Desktop as a custom connector, sign in with your CyVerse account, and use it in chats and in Claude Code.
tags:
  - claude-ai
  - claude-desktop
  - connector
  - formation
  - remote-mcp
  - oauth
generated:
  by: "claude-code/2.1.294"
  at: "2026-10-08T00:00:00Z"
sources:
  - id: claude-connectors
    resource: "https://support.claude.com/en/articles/11175166-getting-started-with-custom-connectors-using-remote-mcp"
    title: "Getting started with custom connectors using remote MCP"
    author: "team:anthropic"
  - id: claude-code-mcp
    resource: "https://code.claude.com/docs/en/mcp"
    title: "Claude Code MCP documentation (Use MCP servers from claude.ai)"
    author: "team:anthropic"
  - id: formation
    resource: "https://github.com/cyverse-de/formation"
    title: "Formation source repository (README)"
    author: "team:cyverse-de"
status: stable
stale_after: "2027-04-08T00:00:00Z"
---

# claude.ai and Claude Desktop

On claude.ai and in Claude Desktop, MCP servers are added as **connectors**. A custom
connector points Claude at a remote MCP server on the internet; Claude connects to it from
Anthropic's cloud, not from your computer[^claude-connectors].

The main MESA server you can add this way is **[Formation](servers/formation-mcp.md)**,
CyVerse's hosted MCP server for the Discovery Environment, at
<https://de.cyverse.org/formation/mcp>. With it, Claude can launch Discovery Environment
apps, follow your analyses, and read and write your Data Store files, as you. CyVerse also
hosts a public, read-only Data Store server at `https://mcp-public.cyverse.ai/mcp`, which
you can add the same way ([below](#optional-public-data-store-connector)). The installer's
`mesa-mcp` and `irods` servers run on your own computer and are for
[Claude Code](claude-code.md) and the other agent clients.

Custom connectors are available on the Free, Pro, Max, Team, and Enterprise plans; the Free
plan allows one custom connector, so pick the one you need.

## Add the Formation connector

=== "Free, Pro, and Max"

    1. Go to **Customize > Connectors**. In Claude Desktop, choose **Customize** in the
       sidebar, then **Connectors**.
    2. Click **+ Add**, then **Add custom connector**.
    3. Enter a name, for example `CyVerse Formation`.
    4. Enter the URL `https://de.cyverse.org/formation/mcp` exactly (no trailing slash)
       and click **Continue**.
    5. Review the authentication settings Claude detected and click **Continue**.
    6. Under **Authentication**, choose **Sign in now** (or **Sign in when needed**).
    7. Under **OAuth client**, choose **Register automatically** (not the default
       **Use Claude's published identity**). Formation registers Claude for you; there
       is no client ID or secret to enter.
    8. Leave **Request headers** empty and click **Add**.
    9. Sign in with your CyVerse username and password on the CyVerse page that opens.

=== "Team and Enterprise"

    **An owner adds it once for the organization:**

    1. Go to **Organization settings > Connectors**.
    2. Click **Add**, hover over **Custom**, and select **Web**.
    3. Enter a name (`CyVerse Formation`) and the URL
       `https://de.cyverse.org/formation/mcp`, and click **Continue**.
    4. Review the detected authentication, choose **Register automatically** under
       **OAuth client**, and click **Add**.

    On Team, Owners and Primary Owners can add connectors; on Enterprise, so can people
    with a custom role that includes **Manage access to Libraries**.

    **Then each member connects it:**

    1. Go to **Customize > Connectors**.
    2. Find **CyVerse Formation** (it has a **Custom** label) and click **Connect**.
    3. Sign in with your own CyVerse account.

    Every member signs in separately, so Claude only reaches what that person can reach
    in CyVerse.

To change a connector's settings later, remove it and add it again.

## Optional: public Data Store connector

CyVerse's public Data Store server reads the public collections under
`/iplant/home/shared` with no sign-in. Add it as above, with these values:

- **Name:** `CyVerse Data Store (public)`
- **URL:** `https://mcp-public.cyverse.ai/mcp`
- **Authentication:** **No sign in**

It cannot reach your own home folder; Formation's `browse_data` and `upload_file` do that.

## Use it in a chat

1. Click **+** at the lower left of the message box and choose **Connectors**.
2. Switch **CyVerse Formation** on for the conversation.
3. Ask, for example:
    - *"Who am I in CyVerse, and what is in my home folder?"*
    - *"Find a JupyterLab app in the Discovery Environment and launch it for me."*
    - *"Which of my analyses are running? Stop the oldest one and save its outputs."*

Keep approval on for the tools that change things — `delete_data`, `upload_file`,
`set_metadata`, `stop_analysis`, and `launch_app_and_wait` — rather than allowing them
always; you can also block individual tools in the connector's settings under
**Customize > Connectors**. File contents Formation reads become part of the
conversation. The [Formation page](servers/formation-mcp.md#tools) lists every tool.

A connector you add on claude.ai is also available in Claude Desktop and in the Claude
mobile apps once it is connected.

## In Claude Code

If you are signed in to Claude Code with a claude.ai subscription, connectors you added on
claude.ai are available there automatically; run `/mcp` to see them[^claude-code-mcp].
Connectors are not loaded when Claude Code runs with an API key or another model
provider; register Formation directly instead (see [Claude Code](claude-code.md#hosted-servers-and-connectors)).

If Claude Code also has its own `formation` entry pointing at the same URL, Claude Code
uses its own entry and hides the connector. An older local `formation` entry from the MESA
installer does not count as the same server, so you would see both; re-run the
[installer](install.md) or remove the old entry with `claude mcp remove formation -s user`.

## Troubleshooting

| Problem | What to do |
|---|---|
| **Connect** fails or the CyVerse sign-in page shows an error | Check the URL is exactly `https://de.cyverse.org/formation/mcp`. If it is, remove the connector, add it again, and choose **Register automatically**. |
| Tools fail with authentication errors after a while | Go to **Customize > Connectors**, open **CyVerse Formation**, and connect again. |
| Formation does not answer at all | Check <https://status.cyverse.org> for a CyVerse outage. |

[^claude-connectors]: Getting started with custom connectors using remote MCP, <https://support.claude.com/en/articles/11175166-getting-started-with-custom-connectors-using-remote-mcp>.
[^claude-code-mcp]: Claude Code MCP documentation, <https://code.claude.com/docs/en/mcp>.
