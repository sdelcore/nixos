{userConfig, ...}: {
  # Install git via home-manager module
  catppuccin.delta.enable = false;
  
  programs.delta = {
    enable = true;
    options = {
      keep-plus-minus-markers = true;
      light = false;
      line-numbers = true;
      navigate = true;
      width = 280;
    };
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      pull.rebase = "true";
      url."ssh://git@github.com/".insteadOf = "https://github.com/";
    };
    includes = [
      {
        # Default for all git repos
        condition = "gitdir:~/";
        contents = {
          user = {
            name = "Spencer Delcore";
            email = "sdelcore@gmail.com";
          };
        };
      }
      {
        # HMS repos override
        condition = "gitdir:~/hms/";
        contents = {
          user = {
            name = "Spencer Delcore";
            email = "spde@hms.se";
          };
        };
      }
      {
        # Wiselab repos
        condition = "gitdir:~/wiselab/";
        contents = {
          user = {
            name = "Spencer Delcore";
            email = "sdelcore@uwaterloo.ca";
          };
        };
      }
    ];
  };
}
