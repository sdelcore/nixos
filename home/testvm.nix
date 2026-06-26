{ config, pkgs, ... }:

{
  imports = [
    ./modules/base.nix    # Core home config
    ./modules/common.nix  # Shell tools, terminal, git, etc. (sets catppuccin via cli.nix)
  ];
}
