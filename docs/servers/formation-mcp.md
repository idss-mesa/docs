---
type: MCP Server
title: Formation (hosted)
description: CyVerse's hosted MCP server for the Discovery Environment at https://de.cyverse.org/formation/mcp — launch apps, manage analyses, and work with the Data Store from claude.ai or Claude Code; Codex, OpenCode, and Antigravity can be set up too, but their sign-in is not yet confirmed.
tags:
  - formation
  - discovery-environment
  - hosted
  - remote-mcp
  - oauth
  - connector
generated:
  by: "claude-code/2.1.294"
  at: "2026-10-08T00:00:00Z"
sources:
  - id: formation
    resource: "https://github.com/cyverse-de/formation"
    title: "Formation source repository (README and landing page)"
    author: "team:cyverse-de"
  - id: claude-connectors
    resource: "https://support.claude.com/en/articles/11175166-getting-started-with-custom-connectors-using-remote-mcp"
    title: "Getting started with custom connectors using remote MCP"
    author: "team:anthropic"
  - id: claude-code-mcp
    resource: "https://code.claude.com/docs/en/mcp"
    title: "Claude Code MCP documentation"
    author: "team:anthropic"
  - id: install-sh
    resource: "https://github.com/idss-mesa/docs/blob/main/install.sh"
    title: "MESA install.sh"
    author: "team:idss-mesa"
  - id: mesa-apps
    resource: "https://github.com/idss-mesa/jupyterlab/tree/main/latest/configs"
    title: "MESA app images: per-agent MCP configs"
    author: "team:idss-mesa"
status: stable
stale_after: "2027-04-08T00:00:00Z"
---

# Formation (hosted)

