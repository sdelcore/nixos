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

    # wagent on loopback by default. Flip `bind` to the tailscale
    # interface and set `authTokenPath` to allow ARIA on ariaos to
    # drive this host's wagent via `wagent-on dayman`.
    services.wagent = {
        enable = true;
    };
}
