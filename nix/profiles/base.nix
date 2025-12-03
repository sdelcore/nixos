{ ... }: {
  imports = [
    ../modules/default.nix
    ../modules/common/boot.nix
    ../modules/common/network.nix
    ../modules/common/performance.nix
    ../modules/common/power-management.nix
    ../users/default.nix
  ];
}
