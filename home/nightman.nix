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

    # wagent on loopback by default — safe to leave on. Flip `bind` to
    # the tailscale interface and set `authTokenPath` to expose this
    # host's wagent to peers (e.g. so ARIA on ariaos can drive it via
    # `wagent-on nightman`).
    services.wagent = {
        enable = true;
    };
}
