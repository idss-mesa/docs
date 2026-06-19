#!/usr/bin/env bash
#
# MESA — one-liner installer for the CyVerse MESA MCP stack on Claude Code.
#
# Clones, builds, and registers four CyVerse MCP servers as local stdio
# servers in Claude Code (user scope):
#
#   * mesa-mcp         iRODS Data Store + OBO/OLS ontology + DataCite + DuckLake   (Python)
#   * irods-mcp-server reference iRODS Data Store server                           (Go)
#   * formation-mcp    CyVerse Discovery Environment (Formation API)               (Go)
#
# mesa-ducklake (the AVU metadata-history library) is installed alongside
# mesa-mcp, which imports it — it is not a standalone MCP server.
#
# Supported platforms: Linux, macOS, and Windows Subsystem for Linux (WSL).
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/idss-mesa/mesa/main/install.sh | bash
#
#   # or, after cloning this repo:
#   ./install.sh [--prefix DIR] [--no-go] [--uninstall] [--help]
#
# Environment overrides:
#   MESA_HOME          install location          (default: ~/.mesa)
#   MESA_GIT_ORG       GitHub org to clone from  (default: idss-mesa)
#   MESA_MCP_REF       branch/tag for mesa-mcp   (default: main)
#   MCP_SCOPE          claude mcp scope          (default: user)
#
# Credentials (optional — default is anonymous public CyVerse access):
#   CYVERSE_USERNAME / CYVERSE_PASSWORD   applied to mesa-mcp + formation
#   any MESA_MCP_IRODS__* / FORMATION_*   passed through verbatim to the server
#
set -euo pipefail

# ---------------------------------------------------------------------------
# Config & defaults
# ---------------------------------------------------------------------------
MESA_HOME="${MESA_HOME:-$HOME/.mesa}"
MESA_GIT_ORG="${MESA_GIT_ORG:-idss-mesa}"
MESA_MCP_REF="${MESA_MCP_REF:-main}"
MCP_SCOPE="${MCP_SCOPE:-user}"
GO_MIN_MINOR=25            # require Go >= 1.25
BUILD_GO=1
DO_UNINSTALL=0

# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------
if [ -t 1 ]; then
  C_BLUE='\033[1;34m'; C_GREEN='\033[1;32m'; C_YELLOW='\033[1;33m'; C_RED='\033[1;31m'; C_DIM='\033[2m'; C_OFF='\033[0m'
else
  C_BLUE=''; C_GREEN=''; C_YELLOW=''; C_RED=''; C_DIM=''; C_OFF=''
fi
say()  { printf "${C_BLUE}==>${C_OFF} %s\n" "$*"; }
ok()   { printf "${C_GREEN} ✓${C_OFF} %s\n" "$*"; }
warn() { printf "${C_YELLOW} !${C_OFF} %s\n" "$*" >&2; }
die()  { printf "${C_RED}error:${C_OFF} %s\n" "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

usage() {
  sed -n '2,33p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
while [ $# -gt 0 ]; do
  case "$1" in
    --prefix)    MESA_HOME="${2:?--prefix needs a directory}"; shift 2 ;;
    --prefix=*)  MESA_HOME="${1#*=}"; shift ;;
    --no-go)     BUILD_GO=0; shift ;;
    --uninstall) DO_UNINSTALL=1; shift ;;
    -h|--help)   usage ;;
    *) die "unknown argument: $1 (try --help)" ;;
  esac
done

SERVERS="mesa-mcp irods formation"   # names as registered in Claude Code

# ---------------------------------------------------------------------------
# Platform detection (Linux, macOS, WSL; reject native-Windows shells)
# ---------------------------------------------------------------------------
detect_platform() {
  local uname_s; uname_s="$(uname -s)"
  case "$uname_s" in
    Linux*)
      if grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null; then PLATFORM="wsl"; else PLATFORM="linux"; fi ;;
    Darwin*)               PLATFORM="macos" ;;
    MINGW*|MSYS*|CYGWIN*)  die "native Windows shells are not supported — please run this inside WSL (Windows Subsystem for Linux)." ;;
    *)                     die "unsupported platform: $uname_s" ;;
  esac
}

