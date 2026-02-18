#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/Manbearpiet/kickstart.nvim.git"
NVIM_CONFIG_DIR="${HOME}/.config/nvim"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="${NVIM_CONFIG_DIR}.backup.${TIMESTAMP}"
FORCE_INSTALL=false

usage() {
  cat <<'EOF'
Usage: install-optional-kickstart.sh [--force]

Options:
  --force   Install without interactive confirmation.
  -h, --help   Show this help text.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      FORCE_INSTALL=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[kickstart] Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

if ! command -v git >/dev/null 2>&1; then
  echo "[kickstart] git is required but not found."
  exit 1
fi

if [[ "${FORCE_INSTALL}" != "true" ]]; then
  read -r -p "[kickstart] Clone ${REPO_URL} into ${NVIM_CONFIG_DIR}? [y/N]: " response
  response="${response:-N}"
  case "${response}" in
    y|Y|yes|YES)
      ;;
    *)
      echo "[kickstart] Cancelled."
      exit 0
      ;;
  esac
fi

HAD_EXISTING_CONFIG=false
if [[ -e "${NVIM_CONFIG_DIR}" ]]; then
  HAD_EXISTING_CONFIG=true
  echo "[kickstart] Existing config detected: ${NVIM_CONFIG_DIR}"
  echo "[kickstart] Backing it up to: ${BACKUP_DIR}"
  mv "${NVIM_CONFIG_DIR}" "${BACKUP_DIR}"
fi

mkdir -p "$(dirname "${NVIM_CONFIG_DIR}")"
git clone "${REPO_URL}" "${NVIM_CONFIG_DIR}"

echo "[kickstart] Kickstart config installed."
echo "[kickstart] Open nvim and allow plugins to install."
if [[ "${HAD_EXISTING_CONFIG}" == "true" ]]; then
  echo "[kickstart] You can restore previous config from: ${BACKUP_DIR}"
fi
