{ inputs, lib, config, pkgs, ... }:
let
  sttd = inputs.sttd.packages.${pkgs.system}.default;
in
{
  home.packages = [
    sttd
    pkgs.wtype        # For text injection
    pkgs.wl-clipboard # For clipboard fallback
  ];

  # sttd daemon with embedded HTTP server
  # Provides both desktop mode (tray icon, hotkey toggle) and HTTP API
  # Started explicitly by Hyprland via exec-once = systemctl --user start sttd
  # HTTP API used by mem and other services that need transcription
  systemd.user.services.sttd = {
    Unit = {
      Description = "Speech-to-Text Daemon";
      After = [ "network.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${sttd}/bin/sttd start --http";
      Restart = "on-failure";
      RestartSec = 5;
      # Environment variables for GPU support
      Environment = [
        "CUDA_VISIBLE_DEVICES=0"
      ];
    };
  };

  # Default configuration
  xdg.configFile."sttd/config.toml".text = ''
    [transcription]
    model = "base"           # tiny, base, small, medium, large-v3
    device = "auto"          # auto, cuda, cpu
    compute_type = "auto"    # auto, float16, int8, float32
    language = "en"

    [audio]
    sample_rate = 16000
    channels = 1
    device = "default"       # or specific device name
    beep_enabled = true      # audio feedback on start/stop

    [diarization]
    device = "auto"          # auto, cuda, cpu
    similarity_threshold = 0.5  # Profile matching threshold (0-1)
    min_segment_duration = 0.5  # Minimum segment length for embedding (seconds)

    [server]
    host = "0.0.0.0"         # Accept remote connections (used by --http flag)
    port = 8765
  '';
}
