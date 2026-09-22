# AGENTS.md

Instructions for AI coding agents working in this repository.

## Project Overview

NixOS and Home Manager configurations for personal machines:

- `dayman`: laptop
- `nightman`: desktop
- `lab`: SBC/lab host
- `testvm`: throwaway VM target, not a physical host

The repository uses Nix flakes, Home Manager, Hyprland, Catppuccin, Disko,
opnix-backed 1Password secrets, and an unstable nixpkgs overlay exposed as
`pkgs.unstable.*`.

## Activation Safety

Never activate a host configuration without explicit permission in the current
conversation. Before any build or activation command that names a host, run
`hostname`.

- `just switch` applies the current host configuration.
- `just switch <hostname>` is safe only when `<hostname>` matches the current
  machine.
- Never run a `dayman` switch on `nightman`, or a `nightman` switch on `dayman`.
- Use `just deploy <hostname> <ip>` for a remote host; do not activate its
  configuration locally.
- `just provision` runs nixos-anywhere and wipes the target disk.

## Commands

```bash
just                         # List recipes
just update                  # Update flake inputs
just fmt                     # Format Nix files
just build <hostname>        # Build without activating
just switch                  # Activate current host; permission required
just buildvm <hostname>      # Build and run a host as a VM
just testvm <hostname>       # Test a host in a throwaway VM
just testvm-build <hostname> # Build the test VM without running it
just testvm-headless <host>  # Run test VM headlessly with SSH forwarding
just deploy <host> <ip>      # Deploy to a remote host
just provision <host> <ip>   # Destructively provision with nixos-anywhere
```

## Architecture

- `flake.nix` defines `mkSystem`, shared NixOS modules, Home Manager wiring,
  host outputs, and the `pkgs.unstable` overlay.
- `nix/<host>.configuration.nix` contains each host's system configuration.
- `nix/modules/` contains reusable system modules.
- `nix/disks/` contains Disko layouts.
- `nix/hardware/` contains host hardware configuration.
- `nix/profiles/` contains reusable system profiles.
- `nix/users/` contains user definitions.
- `home/<host>.nix` contains each host's Home Manager configuration.
- `home/modules/` contains shared Home Manager modules.
- `home/modules/agent-skills/skills/` is the source of shared agent skills. It
  is linked into `~/.claude/skills/` and `~/.agents/skills/` by Home Manager.
- `home/configs/` contains application configuration files.
- `scripts/test-vm.sh` implements the test VM recipes.

`mkSystem` passes flake inputs and `primaryUser` through `specialArgs`. Add
host-specific system modules through `extraModules` and Home Manager arguments
through `extraHomeSpecialArgs` rather than introducing a second host factory.

Standalone Home Manager configurations for non-NixOS systems are exposed as
`homeConfigurations.headless` and `homeConfigurations.sdelcore`.

## Secrets

Secrets are managed through opnix and 1Password. Never commit credentials or
materialized secret values. The provisioning recipe copies the local opnix
service-account token into a temporary target tree and removes it afterward.

## Validation

Use the smallest check that covers the change:

```bash
just fmt
just build <hostname>
nix flake check
```

For desktop behavior that needs runtime validation, prefer `just testvm` when
practical. Do not use `just switch` merely as a validation step.

Nix flakes only see tracked files. Add newly created source files to Git before
a flake build, without staging unrelated user changes.

## Code Style

- Preserve the existing module and host structure; do not introduce a second
  convention beside it.
- Use section headers with `# ============` separators where the surrounding
  file uses them.
- Use `mkEnableOption` for boolean module enable flags.
- Use `mkOption` with explicit `types.*` and descriptions for other options.
- Use `mkIf`, `mkMerge`, and `mkForce` for conditional or overriding config.
- Pass shared values through `specialArgs` or `extraSpecialArgs`.
- Keep comments for non-obvious constraints and operational hazards.
- Do not bump `system.stateVersion` during routine NixOS upgrades; each host
  pins the value from its original installation.
