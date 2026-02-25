{ ... }:
{
  programs.ghostty = {
    enable = true;
    settings = {
      font-size = 9;
      font-family = "MesloLGS Nerd Font";

      # The default is a bit intense for my liking
      # but it looks good with some themes
      unfocused-split-opacity = 0.96;

      # Disables ligatures
      #font-feature = ["-liga" "-dlig" "-calt"];
      theme = "catppuccin-mocha";

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