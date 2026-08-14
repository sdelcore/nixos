{ inputs, lib, config, pkgs, ... }:
let
  serverPort = 4096;

  mcpServers = lib.mapAttrs (_: server:
    if server ? command then {
      type = "local";
      command = [ server.command ] ++ (server.args or [ ]);
      enabled = true;
    } // lib.optionalAttrs ((server.env or { }) != { }) {
      environment = server.env;
    } else {
      type = "remote";
      inherit (server) url;
      enabled = true;
    } // lib.optionalAttrs ((server.headers or { }) != { }) {
      inherit (server) headers;
    }
  ) config.programs.mcp.servers;

  opencodeConfig = lib.recursiveUpdate
    (builtins.fromJSON (builtins.readFile ./opencode.jsonc))
    { mcp = mcpServers; };
in
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
    LITELLM_BASE_URL = "http://llm.ai.tap";
  };

  # Load EXA_API_KEY from opnix secret for interactive sessions
  home.sessionVariablesExtra = ''
    if [ -r /var/lib/opnix/secrets/exaApiKey ]; then
      export EXA_API_KEY=$(${pkgs.coreutils}/bin/cat /var/lib/opnix/secrets/exaApiKey)
    fi
    if [ -r /var/lib/opnix/secrets/litellmApiKey ]; then
      export LITELLM_API_KEY=$(${pkgs.coreutils}/bin/cat /var/lib/opnix/secrets/litellmApiKey)
    fi
  '';

  home.file.".config/opencode/opencode.jsonc".text = builtins.toJSON opencodeConfig;

  # Share the global agent instructions with Claude Code by sourcing the
  # same CLAUDE.md file. opencode reads ~/.config/opencode/AGENTS.md as
  # global instructions on every session.
  home.file.".config/opencode/AGENTS.md".source = ../claude-code/CLAUDE.md;

  # Install OpenCode 2 via native installer. The v2 beta ships as a separate
  # `opencode2` binary; the v1 `opencode` binary is removed on first activation
  # because the `opencode` shell alias now points at opencode2.
  home.activation.installopencode = lib.hm.dag.entryAfter ["writeBoundary"] ''
    export PATH="${pkgs.curl}/bin:${pkgs.wget}/bin:${pkgs.gnutar}/bin:${pkgs.gzip}/bin:$PATH"
    if [ ! -f "$HOME/.opencode/bin/opencode2" ]; then
      echo "Installing OpenCode 2..."
      if ! ${pkgs.curl}/bin/curl -fsSL https://raw.githubusercontent.com/anomalyco/opencode/v2/install \
           | ${pkgs.bash}/bin/bash -s -- --no-modify-path; then
        echo "WARNING: OpenCode 2 install failed; rerun the switch when the network is back" >&2
      fi
    else
      echo "OpenCode 2 is already installed at $HOME/.opencode/bin/opencode2"
    fi

    if [ -f "$HOME/.opencode/bin/opencode" ]; then
      echo "Removing the OpenCode 1 binary"
      rm -f "$HOME/.opencode/bin/opencode"
    fi

    # ~/.config/opencode/service.json also holds a generated pairing password,
    # so it is written by opencode itself rather than by home-manager.
    if [ -x "$HOME/.opencode/bin/opencode2" ]; then
      $DRY_RUN_CMD "$HOME/.opencode/bin/opencode2" service set hostname 0.0.0.0 >/dev/null
      $DRY_RUN_CMD "$HOME/.opencode/bin/opencode2" service set port ${toString serverPort} >/dev/null
    fi
  '';

  # OpenCode 2 managed server, reachable on the LAN at :${toString serverPort}
  # behind the pairing password from `opencode2 pair`.
  # Starts automatically on boot, can be controlled with:
  #   systemctl --user start/stop/restart opencode-server
  systemd.user.services.opencode-server = {
    Unit = {
      Description = "OpenCode 2 Server";
      After = [ "network.target" ];
    };

    Service = {
      Type = "simple";
      # Load EXA_API_KEY from opnix secret and start server
      ExecStart = "${pkgs.bash}/bin/bash -c 'if [ -r /var/lib/opnix/secrets/exaApiKey ]; then export EXA_API_KEY=$(${pkgs.coreutils}/bin/cat /var/lib/opnix/secrets/exaApiKey); fi; if [ -r /var/lib/opnix/secrets/litellmApiKey ]; then export LITELLM_API_KEY=$(${pkgs.coreutils}/bin/cat /var/lib/opnix/secrets/litellmApiKey); fi; exec %h/.opencode/bin/opencode2 serve --service'";
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
