{ ... }: {
  imports = [
    ../modules/software/localllm
    ../modules/software/android.nix
    ../modules/software/shared.nix
    ../modules/virtualization/docker.nix
    ../modules/virtualization/libvirt.nix
  ];
}
