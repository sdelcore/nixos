{ pkgs, ... }: {
  # Enable Steam hardware support (udev rules + uinput kernel module for controllers)
  hardware.steam-hardware.enable = true;

  environment.systemPackages = with pkgs; [
    unstable.steam
  ];
}
