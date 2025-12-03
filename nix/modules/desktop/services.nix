{ pkgs, ... }: {
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  services.xserver = {
    enable = true;
    xkb.layout = "us";
    xkb.variant = "";
    excludePackages = with pkgs; [ xterm ];
    displayManager.gdm.enable = true;
  };

  nixpkgs.config.firefox.enableDrmSupport = true;
}
