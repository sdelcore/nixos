{ lib, config, pkgs, ... }:

let
  cfg = config.programs.mcp;

  # Keep one server definition and render each client's native schema from it.
  mcpConfigAttrs = { mcpServers = cfg.servers; };
  mcpConfigJson = builtins.toJSON mcpConfigAttrs;
  mcpConfigFile = "${config.home.homeDirectory}/.config/mcp/mcp.json";
  claudeConfigFile = "${config.home.homeDirectory}/.claude.json";
in
{
  config = {
    home.activation.mcpConfig =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "$(dirname "${mcpConfigFile}")"
        if [ -f "${mcpConfigFile}" ]; then
          ${pkgs.jq}/bin/jq --argjson new '${mcpConfigJson}' '. * $new' \
            "${mcpConfigFile}" > "${mcpConfigFile}.tmp" \
            && mv "${mcpConfigFile}.tmp" "${mcpConfigFile}"
        else
          echo '${mcpConfigJson}' | ${pkgs.jq}/bin/jq . > "${mcpConfigFile}"
        fi
      '';

    # Claude Code stores user-scoped MCP servers in ~/.claude.json.
    home.activation.claudeMcpConfig =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ -f "${claudeConfigFile}" ]; then
          ${pkgs.jq}/bin/jq --argjson new '${mcpConfigJson}' \
            '.mcpServers = ((.mcpServers // {}) * $new.mcpServers)' \
            "${claudeConfigFile}" > "${claudeConfigFile}.tmp" \
            && mv "${claudeConfigFile}.tmp" "${claudeConfigFile}"
        else
          echo '${mcpConfigJson}' | ${pkgs.jq}/bin/jq . > "${claudeConfigFile}"
        fi
      '';
  };
}
