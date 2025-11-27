{ config, pkgs, lib, username ? "sdelcore", ... }:

{
  imports = [
    ./modules/atuin.nix
    ./modules/bat.nix
    ./modules/claude-code/default.nix
    ./modules/direnv.nix
    ./modules/fzf.nix
    ./modules/git.nix
    ./modules/lazygit.nix
    ./modules/lazydocker.nix
    ./modules/neovim.nix
    ./modules/zsh.nix
    ./modules/zellij.nix
    ./modules/zoxide.nix
  ];

  # Base home-manager settings for standalone deployment
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  # Catppuccin theme
  catppuccin = {
    flavor = "macchiato";
    accent = "lavender";
  };

  # Ensure XDG directories exist
  xdg.enable = true;
}
