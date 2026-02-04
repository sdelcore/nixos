{ config, pkgs, ... }:

{
  # Graphics Card

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages = [ ];
  };

  hardware.graphics = {
    enable = true;
  };

  environment.variables.VDPAU_DRIVER = "va_gl";
  environment.variables.LIBVA_DRIVER_NAME = "nvidia";
  environment.variables.MUTTER_DEBUG_KMS_THREAD_TYPE="user";

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.production;
    forceFullCompositionPipeline = true;
    nvidiaSettings = true;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
        
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:01:0:0";
    };
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
      package = pkgs.docker_28;
      rootless.daemon.settings.features.cdi = true;
      daemon.settings.features.cdi = true;
    };
  };

}
