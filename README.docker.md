# Docker + Codespaces Guide for Neovim

This guide gives you a ready-to-use Neovim environment for this repository without installing all dependencies on your host machine.

It supports:
- Local Docker (primary workflow: Docker Compose)
- GitHub Codespaces (via `.devcontainer/devcontainer.json`)

## What Is Included

The container image includes:
- `neovim`
- `powershell` (`pwsh`)
- `git`, `curl`
- `ripgrep`, `fd` (via `fd-find`)
- `python3`, `pip`
- `nodejs`, `npm`
- `xclip`

## Source Policy (Strict)

The container workspace is built from:
- Git-tracked files from this repository only
- Optional Neovim kickstart config from the remote repo:
  - `https://github.com/Manbearpiet/kickstart.nvim.git`

The container workspace intentionally excludes:
- Local untracked/personal files
- Files matched by `.gitignore`
- `.gitignore` file(s) themselves

## Prerequisites

- Docker Desktop (or Docker Engine + Compose plugin)
- (Optional) GitHub account with Codespaces enabled

## Local Quick Start (Compose First)

From the repository root:

1. Build and start the container:
   - `docker compose up -d --build`
2. Enter the running container:
   - `docker compose exec neovim-dev bash`
3. Run first-time bootstrap:
   - `container-bootstrap.sh --sync-workspace`
4. Open Neovim:
   - `nvim`

## How Workspace Sync Works

- Host repo is mounted read-only at `/repo-src`.
- Runtime workspace is `/workspaces/PowerShellVIM`.
- `container-bootstrap.sh --sync-workspace` copies only `git ls-files` output into runtime workspace.
- Any `.gitignore` files are skipped during sync.

If you change tracked files locally and want to refresh container workspace:
- `docker compose exec neovim-dev container-bootstrap.sh --sync-workspace --skip-health-check`

## Verify the Environment

Inside the container:

- `nvim --version`
- `pwsh -v`
- `nvim --headless "+checkhealth" "+qall"`

Validate strict filtering:
- `ls -la /workspaces/PowerShellVIM`
- `find /workspaces/PowerShellVIM -name ".gitignore"`
  - Expected: no output
- Create a local untracked temp file on host, then re-run sync:
  - `docker compose exec neovim-dev container-bootstrap.sh --sync-workspace --skip-health-check`
  - Confirm the temp file is not present in `/workspaces/PowerShellVIM`.

If needed, inspect bootstrap output:
- `cat /tmp/nvim-checkhealth.log`

## Optional External Starter Config

This is opt-in and not automatic.

Inside the container:

- Interactive install:
  - `install-optional-kickstart.sh`
- Non-interactive install:
  - `install-optional-kickstart.sh --force`

This script clones:
- `https://github.com/Manbearpiet/kickstart.nvim.git`

If an existing config is present, it is backed up to:
- `~/.config/nvim.backup.<timestamp>`

## Run Tutorial Files in the Container

Inside the container:

- Open tutorial script:
  - `nvim learn_VIM_Motions_for_PowerShell.ps1`
- Open the tutor text file:
  - `nvim vimTutorFile.txt`
- Run your PowerShell script directly:
  - `pwsh -File learn_VIM_Motions_for_PowerShell.ps1`

## Optional `docker run` Flow

If you prefer not to use Compose:

1. Build image:
   - `docker build -t powershellvim-neovim .`
2. Create persistent volumes:
   - `docker volume create powershellvim_workspace_repo`
   - `docker volume create powershellvim_nvim_config`
   - `docker volume create powershellvim_nvim_data`
   - `docker volume create powershellvim_nvim_state`
   - `docker volume create powershellvim_nvim_cache`
3. Start container with strict source mapping:
   - `docker run --rm -it -e SOURCE_REPO_DIR=/repo-src -e TARGET_WORKSPACE_DIR=/workspaces/PowerShellVIM -v "${PWD}:/repo-src:ro" -v powershellvim_workspace_repo:/workspaces/PowerShellVIM -v powershellvim_nvim_config:/home/vscode/.config/nvim -v powershellvim_nvim_data:/home/vscode/.local/share/nvim -v powershellvim_nvim_state:/home/vscode/.local/state/nvim -v powershellvim_nvim_cache:/home/vscode/.cache/nvim powershellvim-neovim bash`
4. Bootstrap:
   - `container-bootstrap.sh --sync-workspace`

## Persistence and Reset

Compose persists Neovim state in named volumes:
- `workspace_repo`
- `nvim_config`
- `nvim_data`
- `nvim_state`
- `nvim_cache`

To remove everything (container + volumes):
- `docker compose down -v`

To stop but keep data:
- `docker compose down`

## GitHub Codespaces Usage

1. Create a Codespace from this repo.
2. Codespaces will use `.devcontainer/devcontainer.json`.
3. After creation, run:
   - `container-bootstrap.sh --sync-workspace`
4. Start Neovim:
   - `nvim`

## Troubleshooting

- `nvim: command not found`
  - Rebuild image: `docker compose build --no-cache`
- Clipboard warnings in `:checkhealth`
  - In minimal containers, some clipboard/provider warnings are expected.
- Permission issues in `~/.config/nvim`
  - Ensure you are running as `vscode` user in the container.
- Plugin install/network issues
  - Re-run when network is stable and verify with `git --version` and `curl --version`.
