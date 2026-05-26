#Requires -RunAsAdministrator

<#
.SYNOPSIS
    PowerShell Terminal Setup - Automated Installer with AMRO Theme

.DESCRIPTION
    Installs and configures a beautiful PowerShell terminal with Oh My Posh,
    Nerd Fonts, and custom color schemes. Supports multiple installation modes
    from minimal theming to full power user setup.

.PARAMETER Mode
    Installation mode: 1=ThemeOnly, 2=Express, 3=Productivity, 4=PowerUser, 5=Custom

.EXAMPLE
    .\install.ps1
    Interactive installation with mode selection

.EXAMPLE
    .\install.ps1 -Mode 2
    Direct installation in Express mode

.NOTES
    Version: 2.0.0
    Author: PowerShell Terminal Setup Contributors
    Requires: Windows 10/11, Administrator privileges
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateRange(1,5)]
    [int]$Mode
)

# ============================================
# Configuration & Globals
# ============================================

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$script:Config = @{
    RepoPath = $PSScriptRoot
    BackupPath = Join-Path $env:USERPROFILE "PowerShell_Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    ProfilePath = $PROFILE
    SettingsPath = "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
    ThemePath = "$env:USERPROFILE\Documents\PowerShell\themes"
    FontsPath = Join-Path $PSScriptRoot "fonts"
    EnvPath = Join-Path $PSScriptRoot ".env"
    MinPowerShellVersion = "7.4.0"
}

# ============================================
# Helper Functions
# ============================================

function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Success {
    param([string]$Text)
    Write-Host "✅ $Text" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Text)
    Write-Host "⚠️  $Text" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Text)
    Write-Host "❌ $Text" -ForegroundColor Red
}

function Write-Info {
    param([string]$Text)
    Write-Host "ℹ️  $Text" -ForegroundColor Cyan
}

# ============================================
# .env Management Functions
# ============================================

function Read-EnvFile {
    if (Test-Path $script:Config.EnvPath) {
        Write-Info "Found existing .env configuration"

        Get-Content $script:Config.EnvPath | ForEach-Object {
            if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
                $key = $matches[1].Trim()
                $value = $matches[2].Trim()
                [System.Environment]::SetEnvironmentVariable($key, $value, "Process")
            }
        }

        return $true
    }
    return $false
}

function Save-UserPreferences {
    param(
        [hashtable]$Preferences
    )

    $envContent = @"
# ============================================
# PowerShell Terminal Setup - Configuration
# ============================================
# Generated on: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
# All settings are optional - installer will auto-detect if left empty

# ============================================
# Git Configuration
# ============================================
# Git installation path (leave empty for auto-detection)
GIT_PATH=$($Preferences.GitPath)

# ============================================
# User Configuration
# ============================================
# Windows username (leave empty for auto-detection)
USERNAME=$($Preferences.Username)

# ============================================
# Font Configuration
# ============================================
# Preferred Nerd Font (default: Monofoki)
# Options: Monofoki, CascadiaCode, FiraCode, JetBrainsMono
NERD_FONT=$($Preferences.NerdFont)

# Font size (default: 14)
FONT_SIZE=$($Preferences.FontSize)

# ============================================
# Oh My Posh Configuration
# ============================================
# Theme name (default: amro)
THEME_NAME=$($Preferences.ThemeName)

# ============================================
# Terminal Appearance
# ============================================
# Terminal opacity (0-100, default: 82)
# 0 = fully transparent, 100 = fully opaque
TERMINAL_OPACITY=$($Preferences.TerminalOpacity)

# Use acrylic transparency effect (true/false, default: true)
USE_ACRYLIC=$($Preferences.UseAcrylic)

# ============================================
# Terminal Size
# ============================================
# Initial terminal columns (default: 90)
TERMINAL_COLS=$($Preferences.TerminalCols)

# Initial terminal rows (default: 30)
TERMINAL_ROWS=$($Preferences.TerminalRows)

# ============================================
# Installation Options
# ============================================
# Installation mode (1-5)
# 1 = Theme Only
# 2 = Express (recommended)
# 3 = Productivity
# 4 = Power User
# 5 = Custom
INSTALL_MODE=$($Preferences.InstallMode)

# Install Terminal-Icons module (true/false)
INSTALL_TERMINAL_ICONS=$($Preferences.InstallTerminalIcons)

# Include Git Bash profile (true/false)
INCLUDE_GIT_BASH=$($Preferences.IncludeGitBash)

# Include Command Prompt profile (true/false)
INCLUDE_CMD=$($Preferences.IncludeCmd)

# ============================================
# Advanced Options
# ============================================
# Show full path or use ~ for home directory (true/false, default: true)
# true = C:/Users/username, false = ~
SHOW_FULL_PATH=$($Preferences.ShowFullPath)

# PowerShell execution policy (default: RemoteSigned)
# Options: RemoteSigned, Unrestricted, Bypass
EXECUTION_POLICY=$($Preferences.ExecutionPolicy)

# Skip backup of existing configuration (true/false, default: false)
# WARNING: Setting this to true will overwrite existing configs without backup
SKIP_BACKUP=$($Preferences.SkipBackup)
"@

    Set-Content -Path $script:Config.EnvPath -Value $envContent -Encoding UTF8
    Write-Success "Preferences saved to .env for future installations"
}

