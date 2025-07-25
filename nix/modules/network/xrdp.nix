{ config, pkgs, ... }:

{
  
  # RDP
  # See https://nixos.wiki/wiki/Remote_Desktop
  services.xrdp.enable = true;

  # Enable Gnome-Remote-Desktop
  services.xrdp.defaultWindowManager = "gnome-remote-desktop";
  services.xrdp.openFirewall = true;
  
}