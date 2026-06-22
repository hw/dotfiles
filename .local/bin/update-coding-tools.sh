#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track success/failures
SUCCESSES=()
FAILURES=()

# Function to log with color
log_success() {
  echo -e "${GREEN}✓${NC} $1"
  SUCCESSES+=("$1")
}

log_error() {
  echo -e "${RED}✗${NC} $1"
  FAILURES+=("$1")
}

log_info() {
  echo -e "${YELLOW}→${NC} $1"
}

# Check prerequisites
if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is required but not installed."
  exit 1
fi

declare -A UPDATE_URLS=(
  [volta]="https://get.volta.sh"
  [uv]="https://astral.sh/uv/install.sh"
  [claude]="https://claude.ai/install.sh"
  [antigravity]="https://antigravity.google/cli/install.sh"
  [opencode]="https://opencode.ai/install"
)
declare -A UPDATE_ARGS=(
  [volta]="--skip-setup"
  [opencode]="--no-modify-path"
)

# Update tools via curl installers
for UPDATE_TOOL in "${!UPDATE_URLS[@]}"; do
  log_info "Updating ${UPDATE_TOOL}..."
  if curl -fsSL "${UPDATE_URLS[$UPDATE_TOOL]}" | bash -s -- ${UPDATE_ARGS[$UPDATE_TOOL]:-}; then
    log_success "Updated ${UPDATE_TOOL}"
  else
    log_error "Failed to update ${UPDATE_TOOL}"
  fi
done

# Update npm packages
if ! command -v npm >/dev/null 2>&1; then
  log_info "npm not found, installing Node.js via Volta..."
  export VOLTA_HOME="${HOME}/.volta"
  export PATH="${VOLTA_HOME}/bin:${PATH}"
  volta install node
fi

NPM_PKGS=(
  @openai/codex 
  @google/gemini-cli
)
for NPM_PKG in ${NPM_PKGS[@]}; do 
  log_info "Updating ${NPM_PKG}..."
  if npm i -g --no-audit --no-fund "${NPM_PKG}@latest" 2>/dev/null; then
    log_success "Updated ${NPM_PKG}"
  else
    log_error "Failed to update ${NPM_PKG}"
  fi
done


# Update Rust if rustup is installed
if command -v rustup >/dev/null 2>&1; then
  log_info "Updating Rust..."
  if rustup update; then
    log_success "Updated Rust"
  else
    log_error "Failed to update Rust"
  fi
fi

# Move opencode binary to ~/.local/bin if it exists
if [ -f "$HOME/.opencode/bin/opencode" ]; then
  log_info "Moving opencode binary..."
  mkdir -p "$HOME/.local/bin"
  if mv -f "$HOME/.opencode/bin/opencode" "$HOME/.local/bin/opencode"; then
    rm -rf "$HOME/.opencode"
    log_success "Moved opencode binary"
  else
    log_error "Failed to move opencode binary"
  fi
fi

# Summary
echo ""
echo "===== Update Summary ====="
echo "Successes: ${#SUCCESSES[@]}"
echo "Failures: ${#FAILURES[@]}"

if [ "${#FAILURES[@]}" -gt 0 ]; then
  echo ""
  echo "Failed updates:"
  printf '  - %s\n' "${FAILURES[@]}"
  exit 1
fi
