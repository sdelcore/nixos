# NixOS Configuration

## 🖥️ Hosts

| Host | Role | CPU | GPU | Storage | Features |
|------|------|-----|-----|---------|----------|
| **dayman** | Laptop | Intel | NVIDIA | NVMe (disko) | TLP, Thunderbolt, Lid controls |
| **nightman** | Desktop | AMD | NVIDIA | NVMe + drives (imperative) | Triple monitors, Virtualization |
| **lab** | SBC / lab box | — | — | SATA (disko) | Minimal Hyprland, firewall off |

There is also a `testvm` target — a throwaway VM build (GNOME desktop) used to test config changes; it is not a physical host.

## 🚀 Features

### System Architecture
- **NixOS 25.11** with Flakes
- **Disko** for declarative disk partitioning
- **Home Manager** for user environments

### Desktop Environment
- **Hyprland** (Wayland compositor) with extensive customization
- **Catppuccin Macchiato** theme throughout
- **Waybar**, **Wofi**, **SwayNC** for desktop utilities
- GNOME is also available (used by the `testvm` target)

### Development Stack
- **Editors**: Cursor, VS Code, Neovim (LazyVim), Claude Code
- **Languages**: Python, Node.js, Go
- **Tools**: Git, Direnv, FZF, Ripgrep, Bat
- **Containers**: Docker, Libvirt/QEMU
- **Terminal**: Zsh + Starship, Zellij

### Agent Tooling
- **Claude Code**, **OpenCode**, **Codex**, and **OMP** managed via Home Manager modules
- Shared skills under `home/modules/agent-skills/skills/` symlink into `~/.claude/skills/` and `~/.agents/skills/`

### Security & Auth
- **1Password** integration
- **YubiKey** support (PAM U2F)
- **opnix** (1Password-backed) for secret management
- **NetBird** mesh VPN (see `nix/modules/network/netbird.nix`)

## 🛠️ Usage

### Quick Commands
```bash
just update              # Update flake inputs
just switch              # Apply configuration (current host)
just build hostname      # Build a specific host without applying
just deploy host ip      # Remote deployment
just testvm hostname     # Boot a host config in a throwaway VM
just testvm-headless h   # Same, headless with SSH on a forwarded port
```

### Initial Setup
1. Clone repository
2. Update hardware configuration for your system
3. Run `just switch hostname`
4. **Change default password immediately**: `passwd`

### Maintenance
- **Updates**: `just update` then `just switch`
- **Garbage collection**: Runs automatically (daily, 3-day retention)
- **VM testing**: `just buildvm hostname`, or `just testvm hostname` to boot it

> Each host pins its own `system.stateVersion` (set at install time and intentionally left alone per host — it is not a "current NixOS version" and should not be bumped on upgrade).

## 📁 Structure

```
.
├── flake.nix                # Entry point, defines hosts via mkSystem
├── nix/
│   ├── <host>.configuration.nix   # Per-host system config
│   ├── modules/             # System modules (common, desktop, hardware, software, virtualization)
│   ├── disks/               # Disko layouts
│   ├── hardware/            # Per-host hardware configs
│   ├── profiles/            # Reusable system profiles
│   └── users/               # User definitions
└── home/
    ├── <host>.nix           # Per-host Home Manager config
    ├── modules/             # Home Manager modules (shell, editors, desktop apps)
    │   ├── agent-skills/    # Shared SKILL.md set for coding agents
    │   ├── claude-code/     # Claude Code commands, plugins, settings
    │   ├── opencode/
    │   ├── omp.nix          # OMP coding agent and LiteLLM discovery
    │   └── hyprland/
    ├── configs/             # Application dotfiles
    ├── scripts/
    └── wallpapers/
```

---

<a href="https://www.buymeacoffee.com/sdelcore" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
