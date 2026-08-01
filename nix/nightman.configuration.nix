{ primaryUser, ... }: {
  imports = [
    ./hardware/nightman.nix
    ./profiles/base.nix
    ./profiles/desktop.nix
    ./profiles/development.nix
    ./modules/desktop/monitors.nix
    ./modules/software/droidcode.nix
  ];

  networking.hostName = "nightman";
  networking.wireless.enable = false;

  # Start this user's systemd instance at boot instead of at first login, so
  # the voiced STT/TTS API answers Open WebUI on the ai VM whether or not
  # anyone has logged in. Only nightman serves voice to the LAN; dayman is a
  # laptop, where a daemon running past logout is a battery cost with no user.
  users.users.${primaryUser}.linger = true;

  system.stateVersion = "24.05";
}
