{ config, pkgs, ... }:

{
  fileSystems."/mnt/research" = {
    device = "tower.local:/mnt/user/research";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };

  fileSystems."/mnt/downloads" = {
    device = "tower.local:/mnt/user/downloads";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };

  fileSystems."/mnt/media" = {
    device = "tower.local:/mnt/user/media";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };

  fileSystems."/mnt/backups" = {
    device = "tower.local:/mnt/user/backups";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };
}
