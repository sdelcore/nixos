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
      ctx = 262144;
      extra = "--cpu-moe --no-mmap --image-min-tokens 1024 --spec-type draft-mtp --spec-draft-n-max 2";
    };
    "Qwen3.6-27B-MTP" = {
      hf = "unsloth/Qwen3.6-27B-MTP-GGUF:UD-Q4_K_XL";
      ctx = 262144;
      gpuLayers = 50;
      extra = "--no-mmproj --spec-type draft-mtp --spec-draft-n-max 2";
    };
    "Qwen3-8B" = {
      hf = "unsloth/Qwen3-8B-GGUF:Q4_K_M";
      ctx = 16384;
      extra = "";
    };
    "Phi-4" = {
      hf = "unsloth/phi-4-GGUF:Q4_K_M";
      ctx = 16384;
      extra = "";
    };
    # Embedding model for the LiteLLM MCP semantic tool filter on the ai VM.
    # F16 rather than Q8_0: the file is only 1.2 GB, and quantization noise
    # shows up directly in cosine distance. 1024 dimensions, last-token pooling
    # (what Qwen3-Embedding was trained with), 8192 context is far more than
    # tool descriptions need.
    "Qwen3-Embedding-0.6B" = {
      hf = "Qwen/Qwen3-Embedding-0.6B-GGUF:F16";
      ctx = 8192;
      embedding = true;
      ttl = 1800;
      extra = "";
    };
  };

  # Chat models share one flag set. An embedding model needs a different one:
  # no KV-cache quantization, because it perturbs the vectors, and the pooling
  # mode the model was trained with.
  chatFlags = "--flash-attn on --cache-type-k q8_0 --cache-type-v q8_0 -np 1";
  embedFlags = m: "--embedding --pooling ${m.pooling or "last"} -ub ${toString m.ctx}";

  mkModel = name: m:
    "  \"${name}\":\n" +
    "    cmd: ${llamaServer} -hf ${m.hf} --host 127.0.0.1 --port \${PORT} --ctx-size ${toString m.ctx} --n-gpu-layers ${toString (m.gpuLayers or 999)} ${if m.embedding or false then embedFlags m else chatFlags} ${m.extra}\n" +
    "    ttl: ${toString (m.ttl or 900)}\n";

  # Groups control what swapping does. The chat group keeps the old behaviour:
  # one model at a time, and loading one unloads everything else. The embedding
  # model needs its own group, because the semantic tool filter embeds the user
  # query on every request that carries MCP tools. In the default group each of
  # those calls would evict the loaded chat model.
  chatModels = filterAttrs (_: m: !(m.embedding or false)) models;
  embedModels = filterAttrs (_: m: m.embedding or false) models;

  mkMembers = ms: concatStrings (map (n: "      - \"${n}\"\n") (attrNames ms));

  mkGroup = name: settings: ms:
    optionalString (ms != { })
      ("  \"${name}\":\n" + settings + "    members:\n" + mkMembers ms);

  llamaSwapConfig = pkgs.writeText "llama-swap.yaml"
    ("healthCheckTimeout: 600\nstartPort: 9300\nmodels:\n"
      + concatStrings (mapAttrsToList mkModel models)
      + "groups:\n"
      + mkGroup "chat" "    swap: true\n    exclusive: true\n" chatModels
      + mkGroup "embedding" "    swap: false\n    exclusive: false\n    persistent: true\n" embedModels);
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
