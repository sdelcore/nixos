{ config, pkgs, ... }:

{
  imports =
  [
    
  ];

  home-manager.users.sdelcore = {

  };

  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  services.xserver = {
    enable = true;
    xkb.layout = "us";
    xkb.variant = "";
    excludePackages = with pkgs; [xterm];
    displayManager.gdm.enable = true;
  };

  environment.localBinInPath = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #iconpack-obsidian
    numix-cursor-theme
    numix-gtk-theme
    numix-icon-theme
    numix-icon-theme-square
    flat-remix-gtk

    # media
    unstable.spotify
    unstable.vlc

    # gaming
    unstable.steam

    # comms
    teams-for-linux
    unstable.signal-desktop
    unstable.vesktop

    # browsers
    firefox-bin
    google-chrome

    # tools
    unstable.vscode.fhs
    
    # widevine-cdm # Temporarily disabled - download source is broken
    
    prusa-slicer
    cliphist
    flameshot
    normcap
    unstable.logiops
    gnome-disk-utility

    # vms
    virt-manager
    virt-viewer
    spice 
    spice-gtk
    spice-protocol
    virtio-win
    win-spice

    # to clean up
    mesa
    openconnect
    pipenv
    pulseaudio
    qt6.qtwayland
    wl-clipboard
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk

    (pkgs.wrapOBS {
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
    ];
  })
  ];

  nixpkgs.config.firefox.enableDrmSupport = true;

  # Nerd Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.droid-sans-mono
    nerd-fonts.fira-code
    nerd-fonts.dejavu-sans-mono
    nerd-fonts.meslo-lg
    nerd-fonts.jetbrains-mono
    roboto
  ];

}
