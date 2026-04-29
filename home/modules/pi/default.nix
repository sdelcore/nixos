{ inputs, lib, config, pkgs, ... }:

let
  extensionsDir = ./extensions;

  readDirSafe = path:
    if builtins.pathExists path then builtins.readDir path else { };

  # Pi auto-discovers two extension shapes from ~/.pi/agent/extensions/:
  #   <name>.ts                  (single-file extension)
  #   <name>/index.ts            (directory extension)
  # We mirror that here. Single-file home.file entries only manage the
  # specific symlink, so locally-added files in ~/.pi/agent/extensions/
  # are left untouched across activations.
  isExtensionEntry = name: type:
    (type == "regular" && lib.hasSuffix ".ts" name) || (type == "directory");

  extensions = lib.filterAttrs isExtensionEntry (readDirSafe extensionsDir);

  mkExtensionFile = name: type:
    let src = extensionsDir + "/${name}";
    in if type == "directory"
       then { source = src; recursive = true; }
       else { source = src; };

  extensionEntries = lib.mapAttrs'
    (name: type: lib.nameValuePair ".pi/agent/extensions/${name}"
      (mkExtensionFile name type))
    extensions;

  # Base pi settings, deep-merged into ~/.pi/agent/settings.json on every
  # activation. Preserves user-set keys (defaultProvider, defaultModel, etc.)
  # while keeping nix as the source of truth for auto-installed pi packages.
  piSettingsAttrs = {
    packages = [ "npm:pi-mcp-adapter" ];
  };
  piSettingsJson = builtins.toJSON piSettingsAttrs;
  piSettingsFile = "${config.home.homeDirectory}/.pi/agent/settings.json";
in
{
  home.packages = with pkgs; [
    nodejs_22
  ];

  home.sessionPath = [
    "$HOME/.npm-global/bin"
  ];

  # Load OPENCODE_API_KEY from opnix secret so pi can use OpenCode Zen.
  # Pi has built-in support for the `opencode` provider and reads this env var.
  home.sessionVariablesExtra = ''
    if [ -r /var/lib/opnix/secrets/opencodeApiKey ]; then
      export OPENCODE_API_KEY=$(cat /var/lib/opnix/secrets/opencodeApiKey)
    fi
  '';

  home.file = extensionEntries // {
    # Share the global agent instructions with Claude and opencode by
    # sourcing the same CLAUDE.md file. Pi loads ~/.pi/agent/AGENTS.md
    # globally and concatenates it into the system prompt.
    ".pi/agent/AGENTS.md".source = ../claude-code/CLAUDE.md;
  };

  # Deep-merge base pi settings into ~/.pi/agent/settings.json on every
  # activation. Preserves user-added keys; nix owns the `packages` array
  # so pi auto-installs pi-mcp-adapter (and any future declared packages).
  home.activation.piSettings =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$(dirname "${piSettingsFile}")"
      if [ -f "${piSettingsFile}" ]; then
        ${pkgs.jq}/bin/jq --argjson new '${piSettingsJson}' '. * $new' \
          "${piSettingsFile}" > "${piSettingsFile}.tmp" \
          && mv "${piSettingsFile}.tmp" "${piSettingsFile}"
      else
        echo '${piSettingsJson}' | ${pkgs.jq}/bin/jq . > "${piSettingsFile}"
      fi
    '';

  # Install pi coding agent globally under ~/.npm-global so npm doesn't try to
  # write into the nix store. Skips if already installed.
  home.activation.installPi = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${pkgs.nodejs_22}/bin:$PATH"
    export npm_config_prefix="$HOME/.npm-global"
    mkdir -p "$HOME/.npm-global"
    if [ ! -x "$HOME/.npm-global/bin/pi" ]; then
      echo "Installing pi coding agent..."
      ${pkgs.nodejs_22}/bin/npm install -g @mariozechner/pi-coding-agent
    else
      echo "pi is already installed at $HOME/.npm-global/bin/pi"
    fi
  '';
}
