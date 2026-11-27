# NeoTokyo para macOS

La migración de **NeoTokyo PowerShell Theme** a **Zsh + iTerm2**, con herramientas nativas para Apple Silicon. Conserva la identidad visual de nuestra consola de Windows y adapta sus funciones al Mac. No instala PowerShell.

## Instalar en el Mac

1. Copia `NeoTokyo-macOS.zip` al Mac y descomprímelo. También puedes copiar esta carpeta completa.
2. El instalador detecta Homebrew y, si falta, ejecuta el instalador oficial de [brew.sh](https://brew.sh). Necesitarás conexión a internet y una sesión interactiva; Homebrew puede pedir confirmación, contraseña y herramientas de desarrollo de Apple. En equipos gestionados, utiliza el procedimiento de tu departamento de IT si la instalación está bloqueada.
3. Cierra iTerm2 por completo con **⌘Q**. Abre la aplicación Terminal de macOS, escribe `cd `, arrastra la carpeta descomprimida a la ventana y pulsa Enter. El instalador comprueba que iTerm2 esté cerrado para que sus preferencias no sobrescriban el cambio.
4. Ejecuta:

   ```sh
   bash install.sh
   ```

   Utiliza tu usuario habitual, sin `sudo`. En el M1, abre Terminal sin Rosetta. El instalador comprueba que Homebrew sea nativo en `/opt/homebrew`.

5. Abre iTerm2: el instalador selecciona NeoTokyo como perfil predeterminado. Si la aplicación restaura una ventana antigua, abre una ventana nueva.
6. En esa ventana ejecuta:

   ```sh
   neotokyo-doctor
   neotokyo-help
   ```

El instalador detecta iTerm2 y, si no lo encuentra, lo instala mediante Homebrew. Guarda el perfil predeterminado anterior y selecciona NeoTokyo para las ventanas nuevas. Añade NeoTokyo a `.zshrc`; también tendrás las funciones al abrir otras aplicaciones que usen Zsh interactivo. El aspecto completo está configurado en el perfil de iTerm2.

## Instalación manual en macOS

Estos pasos están pensados para quien quiere integrar la configuración por su cuenta. El instalador automatizado también hace copias de seguridad y configura el perfil predeterminado. En los comandos siguientes, parte de la carpeta `macos` de este repositorio o de la carpeta descomprimida del release.

1. Instala [Homebrew](https://brew.sh/) y [iTerm2](https://iterm2.com/downloads.html) siguiendo sus instrucciones oficiales. En Apple Silicon, comprueba que se usa Homebrew de `/opt/homebrew`. Instala las herramientas:

   ```sh
   brew install jandedobbeleer/oh-my-posh/oh-my-posh zsh-autosuggestions zsh-syntax-highlighting zsh-completions fzf zoxide eza bat ripgrep
   ```

2. Instala las cuatro fuentes `fonts/MonofokiNerdFont-*.ttf` con Catálogo Tipográfico. Cierra iTerm2 con ⌘Q y vuelve a abrirlo después de instalar las fuentes.
3. Revisa y guarda una copia de tus ajustes existentes. Copia `config/neotokyo.zsh`, `config/neotokyo.omp.json`, `config/palette.json` y `config/shortcuts.txt` a `${XDG_CONFIG_HOME:-$HOME/.config}/neotokyo/`; copia `config/eza/theme.yml` a su subcarpeta `eza/`. Si ya tienes archivos con esos nombres, evita sobrescribirlos sin revisarlos.
4. Añade esta línea al final de `${ZDOTDIR:-$HOME}/.zshrc`, conservando su contenido:

   ```zsh
   [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/neotokyo/neotokyo.zsh" ]] && source "${XDG_CONFIG_HOME:-$HOME/.config}/neotokyo/neotokyo.zsh"
   ```

5. Copia `config/iterm2/NeoTokyo.json` a `~/Library/Application Support/iTerm2/DynamicProfiles/`. Si ya existe un archivo con ese nombre, haz una copia primero. En iTerm2, selecciona **Profiles → NeoTokyo** y, para las ventanas nuevas, **Settings → Profiles → NeoTokyo → Other Actions → Set as Default**.
6. Abre una ventana nueva y sigue las [comprobaciones rápidas](#comprobaciones-rápidas). Para deshacer una instalación manual, retira la línea añadida a `.zshrc` y el perfil dinámico después de seleccionar otro perfil predeterminado; conserva las copias y cualquier archivo personal.

## Qué conserva y qué mejora

| Función de la consola original | Versión Mac |
|---|---|
| Paleta NeoTokyo | Los 16 colores ANSI de la versión de NeoTokyo probada en el Mac, fondo `#0B1020`, texto cian `#8BE9FD`, cursor rosa `#FF79C6` y selección `#A1FFD6` |
| Monofoki Nerd Font, 14 pt | Se incluyen e instalan las variantes regular, negrita, cursiva y negrita cursiva originales |
| Transparencia al 82 % de opacidad | iTerm2 con 18 % de transparencia y desenfoque; el resultado depende del fondo y los ajustes de accesibilidad de macOS |
| Ventana inicial | 90 columnas × 30 filas, cursor vertical, sin campana y 50.000 líneas de desplazamiento |
| Prompt de dos líneas | Mismos colores e iconos, usuario, ruta completa y `#` rosa en la segunda línea |
| Git | Rama, cambios locales, cambios preparados, stash y relación con upstream; consulta el repositorio local, sin ejecutar `git fetch` |
| Reloj y duración | Hora a la derecha y duración de comandos que superan 300 ms |
| Información adicional | Entorno virtual de Python cuando está activo; código de salida cuando falla un comando; host en sesiones SSH |
| Predicción basada en historial | Sugerencias en gris mientras escribes; → acepta la sugerencia y Option izquierda+F acepta una palabra |
| Historial de 50.000 comandos | Persistente y compartido entre ventanas Zsh; evita duplicados y permite búsqueda por prefijo con ↑/↓ |
| Búsqueda del historial | Ctrl+R abre un selector con fzf. Enter inserta el comando: lo revisas antes de ejecutarlo |
| Autocompletado | Tab muestra opciones y rutas en un menú; Shift+Tab recorre hacia atrás; incluye zsh-completions |
| Colores de sintaxis | Comandos rosas, opciones turquesas, cadenas azules, comentarios verdes y comandos desconocidos en rojo |
| Archivos con iconos | eza sustituye el listado interactivo de `ls`, con colores NeoTokyo, Git y vistas detalladas o en árbol |
| Buscar archivos y carpetas | Ctrl+T inserta un archivo, Option izquierda+C cambia de carpeta; ambos tienen vista previa |
| Navegación rápida | zoxide recuerda carpetas visitadas: `z proyecto` y `zi` |
| Atajos propios | Git, Docker, Kubernetes, carpetas, Finder, portapapeles, búsqueda de archivos e información del Mac |

Las tuberías y el lenguaje son los de Zsh. Los scripts `.ps1` y las funciones basadas en APIs de Windows necesitan reescribirse si se quieren ejecutar aquí. Los colores de sintaxis se aproximan con el analizador de Zsh, que distingue construcciones diferentes a PowerShell. Acrylic de Windows y el desenfoque de macOS tampoco son idénticos.

## Atajos principales

| Tecla o comando | Acción |
|---|---|
| → al final de la línea | Aceptar la sugerencia completa |
| Option izquierda+F | Aceptar la siguiente palabra de la sugerencia |
| ↑ / ↓ | Buscar comandos que empiezan por lo que ya escribiste; también moverse por líneas de una entrada multilínea |
| Ctrl+R | Buscar en el historial con fzf |
| Tab / Shift+Tab | Autocompletar y recorrer el menú |
| Ctrl+T | Buscar e insertar archivos |
| Option izquierda+C | Buscar una carpeta y entrar |
| Shift+Enter | Añadir una línea sin ejecutar; requiere el perfil NeoTokyo de iTerm2 |
| Ctrl+L | Limpiar la pantalla |
| Ctrl+Z / Option izquierda+Z | Deshacer / rehacer la edición de la línea |
| Ctrl+A / Ctrl+E | Principio / final de la línea |
| Ctrl+W | Borrar la palabra anterior |
| Option izquierda+B / F | Moverse por palabras; F también acepta parte de una sugerencia |
| Cmd+C / Cmd+V | Copiar / pegar |
| Ctrl+C | Interrumpir un comando |
| `ll`, `la`, `lt` | Listado detallado, archivos ocultos, árbol de dos niveles |
| `catc archivo` | Mostrar un archivo con resaltado de sintaxis |
| `z nombre`, `zi` | Saltar a una carpeta conocida, con o sin selector |
| `..`, `...`, `....` | Subir uno, dos o tres niveles |
| `mkcd "mi carpeta"` | Crear una carpeta y entrar |
| `docs`, `downloads`, `desktop`, `repos` | Ir a `~/Documents`, `~/Downloads`, `~/Desktop`, `~/repos` |
| `gs`, `ga`, `gc`, `gp`, `gl`, `gd`, `gb`, `gco`, `gpull` | Atajos de Git; puedes añadir argumentos, por ejemplo `gc -m "mensaje"` |
| `k`, `kgp`, `kgs`, `kgd`, `kdp` | Atajos de kubectl |
| `d`, `dc`, `dps`, `dpsa`, `di` | Atajos de Docker y Docker Compose |
| `pwdc`, `ex [ruta]` | Copiar ruta, abrir Finder o un archivo |
| `ff texto`, `sysinfo` | Buscar nombres de archivos, consultar información del Mac |
| `hist`, `histall` | Últimos comandos, historial cargado en la sesión |
| `edit-profile`, `reload` | Editar tus ajustes personales, abrir una sesión nueva |

Se utiliza **Option izquierda como Alt**, dejando **Option derecha disponible para los símbolos del teclado español**. macOS puede capturar Ctrl+←/→ para Mission Control; Option izquierda+B/F es la alternativa. Ctrl+Z está asignado a deshacer mientras editas una línea; conserva su función de suspensión cuando hay un programa ejecutándose.

Los atajos de Docker, Kubernetes y Git requieren que esas herramientas estén instaladas. NeoTokyo no instala Docker Desktop, AWS CLI, Python, kubectl ni modifica credenciales. Los autocompletados específicos dependen de los que proporcione cada herramienta y zsh-completions.

## Ajustes personales

Por defecto, la configuración queda en `~/.config/neotokyo`. Si defines `XDG_CONFIG_HOME`, se utiliza esa ubicación. Para cambiar alias, opciones o variables propias:

```sh
edit-profile
```

Ese comando abre `local.zsh`, que se conserva al reinstalar. Después ejecuta `reload`. Las personalizaciones de resaltado deben hacerse tras cargar el complemento; puedes ponerlas en `.zshrc` después del bloque NeoTokyo.

El perfil de iTerm2 está en:

```text
~/Library/Application Support/iTerm2/DynamicProfiles/NeoTokyo.json
```

Es un **perfil dinámico**: para cambios permanentes de fuente, opacidad o colores, edita ese archivo o duplica el perfil en iTerm2 y personaliza la copia. Reinstalar actualiza el perfil dinámico y deja una copia de su versión anterior. En iTerm2 la opción `Transparency` es `0.18`, equivalente a 82 % de opacidad. Para un fondo sólido utiliza `0`; para reducir un poco la transparencia, prueba `0.10` (90 % de opacidad).

También se incluye `config/iterm2/NeoTokyo.itermcolors`, importable desde **Settings → Profiles → Colors → Color Presets → Import** para aplicar únicamente la paleta a otro perfil.

### Personalizar el prompt y los atajos

- **Prompt e iconos:** edita `${XDG_CONFIG_HOME:-$HOME/.config}/neotokyo/neotokyo.omp.json` y ejecuta `reload`. Los iconos necesitan una Nerd Font activa. El instalador sustituye ese archivo al reinstalar; guarda una copia de tus cambios.
- **Funciones y alias:** añade tus ajustes a `local.zsh` mediante `edit-profile`; el instalador conserva ese archivo. Por ejemplo, `alias proyectos='cd ~/Projects'`.
- **Teclas:** añade tus asignaciones Zsh a `local.zsh`, por ejemplo `bindkey '^P' up-line-or-beginning-search`. Las teclas que dependen del terminal, como Shift+Enter, se configuran en el perfil de iTerm2; una copia del perfil permite conservar cambios visuales y de teclas al reinstalar.
- **Colores y transparencia:** el perfil dinámico determina fuente, paleta y transparencia. Edita el JSON del perfil o duplica NeoTokyo en iTerm2 y modifica la copia en Settings. El valor predeterminado `Transparency: 0.18` corresponde a 82 % de opacidad.
- **Restauración:** el instalador guarda copias en `${XDG_STATE_HOME:-$HOME/.local/state}/neotokyo/backups`; `bash uninstall.sh` desactiva NeoTokyo y trata de restaurar el perfil anterior. No desinstala Homebrew ni las demás herramientas.

El tema de `bat` es Dracula, próximo a nuestros colores. El prompt, los listados de eza, fzf y el resaltado de Zsh sí tienen configuración NeoTokyo propia.

## Historial y configuración existente

- Se conserva la ubicación de `HISTFILE` si ya está configurada. En una instalación nueva se usa `~/.zsh_history`.
- El instalador no copia el historial de PowerShell de Windows; sus comandos pueden usar otra sintaxis. El archivo distribuible no contiene historial personal ni credenciales.
- Un comando que comienza con un espacio queda excluido del guardado del historial de Zsh.
- Se añade un bloque delimitado al final de `.zshrc`, conservando su contenido y los enlaces simbólicos. Los alias incluidos pueden sustituir alias del mismo nombre; `local.zsh` permite redefinirlos.
- Si ya usas otro tema de prompt o los mismos complementos con Oh My Zsh, desactiva sus entradas duplicadas en tu configuración. La copia de `.zshrc` anterior a la instalación permite compararlas.
- Si utilizas un `ZDOTDIR` propio, expórtalo antes de ejecutar tanto la instalación como la desactivación: `export ZDOTDIR="/ruta/a/tus/dotfiles"`.

## Desactivar y recuperar

Cierra iTerm2 con ⌘Q y, desde Terminal de macOS, ejecuta en esta carpeta:

```sh
bash uninstall.sh
```

Quita el bloque de arranque de NeoTokyo de `.zshrc` y archiva su perfil dinámico. Si NeoTokyo sigue siendo el perfil predeterminado, restaura el anterior guardado por el instalador; respeta cualquier otro perfil que hayas seleccionado después. Si NeoTokyo ya era el perfil predeterminado antes de instalar y no hay copia del anterior, selecciona otro perfil manualmente antes de desinstalar. Conserva otros cambios posteriores, la configuración de NeoTokyo, las fuentes, el historial y las herramientas instaladas. Abre una ventana nueva con otro perfil para que deje de estar activo.

Las copias se guardan en `~/.local/state/neotokyo/backups` o bajo `XDG_STATE_HOME`. Cada ejecución tiene su propia carpeta. Si un bloque NeoTokyo está incompleto o fuera de orden, los scripts se detienen antes de editar `.zshrc`.

## Comprobaciones rápidas

1. Ejecuta `neotokyo-doctor`: debe encontrar las herramientas y los dos complementos principales.
2. Escribe y ejecuta `echo neotokyo-prueba`. Luego empieza a escribir `echo neot`: debe aparecer la sugerencia en gris; acéptala con →.
3. Pulsa Ctrl+R y busca `neotokyo-prueba`. Selecciona con Enter y comprueba que aparece en la línea sin ejecutarse.
4. Ejecuta `ll` y `lt`: deben aparecer iconos. Si ves cuadrados, comprueba **Text → Font → Monofoki Nerd Font, 14 pt** y reinicia iTerm2.
5. Entra en un repositorio: debe aparecer la rama; crea o modifica un archivo para ver el estado de Git.
6. Ejecuta `sleep 1`: comprueba la duración. Ejecuta `false`: debe aparecer el código de salida `1` en rojo en el siguiente prompt.
7. Prueba Shift+Enter: debe insertar una línea; si ejecuta el comando, abre el perfil NeoTokyo y comprueba su asignación de teclas.

Si aparece `zsh compinit: insecure directories`, ejecuta `autoload -Uz compaudit; compaudit` y revisa la propiedad y los permisos de las rutas que aparezcan. En el Mac probado el problema era que `/opt/homebrew/share` permitía escritura al grupo; tras confirmar que es la ruta afectada y que te pertenece, `chmod g-w /opt/homebrew/share` resolvió el aviso. No desactives la comprobación de seguridad.

Si ves cuadrados en vez de iconos, cierra iTerm2 con ⌘Q, abre **Profiles → NeoTokyo** y comprueba que está seleccionado ese perfil, con la fuente Monofoki Nerd Font. Para que las ventanas nuevas lo usen, selecciona **Settings → Profiles → NeoTokyo → Other Actions → Set as Default**. Si persiste, abre Catálogo Tipográfico y comprueba que Monofoki Nerd Font esté instalada y activada.

Si falta fzf o su integración falla, actualiza con `brew upgrade fzf`; se utiliza la integración `fzf --zsh` disponible desde fzf 0.48. Si falta otra herramienta, vuelve a ejecutar el instalador para instalarla. El arranque conserva un prompt básico cuando Oh My Posh no está disponible.

Para integración adicional de iTerm2 —marcas de comandos y salto entre prompts— puedes utilizar **iTerm2 → Install Shell Integration → Internet-Free Install**. La guía oficial describe también la carga automática cuando se usa un perfil de tipo Login Shell. El perfil entregado ejecuta explícitamente `/bin/zsh -l`.

## Validación y mantenimiento

Se han probado la carga real con Zsh 5.9, los complementos de sugerencias y resaltado, fzf 0.74.5, zoxide 0.10.0 y Oh My Posh 31.9.1 en Linux. Las pruebas del instalador simulan las rutas y herramientas de macOS en carpetas temporales: instalación, reinstalación, desactivación, rutas con espacios, `ZDOTDIR`, enlaces simbólicos y rechazo de marcadores dañados. Se ha validado el tema con el esquema actual de Oh My Posh y se ha comprobado el nombre interno real de la fuente.

Probado en un MacBook Pro M1 Max: el perfil NeoTokyo de iTerm2 muestra los iconos, la paleta y la transparencia esperadas. El aviso de seguridad de compinit se resolvió corrigiendo los permisos de la carpeta concreta señalada por compaudit. La compatibilidad con otras versiones de macOS, distribuciones de teclado y configuraciones de iTerm2 requiere pruebas adicionales.

Para repetir las pruebas en macOS o Linux con Python 3 y Zsh:

```sh
bash tests/run.sh
```

`config/palette.json` conserva la paleta probada en el Mac; la rama principal de Windows usa actualmente una variante más pastel. Si la editas, `python3 tools/build_assets.py` regenera el perfil de iTerm2 y el preset de colores. El tema del prompt y el resaltado se editan en sus archivos respectivos.

## Fuentes y documentación

- [Oh My Posh para macOS](https://ohmyposh.dev/docs/installation/macos) y [configuración de Zsh](https://ohmyposh.dev/docs/installation/customize).
- [Perfiles dinámicos de iTerm2](https://iterm2.com/documentation-dynamic-profiles.html) e [integración con la shell](https://iterm2.com/documentation-shell-integration.html).
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions), [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) y [zsh-completions](https://github.com/zsh-users/zsh-completions).
- [fzf](https://github.com/junegunn/fzf), [zoxide](https://github.com/ajeetdsouza/zoxide), [eza](https://github.com/eza-community/eza) y [bat](https://github.com/sharkdp/bat).
- Las cuatro fuentes Monofoki Nerd Font se reutilizan sin modificar del paquete original de NeoTokyo. Sus licencias y la auditoría de Nerd Fonts se incluyen en `fonts/`.
