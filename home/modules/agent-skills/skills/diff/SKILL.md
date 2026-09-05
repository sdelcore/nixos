---
name: diff
description: Review the current changeset on explicit request. Remove proven padding, open Hunk in the current Zellij tab, check current docs for external APIs, and get exactly one independent model review. Use only when the user invokes /diff or explicitly asks for a changeset review.
---

# Diff Review

Run this workflow only when the user invokes `/diff` or explicitly asks for a
changeset review. Do not trigger it automatically before reporting ordinary
coding work; the user may prefer to keep moving without reviewing each diff.

The review gets a second read from something other than the agent that wrote
the changes. The operational steps use shell commands where that keeps the
workflow portable across Claude Code, opencode, OMP, and Codex.

## Step 0 — De-slop the changeset

Before inspecting the diff or asking the independent reviewer, inspect the full
changeset for padding introduced by the changeset. This is an editing pass:
remove each artifact proven unnecessary, then re-run the changed contract or
the most specific available smoke test. Review the resulting smaller diff, not
the padded original.

Do not claim or imply anything about the change's author. "AI slop" is only a
search label; findings must be concrete and grounded in behavior or established
local patterns.

Preserve a comment when it carries the only useful explanation of an invariant,
non-obvious intent, external constraint, or operational gotcha. Before
removing a construct, apply this load-bearing question: what caller, behavior,
test, or future reader loses essential information if it disappears? Keep it
when the answer is concrete; remove it when nothing material is lost. When
uncertain, preserve the code and record the question for review. Never change
observable behavior in this pass.

Remove, when unnecessary:

- Comments that restate the code, narrate the diff, defend awkward code, or
  add generic process language. Keep concise comments that explain why.
- One-call-site wrappers, one-off helpers, aliases, types, interfaces, config
  keys, flags, re-exports, and extensibility scaffolding added by the
  changeset without a current requirement or meaningful domain name.
- Redundant validation inside trusted internal paths, defensive catch blocks,
  silent fallbacks, and swallowed errors only when no real failure mode or
  caller requires them.
- Dead branches, unused options, speculative TODOs, compatibility cruft, tests
  that do not exercise a changed path, and unrelated formatting changes.
- Language-specific escape hatches or performance ceremony without evidence,
  such as casts to bypass types or memoization added without an identity or
  computational need.

Search nearby code before removing or replacing a pattern. Reuse an established
local convention rather than introducing a second one. Do not clean up
pre-existing code outside the changeset in this pass; record a separate finding
instead.

Update all affected callers and delete obsolete paths in the same pass. Verify
the modified behavior with the changed contract test or most specific available
smoke test before continuing to Step 1.

## Step 1 — Open Hunk in the current Zellij tab

Never run `hunk diff` or `hunk show` in your own pane. They are full-screen
TUIs. Confirm the agent is inside Zellij, then open Hunk in a right-hand split
of the current tab:

```bash
test -n "${ZELLIJ:-}"
zellij action new-pane --direction right --cwd "$PWD" \
  --name "Changeset Review" -- hunk diff
hunk session list
```

Use `hunk diff` for uncommitted work. For committed branch work, replace the
final command with `hunk diff main...HEAD`. The new pane must stay in the
current tab; do not create another tab or run Hunk in the agent's pane.

If the agent is not inside Zellij, do not launch the TUI. Inspect the complete
scoped diff headlessly and report findings in chat with file and line references.
Use plain `git diff` for uncommitted work and `git diff main...HEAD` for
committed branch work. Scope out unrelated user changes.

Review every changed line for behavioral regressions, missed callsites, stale
comments, accidental formatting churn, and missing coverage of a changed
contract. Fix verified defects before requesting the independent review, then
rerun the most specific check.

## Step 2 — Check the docs, do not trust your memory

For every external API, CLI flag, config key, or module option the
changeset touches, look up the current documentation. Use whatever web
search or fetch tool you have. If you have none, use `curl` against the
upstream docs or the source.

This step exists because model memory of an API is frequently a version
or two stale, and that is the defect class that survives self-review.

Record what you checked. A claim like "the option still exists" needs the
URL or the source file that proves it.

## Step 3 — Get exactly one second read

Run one external model review, not a chain of reviewers. Never run multiple
headless reviewers for the same changeset.

The reviewer starts from a fresh context, so it cannot inherit the reasoning
that produced the mistake. Pick a model that is not the one you are running.

### Run the reviewer as a background process

Use exactly one available headless CLI with a model different from the active
executor. Launch it through the host's normal background-job facility; never
prompt, steer, resume, or reuse an existing interactive agent. The fresh process
provides context separation without taking over the user's workspace.

Match effort to risk. The examples use medium. Raise it only under the risk
criteria above.

**Codex** reads the repository itself. Revision selectors cannot be combined
with a custom positional prompt:

```bash
codex exec review --uncommitted -c model_reasoning_effort="medium"
```

Use `--base main` for committed branch changes or `--commit <sha>` for one
commit.

**Claude** can review a scoped diff from stdin with read-only tools:

```bash
git diff -- path/to/changed/files | claude -p --effort medium \
  --tools Read,Grep,Glob \
  'Review this diff. Report concrete defects with file and line; no style notes.'
```

**OMP** also accepts a diff on stdin:

```bash
git diff -- path/to/changed/files | omp -p \
  --model '<different-reviewer-model>' --thinking medium \
  'Review this diff. Name concrete defects only; no style notes.'
```

Use plain `git diff` for uncommitted work and `git diff main...HEAD` for
committed branch work. Scope out unrelated user changes. Verify the diff is
non-empty before piping it. Ask a narrow question, treat the result as
evidence, and discard findings you cannot reproduce.

If the chosen reviewer cannot start or finish, report the failure. Do not
silently run another reviewer; that recreates the duplicate-review chain this
workflow intentionally avoids.

## Step 4 — Reconcile and publish the findings

Verify each finding from the self-review and independent reviewer against the
code, current documentation, or command output. Fix every confirmed defect and
rerun the affected check. Drop findings that cannot be reproduced, but report
that they were dropped and why.

When the Hunk session is available, put every surviving finding into it as one
batch so the user can read the comments against the changed lines:

```bash
printf '%s' '{"comments":[
  {"filePath":"path/to/file.nix","newLine":42,
   "summary":"Stale option name","author":"codex",
   "rationale":"Upstream renamed this; see <url>."}
]}' | hunk session comment apply --repo . --stdin
```

Each comment needs `filePath`, `summary`, and exactly one target: `hunk`,
`oldLine`, or `newLine`. Put evidence in `rationale` and identify the reviewer
in `author`. Also report every reviewer's result and all surviving findings in
chat with file and line references, whether or not Hunk was available.

## Step 5 — Report

Tell the user in chat:

- What each reviewer found, and which findings survived verification.
- What Step 0 removed, and the verification that showed each removal preserved
  behavior.
- What you fixed, and what you left alone with the reason.
- Which claims you could not verify.

Then follow the pull-request rules in the working agreement. The review
is a gate in front of the PR, not a replacement for it.

## Honesty rules

These matter more than the mechanics.

- A review that finds nothing is a valid result. Report it plainly.
  Do not invent a finding to look thorough.
- Never report a step as run when it was not run. If the second model timed out,
  say so.
- Do not soften a real defect because you wrote the code.
