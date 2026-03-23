# Project File Tree | Theme-Switcher-

This document describes the current repository structure and the dynamic workspace generated during runtime.

## 1. Repository Manifest (GitHub)
These are the source files tracked by Git:

Theme-Switcher-/
├── .gitignore         # Prevents tracking of local cache and user images
├── LICENSE            # MIT License (Terms of use and distribution)
├── README.md          # Primary technical documentation
├── install.sh         # Universal dependency resolver and bootstrap
└── themes.sh          # Main theme synchronization engine (Shell/Bash)

## 2. Dynamic Workspace Architecture
The engine initializes this structure in the user's HOME directory upon the first execution:

~/
└── theme_CORE/        # Data root for the switching engine
    ├── wallpapers/    # USER INPUT: Put your .jpg and .png files here
    ├── cache/         # Generated CSS (Wofi) and Pywal metadata
    ├── logs/          # Execution logs for system debugging
    └── temp/          # Ephemeral runtime files

## 3. Configuration & Pointers
System-wide reference files:

~/.config/
└── themes/
    └── core_path.ptr  # Pointer file containing the absolute path to theme_CORE
