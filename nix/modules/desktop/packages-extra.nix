{ pkgs, ... }: {
  # Insecure Packages
  nixpkgs.config.permittedInsecurePackages = [
    "electron-12.2.3"
    "electron-19.1.9"
    "electron-24.8.6"
    "electron-25.9.0"
    "electron-29.4.6"
  ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.syncthing = {
    enable = true;
    user = "sdelcore";
    dataDir = "/home/sdelcore/sync";
    configDir = "/home/sdelcore/.config/syncthing";
  };

  environment.systemPackages = with pkgs; [
    # IaC tools
    vagrant
    packer
    opentofu
    ansible

    # Build tools
    gcc
    gnumake
    glib
    glibc

    # Dev environment
    (python3.withPackages (ps: with ps; [pip virtualenv]))

    # Remote access
    samba
    xrdp

    # Containers / batch
    distrobox
    parallel

    # Multimedia
    ffmpeg

    # Kubernetes
    kubectl

    # Misc tools
    unstable.appimage-run
    sshpass
    jose
    w3m
    pay-respects
    neofetch

    # Dev libs
    libuuid
    libossp_uuid
    libusb1
    libusbp

    # Foreign filesystem support
    ntfs3g
    exfatprogs
    exfat
  ];
}