**Endpoint:** <https://de.cyverse.org/formation/mcp> · **Run by:** CyVerse ·
**Source:** [cyverse-de/formation](https://github.com/cyverse-de/formation) ·
**Registered as:** `formation`

Formation is the CyVerse Discovery Environment's own MCP server[^formation]. CyVerse
hosts it, so there is nothing to install or build: point your client at the URL and sign
in with your CyVerse account. Your agent can then find and launch Discovery Environment
apps, follow and stop analyses, and read, write, and describe files in the CyVerse Data
Store, always as **you** and with your own permissions.

CyVerse documents it for Claude Code and as a **custom connector** on claude.ai and in
Claude Desktop. You can register it in every client MESA supports, but whether Codex,
OpenCode, and Antigravity can complete the CyVerse sign-in is not yet confirmed (see
[Troubleshooting](#troubleshooting)).

!!! tip "Enter the URL exactly"
    Use `https://de.cyverse.org/formation/mcp`, with `https` and no trailing slash. The
    sign-in checks that the address matches exactly.

## Add it to your client

=== "claude.ai & Claude Desktop"

    1. Go to **Customize > Connectors**, click **+ Add**, then **Add custom connector**.
    2. Name it `CyVerse Formation`, paste `https://de.cyverse.org/formation/mcp`, and
       click **Continue**.
    3. Review the detected authentication and click **Continue**. Under **Authentication**
       choose **Sign in now**, under **OAuth client** choose **Register automatically**
       (not the default **Use Claude's published identity**), and click **Add**.
    4. Sign in with your CyVerse account when asked.

    On Team and Enterprise plans an owner adds the connector once and each member clicks
    **Connect**. Step by step: [claude.ai and Claude Desktop](../claude-ai.md).

=== "Claude Code"

    ```bash
    claude mcp add --transport http --scope user formation https://de.cyverse.org/formation/mcp
    ```

    Then, inside Claude Code, run `/mcp`, pick **formation**, and choose
    **Authenticate**; or from a shell run `claude mcp login formation` (add
    `--no-browser` on a remote machine and paste the redirect URL back)[^claude-code-mcp].

    If you are signed in to Claude Code with a claude.ai subscription, a Formation
    connector you added on claude.ai is available in Claude Code automatically.

=== "Codex"

    In `~/.codex/config.toml`:

    ```toml
    [mcp_servers.formation]
    url = "https://de.cyverse.org/formation/mcp"
    tool_timeout_sec = 600   # launches can wait up to 9 minutes
    ```

    Then sign in with `codex mcp login formation`. On a remote machine add `--no-browser`
    (Codex 0.156 or newer): Codex prints the sign-in address, and you paste back the
    address your browser lands on.

    Or run `codex mcp add formation --url https://de.cyverse.org/formation/mcp`, which
    starts the sign-in straight away, and then add `tool_timeout_sec = 600` to the
    `[mcp_servers.formation]` table it wrote. The command sets no timeout, and Codex's
    default (300 seconds from Codex 0.141, 60 or 120 seconds before) can cut a launch
    off.

    Needs Codex 0.77 or newer.

=== "OpenCode"

    In `~/.config/opencode/opencode.json`:

    ```json
    {
      "mcp": {
        "formation": {
          "type": "remote",
          "url": "https://de.cyverse.org/formation/mcp",
          "enabled": true
        }
      }
    }
    ```

    Then sign in with `opencode mcp auth formation`; `opencode mcp auth list` shows the
    status. OpenCode waits for the browser to come back to its own port 19876, so on a
    remote machine, such as a MESA app, the sign-in cannot finish: use Claude Code or
    Codex with `--no-browser` there.

=== "Antigravity"

    In `$HOME/.gemini/config/mcp_config.json` (note `serverUrl`, not `url`):

    ```json
    {
      "mcpServers": {
        "formation": {
          "serverUrl": "https://de.cyverse.org/formation/mcp"
        }
      }
    }
    ```

    Then refresh the IDE's MCP servers panel, or run `/mcp` in `agy`. The MESA team has
    not tested Antigravity's sign-in to Formation; if it fails, use another client.

=== "MESA installer and apps"

    The [MESA installer](../install.md) registers Formation by URL with every client it
    detects; then sign in once in each client as shown in the other tabs. Re-running the
    installer keeps those sign-ins.

    The [MESA featured apps](../apps/agents.md) come with Formation already registered
    for every agent, but an app's home folder is not kept between analyses, so sign in
    again in each new analysis as described in
    [Sign in to Formation](../apps/agents.md#sign-in-to-formation) (Claude Code and Codex
    with `--no-browser`). OpenCode and Goose cannot complete the sign-in in the apps.

## Sign in

Until you sign in, the client lists `formation` as needing authentication. Run its
sign-in command (in your client's tab above, or the list below), which opens the CyVerse
sign-in page in your browser. Log in with your CyVerse username and password and you are
sent back to the client. Behind
this is standard MCP sign-in: OAuth 2.1 with PKCE against CyVerse's Keycloak, and
automatic client registration, so there is no API key or client ID to set up[^formation].

- No password, environment variable, `~/.irods` file, or `cyverse-login` is involved.
- Sign in, and later sign in again if calls fail with authentication errors, with
  `/mcp` or `claude mcp login formation`, `codex mcp login formation`,
  `opencode mcp auth formation`, or **Connect** on claude.ai. The client stores the
  sign-in and refreshes it.
- Sign in with a CyVerse user account. Keycloak service-account (client-credentials)
  tokens are refused.
- No CyVerse account yet? Register for free at <https://user.cyverse.org>.

## Tools

| Tool | What it does |
|---|---|
| `whoami` | Your username, name, email, and Data Store paths: home folder, trash, and default analysis output folder. Agents call it first instead of guessing paths. |
| `list_apps` | Lists the Discovery Environment apps you can use, optionally filtered by name |
| `get_app_parameters` | An app's parameters, their types, and defaults |
| `launch_app_and_wait` | Launches an app. For an interactive (VICE) app it waits until the app's address answers and returns it |
| `get_analysis_status` | An analysis's status, and whether its app address is ready |
| `list_running_analyses` | Your running analyses |
| `stop_analysis` | Stops an analysis, saving its outputs unless asked not to |
| `browse_data` | Lists a Data Store folder or reads a text file |
| `create_directory` | Creates a folder, optionally with metadata |
| `upload_file` | Writes text to a file in the Data Store, optionally with metadata |
| `set_metadata` | Adds or replaces AVU metadata on a file or folder |
| `delete_data` | Moves a file or folder to your Data Store trash; `dry_run` previews it |

## Good to know

- **Launching apps.** `launch_app_and_wait` waits up to 5 minutes by default and never
  more than 9 minutes. Unless the agent passes `overall_job_type`, the tool first checks
  for required parameters the request did not supply and lists them instead of
  launching, so the agent can ask you; with `overall_job_type` it launches directly.
  Batch (non-interactive) jobs return as soon as they are submitted; check them with
  `get_analysis_status`.
- **Text only.** `browse_data` returns file contents into the conversation, so whatever it
  reads is sent to your model provider. It reads at most 1 MiB at a time and continues
  with `offset` and `limit`; images, archives, and other binary files cannot be read.
- **Deleting.** `delete_data` moves items to your Data Store trash (its own description
  says deletions are permanent; they are not). Non-empty folders need `recurse`.
- **Metadata.** `set_metadata` with `replace` replaces only the attributes you set and
  keeps the others. CyVerse system attributes (names starting with `ipc`) are hidden and
  cannot be written.
- **Everything is yours.** Analyses Formation launches appear in the Discovery
  Environment and on the MESA Portal's [Analyses](../portal/analyses.md) page, and output
  goes to your `analyses` folder.
- **Approving tools.** The tools carry no read-only or destructive hints, so your client
  treats them all alike. Approve `delete_data`, `upload_file`, `set_metadata`,
  `stop_analysis`, and `launch_app_and_wait` call by call rather than "always".

## Moving from the local formation-mcp

Earlier versions of the MESA installer built [formation-mcp](https://github.com/idss-mesa/formation-mcp)
and registered it as a local stdio server that called Formation's REST API. CyVerse
replaced that API with this hosted MCP server in mid-2026, so the local server no longer
works: it exits with `Configuration error: FORMATION_BASE_URL is required`, or its tools
fail with `login failed with status 404`.

Re-run the installer and it replaces the old entry with the hosted one in every client
and deletes `~/.mesa/bin/formation-mcp`:

```bash
curl -fsSL https://raw.githubusercontent.com/idss-mesa/docs/main/install.sh | bash
```

To switch by hand instead, remove the old entry first, then add the hosted one as shown
above:

| Client | Remove the old entry |
|---|---|
| Claude Code | `claude mcp remove formation -s user` (adding again at user scope fails while the old entry exists) |
| Codex | `codex mcp remove formation` |
| OpenCode | delete `formation` from the `mcp` key of `~/.config/opencode/opencode.json` |
| Antigravity | delete `formation` from `mcpServers` in `$HOME/.gemini/config/mcp_config.json` |

`~/.formation-mcp.yaml` and the `FORMATION_*` environment variables are no longer used;
you can delete them, along with `~/.mesa/repos/formation-mcp`.

## Troubleshooting

| Problem | What to do |
|---|---|
| **Needs authentication** in `claude mcp list` or `/mcp` | Expected until you sign in: run `/mcp` or `claude mcp login formation`. |
| `formation` appears twice in Claude Code | You have the old local entry and a claude.ai connector. Remove the local one: `claude mcp remove formation -s user`. |
| The CyVerse page says `Invalid parameter: redirect_uri` | CyVerse does not yet accept that client's sign-in callback. CyVerse's documented callbacks are claude.ai's and `http://localhost…` (Claude Code); Codex and OpenCode call back to `http://127.0.0.1…`. Report it to [CyVerse support](https://user.cyverse.org/support) and use Claude Code or the claude.ai connector meanwhile. |
| `authentication error` (HTTP 500) | CyVerse's sign-in service is unreachable from Formation; try again later and check <https://status.cyverse.org>. |
| A launch times out in Codex | Add `tool_timeout_sec = 600` to `[mcp_servers.formation]` in `~/.codex/config.toml`. |
| `codex mcp login` says `unexpected argument '--no-browser'` | Your Codex is older than 0.156. Update it with `npm install -g @openai/codex@latest`. |

More in [Troubleshooting](../troubleshooting.md#formation-sign-in-and-connection).

[^formation]: Formation README and landing page, <https://github.com/cyverse-de/formation>.
[^claude-code-mcp]: Claude Code MCP documentation, <https://code.claude.com/docs/en/mcp>.
