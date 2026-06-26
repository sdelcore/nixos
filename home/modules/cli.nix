{ ... }: {
  # Shared CLI toolset — the modules common to every machine, headless or
  # desktop. Imported by both common.nix (desktops/VMs) and headless.nix
  # (standalone non-NixOS deploys), so a tool only has to be listed once.
  imports = [
    ./atuin.nix
    ./bat.nix
    ./claude-code/default.nix
    ./direnv.nix
    ./fzf.nix
    ./git.nix
    ./lazygit.nix
    ./neovim.nix
    ./zsh.nix
    ./zellij.nix
    ./zoxide.nix
  ];

  # Catppuccin flavor + accent — set once here for every consumer.
  catppuccin = {
    flavor = "macchiato";
    accent = "lavender";
  };
}
