<#
.SYNOPSIS
Installs Neovim in a beginner-friendly way across Windows, macOS, and Linux.

.DESCRIPTION
This script focuses on guided Neovim setup with safety confirmations and optional
starter configuration. For first-time Vim navigation and practice exercises,
see README.md and learn_VIM_Motions_for_PowerShell.ps1 in this repo.

Beginner learning order:
1) Learn basic navigation/modes in README.md
2) Run practice exercises in learn_VIM_Motions_for_PowerShell.ps1
3) Use this script for guided Neovim installation/setup
4) Use official install docs if you need a manual path:
   https://neovim.io/doc/install/

.NOTES
Designed to be beginner-friendly and gradually increase complexity.
#>
[CmdletBinding()]
param(
    [switch]$NonInteractive,
    [switch]$DryRun,
    [switch]$SkipHealthCheck,
    [switch]$SkipConfig,
    [string]$Installer
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-LogInfo {
    param([string]$Message)
    Write-Host "[INFO ] $Message" -ForegroundColor Cyan
}

function Write-LogWarn {
    param([string]$Message)
    Write-Host "[WARN ] $Message" -ForegroundColor Yellow
}

function Write-LogOk {
    param([string]$Message)
    Write-Host "[ OK  ] $Message" -ForegroundColor Green
}

function Write-LogError {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Test-CommandExists {
    param([Parameter(Mandatory = $true)][string]$CommandName)
    return $null -ne (Get-Command -Name $CommandName -ErrorAction SilentlyContinue)
}

function Test-IsElevated {
    if ($IsWindows) {
        try {
            $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
            $principal = [Security.Principal.WindowsPrincipal]::new($identity)
            return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        }
        catch {
            return $false
        }
    }

    if (Test-CommandExists -CommandName "id") {
        try {
            $uid = & id -u
            return [int]$uid -eq 0
        }
        catch {
            return $false
        }
    }

    return $false
}

function Confirm-Action {
    param(
        [Parameter(Mandatory = $true)][string]$Prompt,
        [switch]$DefaultNo
    )

    if ($NonInteractive) {
        Write-LogWarn "NonInteractive mode: prompt denied -> $Prompt"
        return $false
    }

    $suffix = if ($DefaultNo) { "[y/N]" } else { "[Y/n]" }
    $response = Read-Host "$Prompt $suffix"
    if ([string]::IsNullOrWhiteSpace($response)) {
        return -not $DefaultNo
    }

    return $response.Trim().ToLowerInvariant() -in @("y", "yes")
}

function Invoke-ExternalCommand {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [string[]]$Arguments = @()
    )

    $display = @($FilePath) + $Arguments
    Write-LogInfo ("Executing: {0}" -f ($display -join " "))

    if ($DryRun) {
        Write-LogWarn "DryRun enabled. Command not executed."
        return 0
    }

    & $FilePath @Arguments
    $exitCode = $LASTEXITCODE
    if ($null -eq $exitCode) {
        $exitCode = 0
    }

    if ($exitCode -ne 0) {
        throw "Command failed with exit code ${exitCode}: $FilePath $($Arguments -join ' ')"
    }

    return $exitCode
}

function Get-LinuxOsInfo {
    $result = [ordered]@{
        Id = ""
        IdLike = @()
        PrettyName = ""
        Source = "unknown"
    }

    $osReleasePath = "/etc/os-release"
    if (Test-Path -LiteralPath $osReleasePath) {
        $rawLines = Get-Content -LiteralPath $osReleasePath
        $map = @{}
        foreach ($line in $rawLines) {
            if ($line -match "^\s*#") { continue }
            if ($line -notmatch "=") { continue }
            $parts = $line -split "=", 2
            $key = $parts[0].Trim()
            $value = $parts[1].Trim().Trim('"')
            $map[$key] = $value
        }

        if ($map.ContainsKey("ID")) {
            $result.Id = $map["ID"].ToLowerInvariant()
        }
        if ($map.ContainsKey("ID_LIKE")) {
            $result.IdLike = $map["ID_LIKE"].ToLowerInvariant().Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)
        }
        if ($map.ContainsKey("PRETTY_NAME")) {
            $result.PrettyName = $map["PRETTY_NAME"]
        }
        $result.Source = "/etc/os-release"
        return [pscustomobject]$result
    }

    if (Test-CommandExists -CommandName "lsb_release") {
        try {
            $id = (& lsb_release -si).Trim().ToLowerInvariant()
            $result.Id = $id
            $result.PrettyName = (& lsb_release -sd).Trim().Trim('"')
            $result.Source = "lsb_release"
            return [pscustomobject]$result
        }
        catch {
            Write-LogWarn "lsb_release exists but could not be read."
        }
    }

    return [pscustomobject]$result
}

