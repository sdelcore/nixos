{ lib, pkgs, ... }: {
  imports = [ ./common.nix ];

  hyprland = {
    configSource = ./../../configs/hypr/lab;
    wallpaper = ./../../wallpapers/topographic-black.jpg;
    wallpaperLock = ./../../wallpapers/topographic-black.jpg;
    enableSuspend = true;
  };
  hyprland.nvidia = false;

  fonts.fontconfig.enable = true;

  home.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  programs.waybar.systemd.enable = lib.mkForce false;
}
