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

  # Enable CUPS to print documents.
  services.printing.enable = true;

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

  # NixPackages Configuration
  # Insecure Packages
  # Needed to allow building with insecure packages.
  nixpkgs.config.permittedInsecurePackages = [
    "electron-12.2.3"
    "electron-19.1.9"
    "electron-24.8.6"
    "electron-25.9.0"
    "electron-29.4.6"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    curl
    fzf
    sshpass
    jq
    w3m
    unstable.appimage-run
    jose
    pay-respects
    tree


    ntfs3g # FUSE-based NTFS driver with full write support
    exfatprogs
    exfat
    xdg-utils
    neofetch
    kubectl

    # shells
    zsh
    oh-my-zsh # A framework for managing your zsh configuration
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
    samba
    tree
    unzip
    xrdp
    file
    distrobox
    parallel
    tree
    jq
    
    # libs
    libuuid
    libossp_uuid
    libusb1
    libusbp
    pkgs.home-manager

    # misc
    coreutils
    pciutils
    ffmpeg

    (python3.withPackages (ps: with ps; [pip virtualenv]))
    delta
    dig
    dust
    eza
    fd
    gcc
    glib
    glibc
    gnumake
    jq
    killall
    nh
    dysk
    just
    
    vagrant
    packer
    opentofu
    ansible
  ];

  programs.zsh.enable = true;

  # List services that you want to enable:
  
  services = {
    syncthing = {
        enable = true;
        user = "sdelcore";
        dataDir = "/home/sdelcore/sync";    # Default folder for new synced folders
        configDir = "/home/sdelcore/.config/syncthing";   # Folder for Syncthing's settings and keys
    };
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
