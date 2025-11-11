# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ ];
  users.groups.docker = {};
  users.users.sdelcore = {    
    isNormalUser = true;
    description = "Spencer Delcore";
    extraGroups = [ "networkmanager" "wheel" "kvm" "libvirtd" "docker" "storage" "dialout" "seat" "video" "audio"];
    uid = 1000;

    shell = pkgs.zsh;
    
    packages = with pkgs; [
      
    ];
    
    #hashedPasswordFile = config.sops.secrets.user_passwd.path;
    initialPassword = "asd"; # until we figure out sops properly with deployment, just set the initial password, change after installation with `passwd`

    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDbCTR4sfbJyTfM/jYhVXZsPMU2QoEib0usUVtmIjU+tjohaZZ8X6maMT32y7V5Ii91TiOxILkh+jd3nbc5svO27li4bjz704Mm6IfNuetv0+YbsfjngLk/VcNBpUbJskEoCh+oiq5JCo9wXmmNZEGaq4LM/FKsnRnTiGlnjeJ9d892sps2eRnjDKLRtO1K+k7C/+UmIOp7qU1CPD7wFys7arIM6m+DdDnNR47syLFJaQA3TxCw01+zG0hNNAMFU1g5Ck41mVQYXAIl5fjGbM+C6jNSl0f64TcZv8+G28uN/uvt/cJYwEH1jC640ieRrStVeYBiUlUuco4Eb1SVIabVNkb2je9wI1qw2VoDjXq+bQFlBHzMj4mPESNVRmrfEg0+KXFvYKvKcOMlYsSfAtLujKa6/4z3Ai3eQQlwo4mZdULe8AY1pbJ4Hb2o/NF8zumsXDci2pYUMzNmWOSonuS+MYIvNEMY5H3sBMC9jkLfvNbm5AA6jadAr/Jkb3Lu168ip8QTQAz/pIecyXQKWXN9bwgMvU3ZxSaHOWL0loeRUiBdAmqJQEQgh7ANZoLIL3uqtaYPPT0pBMMm3V4fEESJ6uWq+lZNFs1DqehMWaBRZ1u86qLZqx8kf46dQB+oW2mWtU2/Re4Ur0cBWR/L2VimwmlB2epsRJT1Lz0kA+jnUw=="
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILt/+MqQJoCw5xNAyqBM8taSJAwb+nTuTQXEHx/yGCRs"
    ];
  };
  
  nix.settings.trusted-users = [ "root" "@wheel" ];
  security.sudo.wheelNeedsPassword = false;
  security.sudo.extraRules = [
    {
      users = [ "sdelcore" ];
      commands = [ { command = "ALL"; options = [ "NOPASSWD" "SETENV" ]; } ]; 
    }
  ];

}
