{ inputs, lib, config, pkgs, ... }:
let
  voiced = inputs.voiced.packages.${pkgs.system}.default;
in
{
  home.packages = [
    voiced
    pkgs.wtype        # For text injection
    pkgs.wl-clipboard # For clipboard fallback
  ];

  # voiced daemon with embedded HTTP server
  # Provides desktop mode (tray icon, hotkey toggle), HTTP API for STT/TTS
  # Started explicitly by Hyprland via exec-once = systemctl --user start voiced
  # HTTP API used by mem and other services that need transcription/synthesis
  systemd.user.services.voiced = {
    Unit = {
      Description = "Voice Daemon (STT/TTS)";
      After = [ "network.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${voiced}/bin/voiced start --http";
      Restart = "on-failure";
      RestartSec = 5;
      # Environment variables for GPU support and Wayland clipboard
      Environment = [
        "CUDA_VISIBLE_DEVICES=0"
        "WAYLAND_DISPLAY=wayland-1"
        "XDG_RUNTIME_DIR=/run/user/1000"
      ];
    };
  };

  # Default configuration
  xdg.configFile."voiced/config.toml".text = ''
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

    [vad]
    enabled = false          # Disabled - VAD incorrectly filters out longer recordings
    threshold = 0.3          # Speech probability threshold (lower = more permissive)

    [tts]
    enabled = true           # Enable TTS (requires VibeVoice)
    model = "microsoft/VibeVoice-Realtime-0.5B"
    device = "auto"          # auto, cuda, mps, cpu
    default_voice = "emma"   # carter, davis, emma, frank, grace, mike
    cfg_scale = 1.5          # Classifier-free guidance scale
    unload_timeout_minutes = 60  # Auto-unload model after inactivity (0 = never)

    [diarization]
    device = "auto"          # auto, cuda, cpu
    similarity_threshold = 0.5  # Profile matching threshold (0-1)
    min_segment_duration = 0.5  # Minimum segment length for embedding (seconds)

    [webrtc]
    audio_codec = "opus"     # Audio codec (opus is standard)
    sample_rate = 48000      # WebRTC audio sample rate

    [server]
    host = "0.0.0.0"         # Accept remote connections (used by --http flag)
    port = 8765
  '';
}
