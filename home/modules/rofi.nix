{ pkgs, ... }:
{
  catppuccin.rofi.enable = true;

  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    plugins = [ pkgs.rofi-emoji ];
    terminal = "${pkgs.alacritty}/bin/alacritty";
    extraConfig = {
      modi = "drun,emoji,run";
      show-icons = true;
      icon-theme = "Papirus";
      display-drun = "Apps";
      display-emoji = "Emoji";
      drun-display-format = "{name}";
    };
  };

  home.packages = [ pkgs.rofimoji ];
}
