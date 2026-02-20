---
description: Query your Obsidian vault — tasks, projects, notes, daily/weekly journals
argument-hint: [query]
allowed-tools: [Read, Glob, Grep, WebSearch, Task]
---

# Obsidian Vault Query

You have access to the user's Obsidian vault at `/home/sdelcore/Obsidian/sdelcore`.

The user's query: $ARGUMENTS

## Vault Structure

| Path | Contents |
|------|----------|
| `Periodic/Daily/YYYY-MM-DD.md` | Daily notes with tasks, events, work logs |
| `Periodic/Weekly/YYYY-Www.md` | Weekly summaries |
| `Projects/` | Personal projects: aria, blog, droidcode, Home Lab, Ideas, Paradise Resort, voiced |
| `Work/` | Work projects: HMS.md, HMS Tool Certification/, Infrastructure/, NOVA/ |
| `WISE Lab/` | Research projects: E2E ADS X/, GeoScenario/, Admin/ |
| `Personal/` | Personal life notes |
| `Vault/` | Reference materials and knowledge base |
| `Archive/` | Completed/old items |
| `Tasks.md` | Dashboard (plugin queries only — not raw data) |
| `Projects.md` | Dashboard (plugin queries only — not raw data) |
| `Quick Notes.md` | Scratch pad |

## Query Routing

Classify the query and follow the matching strategy. Combine strategies if a query spans multiple categories.

### Tasks (keywords: task, todo, due, overdue, open, done, completed)

Tasks live **inside project files and daily notes**. Do NOT read Tasks.md or Projects.md for task data — they contain Obsidian Tasks plugin queries that cannot be evaluated outside the app. Grep raw markdown instead.

1. **Open tasks**: Grep pattern `- \[ \]` on `/home/sdelcore/Obsidian/sdelcore`
2. **In-progress tasks**: Grep pattern `- \[/\]`
3. **Completed tasks**: Grep pattern `- \[x\]`
4. **Cancelled tasks**: Grep pattern `- \[-\]`
5. **Filter by project**: Add `#project/tag-name` to the grep
6. **Filter by date**: Add the `YYYY-MM-DD` date string to the grep
7. **Overdue**: Find open tasks with `📅` dates before today's date

**Task checkbox statuses:**
- `[ ]` — Todo (open)
- `[/]` — In Progress
- `[x]` — Done (auto-sets `✅ YYYY-MM-DD`)
- `[-]` — Cancelled (auto-sets `❌ YYYY-MM-DD`)

**Task metadata markers:**
- `📅 YYYY-MM-DD` — due date
- `⏳ YYYY-MM-DD` — scheduled date (when to start)
- `⏫` — high priority
- `🔼` — medium priority
- `🔽` — low priority
- `✅ YYYY-MM-DD` — completed date
- `❌ YYYY-MM-DD` — cancelled date
- `#project/kebab-case` — project tag

### Projects (keywords: project, status, progress, or a project name)

**Known project-to-tag mapping:**
| Project | Tag | Location |
|---------|-----|----------|
| aria | `#project/aria` | Projects/aria/ |
| HMS | `#project/HMS` | Work/HMS.md |
| HMS Bakery | `#project/HMS-Bakery` | Work/ |
| HMS Tool Cert | `#project/HMS-Tool-Cert` | Work/HMS Tool Certification/ |
| Thesis / E2E ADS X | `#project/thesis` | WISE Lab/E2E ADS X/ |
| blog | — | Projects/blog/ |
| NOVA | — | Work/NOVA/ |
| Home Lab | `#project/home-lab` | Projects/Home Lab/ |

1. **Find project file**: Glob for `.md` files in Projects/, Work/, or WISE Lab/ matching the name
2. **Read frontmatter**: status, priority, area, start-date, target-date
3. **Open tasks**: Grep for `#project/<tag>` combined with `- \[ \]`
4. **Recent activity**: Grep `Periodic/Daily/` for `## [[ProjectName]]` headers in recent daily notes
5. **List active projects**: Grep for `status: active` across all `.md` files

### Daily Notes (keywords: today, yesterday, daily, journal, what did I do, work log)

- **Today**: Read `Periodic/Daily/YYYY-MM-DD.md` (use current date)
- **Yesterday**: Read the previous date's file
- **Recent**: Glob `Periodic/Daily/YYYY-MM-*.md` and read the latest few
- **Structure**: Daily notes have `# Quick Tasks`, `# Events`, and `# Work Log` with `## [[ProjectName]]` sub-headers

### Weekly Notes (keywords: week, weekly, this week, last week)

- Read `Periodic/Weekly/YYYY-Www.md` for the relevant week
- Weekly notes embed/aggregate daily content

### Knowledge Base (keywords: notes about, reference, how to, vault)

1. Glob `Vault/**/*keyword*.md` for filename matches
2. Grep `/home/sdelcore/Obsidian/sdelcore` for content keyword matches
3. Read matching files

### General Search

1. Glob `**/*keyword*.md` across the vault root
2. Grep for keyword in file contents
3. Read matching files and summarize

## Deep Research

For queries that require searching across many files (e.g., "summarize all my work this month"), use the Task tool to spawn an Explore subagent:
- Point the agent at `/home/sdelcore/Obsidian/sdelcore`
- Give it a focused search objective
- Let it do multi-step Glob/Grep/Read across the vault

## Supplementary Web Search

When the user's query relates to external topics mentioned in vault notes (technologies, libraries, concepts), use WebSearch to provide additional context alongside the vault findings.

## Response Guidelines

- Present findings clearly with vault file paths as references
- For tasks: show checkbox status, description, project tag, priority, due date
- For projects: show status, priority, area, open task count, recent activity summary
- For daily notes: summarize events, tasks, and work log entries
- If you encounter Obsidian plugin syntax (dataview/tasks queries, callouts), explain it's a dynamic query and search for the raw underlying data instead
