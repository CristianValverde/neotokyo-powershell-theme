# 🚀 NeoTokyo PowerShell Theme (AMRO)

[![PowerShell](https://img.shields.io/badge/PowerShell-7.6+-blue.svg)](https://github.com/PowerShell/PowerShell)
[![Windows Terminal](https://img.shields.io/badge/Windows%20Terminal-1.12+-green.svg)](https://github.com/microsoft/terminal)
[![Oh My Posh](https://img.shields.io/badge/Oh%20My%20Posh-Latest-orange.svg)](https://ohmyposh.dev/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS-lightgrey.svg)]()

NeoTokyo brings the custom AMRO prompt and a NeoTokyo color palette to **Windows Terminal + PowerShell** and **macOS + iTerm2 + Zsh**. Choose the installation guide for your platform below.


## Choose your platform

- **Windows:** follow the PowerShell instructions below.
- **macOS:** see the [macOS installation and troubleshooting guide](macos/README.md). It uses Zsh and iTerm2, with history suggestions, icons, syntax highlighting and the NeoTokyo palette. Tested visually on a MacBook Pro M1 Max.

For macOS, clone this repository, quit iTerm2 completely and run the installer from macOS Terminal:

```sh
cd neotokyo-powershell-theme/macos
bash install.sh
```

The installer detects Homebrew and runs its official interactive installer if needed, then installs iTerm2 through Homebrew if needed. Internet access is required; Homebrew may request confirmation, administrator authentication and Apple Command Line Tools. Open iTerm2: NeoTokyo is set as the default profile. If iTerm2 restores an older window, open a new one. See the guide for prerequisites, shortcuts, backups and troubleshooting.

The macOS edition preserves the palette tested on the M1 Max; the Windows edition currently uses a softer pastel variant. The remaining sections on this page describe the Windows edition.

## Windows edition

The Windows instructions below apply to PowerShell and Windows Terminal. For macOS, use the [macOS guide](macos/README.md).

## ✨ Features

- 🎨 **Beautiful AMRO Theme** - Custom Oh My Posh theme with NeoTokyo color scheme
- ⚡ **Optimized Performance** - Fast startup times (< 2 seconds)
- 🔤 **Monofoki Nerd Font** - Crisp, modern font with full icon support
- 🌈 **Syntax Highlighting** - Color-coded commands, parameters, and strings
- 📁 **Terminal Icons** - Beautiful file and folder icons in directory listings (optional)
- 🔍 **Intelligent History** - Predictive IntelliSense based on command history
- 🎯 **Git Integration** - Real-time git branch and status information
- ⏱️ **Execution Time** - Automatic timing for long-running commands
- 🪟 **Transparency Support** - Elegant acrylic transparency effect
- 🔧 **Fully Automated** - One-command installation with smart dependency management
- 📦 **Multiple Installation Modes** - From minimal theming to full power user setup

## 📋 Prerequisites

- **Operating System:** Windows 10 (build 19041+) or Windows 11
- **Architecture:** x64 (64-bit)
- **Internet Connection:** Required for downloading dependencies
- **Permissions:** Administrator rights (for installing fonts and applications)
- **PowerShell:** Windows PowerShell 5.1+ (PowerShell 7.6+ recommended)

## ⚡ Quick Start

### Express Installation (Recommended)

1. **Download** this repository:
   ```powershell
   git clone https://github.com/CristianValverde/neotokyo-powershell-theme.git
   cd neotokyo-powershell-theme
   ```

2. **Run** the installer:
   ```powershell
   .\install.ps1
   ```

3. **Choose** your installation mode when prompted

4. **Wait** 2-3 minutes while everything installs automatically

5. **Done!** Open Windows Terminal and enjoy your new setup

## 🎨 Installation Modes

Choose the perfect setup for your needs:

### 1️⃣ Theme Only (Minimalist)
**Perfect for:** Users who already have their setup configured and only want the visual theme

**Includes:**
- ✅ AMRO Oh My Posh theme
- ✅ Monofoki Nerd Font
- ✅ NeoTokyo color scheme
- ✅ Syntax highlighting colors
- ❌ No keybinding modifications
- ❌ No function changes

**Load time:** <0.5s | **Install time:** ~1 min

---

### 2️⃣ Express (Recommended)
**Perfect for:** Most users who want a beautiful and functional terminal

**Includes:**
- ✅ Everything in Theme Only
- ✅ Essential shortcuts (Ctrl+L, Shift+Enter, history search)
- ✅ Basic navigation functions (.., ..., git shortcuts)
- ✅ Aliases (ll, grep)

**Load time:** <1s | **Install time:** ~2 min

---

### 3️⃣ Productivity (For Developers)
**Perfect for:** Developers who want maximum productivity

**Includes:**
- ✅ Everything in Express
- ✅ Terminal-Icons (colorful file icons)
- ✅ Advanced shortcuts (Ctrl+R, Ctrl+Z/Y, word navigation)
- ✅ Enhanced functions (pwdc, ex, hist)
- ✅ Quick navigation (docs, downloads, desktop)
- ✅ Tab navigation (Ctrl+Tab)
- ✅ Split panes (Alt+Shift+- and +)
- ✅ Search in terminal (Ctrl+F)

**Load time:** ~1.5s | **Install time:** ~3 min

---

### 4️⃣ Power User (Everything)
**Perfect for:** Advanced users who want all features

**Includes:**
- ✅ Everything in Productivity
- ✅ MenuComplete with Tab
- ✅ Extended aliases (touch, which)
- ✅ Docker shortcuts (d, dc, dps, di)
- ✅ Kubernetes shortcuts (k, kgp, kgs, kgd)
- ✅ Advanced Git functions (gd, gb, gco, gpull)
- ✅ Utility functions (mkcd, Get-PublicIP, Get-Weather, sysinfo, ff, pkill)
- ✅ Pane navigation (Alt+Arrows)
- ✅ Profile management (reload, edit-profile)

**Load time:** ~2s | **Install time:** ~5 min

---

### 5️⃣ Custom
**Perfect for:** Users who want to choose exactly what to install

**Includes:** Whatever you select during installation

---

## 📊 Feature Comparison

| Feature | Theme Only | Express | Productivity | Power User |
|---------|------------|---------|--------------|------------|
| AMRO Theme | ✅ | ✅ | ✅ | ✅ |
| Nerd Font | ✅ | ✅ | ✅ | ✅ |
| Color Scheme | ✅ | ✅ | ✅ | ✅ |
| Syntax Colors | ✅ | ✅ | ✅ | ✅ |
| Basic Shortcuts | ❌ | ✅ | ✅ | ✅ |
| Navigation Functions | ❌ | ✅ | ✅ | ✅ |
| Terminal-Icons | ❌ | ❌ | ✅ | ✅ |
| Advanced Shortcuts | ❌ | ❌ | ✅ | ✅ |
| Pane Navigation | ❌ | ❌ | ❌ | ✅ |
| Advanced Aliases | ❌ | ❌ | ❌ | ✅ |
| Docker/K8s Shortcuts | ❌ | ❌ | ❌ | ✅ |
| **Modifies Keybindings** | ❌ | ✅ | ✅ | ✅ |
| **Modifies Functions** | ❌ | ✅ | ✅ | ✅ |
| **Load Time** | <0.5s | <1s | ~1.5s | ~2s |
| **Install Time** | 1 min | 2 min | 3 min | 5 min |

## 📦 What Gets Installed

### macOS: iTerm2 + Zsh

The [macOS installer](macos/README.md) checks for Homebrew and iTerm2 and installs them if absent. It installs missing command-line tools with Homebrew and copies the bundled fonts and configuration. Internet access is needed; the official Homebrew installer may request confirmation, a password, or Apple Command Line Tools.

| Component | Purpose | Installation |
|-----------|---------|--------------|
| Homebrew | Package manager | Official installer, if missing |
| iTerm2 | Terminal application and visual profile | Homebrew cask, if missing |
| Zsh | Interactive shell | Uses macOS `/bin/zsh` |
| Oh My Posh | NeoTokyo prompt, Git and timing | Homebrew |
| Monofoki Nerd Font | Prompt and file icons | Four bundled font variants |
| zsh-autosuggestions | History and completion suggestions | Homebrew |
| zsh-syntax-highlighting | Command-line colors | Homebrew |
| zsh-completions | Extra completion definitions | Homebrew |
| fzf | Interactive history and file search | Homebrew |
| zoxide | Navigation to visited directories | Homebrew |
| eza | File listings with icons | Homebrew |
| bat | Syntax-highlighted file previews | Homebrew |
| ripgrep | File-name search with `ff` | Homebrew |

The installer adds a block to `${ZDOTDIR:-$HOME}/.zshrc`, copies the shell configuration and prompt to `${XDG_CONFIG_HOME:-$HOME/.config}/neotokyo`, and places the iTerm2 dynamic profile in `~/Library/Application Support/iTerm2/DynamicProfiles/NeoTokyo.json`. It sets the default iTerm2 profile and keeps backups under `${XDG_STATE_HOME:-$HOME/.local/state}/neotokyo/backups`. Git, Docker and Kubernetes are not installed by the macOS installer; their shortcuts work when those tools are available. The visual profile targets iTerm2; Zsh features also load in other interactive terminals.

### Windows: PowerShell + Windows Terminal

#### Core Components

| Component | Version | Description | Auto-Install |
|-----------|---------|-------------|--------------|
| **PowerShell 7.6+** | Latest | Modern cross-platform PowerShell | ✅ Yes |
| **Windows Terminal** | 1.12+ | Microsoft's modern terminal | ✅ Yes |
| **Oh My Posh** | Latest | Prompt theme engine | ✅ Yes |
| **Monofoki Nerd Font** | Latest | Patched font with icons | ✅ Yes |

#### Optional Components

| Component | Default | Description | Modes |
|-----------|---------|-------------|-------|
| **Git** | Ask | Git Bash profile in Terminal | Custom |
| **Terminal-Icons** | Productivity+ | Colorful file/folder icons | Productivity, Power User |
| **Command Prompt** | Ask | Classic cmd.exe profile | Custom |

#### Configuration Files

- **`Microsoft.PowerShell_profile.ps1`** - PowerShell profile with optimizations
- **`settings.json`** - Windows Terminal configuration
- **`amro.omp.json`** - Custom Oh My Posh theme

## 🔧 PowerShell Version Handling

The installer intelligently handles PowerShell versions:

| Situation | Action |
|-----------|--------|
| **No PowerShell 7** | ➡️ Installs PowerShell 7.6+ automatically |
| **PowerShell 7.0-7.5** | ➡️ Asks if you want to upgrade to 7.6+ |
| **PowerShell 7.6+** | ➡️ Continues without asking ✅ |
| **Windows PowerShell 5.1** | ➡️ Configures separate profile with lighter blue tab color |

## 🎯 Manual Installation

### macOS

The supported path is `bash macos/install.sh`; it handles dependencies, backups and the iTerm2 default profile. For manual setup or a pre-existing configuration, see [macOS manual installation](macos/README.md#instalación-manual-en-macos). The manual steps require Homebrew, iTerm2, font setup, Zsh initialization and a separate iTerm2 profile selection.

### Windows

If you prefer to install manually or the automated installer fails:

<details>
<summary>Click to expand manual installation steps</summary>

### Step 1: Install PowerShell 7.6+

```powershell
winget install Microsoft.PowerShell
```

Or download from: https://github.com/PowerShell/PowerShell/releases

### Step 2: Install Windows Terminal

```powershell
winget install Microsoft.WindowsTerminal
```

Or install from Microsoft Store

### Step 3: Install Oh My Posh

```powershell
winget install JanDeDobbeleer.OhMyPosh
```

### Step 4: Install Monofoki Nerd Font

1. Navigate to `fonts/` folder
2. Right-click `MonofokiNerdFont-Regular.ttf` (and optionally the bold and italic variants)
3. Click "Install for all users"

### Step 5: Install Terminal-Icons (Optional)

```powershell
Install-Module -Name Terminal-Icons -Scope CurrentUser -Force
```

### Step 6: Copy Configuration Files

```powershell
# Choose your profile variant
$profileVariant = "profile_productivity.ps1"  # or profile_core.ps1, profile_poweruser.ps1, profile_theme_only.ps1

# Copy PowerShell Profile
Copy-Item "config/$profileVariant" -Destination $PROFILE -Force

# Oh My Posh Theme
$themePath = "$env:USERPROFILE\Documents\PowerShell\themes"
New-Item -ItemType Directory -Path $themePath -Force
Copy-Item "config/themes/amro.omp.json" -Destination "$themePath\amro.omp.json" -Force

# Windows Terminal Settings
$wtSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
Copy-Item "config/settings.json" -Destination $wtSettingsPath -Force
```

### Step 7: Restart Windows Terminal

Close all Windows Terminal windows and reopen.

</details>

## 🔍 Troubleshooting

For macOS, see [checks and troubleshooting](macos/README.md#comprobaciones-rápidas). The following items apply to Windows.

### Profile loads slowly (> 5 seconds)

**Cause:** Usually Terminal-Icons module or network timeout

**Solution:**
```powershell
# Disable Terminal-Icons temporarily
# Edit your profile and comment out:
# Import-Module Terminal-Icons
```

### "CONFIG PARSE ERROR" in Oh My Posh

**Cause:** Syntax error in `amro.omp.json`

**Solution:**
```powershell
# Validate JSON syntax
Get-Content "$env:USERPROFILE\Documents\PowerShell\themes\amro.omp.json" | ConvertFrom-Json
```

### Icons not displaying correctly

**Cause:** Nerd Font not installed or not selected in Windows Terminal

**Solution:**
1. Verify font is installed: Settings → Fonts in Windows
2. Check Windows Terminal settings: Settings → Defaults → Font face → "Monofoki Nerd Font"

### PowerShell execution policy error

**Cause:** Scripts are blocked by default

**Solution:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Git Bash profile not working

**Cause:** Git not installed or wrong path

**Solution:**
1. Install Git: `winget install Git.Git`
2. Update path in `settings.json` to match your Git installation

### Colors look wrong

**Cause:** Terminal doesn't support true color

**Solution:**
- Ensure you're using Windows Terminal (not legacy console)
- Update Windows Terminal to latest version

### Load time is too slow

**Cause:** Too many features for your needs

**Solution:**
- Run installer again and choose a lighter mode (Theme Only or Express)
- Or manually switch to a lighter profile variant

## 🎨 Customization for Enthusiasts

### macOS

Use `edit-profile` to edit `${XDG_CONFIG_HOME:-$HOME/.config}/neotokyo/local.zsh`; `reload` starts a new Zsh session. Change the prompt in `neotokyo.omp.json` and the iTerm2 colors, font or transparency in the dynamic profile under `~/Library/Application Support/iTerm2/DynamicProfiles/`. Duplicate the profile in iTerm2 for UI edits that survive reinstallations. [The macOS customization guide](macos/README.md#ajustes-personales) explains these paths, shortcuts and the differences between the shell and the terminal profile.

### Windows

The following examples customize the PowerShell and Windows Terminal edition.

### 🔤 Changing Nerd Fonts

The default **Monofoki Nerd Font** is great, but you might want to try others:

#### 1. Browse Available Fonts

Visit: **https://www.nerdfonts.com/font-downloads**

Popular alternatives:
- **FiraCode Nerd Font** - Modern, clean ligatures
- **JetBrainsMono Nerd Font** - Designed for developers
- **CascadiaCode Nerd Font** - Microsoft's modern font
- **Hack Nerd Font** - Classic programming font
- **MesloLGS Nerd Font** - Popular with Oh My Posh

#### 2. Download and Install

1. Download your chosen font from Nerd Fonts website
2. Extract the `.ttf` or `.otf` files
3. Right-click → "Install for all users"

#### 3. Update Windows Terminal Settings

Edit your `settings.json` (Ctrl+Shift+, in Windows Terminal):

```json
"defaults": {
    "font": {
        "face": "FiraCode Nerd Font",  // Change this
        "size": 14
    }
}
```

#### 4. Restart Windows Terminal

Close all tabs and reopen.

---

### 🎨 Exploring Oh My Posh Themes

Oh My Posh has **hundreds** of pre-built themes to choose from!

#### 1. Browse All Themes

Visit: **https://ohmyposh.dev/docs/themes**

Or preview them directly in your terminal:

```powershell
Get-PoshThemes
```

Popular themes:
- **agnoster** - Classic, clean design
- **paradox** - Minimalist with git info
- **powerlevel10k_rainbow** - Colorful and informative
- **atomic** - Modern and sleek
- **jandedobbeleer** - Creator's personal theme

#### 2. Test a Theme Temporarily

```powershell
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\agnoster.omp.json" | Invoke-Expression
```

#### 3. Apply Permanently

Edit your PowerShell profile:

```powershell
notepad $PROFILE
```

Change the Oh My Posh line:

```powershell
# From:
oh-my-posh init pwsh --config "$env:USERPROFILE\Documents\PowerShell\themes\amro.omp.json" | Invoke-Expression

# To:
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\agnoster.omp.json" | Invoke-Expression
```

#### 4. Create Your Own Theme

Copy AMRO theme and customize:

```powershell
Copy-Item "$env:USERPROFILE\Documents\PowerShell\themes\amro.omp.json" "$env:USERPROFILE\Documents\PowerShell\themes\mytheme.omp.json"
code "$env:USERPROFILE\Documents\PowerShell\themes\mytheme.omp.json"
```

---

### 🎯 Customizing Icons in AMRO Theme

Want different icons in your prompt? Here's how!

#### 1. Browse Nerd Fonts Icons

Visit: **https://www.nerdfonts.com/cheat-sheet**

Search for icons by name (folder, git, time, etc.)

#### 2. Edit Your Theme

Open your AMRO theme:

```powershell
code "$env:USERPROFILE\Documents\PowerShell\themes\amro.omp.json"
```

#### 3. Replace Icon Unicode

Find the segment you want to change and replace the icon:

```json
{
    "type": "path",
    "template": " \uf07c {{ .Path }} "  // Change \uf07c to your icon
}
```

#### 4. Common Icon Alternatives

| Element | Current | Alternatives |
|---------|---------|--------------|
| **Folder** | `\uf07c` | `\uf115` (open folder), `\uf74a` (modern), `\uf413` (bordered) |
| **Git** | `\uea84` | `\ue702`, `\uf1d3`, `\uf7a1` |
| **User** | `\ueb99` | `\uf007`, `\uf2c0`, `\uf500` |
| **Time** | `\uf017` | `\uf64f`, `\uf43a` |
| **Execution** | `\uf252` | `\uf017`, `\uf520` |
| **Root** | `\ue3bf` | `\uf0e7`, `\uf132` |

#### 5. Test Your Changes

Reload your profile:

```powershell
. $PROFILE
```

---

### 🌈 Customizing Color Schemes

Want different colors? You can modify the NeoTokyo scheme or create your own!

#### 1. Edit Windows Terminal Settings

```powershell
# Open settings.json
code "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
```

#### 2. Modify NeoTokyo Colors

Find the `"schemes"` section and edit colors:

```json
{
    "name": "NeoTokyo",
    "background": "#0B1020",    // Change background
    "foreground": "#A7E7F2",    // Change text color
    "cursorColor": "#F4A3C4",   // Change cursor
    // ... modify other colors
}
```

#### 3. Or Add a New Scheme

Popular alternatives:
- **Dracula** - Purple and pink tones
- **Nord** - Cool blue palette
- **Gruvbox** - Warm retro colors
- **One Dark** - Atom editor colors

Visit: https://windowsterminalthemes.dev/

#### 4. Apply Your Scheme

In `settings.json`, change the default:

```json
"defaults": {
    "colorScheme": "YourSchemeName"
}
```

---

### ⌨️ Adding Custom Keybindings

Want more shortcuts? Add them to Windows Terminal!

#### 1. Edit Settings

```powershell
code "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
```

#### 2. Add to "actions" Array

```json
"actions": [
    {
        "command": "closePane",
        "keys": "ctrl+w"
    },
    {
        "command": { "action": "resizePane", "direction": "left" },
        "keys": "alt+h"
    }
    // Add more...
]
```

#### 3. Useful Actions

- `closePane` - Close current pane
- `resizePane` - Resize panes
- `toggleFullscreen` - Fullscreen mode
- `openSettings` - Open settings
- `renameTab` - Rename current tab

---

### 🔧 Advanced Profile Customization

#### Add Your Own Functions

Edit your profile:

```powershell
code $PROFILE
```

Add custom functions:

```powershell
# Quick edit hosts file
function edit-hosts {
    sudo notepad C:\Windows\System32\drivers\etc\hosts
}

# Open project in VS Code
function code-project {
    param([string]$name)
    code "C:\Projects\$name"
}

# Quick commit
function qc {
    param([string]$message)
    git add .
    git commit -m $message
    git push
}
```

#### Add Environment Variables

```powershell
# Add to your profile
$env:MY_PROJECT_PATH = "C:\Projects"
$env:MY_API_KEY = "your-api-key"
```

#### Create Custom Aliases

```powershell
Set-Alias -Name py -Value python
Set-Alias -Name g -Value git
Set-Alias -Name v -Value code
```

---

### 📚 Additional Resources

- **Oh My Posh Documentation:** https://ohmyposh.dev/docs
- **Windows Terminal Documentation:** https://docs.microsoft.com/en-us/windows/terminal/
- **PowerShell Documentation:** https://docs.microsoft.com/en-us/powershell/
- **Nerd Fonts:** https://www.nerdfonts.com/
- **PSReadLine Documentation:** https://docs.microsoft.com/en-us/powershell/module/psreadline/

---

## 📜 Credits & Licenses

NeoTokyo's project code uses the [MIT license](LICENSE). Its dependencies are separate projects and retain their own licenses. macOS tools are installed through Homebrew; they are not bundled as executables in this repository. Windows may install or use additional tools depending on the chosen mode.

| Project | Used by | License / source |
|---------|---------|------------------|
| [Oh My Posh](https://github.com/JanDeDobbeleer/oh-my-posh) | Windows and macOS prompt | [MIT](https://github.com/JanDeDobbeleer/oh-my-posh/blob/main/LICENSE) |
| [Monofoki Nerd Font](https://github.com/ryanoasis/nerd-fonts) | Bundled fonts and icons | Monofoki by Marvin Dostal, [SIL OFL 1.1](fonts/LICENSE-Monofoki); see the [Nerd Fonts license](fonts/LICENSE-nerd-font) and [glyph license audit](fonts/license-audit-nerd-font.md) |
| [PowerShell](https://github.com/PowerShell/PowerShell) and [Windows Terminal](https://github.com/microsoft/terminal) | Windows | See the respective project licenses |
| [Terminal-Icons](https://github.com/devblackops/Terminal-Icons) | Windows, optional | See its repository license |
| [Homebrew](https://github.com/Homebrew/brew) | macOS package manager | [BSD-2-Clause](https://github.com/Homebrew/brew/blob/main/LICENSE.txt) |
| [iTerm2](https://github.com/gnachman/iTerm2) and [Zsh](https://www.zsh.org/) | macOS terminal and shell | See their respective project licenses |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions), [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting), [zsh-completions](https://github.com/zsh-users/zsh-completions) | macOS editing and completion | See each repository's license |
| [fzf](https://github.com/junegunn/fzf), [zoxide](https://github.com/ajeetdsouza/zoxide), [eza](https://github.com/eza-community/eza), [bat](https://github.com/sharkdp/bat), [ripgrep](https://github.com/BurntSushi/ripgrep) | macOS search, navigation and listings | See each repository's license; eza uses [EUPL-1.2](https://github.com/eza-community/eza/blob/main/LICENSE.txt) |

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

### Reporting Issues

Found a bug? Have a suggestion?

1. Check if the issue already exists
2. Create a new issue with:
   - Clear description
   - Steps to reproduce
   - Your operating system version, terminal and shell versions
   - Screenshots if applicable

### Submitting Changes

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style

- Use clear, descriptive variable names
- Comment complex logic
- Follow PowerShell or Zsh best practices as appropriate
- Test on the affected platform and describe any limitations

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

### What this means:

✅ **You CAN:**
- Use this commercially
- Modify the code
- Distribute it
- Use it privately
- Sublicense it

❌ **You CANNOT:**
- Hold the authors liable
- Use authors' names for endorsement

📋 **You MUST:**
- Include the original license
- Include copyright notice

---

## 💬 Support

Need help? Here's how to get support:

- 📖 **Documentation:** Check this README
- 🐛 **Bug Reports:** [Open an issue](https://github.com/CristianValverde/neotokyo-powershell-theme/issues)
- 💡 **Feature Requests:** [Open an issue](https://github.com/CristianValverde/neotokyo-powershell-theme/issues)

---

## ⭐ Show Your Support

If you found this project helpful, please consider:

- ⭐ Starring the repository
- 🐦 Sharing it on social media
- 🤝 Contributing improvements

---

## 🗺️ Roadmap

Future improvements planned:

- [x] macOS support with iTerm2 and Zsh
- [ ] Linux support
- [ ] GUI installer
- [ ] More theme variants
- [ ] Integration with popular dev tools
- [ ] Auto-update functionality
- [ ] Theme marketplace/gallery
- [ ] Video tutorials

---

<p align="center">
  Made with ❤️ by [Cristian de Andrade Valverde](https://github.com/CristianValverde)
</p>

<p align="center">
  <a href="#-neotokyo-powershell-theme-amro">Back to top ↑</a>
</p>
