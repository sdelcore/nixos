{lib, ...}: {
  imports = [ ./common.nix ];

  hyprland = {
    configSource = ./../../configs/hypr/lab;
    wallpaper = ./../../wallpapers/topographic-black.jpg;
    wallpaperLock = ./../../wallpapers/topographic-black.jpg;
    enableSuspend = false;
  };

  # Override NVIDIA session vars from common.nix for AMD iGPU
  home.sessionVariables = {
    GBM_BACKEND = lib.mkForce "";
    LIBVA_DRIVER_NAME = lib.mkForce "radeonsi";
    __GLX_VENDOR_LIBRARY_NAME = lib.mkForce "mesa";
    __GL_GSYNC_ALLOWED = lib.mkForce "";
  };
}
