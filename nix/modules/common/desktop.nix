{ config, pkgs, ... }:

{
  # Common desktop imports shared by dayman, nightman, and seeed
  imports = [
    ../desktop/default.nix
    ../desktop/hyprland.nix
    ../network/xrdp.nix
    ../hardware/nvidia.nix
    ../hardware/yubikey.nix
    ../hardware/ledger.nix
    ../software/1password.nix
    ../software/flatpak.nix
    ../software/ollama.nix
    ../virtualization/docker.nix
  ];
}