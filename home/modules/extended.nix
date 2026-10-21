{ pkgs, ... }: {
  imports = [
    ../modules/easyeffects.nix
    ../modules/fastfetch.nix
    ../modules/ghostty.nix
    ../modules/go.nix
    ../modules/lazydocker.nix
    ../modules/lmstudio.nix
  ];
  home.packages = [ pkgs.mattermost-desktop ];
}
