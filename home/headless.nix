{
  pkgs,
  username ? "sdelcore",
  ...
}:

{
  imports = [
    ./modules/base.nix
    ./modules/cli.nix # shared CLI toolset + catppuccin theme
    ./modules/lazydocker.nix # headless-only extra (servers run containers)
  ];

  # Ensure XDG directories exist
  xdg.enable = true;
}
