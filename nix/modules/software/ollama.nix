{ config, pkgs, ... }:

{
  virtualisation.oci-containers = {
    backend = "docker";

    containers.ollama = {
      autoStart = true;
      image = "ollama/ollama";
      ports = [ "11434:11434" ];
      extraOptions = [ "--devices nvidia.com/gpu=all" ];
      volumes = [ "ollama:/home/sdelcore/.ollama" ];
      environment = {
        OLLAMA_HOST="0.0.0.0:11434";
        OLLAMA_FLASH_ATTENTION="1";
      };
    };
  };
}