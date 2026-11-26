#!/bin/bash
set -euo pipefail
[[ "$(uname -s)" == Darwin ]] || { printf 'Ejecuta este archivo en el Mac.\n' >&2; exit 1; }
[[ "$EUID" -ne 0 ]] || { printf 'Ejecuta el archivo sin sudo.\n' >&2; exit 1; }
ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"
PROFILE="$HOME/Library/Application Support/iTerm2/DynamicProfiles/NeoTokyo.json"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/neotokyo"
DEFAULT_BACKUP="$CONFIG/previous-iterm-default"
ITERM_GUID='e4291583-e47f-4ddf-8f63-193af92108fb'
BACKUP="${XDG_STATE_HOME:-$HOME/.local/state}/neotokyo/backups/disabled-$(date +%Y%m%d-%H%M%S)-$$"
if pgrep -x iTerm2 >/dev/null 2>&1; then
    printf 'Cierra iTerm2 con Cmd+Q y ejecuta de nuevo desde Terminal de macOS.\n' >&2; exit 1
fi
START='# >>> NeoTokyo >>>'
END='# <<< NeoTokyo <<<'
if [[ -f "$ZSHRC" ]]; then
    starts=$(grep -cFx "$START" "$ZSHRC" || true)
    ends=$(grep -cFx "$END" "$ZSHRC" || true)
    [[ "$starts" == "$ends" && "$starts" -le 1 ]] || { printf 'Bloque NeoTokyo incompleto: conserva .zshrc y revísalo manualmente.\n' >&2; exit 1; }
    awk -v start="$START" -v end="$END" '$0 == start { depth++; if (depth != 1) bad=1 } $0 == end { depth--; if (depth != 0) bad=1 } END { exit (bad || depth) }' "$ZSHRC" || { printf 'Marcadores NeoTokyo fuera de orden. No se ha modificado .zshrc.\n' >&2; exit 1; }
fi
current_default=$(defaults read com.googlecode.iterm2 'Default Bookmark Guid' 2>/dev/null || true)
if [[ "$current_default" == "$ITERM_GUID" ]]; then
    if [[ ! -f "$DEFAULT_BACKUP" ]]; then
        printf 'No se conoce el perfil anterior. Selecciona otro perfil predeterminado en iTerm2 antes de desactivar NeoTokyo.\n' >&2
        exit 1
    fi
    previous_default=$(cat "$DEFAULT_BACKUP")
    if [[ "$previous_default" == '__unset__' ]]; then
        defaults delete com.googlecode.iterm2 'Default Bookmark Guid'
    elif [[ -n "$previous_default" && "$previous_default" != "$ITERM_GUID" ]]; then
        defaults write com.googlecode.iterm2 'Default Bookmark Guid' -string "$previous_default"
    else
        printf 'No se pudo recuperar el perfil anterior; se conserva el perfil NeoTokyo.\n' >&2; exit 1
    fi
fi

mkdir -p "$BACKUP"
if [[ -f "$ZSHRC" ]] && grep -qFx "$START" "$ZSHRC"; then
    cp -p "$ZSHRC" "$BACKUP/zshrc.before"
    awk -v start="$START" -v end="$END" '
        $0 == start { skip = 1; next }
        $0 == end { skip = 0; next }
        !skip { print }
    ' "$ZSHRC" > "$BACKUP/zshrc.after"
    # Writing through the original path preserves dotfile symlinks.
    cat "$BACKUP/zshrc.after" > "$ZSHRC"
fi
if [[ -f "$PROFILE" ]]; then
    mv "$PROFILE" "$BACKUP/NeoTokyo.json"
fi
printf 'NeoTokyo desactivado. El perfil predeterminado anterior se ha conservado o recuperado.\n'
printf 'Configuración, historial, fuentes y herramientas conservados. Copias: %s\n' "$BACKUP"
