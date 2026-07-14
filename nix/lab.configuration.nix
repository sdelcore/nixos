{ lib, pkgs, primaryUser, ... }: {
  imports = [
    ./hardware/lab.nix
    ./disks/lab.nix
    ./profiles/base.nix
  ];

  networking.hostName = "lab";
  networking.firewall.enable = false;

  # Minimal Sway session for the web-search browser: greetd auto-logs
  # straight into sway on the console, no display manager.
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

  # No opnix token on this box — local password instead of 1Password.
  services.onepassword-secrets.enable = lib.mkForce false;
  users.users.${primaryUser} = {
    hashedPasswordFile = lib.mkForce null;
    hashedPassword = "$6$i0XXQCnld0rzsfQ1$9pe7qb8M1mTIsc6wwmGwga6A/aHvWcF4Vup8UyIMiSfHzZ2Bqh/nuWuLhPIbS76s0ZZhBTozES6NWwHuuz3/C.";
  };

  system.stateVersion = "25.11";
}
