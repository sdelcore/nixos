{ config, pkgs, ... }:

# Base system config shared by every host (timezone, locale, nix settings,
# core packages, sound, ssh). Update via `just update` then `just switch`.

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

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.variables = {
    #WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    EDITOR = "nvim";
    BROWSER = "zen";
    TERMINAL = "ghostty";
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

  # Resolve /usr/bin & /bin shebangs for prebuilt binaries (pairs with nix-ld).
  services.envfs.enable = true;

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

    # Stop the daily GC from evicting dev-shell (nix-direnv) build inputs.
    keep-outputs = true;
    keep-derivations = true;
  };

}
