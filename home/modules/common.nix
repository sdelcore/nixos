{ ... }: {
  imports = [
    ./cli.nix # shared CLI toolset + catppuccin theme
    ./ssh.nix
    ./bottom.nix
    ./agent-skills/default.nix
    ./mcp.nix
    ./opencode/default.nix
    ./codex.nix
    ./omp.nix
    ./herdr.nix
    ./orca.nix
    ./claude-code/default.nix
    ./rofi.nix
    ./zen-browser.nix
  ];

}
