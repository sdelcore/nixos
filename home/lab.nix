{ config, pkgs, ... }:

{
    imports = [
        ./modules/base.nix
        ./modules/cli.nix
    ];
}
