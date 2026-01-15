{ config, pkgs, ... }:

{
  home-manager.users.sdelcore = {
    # Gnome Settings
    # See https://the-empire.systems/nixos-gnome-settings-and-keyboard-shortcuts
    # You can check all of your settings by running `dconf dump / > old-conf.txt`
    dconf.enable = true;
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
            autoconnect = ["qemu:///system"];
            uris = ["qemu:///system"];
        };
      "org/gnome/shell" = {
        disable-user-extensions = false;
        disabled-extensions = [
          "gnordvpn-local@isopolito"
          "window-list@gnome-shell-extensions.gcampax.github.com"
        ];
        enabled-extensions = [
          #"apps-menu@gnome-shell-extensions.gcampax.github.com"
          #"places-menu@gnome-shell-extensions.gcampax.github.com"
          #"drive-menu@gnome-shell-extensions.gcampax.github.com"
          "user-theme@gnome-shell-extensions.gcampax.github.com"
          "windowsNavigator@gnome-shell-extensions.gcampax.github.com"
          "workspace-indicator@gnome-shell-extensions.gcampax.github.com"
          "appindicatorsupport@rgcjonas.gmail.com"
          "remmina-search-provider@alexmurray.github.com"
          "gsconnect@andyholmes.github.io"
          "dash-to-dock@micxgx.gmail.com"
          #"native-window-placement@gnome-shell-extensions.gcampax.github.com"
          "just-perfection-desktop@just-perfection"
          #"caffeine@patapon.info"
          #"hidetopbar@mathieu.bidon.ca"
          #"arcmenu@arcmenu.com"
          "firefox-pip@bennypowers.com"
        ];
        favorite-apps = [
            "firefox.desktop"
            "org.gnome.Nautilus.desktop"
            "com.gexperts.Tilix.desktop"
            "obsidian.desktop"
            #"thunderbird.desktop"
            #"io.vikunja.Vikunja.desktop"
            #"@joplinapp-desktop.desktop" 
            #"com.github.zadam.trilium.desktop" 
            #"codium.desktop" 
            #"writer.desktop" 
            #"calc.desktop" 
            #"PrusaSlicer.desktop" 
            #"signal-desktop.desktop" 
            #"org.gnome.Console.desktop" 
            #"org.remmina.Remmina.desktop" 
            #"bitwarden.desktop"
        ]; 
        remember-mount-password = false;
        welcome-dialog-last-shown-version = "42.4";
      };

      "org/gnome/mutter" = {
        dynamic-workspaces = true;
        edge-tiling = true;
        overlay-key = "Super_L";
        center-new-windows = true;
      };

      
      "org/gnome/settings-daemon/plugins/color" = {
        night-light-enabled = true; #note that this seems to be broken and only works with one monitor.
      };

      "org/gnome/desktop/interface" = {
        clock-format = "12h";
        clock-show-seconds = false;
        clock-show-weekday = true;
        color-scheme = "prefer-dark";
        enable-hot-corners = true;
        font-antialiasing = "grayscale";
        font-hinting = "slight";
        font-name = "Cantarell 11";
        monospace-font-name = "DejaVuSansM Nerd Font Mono 10";
        cursor-theme = "Numix-Cursor-Light";
        gtk-theme = "Adwaita-dark";
        icon-theme = "Numix-Square";
        toolkit-accessibility = true;
        show-battery-percentage = true;
      };

      "org/gnome/shell/extensions/gsconnect" = {
        enabled = true;
        show-indicators = true;
      };

      "org/gnome/desktop/wm/preferences" = {
        action-middle-click-titlebar = "minimize";
        button-layout = "appmenu:minimize,maximize,close";
        #num-workspaces = 10;
      };

      "org/gnome/shell/extensions/just-perfection" = {
        accessibility-menu = false;
        activities-button = true;
        app-menu = true;
        app-menu-icon = true;
        dash-icon-size = 32;
        hot-corner = true;
        keyboard-layout = true;
        panel = true;
        panel-arrow = false;
        panel-button-padding-size = 5;
        panel-corner-size = 1;
        panel-icon-size = 0;
        panel-in-overview = true;
        panel-indicator-padding-size = 0;
        ripple-box = true;
        search = true;
        show-apps-button = true;
        startup-status = 0;
        theme = true;
        top-panel-position = 0;
        window-demands-attention-focus = true;
        window-picker-icon = true;
        workspace = true;
        workspace-switcher-should-show = true;
        workspace-switcher-size = 0;
        workspace-wrap-around = true;
        workspaces-in-app-grid = true;
      };

      "org/gnome/desktop/peripherals/touchpad" = {
        tap-to-click = true;
        two-finger-scrolling-enabled = true;
      };

      "org/gnome/deskttop/calendar" = {
        show-weekdate = true;
      };

      "org/gnome/shell/extensions/dash-to-dock" = {
        always-center-icons = false;
        animation-time = 0.10000000000000002;
        apply-custom-theme = true;
        autohide-in-fullscreen = false;
        background-opacity = 0.80000000000000004;
        custom-theme-shrink = true;
        click-action = "focus-minimize-or-previews";
        dash-max-icon-size = 32;
        dock-position = "BOTTOM";
        extend-height = true;
        height-fraction = 0.90000000000000002;
        intellihide-mode = "FOCUS_APPLICATION_WINDOWS";
        isolate-monitors = false;
        multi-monitor = true;
        preferred-monitor = -2;
        preferred-monitor-by-connector = "eDP-1";
        preview-size-scale= "0.0";
        scroll-action = "switch-workspace";
        show-apps-at-top = true;
        show-mounts-network = false;
        show-mounts = false;
        show-trash = false;
      };

      "org/gnome/desktop/search-providers" = {
        enabled = "org.gnome.Weather.desktop";
      };

      #"apps/gnome/gnome-terminal/profiles/Default/cursor_shape" = "ibeam";

      # Gnome Remote Desktop
      "org/gnome/desktop/remote-desktop/rdp" = {
        enable = true ;
        tls-cert = "/home/sdelcore/.local/share/gnome-remote-desktop/rdp-tls.crt";
        tls-key = "/home/sdelcore/.local/share/gnome-remote-desktop/rdp-tls.key";
        view-only = false;
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        "custom-keybindings" = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8/"
        ];
        "screensaver" = ["<Alt><Ctrl>l"];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        "binding" = "<Control>space";
        "command" = "rofi -show drun";
        "name" = "Rofi";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" =
      {
        binding = "Print"; # printscrn key
        command = "flameshot gui";
        name = "flameshot";
      };
    };

    # Wayland, X, etc. support for session vars
    systemd.user.sessionVariables = config.home-manager.users.sdelcore.home.sessionVariables;

  }; # End of Home Manager
  
  services.xserver.desktopManager.gnome = {
    enable = true;
    extraGSettingsOverridePackages = [
      pkgs.nautilus-open-any-terminal
    ];
  };

  programs.dconf.enable = true;
  environment.variables.GTK_THEME = "Adwaita:dark";

  # Gnome Remote Desktop
  services.gnome.gnome-remote-desktop.enable = true;

  # Gnome Sushi Previewer
  services.gnome.sushi.enable = true; 

  # Authentication Services for Gnome
  programs.seahorse.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  security.pam.services.login.enableGnomeKeyring = true; 

  # Install Gnome-Specific Apps
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nautilus-open-any-terminal
    gedit
    gnome-remote-desktop
    gnomeExtensions.dash-to-dock
    gnomeExtensions.appindicator
    gnome-software
    gnome-extension-manager
    gnomeExtensions.gsconnect
    gnome-tweaks
    gnome-podcasts
    gnomeExtensions.just-perfection
    gnomeExtensions.arcmenu
    nemo-with-extensions
    gnomeExtensions.blur-my-shell
    dconf-editor
    gnomeExtensions.forge
    gnomeExtensions.paperwm
    gnomeExtensions.freon
    gnomeExtensions.vitals
  ];

  # Get Gnome Settings Daemon running for gnome-shell extensions.
  services.udev.packages = with pkgs; [ gnome-settings-daemon ];

}
