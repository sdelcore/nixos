{...}: {
  programs.zellij = {
    enable = true;
    enableZshIntegration = false; # Custom integration in zsh.nix with guards
    settings = {
        theme = "catppuccin-macchiato";
    };
  };

  xdg.configFile = {
    "zellij/config.kdl".text = # kdl
      ''
        default_mode "locked"
        show_startup_tips false
        keybinds {
          unbind "Ctrl q"
        }
      '';
  };
}