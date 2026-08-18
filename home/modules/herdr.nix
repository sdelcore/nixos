{ lib, pkgs, ... }:
let
  localBin = "$HOME/.local/bin";
  tabTitleSyncRef = "409dd7050fbf105df7d406ca3396c563c65cc14d";
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
          git
          openssh
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

  # Mirror OMP's generated OSC terminal title into the containing Herdr tab.
  home.activation.installHerdrTabTitleSync = lib.hm.dag.entryAfter [ "installHerdr" ] ''
    export PATH="${localBin}:${lib.makeBinPath (with pkgs; [ coreutils git jq openssh ])}:$PATH"
    installedRef=$(${localBin}/herdr plugin list --plugin tab-title-sync --json 2>/dev/null \
      | ${pkgs.jq}/bin/jq -r '.result.plugins[0].source.resolved_commit // empty' \
      || true)
    if [ "$installedRef" != "${tabTitleSyncRef}" ]; then
      echo "Installing Herdr tab title sync at ${tabTitleSyncRef}..."
      if ! GIT_CONFIG_GLOBAL=/dev/null ${localBin}/herdr plugin install \
        lucasleon2107/herdr-tab-title-sync --ref "${tabTitleSyncRef}" --yes; then
        echo "warning: failed to install Herdr tab title sync; keeping the existing plugin"
      fi
    else
      echo "Herdr tab title sync is already at ${tabTitleSyncRef}"
    fi
  '';
}
