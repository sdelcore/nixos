{ inputs, pkgs, ... }:

let
  aiUsagebar = inputs.ai-usagebar.packages.${pkgs.stdenv.hostPlatform.system}.default;
  waybar_config = ./../configs/waybar;
in
{
  # Install waybar via home-manager module
  programs.waybar.enable = true;
  home.packages = [ aiUsagebar ];

  # Source waybar config from the home-manager store
  xdg.configFile = {
    "waybar" = {
      recursive = true;
      source = "${waybar_config}";
    };
  };
}
