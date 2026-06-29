{ inputs, pkgs, ... }:
{
  # `shared` deploy CLI for the self-hosted static-site platform (shared.tap).
  # Deploy a site dir:  shared deploy ./site --name <name>  ->  <name>.shared.tap
  # Also: `shared list`, `shared open <name>`.
  environment.systemPackages = [
    inputs.shared.packages.${pkgs.stdenv.hostPlatform.system}.shared
  ];
}
