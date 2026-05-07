{ config, pkgs, ... }:

{
    imports = [
        ./modules/base.nix
        ./modules/common.nix
        ./modules/extended.nix
        ./modules/hyprland/desktop.nix
        ./modules/1password.nix
        ./modules/sagent.nix
        ./modules/wagent.nix
    ];

    services.sagent = {
        enable = true;
        # 7 LLM calls/hour ≈ 3-4 sessions/hour (each session = per-session
        # digest + project rollup = 2 calls).
        maxPerHour = 7;
    };

    # wagent bound on the LAN with no auth so the phone can reach it
    # via mDNS (`http://nightman.local:2468`). Trust assumption: the
    # home network. To re-tighten, drop `bind` back to the default
    # loopback or flip to the tailscale interface and set
    # `authTokenPath` (which lets `requireAuth` stay at its default).
    services.wagent = {
        enable = true;
        bind = "0.0.0.0";
        requireAuth = false;
    };
}
