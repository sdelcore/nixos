{ inputs, pkgs, ... }:

let
  voiced = inputs.voiced.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  imports = [ ./voiced-client.nix ];
  systemd.user.services.voiced-backend = {
    Unit = {
      Description = "Voiced headless backend";
      Wants = [ "network-online.target" ];
      After = [ "network-online.target" ];
    };
    Service = {
      # Keep the headless service's wrapper venv separate from the desktop client's.
      Environment = [ "XDG_DATA_HOME=%h/.local/share/voiced-backend" ];
      ExecStart = "${voiced}/bin/voiced server --host 0.0.0.0 --port 8765";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
