{...}: {
  imports = [ ./common.nix ];

  hyprland = {
    configSource = ./../../configs/hypr/desktop;
    wallpaper = ./../../wallpapers/topographic-black.jpg;
    wallpaperLock = ./../../wallpapers/topographic-black.jpg;
    enableSuspend = false;
  };
}
