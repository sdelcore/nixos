{ pkgs, ... }:

{
  # SSH client configuration
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    forwardAgent = true;
    # Include user-writable config for VS Code and other tools
    includes = [ "~/.ssh/config.d/*" ];
    matchBlocks = {
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
    agents = [ "ssh" ];
    # Quiet mode - don't print banner
    extraFlags = [ "--quiet" ];
  };
}
