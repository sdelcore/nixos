{ inputs, osConfig, config, pkgs, ... }:

{
  # Shared sagent + wagent setup for the interactive desktops (dayman, nightman).
  # Both run the same quota and the same LAN-exposed wagent; factored here so the
  # two host files don't drift.
  #
  # Both modules ship with their own flakes, so the launchers, the units and the
  # option schemas live next to the code they run. Only policy stays here.
  imports = [
    inputs.sagent.homeModules.default
    inputs.wagent.homeModules.default
  ];

  services.sagent = {
    enable = true;
    # Shared subscription quota across the desktops. 7 LLM calls/hour ≈ 3-4
    # sessions/hour (each session = per-session digest + project rollup = 2 calls).
    maxPerHour = 7;

    # sagent defaults to ~/.sagent/<hostname>, which syncs nowhere. Sending the
    # digests into the vault instead is what makes them reachable from the
    # phone and indexable by recall, so it is a decision this repo makes, not
    # one sagent should make for everyone. The per-host leaf is load-bearing:
    # INDEX.md aggregates every project under its root, so two machines sharing
    # a root would merge their fleets into one index.
    outDir = "${config.home.homeDirectory}/Obsidian/sagent/${osConfig.networking.hostName}";
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
