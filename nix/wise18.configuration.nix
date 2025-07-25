# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware/wise18.nix
      ./disks/wise18.nix
      ./users/default.nix
      ./modules/default.nix
      ./modules/common/boot.nix
      ./modules/common/network.nix
      ./modules/common/performance.nix
      ./modules/hardware/nvidia.headless.nix
      ./modules/software/1password.nix
      ./modules/software/ollama.nix
      ./modules/virtualization/docker.nix
    ];

  networking.hostName = "wise18"; # Define your hostname.
  networking.wireless.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
