{ inputs, pkgs, ... }:

let
  unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };
in
{
  services.ollama = {
    enable = true;
    package = unstable.ollama-cuda;
    acceleration = "cuda";
    host = "0.0.0.0";
    port = 11434;

    # Keep the existing data directory from the previous Docker setup so
    # we don't re-pull models. The `ollama` system user owns the files
    # (chowned by the tmpfiles rule below); user access goes through the
    # daemon on port 11434, not direct filesystem access.
    home = "/home/sdelcore/.ollama";
    models = "/home/sdelcore/.ollama/models";

    environmentVariables = {
      OLLAMA_FLASH_ATTENTION = "1";
    };
  };

  # The Docker container wrote files as root via bind mount. Hand them
  # to the new ollama daemon's user. Idempotent — no-op once correct.
  systemd.tmpfiles.rules = [
    "Z /home/sdelcore/.ollama - ollama ollama - -"
  ];
}
