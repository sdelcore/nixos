---
name: nix-switch
description: Apply the NixOS configuration to the current host. Requires sudo.
disable-model-invocation: true
allowed-tools: Bash
---

Apply the NixOS configuration to the CURRENT host only.

## SAFETY: Host Check

1. Run `hostname` to get the current host.
2. If `$ARGUMENTS` is provided and does NOT match the current
   hostname, ABORT. Tell the user to use `just deploy <host> <ip>`
   for remote deployment. Switching to a foreign host config will
   break the system.

## Steps

1. Run `git status` and warn if there are unstaged or uncommitted
   changes in the flake directory — flakes only see tracked files.
2. Run the switch:

   ```bash
   just switch
   ```

   Or on workbox (downstream flake at `~/hms/workbox`):

   ```bash
   sudo nixos-rebuild switch --flake .#workbox
   ```

3. Report success, or the full error output on failure. Do not
   retry blindly; diagnose the root cause first.
