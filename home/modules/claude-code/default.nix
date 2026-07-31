{ inputs, lib, config, pkgs, ... }:

let
  commandsDir = ./commands;

  # `hunk` (terminal diff viewer for reviewing agent-written changesets) is
  # only in nixpkgs unstable, not in the stable channel this host tracks.
  # Home Manager's `pkgs` does not carry the `unstable` overlay — that overlay
  # is applied at `nixpkgs.overlays` in mkSystem and `useGlobalPkgs` is never
  # set — so `pkgs.unstable.hunk` is not available here. Import the unstable
  # input directly, the same way nix/modules/software/localllm/ does.
  unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };

  readDirSafe = path:
    if builtins.pathExists path then builtins.readDir path else { };

  # Skills are managed by the shared agent-skills module so they're picked up
  # by Claude, opencode, and OMP from a single source.

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
  # Using a merge rather than a symlink preserves user and host settings.
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
  home.packages = (with pkgs; [
    yq
    jq
    ripgrep
    curl
  ]) ++ [
    unstable.hunk
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
  } // commandEntries;

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