function Get-LinuxNativeManagerOrder {
    param([Parameter(Mandatory = $true)][pscustomobject]$LinuxInfo)

    $id = $LinuxInfo.Id
    $idLike = @($LinuxInfo.IdLike)
    $tokens = @($id) + $idLike

    Write-LogInfo ("Linux distro detection source: {0}" -f $LinuxInfo.Source)
    if (-not [string]::IsNullOrWhiteSpace($LinuxInfo.PrettyName)) {
        Write-LogInfo ("Linux distribution: {0}" -f $LinuxInfo.PrettyName)
    }
    if (-not [string]::IsNullOrWhiteSpace($id)) {
        Write-LogInfo ("Linux ID={0}" -f $id)
    }
    if ($idLike.Count -gt 0) {
        Write-LogInfo ("Linux ID_LIKE={0}" -f ($idLike -join ","))
    }

    if ($tokens -contains "ubuntu" -or $tokens -contains "debian") {
        return @("apt", "apt-get")
    }
    if ($tokens -contains "fedora" -or $tokens -contains "rhel" -or $tokens -contains "centos") {
        return @("dnf", "yum")
    }
    if ($tokens -contains "arch") {
        return @("pacman")
    }
    if ($tokens -contains "opensuse" -or $tokens -contains "suse" -or $tokens -contains "sles") {
        return @("zypper")
    }
    if ($tokens -contains "alpine") {
        return @("apk")
    }
    if ($tokens -contains "void") {
        return @("xbps-install")
    }
    if ($tokens -contains "clear-linux-os" -or $tokens -contains "clear-linux") {
        return @("swupd")
    }

    Write-LogWarn "Linux distro not recognized from ID/ID_LIKE. Falling back to package-manager heuristic."
    return @("apt", "apt-get", "dnf", "yum", "pacman", "zypper", "apk", "xbps-install", "swupd")
}

function Get-InstallerCandidates {
    if ($IsWindows) {
        return @("winget", "choco", "scoop")
    }
    if ($IsMacOS) {
        return @("brew", "port")
    }
    if ($IsLinux) {
        $linuxInfo = Get-LinuxOsInfo
        $native = Get-LinuxNativeManagerOrder -LinuxInfo $linuxInfo
        $officialFallback = @("flatpak", "snap")
        return @($native + $officialFallback)
    }

    throw "Unsupported platform. This script currently supports Windows, macOS, and Linux."
}

function Resolve-Installer {
    param([string]$InstallerOverride)

    $candidates = Get-InstallerCandidates
    Write-LogInfo ("Installer candidate order: {0}" -f ($candidates -join " -> "))

    if (-not [string]::IsNullOrWhiteSpace($InstallerOverride)) {
        if ($InstallerOverride -notin $candidates) {
            throw "Installer override '$InstallerOverride' is not valid for this OS."
        }
        if (-not (Test-CommandExists -CommandName $InstallerOverride)) {
            throw "Installer override '$InstallerOverride' was requested but command is not installed."
        }
        Write-LogOk "Installer override selected: $InstallerOverride"
        return $InstallerOverride
    }

    foreach ($candidate in $candidates) {
        if (Test-CommandExists -CommandName $candidate) {
            Write-LogOk "Detected installer command: $candidate"
            return $candidate
        }
    }

    throw "No supported Neovim installer command was found for this OS. Install a package manager first and rerun."
}

function Get-InstallCommand {
    param([Parameter(Mandatory = $true)][string]$SelectedInstaller)

    $requiresElevation = $false
    $filePath = $SelectedInstaller
    $installArgs = @()

    switch ($SelectedInstaller) {
        "winget" {
            $installArgs = @("install", "--id", "Neovim.Neovim", "--exact")
        }
        "choco" {
            $installArgs = @("install", "neovim", "-y")
            $requiresElevation = $true
        }
        "scoop" {
            $installArgs = @("install", "neovim")
        }
        "brew" {
            $installArgs = @("install", "neovim")
        }
        "port" {
            $installArgs = @("install", "neovim")
            $requiresElevation = $true
        }
        "apt" {
            $installArgs = @("install", "-y", "neovim")
            $requiresElevation = $true
        }
        "apt-get" {
            $installArgs = @("install", "-y", "neovim")
            $requiresElevation = $true
        }
        "dnf" {
            $installArgs = @("install", "-y", "neovim")
            $requiresElevation = $true
        }
        "yum" {
            $installArgs = @("install", "-y", "neovim")
            $requiresElevation = $true
        }
        "pacman" {
            $installArgs = @("-S", "--noconfirm", "neovim")
            $requiresElevation = $true
        }
        "zypper" {
            $installArgs = @("--non-interactive", "in", "neovim")
            $requiresElevation = $true
        }
        "apk" {
            $installArgs = @("add", "neovim")
            $requiresElevation = $true
        }
        "xbps-install" {
            $installArgs = @("-Sy", "neovim")
            $requiresElevation = $true
        }
        "swupd" {
            $installArgs = @("bundle-add", "neovim")
            $requiresElevation = $true
        }
        "flatpak" {
            $installArgs = @("install", "-y", "flathub", "io.neovim.nvim")
        }
        "snap" {
            $installArgs = @("install", "nvim", "--classic")
            $requiresElevation = $true
        }
        default {
            throw "No install command mapping exists for installer '$SelectedInstaller'."
        }
    }

    [pscustomobject]@{
        FilePath = $filePath
        Arguments = $installArgs
        RequiresElevation = $requiresElevation
    }
}

