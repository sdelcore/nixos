{ lib, config, pkgs, ... }:

let
  # Shared MCP config consumed by any MCP-aware harness (pi-mcp-adapter,
  # claude-code, opencode). Lives at ~/.config/mcp/mcp.json so a single
  # set of servers is reused across agents instead of being duplicated
  # per-tool. Empty by default — downstream hosts (e.g. workbox) layer
  # host-specific mcpServers via their own activation scripts, the same
  # way claude-code settings are layered.
  mcpConfigAttrs = {
    mcpServers = { };
  };
  mcpConfigJson = builtins.toJSON mcpConfigAttrs;
  mcpConfigFile = "${config.home.homeDirectory}/.config/mcp/mcp.json";
in
{
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
}
