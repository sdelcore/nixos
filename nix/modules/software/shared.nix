{ inputs, pkgs, ... }:
{
  # `shared` deploy CLI for the self-hosted static-site platform (shared.tap).
  # Deploy a site dir:  shared deploy ./site --name <name>  ->  <name>.shared.tap
  # Also: `shared list`, `shared open <name>`.
  environment.systemPackages = [
    inputs.shared.packages.${pkgs.stdenv.hostPlatform.system}.shared
  ];

  # Default the CLI at the homelab server so no --server flag is needed. The CLI
  # otherwise defaults to localhost:8787 — override per-command for local dev.
  environment.sessionVariables.SHARED_SERVER = "http://shared.tap";
}
