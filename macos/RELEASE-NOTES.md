# NeoTokyo Terminal Theme v1.1.0

NeoTokyo llega a macOS con Zsh e iTerm2: la paleta y el prompt de dos líneas del tema original, Monofoki Nerd Font, iconos, transparencia, estado de Git, reloj y duración de comandos.

Incluye sugerencias basadas en el historial, búsqueda con fzf, autocompletado, resaltado de sintaxis, listados con eza y navegación con zoxide. El instalador conserva una copia de los archivos modificados y el desinstalador permite desactivar el tema.

Durante la prueba en un MacBook Pro M1 Max se verificaron visualmente los iconos, los colores y la transparencia al seleccionar el perfil NeoTokyo. La paleta de macOS conserva los colores aprobados durante esta prueba; la versión actual de Windows utiliza una variante más pastel. La documentación explica cómo resolver avisos de permisos de Zsh y cómo seleccionar el perfil adecuado. El instalador retira la cuarentena de las fuentes copiadas para facilitar su carga.

Requiere macOS, Zsh y acceso a internet. Si Homebrew falta, se ejecuta su instalador oficial interactivo; iTerm2 se instala mediante Homebrew si no está presente. El instalador requiere cerrar iTerm2, selecciona NeoTokyo como perfil predeterminado y conserva el perfil anterior para restaurarlo al desinstalar. Para otras versiones de macOS y configuraciones de teclado se recomienda validar la instalación.

Esta versión incorpora macOS con iTerm2 y Zsh junto a la edición existente para Windows con PowerShell y Windows Terminal.

Validación previa: instalación con HOME temporal en macOS y dependencias ya instaladas; el instalador seleccionó NeoTokyo como perfil por defecto y guardó el anterior. Tras abrir iTerm2, la ventana usó el perfil NeoTokyo con Monofoki y transparencia de 0,18. El perfil cargado era idéntico al instalado en el HOME temporal; se reutilizó el perfil existente de la cuenta real para el reinicio. La instalación cuando falta Homebrew se verificó con un instalador simulado dentro de una terminal interactiva. No se ensayó una cuenta nueva con descarga e instalación reales de Homebrew e iTerm2.

Validación real en MacBook Pro M1 Max: se retiraron y reinstalaron mediante Homebrew las nueve herramientas de NeoTokyo, sus ajustes y fuentes; Homebrew y el historial se conservaron. El instalador terminó correctamente, las herramientas y dependencias quedaron disponibles, compaudit pasó y la ventana abrió con el perfil NeoTokyo; Core Text reconoció Monofoki y los símbolos del prompt. La apariencia y la reinstalación fueron confirmadas por el usuario. La instalación inicial en un Mac sin Homebrew o iTerm2 sigue pendiente de una prueba real.
