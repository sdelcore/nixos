{lib, config, pkgs, ...}: 
let
  cfg = config.hyprland;
in {
  imports = [
    ./../clipboard.nix
    ./../kanshi.nix
    ./../swappy.nix
    ./../swaync.nix
    ./../waybar.nix
    ./../rofi.nix
    ./../xdg.nix
    ./../gtk.nix
  ];

  options.hyprland = {
    configSource = lib.mkOption {
      type = lib.types.path;
      description = "Path to the hyprland configuration directory";
    };
    wallpaper = lib.mkOption {
      type = lib.types.path;
      description = "Path to the wallpaper image";
    };
    wallpaperLock = lib.mkOption {
      type = lib.types.path;
      description = "Path to the lock screen wallpaper image";
    };
    enableSuspend = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable automatic suspend after 30 minutes";
    };
  };

  config = {

  # Source hyprland config from the home-manager store
  xdg.configFile = {
    "hypr/hyprland.conf".source = "${cfg.configSource}/hyprland.conf";
    "hypr/common.conf".source = ./../../configs/hypr/common.conf;

    "hypr/hyprpaper.conf".text = ''
      splash = false
      preload = ${cfg.wallpaper}
      wallpaper = , ${cfg.wallpaper}
    '';

    "hypr/hypridle.conf".text = ''
      general {
        lock_cmd = pidof hyprlock || hyprlock
        before_sleep_cmd = loginctl lock-session
        after_sleep_cmd = hyprctl dispatch dpms on
      }

      listener {
        timeout = 300
        on-timeout = brightnessctl -s set 10         # set monitor backlight to minimum, avoid 0 on OLED monitor.
        on-resume = brightnessctl -r                 # monitor backlight restore.
      }

      # turn off keyboard backlight, comment out this section if you dont have a keyboard backlight.
      listener { 
        timeout = 300
        on-timeout = brightnessctl -sd rgb:kbd_backlight set 0 # turn off keyboard backlight.
        on-resume = brightnessctl -rd rgb:kbd_backlight        # turn on keyboard backlight.
      }

      listener {
        timeout = 600
        on-timeout = loginctl lock-session            # lock screen when timeout has passed
      }

      listener {
        timeout = 900                                 
        on-timeout = hyprctl dispatch dpms off        # screen off when timeout has passed
        on-resume = hyprctl dispatch dpms on          # screen on when activity is detected after timeout has fired.
      }

      ${lib.optionalString cfg.enableSuspend ''
      listener {
        timeout = 1800                                # 30min
        on-timeout = systemctl suspend                # suspend pc
      }
      ''}
    '';

    "hypr/hyprlock.conf".text = ''
      background {
          monitor =
          path = ${cfg.wallpaperLock}
          blur_passes = 3
          contrast = 0.8916
          brightness = 0.8172
          vibrancy = 0.1696
          vibrancy_darkness = 0.0
      }

      general {
          no_fade_in = false
          grace = 0
          disable_loading_bar = true
      }

      input-field {
          monitor = 
          size = 100, 30
          outline_thickness = 2
          dots_size = 0.2 # Scale of input-field height, 0.2 - 0.8
          dots_spacing = 0.2 # Scale of dots' absolute size, 0.0 - 1.0
          dots_center = true
          outer_color = rgba(0, 0, 0, 0)
          inner_color = rgba(0, 0, 0, 0.5)
          font_color = rgb(200, 200, 200)
          fade_on_empty = false
          capslock_color = -1
          placeholder_text = <i><span foreground="##e6e9ef">Password</span></i>
          fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i>
          hide_input = false
          position = 0, -120
          halign = center
          valign = center
      }

      # Date
      label {
        monitor = 
        text = cmd[update:1000] echo "<span>$(date '+%A, %d %B')</span>"
        color = rgba(255, 255, 255, 0.8)
        font_size = 20
        font_family = JetBrains Mono Nerd Font Mono ExtraBold
        position = 0, -400
        halign = center
        valign = top
      }

      # Time
      label {
          monitor = 
          text = cmd[update:1000] echo "<span>$(date '+%I:%M')</span>"
          color = rgba(255, 255, 255, 0.8)
          font_size = 120
          font_family = JetBrains Mono Nerd Font Mono ExtraBold
          position = 0, -400
          halign = center
          valign = top
      }

    '';
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";
  };
  
  dconf.enable = true;
  dconf.settings = {
    "org/blueman/general" = {
      "plugin-list" = lib.mkForce ["!StatusNotifierItem"];
    };

    "org/blueman/plugins/powermanager" = {
      "auto-power-on" = true;
    };

    "org/gnome/calculator" = {
      "accuracy" = 9;
      "angle-units" = "degrees";
      "base" = 10;
      "button-mode" = "basic";
      "number-format" = "automatic";
      "show-thousands" = false;
      "show-zeroes" = false;
      "source-currency" = "";
      "source-units" = "degree";
      "target-currency" = "";
      "target-units" = "radian";
      "window-maximized" = false;
    };

    "org/gnome/desktop/interface" = {
      "color-scheme" = "prefer-dark";
      "cursor-theme" = "Yaru";
      "font-name" = "Roboto 11";
      "icon-theme" = "Tela-circle-dark";
    };

    "org/gnome/desktop/wm/preferences" = {
      "button-layout" = lib.mkForce "";
    };

    "org/gnome/nautilus/preferences" = {
      "default-folder-viewer" = "list-view";
      "migrated-gtk-settings" = true;
      "search-filter-time-type" = "last_modified";
      "search-view" = "list-view";
    };

    "org/gnome/nm-applet" = {
      "disable-connected-notifications" = true;
      "disable-vpn-notifications" = true;
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      "show-hidden" = true;
    };

    "org/gtk/settings/file-chooser" = {
      "date-format" = "regular";
      "location-mode" = "path-bar";
      "show-hidden" = true;
      "show-size-column" = true;
      "show-type-column" = true;
      "sort-column" = "name";
      "sort-directories-first" = false;
      "sort-order" = "ascending";
      "type-format" = "category";
      "view-type" = "list";
    };
  };

  home.sessionVariables = {
    GBM_BACKEND = "nvidia-drm";
    LIBSEAT_BACKEND = "logind";
    LIBVA_DRIVER_NAME = "nvidia";
    QT_QPA_PLATFORM = "wayland";
    WLR_NO_HARDWARE_CURSORS = "1";
    XDG_SESSION_TYPE = "wayland";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __GL_GSYNC_ALLOWED = "1";
  };
  };
}