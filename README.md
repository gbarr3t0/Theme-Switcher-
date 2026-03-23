# Theme-Switcher-: Dynamic Color & Wallpaper Injection for Linux WMs 

English / Portuguese

English
1. Project Overview
The Theme-Switcher- is a modular synchronization engine designed for Linux environments. It implements a centralized "Source of Truth" architecture where an image file is parsed to generate a global Xresources-compliant color palette. This palette is then injected into active process environments, configuration files, and pseudo-terminals (TTY) in real-time.

2. System Logic & Architecture
The engine operates on a multi-stage execution pipeline:

Extraction: Analysis of image hexadecimal data via Haishoku or Magick backends.

Environment Synchronization: Updates session variables for Wayland (Hyprland/Sway) or X11 protocols.

Atomic Patching: Direct manipulation of configuration files (CAVA) using sed stream editing to bypass static color limitations.

TTY Injection: Direct broadcast of escape sequences to all active /dev/pts/ nodes to ensure shell persistence.

3. Deployment & Environment Setup
The installation process is handled by a universal bootstrap script that manages dependency resolution across multiple package managers (pacman, apt, dnf, zypper).

Installation Procedure:

Bash
git clone https://github.com/gbarr3t0/Theme-Switcher-.git
cd Theme-Switcher-
chmod +x install.sh
./install.sh
Filesystem Structure:
Upon execution, the script initializes a persistent workspace (See STRUCTURE.md for details):

~/theme_CORE/wallpapers/: Primary ingress directory for source assets.

~/theme_CORE/cache/: Storage for generated CSS and metadata.

~/.config/themes/core_path.ptr: Pointer file for absolute path resolution.

4. Operational Usage
Interactive Mode: Invokes a dynamic menu (Wofi or Rofi) to select assets.

Bash
./themes.sh
CLI Mode: Applies a specific theme via absolute path.

Bash
./themes.sh /path/to/image.png
5. Subsystem Integration (Dynamic Sync)
CAVA: Targets the [color] section of ~/.config/cava/config. Enforces gradient = 1 and gradient_count = 2.

Terminal UI: Updates ANSI 0-15 palette via Pywal sequences. Supports Kitty, Alacritty, and Foot.

Third-Party:

Vencord: Enable Pywal theme and link to ~/.cache/wal/colors-vencord.css.

Spicetify: Apply Pywal color scheme to map UI elements.
-------------------------------------------------------------------------------------------------------------------------------------------------------------

Português
1. Visão Geral do Projeto
O Theme-Switcher- é um motor de sincronização modular para Linux. Ele utiliza uma arquitetura de "Fonte Única de Verdade", onde uma imagem é processada para gerar uma paleta de cores global injetada em processos ativos, arquivos de configuração e terminais (TTY) em tempo real.

2. Lógica e Arquitetura
Extração: Análise de cores via Haishoku ou Magick.

Sincronização: Atualiza variáveis de sessão para Wayland (Hyprland/Sway) ou X11.

Patching Atômico: Manipulação via sed no arquivo do CAVA para contornar limites de cores estáticas.

Injeção TTY: Transmissão de sequências de escape para todos os /dev/pts/ ativos.

3. Instalação e Configuração
O script de instalação resolve dependências automaticamente em distros baseadas em Arch, Debian, Fedora ou OpenSUSE.

Procedimento de Instalação:

Bash
git clone https://github.com/gbarr3t0/Theme-Switcher-.git
cd Theme-Switcher-
chmod +x install.sh
./install.sh
Estrutura de Arquivos:
O script inicializa os seguintes diretórios (Detalhes em STRUCTURE.md):

~/theme_CORE/wallpapers/: Coloque suas imagens aqui.

~/theme_CORE/cache/: Armazena CSS e metadados.

~/.config/themes/core_path.ptr: Arquivo de ponteiro para caminhos absolutos.

4. Uso Operacional
Modo Interativo: Abre o menu (Wofi ou Rofi) para seleção.

Bash
./themes.sh
Modo CLI: Aplica um tema diretamente.

Bash
./themes.sh /caminho/para/imagem.png
5. Integração de Subsistemas
CAVA: Gerencia a seção [color] em ~/.config/cava/config.

Terminal UI: Atualiza a paleta ANSI 0-15. Requer terminais modernos (Kitty, Alacritty, Foot).

Integrações:

Vencord: Ative o tema Pywal apontando para ~/.cache/wal/colors-vencord.css.

Spicetify: Use o esquema de cores Pywal.

6. Automação (Keybinding)
Hyprland:

Bash
bind = SUPER, B, exec, /caminho/para/Theme-Switcher-/themes.sh
7. Debugging
Menu Vazio: Verifique se há imagens em ~/theme_CORE/wallpapers/.

Permissão Negada: Garanta acesso de escrita em ~/theme_CORE e ~/.config/cava/.
