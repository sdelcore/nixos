{ inputs, lib, config, pkgs, ... }:
{
  home.packages = with pkgs; [
    yq
    ripgrep
    gnutar
    gzip
  ];

  home.sessionPath = [
    "$HOME/.opencode/bin"
  ];

  home.file.".config/opencode/opencode.jsonc".source = ./opencode.jsonc;

  # Install OpenCode via native installer
  home.activation.installopencode = lib.hm.dag.entryAfter ["writeBoundary"] ''
    export PATH="${pkgs.curl}/bin:${pkgs.wget}/bin:${pkgs.gnutar}/bin:${pkgs.gzip}/bin:$PATH"
    if [ ! -f "$HOME/.opencode/bin/opencode" ]; then
      echo "Installing OpenCode..."
      ${pkgs.curl}/bin/curl -fsSL https://opencode.ai/install | ${pkgs.bash}/bin/bash
    else
      echo "OpenCode is already installed at $HOME/.opencode/bin/opencode"
    fi
  '';
}