# ---------------------------------------------------------------------------
# Uninstall
# ---------------------------------------------------------------------------
uninstall() {
  say "Uninstalling MESA"
  if have claude; then
    for name in $SERVERS; do
      claude mcp remove "$name" -s "$MCP_SCOPE" >/dev/null 2>&1 && ok "removed Claude Code server: $name" || true
    done
  else
    warn "claude CLI not found — skipping MCP server removal"
  fi
  if [ -d "$MESA_HOME" ]; then
    printf "Delete %s ? [y/N] " "$MESA_HOME"; read -r reply </dev/tty || reply=""
    case "$reply" in
      y|Y) rm -rf "$MESA_HOME"; ok "removed $MESA_HOME" ;;
      *)   warn "left $MESA_HOME in place" ;;
    esac
  fi
  ok "Uninstall complete."
  exit 0
}

# ---------------------------------------------------------------------------
# Prerequisites
# ---------------------------------------------------------------------------
ensure_prereqs() {
  have git  || die "git is required but not found. Install git and re-run."
  have curl || die "curl is required but not found. Install curl and re-run."

  have claude || die "the 'claude' CLI was not found on PATH.
    MESA registers its servers via 'claude mcp add', so Claude Code must be installed first.
    See: https://docs.claude.com/en/docs/claude-code/overview"

  if ! have uv; then
    say "Installing uv (Python package manager)…"
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # uv installs to ~/.local/bin (or ~/.cargo/bin on some setups)
    export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
    have uv || die "uv installation did not land on PATH. Open a new shell and re-run, or install uv manually: https://docs.astral.sh/uv/"
    ok "uv installed"
  fi

  if [ "$BUILD_GO" -eq 1 ]; then
    if ! have go; then
      warn "Go toolchain not found — skipping the Go servers (irods-mcp-server, formation-mcp)."
      warn "Install Go >= 1.${GO_MIN_MINOR} from https://go.dev/dl/ and re-run, or pass --no-go to silence this."
      BUILD_GO=0
    else
      local minor; minor="$(go env GOVERSION 2>/dev/null | sed -E 's/^go1\.([0-9]+).*/\1/')"
      if [ -n "$minor" ] && [ "$minor" -lt "$GO_MIN_MINOR" ]; then
        warn "Go 1.$minor is older than the required 1.${GO_MIN_MINOR} — skipping Go servers. Upgrade Go and re-run."
        BUILD_GO=0
      fi
    fi
  fi
}

# ---------------------------------------------------------------------------
# Clone or update a repo from the org
# ---------------------------------------------------------------------------
clone_or_update() {
  local name="$1" ref="${2:-main}" dest="$MESA_HOME/repos/$1"
  if [ -d "$dest/.git" ]; then
    say "Updating $name ($ref)"
    git -C "$dest" fetch --quiet origin "$ref"
    git -C "$dest" checkout --quiet "$ref"
    git -C "$dest" pull --quiet --ff-only origin "$ref" || warn "could not fast-forward $name; leaving local state"
  else
    say "Cloning $name ($ref)"
    git clone --quiet --branch "$ref" "https://github.com/$MESA_GIT_ORG/$name.git" "$dest" \
      || git clone --quiet "https://github.com/$MESA_GIT_ORG/$name.git" "$dest"
  fi
}

# ---------------------------------------------------------------------------
# Python servers (mesa-ducklake + mesa-mcp) via uv
# ---------------------------------------------------------------------------
install_python() {
  say "Setting up Python environment (uv)"
  uv venv --python 3.11 "$MESA_HOME/.venv" >/dev/null
  # ducklake first so mesa-mcp resolves its in-tree dependency, then mesa-mcp.
  VIRTUAL_ENV="$MESA_HOME/.venv" uv pip install --python "$MESA_HOME/.venv/bin/python" \
    -e "$MESA_HOME/repos/mesa-ducklake" \
    -e "$MESA_HOME/repos/mesa-mcp"
  [ -x "$MESA_HOME/.venv/bin/mesa-mcp" ] || die "mesa-mcp entry point missing after install"
  ok "mesa-mcp + mesa-ducklake installed (editable)"
}

# ---------------------------------------------------------------------------
# Go servers (build from source)
# ---------------------------------------------------------------------------
install_go() {
  mkdir -p "$MESA_HOME/bin"

  say "Building irods-mcp-server (Go)"
  ( cd "$MESA_HOME/repos/irods-mcp-server" && make build )
  cp "$MESA_HOME/repos/irods-mcp-server/bin/irods-mcp-server" "$MESA_HOME/bin/irods-mcp-server"
  ok "irods-mcp-server built"

  say "Building formation-mcp (Go)"
  ( cd "$MESA_HOME/repos/formation-mcp" && CGO_ENABLED=0 go build -o "$MESA_HOME/bin/formation-mcp" ./cmd/formation-mcp )
  ok "formation-mcp built"
}

