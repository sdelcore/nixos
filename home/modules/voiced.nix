{ inputs, ... }:

{
  imports = [ inputs.voiced.homeModules.default ];

  services.voiced = {
    enable = true;
    startAtLogin = true;
    settings = {
      unload_timeout_minutes = 60;
      server.host = "0.0.0.0";
      transcription.replacements = {
        "cloud code" = "Claude Code";
        "hyperland" = "Hyprland";
      };
    };
  };
}
