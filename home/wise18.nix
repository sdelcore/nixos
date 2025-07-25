{ config, pkgs, ... }:

{
    imports = [
        ./modules/base.nix
        ./modules/common.nix
    ];

    # wise18 is a server, so no special GUI configurations needed
}
