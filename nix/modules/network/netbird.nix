# NetBird mesh client — personal peer on the self-hosted netbird.sdelcore.com.
#
# Enrolls this machine into the `personal` group (full reach to the homelab via
# the routing peer + DNS for sdelcore.com over the tunnel). The setup key comes
# from 1Password via opnix.
{ config, lib, pkgs, inputs, ... }:
with lib;
let
  cfg = config.services.netbirdClient;
in
{
  # The netbird NixOS module is version-coupled to the netbird-ui desktop-file
  # layout: the stable 25.11 module wraps the tray by replacing an absolute
  # `…/bin/netbird-ui` path that unstable's netbird-ui no longer ships, so it
  # can't build against the unstable package. Pull the whole module from
  # unstable so the module, daemon, and tray (set below) are all matched.
  disabledModules = [ "services/networking/netbird.nix" ];
  imports = [ "${inputs.nixpkgs-unstable}/nixos/modules/services/networking/netbird.nix" ];

  options.services.netbirdClient = {
    enable = mkEnableOption "NetBird mesh client (personal peer)";
    managementUrl = mkOption {
      type = types.str;
      default = "https://netbird.sdelcore.com:443";
      description = "Self-hosted NetBird management URL.";
    };
  };

  config = mkIf cfg.enable {
    # Personal setup key (auto-joins the `personal` group on enrollment).
    services.onepassword-secrets.secrets."netbirdSetupKey" = {
      reference = "op://Infrastructure/netbird-setup-keys/personal";
      mode = "0400";
    };

    # nixos-25.11 stable ships netbird 0.60.2; run the daemon and the desktop
    # tray (netbird-ui) from unstable to track the server. `ui.enable` defaults
    # to graphical-session presence, so the tray app lands on dayman/nightman.
    services.netbird.package = pkgs.unstable.netbird;
    services.netbird.ui.package = pkgs.unstable.netbird-ui;

    services.netbird.clients.nb0 = {
      port               = 51820;
      autoStart          = true;
      openFirewall       = true;
      login.enable       = true;
      login.setupKeyFile = "/var/lib/opnix/secrets/netbirdSetupKey";
      login.systemdDependencies = [ "opnix-secrets.service" ];
    };

    # `netbird up` reads NB_MANAGEMENT_URL to register against the self-hosted
    # server (don't pre-seed config.json — ManagementURL is a parsed url.URL
    # there, and a string crashes the daemon).
    systemd.services."netbird-nb0-login".environment.NB_MANAGEMENT_URL = cfg.managementUrl;
  };
}
