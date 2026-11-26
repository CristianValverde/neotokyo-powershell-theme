#!/bin/bash
# Compatible with the Bash 3.2 shipped with macOS.
set -euo pipefail

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
[[ "$(uname -s)" == Darwin ]] || die 'Este instalador debe ejecutarse en el Mac.'
[[ "$EUID" -ne 0 ]] || die 'Ejecuta el instalador con tu usuario, sin sudo.'
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/neotokyo"
ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"
PROFILE="$HOME/Library/Application Support/iTerm2/DynamicProfiles/NeoTokyo.json"
BACKUP="${XDG_STATE_HOME:-$HOME/.local/state}/neotokyo/backups/$(date +%Y%m%d-%H%M%S)-$$"
START='# >>> NeoTokyo >>>'
END='# <<< NeoTokyo <<<'
ITERM_GUID='e4291583-e47f-4ddf-8f63-193af92108fb'
DEFAULT_BACKUP="$CONFIG/previous-iterm-default"

if pgrep -x iTerm2 >/dev/null 2>&1; then
    die 'Cierra iTerm2 por completo con Cmd+Q y ejecuta de nuevo el instalador desde Terminal de macOS.'
fi

[[ -d "$(dirname "$ZSHRC")" ]] || die 'La carpeta ZDOTDIR no existe.'
[[ ! -e "$ZSHRC" || -f "$ZSHRC" ]] || die '.zshrc no es un archivo normal.'
[[ ! -L "$ZSHRC" || -e "$ZSHRC" ]] || die '.zshrc es un enlace roto.'
if [[ -f "$ZSHRC" ]]; then
    starts=$(grep -cFx "$START" "$ZSHRC" || true)
    ends=$(grep -cFx "$END" "$ZSHRC" || true)
    [[ "$starts" == "$ends" && "$starts" -le 1 ]] || die 'Hay un bloque NeoTokyo incompleto o duplicado en .zshrc.'
    awk -v start="$START" -v end="$END" '$0 == start { depth++; if (depth != 1) bad=1 } $0 == end { depth--; if (depth != 0) bad=1 } END { exit (bad || depth) }' "$ZSHRC" || die 'El orden de los marcadores NeoTokyo en .zshrc no es válido.'
fi

if [[ "$(uname -m)" == x86_64 && "$(sysctl -in sysctl.proc_translated 2>/dev/null || true)" == 1 ]]; then
    die 'Abre Terminal sin Rosetta para instalar las herramientas nativas del M1.'
fi
find_brew() {
    if [[ "$(uname -m)" == arm64 && -x /opt/homebrew/bin/brew ]]; then
        printf '%s\n' /opt/homebrew/bin/brew
    elif [[ -x /usr/local/bin/brew ]]; then
        printf '%s\n' /usr/local/bin/brew
    else
        command -v brew || true
    fi
}
BREW=$(find_brew)
if [[ -z "$BREW" ]]; then
    [[ -t 0 && -t 1 ]] || die 'La instalación de Homebrew requiere una terminal interactiva. Ejecuta bash install.sh en Terminal.'
    printf 'Homebrew no está instalado. Se iniciará su instalador oficial, que puede solicitar confirmación y contraseña.\n'
    brew_installer=$(mktemp "${TMPDIR:-/tmp}/neotokyo-homebrew.XXXXXXXX") || die 'No se pudo crear un archivo temporal.'
    trap 'rm -f -- "$brew_installer"' EXIT
    if ! curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$brew_installer"; then
        die 'No se pudo descargar el instalador oficial de Homebrew. Comprueba la conexión y vuelve a intentarlo.'
    fi
    if ! /bin/bash "$brew_installer"; then
        die 'La instalación de Homebrew no terminó correctamente. Revisa el mensaje anterior y vuelve a intentarlo.'
    fi
    rm -f -- "$brew_installer"
    trap - EXIT
    BREW=$(find_brew)
    [[ -n "$BREW" ]] || die 'Homebrew terminó pero no se encuentra brew. Sigue las indicaciones de Homebrew y vuelve a ejecutar el instalador.'
