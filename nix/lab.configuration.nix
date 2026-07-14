{ lib, pkgs, primaryUser, ... }: {
  imports = [
    ./hardware/lab.nix
    ./disks/lab.nix
    ./profiles/base.nix
  ];

  networking.hostName = "lab";
  networking.firewall.enable = false;
  # Box suspends when idle (see below) — wake it with a WoL magic packet
  # to 2C:F7:F1:20:0F:C7 (e.g. `wakeonlan` from any LAN host).
  networking.interfaces.enp3s0.wakeOnLan.enable = true;

  # Minimal Sway session for the web-search browser: greetd auto-logs
  # straight into sway on the console, no display manager.
  environment.systemPackages = [ pkgs.chromium ];
  hardware.graphics.enable = true;
  programs.sway = {
    enable = true;
    xwayland.enable = true;
  };
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.sway}/bin/sway";
      user = primaryUser;
    };
  };

  # Idle: screen off after 15 min, suspend after 30. The base profile
  # disables the sleep targets, so re-enable them for this host.
  systemd.targets.sleep.enable = lib.mkForce true;
  systemd.targets.suspend.enable = lib.mkForce true;
  environment.etc."sway/config.d/idle.conf".text = ''
    exec swayidle -w \
      timeout 900 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' \
      timeout 1800 'systemctl suspend'
  '';

  # No opnix token on this box — local password instead of 1Password.
  services.onepassword-secrets.enable = lib.mkForce false;
  users.users.${primaryUser} = {
    hashedPasswordFile = lib.mkForce null;
    hashedPassword = "$6$i0XXQCnld0rzsfQ1$9pe7qb8M1mTIsc6wwmGwga6A/aHvWcF4Vup8UyIMiSfHzZ2Bqh/nuWuLhPIbS76s0ZZhBTozES6NWwHuuz3/C.";
  };

  system.stateVersion = "25.11";
}