# ---------------------------------------------------------------------------
# Register servers with Claude Code (idempotent, user scope, stdio)
# ---------------------------------------------------------------------------
mcp_add() {
  # mcp_add <name> -- <command> [args...]   (env via the MCP_ENV array)
  local name="$1"; shift
  [ "$1" = "--" ] && shift
  claude mcp remove "$name" -s "$MCP_SCOPE" >/dev/null 2>&1 || true
  # ${arr[@]+...} keeps an empty array safe under `set -u` on bash 3.2 (macOS default).
  claude mcp add "$name" -s "$MCP_SCOPE" ${MCP_ENV[@]+"${MCP_ENV[@]}"} -- "$@"
  ok "registered Claude Code server: $name"
}

register_servers() {
  say "Registering servers with Claude Code (scope: $MCP_SCOPE)"

  # Build optional credential env for mesa-mcp.
  MCP_ENV=()
  [ -n "${CYVERSE_USERNAME:-}" ] && MCP_ENV+=( -e "MESA_MCP_IRODS__USER=$CYVERSE_USERNAME" )
  [ -n "${CYVERSE_PASSWORD:-}" ] && MCP_ENV+=( -e "MESA_MCP_IRODS__PASSWORD=$CYVERSE_PASSWORD" )
  # Pass through any explicitly-set MESA_MCP_* env (advanced users).
  while IFS='=' read -r k _; do
    case "$k" in MESA_MCP_*) MCP_ENV+=( -e "$k=$(printenv "$k")" );; esac
  done < <(env)
  mcp_add mesa-mcp -- "$MESA_HOME/.venv/bin/mesa-mcp" --transport stdio

  if [ "$BUILD_GO" -eq 1 ]; then
    # irods: anonymous public access via the repo's stdio config (edit it to authenticate).
    MCP_ENV=()
    mcp_add irods -- "$MESA_HOME/bin/irods-mcp-server" -c "$MESA_HOME/repos/irods-mcp-server/config-stdio.yaml"

    # formation: optional CyVerse creds via env (else uses ~/.formation-mcp.yaml or anonymous).
    MCP_ENV=()
    [ -n "${CYVERSE_USERNAME:-}" ] && MCP_ENV+=( -e "FORMATION_USERNAME=$CYVERSE_USERNAME" )
    [ -n "${CYVERSE_PASSWORD:-}" ] && MCP_ENV+=( -e "FORMATION_PASSWORD=$CYVERSE_PASSWORD" )
    while IFS='=' read -r k _; do
      case "$k" in FORMATION_*) MCP_ENV+=( -e "$k=$(printenv "$k")" );; esac
    done < <(env)
    mcp_add formation -- "$MESA_HOME/bin/formation-mcp" --transport stdio
  else
    warn "Go servers skipped — only mesa-mcp was registered."
  fi
}

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
summary() {
  echo
  ok "MESA install complete."
  echo
  printf "${C_DIM}  install dir : %s${C_OFF}\n" "$MESA_HOME"
  printf "${C_DIM}  python venv : %s${C_OFF}\n" "$MESA_HOME/.venv"
  [ "$BUILD_GO" -eq 1 ] && printf "${C_DIM}  go binaries : %s${C_OFF}\n" "$MESA_HOME/bin"
  echo
  say "Registered Claude Code servers:"
  claude mcp list 2>/dev/null || true
  echo
  say "Next steps"
  echo "  • Open Claude Code and try a tool, e.g. ask it to 'ping the CyVerse Data Store' (mesa-mcp ds_ping)."
  echo "  • By default the servers use anonymous public access (data.cyverse.org, zone iplant)."
  echo "  • To authenticate, re-run with CYVERSE_USERNAME / CYVERSE_PASSWORD set, or edit"
  echo "    $MESA_HOME/repos/irods-mcp-server/config-stdio.yaml and your ~/.irods/irods_environment.json."
  echo "  • Docs: https://idss-mesa.github.io/mesa/   •   Uninstall: $0 --uninstall"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
  detect_platform
  [ "$DO_UNINSTALL" -eq 1 ] && uninstall

  say "MESA installer  (platform: $PLATFORM, prefix: $MESA_HOME)"
  ensure_prereqs
  mkdir -p "$MESA_HOME/repos" "$MESA_HOME/bin"

  clone_or_update mesa-ducklake main
  clone_or_update mesa-mcp "$MESA_MCP_REF"
  if [ "$BUILD_GO" -eq 1 ]; then
    clone_or_update irods-mcp-server main
    clone_or_update formation-mcp main
  fi

  install_python
  [ "$BUILD_GO" -eq 1 ] && install_go

  register_servers
  summary
}

main "$@"
