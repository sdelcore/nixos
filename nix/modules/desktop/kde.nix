{ config, pkgs, ... }:

{
  home-manager.users.sdelcore = {
    

  }; # End of Home Manager

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  
  
}
