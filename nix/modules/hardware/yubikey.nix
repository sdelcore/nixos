{ config, pkgs, ... }:

{
  # YubiKey U2F keys deployed via opnix (see opnix.nix)
  
  # U2F authentication settings
  security.pam.u2f = {
    enable = true;
    control = "sufficient";  # YubiKey OR password
    settings = {
      cue = true;  # Print "Please touch the device" message
      authfile = "/var/lib/opnix/secrets/yubikeyU2fKeys";
    };
  };

  # Enable YubiKey for login, sudo, and hyprlock
  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
    hyprlock.u2fAuth = true;
    gdm.enableGnomeKeyring = true;
  };
  
  # Enable Yubikey-Touch-Detector
  programs.yubikey-touch-detector.enable = true; 

  # Fix Gnome Keyring not unlocking
  # note: enabling this caused gnome to hang on startup?
  # Thinking the UID of whatever is set here is jank
  #environment.variables.XDG_RUNTIME_DIR = "/run/user/$UID";

  # Lock the computer when YubiKey is unplugged
  services.udev.extraRules = ''
    ACTION=="remove", \
    ENV{ID_BUS}=="usb", \
    ENV{ID_VENDOR_ID}=="1050", \
    ENV{ID_VENDOR}=="Yubico", \
    RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
  '';

  environment.systemPackages = with pkgs; [
    pam_u2f # A PAM module for allowing authentication with a U2F device
    yubikey-agent # A seamless ssh-agent for YubiKeys
    yubikey-manager # Command line tool for configuring any YubiKey over all USB transports
    yubikey-touch-detector # A tool to detect when your YubiKey is waiting for a touch (to send notification or display a visual indicator on the screen).
    yubikey-personalization # A library and command line tool to personalize YubiKeys
  ];

  services.udev.packages = [ pkgs.yubikey-personalization ];

}