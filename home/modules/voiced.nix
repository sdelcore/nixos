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
        # %t = the user runtime dir (/run/user/<uid>); avoids hardcoding uid 1000.
        "XDG_RUNTIME_DIR=%t"
      ];
    };
  };

  # Default configuration
  # Models are fixed in voiced 0.4.0: Parakeet-TDT v3 (STT), Kokoro-82M (TTS).
  xdg.configFile."voiced/config.toml".text = ''
    # Auto-unload idle STT/TTS models from the GPU after this many minutes
    # (0 = never). Shared by both so they always match.
    unload_timeout_minutes = 60

    [transcription]
    device = "auto"          # auto, cuda, cpu
    language = "en"          # advisory only; Parakeet TDT v3 auto-detects

    # Fix words the model habitually mishears (case-insensitive,
    # word-boundary matched)
    [transcription.replacements]
    "cloud code" = "Claude Code"
    "hyperland" = "Hyprland"

    [audio]
    sample_rate = 16000
    channels = 1
    device = "default"       # or specific device name
    beep_enabled = true      # audio feedback on start/stop

    [tts]
    enabled = true              # Enable TTS (Kokoro-82M)
    device = "auto"             # auto, cuda, cpu
    default_voice = "af_heart"  # see `voiced voices list`
    speed = 1.0                 # Speech rate multiplier

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
