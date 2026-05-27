@echo off
REM ============================================
REM PowerShell Terminal Setup - Batch Wrapper
REM ============================================

setlocal enabledelayedexpansion

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process cmd -ArgumentList '/c %~s0' -Verb RunAs"
    exit /b
)

REM Navigate to script directory
cd /d "%~dp0"

REM Set execution policy and run installer
powershell -NoProfile -ExecutionPolicy Bypass -Command "& '.\install.ps1'"

pause
