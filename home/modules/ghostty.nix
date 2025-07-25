{ pkgs, self, ... }:
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
    }; 
  };
}