function Invoke-InstallWithConfirmation {
    param([Parameter(Mandatory = $true)][pscustomobject]$InstallCommand)

    $displayCommand = @($InstallCommand.FilePath) + $InstallCommand.Arguments
    Write-Host ""
    Write-LogInfo "Neovim install command prepared:"
    Write-Host ("  {0}" -f ($displayCommand -join " ")) -ForegroundColor White

    if (-not (Confirm-Action -Prompt "Proceed with this Neovim installation command?" -DefaultNo)) {
        Write-LogWarn "Installation cancelled by user."
        return
    }

    if ($InstallCommand.RequiresElevation -and -not (Test-IsElevated)) {
        if (-not $IsWindows -and (Test-CommandExists -CommandName "sudo")) {
            if (-not (Confirm-Action -Prompt "This command likely needs elevated privileges. Use sudo?" -DefaultNo)) {
                Write-LogWarn "Installation cancelled before elevation."
                return
            }
            $sudoArgs = @($InstallCommand.FilePath) + @($InstallCommand.Arguments)
            Invoke-ExternalCommand -FilePath "sudo" -Arguments $sudoArgs | Out-Null
            Write-LogOk "Install command completed."
            return
        }

        if ($IsWindows) {
            Write-LogWarn "This installer often requires an elevated shell. Please run PowerShell as Administrator if install fails."
        }
        else {
            throw "Installer likely needs elevation, but sudo was not found. Run manually with elevated privileges."
        }
    }

    Invoke-ExternalCommand -FilePath $InstallCommand.FilePath -Arguments $InstallCommand.Arguments | Out-Null
    Write-LogOk "Install command completed."
}

function Test-NvimAvailable {
    return Test-CommandExists -CommandName "nvim"
}

