{...}: {
  imports = [ ./common.nix ];

  hyprland = {
    configSource = ./../../configs/hypr/laptop;
    wallpaper = ./../../wallpapers/lines.png;
    wallpaperLock = ./../../wallpapers/lines.png;
    enableSuspend = true;
  };
}
