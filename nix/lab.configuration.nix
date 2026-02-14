{ ... }: {
  imports = [
    ./hardware/lab.nix
    ./profiles/base.nix
    ./modules/desktop/default.nix
    ./modules/desktop/hyprland.nix
  ];

  networking.hostName = "lab";
  networking.firewall.enable = false;

  system.stateVersion = "25.11";
}
