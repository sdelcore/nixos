{pkgs, ...}: {
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
  # Note: hyprlock PAM is configured in yubikey.nix with U2F support
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
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  # List of Hyprland specific packages
  environment.systemPackages = with pkgs; [
    gnome-text-editor
    file-roller # archive manager
    gnome-calculator
    nemo
    pomodoro
    seahorse # keyring manager
    totem # Video player
    loupe # image viewer
    polkit_gnome
    lxqt.lxqt-openssh-askpass

    brightnessctl
    grim
    hypridle
    hyprlock
    hyprpaper
    hyprpicker
    libnotify
    networkmanagerapplet
    pamixer
    pavucontrol
    slurp
    swappy
    tesseract
    wf-recorder
    wlr-randr
    wlsunset
    mlocate
  ];
}
