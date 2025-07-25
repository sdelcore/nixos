{...}: {
  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
    settings = {
        theme = "catppuccin-macchiato";
    };
  };

  xdg.configFile = {
    "zellij/config.kdl".text = # kdl
      ''
        keybinds {
          unbind "Ctrl q"
        }
      '';
  };
}