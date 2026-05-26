# ============================================
# PowerShell Profile - Power User Edition
# Full-featured setup with all enhancements
# ============================================

# Output rendering
$PSStyle.OutputRendering = 'Host'

# Suppress progress bars for faster module loading
$global:ProgressPreference = 'SilentlyContinue'

# ============================================
# PSReadLine Configuration - Advanced
# ============================================

Set-PSReadLineKeyHandler -Chord Shift+Enter -Function AddLine
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Ctrl+l -Function ClearScreen

# Advanced shortcuts
Set-PSReadLineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory
Set-PSReadLineKeyHandler -Key Ctrl+z -Function Undo
Set-PSReadLineKeyHandler -Key Ctrl+y -Function Redo
Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow -Function BackwardWord
Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord
Set-PSReadLineKeyHandler -Key Ctrl+Backspace -Function BackwardKillWord
Set-PSReadLineKeyHandler -Key Ctrl+Delete -Function KillWord
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle InlineView
Set-PSReadLineOption -MaximumHistoryCount 50000
Set-PSReadLineOption -ShowToolTips
Set-PSReadLineOption -EditMode Windows

# PSReadLine Colors
Set-PSReadLineOption -Colors @{
    Command          = '#FF79C6'
    Operator         = '#FF79C6'
    Parameter        = '#00F5D4'
    Member           = '#00F5D4'
    Variable         = '#9D4EDD'
    String           = '#5B8CFF'
    Number           = '#FFB86C'
    Type             = '#8BE9FD'
    Keyword          = '#8BE9FD'
    Default          = '#8BE9FD'
    Comment          = '#6A9955'
    InlinePrediction = '#6A9955'
    Error            = '#FF5F87'
}

# ============================================
# ANSI Formatting
# ============================================

$PSStyle.Formatting.Error   = "`e[38;2;255;95;135m"
$PSStyle.Formatting.Warning = "`e[38;2;255;184;108m"
$PSStyle.Formatting.Verbose = "`e[38;2;139;233;253m"
$PSStyle.Formatting.Debug   = "`e[38;2;157;78;221m"

# ============================================
# Terminal Icons (only in Windows Terminal)
# ============================================

if ($env:WT_SESSION) {
    Import-Module Terminal-Icons -ErrorAction SilentlyContinue
}

# ============================================
# Oh My Posh
# ============================================

$omp_config = "$env:USERPROFILE\Documents\PowerShell\themes\amro.omp.json"
if (Test-Path $omp_config) {
    oh-my-posh init pwsh --config $omp_config | Invoke-Expression
}

# ============================================
# Window Title
# ============================================

$Host.UI.RawUI.WindowTitle = "PowerShell 7 - Power User"

# ============================================
# Aliases - Extended
# ============================================

Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name grep -Value Select-String
Set-Alias -Name touch -Value New-Item
Set-Alias -Name which -Value Get-Command

# ============================================
# Functions - Power User
# ============================================

# Navigation
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function .... { Set-Location ../../.. }
function docs { Set-Location "$HOME\Documents" }
function downloads { Set-Location "$HOME\Downloads" }
function desktop { Set-Location "$HOME\Desktop" }
function repos { Set-Location "$HOME\repos" }

# Git shortcuts
function gs { git status }
function ga { git add . }
function gc { git commit $args }
function gp { git push }
function gl { git log --oneline --graph --decorate --all }
function gd { git diff }
function gb { git branch }
function gco { git checkout $args }
function gpull { git pull }

# Kubernetes
function k { kubectl $args }
function kgp { kubectl get pods }
function kgs { kubectl get services }
function kgd { kubectl get deployments }
function kdp { kubectl describe pod $args }

# Docker shortcuts
function d { docker $args }
function dc { docker-compose $args }
function dps { docker ps }
function dpsa { docker ps -a }
function di { docker images }

# Utility functions
function hist {
    Get-Content (Get-PSReadLineOption).HistorySavePath | Select-Object -Last 50
}

function histall {
    Get-Content (Get-PSReadLineOption).HistorySavePath
}

function pwdc {
    $pwd.Path | Set-Clipboard
    Write-Host "📋 Path copied: $($pwd.Path)" -ForegroundColor Green
}

function ex {
    explorer.exe .
}

function reload {
    . $PROFILE
    Write-Host "✅ Profile reloaded" -ForegroundColor Green
}

function edit-profile {
    code $PROFILE
}

function mkcd {
    param([string]$path)
    New-Item -ItemType Directory -Path $path -Force | Out-Null
    Set-Location $path
}

function Get-PublicIP {
    (Invoke-WebRequest -Uri "https://api.ipify.org").Content
}

function Get-Weather {
    param([string]$City = "")
    if ($City) {
        curl "wttr.in/$City"
    } else {
        curl "wttr.in"
    }
}

# System info
function sysinfo {
    Get-ComputerInfo | Select-Object CsName, WindowsVersion, OsArchitecture, CsTotalPhysicalMemory
}

# Find files
function ff {
    param([string]$name)
    Get-ChildItem -Recurse -Filter "*$name*" -ErrorAction SilentlyContinue
}

# Process management
function pkill {
    param([string]$name)
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process -Force
}

# ============================================
# Startup
# ============================================

Set-Location $HOME
Clear-Host

# Welcome message
Write-Host "⚡ PowerShell Power User Mode" -ForegroundColor Cyan
Write-Host "Type 'Get-Command -CommandType Function' to see all available functions" -ForegroundColor DarkGray
Write-Host ""
