{ config, pkgs,... }:

{
  imports = [  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    
    age = {
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      keyFile = "/var/lib/sops/age/keys.txt";
      generateKey = true;
    };

    secrets = {
      user_passwd = {
        neededForUsers = true;
      };
      user_name = {
        #owner = config.users.users.sometestservice.name;
      };
    };
  };

  # we can create a service that does something with a secret since we can't use secret during build time
  #systemd.services."sometestservice" = {
  #  script = ''
  #    echo "Hello $(cat ${config.sops.secrets."user_name".path})
  #    located in ${config.sops.secrets."user_name".path}
  #    " > /var/lib/sometestservice/testfile
  #  '';
  #  serviceConfig = {
  #    User = "sometestservice";
  #    WorkingDirectory = "/var/lib/sometestservice";
  #  };
  #};

  #users.users.sometestservice = {
  #  home = "/var/lib/sometestservice";
  #  createHome = true;
  #  isSystemUser = true;
  #  group = "sometestservice";
  #};
  #users.groups.sometestservice = {};

  environment.systemPackages = with pkgs; [
    age
    ssh-to-age
  ];
}