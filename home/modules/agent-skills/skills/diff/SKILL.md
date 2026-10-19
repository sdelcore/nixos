---
name: diff
description: Review changes only on explicit `/diff` or changeset-review request. Self-verify, get one fresh-context subagent review with a different model, run checks, then report in prose and ask whether to review hunks; open Hunk only on request.
---

# Diff Review

Run this workflow only when the user invokes `/diff` or explicitly asks for a
changeset review. Do not trigger it automatically before reporting ordinary
coding work.

Follow this loop in order:

1. Generate the change.
2. Self-verify and check current documentation.
3. Get exactly one independent review from a fresh-context subagent using a
   different model.
4. Run the repository's automated checks for the changed files and contract.
5. Resolve findings and repeat the loop, or escalate a novel issue.
6. Report in prose, then ask: **Want to review the hunks?**

## 1. Self-verify

Inspect the full changeset for padding introduced by the changeset. This is an
editing pass: remove each artifact proven unnecessary, then re-run the changed
contract or the most specific available smoke test. Review the resulting
smaller diff, not the padded original.

Preserve a comment when it carries the only useful explanation of an invariant,
non-obvious intent, external constraint, or operational gotcha. Before
removing a construct, apply this load-bearing question: what caller, behavior,
test, or future reader loses essential information if it disappears? Keep it
when the answer is concrete; remove it when nothing material is lost. When
uncertain, preserve the code and record the question for review. Never change
observable behavior in this pass.

Search nearby code before removing or replacing a pattern. Reuse an established
local convention rather than introducing a second one. Do not clean up
pre-existing code outside the changeset in this pass; record a separate finding
instead. Update affected callers and delete obsolete paths in the same pass.

Re-run the most specific check after the pass. Also run the repository's own
build, test, and format commands that apply to the touched files.

For every external API, CLI flag, config key, or module option the changeset
touches, look up current documentation. Record the URL or source file that
proves the claim. Do not rely on memory. If documentation cannot be checked,
record that limitation.

## 2. Independent review

Spawn exactly one read-only subagent in the same agent runtime and working tree,
with a fresh context and a model explicitly different from the one that wrote
the change. For example, in OMP use its native subagent/task facility with a
model override. Do not use a different CLI or harness, start another interactive
agent, or prompt or steer the user's panes.

Give the reviewer the scoped diff: `git diff` for uncommitted work or
`git diff main...HEAD` for committed branch work. Ask only for concrete defects
with file and line references; no style notes. Scope out unrelated user
changes. Verify each finding against the code, docs, or command output; discard
unreproducible findings and record why. An empty review is valid.

If the subagent cannot start or finish, report that. Do not substitute another
harness or run another reviewer.

## 3. Automated checks

Run the repository's real checks for the changed files and behavior (for
example, `just fmt`, a host build for Nix changes, or the relevant test/smoke
check for a changed contract). Cached or "up-to-date" output is not evidence;
the check must execute. Record the commands and actual results. If a confirmed
finding is fixed, rerun the affected checks.

## 4. Decide and loop

- **Resolvable:** concrete and fixable without a product, design, or contract
  decision. Fix it, then return to generating the change and repeat the full
  workflow. Allow at most two iterations; on a third iteration, treat the issue
  as novel and escalate.
- **Novel:** requires a human decision or cannot be resolved safely. Do not
  guess; proceed to the human report and question.
- **All clear:** proceed to the human report and question.

## 5. Report, then ask

In chat, report plainly:

- What changed and why, in one short paragraph; do not dump the diff.
- What self-verification removed and which check proved each removal safe.
- What the reviewer found, which findings survived verification, and which
  were dropped and why.
- Which automated checks actually ran and their results.
- What could not be verified.
- Residual risk in one line.

Then ask exactly one question: **Want to review the hunks?**

- **Yes:** open or reuse exactly one Hunk pane beside the current agent, then
  stop for the human. If `HERDR_ENV=1`, inspect `herdr pane list` and
  `hunk session list --json`; reuse a live session for this repository if one
  exists, otherwise split the current pane and run `hunk diff` for uncommitted
  work or `hunk diff main...HEAD` for committed branch work. If Herdr is
  unavailable but `ZELLIJ` is set, reuse a live session or open a right-hand
  split in the current tab. If neither exists, report the findings in chat
  with file and line references instead of launching a TUI. Put surviving
  reviewer findings into the session with one `hunk session comment apply`
  batch. Do not open the PR behind the human's back.
- **No:** proceed to the PR, or ship under the working agreement. Follow the
  repository's PR rules.

If the human does not answer, treat that as **No** only when the working
agreement allows shipping without review; otherwise leave the work staged and
stop.

## Honesty rules

- A review that finds nothing is a valid result. Report it plainly.
  Do not invent a finding to look thorough.
- Never report a step as run when it was not. If the second model timed out,
  say so.
- Do not soften a real defect because you wrote the code.
