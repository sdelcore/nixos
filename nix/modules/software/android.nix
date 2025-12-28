{ primaryUser, ... }: {
  # Enable ADB for Android development
  programs.adb.enable = true;

  # Add user to adbusers group for device access
  users.users.${primaryUser}.extraGroups = [ "adbusers" ];
}
