# Working Agreement

## Communication

- Ask me when the request is unclear. Do not guess the intent or
  the scope.
- Give me the options when more than one approach is correct. Let
  me choose.
- Explain the reason. Do not explain the obvious.

## Review before you hand me the work

Do not hand me a finished changeset that no one but you has read.
Run the `changeset-review` skill first. If your agent does not load
skills, read the same steps from
`~/.agents/skills/changeset-review/SKILL.md`.

- Leave the findings as inline comments in a Hunk session, not in
  chat. Start Hunk yourself in a Herdr pane and tell me how to
  attach. Do not wait on me, and never run the Hunk TUI in your
  own terminal.
- Look up the current docs for every external API the change
  touches. Do not trust your memory of an API.
- Get a second read from another headless agent, whichever is on
  PATH: `codex exec review` or `omp -p`. Use a model that is not
  the one you are running. Ask another Herdr agent too when one
  is up.
- Skip the review for a typo or a one-line edit. Tell me you
  skipped it.
- Tell me what each reviewer found, including nothing. Never
  report a review step you did not run.

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
