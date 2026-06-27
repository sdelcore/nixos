{ inputs, config, pkgs, lib, ... }:

with lib;

let
  enabled = config.networking.hostName == "nightman";

  # CUDA + MTP need llama.cpp >= 9180; stable nixpkgs is too old, so pull it from
  # unstable with cudaSupport (same pattern as vllm.nix).
  unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs) system;
    config = { allowUnfree = true; cudaSupport = true; };
  };

  port = 9292;
  modelName = "Qwen3.6-35B-A3B-MTP";
  # Resolved + cached by llama-server (repo:quant), not a hardcoded snapshot path.
  hfModel = "unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL";

  # --cpu-moe keeps the MoE expert weights on CPU (the bulk of a 35B-A3B); only
  # the active path lives in VRAM, so it fits a 24GB card. MTP via --spec-type.
  llamaSwapConfig = pkgs.writeText "llama-swap.yaml" ''
    healthCheckTimeout: 600
    startPort: 9300
    models:
      "${modelName}":
        cmd: |
          ${unstable.llama-cpp}/bin/llama-server
          -hf ${hfModel}
          --host 127.0.0.1 --port ''${PORT}
          --ctx-size 16384 --n-gpu-layers 999 --cpu-moe --flash-attn on
          --cache-type-k q8_0 --cache-type-v q8_0 -np 1
          --spec-type draft-mtp --spec-draft-n-max 2
        ttl: 900
  '';
in
{
  config = mkIf enabled {
    systemd.services.llama-swap = {
      description = "llama-swap on-demand LLM proxy";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        User = "sdelcore";
        ExecStart = "${pkgs.llama-swap}/bin/llama-swap -config ${llamaSwapConfig} -listen 0.0.0.0:${toString port}";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    # No auth (LAN desktop, open for any LAN PC); reachable as nightman.tap:9292
    # for the LiteLLM gateway and other machines.
    networking.firewall.allowedTCPPorts = [ port ];
  };
}
