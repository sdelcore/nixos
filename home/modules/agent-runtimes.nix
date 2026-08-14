{ config, lib, pkgs, ... }:
let
  localBin = "$HOME/.local/bin";
  orcaDir = "$HOME/.local/share/orca";
in
{
  home.sessionPath = [ localBin ];

  # Keep these fast-moving tools outside the Nix store so their native update
  # mechanisms can install releases without waiting for a flake update.
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

  # Orca's Linux release is an AppImage. Store it in the writable home
  # directory for Orca's built-in stable-channel updater, then execute it via
  # appimage-run because NixOS cannot run AppImages directly.
  home.activation.installOrca = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${
      lib.makeBinPath (
        with pkgs;
        [
          curl
          coreutils
        ]
      )
    }:$PATH"
    mkdir -p "${orcaDir}"
    if [ ! -x "${orcaDir}/orca.AppImage" ]; then
      echo "Installing Orca..."
      tmp="$(${pkgs.coreutils}/bin/mktemp "${orcaDir}/orca.AppImage.XXXXXX")"
      if ${pkgs.curl}/bin/curl -fL --retry 3 \
        https://github.com/stablyai/orca/releases/latest/download/orca-linux.AppImage \
        -o "$tmp"; then
        chmod +x "$tmp"
        mv "$tmp" "${orcaDir}/orca.AppImage"
      else
        rm -f "$tmp"
        exit 1
      fi
    else
      echo "Orca is already installed at ${orcaDir}/orca.AppImage"
    fi
  '';

  home.file.".local/bin/orca" = {
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      exec ${pkgs.appimage-run}/bin/appimage-run "$HOME/.local/share/orca/orca.AppImage" "$@"
    '';
  };

  xdg.desktopEntries.orca = {
    name = "Orca";
    genericName = "Agent Development Environment";
    comment = "Run coding agents in parallel worktrees";
    exec = "${config.home.homeDirectory}/.local/bin/orca %U";
    terminal = false;
    categories = [ "Development" ];
  };
}
