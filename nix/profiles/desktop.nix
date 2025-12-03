{ ... }: {
  imports = [
    ../modules/desktop/default.nix
    ../modules/desktop/hyprland.nix
    ../modules/hardware/nvidia.nix
    ../modules/hardware/yubikey.nix
    ../modules/hardware/ledger.nix
    ../modules/software/1password.nix
    ../modules/software/flatpak.nix
    ../modules/network/xrdp.nix
    ../modules/network/tailscale.nix
  ];
}
