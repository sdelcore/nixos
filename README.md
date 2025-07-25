# NixOS Configuration

## 🖥️ Hosts

| Host | Role | CPU | GPU | Storage | Features |
|------|------|-----|-----|---------|----------|
| **dayman** | Laptop | Intel | NVIDIA | NVMe (btrfs) | TLP, Thunderbolt, Lid controls |
| **nightman** | Desktop | AMD | NVIDIA | NVMe + 4 drives | Triple monitors, Virtualization |
| **wise18** | Server | Intel | NVIDIA (headless) | NVMe + 3-disk RAID0 |  |

## 🚀 Features

### System Architecture
- **NixOS 25.05** with Flakes
- **Disko** for declarative disk partitioning
- **Home Manager** for user environments

### Desktop Environment
- **Hyprland** (Wayland compositor) with extensive customization
- **Catppuccin Macchiato** theme throughout
- **Waybar**, **Wofi**, **SwayNC** for desktop utilities
- Alternative: GNOME/KDE support available

### Development Stack
- **Editors**: Cursor, VS Code, Neovim (LazyVim), Claude Code
- **Languages**: Python, Node.js, Go
- **Tools**: Git, Direnv, FZF, Ripgrep, Bat
- **Containers**: Docker, Libvirt/QEMU
- **Terminal**: Zsh + Starship, Zellij/Tmux

### Security & Auth
- **1Password** integration
- **YubiKey** support (PAM U2F)
- **SOPS** for secret management (TBD)
- **WireGuard** VPN (TBD)

## 🛠️ Usage

### Quick Commands
```bash
just update          # Update flake inputs
just switch          # Apply configuration
just build hostname  # Build specific host
just deploy host ip  # Remote deployment
```

### Initial Setup
1. Clone repository
2. Update hardware configuration for your system
3. Run `just switch hostname`
4. **Change default password immediately**: `passwd`

### Maintenance
- **Updates**: `just update` then `just switch`
- **Garbage collection**: Runs automatically (daily, 3-day retention)
- **VM testing**: `just buildvm hostname`

## 📁 Structure

```
.
├── flake.nix           # Entry point, defines hosts
├── nix/
│   ├── modules/        # System modules
│   │   ├── common/     # Shared configs (boot, network, performance)
│   │   ├── desktop/    # DE configurations
│   │   ├── hardware/   # Hardware-specific
│   │   ├── software/   # Application modules
│   │   └── virtualization/
│   ├── hardware/       # Per-host hardware configs
│   └── users/          # User definitions
└── home/
    ├── modules/        # Home Manager modules
    └── configs/        # Application dotfiles
```

---

<a href="https://www.buymeacoffee.com/sdelcore" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
