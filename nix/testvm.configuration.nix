{ config, pkgs, lib, inputs, primaryUser, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./profiles/base.nix
    ./modules/desktop/default.nix  # packages, fonts, steam, services
    ./modules/desktop/gnome.nix    # GNOME instead of Hyprland
    ./modules/virtualization/nix-testvm.nix
  ];

  # Deliberately impersonates dayman: opnix resolves secrets by hostname, so the
  # throwaway test VM borrows dayman's identity to reuse the same 1Password items
  # instead of needing its own. This is the only host whose name != its config name.
  networking.hostName = "dayman";

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
