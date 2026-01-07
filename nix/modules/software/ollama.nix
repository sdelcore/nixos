{ config, pkgs, ... }:

{
  virtualisation.oci-containers = {

    containers.ollama = {
      autoStart = true;
      image = "ollama/ollama";
      ports = [ "11434:11434" ];
      extraOptions = [ 
        "--device=nvidia.com/gpu=all"
        "--pull=always"
      ];
      volumes = [ "/home/sdelcore/.ollama:/root/.ollama" ];
      environment = {
        OLLAMA_HOST="0.0.0.0:11434";
        OLLAMA_FLASH_ATTENTION="1";
      };
    };
  };
}