---
name: nix-build
description: Build the NixOS system configuration without switching. Use to verify changes compile.
allowed-tools: Bash
---

Build a NixOS host configuration without applying it.

## Steps

1. If `$ARGUMENTS` is empty, build for the current host — look up
   hostname first with `hostname` and pass it to `just build`.
2. If `$ARGUMENTS` names a host, build that one.

From the upstream `nixos/` flake directory:

```bash
just build <hostname>
```

On workbox (downstream flake at `~/hms/workbox`):

```bash
nix build .#nixosConfigurations.workbox.config.system.build.toplevel
```

Report the store path on success. On failure, show the full error
output and suggest fixes. Do NOT declare success until the build
exits 0.
