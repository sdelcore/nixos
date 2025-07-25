# NixOS Config File
# 
# Latest Change: June 8, 2024
#
# Setup Notes:
#	To set up this configuration file, ensure that the dotfiles for the system are located in ~/Dotfiles.
#	This can be done with a systemlink, such as by running:
#		`ln -s ~/Nextcloud/Dotfiles ~/Dotfiles`
#	The nextcloud-desktop package can be installed to move dotfiles over to the system.
#	Otherwise, the goal of this system is to be completely reproducable only by moving the one Configuration.nix file to the new system.
# Configuration Notes:
#	Once this file is configured, you can rebuild your system with (as root):
#		`nixos-rebuild switch`
#
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{

  # Install Flatpak
  environment.systemPackages = with pkgs; [
    flatpak
  ];

  # Enable Flatpak
  services.flatpak.enable = true;

  # Enable XDG Desktop Portal (required for Flatpak)
  # Note: Portal configuration is handled by desktop environment modules

  # Enable D-Bus (required for XDG portals)
  services.dbus.enable = true;

  # Add Flatpak directories to XDG_DATA_DIRS through environment.profiles
  environment.profiles = [ 
    "/var/lib/flatpak/exports"
    "\${HOME}/.local/share/flatpak/exports"
  ];

  systemd.packages = [
    (pkgs.writeTextFile {
      name = "flatpak-dbus-overrides";
      destination = "/etc/systemd/user/dbus-.service.d/flatpak.conf";
      text = ''
        [Service]
        ExecSearchPath=${pkgs.flatpak}/bin
      '';
    })
  ];

  # Add Flatpak Repositories 
  environment.etc."flatpak/repo.d/flathub.conf".text = ''
    [remote "flathub"]
    url=https://flathub.org/repo/
    gpg-verify=true
    gpg-verify-summary=true
    xa.title=Flathub
    xa.comment=Apps for all Linux devices
  '';
  system.activationScripts.flatpak = ''
    ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  '';

  # Install Flatpak Apps
     system.activationScripts.flatpakApps = ''
     ${pkgs.flatpak}/bin/flatpak install -y flathub md.obsidian.Obsidian
     ${pkgs.flatpak}/bin/flatpak install -y com.rustdesk.RustDesk
     ${pkgs.flatpak}/bin/flatpak install -y com.usebottles.bottles
     ${pkgs.flatpak}/bin/flatpak update -y

     ${pkgs.flatpak}/bin/flatpak override md.obsidian.Obsidian --user --socket=wayland

   '';

}
