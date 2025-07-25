{ config, pkgs, system, inputs, ... }:

{
  home.packages = with pkgs; [
    inputs.zen-browser.packages."${pkgs.system}".default
  ];
}