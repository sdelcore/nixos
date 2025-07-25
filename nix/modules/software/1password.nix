{ config, pkgs, ... }:

{

  # Enable 1password plugins on interactive shell init
  #programs.bash.interactiveShellInit = ''
  #  source /home/sdelcore/.config/op/plugins.sh
  #'';

  # Enable the 1Passsword GUI with myself as an authorized user for polkit
  programs = {
    _1password = {
      enable = true;
    };

    _1password-gui = {
      enable = true;
      polkitPolicyOwners = ["sdelcore"];
    };
  };

  # Enable 1password to open with gnomekeyring
  security.pam.services."1password".enableGnomeKeyring = true;

  environment.etc = {
      "1password/custom_allowed_browsers" = {
        text = ''
          firefox
          firefox-bin
          zen
        '';
        mode = "0755";
      };
    };

}