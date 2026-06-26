{ config, pkgs, ... }:

# Docker daemon for the desktop/dev hosts.
# Update Docker by bumping the flake inputs: `just update` then `just switch`.

{
  virtualisation.containers.enable = true;
  virtualisation.oci-containers.backend = "docker";
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    # Local unix socket only. Do NOT add a TCP listener (e.g. 0.0.0.0:2376)
    # without TLS + client-cert auth: an open Docker socket is root-equivalent.
    listenOptions = [ "/run/docker.sock" ];
    extraOptions = "--insecure-registry registry.sdelcore.com";
    package = pkgs.docker_29;
    rootless.daemon.settings.features.cdi = true;
    daemon.settings.features.cdi = true;
  };

  virtualisation.containers.registries.insecure = [ "registry.sdelcore.com" ];

  environment.etc."containers/registries.conf.d/50-insecure.conf".text = ''
    [[registry]]
    location = "registry.sdelcore.com"
    insecure = true
  '';
}
