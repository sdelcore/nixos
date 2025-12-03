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
    unstable.signal-desktop
    unstable.vesktop

    # Browsers
    firefox-bin
    google-chrome

    # Tools
    unstable.vscode.fhs
    prusa-slicer
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
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    })
  ];
}
