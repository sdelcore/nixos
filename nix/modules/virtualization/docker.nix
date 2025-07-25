{ config, pkgs, ... }:

# to update to latest: `nix-channel --update nixos; nixos-rebuild switch`


let
  dockerEnabled = true;
in

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true; 
    listenOptions = [ "/run/docker.sock" "0.0.0.0:2376" ];
    extraOptions = "--insecure-registry registry.sdelcore.com";
  };
}
