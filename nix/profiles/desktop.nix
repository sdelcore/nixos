{ ... }: {
  imports = [
    ../modules/desktop/default.nix
    ./desktop-session.nix
    ../modules/hardware/nvidia.nix
    ../modules/hardware/yubikey.nix
    ../modules/hardware/ledger.nix
    ../modules/software/1password.nix
    ../modules/software/flatpak.nix
    ../modules/network/xrdp.nix
    ../modules/network/tailscale.nix
    ../modules/network/netbird.nix
  ];

  # dayman + nightman are personal NetBird peers (whole-homelab reach via the route).
  services.netbirdClient.enable = true;
}
