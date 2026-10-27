{ config, pkgs, ... }:

{
  imports = [
    ./modules/base.nix
    ./modules/desktop-policy.nix
    ./modules/common.nix
    ./modules/extended.nix
    ./modules/hyprland/laptop.nix
    ./modules/voiced-client.nix
    ./modules/1password.nix
    ./modules/desktop-agents.nix # sagent + wagent (shared with nightman)
    ./modules/hermes-desktop.nix
    ./modules/recall.nix
  ];
}
