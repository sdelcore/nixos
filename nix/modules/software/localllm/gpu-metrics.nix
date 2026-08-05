{ config, pkgs, lib, ... }:

with lib;

let
  enabled = config.networking.hostName == "nightman";
  port = 9835;
in
{
  config = mkIf enabled {
    # nvidia_gpu_exporter — GPU metrics for the homelab Prometheus (the `nvidia-gpu`
    # job on 10.0.0.33). The 4090 runs the local chat models and the embedding
    # model behind the LiteLLM MCP tool filter, so VRAM pressure and temperature
    # are the leading indicator when either starts to degrade.
    #
    # Same port and package as the homelab's monitoring-agent module uses for
    # nvr's T400, so one scrape job covers both machines.
    #
    # nixpkgs has no services.prometheus.exporters option for this, so the unit
    # is written out directly. It shells out to nvidia-smi, hence the video
    # group rather than a fully sandboxed unit.
    systemd.services.nvidia-gpu-exporter = {
      description = "Prometheus NVIDIA GPU exporter";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.prometheus-nvidia-gpu-exporter}/bin/nvidia_gpu_exporter --web.listen-address=:${toString port}";
        Restart = "on-failure";
        RestartSec = 5;
        DynamicUser = true;
        SupplementaryGroups = [ "video" ];
      };
    };

    networking.firewall.allowedTCPPorts = [ port ];
  };
}
