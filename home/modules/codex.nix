{ lib, pkgs, ... }:
{
  # Codex reads ~/.codex/AGENTS.md as global instructions on every session;
  # source the same file Claude Code, opencode, and pi share.
  home.file.".codex/AGENTS.md".source = ./claude-code/CLAUDE.md;

  # Install Codex CLI via the native installer; it self-updates with
  # `codex update`. ~/.local/bin is prepended to PATH so the installer's
  # add_to_path check short-circuits — otherwise it appends a PATH block
  # to ~/.zshrc, which is a read-only home-manager symlink.
  # The installer also shells out to awk/fold/grep/sed, which aren't in
  # home-manager's minimal activation PATH.
  home.activation.installCodex = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="$HOME/.local/bin:${lib.makeBinPath (with pkgs; [ curl gnutar gzip coreutils gawk gnugrep gnused findutils ])}:$PATH"
    if [ ! -f "$HOME/.local/bin/codex" ]; then
      echo "Installing Codex CLI..."
      ${pkgs.curl}/bin/curl -fsSL https://chatgpt.com/codex/install.sh | ${pkgs.bash}/bin/bash
    else
      echo "Codex CLI is already installed at $HOME/.local/bin/codex"
    fi
  '';
}
