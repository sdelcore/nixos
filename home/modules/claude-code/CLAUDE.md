# Working Agreement

## Communication

- Ask me when the request is unclear. Do not guess the intent or
  the scope.
- Give me the options when more than one approach is correct. Let
  me choose.
- Explain the reason. Do not explain the obvious.

## Optional diff review

Do not interrupt normal coding work with a diff review. Run the `diff` skill
only when I explicitly invoke `/diff` or ask for a changeset review. If your
agent does not load skills, read the same steps from
`~/.agents/skills/diff/SKILL.md`.

- Open Hunk in a split pane in the current Zellij tab and leave it available for
  me. Do not run the Hunk TUI in your own pane or create a separate tab.
- Put verified findings in Hunk as inline comments and report every reviewer's
  result in chat, including when they found nothing.
- Look up the current docs for every external API the change touches. Do not
  trust your memory of an API.
- Get exactly one second read from a different model. Run the independent
  reviewer as a fresh headless background process; never prompt, steer, resume,
  or reuse an existing interactive agent for review.
- Tell me what each reviewer found, including nothing. Never report a review
  step you did not run.

## Pull requests

These rules apply to every repository. Treat `main` as protected.
The review above is a gate in front of the PR, not a replacement.

- Do not commit to `main`. Create a branch, then open a PR.
- Name the branch in short kebab-case, for example
  `fix-stale-token-refresh`.
- Write the PR body to explain the reason for the change. Send me
  the URL.
- Watch the CI checks. Find the cause of a failure. Do not re-run
  a failed check without a fix.
- Answer a review comment in a new commit on the branch. Tell me
  if you disagree with it.

## NixOS

- `nightman` is the desktop. It also holds the upstream config at
  `~/src/infra/nixos`. `dayman` is the laptop. `workbox` builds
  from `~/hms/workbox` on dayman.
- Run `hostname` before a build or a switch that names a host. A
  foreign host config breaks the system.
- Never run `just switch`, `nixos-rebuild switch`, or any equivalent
  activation command without explicit permission in the current conversation.
- A flake sees only the tracked files. Run `git add` on a new file
  before you build.
- Use `nix develop`, or let direnv load the shell. Do not install
  a tool globally.
- opnix holds the secrets in `/var/lib/opnix/secrets/`. Never
  commit a credential.
