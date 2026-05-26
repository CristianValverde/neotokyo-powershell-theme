# Contributing to PowerShell Terminal Setup

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## 🤝 How to Contribute

### Reporting Bugs

If you find a bug, please create an issue with:

- **Clear title** describing the problem
- **Steps to reproduce** the issue
- **Expected behavior** vs actual behavior
- **Environment details:**
  - Windows version
  - PowerShell version
  - Windows Terminal version
  - Installation mode used

### Suggesting Features

Feature requests are welcome! Please:

1. Check if the feature already exists or is planned
2. Create an issue with the `enhancement` label
3. Describe the feature and its use case
4. Explain why it would be useful

### Submitting Pull Requests

1. **Fork the repository**
2. **Create a feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
4. **Test thoroughly:**
   - Test on fresh Windows installation if possible
   - Test all installation modes
   - Verify backward compatibility
5. **Commit with clear messages:**
   ```bash
   git commit -m "Add: New feature description"
   ```
6. **Push to your fork:**
   ```bash
   git push origin feature/your-feature-name
   ```
7. **Create a Pull Request**

## 📋 Development Guidelines

### Code Style

#### PowerShell Scripts
- Use **PascalCase** for function names
- Use **camelCase** for variables
- Add comments for complex logic
- Follow existing code structure
- Use `Write-Host` with colors for user messages

#### JSON Files
- Use **2 spaces** for indentation
- Keep consistent formatting
- Validate JSON before committing

### Testing

Before submitting a PR, test:

1. **Fresh installation** (no existing config)
2. **Upgrade scenario** (existing config present)
3. **All installation modes:**
   - Theme Only
   - Express
   - Productivity
   - Power User
   - Custom
4. **Edge cases:**
   - No internet connection
   - Missing dependencies
   - Experimental PowerShell versions

### Documentation

- Update **README.md** if adding features
- Add comments to complex code
- Update **CHANGELOG.md** (if exists)

## 🎨 Adding New Themes

To add a new Oh My Posh theme:

1. Create theme file in `config/themes/`
2. Follow Oh My Posh schema
3. Test with all profiles
4. Update documentation
5. Add screenshot

## 🔧 Adding New Profiles

To add a new profile variant:

1. Create in `config/` with descriptive name
2. Follow existing profile structure
3. Add to installer options
4. Update comparison table in README
5. Test load time

## 🐛 Debugging

### Enable verbose output:
```powershell
$VerbosePreference = "Continue"
.\install.ps1
```

### Check logs:
```powershell
Get-Content "$env:TEMP\powershell-setup-install.log"
```

## 📝 Commit Message Guidelines

Use conventional commits:

- `Add:` New feature
- `Fix:` Bug fix
- `Update:` Update existing feature
- `Docs:` Documentation changes
- `Style:` Code style changes (formatting)
- `Refactor:` Code refactoring
- `Test:` Adding tests
- `Chore:` Maintenance tasks

Examples:
```
Add: Support for custom color schemes
Fix: Installation fails on Windows 10 1909
Update: Oh My Posh to latest version
Docs: Add troubleshooting section for font issues
```

## 🌍 Internationalization

Currently, the project is in English. If you want to add translations:

1. Create `i18n/` folder
2. Add language files (e.g., `es.json`, `fr.json`)
3. Update installer to support language selection
4. Keep English as default

## 🔒 Security

If you discover a security vulnerability:

1. **DO NOT** create a public issue
2. Email the maintainers directly
3. Provide detailed information
4. Allow time for a fix before disclosure

## 📜 License

By contributing, you agree that your contributions will be licensed under the MIT License.

## 🙏 Recognition

Contributors will be:
- Listed in README.md
- Mentioned in release notes
- Credited in commit history

## ❓ Questions?

- Create a **Discussion** on GitHub
- Check existing **Issues**
- Read the **README.md**

---

Thank you for contributing! 🚀
