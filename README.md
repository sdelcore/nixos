# NixOS Configuration

Flake-based NixOS configurations for `dayman`, `nightman`, and `lab`, with shared system modules and Home Manager environments.

## Hosts

| Host | Role | Hardware | Notable configuration |
|------|------|----------|------------------------|
| `dayman` | Laptop | Intel CPU, NVIDIA GPU | NVMe (Disko), TLP, Thunderbolt, lid controls |
| `nightman` | Desktop | AMD CPU, NVIDIA GPU | NVMe and additional drives, triple monitors, virtualization |
| `lab` | SBC / lab box | — | SATA (Disko), minimal Hyprland; firewall disabled |

`testvm` is a throwaway GNOME VM target for testing host configurations; it is not a physical host.

## Agent tooling

Claude Code, OpenCode, Codex, OMP, Herdr, and Orca are managed with Home Manager. Shared skills live in `home/modules/agent-skills/skills/` and are linked for supported agents. `ai-usagebar` provides Claude and Codex usage in Waybar; OpenCode Go is available when configured.

NetBird clients use a loopback DNS listener on `127.0.0.153:53` so Tailscale's CGNAT filtering does not block local DNS replies. The NetBird service needs `CAP_NET_BIND_SERVICE` to bind that port.

## Commands

```bash
just update                 # Update flake inputs
just build <host>           # Build a host without applying it
just switch                 # Apply the current host configuration
just deploy <host> <ip>     # Deploy to a remote host
just testvm <host>          # Build and boot a host configuration in a throwaway VM
just testvm-headless <host> # Same, headless with SSH on a forwarded port
just buildvm <host>         # Build and run the VM
just testvm-build <host>    # Build the VM only; do not run it
```

For initial setup, clone the repository, configure the machine's hardware, and build the intended host before applying it. Only switch a configuration when authorized and appropriate for that machine. Change the default password immediately with `passwd`.

Garbage collection runs daily with three-day retention.

Each host's `system.stateVersion` is set at installation and should not be changed during routine upgrades; it does not indicate the current NixOS release.

## Structure

```text
.
├── flake.nix              # Flake entry point and host definitions
├── nix/
│   ├── <host>.configuration.nix
│   ├── modules/           # Shared system modules
│   ├── disks/             # Disko layouts
│   ├── hardware/          # Host hardware configuration
│   ├── profiles/          # Reusable system profiles
│   └── users/             # User definitions
└── home/
    ├── <host>.nix         # Host Home Manager configuration
    ├── modules/            # Home Manager modules
    ├── configs/            # Application dotfiles
    ├── scripts/
    └── wallpapers/
```
