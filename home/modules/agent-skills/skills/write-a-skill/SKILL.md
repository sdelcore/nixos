---
name: write-a-skill
description: Write a new agent skill, and optionally ship it to every host through the NixOS config. Use when the user wants to create, write, build, add, or deploy a skill.
---

# Writing Skills

## Process

1. **Gather requirements** - ask user about:
   - What task/domain does the skill cover?
   - What specific use cases should it handle?
   - Does it need executable scripts or just instructions?
   - Any reference materials to include?

2. **Draft the skill** - create:
   - SKILL.md with concise instructions
   - Additional reference files if content exceeds 500 lines
   - Utility scripts if deterministic operations needed

3. **Review with user** - present draft and ask:
   - Does this cover your use cases?
   - Anything missing or unclear?
   - Should any section be more/less detailed?

## Skill Structure

```
skill-name/
├── SKILL.md           # Main instructions (required)
├── REFERENCE.md       # Detailed docs (if needed)
├── EXAMPLES.md        # Usage examples (if needed)
└── scripts/           # Utility scripts (if needed)
    └── helper.js
```

## SKILL.md Template

```md
---
name: skill-name
description: Brief description of capability. Use when [specific triggers].
---

# Skill Name

## Quick start

[Minimal working example]

## Workflows

[Step-by-step processes with checklists for complex tasks]

## Advanced features

[Link to separate files: See [REFERENCE.md](REFERENCE.md)]
```

## Description Requirements

The description is **the only thing your agent sees** when deciding which skill to load. It's surfaced in the system prompt alongside all other installed skills. Your agent reads these descriptions and picks the relevant skill based on the user's request.

**Goal**: Give your agent just enough info to know:

1. What capability this skill provides
2. When/why to trigger it (specific keywords, contexts, file types)

**Format**:

- Max 1024 chars
- Write in third person
- First sentence: what it does
- Second sentence: "Use when [specific triggers]"

**Good example**:

```
Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when user mentions PDFs, forms, or document extraction.
```

**Bad example**:

```
Helps with documents.
```

The bad example gives your agent no way to distinguish this from other document skills.

## When to Add Scripts

Add utility scripts when:

- Operation is deterministic (validation, formatting)
- Same code would be generated repeatedly
- Errors need explicit handling

Scripts save tokens and improve reliability vs generated code.

## When to Split Files

Split into separate files when:

- SKILL.md exceeds 100 lines
- Content has distinct domains (finance vs sales schemas)
- Advanced features are rarely needed

## Review Checklist

After drafting, verify:

- [ ] Description includes triggers ("Use when...")
- [ ] Description does not collide with an existing skill's triggers
- [ ] SKILL.md under 100 lines
- [ ] No time-sensitive info
- [ ] Consistent terminology
- [ ] Concrete examples included
- [ ] References one level deep

## Shipping to every host

Only when the user wants the skill live, not just drafted. Shared skills live in the upstream NixOS config at
`home/modules/agent-skills/skills/<name>/` and auto-symlink into
`~/.claude/skills/<name>/` (Claude Code) and `~/.agents/skills/<name>/`
(opencode, OMP) on the next `just switch`.

1. **Find the upstream.** Run `hostname`. On `nightman`, operate locally at
   `/home/sdelcore/src/infra/nixos`. Anywhere else, run every git and file
   operation over `ssh sdelcore@nightman.tap` against `~/src/infra/nixos`.

2. **Check for a conflict.** If `skills/<name>/` already exists, stop and ask
   before overwriting.

3. **Branch and write.** From a clean `main`, create a feature branch
   (`add-<name>-skill`). Write `SKILL.md` plus any bundled files.

4. **Commit and push.** Stage only the new files — never `git add .`. Push with `-u`.

5. **Open a PR** explaining what the skill does and why. Share the URL immediately,
   then watch CI. If a check fails, fix the root cause — never re-run blindly.

6. **After merge, roll out.** On each host: `git -C ~/src/infra/nixos pull`, then
   `just switch` with no arguments. For remote hosts run `just deploy <host> <ip>`
   from nightman. **Never** run `just switch <foreign-hostname>` — applying another
   host's config breaks the system.

Do not edit `agent-skills/default.nix`; skills are auto-discovered via `builtins.readDir`.
