{ inputs, lib, config, pkgs, ... }:

let
  skillsDir = ./skills;

  readDirSafe = path:
    if builtins.pathExists path then builtins.readDir path else { };

  # Each subdirectory of ./skills is one skill containing a SKILL.md per the
  # Agent Skills standard (https://agentskills.io/specification).
  skillDirs = lib.filterAttrs (_: type: type == "directory") (readDirSafe skillsDir);

  # Symlink each skill directory into both default discovery roots:
  #   ~/.claude/skills/<name>/   — read by Claude Code
  #   ~/.agents/skills/<name>/   — read natively by opencode and pi
  # Recursive directory entries pull in SKILL.md plus any bundled reference
  # docs (LANGUAGE.md, tests.md, etc.) the skill links to. The skills/ parent
  # directory itself stays writable, so users can drop additional skill dirs
  # locally without conflict.
  mkSkillEntry = base: name: lib.nameValuePair "${base}/${name}" {
    source = skillsDir + "/${name}";
    recursive = true;
  };

  claudeEntries = lib.mapAttrs' (name: _: mkSkillEntry ".claude/skills" name) skillDirs;
  agentsEntries = lib.mapAttrs' (name: _: mkSkillEntry ".agents/skills" name) skillDirs;
in
{
  home.file = claudeEntries // agentsEntries;
}
