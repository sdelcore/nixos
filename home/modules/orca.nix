{
  config,
  lib,
  pkgs,
  ...
}:
let
  localBin = "$HOME/.local/bin";
  orcaDir = "$HOME/.local/share/orca";
in
{
  home.sessionPath = [ localBin ];

  # Store Orca in the writable home directory for its built-in stable-channel
  # updater, then execute the AppImage through appimage-run on NixOS.
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
