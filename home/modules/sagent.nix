{ inputs, lib, config, pkgs, osConfig, ... }:
let
  cfg = config.services.sagent;
  sagent = inputs.sagent.packages.${pkgs.system}.default;
  hostname = osConfig.networking.hostName or "unknown-host";

  # Optional wrapper that exports ANTHROPIC_API_KEY from a raw-content
  # secret file (opnix/sops style) before launching sagent. When apiKeyFile
  # is null the Agent SDK falls back to the user's ~/.claude/ OAuth login.
  launcher = pkgs.writeShellScript "sagent-launcher" ''
    set -eu
    ${lib.optionalString (cfg.apiKeyFile != null) ''
      if [ -s "${toString cfg.apiKeyFile}" ]; then
        ANTHROPIC_API_KEY="$(${pkgs.coreutils}/bin/cat "${toString cfg.apiKeyFile}")"
        export ANTHROPIC_API_KEY
      fi
    ''}
    exec ${cfg.package}/bin/sagent watch-all \
      --model ${lib.escapeShellArg cfg.model} \
      ${lib.escapeShellArgs cfg.extraArgs}
  '';
in
{
  options.services.sagent = {
    enable = lib.mkEnableOption "sagent — Claude Code session scribe";

    package = lib.mkOption {
      type = lib.types.package;
      default = sagent;
      description = "The sagent package to install.";
    };

    outDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/Obsidian/sagent/${hostname}";
      description = ''
        Root directory for digest output. sagent writes
        `<project>/<session-id>/` underneath this. Defaults to
        ~/Obsidian/sagent/<hostname>/ so synced vaults don't collide
        across machines.
      '';
    };

    model = lib.mkOption {
      type = lib.types.str;
      default = "claude-haiku-4-5";
      description = "Model id used for digest generation.";
    };

    apiKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/var/lib/opnix/secrets/anthropicApiKey";
      description = ''
        Optional. Path to a file whose contents are the raw Anthropic API
        key (no `KEY=` prefix). When set, the launcher exports
        ANTHROPIC_API_KEY and sagent bills that key per-token. When null,
        the Agent SDK uses the user's Claude Code subscription auth — no
        key needed.
      '';
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional arguments appended to `sagent watch-all`.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    systemd.user.services.sagent = {
      Unit = {
        Description = "sagent — Claude Code session scribe";
        After = [ "default.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${launcher}";
        Environment = [
          "SAGENT_OUT=${cfg.outDir}"
          "PATH=${config.home.homeDirectory}/.local/bin:${lib.makeBinPath [ pkgs.coreutils ]}"
          "HOME=${config.home.homeDirectory}"
        ];
        Restart = "on-failure";
        RestartSec = "30s";
      };

      Install.WantedBy = [ "default.target" ];
    };
  };
}
