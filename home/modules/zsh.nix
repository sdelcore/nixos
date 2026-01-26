{pkgs, ...}: {
  # Catppuccin theme for starship
  catppuccin.starship.enable = true;

  # Zsh shell configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    #plugins = [
    #  {
    #    name = "fzf-tab";
    #    src = pkgs.fetchFromGitHub {
    #      owner = "Aloxaf";
    #      repo = "fzf-tab";
    #      rev = "c2b4aa5ad2532cca91f23908ac7f00efb7ff09c9";
    #      sha256 = "1b4pksrc573aklk71dn2zikiymsvq19bgvamrdffpf7azpq6kxl2";
    #    };
    #  }
    #];

    shellAliases = {
      cat = "bat";
      cc = "claude --dangerously-skip-permissions";

      ff = "fastfetch";

      # git
      gaa = "git add --all";
      gcam = "git commit --all --message";
      gcl = "git clone";
      gco = "git checkout";
      ggl = "git pull";
      ggp = "git push";

      htop = "btop";
      top = "btop";

      ld = "lazydocker";
      lg = "lazygit";

      repo = "cd $HOME/src";
      temp = "cd $HOME/Downloads/temp";

      v = "nvim";
      vi = "nvim";
      vim = "nvim";

      ls = "eza --icons always"; # default view
      ll = "eza -bhl --icons --group-directories-first"; # long list
      la = "eza -abhl --icons --group-directories-first"; # all list
      lt = "eza --tree --level=2 --icons"; # tree
    };

    initContent = ''
      # source home-manager session variables (unset guard to force re-source)
      unset __HM_SESS_VARS_SOURCED
      . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"

      # kubectl auto-complete
      source <(kubectl completion zsh)

      # bindings
      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word

      # open commands in $EDITOR with C-e
      autoload -z edit-command-line
      zle -N edit-command-line
      bindkey "^e" edit-command-line

      # Zellij auto-attach with guards to prevent spawning sessions from
      # non-interactive shells (e.g., OpenCode command execution)
      # Guards:
      #   - $ZELLIJ: not already inside Zellij
      #   - $- == *i*: shell is interactive
      #   - $TERM: terminal is set and not "dumb"
      #   - $INSIDE_EMACS/$VSCODE_INJECTION: not in IDE terminals
      if [[ -z "$ZELLIJ" && $- == *i* && -n "$TERM" && "$TERM" != "dumb" && -z "$INSIDE_EMACS" && -z "$VSCODE_INJECTION" ]]; then
        if [[ -n "$SSH_TTY" ]]; then
          export ZELLIJ_CONFIG_FILE="$HOME/.config/zellij/config-remote.kdl"
        fi
        eval "$(zellij setup --generate-auto-start zsh)"
      fi
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      directory = {
        style = "bold lavender";
      };
      aws = {
        disabled = true;
      };
      golang = {
        symbol = " ";
      };
      kubernetes = {
        disabled = false;
        style = "bold pink";
        symbol = "󱃾 ";
        format = "[$symbol$context( \($namespace\))]($style)";
        contexts = [
          {
            context_pattern = "arn:aws:eks:(?P<var_region>.*):(?P<var_account>[0-9]{12}):cluster/(?P<var_cluster>.*)";
            context_alias = "$var_cluster";
          }
        ];
      };
      lua = {
        symbol = " ";
      };
      package = {
        symbol = " ";
      };
      php = {
        symbol = " ";
      };
      python = {
        symbol = " ";
      };
      terraform = {
        symbol = " ";
      };
      right_format = "$kubernetes";
    };
  };
}
