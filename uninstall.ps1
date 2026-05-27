#Requires -RunAsAdministrator

<#
.SYNOPSIS
    PowerShell Terminal Setup - Uninstaller

.DESCRIPTION
    Uninstalls PowerShell Terminal Setup and restores previous configuration.
    Can selectively remove components or perform a complete uninstallation.

.PARAMETER Full
    Performs a complete uninstallation including Oh My Posh and fonts

.PARAMETER KeepBackup
    Keeps backup files after restoration

.EXAMPLE
    .\uninstall.ps1
    Interactive uninstallation with options

.EXAMPLE
    .\uninstall.ps1 -Full
    Complete uninstallation including all dependencies

.NOTES
    Version: 1.0.0
    Requires: Administrator privileges for font removal
#>

param(
    [Parameter(Mandatory=$false)]
    [switch]$Full,
    
    [Parameter(Mandatory=$false)]
    [switch]$KeepBackup
)

# ============================================
# Configuration
# ============================================

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$script:Config = @{
    ProfilePath   = $PROFILE
    SettingsPath  = $(
        # Same detection logic as the installer: prefer the Store path
        $storePath   = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
        $legacyPath  = "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
        if     (Test-Path $storePath)  { $storePath  }
        elseif (Test-Path $legacyPath) { $legacyPath }
        else   { $storePath }   # default to Store path even if not yet created
    )
    ThemePath     = "$env:USERPROFILE\Documents\PowerShell\themes"
    BackupPattern = "$env:USERPROFILE\PowerShell_Backup_*"
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
# Backup Detection
# ============================================

function Get-LatestBackup {
    $backups = Get-ChildItem -Path $env:USERPROFILE -Directory -Filter "PowerShell_Backup_*" -ErrorAction SilentlyContinue |
               Sort-Object Name -Descending |
               Select-Object -First 1
    
    return $backups
}

# ============================================
# Restoration Functions
# ============================================

function Restore-Profile {
    param([string]$BackupPath)
    
    Write-Info "Restoring PowerShell profile..."
    
    $backupProfile = Join-Path $BackupPath "Microsoft.PowerShell_profile.ps1"
    
    if (Test-Path $backupProfile) {
        Copy-Item -Path $backupProfile -Destination $script:Config.ProfilePath -Force
        Write-Success "Profile restored from backup"
    } else {
        if (Test-Path $script:Config.ProfilePath) {
            Remove-Item -Path $script:Config.ProfilePath -Force
            Write-Success "Profile removed (no backup found)"
        }
    }
}

function Restore-Settings {
    param([string]$BackupPath)
    
    Write-Info "Restoring Windows Terminal settings..."
    
    $backupSettings = Join-Path $BackupPath "settings.json"
    
    if (Test-Path $backupSettings) {
        Copy-Item -Path $backupSettings -Destination $script:Config.SettingsPath -Force
        Write-Success "Settings restored from backup"
    } else {
        Write-Warning "No settings backup found, keeping current settings"
    }
}

function Remove-Theme {
    Write-Info "Removing Oh My Posh theme..."
    
    $amroTheme = Join-Path $script:Config.ThemePath "amro.omp.json"
    
    if (Test-Path $amroTheme) {
        Remove-Item -Path $amroTheme -Force
        Write-Success "AMRO theme removed"
    }
    
    # Remove themes folder if empty
    if (Test-Path $script:Config.ThemePath) {
        $items = Get-ChildItem -Path $script:Config.ThemePath
        if ($items.Count -eq 0) {
            Remove-Item -Path $script:Config.ThemePath -Force
            Write-Success "Themes folder removed (empty)"
        }
    }
}

function Uninstall-TerminalIcons {
    Write-Info "Checking for Terminal-Icons module..."
    
    $module = Get-Module -Name Terminal-Icons -ListAvailable
    
    if ($module) {
        $response = Read-Host "Remove Terminal-Icons module? (Y/N)"
        if ($response -eq "Y") {
            Uninstall-Module -Name Terminal-Icons -Force -ErrorAction SilentlyContinue
            Write-Success "Terminal-Icons module removed"
        }
    }
}

function Uninstall-OhMyPosh {
    Write-Info "Checking for Oh My Posh..."
    
    $omp = Get-Command oh-my-posh -ErrorAction SilentlyContinue
    
    if ($omp) {
        $response = Read-Host "Remove Oh My Posh? (Y/N)"
        if ($response -eq "Y") {
            try {
                winget uninstall JanDeDobbeleer.OhMyPosh
                Write-Success "Oh My Posh removed"
            } catch {
                Write-Warning "Could not remove Oh My Posh automatically. Remove manually via Settings > Apps"
            }
        }
    }
}

function Uninstall-Font {
    Write-Info "Checking for Monofoki Nerd Font..."
    
    $fontsFolder = [System.Environment]::GetFolderPath('Fonts')
    $fontFiles = Get-ChildItem -Path $fontsFolder -Filter "*Monofoki*" -ErrorAction SilentlyContinue
    
    if ($fontFiles) {
        $response = Read-Host "Remove Monofoki Nerd Font? (Y/N)"
        if ($response -eq "Y") {
            foreach ($font in $fontFiles) {
                try {
                    Remove-Item -Path $font.FullName -Force
                    Write-Success "Font removed: $($font.Name)"
                } catch {
                    Write-Warning "Could not remove font: $($font.Name). Remove manually from Fonts folder"
                }
            }
        }
    }
}

function Remove-BackupFolder {
    param([string]$BackupPath)
    
    if (-not $KeepBackup) {
        $response = Read-Host "Delete backup folder? (Y/N)"
        if ($response -eq "Y") {
            Remove-Item -Path $BackupPath -Recurse -Force
            Write-Success "Backup folder deleted"
        } else {
            Write-Info "Backup kept at: $BackupPath"
        }
    } else {
        Write-Info "Backup kept at: $BackupPath"
    }
}

# ============================================
# Main Uninstallation
# ============================================

function Start-Uninstallation {
    Write-Header "PowerShell Terminal Setup - Uninstaller"
    
    Write-Warning "This will remove PowerShell Terminal Setup configuration"
    Write-Host ""
    
    # Find latest backup
    $latestBackup = Get-LatestBackup
    
    if ($latestBackup) {
        Write-Info "Found backup: $($latestBackup.Name)"
        Write-Info "Created: $($latestBackup.CreationTime)"
        Write-Host ""
    } else {
        Write-Warning "No backup found. Configuration will be removed without restoration."
        Write-Host ""
        $continue = Read-Host "Continue anyway? (Y/N)"
        if ($continue -ne "Y") {
            Write-Info "Uninstallation cancelled"
            exit 0
        }
    }
    
    # Uninstallation options
    if (-not $Full) {
        Write-Host "Uninstallation options:" -ForegroundColor Yellow
        Write-Host "1. Restore backup only (keep Oh My Posh, fonts, modules)"
        Write-Host "2. Full uninstallation (remove everything)"
        Write-Host ""
        $option = Read-Host "Select option (1/2)"
        
        if ($option -eq "2") {
            $Full = $true
        }
    }
    
    Write-Host ""
    Write-Info "Starting uninstallation..."
    Write-Host ""
    
    # Restore from backup
    if ($latestBackup) {
        Restore-Profile -BackupPath $latestBackup.FullName
        Restore-Settings -BackupPath $latestBackup.FullName
    } else {
        # Remove without backup
        if (Test-Path $script:Config.ProfilePath) {
            Remove-Item -Path $script:Config.ProfilePath -Force
            Write-Success "Profile removed"
        }
    }
    
    # Remove theme
    Remove-Theme
    
    # Full uninstallation
    if ($Full) {
        Write-Host ""
        Write-Info "Performing full uninstallation..."
        Write-Host ""
        
        Uninstall-TerminalIcons
        Uninstall-OhMyPosh
        Uninstall-Font
    }
    
    # Clean up backup
    if ($latestBackup) {
        Write-Host ""
        Remove-BackupFolder -BackupPath $latestBackup.FullName
    }
    
    Write-Host ""
    Write-Header "Uninstallation Complete"
    
    Write-Success "PowerShell Terminal Setup has been uninstalled"
    Write-Host ""
    Write-Info "Please restart Windows Terminal for changes to take effect"
    Write-Host ""
    
    if ($Full) {
        Write-Info "Note: PowerShell 7 and Windows Terminal were not removed"
        Write-Info "Remove them manually if desired via Settings > Apps"
    }
    
    Write-Host ""
}

# ============================================
# Entry Point
# ============================================

try {
    Start-Uninstallation
} catch {
    Write-Error "Uninstallation failed: $_"
    Write-Host ""
    Write-Info "Please report this issue on GitHub"
    exit 1
}
