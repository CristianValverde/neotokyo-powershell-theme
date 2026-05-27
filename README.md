# 🌆 NeoTokyo PowerShell Theme

A beautiful, modern PowerShell terminal setup inspired by the NeoTokyo aesthetic — dark blues, neon cyans, and glowing purples.

![NeoTokyo Theme Preview](https://img.shields.io/badge/PowerShell-7.6%2B-blue?logo=powershell) ![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey?logo=windows) ![License](https://img.shields.io/badge/License-MIT-green)

---

## ⚡ Instalación

### Opción 1 — `.exe` desde Releases ⭐ Recomendada

La forma más sencilla. No requiere clonar el repositorio.

1. Ve a [**Releases**](https://github.com/CristianValverde/neotokyo-powershell-theme/releases) y descarga `NeoTokyo-Setup-vX.X.X.zip`.
2. **Extrae** el `.zip` en cualquier carpeta.
3. **Haz doble clic** en `NeoTokyo-Setup.exe`.
4. Acepta el prompt de **administrador** (UAC).
5. Selecciona tu **modo de instalación** y sigue las instrucciones.
6. Cierra y vuelve a abrir **Windows Terminal**. 🎉

> El `.exe` necesita las carpetas `config/` y `fonts/` junto a él — no lo muevas fuera de la carpeta extraída.

---

### Opción 2 — `.bat` (doble clic)

Útil si ya tienes el repositorio clonado o extraído.

1. Descarga o clona el repositorio.
2. **Haz doble clic** en `install.bat`.
3. Se abrirá una ventana con permisos de administrador automáticamente.
4. Sigue las instrucciones del instalador.

---

### Opción 3 — `.ps1` desde PowerShell como administrador

Para usuarios avanzados que prefieren control total.

1. Abre **PowerShell 7 como administrador**.
2. Navega a la carpeta del repositorio:
   ```powershell
   cd "C:\ruta\a\neotokyo-powershell-theme"
   ```
3. Ejecuta el instalador:
   ```powershell
   .\install.ps1
   ```

---

## 🗑️ Desinstalación

| Método | Comando |
|--------|---------|
| Desde la release | Doble clic en `NeoTokyo-Uninstall.exe` |
| Desde el repositorio | Doble clic en `uninstall.bat` |
| PowerShell admin | `.\uninstall.ps1` |

El desinstalador restaura automáticamente la configuración anterior desde el backup creado durante la instalación.

---

## 📦 Modos de instalación

| Modo | Descripción | Tiempo |
|------|-------------|--------|
| **Theme Only** | Solo colores, fuente y tema visual | ~1 min |
| **Express** | Tema + funciones básicas y navegación | ~2 min |
| **Productivity** | Express + Terminal Icons + shortcuts avanzados | ~3 min |
| **Power User** | Todo incluido, máximas funciones | ~5 min |
| **Custom** | Elige exactamente qué instalar | variable |

---

## 🎨 Características

- Tema de color **NeoTokyo** para Windows Terminal
- Fuente **Monofoki Nerd Font** con ligaduras e iconos
- Prompt personalizado con **Oh My Posh**
- Detección automática de todas las versiones de **PowerShell** instaladas
- Perfil de **Git Bash** creado automáticamente si está instalado
- Orden de perfiles: PS preview → Git Bash → CMD → Azure → PS stable → Legacy
- Acrílico + transparencia + colores de pestaña por perfil

---

## 📋 Requisitos

- Windows 10 / 11
- **PowerShell 7.6 o superior** — el instalador te ofrecerá actualizarlo si tu versión es anterior
- **Windows Terminal** — el instalador lo instalará si no está presente
- Permisos de administrador

---

## 📄 Licencia

MIT License — ver [LICENSE](LICENSE)
