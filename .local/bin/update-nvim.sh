#!/usr/bin/env bash

set -Eeuo pipefail

readonly INSTALL_ARCHIVE="nvim-linux-x86_64.tar.gz"
readonly OUTDIR_NAME="nvim-linux-x86_64"
readonly RELEASE_API="https://api.github.com/repos/neovim/neovim/releases/latest"

SUDO=()
DOWNLOADED_ARCHIVE=false
EXTRACT_DIR=""

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

cleanup() {
  if [[ -n "$EXTRACT_DIR" && -d "$EXTRACT_DIR" ]]; then
    rm -rf -- "$EXTRACT_DIR"
  fi

  if [[ "$DOWNLOADED_ARCHIVE" == true ]]; then
    rm -f -- "$INSTALL_ARCHIVE"
  fi
}
trap cleanup EXIT

for command in wget tar; do
  command -v "$command" >/dev/null 2>&1 || die "Required command not found: $command"
done

if (( EUID != 0 )); then
  SUDO=(sudo)
fi

if (( $# > 1 )); then
  die "Usage: $0 [release-tag]"
fi

if (( $# == 1 )); then
  RELEASE_VERSION=$1
  RELEASE_URL="https://github.com/neovim/neovim/releases/download/${RELEASE_VERSION}/${INSTALL_ARCHIVE}"
else
  command -v jq >/dev/null 2>&1 || die "Required command not found: jq"

  RELEASE_JSON=$(wget -qO- "$RELEASE_API") || die "Could not query the latest Neovim release."
  RELEASE_VERSION=$(jq -er '.tag_name' <<<"$RELEASE_JSON") || die "Could not determine the latest release tag."
  RELEASE_URL=$(
    jq -er --arg name "$INSTALL_ARCHIVE" \
      '.assets[] | select(.name == $name) | .browser_download_url' <<<"$RELEASE_JSON"
  ) || die "Release ${RELEASE_VERSION} has no ${INSTALL_ARCHIVE} asset."
fi

if [[ -x /usr/bin/nvim ]]; then
  INSTALLED_VERSION=$(/usr/bin/nvim --version | awk 'NR == 1 { print $2 }')
else
  INSTALLED_VERSION="not installed"
fi

printf 'Requested release version = %s\n' "$RELEASE_VERSION"
printf 'Installed version         = %s\n' "$INSTALLED_VERSION"

if [[ "$INSTALLED_VERSION" == "$RELEASE_VERSION" ]]; then
  printf 'Neovim %s is already installed.\n' "$RELEASE_VERSION"
  exit 0
fi

if [[ ! -f "$INSTALL_ARCHIVE" ]]; then
  DOWNLOADED_ARCHIVE=true
  printf 'Downloading %s...\n' "$RELEASE_URL"
  wget --show-progress -O "$INSTALL_ARCHIVE" "$RELEASE_URL" || die "Download failed: $RELEASE_URL"
fi

EXTRACT_DIR=$(mktemp -d "${TMPDIR:-/tmp}/update-nvim.XXXXXXXX")
tar -xzf "$INSTALL_ARCHIVE" -C "$EXTRACT_DIR" || die "Could not extract $INSTALL_ARCHIVE."
OUTDIR="$EXTRACT_DIR/$OUTDIR_NAME"

[[ -x "$OUTDIR/bin/nvim" ]] || die "Archive does not contain $OUTDIR_NAME/bin/nvim."
[[ -d "$OUTDIR/lib/nvim" ]] || die "Archive does not contain $OUTDIR_NAME/lib/nvim."
[[ -d "$OUTDIR/share/nvim" ]] || die "Archive does not contain $OUTDIR_NAME/share/nvim."

# Only operations that write to system directories run with elevated privileges.
if (( EUID != 0 )); then
  command -v sudo >/dev/null 2>&1 || die "Root access is required for installation, but sudo was not found."
fi

"${SUDO[@]}" cp -a "$OUTDIR/bin/nvim" /usr/bin/
"${SUDO[@]}" cp -a "$OUTDIR/lib/nvim" /usr/lib/
"${SUDO[@]}" cp -a "$OUTDIR/share/." /usr/share/

if [[ -x /usr/bin/update-alternatives ]]; then
  "${SUDO[@]}" /usr/bin/update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
  "${SUDO[@]}" /usr/bin/update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
fi

printf 'Neovim %s installed successfully.\n' "$RELEASE_VERSION"
