{ ... }: {
  imports = [
    ./hardware/dayman.nix
    ./disks/nvme0n1.full.nix
    ./profiles/base.nix
    ./profiles/desktop.nix
    ./profiles/development.nix
    ./profiles/laptop.nix
  ];

  networking.hostName = "dayman";

  system.stateVersion = "24.05";
}
