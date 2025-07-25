{ config, pkgs, ... }:

{
  # Set orientation and location for each monitor.
  # See https://discourse.nixos.org/t/proper-way-to-configure-monitors/12341
  services.xserver.displayManager.setupCommands = ''
    LEFT='DP-1'
    CENTER='DP-3'
    RIGHT='DP-2'
    ${pkgs.xorg.xrandr}/bin/xrandr --output $CENTER --output $LEFT --left-of $CENTER --output $RIGHT --right-of $CENTER
  '';
}