# irods-mcp-server

**Repo:** [idss-mesa/irods-mcp-server](https://github.com/idss-mesa/irods-mcp-server) · **Language:** Go · **Registered as:** `irods`

The reference MCP server for the CyVerse Data Store (iRODS). It provides the canonical
`ds_*` tool surface that [mesa-mcp](mesa-mcp.md) is compatible with. Use it on its own when
you want a lightweight, dependency-free Go binary for iRODS access.

## How MESA runs it

The installer builds it from source and registers the stdio binary against the repo's
anonymous-access config:

```bash
( cd ~/.mesa/repos/irods-mcp-server && make build )      # -> bin/irods-mcp-server
claude mcp add irods -s user -- ~/.mesa/bin/irods-mcp-server \
  -c ~/.mesa/repos/irods-mcp-server/config-stdio.yaml
```

`make build` produces a static (`CGO_ENABLED=0`) binary; Go ≥ 1.25 is required. Pass
`--no-go` to the installer to skip this server (and `formation`).

## Capabilities

Anonymous access to public data under `/iplant/home/shared`, or authenticated access with
iRODS credentials. Supports both **stdio** (local, what MESA uses) and **HTTP/SSE**
(remote) transports. A published Docker image, `cyverse/irods-mcp-server`, is also available
if you'd rather run it in a container than build it.

## Authentication

Edit `config-stdio.yaml` to switch from anonymous to a named account — see
[Credentials](../credentials.md#mesa-mcp-irods-native-irods-auth). The config keys are
`irods_host`, `irods_zone_name`, `irods_user_name`, `irods_user_password`.
