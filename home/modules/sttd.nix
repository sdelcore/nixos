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

  # sttd daemon systemd user service
  # Started explicitly by Hyprland via exec-once = systemctl --user start sttd
  systemd.user.services.sttd = {
    Unit = {
      Description = "Speech-to-Text Daemon";
    };

    Service = {
      Type = "simple";
      ExecStart = "${sttd}/bin/sttd start";
      Restart = "on-failure";
      RestartSec = 5;
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
    host = "127.0.0.1"       # 0.0.0.0 to accept remote connections
    port = 8765

    [client]
    server_url = "http://127.0.0.1:8765"
    timeout = 60.0           # Request timeout in seconds
  '';
}
