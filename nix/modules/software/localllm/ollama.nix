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

    environmentVariables = {
      OLLAMA_FLASH_ATTENTION = "1";
    };
  };

  # services.ollama runs with DynamicUser, so its data must live under
  # /var/lib/ollama (the StateDirectory) — the daemon has no traverse
  # permission into /home/sdelcore. This oneshot copies the models from
  # the previous Docker container's bind-mount path the first time it
  # runs; ollama.service's StateDirectory will chown them on its next
  # start. Idempotent.
  systemd.services.ollama-migrate = {
    description = "Seed /var/lib/ollama from the legacy ~/.ollama dir";
    before = [ "ollama.service" ];
    requiredBy = [ "ollama.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "ollama-migrate" ''
        set -euo pipefail
        if [ -d /var/lib/ollama/models ] \
            && [ -n "$(${pkgs.coreutils}/bin/ls -A /var/lib/ollama/models 2>/dev/null)" ]; then
          echo "models already present, skipping"
          exit 0
        fi
        if [ ! -d /home/sdelcore/.ollama/models ]; then
          echo "no legacy models found at /home/sdelcore/.ollama/models"
          exit 0
        fi
        ${pkgs.coreutils}/bin/mkdir -p /var/lib/ollama
        ${pkgs.coreutils}/bin/cp -a /home/sdelcore/.ollama/models /var/lib/ollama/
      '';
    };
  };
}
