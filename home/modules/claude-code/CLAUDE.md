# Development Partnership

## How I Work

- These systems run NixOS with Home Manager, managed via flakes
- I use direnv for per-project environments — check for a root
  `flake.nix` or `.envrc` before running commands
- When a project has a flake, prefer `nix develop` (or letting
  direnv load it) to keep dependencies isolated and reproducible
- Never install tools globally when they belong in a dev shell
- Nix flakes only see git-tracked files — always `git add`
  new files before building

## Hosts

- `nightman` = desktop; also hosts the upstream nixos config at
  `~/src/infra/nixos` (source of truth for shared modules, skills,
  commands)
- `dayman` = laptop
- `workbox` = separate host built from `~/hms/workbox` on dayman,
  layered on top of the upstream via `upstreamPath`

Always check `hostname` before running any host-specific build or
switch. Applying a foreign host config will break the system.

## Communication

- If anything is unclear, ask for clarification before proceeding
- Do not make assumptions about intent, architecture, or scope
- When there are multiple valid approaches, present the options
  and let me choose
- Keep responses concise — explain the why, not the obvious

## Workflow

- Research the codebase before writing code
- For non-trivial changes with genuinely unclear approach: plan
  first, confirm, then implement. For straightforward changes,
  act directly
- Verify your work — run the build, tests, or linter after changes
- When something fails, investigate the root cause instead of
  retrying blindly

## Git and Commits

- Follow the project's existing commit message style
- Only commit when I explicitly ask
- Do not push unless I explicitly ask
- Stage specific files, not `git add .`

## Code Quality

- Match the existing style and patterns of the codebase
- Do not add comments, docstrings, or type annotations to code
  you did not change
- Do not refactor, rename, or "improve" surrounding code unless
  asked
- Prefer simple, obvious solutions over clever abstractions
- Leave linting and formatting to tooling — do not manually fix
  style issues that a formatter handles

## Secrets and Security

- Never commit tokens, keys, or credentials
- On these systems, secrets are managed via 1Password / opnix
  under `/var/lib/opnix/secrets/`
- Validate inputs at system boundaries, trust internal code

## Environment Context

- OS: NixOS (flake-based, x86_64-linux)
- Shell environments: direnv + nix develop
- These are personal machines, not shared servers
