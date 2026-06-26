{ config, pkgs, ... }:

{
  # Shared sagent + wagent setup for the interactive desktops (dayman, nightman).
  # Both run the same quota and the same LAN-exposed wagent; factored here so the
  # two host files don't drift.
  imports = [
    ./sagent.nix
    ./wagent.nix
  ];

  services.sagent = {
    enable = true;
    # Shared subscription quota across the desktops. 7 LLM calls/hour ≈ 3-4
    # sessions/hour (each session = per-session digest + project rollup = 2 calls).
    maxPerHour = 7;
  };

  # wagent bound on the LAN with no auth so the phone can reach it via mDNS
  # (`http://<host>.local:2468`). Trust assumption: the home network. To
  # re-tighten, drop `bind` back to the default loopback, or flip to the
  # tailscale interface and set `authTokenPath` (which lets `requireAuth` stay
  # at its default).
  services.wagent = {
    enable = true;
    bind = "0.0.0.0";
    requireAuth = false;
  };
}
