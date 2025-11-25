{ config, pkgs, lib, ... }: 

{
    virtualisation.vmVariant = {
        virtualisation.diskSize = 10 * 1024 * 1024;
        
        virtualisation.sharedDirectories = {
        #    keys = {
        #        source = "/etc/ssh";
        #        target = "/etc/ssh";
        #    };

            op-secrets = {
                source = "$HOME/.config/op";
                target = "/mnt/op-host";
            };
        };


        # Symlink token to where opnix expects it (works in VM with shared dir)
        systemd.tmpfiles.rules = [
            "L /etc/opnix-token - - - - /mnt/op-host/service-account-token"
        ];

        virtualisation.memorySize =  2048;
        virtualisation.cores = 3;
        virtualisation.qemu.options = [
            "-device virtio-vga-gl"
            "-display sdl,gl=on,show-cursor=off"
            # Wire up pipewire audio
            #"-audiodev pipewire,id=audio0"
            #"-device intel-hda"
            #"-device hda-output,audiodev=audio0"
        ];

        environment.sessionVariables = {
            WLR_NO_HARDWARE_CURSORS = "1";
        };

        # disable troublesome virtualization for VMs
        hardware.nvidia-container-toolkit.enable = lib.mkForce false;
        virtualisation.libvirt.enable = lib.mkForce false;
        virtualisation.libvirtd.enable = lib.mkForce false;
    };
}