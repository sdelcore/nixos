{...}: {
  imports = [ ./common.nix ];

  hyprland = {
    configSource = ./../../configs/hypr/laptop;
    wallpaper = ./../../wallpapers/wallhaven-j3qq15.jpg;
    wallpaperLock = ./../../wallpapers/wallhaven-j3qq15.jpg;
    enableSuspend = true;
  };
}
