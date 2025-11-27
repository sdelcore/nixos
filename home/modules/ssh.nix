{ pkgs, ... }:

{
  # SSH client configuration
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
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
