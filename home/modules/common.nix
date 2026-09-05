{ lib, pkgs, ... }: {
  imports = [
    ./cli.nix # shared CLI toolset + catppuccin theme
    # Desktop / GUI-adjacent additions on top of the shared CLI set:
    ./alacritty.nix
    ./ssh.nix
    ./bottom.nix
    ./agent-skills/default.nix
    ./mcp.nix
    ./opencode/default.nix
    ./codex.nix
    ./omp.nix
    ./orca.nix
    ./scripts.nix
    ./rofi.nix
    ./zen-browser.nix
  ];

  # Remove files left by the former imperative Herdr installer.
  home.activation.removeHerdr = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    marker="$HOME/.local/state/nixos/herdr-removed"
    if [ ! -e "$marker" ]; then
      ${pkgs.coreutils}/bin/rm -f "$HOME/.local/bin/herdr"
      ${pkgs.coreutils}/bin/rm -rf "$HOME/.config/herdr"
      ${pkgs.coreutils}/bin/mkdir -p "$(dirname "$marker")"
      ${pkgs.coreutils}/bin/touch "$marker"
    fi
  '';
}
