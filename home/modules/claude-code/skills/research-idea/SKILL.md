---
name: research-idea
description: Structured project-idea research workflow — landscape scan, critical assessment, build-vs-adopt analysis, differentiator hunt, and (only if warranted) architectural direction. Skeptical by default. Writes to Obsidian vault as research.md. When you detect the user bouncing around potential project ideas ("what if I built X", "I wonder if there's a tool that does Y"), ASK before invoking — never silently run.
argument-hint: [project-name] ["description"] [optional vault path]
allowed-tools: WebSearch, WebFetch, Bash, Write, Read, Glob, Grep, Agent
effort: max
---

Guide the user through end-to-end research for a software project idea
and store the result as `research.md` in their Obsidian vault at
`~/Obsidian/sdelcore/`. Never commit or push anything.

## Auto-invocation behavior

If the user is bouncing around potential project ideas in normal
conversation ("what if I built X", "I wonder if there's a tool for
Y", "I've been thinking about making a Z"), **do not silently invoke
this skill**. Ask first:

> "Want me to run `/research-idea` on this before we go further?"

Only proceed after they confirm. The user is trying to talk
themselves OUT of building something unless the case is strong.

## 1. Parse arguments

`$ARGUMENTS` may contain:
- project name (kebab-case or short)
- optional `"one-line description"`
- optional trailing vault subpath (e.g. `Projects/myapp`)

If the description is missing or vague, treat it as vague and ask
more clarifying questions in the next step.

## 2. Clarifying questions

**Before any research**, ask the user questions to scope the work.
Use judgment — if they already gave a detailed description, ask
fewer. If vague, ask more. Never fire all of these robotically.

Candidate questions:

- What's the actual problem? What triggered this — a pain point,
  a missing tool, curiosity?
- Is this for you personally, for a team, or as a product?
- What existing tools have you already tried or looked at? What
  didn't work?
- Any hard constraints? (language, platform, infra you already
  run)
- How much time are you willing to put in — weekend hack or
  long-term project?
- Where should this go in the vault?

For the vault question, first run:

```bash
ls ~/Obsidian/sdelcore/
```

Show the top-level folders so the user can pick. Common patterns:
`Projects/<name>`, `Work/<name>`, `Ideas/<name>`. Don't assume —
let them choose.

Stop and wait for answers. Do not start phase 3 until you have
what you need.

## 3. Resolve vault path

- If the user passed a path as a third argument, use it.
- Otherwise use the answer from clarifying questions.
- Create with `mkdir -p ~/Obsidian/sdelcore/<path>` if missing.
- Output file is always `research.md` inside the chosen directory.

## 4. Research phases

Run in order. Collect sources (URLs) as you go — they all land in
the Sources section at the end. Consider spawning subagents with
`Agent` for phase 1 (landscape) and phase 4 (differentiators) to
parallelize searches.

### Phase 1 — Landscape

Web-search for existing projects, official tools, and open-source
alternatives that solve the same or adjacent problems. Organize
into tiers:

- **Official / first-party**
- **Closest analogs** (direct competitors)
- **Smaller community projects**
- **Adjacent tools** (solve a neighboring problem, partial overlap)

Include links for every entry. Be thorough — the user wants to
know what already exists before writing a line of code.

### Phase 2 — Critical analysis

Reasons NOT to do this project. Genuinely skeptical, not
performative. For each existing solution from phase 1, explain
concretely why it might already be enough and why building
something new is potentially wasted effort.

Address at minimum:
- Maintenance burden
- Security implications
- Audience size
- Opportunity cost
- Scope creep risk

Don't soften. If most tools cover the need, say so outright.

### Phase 3 — Build vs. adopt

For the closest 1–2 existing projects, do an honest comparison.

- What would "just use/fork that" look like concretely?
- What breaks? What works?
- Could a thin glue layer on top be enough?
- When does glue become its own project?

Be realistic about the threshold. Err on the side of
"adopt + glue" unless there's a clear reason not to.

### Phase 4 — Differentiators

Web-search for real pain points and complaints about existing
solutions (issues, forums, HN/Reddit threads, blog posts).
Identify what's actually missing vs. what will probably get
patched in the next release.

For each differentiator, score:

| Differentiator | Value | Risk / Caveat |
| -------------- | ----- | ------------- |
| …              | high/med/low | specific reason it's fragile |

Do not gas up the project. If the differentiators are thin, say so
and flag this as a reason not to build.

"It's written in Rust" is not a differentiator. Neither is
"it's modern". Differentiators must be things a user would
actually notice.

### Phase 5 — Architectural direction

**Only run this phase if phases 1–4 suggest the project is worth
pursuing.** Otherwise skip and note in the summary that the project
doesn't warrant it.

If pursuing:
- High-level design decisions with leanings and rationale
- Prior art to adopt vs. build from scratch
- Explicit non-goals
- Milestones scoped to reach minimum usefulness FAST

### Phase 6 — Open questions

Decisions that can't be made without more information or
prototyping. Be specific — "figure out the data model" is not an
open question, but "can the scheduler run without a durable queue
for single-user deployments?" is.

## 5. Tone and style rules

Bake these into the output:

- **Concise.** No flowery language, no filler, no "exciting
  opportunity" framing.
- **Skeptical by default.** Argue against the project unless the
  case is strong.
- **Honest about speculation.** Label assumptions clearly.
- **Tables for comparisons, bullets for lists.** No walls of
  prose.
- **Value + risk on the same line.** Never score a feature
  "high value" without naming the caveat.
- **If existing tools cover 90% of the need, recommend against
  building.** Say it directly.

## 6. File output

Write the full research as markdown to
`~/Obsidian/sdelcore/<path>/research.md` using the `Write` tool.

Structure:

```markdown
# <Project name>

> <one-line description>

## Summary
<2–3 sentence verdict: worth building or not, and why>

## 1. Landscape
…

## 2. Critical analysis
…

## 3. Build vs. adopt
…

## 4. Differentiators
…

## 5. Architectural direction
<or: "Skipped — see summary">

## 6. Open questions
…

## Sources
- [Title 1](url)
- [Title 2](url)
```

Every URL touched during research goes in Sources as a markdown
link.

## 7. Report back

After writing the file:

1. Print the absolute path of the saved file.
2. Give a 2–3 sentence honest verdict: worth pursuing or not, and
   the main reason.

Do NOT:
- Commit or push anything
- Suggest next steps beyond "review the file"
- Gas up the project if the research doesn't support it
