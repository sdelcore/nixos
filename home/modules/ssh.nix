{ pkgs, ... }:

{
  # SSH client configuration
  programs.ssh = {
    enable = true;
    # Include user-writable config for VS Code and other tools
    includes = [ "~/.ssh/config.d/*" ];
    matchBlocks = {
      "*" = {
        extraOptions = {
          AddKeysToAgent = "yes";
        };
        forwardAgent = true;
      };
      "nightman" = {
        hostname = "nightman.tap";
        user = "sdelcore";
      };
    };
  };

  # Keychain manages ssh-agent and loads keys at shell startup
  programs.keychain = {
    enable = true;
    keys = [ "id_rsa" ];
    # Quiet mode - don't print banner
    extraFlags = [ "--quiet" ];
  };
}
