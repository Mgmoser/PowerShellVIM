#!/usr/bin/env bash
set -euo pipefail

NVIM_CONFIG_DIR="${HOME}/.config/nvim"
NVIM_INIT_FILE="${NVIM_CONFIG_DIR}/init.lua"
SOURCE_REPO_DIR="${SOURCE_REPO_DIR:-/repo-src}"
TARGET_WORKSPACE_DIR="${TARGET_WORKSPACE_DIR:-/workspaces/PowerShellVIM}"
SYNC_WORKSPACE=false
SKIP_HEALTH_CHECK=false

usage() {
  cat <<'EOF'
Usage: container-bootstrap.sh [--sync-workspace] [--skip-health-check]

Options:
  --sync-workspace   Rebuild workspace from git-tracked files only.
  --skip-health-check   Skip nvim checkhealth command.
  -h, --help   Show this help text.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --sync-workspace)
      SYNC_WORKSPACE=true
      shift
      ;;
    --skip-health-check)
      SKIP_HEALTH_CHECK=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[bootstrap] Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

sync_workspace_from_tracked_files() {
  echo "[bootstrap] Syncing workspace from tracked repository files only..."

  if [[ ! -d "${SOURCE_REPO_DIR}" ]]; then
    echo "[bootstrap] Source repository directory not found: ${SOURCE_REPO_DIR}"
    exit 1
  fi
  if ! git -C "${SOURCE_REPO_DIR}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "[bootstrap] Source path is not a git work tree: ${SOURCE_REPO_DIR}"
    exit 1
  fi

  mkdir -p "${TARGET_WORKSPACE_DIR}"
  find "${TARGET_WORKSPACE_DIR}" -mindepth 1 -maxdepth 1 -exec rm -rf {} +

  while IFS= read -r -d '' rel_path; do
    if [[ "$(basename "${rel_path}")" == ".gitignore" ]]; then
      continue
    fi
    mkdir -p "${TARGET_WORKSPACE_DIR}/$(dirname "${rel_path}")"
    cp -a "${SOURCE_REPO_DIR}/${rel_path}" "${TARGET_WORKSPACE_DIR}/${rel_path}"
  done < <(git -C "${SOURCE_REPO_DIR}" ls-files -z)

  echo "[bootstrap] Workspace sync completed."
}

if [[ "${SYNC_WORKSPACE}" == "true" ]]; then
  sync_workspace_from_tracked_files
fi

echo "[bootstrap] Preparing Neovim environment..."
mkdir -p "${NVIM_CONFIG_DIR}"

if [[ -f "${NVIM_INIT_FILE}" ]]; then
  echo "[bootstrap] Existing Neovim config detected at ${NVIM_INIT_FILE}. Leaving it unchanged."
else
  cat > "${NVIM_INIT_FILE}" <<'EOF'
-- Minimal repo-friendly Neovim starter config
vim.g.mapleader = " "
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.o.clipboard = "unnamedplus"
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.termguicolors = true
vim.o.updatetime = 250
vim.o.signcolumn = "yes"
EOF
  echo "[bootstrap] Created minimal config at ${NVIM_INIT_FILE}."
fi

if [[ "${SKIP_HEALTH_CHECK}" == "false" ]]; then
  echo "[bootstrap] Running non-interactive Neovim health check..."
  if nvim --headless "+checkhealth" "+qall" >/tmp/nvim-checkhealth.log 2>&1; then
    echo "[bootstrap] checkhealth completed. Review /tmp/nvim-checkhealth.log for details."
  else
    echo "[bootstrap] checkhealth returned a non-zero status."
    echo "[bootstrap] Some warnings are normal in minimal containers. See /tmp/nvim-checkhealth.log."
  fi
fi

echo "[bootstrap] Done."
