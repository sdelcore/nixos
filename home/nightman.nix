{ config, pkgs, ... }:

{
  imports = [
    ./modules/base.nix
    ./modules/common.nix
    ./modules/extended.nix
    ./modules/hyprland/desktop.nix
    ./modules/1password.nix
    ./modules/desktop-agents.nix # sagent + wagent (shared with dayman)
    ./modules/recall.nix
  ];

  systemd.user.services = {
    orca-xvfb = {
      Unit.Description = "Virtual display for headless Orca";
      Service = {
        ExecStart = "${pkgs.xorg.xorgserver}/bin/Xvfb :97 -screen 0 1280x800x24 -nolisten tcp";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "default.target" ];
    };

    orca-serve = {
      Unit = {
        Description = "Headless Orca runtime server";
        Requires = [ "orca-xvfb.service" ];
        Wants = [ "network-online.target" ];
        After = [ "network-online.target" "orca-xvfb.service" ];
      };
      Service = {
        Environment = [
          "DISPLAY=:97"
          "LIBGL_ALWAYS_SOFTWARE=1"
        ];
        ExecStart = "${pkgs.coreutils}/bin/env -u WAYLAND_DISPLAY -u XDG_SESSION_TYPE ${config.home.homeDirectory}/.local/bin/orca serve --port 6768 --pairing-address nightman.tap --json";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
