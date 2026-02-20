{ config, pkgs, ... }:

# to update to latest: `nix-channel --update nixos; nixos-rebuild switch`


let
  
in

{
  imports =
    [
      ./virtualization/nix-testvm.nix
      ./secrets/opnix.nix
    ];
  
  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  environment.etc = {
  };

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.variables = {
    #WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    EDITOR = "nvim";
    BROWSER = "zen";
    TERMINAL = "alacritty";
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    curl
    fzf
    jq
    tree
    xdg-utils

    # shells
    zsh
    oh-my-zsh
    zsh-completions
    zsh-powerlevel9k
    zsh-powerlevel10k
    zsh-autocomplete
    zsh-autosuggestions
    zsh-syntax-highlighting
    nix-zsh-completions

    # tools
    git
    btop
    bat
    unzip
    file
    home-manager

    # misc
    coreutils
    pciutils
    delta
    dig
    dust
    eza
    fd
    jq
    killall
    nh
    dysk
    just
  ];

  programs.zsh.enable = true;

  # List services that you want to enable:
  
  services = {
    openssh = {
        enable = true;
        settings = {
            AcceptEnv = "WAYLAND_DISPLAY";
            X11Forwarding = true;
        };
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
    };

    dbus = {
      enable = true;
      #implementation = "broker";
    };

  };

  programs.nix-ld = {
      enable = true;
      package = pkgs.nix-ld;
  };

  # Garbage Collection
  # Keeps space down
  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 3d";
    };
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
  };

  # Automatic Updates
  system.autoUpgrade = {
    enable = false;
  };

  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

}
