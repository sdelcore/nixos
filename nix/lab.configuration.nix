{ lib, primaryUser, ... }: {
  imports = [
    ./hardware/lab.nix
    ./disks/lab.nix
    ./profiles/base.nix
  ];

  networking.hostName = "lab";
  networking.firewall.enable = false;

  # No opnix token on this box — local password instead of 1Password.
  services.onepassword-secrets.enable = lib.mkForce false;
  users.users.${primaryUser} = {
    hashedPasswordFile = lib.mkForce null;
    hashedPassword = "$6$i0XXQCnld0rzsfQ1$9pe7qb8M1mTIsc6wwmGwga6A/aHvWcF4Vup8UyIMiSfHzZ2Bqh/nuWuLhPIbS76s0ZZhBTozES6NWwHuuz3/C.";
  };

  system.stateVersion = "25.11";
}
