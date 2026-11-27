# Prueba previa al release en macOS limpio

Estado: **pendiente de ejecución en una cuenta o máquina macOS limpia**. No sustituir esta comprobación por la prueba simulada.

1. Usar un Mac o máquina virtual con macOS compatible, sin Homebrew ni iTerm2. Confirmar la versión y la arquitectura (`sw_vers` y `uname -m`); consultar los [requisitos de Homebrew](https://docs.brew.sh/Installation). No retirar herramientas de un ordenador de trabajo para realizar esta prueba.
2. Descomprimir el paquete candidato. Desde Terminal de macOS, ejecutar `bash install.sh` dentro de la carpeta del paquete. Completar las indicaciones interactivas de Homebrew, incluidas las herramientas de Apple y la autenticación si las pide. Registrar cualquier error, confirmación o reinicio necesario.
3. Comprobar que termina correctamente, que `brew --prefix` apunta a la instalación nativa, y que iTerm2 aparece en Aplicaciones. Abrir iTerm2, confirmar que su ventana nueva utiliza NeoTokyo, y comprobar fuente, iconos, paleta, transparencia y `neotokyo-doctor`.
4. Ejecutar `echo neotokyo-prueba`; escribir `echo neot` y aceptar la sugerencia con la flecha derecha. Probar Ctrl+R, `ll`, y el prompt en un repositorio Git.
5. Cerrar iTerm2 con ⌘Q y abrirlo de nuevo; confirmar que la nueva ventana mantiene NeoTokyo, los iconos y la transparencia. Verificar el perfil activo en Settings → Profiles; el título de la ventana no es suficiente.
6. Repetir el instalador desde Terminal de macOS con iTerm2 cerrado. Comprobar que no duplica el bloque de `.zshrc` ni reinstala Homebrew innecesariamente.
7. En el entorno de prueba, cerrar iTerm2 y ejecutar `bash uninstall.sh`. Verificar que se conserva el contenido previo de `.zshrc` y se restaura el perfil anterior o el comportamiento de primer arranque. Revisar una selección manual posterior de perfil y confirmar que se respeta.
8. Anotar versión de macOS, arquitectura, versiones de Homebrew e iTerm2, fecha, resultados y limitaciones; adjuntar evidencia visual sin incluir datos personales o credenciales. Si falla algo, corregirlo y repetir las comprobaciones afectadas antes de publicar.
