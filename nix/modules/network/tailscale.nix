{ config, pkgs, ... }:

{
  # Enable Tailscale service
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  # Fix for exit node connectivity issues
  networking.firewall.checkReversePath = "loose";

  # Add tailscale CLI to system packages
  environment.systemPackages = with pkgs; [
    unstable.tailscale
  ];
}
