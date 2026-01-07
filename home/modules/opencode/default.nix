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

  home.sessionVariables = {
    OPENCODE_ENABLE_EXA = "true";
  };

  # Load EXA_API_KEY from opnix secret for interactive sessions
  home.sessionVariablesExtra = ''
    if [ -r /var/lib/opnix/secrets/exaApiKey ]; then
      export EXA_API_KEY=$(cat /var/lib/opnix/secrets/exaApiKey)
    fi
  '';

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

  # OpenCode server with mDNS enabled for Android discovery
  # Starts automatically on boot, can be controlled with:
  #   systemctl --user start/stop/restart opencode-server
  systemd.user.services.opencode-server = {
    Unit = {
      Description = "OpenCode Server with mDNS";
      After = [ "network.target" ];
    };

    Service = {
      Type = "simple";
      # Load EXA_API_KEY from opnix secret and start server
      ExecStart = "${pkgs.bash}/bin/bash -c 'if [ -r /var/lib/opnix/secrets/exaApiKey ]; then export EXA_API_KEY=$(cat /var/lib/opnix/secrets/exaApiKey); fi; exec %h/.opencode/bin/opencode serve'";
      Restart = "on-failure";
      RestartSec = 5;
      # Set working directory for session context
      WorkingDirectory = "%h";
      Environment = [ "OPENCODE_ENABLE_EXA=true" ];
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
