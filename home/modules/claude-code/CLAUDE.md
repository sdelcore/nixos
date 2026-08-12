# Working Agreement

## Communication

- Ask me when the request is unclear. Do not guess the intent or
  the scope.
- Give me the options when more than one approach is correct. Let
  me choose.
- Explain the reason. Do not explain the obvious.

## Pull requests

These rules apply to every repository. Treat `main` as protected.

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
- A flake sees only the tracked files. Run `git add` on a new file
  before you build.
- Use `nix develop`, or let direnv load the shell. Do not install
  a tool globally.
- opnix holds the secrets in `/var/lib/opnix/secrets/`. Never
  commit a credential.
