# Theme-Switcher (English & Português-BR)

## 🇺🇸 English

## 📌 Overview

**Themes-Core** is a lightweight CLI tool that synchronizes your system theme based on a single wallpaper.

It uses `pywal` to extract colors and applies them across:
- terminal
- window manager / desktop environment
- UI elements (where supported)
- cava (optional)

The goal is simple: **consistent theming without manual tweaking**.

No daemons. No bloated dependencies. Just a clean, predictable pipeline.

---

## ✨ Features

- 🎨 Wallpaper-based dynamic theming
- ⚡ Fast execution (no background services)
- 🧠 Automatic WM/DE detection
- 🖥️ Works on X11 and Wayland
- 🔁 Live terminal color refresh
- 🎵 Cava integration
- 📦 Cross-distro support
- 🧩 Modular structure

---

## 🧩 Supported Environments

Works across most setups:

- Hyprland  
- Sway  
- i3  
- BSPWM  
- Openbox  
- GNOME (partial support)  
- KDE Plasma (partial support)  
- XFCE (partial support)  

Fallback logic is applied for unsupported environments.

---

## 📦 Installation

```bash
git clone https://github.com/gbarr3t0/Theme-Switcher-.git
cd Theme-Switcher-
chmod +x install.sh
./install.sh
```

### What the installer does

- Detects your package manager
- Installs required dependencies (`pywal`, `jq`, `file`)
- Installs optional tools (`rofi`, `cava`, wallpaper backends)
- Installs the binary to:

```
~/.local/bin/themes-core
```

Ensure your PATH includes:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

---

## 🚀 Usage

```bash
themes-core --menu
themes-core --random
themes-core --apply /path/to/image.png
themes-core --list
```

---

## ⚙️ Directory Structure

```
~/.local/share/themes-core/
├── wallpapers/
├── cache/
├── history/
└── backups/
```

---

## ⚙️ How It Works

1. Wallpaper is selected  
2. `pywal` generates a color palette  
3. System updates:
   - wallpaper applied  
   - terminal colors updated  
   - WM/DE styling adjusted  
   - cava synced (if running)  
4. Terminal colors are broadcast to active sessions  

---

## ⚠️ Notes

- Some terminals may require restart  
- Wayland depends on tools like `swww`  
- DE integrations are best-effort  

---

## 🛠️ Keybind Example

**Hyprland**
```ini
bind = SUPER, T, exec, themes-core --menu
```

**i3**
```bash
bindsym $mod+t exec --no-startup-id themes-core --menu
```

---

## 🇧🇷 Português

## 📌 Visão Geral

**Themes-Core** é uma ferramenta CLI leve que sincroniza o tema do seu sistema com base em um único wallpaper.

Ela utiliza `pywal` para extrair cores e aplicá-las em:
- terminal
- gerenciador de janelas / ambiente de desktop
- elementos de UI (quando suportado)
- cava (opcional)

O objetivo é simples: **tematização consistente sem ajustes manuais**.

Sem daemons. Sem dependências pesadas. Apenas um fluxo limpo e previsível.

---

## ✨ Funcionalidades

- 🎨 Tematização dinâmica baseada em wallpaper
- ⚡ Execução rápida (sem serviços em background)
- 🧠 Detecção automática de WM/DE
- 🖥️ Funciona em X11 e Wayland
- 🔁 Atualização ao vivo das cores do terminal
- 🎵 Integração com Cava
- 📦 Suporte a múltiplas distros
- 🧩 Estrutura modular

---

## 🧩 Ambientes Suportados

- Hyprland  
- Sway  
- i3  
- BSPWM  
- Openbox  
- GNOME (parcial)  
- KDE Plasma (parcial)  
- XFCE (parcial)  

---

## 📦 Instalação

```bash
git clone https://github.com/gbarr3t0/Theme-Switcher-.git
cd Theme-Switcher-
chmod +x install.sh
./install.sh
```

---

## 🚀 Uso

```bash
themes-core --menu
themes-core --random
themes-core --apply /path/to/image.png
themes-core --list
```

---

## 📄 Licença

MIT License

---

## 👤 Autor

Desenvolvido por gbarr3t0
