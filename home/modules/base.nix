{
  lib,
  username ? "sdelcore",
  ...
}:

{
  home.username = lib.mkDefault username;
  home.homeDirectory = lib.mkDefault "/home/${username}";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";
}
