{ config, pkgs, ... }:

{
  imports = [
    ./modules/base.nix    # Core home config
    ./modules/common.nix  # Shell tools, terminal, git, etc.
  ];

  # Catppuccin flavor and accent (inherited from common.nix but explicit here)
  catppuccin = {
    flavor = "macchiato";
    accent = "lavender";
  };
}
