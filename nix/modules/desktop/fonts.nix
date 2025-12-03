{ pkgs, ... }: {
  fonts.packages = with pkgs; [
    nerd-fonts.droid-sans-mono
    nerd-fonts.fira-code
    nerd-fonts.dejavu-sans-mono
    nerd-fonts.meslo-lg
    nerd-fonts.jetbrains-mono
    roboto
  ];
}
