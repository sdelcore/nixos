{
  lib,
  pkgs,
  primaryUser,
  ...
}:
{
  imports = [
    ./hardware/lab.nix
    ./disks/lab.nix
    ./profiles/base.nix
    ./profiles/desktop-session.nix
  ];

  networking.hostName = "lab";
  networking.firewall.enable = false;
  # Box suspends when idle (see below) — wake it with a WoL magic packet
  # to 2C:F7:F1:20:0F:C7 (e.g. `wakeonlan` from any LAN host).
  networking.interfaces.enp3s0.wakeOnLan.enable = true;

  # Match the other desktops: GDM prompts for login before starting Hyprland.
  hardware.graphics.enable = true;
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  # Idle: screen off after 15 min, suspend after 30. The base profile
  # disables the sleep targets, so re-enable them for this host.
  systemd.targets.sleep.enable = lib.mkForce true;
  systemd.targets.suspend.enable = lib.mkForce true;
  environment.systemPackages = with pkgs; [
    chromium
    ghostty
    hypridle
    hyprlock
    polkit_gnome
    grim
    slurp
    swappy
    xfce.thunar
  ];

  # No opnix token on this box — local password instead of 1Password.
  services.onepassword-secrets.enable = lib.mkForce false;
  users.users.${primaryUser} = {
    hashedPasswordFile = lib.mkForce null;
    hashedPassword = "$6$i0XXQCnld0rzsfQ1$9pe7qb8M1mTIsc6wwmGwga6A/aHvWcF4Vup8UyIMiSfHzZ2Bqh/nuWuLhPIbS76s0ZZhBTozES6NWwHuuz3/C.";
  };

  system.stateVersion = "25.11";
}
