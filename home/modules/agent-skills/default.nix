{ inputs, lib, config, pkgs, ... }:

let
  skillsDir = ./skills;

  readDirSafe = path:
    if builtins.pathExists path then builtins.readDir path else { };

  # Each subdirectory of ./skills is one skill containing a SKILL.md per the
  # Agent Skills standard (https://agentskills.io/specification).
  skillDirs = lib.filterAttrs (_: type: type == "directory") (readDirSafe skillsDir);

  # Symlink each SKILL.md into both default discovery roots:
  #   ~/.claude/skills/<name>/SKILL.md  — read by Claude Code
  #   ~/.agents/skills/<name>/SKILL.md  — read natively by opencode and pi
  # Single-file home.file entries leave each skill's parent directory writable,
  # so users can drop additional skill dirs locally without conflict.
  mkSkillEntry = base: name: lib.nameValuePair "${base}/${name}/SKILL.md" {
    source = skillsDir + "/${name}/SKILL.md";
  };

  claudeEntries = lib.mapAttrs' (name: _: mkSkillEntry ".claude/skills" name) skillDirs;
  agentsEntries = lib.mapAttrs' (name: _: mkSkillEntry ".agents/skills" name) skillDirs;
in
{
  home.file = claudeEntries // agentsEntries;
}
