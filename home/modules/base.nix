{ config, pkgs, ... }:

{
  # Common home-manager settings shared across all machines
  home.username = "sdelcore";
  home.homeDirectory = "/home/sdelcore";
  home.stateVersion = "24.05";
  
  programs.home-manager.enable = true;
  
  systemd.user.startServices = "sd-switch";
  
  home.sessionVariables = {
    SSH_ASKPASS = "${pkgs.lxqt.lxqt-openssh-askpass}/bin/lxqt-openssh-askpass";
  };
  
  # Common dconf settings for virt-manager
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
}