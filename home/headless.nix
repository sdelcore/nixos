{ config, pkgs, lib, username ? "sdelcore", ... }:

{
  imports = [
    ./modules/cli.nix # shared CLI toolset + catppuccin theme
    ./modules/lazydocker.nix # headless-only extra (servers run containers)
  ];

  # Base home-manager settings for standalone (non-NixOS) deployment. These
  # mirror modules/base.nix but stay inline: base.nix also pulls in desktop-only
  # bits (virt-manager dconf, lxqt askpass) that don't belong on a headless box.
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  # Ensure XDG directories exist
  xdg.enable = true;
}
