---
name: changeset-review
description: Review a finished changeset before it reaches the user, using a live Hunk session for inline comments, current web docs for every external API touched, and a second read from another headless agent (codex or omp). Use after finishing any non-trivial change, before opening a PR or reporting the work as done.
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

Hunk's TUI belongs to the user. Never run `hunk diff` or `hunk show`
yourself; those take over the terminal. You drive the live session
through `hunk session *` only.

```bash
hunk session list
```

If it prints `No active Hunk sessions.`, stop and ask the user to open
one in their terminal:

> Run `hunk diff main...HEAD` in the repo, then tell me when it is up.

If a session is live, read the structure before the raw text:

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

## Step 3 — Get a second model to read it

Send the changeset to another agent running headlessly. The reviewer
starts from a fresh context, so it cannot inherit the reasoning that
produced the mistake. Pick a model that is not the one you are running.

Do not depend on any single vendor's CLI being installed. Use whichever
of these is on PATH.

**Codex** has a review mode built in, so it reads the repository itself
rather than a piped diff:

```bash
codex exec review --base main -c model_reasoning_effort="max" \
  'Name concrete defects only: wrong behavior, a broken edge case, a
   stale API, or a claim the diff does not support. Give the file and
   line for each. If it is sound, say so in one line. No style notes.'
```

Use `--uncommitted` instead of `--base main` when the work is not
committed yet, or `--commit <sha>` for one commit.

**OMP** takes the diff on stdin:

```bash
git diff main...HEAD | omp -p --model 'litellm/chatgpt/gpt-5.6-sol' \
  --thinking max 'Review this diff. Name concrete defects only: ...'
```

Check that the diff is not empty before you pipe it. `main...HEAD` covers
committed work only, so use plain `git diff` when the changeset is still
uncommitted. An empty pipe produces a confident review of nothing.

Ask a narrow question rather than "review this". A narrow question gets a
specific answer; a broad one gets a summary you already know.

Treat the reply as evidence, not as a verdict. Verify each claim against
the code before you act on it. A second model is confidently wrong at
roughly the same rate you are.

## Step 4 — Ask another agent, when one is running

If Herdr has other agent panes live, send the diff to one for a third
read:

```bash
herdr agent list
herdr agent prompt <id> 'Review the diff on branch <branch> in <repo>. Report concrete defects with file and line.'
herdr agent wait <id> --until idle --timeout 300000
herdr agent read <id>
```

Skip this when no other agent is running. Step 3 alone satisfies the
second-reader requirement.

## Step 5 — Post the findings into Hunk

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

## Step 6 — Report

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
