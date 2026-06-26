{ ... }: {
  imports = [
    ./hardware/dayman.nix
    ./disks/dayman.nix
    ./profiles/base.nix
    ./profiles/desktop.nix
    ./profiles/development.nix
    ./profiles/laptop.nix
    ./modules/software/droidcode.nix
  ];

  networking.hostName = "dayman";

  system.stateVersion = "24.05";
}
