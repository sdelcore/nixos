# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware/dayman.nix
      ./disks/nvme0n1.full.nix
      ./modules/default.nix
      ./modules/common/boot.nix
      ./modules/common/network.nix
      ./modules/common/performance.nix
      ./modules/common/power-management.nix
      ./modules/desktop/default.nix
      ./modules/desktop/hyprland.nix
      ./modules/network/xrdp.nix
      ./modules/hardware/nvidia.nix
      ./modules/hardware/yubikey.nix
      ./modules/hardware/ledger.nix
      ./modules/software/1password.nix
      ./modules/software/flatpak.nix
      ./modules/software/spicetify.nix
      ./modules/software/ollama.nix
      ./modules/virtualization/docker.nix
      ./modules/virtualization/libvirt.nix
      ./users/default.nix
    ];

  networking.hostName = "dayman"; # Define your hostname.

  services.logind.lidSwitchExternalPower = "ignore";
  services.logind.lidSwitchDocked = "ignore";


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
