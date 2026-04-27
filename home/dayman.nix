{ config, pkgs, ... }:

{
    imports = [
        ./modules/base.nix
        ./modules/common.nix
        ./modules/extended.nix
        ./modules/hyprland/laptop.nix
        ./modules/1password.nix
        ./modules/sagent.nix
    ];

    services.sagent = {
        enable = true;
        # Shared subscription quota with nightman.
        # 7/hr each ≈ 3-4 sessions/hour ≈ 70 LLM calls/5h combined.
        maxPerHour = 7;
    };
}
