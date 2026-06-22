#!/usr/bin/env bash
set -euo pipefail

export CODEX_NON_INTERACTIVE=1

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SUCCESSES=()
FAILURES=()

log_success() {
  printf '%b\n' "${GREEN}✓${NC} $1"
  SUCCESSES+=("$1")
}

log_error() {
  printf '%b\n' "${RED}✗${NC} $1" >&2
  FAILURES+=("$1")
}

log_info() {
  printf '%b\n' "${YELLOW}→${NC} $1"
}

update_command() {
  local tool=$1
  shift

  log_info "Updating ${tool}..."
  if "$@"; then
    log_success "Updated ${tool}"
  else
    log_error "Failed to update ${tool}"
  fi
}

run_remote_installer() {
  local tool=$1
  local url=$2
  local interpreter=$3
  local operation=$4
  local installer
  local progress_verb
  local result_verb
  shift 4

  case $operation in
    install)
      progress_verb=Installing
      result_verb=Installed
      ;;
    update)
      progress_verb=Updating
      result_verb=Updated
      ;;
    *)
      log_error "Invalid operation for ${tool}: ${operation}"
      return
      ;;
  esac

  if ! command -v curl >/dev/null 2>&1; then
    log_error "Cannot ${operation} ${tool}: curl is not installed"
    return
  fi

  if ! installer=$(mktemp); then
    log_error "Cannot ${operation} ${tool}: failed to create a temporary file"
    return
  fi

  log_info "${progress_verb} ${tool}..."
  if curl -fsSL "$url" -o "$installer" && \
    "$interpreter" "$installer" "$@"; then
    log_success "${result_verb} ${tool}"
  else
    log_error "Failed to ${operation} ${tool}"
  fi
  rm -f "$installer"
}

manage_tool() {
  local tool=$1
  local url=$2
  local interpreter=$3
  local -a install_args=()
  shift 3

  while (($# > 0)) && [[ $1 != -- ]]; do
    install_args+=("$1")
    shift
  done

  if (($# == 0)); then
    log_error "Invalid configuration for ${tool}: missing argument separator"
    return
  fi
  shift

  if command -v "$tool" >/dev/null 2>&1; then
    if (($# > 0)); then
      update_command "$tool" "$@"
    else
      run_remote_installer \
        "$tool" "$url" "$interpreter" update "${install_args[@]}"
    fi
  else
    run_remote_installer \
      "$tool" "$url" "$interpreter" install "${install_args[@]}"
  fi
}

print_summary() {
  printf '\n===== Update Summary =====\n'
  printf 'Successes: %d\n' "${#SUCCESSES[@]}"
  printf 'Failures: %d\n' "${#FAILURES[@]}"

  if ((${#FAILURES[@]} > 0)); then
    printf '\nFailed installs/updates:\n'
    printf '  - %s\n' "${FAILURES[@]}"
  fi

  ((${#FAILURES[@]} == 0))
}

main() {
  # Arguments before `--` belong to the installer; arguments after it are the
  # update command. An empty update command reruns the bootstrap installer,
  # which is Volta's update mechanism.
  manage_tool uv https://astral.sh/uv/install.sh sh \
    -- uv self update
  manage_tool claude https://claude.ai/install.sh bash \
    -- claude update
  manage_tool codex https://chatgpt.com/codex/install.sh sh \
    -- codex update
  manage_tool opencode https://opencode.ai/install bash \
    --no-modify-path -- opencode upgrade
  manage_tool agy https://antigravity.google/cli/install.sh bash \
    -- agy update
  manage_tool volta https://get.volta.sh bash \
    --skip-setup --
  manage_tool rustup https://sh.rustup.rs sh \
    -y --no-modify-path -- rustup update

  print_summary
}

main "$@"
