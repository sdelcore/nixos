# NetBird mesh client — personal peer on the self-hosted netbird.sdelcore.com.
#
# Enrolls this machine into the `personal` group (full reach to the homelab via
# the routing peer + DNS for sdelcore.com over the tunnel). The setup key comes
# from 1Password via opnix.
{ config, lib, ... }:
with lib;
let
  cfg = config.services.netbirdClient;
in
{
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
