#!/usr/bin/env bash
#
# MESA — one-liner installer for the CyVerse MESA MCP stack.
#
# Clones, builds, and registers three CyVerse MCP servers as local stdio
# servers with every supported agent client found on this machine:
#
#   clients:  Claude Code (claude) · OpenAI Codex CLI (codex)
#             Google Antigravity (agy / IDE) · OpenCode (opencode)
#
#   servers:
#   * mesa-mcp    iRODS Data Store + OBO/OLS ontology + DataCite + DuckLake   (Python)
#   * irods       reference iRODS Data Store server (irods-mcp-server)        (Go)
#   * formation   CyVerse Discovery Environment (Formation API)               (Go)
#
# mesa-ducklake (the AVU metadata-history library) is installed alongside
# mesa-mcp, which imports it — it is not a standalone MCP server.
#
# Supported platforms: Linux, macOS, and Windows Subsystem for Linux (WSL).
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/idss-mesa/docs/main/install.sh | bash
#
#   # or, after cloning this repo:
#   ./install.sh [--prefix DIR] [--for CLIENTS] [--no-go] [--uninstall] [--help]
#
#   --for CLIENTS   comma-separated subset of: claude,codex,antigravity,opencode
#                   (default: every supported client detected on this machine)
#
# Environment overrides:
#   MESA_HOME          install location          (default: ~/.mesa)
#   MESA_GIT_ORG       GitHub org to clone from  (default: idss-mesa)
#   MESA_MCP_REF       branch/tag for mesa-mcp   (default: main)
#   MESA_CLIENTS       same as --for             (default: auto-detect)
#   MCP_SCOPE          Claude Code scope only    (default: user)
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
MCP_SCOPE="${MCP_SCOPE:-user}"            # Claude Code only
CLIENTS_ALL="claude codex antigravity opencode"
CLIENT_FILTER="${MESA_CLIENTS:-}"         # --for overrides this
CLIENTS_SELECTED=""                       # resolved by select_clients()
OPENCODE_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/opencode/opencode.json"
ANTIGRAVITY_WRITTEN=""                    # config paths written; summary reads it
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

# NB: keep the sed range in sync with the header comment block above
# (first '#' line through the last '#' line before `set -euo pipefail`).
# When piped (curl … | bash -s -- --help) $0 is the bash binary, not this
# script, so fall back to a compact usage text.
usage() {
  if [ -r "$0" ] && head -1 "$0" 2>/dev/null | grep -q '^#!' ; then
    sed -n '2,40p' "$0" | sed 's/^# \{0,1\}//'
  else
    cat <<'EOF'
MESA — one-liner installer for the CyVerse MESA MCP stack.

Usage:
  install.sh [--prefix DIR] [--for CLIENTS] [--no-go] [--uninstall] [--help]

  --for CLIENTS   comma-separated subset of: claude,codex,antigravity,opencode
                  (default: every supported client detected on this machine)

Environment overrides: MESA_HOME, MESA_GIT_ORG, MESA_MCP_REF, MESA_CLIENTS,
MCP_SCOPE, CYVERSE_USERNAME / CYVERSE_PASSWORD.

Docs: https://idss-mesa.github.io/docs/
EOF
  fi
  exit 0
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
while [ $# -gt 0 ]; do
  case "$1" in
    --prefix)    MESA_HOME="${2:?--prefix needs a directory}"; shift 2 ;;
    --prefix=*)  MESA_HOME="${1#*=}"; [ -n "$MESA_HOME" ] || die "--prefix needs a directory"; shift ;;
    --for)       CLIENT_FILTER="${2:?--for needs a comma-separated client list}"; shift 2 ;;
    --for=*)     CLIENT_FILTER="${1#*=}"; [ -n "$CLIENT_FILTER" ] || die "--for needs a comma-separated client list"; shift ;;
    --no-go)     BUILD_GO=0; shift ;;
    --uninstall) DO_UNINSTALL=1; shift ;;
    -h|--help)   usage ;;
    *) die "unknown argument: $1 (try --help)" ;;
  esac
