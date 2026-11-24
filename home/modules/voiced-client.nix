{ inputs, pkgs, ... }:

let
  voiced = inputs.voiced.packages.${pkgs.stdenv.hostPlatform.system}.default;
  tomlFormat = pkgs.formats.toml { };
in
{
  home.packages = [ voiced pkgs.wtype pkgs.wl-clipboard ];

  xdg.configFile."voiced/config.toml".source = tomlFormat.generate "voiced-config.toml" {
    client = {
      audio_base_url = "http://llm.ai.tap/v1";
      stt_model = "nightman/stt-1";
      tts_model = "nightman/tts-1";
      api_key_env = "LITELLM_API_KEY";
    };
    assistant = {
      base_url = "http://llm.ai.tap/v1";
      model = "realy";
      api_key_env = "LITELLM_API_KEY";
    };
    transcription.replacements = {
      "cloud code" = "Claude Code";
      "hyperland" = "Hyprland";
    };
    unload_timeout_minutes = 60;
  };

  systemd.user.services.voiced = {
    Unit = {
      Description = "Voiced gateway client";
      Wants = [ "network-online.target" ];
      After = [ "network-online.target" ];
    };
    Service = {
      ExecStart = "${pkgs.bash}/bin/bash -euc 'export LITELLM_API_KEY=\"$(< /var/lib/opnix/secrets/litellmApiKey)\"; exec ${voiced}/bin/voiced start'";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
