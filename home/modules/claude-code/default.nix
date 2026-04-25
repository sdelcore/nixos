{ inputs, lib, config, pkgs, ... }:

let
  skillsDir = ./skills;
  commandsDir = ./commands;

  readDirSafe = path:
    if builtins.pathExists path then builtins.readDir path else { };

  # Auto-discover skills: each subdirectory of ./skills must contain SKILL.md
  skillDirs = lib.filterAttrs (_: type: type == "directory")
    (readDirSafe skillsDir);

  skillEntries = lib.mapAttrs'
    (name: _: lib.nameValuePair ".claude/skills/${name}/SKILL.md" {
      source = skillsDir + "/${name}/SKILL.md";
    })
    skillDirs;

  # Auto-discover commands: every *.md file in ./commands
  commandFileNames = lib.filterAttrs
    (name: type: type == "regular" && lib.hasSuffix ".md" name)
    (readDirSafe commandsDir);

  commandEntries = lib.mapAttrs'
    (name: _: lib.nameValuePair ".claude/commands/${name}" {
      source = commandsDir + "/${name}";
    })
    commandFileNames;

  # Base Claude Code settings, merged into ~/.claude/settings.json via jq.
  # Using a merge rather than a symlink lets downstream hosts layer additional
  # keys (e.g. mcpServers on workbox) through their own activation scripts.
  settingsAttrs = {
    attribution = {
      commit = "";
      pr = "";
    };
  };
  settingsJson = builtins.toJSON settingsAttrs;
  settingsFile = "${config.home.homeDirectory}/.claude/settings.json";
in
{
  home.packages = with pkgs; [
    yq
    jq
    ripgrep
    curl
  ];

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  home.file = {
    # Keep directories
    ".claude/.keep".text = "";
    ".claude/projects/.keep".text = "";
    ".claude/todos/.keep".text = "";
    ".claude/statsig/.keep".text = "";

    # Global user CLAUDE.md
    ".claude/CLAUDE.md".source = ./CLAUDE.md;

    # Obsidian vault plugin
    ".claude/plugins/obsidian" = {
      source = ./plugins/obsidian;
      recursive = true;
    };
  } // skillEntries // commandEntries;

  # Deep-merge base settings into ~/.claude/settings.json on every activation.
  # Preserves user-added keys (effortLevel, enabledPlugins, etc.) and any
  # keys set by downstream activation scripts.
  home.activation.claudeSettings =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$(dirname "${settingsFile}")"
      if [ -f "${settingsFile}" ]; then
        ${pkgs.jq}/bin/jq --argjson new '${settingsJson}' '. * $new' \
          "${settingsFile}" > "${settingsFile}.tmp" \
          && mv "${settingsFile}.tmp" "${settingsFile}"
      else
        echo '${settingsJson}' | ${pkgs.jq}/bin/jq . > "${settingsFile}"
      fi
    '';

  # Install Claude Code via native installer
  home.activation.installClaudeCode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${pkgs.curl}/bin:${pkgs.wget}/bin:$PATH"
    if [ ! -f "$HOME/.local/bin/claude" ]; then
      echo "Installing Claude Code..."
      ${pkgs.curl}/bin/curl -fsSL https://claude.ai/install.sh | ${pkgs.bash}/bin/bash -s -- stable
    else
      echo "Claude Code is already installed at $HOME/.local/bin/claude"
    fi
  '';
}
