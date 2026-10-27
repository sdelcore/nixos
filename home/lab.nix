{ config, pkgs, ... }:

{
  imports = [
    ./headless.nix
    ./modules/hyprland/lab.nix
  ];
}
