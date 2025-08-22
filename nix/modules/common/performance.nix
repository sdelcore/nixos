{ config, lib, pkgs, ... }:

{
  # Enable zswap for compressed memory
  boot.kernelParams = [
    "zswap.enabled=1"
    "zswap.compressor=zstd"
    "zswap.max_pool_percent=20"
    "zswap.zpool=z3fold"
  ];

  # Enable zram swap device
  zramSwap = {
    enable = false;
    algorithm = "zstd";
    memoryPercent = 20; 
    priority = 100; # Higher priority than disk swap
  };

  # Configure IO scheduler for SSDs
  # Use mq-deadline for SSDs/NVMe for better latency
  services.udev.extraRules = ''
    # Set mq-deadline scheduler for NVMe devices
    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="mq-deadline"
    # Set mq-deadline scheduler for SATA SSDs
    ACTION=="add|change", KERNEL=="sd[a-z]|sd[a-z][a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
    # Set bfq scheduler for HDDs
    ACTION=="add|change", KERNEL=="sd[a-z]|sd[a-z][a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
  '';

  # Enable periodic TRIM for SSDs
  services.fstrim = {
    enable = false;
    interval = "weekly"; # Run TRIM weekly
  };

  # Additional performance optimizations
  boot.kernel.sysctl = {
    "vm.swappiness" = 20;
    
    # Optimize for SSDs
    "vm.dirty_ratio" = 15;
    "vm.dirty_background_ratio" = 5;
    
    # Enable transparent hugepages for better memory performance
    "vm.transparent_hugepages" = "madvise";
  };

  # CPU frequency governor - use powersave for laptops, performance for desktops
  # This can be overridden in machine-specific configs
  # powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}