---
name: obsidian
description: >
  This skill should be used when the user mentions their "Obsidian vault",
  "notes", "daily note", "weekly note", "journal", asks about "tasks" or
  "todos" that are not related to the current codebase, references personal
  projects like "aria", "HMS", "NOVA", "thesis", "blog", "Home Lab", asks
  "what did I work on", "what's on my plate", "what's due", "show my tasks",
  "check my notes", mentions project status or progress outside the current
  repo, references "quick notes", or asks about anything stored in their
  personal knowledge base or vault. This skill provides read-only access to
  the user's Obsidian vault from any working directory.
---

# Obsidian Vault Access

The user's Obsidian vault is at `/home/sdelcore/Obsidian/sdelcore`. Use Glob, Grep, and Read tools with absolute paths to search and read vault files from any working directory.

## Vault Layout

```
/home/sdelcore/Obsidian/sdelcore/
├── Periodic/
│   ├── Daily/YYYY-MM-DD.md        # Daily notes (tasks, events, work logs)
│   └── Weekly/YYYY-Www.md         # Weekly summaries
├── Projects/                       # aria, blog, droidcode, Home Lab, Ideas, Paradise Resort, voiced
├── Work/                           # HMS.md, HMS Tool Certification/, Infrastructure/, NOVA/
├── WISE Lab/                       # E2E ADS X/, GeoScenario/, Admin/
├── Personal/                       # Personal life notes
├── Vault/                          # Reference materials, knowledge base
├── Archive/                        # Completed/old items
├── Tasks.md                        # Dashboard queries only (not raw data)
├── Projects.md                     # Dashboard queries only (not raw data)
└── Quick Notes.md                  # Scratch pad
```

## Frontmatter Schema

Project files use:
```yaml
type: project
status: active | planning | on-hold | completed | archived
priority: high | medium | low
area: work | personal | research
project-tag: kebab-case-name
start-date: YYYY-MM-DD
target-date: YYYY-MM-DD
```

## Task Format

**Checkbox statuses:**
- `[ ]` — Todo (open)
- `[/]` — In Progress
- `[x]` — Done (auto-sets `✅ YYYY-MM-DD`)
- `[-]` — Cancelled (auto-sets `❌ YYYY-MM-DD`)

**Examples:**
```
- [ ] Task description #project/tag-name 📅 YYYY-MM-DD
- [ ] High priority task #project/tag ⏫ 📅 YYYY-MM-DD
- [/] In-progress task #project/tag ⏳ YYYY-MM-DD 📅 YYYY-MM-DD
- [x] Completed task #project/tag 📅 YYYY-MM-DD ✅ YYYY-MM-DD
- [-] Cancelled task #project/tag ❌ YYYY-MM-DD
```

**Date markers:** `📅` due date, `⏳` scheduled date (when to start), `✅` done date, `❌` cancelled date
**Priority markers:** `⏫` high, `🔼` medium, `🔽` low
**Project tags:** `#project/kebab-case` — known tags: `aria`, `HMS`, `HMS-Bakery`, `HMS-Tool-Cert`, `thesis`, `blog`, `home-lab`.

## Search Strategies

**Finding tasks**: Grep for `- \[ \]` (open), `- \[/\]` (in-progress), `- \[x\]` (done), or `- \[-\]` (cancelled) in `/home/sdelcore/Obsidian/sdelcore`. Filter with project tags or dates. Do NOT read Tasks.md for raw tasks — it contains only Obsidian plugin queries.

**Finding project status**: Read the project's `.md` file for frontmatter, grep for open tasks with its tag, grep recent daily notes for `## [[ProjectName]]` work log headers.

**Daily notes**: Read `Periodic/Daily/YYYY-MM-DD.md` for a specific date. Glob `Periodic/Daily/YYYY-MM-*.md` for a date range.

**Knowledge base**: Glob `Vault/**/*.md` or grep vault-wide for content matches.

**Deep research**: For queries spanning many files, use the Agent tool with an Explore subagent pointed at the vault path.
