---
name: nix-check
description: Evaluate the flake and run checks to validate the configuration.
allowed-tools: Bash
---

Validate the current flake.

## Steps

1. `nix flake check` — run any defined checks
2. `nix flake show` — verify the flake evaluates cleanly

If `$ARGUMENTS` is `eval-only`, skip `nix flake check` and only run
`nix flake show`.

Report each step's result. On failure, analyze the error and suggest
fixes based on Nix conventions (missing `git add`, attribute typos,
missing inputs, etc.).
