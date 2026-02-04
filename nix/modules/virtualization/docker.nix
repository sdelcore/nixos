{ config, pkgs, ... }:

# to update to latest: `nix-channel --update nixos; nixos-rebuild switch`


let
  dockerEnabled = true;
in

{
  virtualisation.containers.enable = true;
  virtualisation.oci-containers.backend = "docker";
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true; 
    listenOptions = [ "/run/docker.sock" "0.0.0.0:2376" ];
    extraOptions = "--insecure-registry registry.sdelcore.com";
    package = pkgs.docker_28;
    rootless.daemon.settings.features.cdi = true;
    daemon.settings.features.cdi = true;
  };

  virtualisation.containers.registries.insecure = [ "registry.sdelcore.com" ];
  
  environment.etc."containers/registries.conf.d/50-insecure.conf".text = ''
    [[registry]]
    location = "registry.sdelcore.com"
    insecure = true
  '';

  environment.systemPackages = with pkgs; [ 
    #docker-compose 
    ];
}