done

# The JSON-config clients (Antigravity, OpenCode) do not expand ~ or $HOME,
# so MESA_HOME must be absolute before it is written into any config file.
case "$MESA_HOME" in /*) ;; *) MESA_HOME="$PWD/${MESA_HOME#./}" ;; esac

SERVERS="mesa-mcp irods formation"   # names as registered with each client

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
# Agent-client detection & selection
# ---------------------------------------------------------------------------
client_detected() {
  case "$1" in
    claude)      have claude ;;
    codex)       have codex ;;
    antigravity) have agy \
                   || [ -d "/Applications/Antigravity.app" ] \
                   || [ -d "/Applications/Antigravity IDE.app" ] \
                   || [ -d "$HOME/.gemini/config" ] \
                   || [ -d "$HOME/.gemini/antigravity" ] \
                   || [ -d "$HOME/.gemini/antigravity-cli" ] ;;
    opencode)    have opencode ;;
    *)           return 1 ;;
  esac
}

client_hint() {   # install link, used in error messages
  case "$1" in
    claude)      echo "https://docs.claude.com/en/docs/claude-code/overview" ;;
    codex)       echo "https://developers.openai.com/codex/cli/" ;;
    antigravity) echo "https://antigravity.google/" ;;
    opencode)    echo "https://opencode.ai/docs/" ;;
  esac
}

antigravity_candidate_paths() {   # unified (Antigravity 2.0) path first, then legacy
  printf '%s\n' \
    "$HOME/.gemini/config/mcp_config.json" \
    "$HOME/.gemini/antigravity/mcp_config.json" \
    "$HOME/.gemini/antigravity-cli/mcp_config.json"
}

select_clients() {
  CLIENTS_SELECTED=""
  local c k known
  if [ -n "$CLIENT_FILTER" ]; then
    local list; list="$(printf '%s' "$CLIENT_FILTER" | tr '[:upper:]' '[:lower:]' | tr ',' ' ')"
    for c in $list; do
      known=0
      for k in $CLIENTS_ALL; do [ "$c" = "$k" ] && known=1; done
      if [ "$known" -ne 1 ]; then
        die "unknown client '$c' in --for/MESA_CLIENTS (valid: claude, codex, antigravity, opencode)"
      fi
      if client_detected "$c"; then
        CLIENTS_SELECTED="$CLIENTS_SELECTED $c"
      elif [ "$DO_UNINSTALL" -eq 1 ]; then
        warn "client '$c' not detected — skipping"
      else
        die "client '$c' was requested via --for but is not installed. See: $(client_hint "$c")"
      fi
    done
  else
    for c in $CLIENTS_ALL; do
      if client_detected "$c"; then CLIENTS_SELECTED="$CLIENTS_SELECTED $c"; fi
    done
  fi
  CLIENTS_SELECTED="${CLIENTS_SELECTED# }"
}

# ---------------------------------------------------------------------------
# JSON config helpers (Antigravity + OpenCode have no scriptable CLI)
# ---------------------------------------------------------------------------
mesa_python() {
  if [ -x "$MESA_HOME/.venv/bin/python" ]; then printf '%s\n' "$MESA_HOME/.venv/bin/python"
  elif have python3; then printf 'python3\n'
  else return 1
  fi
}

json_add_server() {   # json_add_server <file> <flavor:antigravity|opencode> <name> <cmd> [args...]
  # env pairs travel via the MCP_ENV array; they always contain '=' so the
  # literal '--' below unambiguously separates them from the command argv.
  local file="$1" flavor="$2" name="$3"; shift 3
  local py; py="$(mesa_python)" || die "python is required to edit $file (install python3 and re-run)"
  "$py" - "$file" "$flavor" "$name" ${MCP_ENV[@]+"${MCP_ENV[@]}"} -- "$@" <<'PY'
import json, os, sys

path, flavor, name = sys.argv[1], sys.argv[2], sys.argv[3]
rest = sys.argv[4:]
sep = rest.index('--')
env = dict(kv.partition('=')[::2] for kv in rest[:sep])
cmd = rest[sep + 1:]

data = {}
try:
    with open(path) as f:
        text = f.read().strip()             # 0-byte / whitespace-only file == absent
    if text:
        data = json.loads(text)
except FileNotFoundError:
    pass
except json.JSONDecodeError as e:
    sys.exit(f"error: {path} contains invalid JSON ({e}); fix or remove it and re-run")
if not isinstance(data, dict):
    sys.exit(f"error: {path} top level is not a JSON object; fix it and re-run")

if flavor == 'antigravity':
    entry = {'command': cmd[0], 'args': cmd[1:]}   # command: single absolute-path string
    if env:
        entry['env'] = env
    data.setdefault('mcpServers', {})[name] = entry
else:  # opencode
    entry = {'type': 'local', 'command': cmd, 'enabled': True}   # command: full argv array
    if env:
        entry['environment'] = env
    data.setdefault('mcp', {})[name] = entry

d = os.path.dirname(path)
if d:
    os.makedirs(d, exist_ok=True)
tmp = f"{path}.mesa-tmp.{os.getpid()}"
with open(tmp, 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
os.replace(tmp, path)
PY
}

json_remove_server() {   # json_remove_server <file> <flavor> <name>  (never fails the caller)
  local file="$1" flavor="$2" name="$3" py
  [ -e "$file" ] || return 0
  py="$(mesa_python)" || { warn "no python found — manually remove '$name' from $file"; return 0; }
  "$py" - "$file" "$flavor" "$name" <<'PY' || warn "could not update $file — remove '$name' manually"
import json, os, sys
path, flavor, name = sys.argv[1], sys.argv[2], sys.argv[3]
key = 'mcpServers' if flavor == 'antigravity' else 'mcp'
try:
    with open(path) as f:
        text = f.read().strip()
except FileNotFoundError:
    sys.exit(0)
if not text:
    sys.exit(0)
try:
    data = json.loads(text)
except json.JSONDecodeError:
    print(f"warning: {path} is not valid JSON; skipping", file=sys.stderr)
    sys.exit(0)
if not (isinstance(data, dict) and name in data.get(key, {})):
    sys.exit(0)
del data[key][name]
tmp = f"{path}.mesa-tmp.{os.getpid()}"
with open(tmp, 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
os.replace(tmp, path)
PY
  return 0
}

# ---------------------------------------------------------------------------
# Uninstall (sweeps by tool/file presence so stale configs get cleaned too)
# ---------------------------------------------------------------------------
uninstall() {
  say "Uninstalling MESA"
  local clients="$CLIENTS_ALL" c name f
  [ -n "$CLIENT_FILTER" ] && clients="$CLIENTS_SELECTED"
  [ -n "$clients" ] || warn "no clients selected — skipping MCP unregistration"
  for c in $clients; do
    case "$c" in
      claude)
        if have claude; then
          for name in $SERVERS; do
            claude mcp remove "$name" -s "$MCP_SCOPE" >/dev/null 2>&1 && ok "claude: removed $name" || true
          done
        fi ;;
      codex)
        if have codex; then
          for name in $SERVERS; do   # serial on purpose: config.toml read-modify-write
            codex mcp remove "$name" >/dev/null 2>&1 && ok "codex: removed $name" || true
          done
        fi ;;
      antigravity)
        while IFS= read -r f; do
          if [ -e "$f" ]; then
            for name in $SERVERS; do json_remove_server "$f" antigravity "$name"; done
            ok "antigravity: cleaned $f"
          fi
        done < <(antigravity_candidate_paths) ;;
      opencode)
        if [ -e "$OPENCODE_CONFIG" ]; then
          for name in $SERVERS; do json_remove_server "$OPENCODE_CONFIG" opencode "$name"; done
          ok "opencode: cleaned $OPENCODE_CONFIG"
        fi ;;
    esac
  done
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

  if [ -z "$CLIENTS_SELECTED" ]; then
    die "no supported agent client found.
    MESA registers its MCP servers with at least one of:
      * Claude Code           (claude CLI)      https://docs.claude.com/en/docs/claude-code/overview
      * OpenAI Codex CLI      (codex)           https://developers.openai.com/codex/cli/
      * Google Antigravity    (agy / IDE)       https://antigravity.google/
      * OpenCode              (opencode)        https://opencode.ai/docs/
    Install one and re-run (or use --for to name a specific client)."
  fi

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
  # UV_VENV_CLEAR: newer uv refuses to replace an existing venv without it;
  # older uv clears by default and ignores the variable — keeps re-runs idempotent.
  UV_VENV_CLEAR=1 uv venv --python 3.11 "$MESA_HOME/.venv" >/dev/null
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
# Per-server env (bare K=V pairs; each client adapter converts as needed)
# ---------------------------------------------------------------------------
build_env_mesa_mcp() {
  MCP_ENV=()
  [ -n "${CYVERSE_USERNAME:-}" ] && MCP_ENV+=( "MESA_MCP_IRODS__USER=$CYVERSE_USERNAME" )
  [ -n "${CYVERSE_PASSWORD:-}" ] && MCP_ENV+=( "MESA_MCP_IRODS__PASSWORD=$CYVERSE_PASSWORD" )
  # Pass through any explicitly-set MESA_MCP_* env (advanced users); appended
  # after the CYVERSE-derived pairs so explicit vars win in every client.
  while IFS='=' read -r k _; do
    case "$k" in MESA_MCP_*) MCP_ENV+=( "$k=$(printenv "$k")" );; esac
  done < <(env)
}

build_env_formation() {
  MCP_ENV=()
  [ -n "${CYVERSE_USERNAME:-}" ] && MCP_ENV+=( "FORMATION_USERNAME=$CYVERSE_USERNAME" )
  [ -n "${CYVERSE_PASSWORD:-}" ] && MCP_ENV+=( "FORMATION_PASSWORD=$CYVERSE_PASSWORD" )
  while IFS='=' read -r k _; do
    case "$k" in FORMATION_*) MCP_ENV+=( "$k=$(printenv "$k")" );; esac
  done < <(env)
}

env_flags() {   # env_flags <flag>  ->  FLAGGED_ENV=( <flag> K=V ... )
  local flag="$1" kv
  FLAGGED_ENV=()
  for kv in ${MCP_ENV[@]+"${MCP_ENV[@]}"}; do FLAGGED_ENV+=( "$flag" "$kv" ); done
}

# ---------------------------------------------------------------------------
# Per-client registration adapters (<name> <cmd> [args...], env via MCP_ENV)
# ---------------------------------------------------------------------------
add_claude() {
  local name="$1"; shift
  env_flags -e
  claude mcp remove "$name" -s "$MCP_SCOPE" >/dev/null 2>&1 || true
  claude mcp add "$name" -s "$MCP_SCOPE" ${FLAGGED_ENV[@]+"${FLAGGED_ENV[@]}"} -- "$@"
  ok "claude: registered $name (scope: $MCP_SCOPE)"
}

add_codex() {
  # Always remove first (re-add idempotency is not guaranteed); calls stay
  # strictly serial — codex does a read-modify-write on config.toml.
  local name="$1"; shift
  env_flags --env
  codex mcp remove "$name" >/dev/null 2>&1 || true
  codex mcp add "$name" ${FLAGGED_ENV[@]+"${FLAGGED_ENV[@]}"} -- "$@"
  ok "codex: registered $name"
}

add_antigravity() {
  # No non-interactive CLI: edit every existing candidate config, else create
  # the Antigravity 2.0 unified path.
  local name="$1"; shift
  local wrote=0 f
  while IFS= read -r f; do
    if [ -e "$f" ]; then
      json_add_server "$f" antigravity "$name" "$@"
      wrote=1
      case " $ANTIGRAVITY_WRITTEN " in *" $f "*) ;; *) ANTIGRAVITY_WRITTEN="$ANTIGRAVITY_WRITTEN $f" ;; esac
    fi
  done < <(antigravity_candidate_paths)
  if [ "$wrote" -eq 0 ]; then
    f="$HOME/.gemini/config/mcp_config.json"
    json_add_server "$f" antigravity "$name" "$@"
    ANTIGRAVITY_WRITTEN=" $f"
  fi
  ok "antigravity: registered $name"
}

add_opencode() {
  # `opencode mcp add` is interactive-only; the dict-key overwrite in the
  # global config is the idempotent registration.
  local name="$1"; shift
  json_add_server "$OPENCODE_CONFIG" opencode "$name" "$@"
  ok "opencode: registered $name"
}

# ---------------------------------------------------------------------------
# Registration orchestration
# ---------------------------------------------------------------------------
register_with() {   # register_with <add-function>
  local add="$1"
  build_env_mesa_mcp
  "$add" mesa-mcp "$MESA_HOME/.venv/bin/mesa-mcp" --transport stdio
  if [ "$BUILD_GO" -eq 1 ]; then
    # irods: anonymous public access via the repo's stdio config (edit it to authenticate).
    MCP_ENV=()
    "$add" irods "$MESA_HOME/bin/irods-mcp-server" -c "$MESA_HOME/repos/irods-mcp-server/config-stdio.yaml"
    # formation: optional CyVerse creds via env (else uses ~/.formation-mcp.yaml or anonymous).
    build_env_formation
    "$add" formation "$MESA_HOME/bin/formation-mcp" --transport stdio
  else
    warn "Go servers skipped — only mesa-mcp was registered."
  fi
}

register_servers() {
  local client
  for client in $CLIENTS_SELECTED; do
    say "Registering servers with $client"
    register_with "add_$client"
  done
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
  printf "${C_DIM}  clients     : %s${C_OFF}\n" "$CLIENTS_SELECTED"
  echo
  local client f
  for client in $CLIENTS_SELECTED; do
    case "$client" in
      claude)
        say "Claude Code (scope: $MCP_SCOPE):"
        claude mcp list 2>/dev/null || true ;;
      codex)
        say "Codex CLI: servers written to ~/.codex/config.toml"
        echo "    verify with: codex mcp list   (restart any running codex session)" ;;
      antigravity)
        say "Antigravity: servers written to:"
        for f in $ANTIGRAVITY_WRITTEN; do echo "    $f"; done
        echo "    refresh the IDE's MCP panel (or restart 'agy') to pick up changes" ;;
      opencode)
        say "OpenCode: servers written to $OPENCODE_CONFIG"
        echo "    restart 'opencode' to pick up changes" ;;
    esac
  done
  echo
  say "Next steps"
  echo "  • Open your agent and try a tool, e.g. ask it to 'ping the CyVerse Data Store' (mesa-mcp ds_ping)."
  echo "  • By default the servers use anonymous public access (data.cyverse.org, zone iplant)."
  echo "  • To authenticate, re-run with CYVERSE_USERNAME / CYVERSE_PASSWORD set, or edit"
  echo "    $MESA_HOME/repos/irods-mcp-server/config-stdio.yaml and your ~/.irods/irods_environment.json."
  echo "  • Docs: https://idss-mesa.github.io/docs/   •   Uninstall: $0 --uninstall"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
  detect_platform
  select_clients                       # before uninstall — uninstall honors --for
  [ "$DO_UNINSTALL" -eq 1 ] && uninstall

  say "MESA installer  (platform: $PLATFORM, prefix: $MESA_HOME, clients: ${CLIENTS_SELECTED:-none})"
  ensure_prereqs                       # dies here if no client was found
  mkdir -p "$MESA_HOME/repos" "$MESA_HOME/bin"

  clone_or_update mesa-ducklake main
  clone_or_update mesa-mcp "$MESA_MCP_REF"
  if [ "$BUILD_GO" -eq 1 ]; then
    clone_or_update irods-mcp-server main
    clone_or_update formation-mcp main
  fi

  install_python                       # guarantees venv python before any JSON edit
  [ "$BUILD_GO" -eq 1 ] && install_go

  register_servers
  summary
}

main "$@"