# ============================================
# PowerShell Version Detection
# ============================================

function Get-LatestPowerShellVersion {
    <#
    .SYNOPSIS
        Gets the latest stable PowerShell version from GitHub API
    #>
    try {
        Write-Info "Checking latest PowerShell version..."
        $apiUrl = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
        $response = Invoke-RestMethod -Uri $apiUrl -ErrorAction Stop
        $latestVersion = $response.tag_name -replace '^v', ''
        Write-Info "Latest stable PowerShell version: $latestVersion"
        return $latestVersion
    }
    catch {
        Write-Warning "Could not fetch latest version from GitHub, using fallback: 7.4.0"
        return "7.4.0"
    }
}

function Test-PowerShell7 {
    <#
    .SYNOPSIS
        Tests if PowerShell 7 is installed and checks version
    #>
    $pwsh7 = Get-Command pwsh -ErrorAction SilentlyContinue

    if ($pwsh7) {
        $version = & pwsh -NoProfile -Command '$PSVersionTable.PSVersion.ToString()'
        $latestStable = Get-LatestPowerShellVersion

        $isExperimental = $version -match '-(preview|rc|beta|alpha)'
        $versionBase = $version -replace '-(preview|rc|beta|alpha).*', ''

        return @{
            Installed = $true
            Version = $version
            VersionBase = $versionBase
            IsExperimental = $isExperimental
            LatestStable = $latestStable
            NeedsUpdate = ([version]$versionBase -lt [version]$latestStable) -and (-not $isExperimental)
            IsUpToDate = ([version]$versionBase -ge [version]$latestStable) -or $isExperimental
        }
    }

    return @{
        Installed = $false
        Version = $null
        VersionBase = $null
        IsExperimental = $false
        LatestStable = Get-LatestPowerShellVersion
        NeedsUpdate = $false
        IsUpToDate = $false
    }
}

# ============================================
# Dependency Check Functions
# ============================================

function Test-WindowsTerminal {
    $wtPath = Get-Command wt -ErrorAction SilentlyContinue
    return $null -ne $wtPath
}

function Test-OhMyPosh {
    $ompPath = Get-Command oh-my-posh -ErrorAction SilentlyContinue
    return $null -ne $ompPath
}

function Test-Git {
    $gitPath = Get-Command git -ErrorAction SilentlyContinue
    if ($gitPath) {
        return $gitPath.Source
    }

    # Check common installation paths
    $commonPaths = @(
        "$env:ProgramFiles\Git\bin\git.exe",
        "$env:ProgramFiles(x86)\Git\bin\git.exe",
        "$env:LOCALAPPDATA\Programs\Git\bin\git.exe"
    )

    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            return $path
        }
    }

    return $null
}

function Test-NerdFont {
    param([string]$FontName = "Monofoki")

    $fonts = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -ErrorAction SilentlyContinue
    $fontInstalled = $fonts.PSObject.Properties | Where-Object { $_.Name -like "*$FontName*" }

    return $null -ne $fontInstalled
}

# ============================================
# Installation Functions
# ============================================

