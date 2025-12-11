{ inputs, lib, config, pkgs, system, ... }:
let
  sttd = inputs.sttd.packages.${system}.default;
in
{
  home.packages = [
    sttd
    pkgs.wtype        # For text injection
    pkgs.wl-clipboard # For clipboard fallback
  ];

  # sttd daemon systemd user service
  systemd.user.services.sttd = {
    Unit = {
      Description = "Speech-to-Text Daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${sttd}/bin/sttd start";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };

  # Default configuration
  xdg.configFile."sttd/config.toml".text = ''
    [transcription]
    model = "base"
    device = "auto"
    compute_type = "auto"
    language = "en"
    streaming = true         # Continuous streaming transcription
    chunk_duration = 2.0     # Seconds per chunk

    [audio]
    sample_rate = 16000
    channels = 1
    device = "default"
    beep_enabled = true

    [output]
    method = "wtype"
  '';
}
