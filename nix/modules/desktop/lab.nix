{pkgs, ...}: {
  # ============================================================
  # Minimal desktop environment for lab (SBC)
  # Hyprland + essential packages + fonts, no heavy apps
  # ============================================================

  # Call dbus-update-activation-environment on login
  services.xserver.updateDbusEnvironment = true;

  # Enables support for Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Enable Bluetooth support
  services.blueman.enable = true;

  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Enable XDG portals for Hyprland
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Enable security services
  services.gnome.gnome-keyring.enable = true;
  services.gnome.gcr-ssh-agent.enable = false;
  security.polkit.enable = true;
  security.pam.services.gdm.enableGnomeKeyring = true;

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
    };
  };

  # Enable Ozone Wayland support in Chromium and Electron based applications
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XCURSOR_SIZE = "24";
    XCURSOR_THEME = "Yaru";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };

  programs.seahorse.enable = true;

  programs.ssh = {
    startAgent = true;
    enableAskPassword = true;
    askPassword = "${pkgs.lxqt.lxqt-openssh-askpass}/bin/lxqt-openssh-askpass";
  };

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  programs.xfconf.enable = true;
  services.tumbler.enable = true;

  # ============================================================
  # Display / login services
  # ============================================================

  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  services.xserver = {
    enable = true;
    xkb.layout = "us";
    xkb.variant = "";
    excludePackages = with pkgs; [ xterm ];
  };

  services.displayManager.gdm.enable = true;

  nixpkgs.config.firefox.enableDrmSupport = true;

  # ============================================================
  # Fonts
  # ============================================================

  fonts.packages = with pkgs; [
    nerd-fonts.droid-sans-mono
    nerd-fonts.fira-code
    nerd-fonts.dejavu-sans-mono
    nerd-fonts.meslo-lg
    nerd-fonts.jetbrains-mono
    roboto
  ];

  # ============================================================
  # Packages — minimal desktop integration + Hyprland essentials
  # ============================================================

  environment.systemPackages = with pkgs; [
    # Desktop integration
    mesa
    wl-clipboard
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
    qt6.qtwayland
    pulseaudio
    cliphist

    # Hyprland packages
    brightnessctl
    grim
    hypridle
    hyprlock
    hyprpaper
    libnotify
    networkmanagerapplet
    pamixer
    pavucontrol
    slurp
    wlr-randr
    wlsunset
    polkit_gnome
    lxqt.lxqt-openssh-askpass
  ];
}
