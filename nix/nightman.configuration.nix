{ ... }: {
  imports = [
    ./hardware/nightman.nix
    ./profiles/base.nix
    ./profiles/desktop.nix
    ./profiles/development.nix
    ./modules/desktop/monitors.nix
    ./modules/software/droidcode.nix
  ];

  networking.hostName = "nightman";
  networking.wireless.enable = false;

  system.stateVersion = "24.05";
}