function Install-PowerShell7 {
    Write-Header "Installing PowerShell 7"

    try {
        Write-Info "Downloading and installing PowerShell 7..."

        # Try winget first
        $winget = Get-Command winget -ErrorAction SilentlyContinue
        if ($winget) {
            Write-Info "Using winget to install PowerShell..."
            winget install Microsoft.PowerShell --silent --accept-source-agreements --accept-package-agreements
        }
        else {
            # Fallback to direct download
            Write-Info "Downloading PowerShell installer..."
            $installerUrl = "https://github.com/PowerShell/PowerShell/releases/latest/download/PowerShell-7-win-x64.msi"
            $installerPath = "$env:TEMP\PowerShell-7-win-x64.msi"

            Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

            Write-Info "Installing PowerShell 7..."
            Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`" /quiet /norestart" -Wait

            Remove-Item $installerPath -Force
        }

        Write-Success "PowerShell 7 installed successfully"
        Write-Warning "Please restart this installer in PowerShell 7 to continue"
        Write-Host ""
        Write-Host "Run: pwsh -File `"$PSCommandPath`"" -ForegroundColor Yellow
        exit 0
    }
    catch {
        Write-Error "Failed to install PowerShell 7: $_"
        exit 1
    }
}

function Install-WindowsTerminal {
    Write-Header "Installing Windows Terminal"

    try {
        $winget = Get-Command winget -ErrorAction SilentlyContinue
        if ($winget) {
            Write-Info "Using winget to install Windows Terminal..."
            winget install Microsoft.WindowsTerminal --silent --accept-source-agreements --accept-package-agreements
        }
        else {
            Write-Info "Opening Microsoft Store to install Windows Terminal..."
            Start-Process "ms-windows-store://pdp/?ProductId=9N0DX20HK701"
            Write-Warning "Please install Windows Terminal from the Microsoft Store and run this installer again"
            exit 0
        }

        Write-Success "Windows Terminal installed successfully"
    }
    catch {
        Write-Error "Failed to install Windows Terminal: $_"
        exit 1
    }
}

function Install-OhMyPosh {
    Write-Header "Installing Oh My Posh"

    try {
        $winget = Get-Command winget -ErrorAction SilentlyContinue
        if ($winget) {
            Write-Info "Using winget to install Oh My Posh..."
            winget install JanDeDobbeleer.OhMyPosh --silent --accept-source-agreements --accept-package-agreements
        }
        else {
            Write-Info "Using PowerShell to install Oh My Posh..."
            Set-ExecutionPolicy Bypass -Scope Process -Force
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))
        }

        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

        Write-Success "Oh My Posh installed successfully"
    }
    catch {
        Write-Error "Failed to install Oh My Posh: $_"
        exit 1
    }
}

function Install-TerminalIcons {
    Write-Header "Installing Terminal-Icons Module"

    try {
        Write-Info "Installing Terminal-Icons from PowerShell Gallery..."
        Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck
        Write-Success "Terminal-Icons installed successfully"
    }
    catch {
        Write-Error "Failed to install Terminal-Icons: $_"
    }
}

function Install-MonofokiFont {
    Write-Header "Installing Monofoki Nerd Font"

    try {
        $fontPath = Join-Path $script:Config.FontsPath "MonofokiNerdFont-Regular.ttf"

        if (-not (Test-Path $fontPath)) {
            Write-Warning "Font file not found at: $fontPath"
            Write-Info "Please ensure the fonts folder contains Monofoki Nerd Font"
            return
        }

        # Check if already installed
        if (Test-NerdFont -FontName "Monofoki") {
            Write-Success "Monofoki Nerd Font is already installed"
            return
        }

        Write-Info "Installing Monofoki Nerd Font..."

        # Copy font to Windows Fonts folder
        $fontsFolder = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
        if (-not (Test-Path $fontsFolder)) {
            New-Item -ItemType Directory -Path $fontsFolder -Force | Out-Null
        }

        Copy-Item $fontPath -Destination $fontsFolder -Force

        # Register font in registry
        $fontName = "Monofoki Nerd Font (TrueType)"
        $fontFile = Split-Path $fontPath -Leaf
        New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" `
            -Name $fontName -Value $fontFile -PropertyType String -Force | Out-Null

        Write-Success "Monofoki Nerd Font installed successfully"
    }
    catch {
        Write-Error "Failed to install Monofoki Nerd Font: $_"
    }
}