fi
if [[ "$(uname -m)" == arm64 && "$("$BREW" --prefix)" != /opt/homebrew ]]; then
    die 'En Apple Silicon utiliza Homebrew nativo en /opt/homebrew.'
fi

printf 'Instalando las herramientas de NeoTokyo…\n'
missing=()
for formula in jandedobbeleer/oh-my-posh/oh-my-posh zsh-autosuggestions zsh-syntax-highlighting zsh-completions fzf zoxide eza bat ripgrep; do
    if ! "$BREW" list --formula "$formula" >/dev/null 2>&1; then
        missing+=("$formula")
    fi
done
if [[ ${#missing[@]} -gt 0 ]]; then
    "$BREW" install "${missing[@]}"
fi
if [[ ! -d /Applications/iTerm.app && ! -d "$HOME/Applications/iTerm.app" ]] && ! "$BREW" list --cask iterm2 >/dev/null 2>&1; then
    "$BREW" install --cask iterm2
fi

mkdir -p "$BACKUP" "$CONFIG/eza" "$(dirname "$PROFILE")" "$HOME/Library/Fonts"
backup_file() {
    if [[ -e "$1" ]]; then cp -p "$1" "$BACKUP/$2"; fi
}
backup_file "$ZSHRC" zshrc.before
backup_file "$PROFILE" NeoTokyo-profile.before.json
for item in neotokyo.zsh neotokyo.omp.json palette.json shortcuts.txt; do
    backup_file "$CONFIG/$item" "$item.before"
    cp "$ROOT/config/$item" "$CONFIG/$item"
done
backup_file "$CONFIG/eza/theme.yml" eza-theme.before.yml
cp "$ROOT/config/eza/theme.yml" "$CONFIG/eza/theme.yml"
cp "$ROOT/config/iterm2/NeoTokyo.json" "$PROFILE"
cp "$ROOT/config/iterm2/NeoTokyo.itermcolors" "$CONFIG/NeoTokyo.itermcolors"
for font in "$ROOT"/fonts/MonofokiNerdFont-*.ttf; do
    name=$(basename "$font")
    backup_file "$HOME/Library/Fonts/$name" "$name.before"
    cp "$font" "$HOME/Library/Fonts/$name"
    if xattr -p com.apple.quarantine "$HOME/Library/Fonts/$name" >/dev/null 2>&1; then
        xattr -d com.apple.quarantine "$HOME/Library/Fonts/$name" || die "No se pudo activar la fuente $name."
    fi
done

if ! grep -qFx "$START" "$ZSHRC" 2>/dev/null; then
    cat >> "$ZSHRC" <<'NEOTOKYO'

# >>> NeoTokyo >>>
[[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/neotokyo/neotokyo.zsh" ]] && source "${XDG_CONFIG_HOME:-$HOME/.config}/neotokyo/neotokyo.zsh"
# <<< NeoTokyo <<<
NEOTOKYO
fi

# iTerm2 must be closed: a running instance can overwrite external changes.
previous_default=$(defaults read com.googlecode.iterm2 'Default Bookmark Guid' 2>/dev/null || true)
if [[ "$previous_default" != "$ITERM_GUID" ]]; then
    if [[ -n "$previous_default" ]]; then
        printf '%s\n' "$previous_default" > "$DEFAULT_BACKUP"
    else
        printf '%s\n' '__unset__' > "$DEFAULT_BACKUP"
    fi
fi
if ! defaults write com.googlecode.iterm2 'Default Bookmark Guid' -string "$ITERM_GUID" ||
   [[ "$(defaults read com.googlecode.iterm2 'Default Bookmark Guid' 2>/dev/null || true)" != "$ITERM_GUID" ]]; then
    die 'No se pudo establecer NeoTokyo como perfil predeterminado. Consulta la guía para configurarlo manualmente.'
fi

printf '\nNeoTokyo instalado. Copias de seguridad: %s\n' "$BACKUP"
printf 'Cierra iTerm2 por completo con Cmd+Q y vuelve a abrirlo para cargar las fuentes.\n'
printf 'NeoTokyo se ha seleccionado como perfil predeterminado. Abre iTerm2 para comprobarlo.\n'
printf 'En la nueva ventana ejecuta neotokyo-doctor para comprobar las herramientas.\n'
