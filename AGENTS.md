# Repository instructions

See [README.md](README.md) for project, host, command, and state context.

## Operational gotchas

- Never activate a NixOS configuration without permission in the current conversation.
- Run `hostname` before any host-named build or activation command.
- `just provision` wipes its target; use `just deploy` for remote hosts.
- Never commit secrets or materialized secret values.
- Nix flakes only see tracked files; track new source files before building.
