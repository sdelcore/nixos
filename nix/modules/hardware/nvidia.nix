{ config, pkgs, ... }:

{
  # Graphics Card

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [ ];
  };

  environment.variables.VDPAU_DRIVER = "va_gl";
  environment.variables.LIBVA_DRIVER_NAME = "nvidia";
  environment.variables.MUTTER_DEBUG_KMS_THREAD_TYPE="user";

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
    forceFullCompositionPipeline = true;
  };
  
  hardware.nvidia-container-toolkit.enable = true;

  environment.systemPackages = with pkgs; [
    cudaPackages_12_2.cudatoolkit
    egl-wayland
  ];

  boot.blacklistedKernelModules = [ "nouveau"];
  boot.kernelParams = [ "nouveau.modeset=0" ];

  virtualisation = {
    docker = {
      package = pkgs.docker_27;
      rootless.daemon.settings.features.cdi = true;
      enableNvidia = true;
      daemon.settings.features.cdi = true;
    };
  };

}
