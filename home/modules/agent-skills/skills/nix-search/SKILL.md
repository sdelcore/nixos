---
name: nix-search
description: Search for NixOS packages or configuration options.
allowed-tools: Bash, WebFetch
---

Search for NixOS packages or configuration options.

## Steps

If `$ARGUMENTS` looks like a package name (single identifier, no
dots):

```bash
nix search nixpkgs#$ARGUMENTS
```

If `$ARGUMENTS` looks like a NixOS option (contains dots, e.g.
`services.foo` or `programs.bar`), search for the option on
https://search.nixos.org/options.

If ambiguous, search both packages and options.

Present results concisely: name, version (if applicable), and a
one-line description. Do not dump the full search output.
