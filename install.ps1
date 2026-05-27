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
    SettingsPath = $null  # Will be resolved dynamically by Get-WindowsTerminalSettingsPath
    ThemePath = "$env:USERPROFILE\Documents\PowerShell\themes"
    FontsPath = Join-Path $PSScriptRoot "fonts"
    EnvPath = Join-Path $PSScriptRoot ".env"
    MinPowerShellVersion = "7.6.0"
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
        Write-Warning "Could not fetch latest version from GitHub, using fallback: 7.6.0"
        return "7.6.0"
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

function Get-WindowsTerminalSettingsPath {
    <#
    .SYNOPSIS
        Detects the real Windows Terminal settings.json path (Store vs portable install)
    #>
    $candidates = @(
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json",
        "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
    )

    foreach ($path in $candidates) {
        if (Test-Path $path) {
            Write-Info "Windows Terminal settings found at: $path"
            return $path
        }
    }

    # Default to Store path (will be created on first WT launch)
    $defaultPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    Write-Warning "No existing settings.json found. Will create at: $defaultPath"
    return $defaultPath
}

function Get-GitBashPath {
    <#
    .SYNOPSIS
        Finds Git Bash executable and icon, checking common install locations
    #>
    $gitExe = Get-Command git -ErrorAction SilentlyContinue

    $gitRoots = @()

    if ($gitExe) {
        # Resolve: git.exe is usually in Git\cmd\ or Git\bin\
        $gitRoot = Split-Path (Split-Path $gitExe.Source -Parent) -Parent
        $gitRoots += $gitRoot
    }

    # Also check common install paths regardless
    $gitRoots += @(
        "$env:ProgramFiles\Git",
        "${env:ProgramFiles(x86)}\Git",
        "$env:LOCALAPPDATA\Programs\Git"
    )

    foreach ($root in $gitRoots) {
        $bash = Join-Path $root "bin\bash.exe"
        if (Test-Path $bash) {
            $icon = Join-Path $root "mingw64\share\git\git-for-windows.ico"
            if (-not (Test-Path $icon)) { $icon = $null }
            return @{ Found = $true; BashPath = $bash; IconPath = $icon; Root = $root }
        }
    }

    return @{ Found = $false }
}

function New-DeterministicGuid {
    <#
    .SYNOPSIS
        Generates a stable GUID from a seed string (MD5-based, version 3)
    #>
    param([string]$Seed)
    $md5   = [System.Security.Cryptography.MD5]::Create()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Seed)
    $hash  = $md5.ComputeHash($bytes)
    $b     = $hash[0..15]
    $b[6]  = ($b[6] -band 0x0F) -bor 0x30   # version 3
    $b[8]  = ($b[8] -band 0x3F) -bor 0x80   # variant RFC4122
    return '{' + [System.Guid]::new([byte[]]$b).ToString() + '}'
}

