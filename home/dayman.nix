{ config, pkgs, ... }:

{
    imports = [
        ./modules/base.nix
        ./modules/common.nix
        ./modules/extended.nix
        ./modules/hyprland/laptop.nix
        ./modules/1password.nix
        ./modules/desktop-agents.nix  # sagent + wagent (shared with nightman)
    ];
}
