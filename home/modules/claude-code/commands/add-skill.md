---
description: Create a new shared agent skill in the upstream nixos config
allowed-tools: Bash, Read
---

Create a new agent skill in the upstream NixOS config at
`sdelcore@nightman.tap:~/src/infra/nixos`. Skills added here are
auto-discovered by `home/modules/agent-skills/default.nix` and
symlinked into both `~/.claude/skills/<name>/` (Claude Code) and
`~/.agents/skills/<name>/` (opencode, pi) on every host's next
`just switch`.

## Arguments

`$ARGUMENTS` should be the skill name in kebab-case (e.g.
`docker-compose-lint`). If missing, ask the user for a name.

## Workflow

### 1. Detect host

Run `hostname`.

- If `nightman` → operate locally at `/home/sdelcore/src/infra/nixos`.
- Otherwise → every file operation runs via
  `ssh sdelcore@nightman.tap` with paths relative to
  `~/src/infra/nixos/`.

### 2. Collect details

From the user or conversation context, gather:

- **name** (kebab-case) — required
- **description** — one-line, for SKILL.md frontmatter
- **allowed-tools** — default `Bash`
- **body** — the actual skill instructions

If anything is missing, ask before proceeding.

### 3. Check for conflict

Before writing, verify
`home/modules/agent-skills/skills/<name>/` does not already exist:

```bash
# local
test -d home/modules/agent-skills/skills/<name> && echo exists

# remote
ssh sdelcore@nightman.tap "test -d ~/src/infra/nixos/home/modules/agent-skills/skills/<name> && echo exists"
```

If it exists, abort and ask the user whether to overwrite. Require
explicit confirmation — do not clobber silently.

### 4. Write SKILL.md

Construct the file with this frontmatter:

```
---
name: <name>
description: <description>
allowed-tools: <tools>
---

<body>
```

**Local write**:

```bash
mkdir -p home/modules/agent-skills/skills/<name>
# then use the Write tool to create home/modules/agent-skills/skills/<name>/SKILL.md
```

**Remote write** (one SSH call, heredoc):

```bash
ssh sdelcore@nightman.tap bash <<REMOTE
  mkdir -p ~/src/infra/nixos/home/modules/agent-skills/skills/<name>
  cat > ~/src/infra/nixos/home/modules/agent-skills/skills/<name>/SKILL.md <<'SKILL_EOF'
<content>
SKILL_EOF
REMOTE
```

### 5. Stage the file

Nix flakes only see git-tracked files:

```bash
# local
git add home/modules/agent-skills/skills/<name>/SKILL.md

# remote
ssh sdelcore@nightman.tap "cd ~/src/infra/nixos && git add home/modules/agent-skills/skills/<name>/SKILL.md"
```

### 6. Report back

Tell the user:

- The path of the new skill
- That it auto-flows to Claude Code, opencode, and pi
- To run `just switch` on each host where they want it active
- To review + commit + push when they're happy
- That the skill auto-activates next session (no manual wiring
  needed — `default.nix` reads `skills/` via `builtins.readDir`)

## Rules

- Do NOT commit automatically
- Do NOT run `just switch` automatically
- Do NOT overwrite an existing skill without explicit confirmation
- Do NOT edit `default.nix` — skills are auto-discovered
- Bundled reference docs (e.g. `LANGUAGE.md`) sit alongside SKILL.md
  in the same skill dir; the module mounts the whole directory
