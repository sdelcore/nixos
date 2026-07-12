{...}: {
  imports = [
    ./cli.nix # shared CLI toolset + catppuccin theme
    # Desktop / GUI-adjacent additions on top of the shared CLI set:
    ./alacritty.nix
    ./ssh.nix
    ./bottom.nix
    ./agent-skills/default.nix
    ./mcp.nix
    ./opencode/default.nix
    ./pi/default.nix
    ./codex.nix
    ./omp.nix
    ./scripts.nix
    ./rofi.nix
    ./zen-browser.nix
  ];
}