function Install-Git {
    Write-Header "Installing Git"

    try {
        $winget = Get-Command winget -ErrorAction SilentlyContinue
        if ($winget) {
            Write-Info "Using winget to install Git..."
            winget install Git.Git --silent --accept-source-agreements --accept-package-agreements
        }
        else {
            Write-Info "Downloading Git installer..."
            $installerUrl = "https://github.com/git-for-windows/git/releases/latest/download/Git-2.43.0-64-bit.exe"
            $installerPath = "$env:TEMP\Git-installer.exe"

            Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

            Write-Info "Installing Git..."
            Start-Process $installerPath -ArgumentList "/VERYSILENT /NORESTART" -Wait

            Remove-Item $installerPath -Force
        }

        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

        Write-Success "Git installed successfully"
    }
    catch {
        Write-Error "Failed to install Git: $_"
    }
}

# ============================================
# Backup Functions
# ============================================

function Backup-ExistingConfiguration {
    Write-Header "Backing Up Existing Configuration"

    try {
        if (-not (Test-Path $script:Config.BackupPath)) {
            New-Item -ItemType Directory -Path $script:Config.BackupPath -Force | Out-Null
        }

        # Backup PowerShell profile
        if (Test-Path $PROFILE) {
            Write-Info "Backing up PowerShell profile..."
            Copy-Item $PROFILE -Destination (Join-Path $script:Config.BackupPath "Microsoft.PowerShell_profile.ps1") -Force
        }

        # Backup Windows Terminal settings
        if (Test-Path $script:Config.SettingsPath) {
            Write-Info "Backing up Windows Terminal settings..."
            Copy-Item $script:Config.SettingsPath -Destination (Join-Path $script:Config.BackupPath "settings.json") -Force
        }

        # Backup Oh My Posh theme
        $currentTheme = "$env:USERPROFILE\Documents\PowerShell\themes\*.omp.json"
        if (Test-Path $currentTheme) {
            Write-Info "Backing up Oh My Posh themes..."
            $themesBackup = Join-Path $script:Config.BackupPath "themes"
            New-Item -ItemType Directory -Path $themesBackup -Force | Out-Null
            Copy-Item $currentTheme -Destination $themesBackup -Force
        }

        Write-Success "Backup completed: $($script:Config.BackupPath)"
    }
    catch {
        Write-Warning "Backup failed: $_"
    }
}

# ============================================
# Configuration Deployment
# ============================================

function Deploy-PowerShellProfile {
    param(
        [string]$ProfileType
    )

    Write-Header "Deploying PowerShell Profile ($ProfileType)"

    try {
        $sourceProfile = Join-Path $script:Config.RepoPath "config\profile_$ProfileType.ps1"

        if (-not (Test-Path $sourceProfile)) {
            Write-Error "Profile file not found: $sourceProfile"
            return
        }

        # Ensure profile directory exists
        $profileDir = Split-Path $PROFILE -Parent
        if (-not (Test-Path $profileDir)) {
            New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        }

        # Copy profile
        Copy-Item $sourceProfile -Destination $PROFILE -Force

        Write-Success "PowerShell profile deployed successfully"
    }
    catch {
        Write-Error "Failed to deploy PowerShell profile: $_"
    }
}