function Get-AllPowerShellVersions {
    <#
    .SYNOPSIS
        Returns every pwsh.exe found: Store apps (AppxPackage), MSI/winget installs, and PATH fallback
    #>
    $found    = [System.Collections.Generic.List[PSObject]]::new()
    $seenExes = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $candidates = [System.Collections.Generic.List[string]]::new()

    # 1. Store-installed PowerShell (Microsoft.PowerShell + Microsoft.PowerShellPreview)
    try {
        $pkgs = @(Get-AppxPackage -Name "Microsoft.PowerShell"        -AllUsers -ErrorAction SilentlyContinue) +
                @(Get-AppxPackage -Name "Microsoft.PowerShellPreview"  -AllUsers -ErrorAction SilentlyContinue)
        foreach ($pkg in $pkgs) {
            if ($pkg.InstallLocation) {
                $candidates.Add((Join-Path $pkg.InstallLocation "pwsh.exe"))
            }
        }
    } catch { }

    # 2. MSI / winget installs in standard paths
    foreach ($root in @(
        "$env:ProgramFiles\PowerShell",
        "${env:ProgramFiles(x86)}\PowerShell",
        "$env:LOCALAPPDATA\Programs\PowerShell"
    )) {
        if (-not (Test-Path $root)) { continue }
        Get-ChildItem $root -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            $candidates.Add((Join-Path $_.FullName "pwsh.exe"))
        }
    }

    # 3. PATH fallback (catches anything not found above)
    $pathPwsh = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($pathPwsh) { $candidates.Add($pathPwsh.Source) }

    # Probe each candidate, deduplicated by resolved path
    foreach ($exePath in $candidates) {
        if (-not (Test-Path $exePath)) { continue }
        try { $resolved = (Resolve-Path $exePath -ErrorAction Stop).Path } catch { $resolved = $exePath }
        if (-not $seenExes.Add($resolved)) { continue }

        try {
            $ver = & $resolved -NoProfile -NonInteractive -Command '$PSVersionTable.PSVersion.ToString()' 2>$null
            if (-not $ver) { continue }
            $isPreview = $ver -match '-(preview|rc|beta|alpha)'
            $verBase   = $ver -replace '-(preview|rc|beta|alpha).*', ''
            $found.Add([PSCustomObject]@{
                Path        = $resolved
                Version     = $ver
                VersionBase = $verBase
                IsPreview   = $isPreview
            })
        } catch { }
    }

    return $found.ToArray()
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
        [string]$SettingsType = "default",
        [hashtable]$Preferences
    )

    Write-Header "Deploying Windows Terminal Settings"

    try {
        # Resolve real settings path
        $realPath = Get-WindowsTerminalSettingsPath
        $script:Config.SettingsPath = $realPath

        # Ensure directory exists
        $settingsDir = Split-Path $realPath -Parent
        if (-not (Test-Path $settingsDir)) {
            New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null
        }

        # Read existing settings or start from repo base
        if (Test-Path $realPath) {
            $settings = Get-Content $realPath -Raw -Encoding UTF8 | ConvertFrom-Json
            Write-Info "Merging into existing settings.json"
        } else {
            $baseFile = Join-Path $script:Config.RepoPath "config\settings.json"
            $settings = Get-Content $baseFile -Raw -Encoding UTF8 | ConvertFrom-Json
            Write-Info "Creating new settings.json from template"
        }

        # ── NeoTokyo color scheme ────────────────────────────────────────────
        $neoTokyoScheme = [PSCustomObject]@{
            name                = "NeoTokyo"
            background          = "#0B1020"
            foreground          = "#8BE9FD"
            cursorColor         = "#FF79C6"
            selectionBackground = "#A1FFD6"
            black               = "#15161E"; brightBlack  = "#6B7089"
            red                 = "#FF5C8A"; brightRed    = "#FF7DA3"
            green               = "#5AF78E"; brightGreen  = "#7CFFB2"
            yellow              = "#FFD866"; brightYellow = "#FFE38C"
            blue                = "#5AA9FF"; brightBlue   = "#7DC1FF"
            purple              = "#BD93F9"; brightPurple = "#D6ACFF"
            cyan                = "#8BE9FD"; brightCyan   = "#A4FFFF"
            white               = "#BFC7D5"; brightWhite  = "#FFFFFF"
        }

        if ($null -eq $settings.schemes) {
            $settings | Add-Member -NotePropertyName schemes -NotePropertyValue @($neoTokyoScheme)
        } else {
            $others = @($settings.schemes | Where-Object { $_.name -ne "NeoTokyo" })
            $settings.schemes = $others + $neoTokyoScheme
        }
        Write-Success "NeoTokyo color scheme applied"

        # ── Profile defaults ─────────────────────────────────────────────────
        if ($null -eq $settings.profiles) {
            $settings | Add-Member -NotePropertyName profiles -NotePropertyValue (
                [PSCustomObject]@{ defaults = [PSCustomObject]@{}; list = @() }
            )
        }
        if ($null -eq $settings.profiles.defaults) {
            $settings.profiles | Add-Member -NotePropertyName defaults -NotePropertyValue ([PSCustomObject]@{})
        }

        $opacity = if ($Preferences -and $Preferences.TerminalOpacity) { [int]$Preferences.TerminalOpacity } else { 82 }
        $fontSize = if ($Preferences -and $Preferences.FontSize) { [int]$Preferences.FontSize } else { 14 }

        $d = $settings.profiles.defaults
        $d | Add-Member -NotePropertyName colorScheme      -NotePropertyValue "NeoTokyo"   -Force
        $d | Add-Member -NotePropertyName useAcrylic       -NotePropertyValue $true         -Force
        $d | Add-Member -NotePropertyName opacity          -NotePropertyValue $opacity      -Force
        $d | Add-Member -NotePropertyName cursorShape      -NotePropertyValue "bar"         -Force
        $d | Add-Member -NotePropertyName padding          -NotePropertyValue "8,8,8,8"    -Force
        $d | Add-Member -NotePropertyName antialiasingMode -NotePropertyValue "grayscale"  -Force
        $d | Add-Member -NotePropertyName bellStyle        -NotePropertyValue "none"        -Force
        $d | Add-Member -NotePropertyName historySize      -NotePropertyValue 50000         -Force
        $d | Add-Member -NotePropertyName snapOnInput      -NotePropertyValue $true         -Force
        $d | Add-Member -NotePropertyName closeOnExit      -NotePropertyValue "graceful"    -Force
        $d | Add-Member -NotePropertyName font             -NotePropertyValue (
            [PSCustomObject]@{ face = "Monofoki Nerd Font"; size = $fontSize }
        ) -Force

        # ── PowerShell profiles (one per installed version) ─────────────────
        $allPwsh       = Get-AllPowerShellVersions
        $ps7SourceGuid = "{574e775e-4f2a-5b96-ac1e-a2962a402336}"
        $pwshGuids     = @()

        if ($allPwsh.Count -gt 0) {
            $stableList  = @($allPwsh | Where-Object { -not $_.IsPreview } |
                             Sort-Object { [version]$_.VersionBase } -Descending)
            $previewList = @($allPwsh | Where-Object {  $_.IsPreview     } |
                             Sort-Object { [version]$_.VersionBase } -Descending)
            $hasPreview  = $previewList.Count -gt 0

            # Default = highest preview if exists, else highest stable
            $defaultPwsh = if ($hasPreview) { $previewList[0] } else { $stableList[0] }

            # Iterate preview first, then stable
            foreach ($pwsh in ($previewList + $stableList)) {
                $isDefault = ($pwsh.Path -eq $defaultPwsh.Path)
                $guid      = if ($isDefault) {
                    $ps7SourceGuid
                } else {
                    New-DeterministicGuid -Seed "neotokyo-pwsh-$($pwsh.Path.ToLower())"
                }
                $pwshGuids += $guid

                $label    = if ($pwsh.IsPreview) { "PowerShell $($pwsh.VersionBase)-preview" } else { "PowerShell $($pwsh.VersionBase)" }
                $icon     = if ($pwsh.IsPreview) { "ms-appx:///ProfileIcons/pwsh-preview.png" } else { "ms-appx:///ProfileIcons/pwsh.png" }
                $tabColor = if ($pwsh.IsPreview) { "#1A0B2E" } else { "#0B1020" }

                $existing = $settings.profiles.list | Where-Object { $_.guid -eq $guid }
                if ($existing) {
                    $existing | Add-Member -NotePropertyName name        -NotePropertyValue $label    -Force
                    $existing | Add-Member -NotePropertyName tabTitle    -NotePropertyValue $label    -Force
                    $existing | Add-Member -NotePropertyName commandline -NotePropertyValue "`"$($pwsh.Path)`"" -Force
                    $existing | Add-Member -NotePropertyName icon        -NotePropertyValue $icon     -Force
                    $existing | Add-Member -NotePropertyName tabColor    -NotePropertyValue $tabColor -Force
                    $existing | Add-Member -NotePropertyName colorScheme -NotePropertyValue "NeoTokyo" -Force
                    $existing | Add-Member -NotePropertyName hidden      -NotePropertyValue $false    -Force
                    $existing | Add-Member -NotePropertyName suppressApplicationTitle -NotePropertyValue $true -Force
                } else {
                    $newProfile = [PSCustomObject]@{
                        guid                     = $guid
                        name                     = $label
                        tabTitle                 = $label
                        commandline              = "`"$($pwsh.Path)`""
                        icon                     = $icon
                        tabColor                 = $tabColor
                        colorScheme              = "NeoTokyo"
                        suppressApplicationTitle = $true
                        startingDirectory        = "%USERPROFILE%"
                        useAcrylic               = $true
                        opacity                  = $opacity
                        hidden                   = $false
                    }
                    $settings.profiles.list = @($settings.profiles.list) + $newProfile
                }
                Write-Success "Profile: $label  →  $($pwsh.Path)"
            }

            $settings | Add-Member -NotePropertyName defaultProfile -NotePropertyValue $ps7SourceGuid -Force
            Write-Success "Default profile: $($defaultPwsh.Version)"
        } else {
            Write-Warning "No PowerShell installations found in standard paths"
        }

        # ── Git Bash profile ─────────────────────────────────────────────────
        $gitBash = Get-GitBashPath
        $gitBashGuid = "{2ece5bfe-50ed-5f3a-ab87-5cd4baafed2b}"

        if ($gitBash.Found) {
            $gitProfile = $settings.profiles.list | Where-Object { $_.guid -eq $gitBashGuid }

            if ($gitProfile) {
                $gitProfile | Add-Member -NotePropertyName commandline  -NotePropertyValue "`"$($gitBash.BashPath)`" --login -i" -Force
                $gitProfile | Add-Member -NotePropertyName colorScheme  -NotePropertyValue "NeoTokyo" -Force
                $gitProfile | Add-Member -NotePropertyName tabColor     -NotePropertyValue "#20153D"  -Force
                $gitProfile | Add-Member -NotePropertyName hidden       -NotePropertyValue $false     -Force
                if ($gitBash.IconPath) {
                    $gitProfile | Add-Member -NotePropertyName icon -NotePropertyValue $gitBash.IconPath -Force
                }
            } else {
                $newGit = [PSCustomObject]@{
                    guid                     = $gitBashGuid
                    name                     = "Git Bash"
                    tabTitle                 = "Git Bash"
                    commandline              = "`"$($gitBash.BashPath)`" --login -i"
                    tabColor                 = "#20153D"
                    colorScheme              = "NeoTokyo"
                    suppressApplicationTitle = $true
                    startingDirectory        = "%USERPROFILE%"
                    useAcrylic               = $true
                    opacity                  = $opacity
                    hidden                   = $false
                }
                if ($gitBash.IconPath) {
                    $newGit | Add-Member -NotePropertyName icon -NotePropertyValue $gitBash.IconPath -Force
                }
                $settings.profiles.list = @($settings.profiles.list) + $newGit
            }
            Write-Success "Git Bash profile configured: $($gitBash.BashPath)"
        } else {
            Write-Info "Git Bash not found — skipping Git Bash profile"
        }

        # ── Apply NeoTokyo to all other existing profiles ────────────────────
        foreach ($profile in $settings.profiles.list) {
            if ($profile.guid -notin ($pwshGuids + $gitBashGuid)) {
                $profile | Add-Member -NotePropertyName colorScheme -NotePropertyValue "NeoTokyo" -Force
            }
        }

        # ── Reorder profiles ──────────────────────────────────────────────────
        # Desired order:
        #   1. PS preview (default) — or PS stable if no preview
        #   2. Git Bash
        #   3. Command Prompt
        #   4. Azure Cloud Shell
        #   5. PS stable (only when preview also exists)
        #   6. Windows PowerShell Legacy
        #   7. Any other profiles not listed above

        $cmdGuid     = "{0caa0dad-35be-5f56-a8ff-afceeeaa6101}"
        $azureGuid   = "{b453ae62-4e3d-5e58-b989-0a998ec441b8}"
        $legacyGuid  = "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}"

        # Build the priority list in order
        $priorityGuids = @(
            $ps7SourceGuid,   # PS preview or default stable
            $gitBashGuid,     # Git Bash
            $cmdGuid,         # Command Prompt
            $azureGuid        # Azure Cloud Shell
        )
        # Stable PS versions (non-default, i.e. not $ps7SourceGuid)
        foreach ($g in $pwshGuids) {
            if ($g -ne $ps7SourceGuid) { $priorityGuids += $g }
        }
        $priorityGuids += $legacyGuid  # Windows PowerShell Legacy last

        # Build ordered list
        $profileMap  = @{}
        foreach ($p in $settings.profiles.list) { $profileMap[$p.guid] = $p }

        $orderedList = @()
        foreach ($g in $priorityGuids) {
            if ($profileMap.ContainsKey($g)) { $orderedList += $profileMap[$g] }
        }
        # Append any profiles not covered above
        foreach ($p in $settings.profiles.list) {
            if ($p.guid -notin $priorityGuids) { $orderedList += $p }
        }
        $settings.profiles.list = $orderedList
        Write-Success "Profile order applied: $($orderedList | ForEach-Object { $_.name } | Join-String -Separator ' → ')"

        # ── Save ─────────────────────────────────────────────────────────────
        $settings | ConvertTo-Json -Depth 20 | Set-Content $realPath -Encoding UTF8
        Write-Success "Windows Terminal settings deployed to: $realPath"
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
    Write-Host "  NeoTokyo Theme Edition" -ForegroundColor Cyan
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

    # Step 1: Check PowerShell Version
    Write-Header "Checking PowerShell Version"
    $pwshInfo = Test-PowerShell7

    if (-not $pwshInfo.Installed) {
        Write-Warning "PowerShell 7 is not installed"
        Write-Info "Installing PowerShell 7 (required)..."
        Install-PowerShell7
        return
    }

    Write-Info "PowerShell version detected: $($pwshInfo.Version)"

    $versionBase    = [version]($pwshInfo.VersionBase)
    $minimumVersion = [version]$script:Config.MinPowerShellVersion

    if ($versionBase -lt $minimumVersion) {
        Write-Warning "PowerShell $($pwshInfo.Version) is below the minimum required version ($($script:Config.MinPowerShellVersion))"
        Write-Host ""
        Write-Host "  This theme requires PowerShell 7.6 or newer for full compatibility." -ForegroundColor Yellow
        Write-Host "  Latest stable available: $($pwshInfo.LatestStable)" -ForegroundColor Cyan
        Write-Host ""
        $upgrade = Read-Host "Upgrade PowerShell to $($pwshInfo.LatestStable) now? (Y/N)"
        if ($upgrade -eq "Y" -or $upgrade -eq "y") {
            Install-PowerShell7
            return
        } else {
            Write-Warning "Continuing with unsupported version. Some features may not work correctly."
        }
    } elseif ($pwshInfo.IsExperimental) {
        Write-Success "PowerShell $($pwshInfo.Version) (preview) detected — fully supported!"
    } elseif ($pwshInfo.IsUpToDate) {
        Write-Success "PowerShell $($pwshInfo.Version) is up to date!"
    } elseif ($pwshInfo.NeedsUpdate) {
        Write-Warning "A newer stable version is available: $($pwshInfo.LatestStable)"
        $upgrade = Read-Host "Upgrade to PowerShell $($pwshInfo.LatestStable)? (Y/N)"
        if ($upgrade -eq "Y" -or $upgrade -eq "y") {
            Install-PowerShell7
            return
        }
    }

    # Step 2: Check Windows Terminal
    Write-Header "Checking Windows Terminal"
    if (-not (Test-WindowsTerminal)) {
        Write-Warning "Windows Terminal is not installed"
        Write-Info "Installing Windows Terminal (required)..."
        Install-WindowsTerminal
    } else {
        Write-Success "Windows Terminal is installed"
    }

    # Step 3: Select Installation Mode
    if ($useEnv -and $env:INSTALL_MODE) {
        $selectedMode = [int]$env:INSTALL_MODE
        Write-Info "Using saved installation mode: $selectedMode"
    } elseif ($Mode) {
        $selectedMode = $Mode
    } else {
        Show-InstallationModes
        $selectedMode = Read-Host "Select mode (1-5)"
    }

    # Initialize preferences
    $preferences = @{
        InstallMode          = $selectedMode
        NerdFont             = "Monofoki"
        FontSize             = 14
        ThemeName            = "amro"
        TerminalOpacity      = 82
        UseAcrylic           = $true
        TerminalCols         = 90
        TerminalRows         = 30
        ShowFullPath         = $true
        ExecutionPolicy      = "RemoteSigned"
        SkipBackup           = $false
        Username             = $env:USERNAME
        GitPath              = ""
        InstallTerminalIcons = $false
    }

    # Step 4: Mode-specific Configuration
    $profileType     = "core"
    $settingsType    = "default"
    $installOhMyPosh = $true
    $installFont     = $true

    switch ($selectedMode) {
        1 {
            Write-Header "Theme Only Mode Selected"
            $profileType = "theme_only"
            $preferences.InstallTerminalIcons = $false
        }
        2 {
            Write-Header "Express Mode Selected"
            $profileType = "core"
            $preferences.InstallTerminalIcons = $false
        }
        3 {
            Write-Header "Productivity Mode Selected"
            $profileType = "productivity"
            $settingsType = "productivity"
            $preferences.InstallTerminalIcons = $true
        }
        4 {
            Write-Header "Power User Mode Selected"
            $profileType = "poweruser"
            $settingsType = "productivity"
            $preferences.InstallTerminalIcons = $true
        }
        5 {
            Write-Header "Custom Mode Selected"
            Write-Host ""

            if ($useEnv -and $env:INSTALL_TERMINAL_ICONS) {
                $preferences.InstallTerminalIcons = $env:INSTALL_TERMINAL_ICONS -eq "true"
            } else {
                $response = Read-Host "Install Terminal-Icons? (Y/N) [Colorful file icons]"
                $preferences.InstallTerminalIcons = ($response -eq "Y" -or $response -eq "y")
            }

            if ($preferences.InstallTerminalIcons) {
                $profileType  = "productivity"
                $settingsType = "productivity"
            } else {
                $profileType = "core"
            }
        }
    }

    # Step 5: Install Dependencies
    if ($installOhMyPosh) {
        if (-not (Test-OhMyPosh)) { Install-OhMyPosh }
        else { Write-Success "Oh My Posh is already installed" }
    }

    if ($installFont) { Install-MonofokiFont }

    if ($preferences.InstallTerminalIcons) { Install-TerminalIcons }

    # Check Git — always auto-detect; offer to install if missing
    $gitBash = Get-GitBashPath
    if ($gitBash.Found) {
        Write-Success "Git Bash found at: $($gitBash.BashPath)"
        $preferences.GitPath = $gitBash.BashPath
    } else {
        Write-Warning "Git / Git Bash not found"
        $installGit = Read-Host "Install Git? (Y/N)"
        if ($installGit -eq "Y" -or $installGit -eq "y") {
            Install-Git
            $gitBash = Get-GitBashPath
            if ($gitBash.Found) { $preferences.GitPath = $gitBash.BashPath }
        }
    }

    # Step 6: Backup Existing Configuration
    if (-not $preferences.SkipBackup) { Backup-ExistingConfiguration }

    # Step 7: Deploy Configuration
    Deploy-PowerShellProfile -ProfileType $profileType
    Deploy-WindowsTerminalSettings -SettingsType $settingsType -Preferences $preferences
    Deploy-OhMyPoshTheme

    # Step 8: Save Preferences
    Save-UserPreferences -Preferences $preferences

    # Step 9: Final Steps
    Write-Header "Installation Complete!"
    Write-Host ""
    Write-Success "PowerShell Terminal Setup has been installed successfully!"
    Write-Host ""
    Write-Info "Next steps:"
    Write-Host "  1. Close ALL Windows Terminal windows" -ForegroundColor Yellow
    Write-Host "  2. Open Windows Terminal" -ForegroundColor Yellow
    Write-Host "  3. Enjoy your new terminal experience!" -ForegroundColor Yellow
    Write-Host ""

    if ($preferences.InstallTerminalIcons) {
        Write-Info "Terminal-Icons installed - try 'ls' to see colorful icons!"
    }

    Write-Host ""
    Write-Host "Backup location: $($script:Config.BackupPath)" -ForegroundColor Gray
    Write-Host ""

    $restart = Read-Host "Restart Windows Terminal now? (Y/N)"
    if ($restart -eq "Y" -or $restart -eq "y") {
        Write-Info "Closing Windows Terminal..."
        Get-Process -Name "WindowsTerminal" -ErrorAction SilentlyContinue | Stop-Process -Force
        Start-Sleep -Seconds 2
        Write-Info "Starting Windows Terminal..."
        Start-Process "wt.exe"
    }

    Write-Host ""
    Write-Host "Thank you for using PowerShell Terminal Setup!" -ForegroundColor Cyan
    Write-Host ""
}

# ============================================
# Entry Point
# ============================================

# Skip execution when dot-sourced for testing
if ($env:NEOTOKYO_TESTING -ne "1") {
    try {
        Start-Installation
    }
    catch {
        Write-Error "Installation failed: $_"
        Write-Host ""
        Write-Host "Please report this issue at: https://github.com/yourusername/powershell-setup/issues" -ForegroundColor Yellow
        exit 1
    }
}
