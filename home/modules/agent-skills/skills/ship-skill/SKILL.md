---
name: ship-skill
description: Author a new agent skill and ship it through the full deploy flow — write SKILL.md in the upstream nixos config, open a PR, then run just switch on each host. Use when user wants to create AND deploy a new shared skill end-to-end. For authoring-only guidance, see write-a-skill.
---

# Ship a Skill

End-to-end pipeline for adding a shared agent skill to the upstream
NixOS config and rolling it out to every host. Skills land under
`home/modules/agent-skills/skills/<name>/` and auto-symlink into
`~/.claude/skills/<name>/` (Claude Code) and `~/.agents/skills/<name>/`
(opencode, OMP) on the next `just switch`.

## When to use

- User says "add a skill", "ship a skill", "deploy this skill"
- A skill draft exists in conversation and the user wants it live
- User wants the whole flow (write → PR → switch), not just authoring

For content-quality guidance without deploy, use `write-a-skill`.

## Workflow

### 1. Detect upstream host

Run `hostname`.

- `nightman` → operate locally at `/home/sdelcore/src/infra/nixos`.
- Anything else → every git/file operation runs via
  `ssh sdelcore@nightman.tap` against `~/src/infra/nixos`.

### 2. Collect the skill

From conversation or by asking:

- **name** (kebab-case) — required
- **description** — one-line frontmatter, must include "Use when …"
- **body** — the actual instructions
- **bundled files** (optional) — reference docs or scripts

### 3. Check for conflict

Verify `home/modules/agent-skills/skills/<name>/` does not already
exist. If it does, abort and ask before overwriting.

### 4. Branch + write

From a clean main, create a feature branch (`add-<name>-skill` or
similar kebab-case). Then write
`home/modules/agent-skills/skills/<name>/SKILL.md` plus any bundled
files.

Remote example (single ssh call):

    ssh sdelcore@nightman.tap bash <<'REMOTE'
      cd ~/src/infra/nixos
      git switch main && git pull
      git switch -c add-<name>-skill
      mkdir -p home/modules/agent-skills/skills/<name>
      cat > home/modules/agent-skills/skills/<name>/SKILL.md <<'SKILL_EOF'
    <content>
    SKILL_EOF
    REMOTE

### 5. Stage, commit, push

Stage **only** the new file(s) — never `git add .`. Commit with a
HEREDOC message. Push the branch with `-u`.

### 6. Open PR

`gh pr create` with a title and body explaining what the skill does
and why. Share the PR URL with the user immediately.

### 7. Monitor CI

If a check fails, investigate the root cause and push a fix —
never re-run blindly.

### 8. After merge: roll out

Once merged, on each host where the user wants the skill active:

1. Pull main: `git -C ~/src/infra/nixos pull`
2. `just switch` (no args — uses current host)

For remote hosts, run `just deploy <host> <ip>` from nightman
instead. **Never** run `just switch <foreign-hostname>` — applying
a foreign host config breaks the system.

## Rules

- Do not commit directly to main — always feature branch + PR
- Do not force-push
- Do not run `just switch <hostname>` with a mismatched hostname
- Do not edit `home/modules/agent-skills/default.nix` — skills are
  auto-discovered via `builtins.readDir`
- Bundled files sit alongside SKILL.md; the module mounts the
  whole directory recursively
