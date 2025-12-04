{ config, pkgs, lib, inputs, primaryUser, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./profiles/base.nix
    ./modules/desktop/default.nix  # packages, fonts, steam, services
    ./modules/desktop/gnome.nix    # GNOME instead of Hyprland
    ./modules/virtualization/nix-testvm.nix
  ];

  networking.hostName = "dayman";  # Use dayman to reuse 1Password secrets

  # Minimal filesystem for VM (overridden by build-vm at runtime)
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # Disable bootloader for VM (QEMU handles boot)
  boot.loader.grub.enable = false;

  # Increase resources for GNOME (heavier than Hyprland)
  virtualisation.vmVariant = {
    virtualisation.memorySize = lib.mkForce 4096;  # 4GB
    virtualisation.cores = lib.mkForce 4;
  };

  # Auto-login for convenience in VM
  services.displayManager.autoLogin = {
    enable = true;
    user = primaryUser;
  };

  system.stateVersion = "25.05";
}
