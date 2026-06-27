{ inputs, config, pkgs, lib, ... }:

with lib;

let
  enabled = config.networking.hostName == "nightman";

  unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs) system;
    config = { allowUnfree = true; cudaSupport = true; };
  };
  llamaServer = "${unstable.llama-cpp}/bin/llama-server";

  port = 9292;

  models = {
    "Qwen3.6-35B-A3B-MTP" = {
      hf = "unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL";
      extra = "--cpu-moe --spec-type draft-mtp --spec-draft-n-max 2";
    };
    "Qwen3-8B" = {
      hf = "unsloth/Qwen3-8B-GGUF:Q4_K_M";
      extra = "";
    };
    "Phi-4" = {
      hf = "unsloth/phi-4-GGUF:Q4_K_M";
      extra = "";
    };
  };

  mkModel = name: m:
    "  \"${name}\":\n" +
    "    cmd: ${llamaServer} -hf ${m.hf} --host 127.0.0.1 --port \${PORT} --ctx-size 16384 --n-gpu-layers 999 --flash-attn on --cache-type-k q8_0 --cache-type-v q8_0 -np 1 ${m.extra}\n" +
    "    ttl: 900\n";

  llamaSwapConfig = pkgs.writeText "llama-swap.yaml"
    ("healthCheckTimeout: 600\nstartPort: 9300\nmodels:\n"
      + concatStrings (mapAttrsToList mkModel models));
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

    networking.firewall.allowedTCPPorts = [ port ];
  };
}
