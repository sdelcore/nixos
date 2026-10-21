{ config, lib, ... }:

{
  imports = [ ./voiced.nix ];

  # Keep the shared service identity so the compositor's restart reaches the tray client.
  systemd.user.services.voiced.Service.ExecStart = lib.mkForce
    "${config.services.voiced.package}/bin/voiced client --server http://nightman.tap:8765";
}
