{ lib, config, pkgs, ... }:

let
  cfg = config.programs.mcp;

  # Keep one server definition and render each client's native schema from it.
  mcpConfigAttrs = { mcpServers = cfg.servers; };
  mcpConfigJson = builtins.toJSON mcpConfigAttrs;
  mcpConfigFile = "${config.home.homeDirectory}/.config/mcp/mcp.json";
  claudeConfigFile = "${config.home.homeDirectory}/.claude.json";
  kaneoMcp = pkgs.writeShellScript "kaneo-mcp" ''
    set -eu
    export KANEO_API_URL="https://tasks.sdelcore.com"
    export KANEO_API_KEY="$(${pkgs.coreutils}/bin/cat /var/lib/opnix/secrets/kaneoApiKey)"
    exec ${pkgs.nodejs_24}/bin/npx --yes @kaneo/mcp@0.1.12 serve
  '';
  codexPython = pkgs.python3.withPackages (ps: [ ps.tomlkit ]);
in
{
  config = {
    programs.mcp.servers.kaneo.command = "${kaneoMcp}";

    home.activation.ompMcpConfig =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        out="${config.home.homeDirectory}/.omp/agent/mcp.json"
        mkdir -p "$(dirname "$out")"
        if [ -f "$out" ]; then
          ${pkgs.jq}/bin/jq --argjson new '${mcpConfigJson}' '. * $new' \
            "$out" > "$out.tmp" && mv "$out.tmp" "$out"
        else
          echo '${mcpConfigJson}' | ${pkgs.jq}/bin/jq . > "$out"
        fi
      '';

    home.activation.codexMcpConfig =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${codexPython}/bin/python3 - <<'PY'
        import json
        from pathlib import Path
        import tomlkit

        path = Path("${config.home.homeDirectory}/.codex/config.toml")
        path.parent.mkdir(parents=True, exist_ok=True)
        document = tomlkit.parse(path.read_text()) if path.exists() else tomlkit.document()
        servers = document.setdefault("mcp_servers", tomlkit.table())
        for name, server in json.loads('${mcpConfigJson}')["mcpServers"].items():
            servers[name] = server
        path.write_text(tomlkit.dumps(document))
        PY
      '';
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
