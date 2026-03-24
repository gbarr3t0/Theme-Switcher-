# Theme-Switcher (English & Portuguese (Português-BR))
## English ver:
## Portuguese ver below...

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

Clone the repository:

```bash
git clone https://github.com/gbarr3t0/Theme-Switcher-.git
cd Theme-Switcher-
```

Run the installer:

```bash
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

Make sure your PATH includes:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

---

## 🚀 Usage

Open the theme selector:

```bash
themes-core --menu
```

Apply a random wallpaper:

```bash
themes-core --random
```

Apply a specific wallpaper:

```bash
themes-core --apply /path/to/image.png
```

List available wallpapers:

```bash
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

Override root directory:

```bash
themes-core --root /custom/path
```

---

## ⚙️ How It Works

The workflow is straightforward:

1. Wallpaper is selected  
2. `pywal` generates a color palette  
3. System updates:
   - wallpaper applied  
   - terminal colors updated  
   - WM/DE styling adjusted  
   - cava synced (if running)  
4. Terminal colors are broadcast to active sessions  

Everything runs in a single execution — no background services.

---

## ⚠️ Notes

- Some terminals may require restart depending on implementation  
- Wayland support depends on available tools (`swww`, etc.)  
- DE integrations are best-effort with fallback  

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

## 📁 Project Structure

```
.
├── install.sh
├── themes.sh
├── README.md
├── STRUCTURE.md
└── .gitignore
```

---

## 🤝 Contributing

Contributions are welcome:

- fork the repository  
- create a branch  
- submit a pull request  

---

## 📄 License

MIT License

---

## 👤 Author

Developed by gbarr3t0

---

## ⭐ Final Notes

This project focuses on practical theming without overengineering.

If you want a fast, consistent and reproducible desktop setup, this tool gets the job done.

Português ## 📌 Overview

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

Clone the repository:

```bash
git clone https://github.com/gbarr3t0/Theme-Switcher-.git
cd Theme-Switcher-
```

Run the installer:

```bash
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

Make sure your PATH includes:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

---

## 🚀 Usage

Open the theme selector:

```bash
themes-core --menu
```

Apply a random wallpaper:

```bash
themes-core --random
```

Apply a specific wallpaper:

```bash
themes-core --apply /path/to/image.png
```

List available wallpapers:

```bash
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

Override root directory:

```bash
themes-core --root /custom/path
```

---

## ⚙️ How It Works

The workflow is straightforward:

1. Wallpaper is selected  
2. `pywal` generates a color palette  
3. System updates:
   - wallpaper applied  
   - terminal colors updated  
   - WM/DE styling adjusted  
   - cava synced (if running)  
4. Terminal colors are broadcast to active sessions  

Everything runs in a single execution — no background services.

---

## ⚠️ Notes

- Some terminals may require restart depending on implementation  
- Wayland support depends on available tools (`swww`, etc.)  
- DE integrations are best-effort with fallback  

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

## 📁 Project Structure

```
.
├── install.sh
├── themes.sh
├── README.md
├── STRUCTURE.md
└── .gitignore
```

---

## 🤝 Contributing

Contributions are welcome:

- fork the repository  
- create a branch  
- submit a pull request  

---

## 📄 License

MIT License

---

## 👤 Author

Developed by gbarr3t0

---

## ⭐ Final Notes

This project focuses on practical theming without overengineering.

If you want a fast, consistent and reproducible desktop setup, this tool gets the job done.

Português -------------------------------------------------------------------------------------------------------

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

Funciona na maioria dos setups:

- Hyprland  
- Sway  
- i3  
- BSPWM  
- Openbox  
- GNOME (suporte parcial)  
- KDE Plasma (suporte parcial)  
- XFCE (suporte parcial)  

Uma lógica de fallback é aplicada para ambientes não suportados.

---

## 📦 Instalação

Clone o repositório:

```bash
git clone https://github.com/gbarr3t0/Theme-Switcher-.git
cd Theme-Switcher-
```

Execute o instalador:

```bash
chmod +x install.sh
./install.sh
```

### O que o instalador faz

- Detecta seu gerenciador de pacotes
- Instala dependências obrigatórias (`pywal`, `jq`, `file`)
- Instala ferramentas opcionais (`rofi`, `cava`, backends de wallpaper)
- Instala o binário em:

```
~/.local/bin/themes-core
```

Certifique-se de que seu PATH inclui:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

---

## 🚀 Uso

Abrir o seletor de temas:

```bash
themes-core --menu
```

Aplicar um wallpaper aleatório:

```bash
themes-core --random
```

Aplicar um wallpaper específico:

```bash
themes-core --apply /path/to/image.png
```

Listar wallpapers disponíveis:

```bash
themes-core --list
```

---

## ⚙️ Estrutura de Diretórios

```
~/.local/share/themes-core/
├── wallpapers/
├── cache/
├── history/
└── backups/
```

Sobrescrever diretório raiz:

```bash
themes-core --root /custom/path
```

---

## ⚙️ Como Funciona

O fluxo é simples:

1. Um wallpaper é selecionado  
2. O `pywal` gera uma paleta de cores  
3. O sistema é atualizado:
   - wallpaper aplicado  
   - cores do terminal atualizadas  
   - estilos do WM/DE ajustados  
   - cava sincronizado (se estiver em execução)  
4. As cores do terminal são propagadas para sessões ativas  

Tudo ocorre em uma única execução — sem serviços em background.

---

## ⚠️ Observações

- Alguns terminais podem exigir reinício dependendo da implementação  
- O suporte a Wayland depende das ferramentas disponíveis (`swww`, etc.)  
- Integrações com DE são best-effort, sempre com fallback  

---

## 🛠️ Exemplo de Keybind

**Hyprland**
```ini
bind = SUPER, T, exec, themes-core --menu
```

**i3**
```bash
bindsym $mod+t exec --no-startup-id themes-core --menu
```

---

## 📁 Estrutura do Projeto

```
.
├── install.sh
├── themes.sh
├── README.md
├── STRUCTURE.md
└── .gitignore
```

---

## 🤝 Contribuindo

Contribuições são bem-vindas:

- faça um fork do repositório  
- crie uma branch  
- envie um pull request  

---

## 📄 Licença

Licença MIT

---

## 👤 Autor

Desenvolvido por gbarr3t0

---

## ⭐ Observações Finais

Este projeto foca em tematização prática sem overengineering.

Se você quer um setup rápido, consistente e reproduzível, essa ferramenta resolve.
