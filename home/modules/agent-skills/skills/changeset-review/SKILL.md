---
name: changeset-review
description: Review a finished changeset before it reaches the user, using a live Hunk session for inline comments, current web docs for every external API touched, and exactly one independent model review. Use after finishing any non-trivial change, before opening a PR or reporting the work as done.
---

# Changeset Review

Run this after you finish a changeset and before you report the work as
done. The point is that the changeset gets read by something other than
the agent that wrote it. You are a poor reviewer of your own diff.

Every step here is a shell command on purpose. This skill runs the same
way under Claude Code, opencode, OMP, and Codex.

## When to run it

Run it when the change touches more than one file, or when it touches an
external API, a flag, a schema, or a version-pinned dependency.

Skip it for a typo, a comment, or a one-line edit you already verified by
running the code. Say that you skipped it and why.

## Step 1 — Get the changeset into Hunk

Never run `hunk diff` or `hunk show` in your own terminal. Those are
full-screen TUIs and they take over the session you are running in.

Spawn one in a Herdr pane instead. The Herdr server outlives the pane,
so the review sits there until the user attaches to it. Do not block
waiting for them. Each agent creates its own review session; never reuse
another agent's Hunk session just because it covers the same repository.

First check whether this agent is running inside Herdr. Do not call pane
commands with an empty `$HERDR_PANE_ID`.

```bash
herdr status
test -n "${HERDR_PANE_ID:-}"
```

If either check fails, ask the user to run the appropriate `hunk diff` command
and tell you when it is ready. Otherwise, name the tab after the originating
agent's generated terminal title. Strip OMP's `π` run-state prefix and a
leading task verb, then prefix the result with `Review ·`. This distinguishes
concurrent agents reviewing the same working tree. Fall back to the repository
directory when no agent title is available.

```bash
originPane=$(herdr pane get "$HERDR_PANE_ID")
origin=$(printf '%s' "$originPane" \
         | jq -r '.result.pane.terminal_title_stripped // empty')
topic=$(printf '%s' "$origin" \
        | sed -E 's/^π[[:space:]]+[^[:space:]]+[[:space:]]+//; s/^Explore useful[[:space:]]+//; s/^(Fix|Implement|Review|Add|Update|Create|Investigate)[[:space:]]+//')
[ -n "$topic" ] || topic=$(basename "$PWD")
workspace=$(printf '%s' "$originPane" | jq -r '.result.pane.workspace_id')
label=$(printf 'Review · %.48s' "$topic")
pane=$(herdr tab create --workspace "$workspace" --cwd "$PWD" \
       --label "$label" --no-focus | jq -r '.result.root_pane.pane_id')
herdr pane run "$pane" hunk diff
hunk session list                          # confirm it registered
```

Use `hunk diff` for uncommitted work. Use `hunk diff main...HEAD` only
when the intended changeset is committed on the current branch. Add `--focus`
only if the user asked to be taken there.

Tell the user the session is up and how to reach it: attach with
`herdr session attach <name>` from `herdr session list`, or switch to the
named `Review · <topic>` tab if they are already in Herdr.

Once a session is live, read the structure before the raw text:

```bash
hunk session review --repo . --json                   # files and hunks
hunk session review --repo . --include-patch --json   # raw diff, only when needed
```

For the full session CLI reference, read the file that `hunk skill path`
prints. Do not guess at flags.

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

Run one external model review, not a chain of reviewers. Hunk is only the
inline review UI; it does not count as another model review. Never run multiple
headless reviewers for the same changeset.

The reviewer starts from a fresh context, so it cannot inherit the reasoning
that produced the mistake. Pick a model that is not the one you are running.

### Run the reviewer as a background process

Use exactly one available headless CLI with a model different from the active
executor. Launch it through the host's normal background-job facility; do not
create a Herdr tab and never prompt, steer, resume, or reuse an existing Herdr
agent. The fresh process provides context separation without taking over the
user's workspace.

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

## Step 4 — Post the findings into Hunk

Put every surviving finding into the live session as one batch, so the
user reads them inline against the code instead of in a wall of chat
text:

```bash
printf '%s' '{"comments":[
  {"filePath":"path/to/file.nix","newLine":42,
   "summary":"Stale option name","author":"codex",
   "rationale":"Upstream renamed this in 24.11; see <url>."}
]}' | hunk session comment apply --repo . --stdin
```

`author` is a field inside each comment object, not a CLI flag. Name the
reviewer that found it, so the user can tell your findings from the
second model's. Each object needs `filePath`, `summary`, and exactly one
target (`hunk`, `oldLine`, or `newLine`).

Rules for the comments:

- One comment per real defect. Do not annotate every hunk.
- Say what breaks, not what you changed. The user can see the diff.
- Put the evidence in `rationale`: the URL, the source line, or the
  command output.
- Drop any finding you could not verify. Say in chat that you dropped it.

## Step 5 — Report

Tell the user in chat:

- What each reviewer found, and which findings survived verification.
- What you fixed, and what you left alone with the reason.
- Which claims you could not verify.

Then follow the pull-request rules in the working agreement. The review
is a gate in front of the PR, not a replacement for it.

## Honesty rules

These matter more than the mechanics.

- A review that finds nothing is a valid result. Report it plainly.
  Do not invent a finding to look thorough.
- Never report a step as run when it did not run. If Hunk was not open,
  or the second model timed out, say so.
- Do not soften a real defect because you wrote the code.
