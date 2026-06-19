# Troubleshooting

## `the 'claude' CLI was not found`

The installer registers servers with `claude mcp add`, so Claude Code must be installed and
on your `PATH` first. Install it from the
[Claude Code docs](https://docs.claude.com/en/docs/claude-code/overview), open a new shell,
and re-run.

## `native Windows shells are not supported`

You're running in PowerShell, `cmd`, Git Bash, or MSYS. Install
[WSL](https://learn.microsoft.com/windows/wsl/install), open an Ubuntu (or similar) shell,
and run the one-liner there. The installer auto-detects WSL and treats it as Linux.

## Go servers were skipped

If you see *"Go toolchain not found"* or *"Go 1.x is older than the required 1.25"*, only
`mesa-mcp` was installed. Install [Go ≥ 1.25](https://go.dev/dl/) and re-run, or pass
`--no-go` if you only want `mesa-mcp`.

## `uv` not found after install

The installer fetches `uv` from astral.sh into `~/.local/bin`. If a fresh shell still can't
find it, add that directory to your `PATH`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

then re-run the installer.

## `claude mcp list` shows "Needs authentication" or "Failed to connect"

- **Needs authentication** on a *hosted* (`https://…`) server is expected until you log in;
  it does not affect the local stdio servers MESA installs.
- **Failed to connect** on a local server usually means the binary moved or the venv broke.
  Re-run the installer to rebuild and re-register.

## Conflicting scopes

A warning that a server is *"defined in multiple scopes"* means the same name is registered
more than once (e.g. an older manual entry plus MESA's). Remove the ones you don't want:

```bash
claude mcp remove mesa-mcp -s user
claude mcp remove mesa-mcp -s local
```

## iRODS calls return permission errors

Anonymous access is read-only on public collections. To write AVUs or read private data,
[authenticate](credentials.md) — either re-run with `CYVERSE_USERNAME` / `CYVERSE_PASSWORD`,
or run `iinit` to set up `~/.irods`.

## `grep: /etc/os-release: No such file or directory`

Harmless. It comes from the `irods-mcp-server` Makefile probing the OS on macOS; the build
still succeeds.

## Starting over

```bash
curl -fsSL https://raw.githubusercontent.com/idss-mesa/mesa/main/install.sh | bash -s -- --uninstall
```

removes the three servers from Claude Code and (after confirmation) deletes `~/.mesa`.
