{ lib, pkgs, ... }:
let
  localBin = "$HOME/.local/bin";
in
{
  home.sessionPath = [ localBin ];

  # Keep Herdr outside the Nix store so its native updater can install releases
  # without waiting for a flake update.
  home.activation.installHerdr = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${localBin}:${
      lib.makeBinPath (
        with pkgs;
        [
          curl
          coreutils
          gawk
        ]
      )
    }:$PATH"
    if [ ! -x "${localBin}/herdr" ]; then
      echo "Installing Herdr..."
      ${pkgs.curl}/bin/curl -fsSL https://herdr.dev/install.sh | \
        HERDR_INSTALL_DIR="${localBin}" ${pkgs.bash}/bin/bash
    else
      echo "Herdr is already installed at ${localBin}/herdr"
    fi
  '';
}
