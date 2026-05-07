{ config, pkgs, ... }:

{
    imports = [
        ./modules/base.nix
        ./modules/common.nix
        ./modules/extended.nix
        ./modules/hyprland/laptop.nix
        ./modules/1password.nix
        ./modules/sagent.nix
        ./modules/wagent.nix
    ];

    services.sagent = {
        enable = true;
        # Shared subscription quota with nightman.
        # 7/hr each ≈ 3-4 sessions/hour ≈ 70 LLM calls/5h combined.
        maxPerHour = 7;
    };

    # wagent bound on the LAN with no auth so the phone can reach it
    # via mDNS (`http://dayman.local:2468`). Trust assumption: the
    # home network. To re-tighten, drop `bind` back to the default
    # loopback or flip to the tailscale interface and set
    # `authTokenPath` (which lets `requireAuth` stay at its default).
    services.wagent = {
        enable = true;
        bind = "0.0.0.0";
        requireAuth = false;
    };
}
