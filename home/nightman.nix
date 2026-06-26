{ config, pkgs, ... }:

{
    imports = [
        ./modules/base.nix
        ./modules/common.nix
        ./modules/extended.nix
        ./modules/hyprland/desktop.nix
        ./modules/1password.nix
        ./modules/desktop-agents.nix  # sagent + wagent (shared with dayman)
    ];
}
