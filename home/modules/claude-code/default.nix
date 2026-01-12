{ inputs, lib, config, pkgs, ... }:
{
  home.packages = with pkgs; [
    yq
    ripgrep
    curl
  ];

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  # Create necessary directories
  home.file.".claude/.keep".text = "";
  home.file.".claude/projects/.keep".text = "";
  home.file.".claude/todos/.keep".text = "";
  home.file.".claude/statsig/.keep".text = "";
  home.file.".claude/commands/.keep".text = "";

  # Install Claude Code via native installer
  home.activation.installClaudeCode = lib.hm.dag.entryAfter ["writeBoundary"] ''
    export PATH="${pkgs.curl}/bin:${pkgs.wget}/bin:$PATH"
    if [ ! -f "$HOME/.local/bin/claude" ]; then
      echo "Installing Claude Code..."
      ${pkgs.curl}/bin/curl -fsSL https://claude.ai/install.sh | ${pkgs.bash}/bin/bash -s -- stable
    else
      echo "Claude Code is already installed at $HOME/.local/bin/claude"
    fi
  '';
}
