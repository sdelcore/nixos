{ inputs, pkgs, ... }:

{
  systemd.user.services.voiced-client = {
    Unit = {
      Description = "Voiced client";
      Wants = [ "network-online.target" ];
      After = [ "network-online.target" ];
    };
    Service = {
      ExecStart = "${
        inputs.voiced.packages.${pkgs.stdenv.hostPlatform.system}.default
      }/bin/voiced client --server http://nightman.tap:8765";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
