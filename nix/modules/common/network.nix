{ config, pkgs, ... }:

{
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  # systemd-resolved as the single resolver, so Tailscale and NetBird each
  # register per-interface split-DNS instead of fighting over /etc/resolv.conf.
  # Net effect: `*.netbird.sdelcore.com` (peer names) resolves via NetBird,
  # `*.ts.net` via Tailscale, and everything else falls through to pihole — so
  # ad-blocking and the sdelcore.com/.tap split-horizon stay the global default.
  # Without this, whichever VPN grabs resolv.conf wins and the other's names
  # break (NetBird peer names were resolving to the proxy via pihole's wildcard).
  services.resolved.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
}