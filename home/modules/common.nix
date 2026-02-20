{...}: {
  imports = [
    ../modules/alacritty.nix
    ../modules/atuin.nix
    ../modules/ssh.nix
    ../modules/bat.nix
    ../modules/bottom.nix
    ../modules/claude-code/default.nix
    ../modules/direnv.nix
    ../modules/fzf.nix
    ../modules/git.nix
    ../modules/lazygit.nix
    ../modules/neovim.nix
    ../modules/opencode/default.nix
    ../modules/scripts.nix
    ../modules/rofi.nix
    ../modules/zsh.nix
    ../modules/zellij.nix
    ../modules/zen-browser.nix
    ../modules/zoxide.nix
  ];

  # Catpuccin flavor and accent
  catppuccin = {
    flavor = "macchiato";
    accent = "lavender";
  };
}
