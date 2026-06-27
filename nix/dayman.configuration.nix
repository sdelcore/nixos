{ ... }: {
  imports = [
    ./hardware/dayman.nix
    ./disks/dayman.nix
    ./profiles/base.nix
    ./profiles/desktop.nix
    ./profiles/development.nix
    ./profiles/laptop.nix
    ./modules/software/droidcode.nix
  ];

  networking.hostName = "dayman";

  # Offload heavy builds onto nightman over SSH; falls back to local if it's down.
  nix.distributedBuilds = true;
  nix.buildMachines = [{
    hostName = "nightman.tap";
    sshUser = "sdelcore";
    sshKey = "/home/sdelcore/.ssh/id_rsa";
    systems = [ "x86_64-linux" ];
    maxJobs = 8;
    speedFactor = 2;
    supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
  }];
  nix.settings.builders-use-substitutes = true;

  system.stateVersion = "24.05";
}
