# ============================================
# PowerShell Profile - Theme Only Edition
# Visual styling without modifying functionality
# ============================================

# Output rendering
$PSStyle.OutputRendering = 'Host'

# Suppress progress bars for faster module loading
$global:ProgressPreference = 'SilentlyContinue'

# ============================================
# PSReadLine Colors
# ============================================

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
# Oh My Posh
# ============================================

$omp_config = "$env:USERPROFILE\Documents\PowerShell\themes\amro.omp.json"
if (Test-Path $omp_config) {
    oh-my-posh init pwsh --config $omp_config | Invoke-Expression
}

# ============================================
# Window Title
# ============================================

$Host.UI.RawUI.WindowTitle = "PowerShell 7"
