{ ... }: {
  imports = [
    ./hardware/lab.nix
    ./disks/lab.nix
    ./profiles/base.nix
    ./modules/desktop/lab.nix
  ];

  networking.hostName = "lab";
  networking.firewall.enable = false;

  system.stateVersion = "25.11";
}
