# Credentials

By default every MESA server connects **anonymously** to public CyVerse infrastructure
(`data.cyverse.org`, zone `iplant`, user `anonymous`). That is enough to read public
collections and browse the Discovery Environment app catalog. To write metadata, access
private data, or launch apps as yourself, authenticate.

## Quickest path — env vars at install time

```bash
CYVERSE_USERNAME=you CYVERSE_PASSWORD='••••••' \
  curl -fsSL https://raw.githubusercontent.com/idss-mesa/mesa/main/install.sh | bash
```

The installer threads these into the Claude Code registration as:

- `mesa-mcp` → `MESA_MCP_IRODS__USER`, `MESA_MCP_IRODS__PASSWORD`
- `formation` → `FORMATION_USERNAME`, `FORMATION_PASSWORD`

!!! warning "Where the password ends up"
    With user/project scope, these land in your Claude Code config file in plaintext. Prefer
    the `~/.irods` method below if you don't want the password stored there, and never commit
    a `project`-scope `.mcp.json` containing secrets.

## mesa-mcp & irods — native iRODS auth

Both iRODS servers honor a standard iRODS environment. If you use the CyVerse
[iCommands](https://learning.cyverse.org/ds/icommands/), run `iinit` once to create:

```
~/.irods/irods_environment.json   # host, zone, user
~/.irods/.irodsA                  # scrambled password
```

`mesa-mcp` reads these automatically in stdio mode — no env vars needed.

For `irods-mcp-server`, edit its stdio config to add credentials:

```yaml
# ~/.mesa/repos/irods-mcp-server/config-stdio.yaml
irods_host: data.cyverse.org
irods_zone_name: iplant
irods_user_name: you
irods_user_password: ••••••
```

## mesa-mcp — full env reference

`mesa-mcp` uses `MESA_MCP_` env vars (double underscore for nesting). The most useful:

| Variable | Default | Meaning |
|---|---|---|
| `MESA_MCP_IRODS__HOST` | `data.cyverse.org` | iRODS host |
| `MESA_MCP_IRODS__ZONE` | `iplant` | iRODS zone |
| `MESA_MCP_IRODS__USER` | `anonymous` | username |
| `MESA_MCP_IRODS__PASSWORD` | — | password |
| `MESA_MCP_DUCKLAKE__CATALOG_DSN` | — | DuckLake catalog (`duckdb:///path` or `postgresql://…`); blank disables history |

Any `MESA_MCP_*` variable set in your shell at install time is passed through to the server.
The full list is in [`mesa-mcp/.env.example`](https://github.com/idss-mesa/mesa-mcp/blob/main/.env.example).

## formation — Discovery Environment auth

`formation-mcp` accepts a username/password or a JWT, via env vars or `~/.formation-mcp.yaml`:

```yaml
# ~/.formation-mcp.yaml
base_url: https://de.cyverse.org/formation
username: you
password: ••••••
```

Env equivalents: `FORMATION_BASE_URL`, `FORMATION_USERNAME`, `FORMATION_PASSWORD`, or
`FORMATION_TOKEN`.

## DataCite (optional)

DataCite DOI tools in `mesa-mcp` only need credentials when you mint/publish DOIs. See the
[mesa-mcp docs](https://github.com/idss-mesa/mesa-mcp) for the DataCite configuration.
