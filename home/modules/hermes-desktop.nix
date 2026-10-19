{ inputs, pkgs, ... }:
{
  home.packages = [ inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.desktop ];
}
