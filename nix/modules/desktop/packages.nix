{ pkgs, ... }: {
  environment.localBinInPath = true;

  environment.systemPackages = with pkgs; [
    # Themes
    numix-cursor-theme
    numix-gtk-theme
    numix-icon-theme
    numix-icon-theme-square
    flat-remix-gtk

    # Media
    unstable.spotify
    unstable.vlc

    # Communication
    teams-for-linux
    (let
      teams-work-script = pkgs.writeShellScriptBin "teams-work" ''
        exec ${pkgs.teams-for-linux}/bin/teams-for-linux \
          --class=teams-work \
          --user-data-dir="$HOME/.config/teams-profile-work" \
          "$@"
      '';
    in pkgs.symlinkJoin {
      name = "teams-work";
      paths = [ teams-work-script ];
      postBuild = ''
        mkdir -p $out/share/applications
        cat > $out/share/applications/teams-work.desktop <<EOF
        [Desktop Entry]
        Name=Teams (Work)
        Comment=Microsoft Teams - Work Profile
        Exec=${teams-work-script}/bin/teams-work
        Icon=teams-for-linux
        Terminal=false
        Type=Application
        Categories=Network;InstantMessaging;
        StartupWMClass=teams-work
        EOF
      '';
    })
    unstable.signal-desktop
    unstable.vesktop

    # Browsers
    firefox-bin
    google-chrome

    # Tools
    unstable.vscode.fhs
    (pkgs.writeShellScriptBin "prusa-slicer" ''
      unset __GLX_VENDOR_LIBRARY_NAME
      exec ${pkgs.prusa-slicer}/bin/prusa-slicer "$@"
    '')
    cliphist
    flameshot
    normcap
    unstable.logiops
    gnome-disk-utility

    # Virtual machines
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    virtio-win
    win-spice

    # Desktop integration
    mesa
    openconnect
    pipenv
    pulseaudio
    qt6.qtwayland
    wl-clipboard
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk

    # OBS with plugins
    (pkgs.wrapOBS {
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-pipewire-audio-capture
      ];
    })
  ];
}
