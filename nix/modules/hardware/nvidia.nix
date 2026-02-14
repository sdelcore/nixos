{ config, pkgs, lib, ... }:

{
  nixpkgs.config.cudaSupport = true;
  nixpkgs.config.nvidia.acceptLicense = true;

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

  # Make CUDA libraries available to user applications (PyTorch, etc.)
  # This prepends the NVIDIA driver libs to LD_LIBRARY_PATH for all sessions
  environment.extraInit = ''
    export LD_LIBRARY_PATH="/run/opengl-driver/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
  '';

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = false;
    # production (580.x) has a bug with DP MST through Thunderbolt docks:
    # https://github.com/NVIDIA/open-gpu-kernel-modules/issues/879
    package = config.boot.kernelPackages.nvidiaPackages.dc;
    forceFullCompositionPipeline = true;
  };
  
  hardware.nvidia-container-toolkit.enable = true;

  environment.systemPackages = with pkgs; [
    cudaPackages_12.cudatoolkit
    egl-wayland
  ];

  boot.blacklistedKernelModules = [ "nouveau"];
  boot.kernelParams = [ "nouveau.modeset=0" ];

  # Enable CDI (Container Device Interface) for Docker GPU support
  virtualisation.docker.daemon.settings.features.cdi = true;

}
