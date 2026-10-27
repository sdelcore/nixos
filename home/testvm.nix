{ config, pkgs, ... }:

{
  imports = [
    ./modules/base.nix # Core home config
    ./modules/common.nix
  ];
  home.sessionVariables.SSH_ASKPASS = "${pkgs.lxqt.lxqt-openssh-askpass}/bin/lxqt-openssh-askpass";
}
