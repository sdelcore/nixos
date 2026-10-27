{ inputs, lib, config, pkgs, ... }:
let
  mcpServers = lib.mapAttrs (_: server:
    if server ? command then {
      type = "local";
      command = [ server.command ] ++ (server.args or [ ]);
      disabled = false;
    } // lib.optionalAttrs ((server.env or { }) != { }) {
      environment = server.env;
    } else {
      type = "remote";
      inherit (server) url;
      disabled = false;
    } // lib.optionalAttrs ((server.headers or { }) != { }) {
      inherit (server) headers;
    }
  ) config.programs.mcp.servers;

  opencodeConfig = lib.recursiveUpdate
    (builtins.fromJSON (builtins.readFile ./opencode.jsonc))
    { mcp = { servers = mcpServers; }; };
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

  # Share the global agent instructions across Claude Code and OpenCode.
  # OpenCode reads ~/.config/opencode/AGENTS.md as global instructions.
  home.file.".config/opencode/AGENTS.md".source = ../claude-code/AGENTS.md;

  # OpenCode 2 uses the same `opencode` path as V1; upgrade an existing V1 install.
  home.activation.installopencode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${pkgs.curl}/bin:${pkgs.gnutar}/bin:${pkgs.gzip}/bin:$PATH"
    if [ ! -x "$HOME/.opencode/bin/opencode" ]; then
      echo "Installing OpenCode 2..."
      if ! ${pkgs.curl}/bin/curl -fsSL https://opencode.ai/v2/install \
           | ${pkgs.bash}/bin/bash -s -- --no-modify-path; then
        echo "WARNING: OpenCode 2 install failed; rerun the switch when the network is back" >&2
      fi
    else
      echo "OpenCode is installed at $HOME/.opencode/bin/opencode"
    fi
  '';
}
