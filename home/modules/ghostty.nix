{ ... }:
{
  programs.ghostty = {
    enable = true;
    settings = {
      font-size = 9;
      font-family = "MesloLGS Nerd Font";

      # Full opacity on unfocused splits — avoids the transparency
      # compositing pass that causes flicker with Zellij + Claude Code
      unfocused-split-opacity = 1;

      # Disables ligatures
      #font-feature = ["-liga" "-dlig" "-calt"];
      theme = "Catppuccin Mocha";

      # Tiling WM (Hyprland) - no decorations needed
      gtk-titlebar = false;
      window-decoration = "none";

      # Use xterm-256color so remote hosts don't break on xterm-ghostty
      term = "xterm-256color";

      # Allow clipboard access (needed for Neovim yank/paste)
      clipboard-read = "allow";
      clipboard-write = "allow";

      # Confirm before closing
      confirm-close-surface = false;
    };
  };
}