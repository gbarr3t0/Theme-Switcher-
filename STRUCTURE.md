# 📁 Project Structure | Theme-Switcher-

This document describes both the repository layout and the runtime directory structure created by the engine.

---

## 🇺🇸 English

### 1. Repository Structure (Tracked by Git)

Core project files:

```
Theme-Switcher-/
├── .gitignore      # Ignores local cache, logs and user-specific files
├── LICENSE         # MIT License
├── README.md       # Main documentation
├── STRUCTURE.md    # Project structure reference
├── install.sh      # Installer and dependency resolver
└── themes.sh       # Core theme engine (Bash)
```

---

### 2. Runtime Workspace (User Environment)

Created automatically on first execution:

```
~/.local/share/themes-core/
├── wallpapers/     # User wallpapers (input)
├── cache/          # Generated data (pywal, UI configs)
├── history/        # Applied themes history
└── backups/        # Optional backups
```

---

### 3. Configuration Layer

User-specific configuration and pointers:

```
~/.config/themes/
└── core_path.ptr   # Stores custom root path (if overridden)
```

---

### 4. Cache & Temporary Data

Transient and system-generated files:

```
~/.cache/
└── wal/            # Pywal generated colors and sequences

/tmp/
└── themes-core-*   # Temporary runtime files
```

---

### 5. Execution Flow Overview

```
User Input (wallpaper)
        ↓
themes-core CLI
        ↓
pywal generates palette
        ↓
System sync:
  • wallpaper
  • terminal colors
  • WM/DE styling
  • cava (optional)
```

---

## 🇧🇷 Português (BR)

### 1. Estrutura do Repositório (Git)

Arquivos principais do projeto:

```
Theme-Switcher-/
├── .gitignore      # Ignora cache local, logs e arquivos do usuário
├── LICENSE         # Licença MIT
├── README.md       # Documentação principal
├── STRUCTURE.md    # Referência da estrutura do projeto
├── install.sh      # Instalador e resolvedor de dependências
└── themes.sh       # Engine principal (Bash)
```

---

### 2. Workspace Dinâmico (Ambiente do Usuário)

Criado automaticamente na primeira execução:

```
~/.local/share/themes-core/
├── wallpapers/     # Wallpapers do usuário (entrada)
├── cache/          # Dados gerados (pywal, configs de UI)
├── history/        # Histórico de temas aplicados
└── backups/        # Backups opcionais
```

---

### 3. Camada de Configuração

Arquivos de configuração do usuário:

```
~/.config/themes/
└── core_path.ptr   # Define caminho customizado (se usado)
```

---

### 4. Cache e Arquivos Temporários

Arquivos gerados pelo sistema:

```
~/.cache/
└── wal/            # Cores e sequências do Pywal

/tmp/
└── themes-core-*   # Arquivos temporários de execução
```

---

### 5. Fluxo de Execução

```
Wallpaper (entrada do usuário)
        ↓
CLI themes-core
        ↓
pywal gera a paleta
        ↓
Sincronização do sistema:
  • wallpaper
  • cores do terminal
  • estilo do WM/DE
  • cava (opcional)
```

---

## 📌 Notes

- All runtime data is isolated from the repository  
- No user data is committed to Git  
- The structure is designed for portability and reproducibility  
