{ config, pkgs, lib, ... }:

# to update to latest: `nix-channel --update nixos; nixos-rebuild switch`


let
  dockerEnabled = true;
in

{
  # Enable common container config files
  virtualisation.containers.enable = true;
  virtualisation.oci-containers.backend = "podman";
  
  virtualisation.podman = {
    enable = true;
    
    # Enable Docker compatibility mode (creates docker alias)
    dockerCompat = true;
    
    # Enable the Docker-compatible socket
    dockerSocket.enable = true;
    
    # Default network settings for DNS (similar to Docker's networking)
    defaultNetwork.settings = {
      dns_enabled = true;
    };
  };

  environment.systemPackages = with pkgs; [ 
    podman-compose 
    slirp4netns 
    fuse-overlayfs 
    podman-desktop
    ];
    
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;

  users.users.sdelcore.linger = true;
  
  # For insecure registry configuration
  virtualisation.containers.registries.insecure = [ "registry.sdelcore.com" ];
  
  # Additional Podman-specific configuration can be added via containers config
  environment.etc."containers/registries.conf.d/50-insecure.conf".text = ''
    [[registry]]
    location = "registry.sdelcore.com"
    insecure = true
  '';
}
