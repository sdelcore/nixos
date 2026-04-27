{ config, pkgs, ... }:

{
    imports = [
        ./modules/base.nix
        ./modules/common.nix
        ./modules/extended.nix
        ./modules/hyprland/desktop.nix
        ./modules/1password.nix
        ./modules/sagent.nix
    ];

    services.sagent = {
        enable = true;
        # 7 LLM calls/hour ≈ 3-4 sessions/hour (each session = per-session
        # digest + project rollup = 2 calls).
        maxPerHour = 7;
    };
}
