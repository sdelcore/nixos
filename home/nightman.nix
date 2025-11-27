{ config, pkgs, ... }:

{
    imports = [
        ./modules/base.nix
        ./modules/common.nix
        ./modules/hyprland/desktop.nix
        ./modules/1password.nix
    ];
}
