{ inputs, ... }:

{
  # voiced's module ships with its flake, so the unit and the option schema
  # live next to the code they run. Only policy stays here.
  imports = [
    inputs.voiced.homeModules.default
  ];

  services.voiced = {
    enable = true;

    # Hyprland owns the lifecycle via `exec-once = systemctl --user start
    # voiced`, so the unit must not also be pulled in at login. Starting it
    # from the compositor keeps the STT and TTS models out of VRAM until
    # there is a session that could use them.
    startAtLogin = false;

    # Everything voiced already defaults to is left unset on purpose; its
    # own defaults live in src/voiced/config.py. Only the values that differ
    # are stated here.
    settings = {
      # 60 rather than the upstream 15: this desktop has VRAM to spare and
      # reloading the models costs more than holding them.
      unload_timeout_minutes = 60;

      # Upstream binds loopback. voiced has no authentication, so this opens
      # transcription and synthesis to the whole LAN — same trust assumption
      # as wagent in desktop-agents.nix, the home network.
      server.host = "0.0.0.0";

      # Words the model habitually mishears, matched case-insensitively on
      # word boundaries.
      transcription.replacements = {
        "cloud code" = "Claude Code";
        "hyperland" = "Hyprland";
      };
    };
  };
}
