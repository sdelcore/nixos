{...}: {
  imports = [
    ../modules/alacritty.nix
    ../modules/atuin.nix
    ../modules/bat.nix
    ../modules/bottom.nix
    ../modules/claude-code/default.nix
    ../modules/direnv.nix
    ../modules/easyeffects.nix
    ../modules/fastfetch.nix
    ../modules/fzf.nix
    ../modules/git.nix
    ../modules/ghostty.nix
    ../modules/go.nix
    ../modules/lazygit.nix
    ../modules/lazydocker.nix
    ../modules/neovim.nix
    ../modules/scripts.nix
    ../modules/ulauncher.nix
    ../modules/zsh.nix
    ../modules/zellij.nix
    ../modules/zen-browser.nix
  ];

  # Catpuccin flavor and accent
  catppuccin = {
    flavor = "macchiato";
    accent = "lavender";
  };
}
