{ inputs, pkgs, ... }:

let
  unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };
in
{
  # LM Studio GUI + bundled `lms` CLI. Pulled from unstable to track upstream
  # closely (stable nixpkgs lags by several minor versions).
  # Run the GUI at least once before `lms` will work.
  home.packages = [ unstable.lmstudio ];
}
