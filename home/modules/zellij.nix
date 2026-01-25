{...}: {
  programs.zellij = {
    enable = true;
    enableZshIntegration = false; # Custom integration in zsh.nix with guards
    settings = {
        theme = "catppuccin-macchiato";
    };
  };

  # Local config (Ctrl+g)
  xdg.configFile."zellij/config.kdl".text = ''
    default_mode "locked"
    show_startup_tips false
    keybinds {
      unbind "Ctrl q"
      locked {
        bind "Ctrl g" { SwitchToMode "normal"; }
      }
      shared_except "locked" {
        bind "Ctrl g" { SwitchToMode "locked"; }
      }
    }
  '';

  # Remote config (Alt+g)
  xdg.configFile."zellij/config-remote.kdl".text = ''
    default_mode "locked"
    show_startup_tips false
    keybinds {
      unbind "Ctrl q"
      locked {
        bind "Alt g" { SwitchToMode "normal"; }
      }
      shared_except "locked" {
        bind "Alt g" { SwitchToMode "locked"; }
      }
    }
  '';
}