function Deploy-WindowsTerminalSettings {
    param(
        [string]$SettingsType = "default"
    )

    Write-Header "Deploying Windows Terminal Settings"

    try {
        $sourceSettings = if ($SettingsType -eq "productivity") {
            Join-Path $script:Config.RepoPath "config\settings_productivity.json"
        } else {
            Join-Path $script:Config.RepoPath "config\settings.json"
        }

        if (-not (Test-Path $sourceSettings)) {
            Write-Error "Settings file not found: $sourceSettings"
            return
        }

        # Read source settings
        $settings = Get-Content $sourceSettings -Raw | ConvertFrom-Json

        # Update Git Bash path if Git is installed
        $gitPath = Test-Git
        if ($gitPath) {
            $gitBashPath = $gitPath -replace 'git\.exe$', 'bash.exe'
            $gitIconPath = Split-Path (Split-Path $gitPath -Parent) -Parent
            $gitIconPath = Join-Path $gitIconPath "mingw64\share\git\git-for-windows.ico"

            $gitProfile = $settings.profiles.list | Where-Object { $_.name -eq "Git Bash" }
            if ($gitProfile) {
                $gitProfile.commandline = "`"$gitBashPath`" --login -i"
                $gitProfile.icon = $gitIconPath
            }
        }

        # Update username in paths
        $username = $env:USERNAME
        $settingsJson = $settings | ConvertTo-Json -Depth 100
        $settingsJson = $settingsJson -replace 'cristian\.deandrade', $username

        # Ensure settings directory exists
        $settingsDir = Split-Path $script:Config.SettingsPath -Parent
        if (-not (Test-Path $settingsDir)) {
            New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null
        }

        # Save settings
        $settingsJson | Set-Content $script:Config.SettingsPath -Encoding UTF8

        Write-Success "Windows Terminal settings deployed successfully"
    }
    catch {
        Write-Error "Failed to deploy Windows Terminal settings: $_"
    }
}

function Deploy-OhMyPoshTheme {
    Write-Header "Deploying Oh My Posh Theme"

    try {
        $sourceTheme = Join-Path $script:Config.RepoPath "config\themes\amro.omp.json"

        if (-not (Test-Path $sourceTheme)) {
            Write-Error "Theme file not found: $sourceTheme"
            return
        }

        # Ensure themes directory exists
        if (-not (Test-Path $script:Config.ThemePath)) {
            New-Item -ItemType Directory -Path $script:Config.ThemePath -Force | Out-Null
        }

        # Copy theme
        $destTheme = Join-Path $script:Config.ThemePath "amro.omp.json"
        Copy-Item $sourceTheme -Destination $destTheme -Force

        Write-Success "Oh My Posh theme deployed successfully"
    }
    catch {
        Write-Error "Failed to deploy Oh My Posh theme: $_"
    }
}

# ============================================
# Main Installation Logic
# ============================================

function Show-InstallationModes {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  Select Installation Mode" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. 🖌️  Theme Only (Minimalist)" -ForegroundColor Magenta
    Write-Host "   └─ Only aesthetics: colors, font, and theme" -ForegroundColor Gray
    Write-Host "   └─ Does not modify keybindings or functions" -ForegroundColor Gray
    Write-Host "   └─ Load time: <0.5s | Install time: ~1 min" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "2. 🎨 Express (Recommended)" -ForegroundColor Green
    Write-Host "   └─ Theme Only + basic functionality" -ForegroundColor Gray
    Write-Host "   └─ Essential shortcuts + navigation" -ForegroundColor Gray
    Write-Host "   └─ Load time: <1s | Install time: ~2 min" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "3. 🚀 Productivity (For Developers)" -ForegroundColor Cyan
    Write-Host "   └─ Express + Terminal-Icons + advanced shortcuts" -ForegroundColor Gray
    Write-Host "   └─ Maximum productivity with fast loading" -ForegroundColor Gray
    Write-Host "   └─ Load time: ~1.5s | Install time: ~3 min" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "4. ⚡ Power User (Everything)" -ForegroundColor Yellow
    Write-Host "   └─ All available features" -ForegroundColor Gray
    Write-Host "   └─ For advanced users" -ForegroundColor Gray
    Write-Host "   └─ Load time: ~2s | Install time: ~5 min" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "5. ⚙️  Custom" -ForegroundColor White
    Write-Host "   └─ Choose exactly what to install" -ForegroundColor Gray
    Write-Host ""
}

function Start-Installation {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  PowerShell Terminal Setup" -ForegroundColor Cyan
    Write-Host "  AMRO Theme Edition" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""

    # Check if .env exists and ask to use it
    $useEnv = $false
    if (Read-EnvFile) {
        Write-Host ""
        $response = Read-Host "Use saved preferences from .env? (Y/N)"
        if ($response -eq "Y" -or $response -eq "y") {
            $useEnv = $true
            Write-Success "Using saved configuration"
        }
    }

    # ============================================
    # Step 1: Check PowerShell Version
    # ============================================

    Write-Header "Checking PowerShell Version"

    $pwshInfo = Test-PowerShell7

    if (-not $pwshInfo.Installed) {
        Write-Warning "PowerShell 7 is not installed"
        Write-Info "Installing PowerShell 7 (required)..."
        Install-PowerShell7
        return
    }

    Write-Info "PowerShell version: $($pwshInfo.Version)"

    if ($pwshInfo.IsExperimental) {
        Write-Info "Experimental/Preview version detected"
        Write-Success "Experimental versions are fully supported!"
    }

    if ($pwshInfo.IsUpToDate) {
        Write-Success "PowerShell version is up to date!"
    }
    elseif ($pwshInfo.NeedsUpdate) {
        Write-Warning "A newer stable version is available: $($pwshInfo.LatestStable)"
        $upgrade = Read-Host "Do you want to upgrade to PowerShell $($pwshInfo.LatestStable)? (Y/N)"

        if ($upgrade -eq "Y" -or $upgrade -eq "y") {
            Install-PowerShell7
            return
        }
    }

    # ============================================
    # Step 2: Check Windows Terminal
    # ============================================

    Write-Header "Checking Windows Terminal"

    if (-not (Test-WindowsTerminal)) {
        Write-Warning "Windows Terminal is not installed"
        Write-Info "Installing Windows Terminal (required)..."
        Install-WindowsTerminal
    }
    else {
        Write-Success "Windows Terminal is installed"
    }

    # ============================================
    # Step 3: Select Installation Mode
    # ============================================

    if ($useEnv -and $env:INSTALL_MODE) {
        $selectedMode = [int]$env:INSTALL_MODE
        Write-Info "Using saved installation mode: $selectedMode"
    }
    elseif ($Mode) {
        $selectedMode = $Mode
    }
    else {
        Show-InstallationModes
        $selectedMode = Read-Host "Select mode (1-5)"
    }

    # Initialize preferences
    $preferences = @{
        InstallMode = $selectedMode
        NerdFont = "Monofoki"
        FontSize = 14
        ThemeName = "amro"
        TerminalOpacity = 82
        UseAcrylic = $true
        TerminalCols = 90
        TerminalRows = 30
        ShowFullPath = $true
        ExecutionPolicy = "RemoteSigned"
        SkipBackup = $false
        Username = $env:USERNAME
        GitPath = ""
        InstallTerminalIcons = $false
        IncludeGitBash = $false
        IncludeCmd = $false
    }

    # ============================================
    # Step 4: Mode-specific Configuration
    # ============================================

    $profileType = "core"
    $settingsType = "default"
    $installOhMyPosh = $true
    $installFont = $true

    switch ($selectedMode) {
        1 { # Theme Only
            Write-Header "Theme Only Mode Selected"
            $profileType = "theme_only"
            $preferences.InstallTerminalIcons = $false
        }
        2 { # Express
            Write-Header "Express Mode Selected"
            $profileType = "core"
            $preferences.InstallTerminalIcons = $false
        }
        3 { # Productivity
            Write-Header "Productivity Mode Selected"
            $profileType = "productivity"
            $settingsType = "productivity"
            $preferences.InstallTerminalIcons = $true
        }
        4 { # Power User
            Write-Header "Power User Mode Selected"
            $profileType = "poweruser"
            $settingsType = "productivity"
            $preferences.InstallTerminalIcons = $true
        }
        5 { # Custom
            Write-Header "Custom Mode Selected"
            Write-Host ""

            # Ask about Terminal-Icons
            if ($useEnv -and $env:INSTALL_TERMINAL_ICONS) {
                $preferences.InstallTerminalIcons = $env:INSTALL_TERMINAL_ICONS -eq "true"
            }
            else {
                $response = Read-Host "Install Terminal-Icons? (Y/N) [Colorful file icons]"
                $preferences.InstallTerminalIcons = ($response -eq "Y" -or $response -eq "y")
            }

            # Ask about Git Bash
            if ($useEnv -and $env:INCLUDE_GIT_BASH) {
                $preferences.IncludeGitBash = $env:INCLUDE_GIT_BASH -eq "true"
            }
            else {
                $response = Read-Host "Include Git Bash profile? (Y/N)"
                $preferences.IncludeGitBash = ($response -eq "Y" -or $response -eq "y")
            }

            # Ask about CMD
            if ($useEnv -and $env:INCLUDE_CMD) {
                $preferences.IncludeCmd = $env:INCLUDE_CMD -eq "true"
            }
            else {
                $response = Read-Host "Include Command Prompt profile? (Y/N)"
                $preferences.IncludeCmd = ($response -eq "Y" -or $response -eq "y")
            }

            # Determine profile type based on selections
            if ($preferences.InstallTerminalIcons) {
                $profileType = "productivity"
                $settingsType = "productivity"
            }
            else {
                $profileType = "core"
            }
        }
    }

    # ============================================
    # Step 5: Install Dependencies
    # ============================================

    # Check and install Oh My Posh
    if ($installOhMyPosh) {
        if (-not (Test-OhMyPosh)) {
            Install-OhMyPosh
        }
        else {
            Write-Success "Oh My Posh is already installed"
        }
    }

    # Check and install Monofoki Font
    if ($installFont) {
        Install-MonofokiFont
    }

    # Install Terminal-Icons if needed
    if ($preferences.InstallTerminalIcons) {
        Install-TerminalIcons
    }

    # Check Git for Git Bash profile
    if ($preferences.IncludeGitBash -or $selectedMode -eq 3 -or $selectedMode -eq 4) {
        $gitPath = Test-Git
        if (-not $gitPath) {
            Write-Warning "Git is not installed"
            $installGit = Read-Host "Install Git? (Y/N)"
            if ($installGit -eq "Y" -or $installGit -eq "y") {
                Install-Git
                $gitPath = Test-Git
            }
        }
        $preferences.GitPath = $gitPath
    }

    # ============================================
    # Step 6: Backup Existing Configuration
    # ============================================

    if (-not $preferences.SkipBackup) {
        Backup-ExistingConfiguration
    }

    # ============================================
    # Step 7: Deploy Configuration
    # ============================================

    Deploy-PowerShellProfile -ProfileType $profileType
    Deploy-WindowsTerminalSettings -SettingsType $settingsType
    Deploy-OhMyPoshTheme

    # ============================================
    # Step 8: Save Preferences
    # ============================================

    Save-UserPreferences -Preferences $preferences

    # ============================================
    # Step 9: Final Steps
    # ============================================

    Write-Header "Installation Complete!"

    Write-Host ""
    Write-Success "PowerShell Terminal Setup has been installed successfully!"
    Write-Host ""
    Write-Info "Next steps:"
    Write-Host "  1. Close ALL Windows Terminal windows" -ForegroundColor Yellow
    Write-Host "  2. Open Windows Terminal" -ForegroundColor Yellow
    Write-Host "  3. Enjoy your new terminal experience! 🎉" -ForegroundColor Yellow
    Write-Host ""

    if ($preferences.InstallTerminalIcons) {
        Write-Info "Terminal-Icons installed - try 'ls' to see colorful icons!"
    }

    Write-Host ""
    Write-Host "Backup location: $($script:Config.BackupPath)" -ForegroundColor Gray
    Write-Host ""

    # Offer to restart Windows Terminal
    $restart = Read-Host "Restart Windows Terminal now? (Y/N)"
    if ($restart -eq "Y" -or $restart -eq "y") {
        Write-Info "Closing Windows Terminal..."
        Get-Process -Name "WindowsTerminal" -ErrorAction SilentlyContinue | Stop-Process -Force
        Start-Sleep -Seconds 2
        Write-Info "Starting Windows Terminal..."
        Start-Process "wt.exe"
    }

    Write-Host ""
    Write-Host "Thank you for using PowerShell Terminal Setup! ⚡" -ForegroundColor Cyan
    Write-Host ""
}

# ============================================
# Entry Point
# ============================================

try {
    Start-Installation
}
catch {
    Write-Error "Installation failed: $_"
    Write-Host ""
    Write-Host "Please report this issue at: https://github.com/yourusername/powershell-setup/issues" -ForegroundColor Yellow
    exit 1
}
