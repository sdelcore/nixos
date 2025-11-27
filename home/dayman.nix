{ config, pkgs, ... }:

{
    imports = [
        ./modules/base.nix
        ./modules/common.nix
        ./modules/hyprland/laptop.nix
        ./modules/1password.nix
    ];
}