function Show-PathGuidance {
    if (Test-NvimAvailable) {
        Write-LogOk "nvim is available in PATH."
        return
    }

    Write-LogWarn "nvim is not currently available in PATH."

    if ($IsWindows) {
        $candidates = @(
            "C:\Program Files\Neovim\bin",
            "C:\tools\neovim\bin",
            (Join-Path -Path $env:USERPROFILE -ChildPath "scoop\apps\neovim\current\bin")
        ) | Where-Object { Test-Path -LiteralPath $_ }

        if ($candidates.Count -eq 0) {
            Write-LogWarn "No known Windows Neovim bin path detected automatically."
            return
        }

        Write-LogInfo "Detected candidate Neovim bin path(s):"
        foreach ($candidate in $candidates) {
            Write-Host ("  - {0}" -f $candidate) -ForegroundColor White
        }

        $selected = $candidates[0]
        if (Confirm-Action -Prompt "Add '$selected' to your user PATH now?" -DefaultNo) {
            if ($DryRun) {
                Write-LogWarn "DryRun enabled. PATH was not modified."
                return
            }

            $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
            $segments = @()
            if (-not [string]::IsNullOrWhiteSpace($userPath)) {
                $segments = $userPath.Split(";")
            }

            if ($segments -contains $selected) {
                Write-LogOk "Path already contains: $selected"
                return
            }

            $newPath = if ([string]::IsNullOrWhiteSpace($userPath)) { $selected } else { "$userPath;$selected" }
            [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
            Write-LogOk "User PATH updated. Open a new terminal for changes to take effect."
        }

        return
    }

    Write-LogInfo "On Linux/macOS, update shell PATH in your profile if needed."
    Write-Host "Example:" -ForegroundColor White
    if ($IsLinux) {
        Write-Host '  export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' -ForegroundColor White
    }
    else {
        Write-Host '  export PATH="$PATH:/opt/homebrew/bin"' -ForegroundColor White
    }
}

function Get-NvimConfigPath {
    if ($IsWindows) {
        return Join-Path -Path $env:LOCALAPPDATA -ChildPath "nvim"
    }
    return Join-Path -Path $HOME -ChildPath ".config/nvim"
}

function Install-StarterConfig {
    if ($SkipConfig) {
        Write-LogWarn "Skipping starter config by request (-SkipConfig)."
        return
    }

    $repoUrl = "https://github.com/Manbearpiet/kickstart.nvim.git"
    if (-not (Confirm-Action -Prompt "Install beginner starter config from $repoUrl ?" -DefaultNo)) {
        Write-LogWarn "Starter config install skipped."
        return
    }

    if (-not (Test-CommandExists -CommandName "git")) {
        Write-LogWarn "git was not found. Install git first, then clone manually:"
        Write-Host "  git clone $repoUrl <nvim_config_path>" -ForegroundColor White
        return
    }

    $configPath = Get-NvimConfigPath
    Write-LogInfo "Neovim config target path: $configPath"

    if (Test-Path -LiteralPath $configPath) {
        $backupPath = "{0}.backup.{1}" -f $configPath, (Get-Date -Format "yyyyMMdd-HHmmss")
        if (-not (Confirm-Action -Prompt "Existing config found. Backup to '$backupPath' and continue?" -DefaultNo)) {
            Write-LogWarn "Starter config install cancelled to preserve existing config."
            return
        }

        if (-not $DryRun) {
            Move-Item -LiteralPath $configPath -Destination $backupPath -Force
        }
        Write-LogOk "Existing config backed up."
    }

    $parentPath = Split-Path -Path $configPath -Parent
    if (-not (Test-Path -LiteralPath $parentPath)) {
        if (-not $DryRun) {
            New-Item -Path $parentPath -ItemType Directory -Force | Out-Null
        }
    }

    Invoke-ExternalCommand -FilePath "git" -Arguments @("clone", $repoUrl, $configPath) | Out-Null
    Write-LogOk "Starter config installed."
}

function Invoke-HealthCheck {
    if ($SkipHealthCheck) {
        Write-LogWarn "Skipping health check by request (-SkipHealthCheck)."
        return
    }

    if (-not (Confirm-Action -Prompt "Run Neovim health check now?" -DefaultNo)) {
        Write-LogWarn "Health check skipped."
        return
    }

    if (-not (Test-NvimAvailable)) {
        Write-LogWarn "Cannot run health check because nvim is not in PATH."
        return
    }

    Invoke-ExternalCommand -FilePath "nvim" -Arguments @("--headless", "+checkhealth", "+qall") | Out-Null
    Write-LogOk "Health check finished."
}

try {
    Write-Host ""
    Write-Host "=== Neovim Cross-Platform Installer (Beginner-Friendly) ===" -ForegroundColor Magenta
    Write-LogInfo "PowerShell version: $($PSVersionTable.PSVersion)"
    Write-LogInfo "Detected OS flags -> Windows=$IsWindows Linux=$IsLinux macOS=$IsMacOS"
    Write-LogInfo "Current user: $([Environment]::UserName)"
    Write-LogInfo "Elevated shell: $(Test-IsElevated)"
    Write-LogInfo "Mode -> NonInteractive=$NonInteractive DryRun=$DryRun SkipHealthCheck=$SkipHealthCheck SkipConfig=$SkipConfig"

    if (Test-NvimAvailable) {
        Write-LogWarn "Neovim already appears installed (nvim command found)."
        if (-not (Confirm-Action -Prompt "Continue anyway and potentially reinstall?" -DefaultNo)) {
            Write-LogWarn "Exiting with no changes."
            return
        }
    }

    $selectedInstaller = Resolve-Installer -InstallerOverride $Installer
    $installCommand = Get-InstallCommand -SelectedInstaller $selectedInstaller

    Invoke-InstallWithConfirmation -InstallCommand $installCommand

    if (Test-NvimAvailable) {
        Write-LogInfo "Validating installation with: nvim --version"
        Invoke-ExternalCommand -FilePath "nvim" -Arguments @("--version") | Out-Null
        Write-LogOk "nvim is callable."
    }
    else {
        Write-LogWarn "nvim command still not found after install attempt."
    }

    Show-PathGuidance
    Invoke-HealthCheck
    Install-StarterConfig

    Write-Host ""
    Write-LogOk "Script completed."
    Write-Host "Next steps:" -ForegroundColor White
    Write-Host "  1) Open a new terminal session if PATH changed." -ForegroundColor White
    Write-Host "  2) Run: nvim" -ForegroundColor White
    Write-Host "  3) Inside Neovim, run: :checkhealth" -ForegroundColor White
}
catch {
    Write-Host ""
    Write-LogError $_.Exception.Message
    Write-LogWarn "Troubleshooting tips:"
    Write-Host "  - Re-run with -DryRun to inspect planned commands." -ForegroundColor White
    Write-Host "  - Re-run in elevated shell if your package manager requires it." -ForegroundColor White
    Write-Host "  - Verify your package manager is installed and functional." -ForegroundColor White
    exit 1
}
