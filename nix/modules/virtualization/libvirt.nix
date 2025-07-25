{ inputs, config, pkgs, ... }:

let
  libvirtEnabled = true;
  virtLib = inputs.nixvirt.lib;
in

{

  virtualisation = {
    libvirt = {
      enable = true;
      swtpm.enable = true;
      verbose = true;
    };
    libvirtd = {
      enable = true;
      onShutdown = "suspend";
      onBoot = "ignore";
      qemu = {
        package = pkgs.qemu_kvm;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
        swtpm.enable = true;
        runAsRoot = false;
        vhostUserPackages = [ pkgs.virtiofsd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };
  
  services.spice-vdagentd.enable = true;

  environment.etc = {
    "ovmf/edk2-x86_64-secure-code.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-x86_64-secure-code.fd";
    };

    "ovmf/edk2-i386-vars.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-i386-vars.fd";
    };
  };

  virtualisation.libvirt.connections."qemu:///session" = {
    domains = [
        {
          definition = virtLib.domain.writeXML (virtLib.domain.templates.windows
            {
              name = "Wurst";
              uuid = "def734bb-e2ca-44ee-80f5-0ea5f2593aaa";
              memory = { count = 12; unit = "GiB"; };
              storage_vol = { pool = "default"; volume = "Wurst.qcow2"; };
              nvram_path = /opt/vmpool/nvram/Wurst.nvram;
              virtio_net = true;
              virtio_drive = true;
              virtio_video = false;
              install_virtio = true;
            });
        }
        {
            definition = virtLib.domain.writeXML (virtLib.domain.templates.linux
            {
                name = "Penguin";
                uuid = "cc7439ed-36af-4696-a6f2-1f0c4414d87e";
                memory = { count = 8; unit = "GiB"; };
                storage_vol = { pool = "default"; volume = "Penguin.qcow2"; };
                virtio_video = false;
            });
        }
      ];
    pools = [
        {
          definition = virtLib.pool.writeXML {
            name = "default";
            uuid = "afa32edd-a316-4cc5-879d-b25ab3422cf7";
            type = "dir";
            target = {path = "/opt/vmpool";};
          };
          active = true;
          volumes = [];
        }
      ];
    networks = [
        {
          active = true;
          definition = virtLib.network.writeXML {
            uuid = "8e91d351-e902-4fce-99b6-e5ea88ac9b80";
            name = "vm-lan";
            forward = {
              mode = "nat";
              nat = {
                nat = {
                  port = {
                    start = 1024;
                    end = 65535;
                  };
                };
                ipv6 = false;
              };
            };
            bridge = {
              name = "virbr0";
              stp = true;
              delay = 0;
            };
            ipv6 = false;
            ip =
              let
                subnet = inputs.nix-secrets.networking.subnets.vm-lan;
              in
              {
                address = "192.168.71.1";
                netmask = "255.255.255.0";
                dhcp = {
                  range = {
                    start = "192.168.71.2";
                    end = "192.168.71.254";
                  };
                };
              };
          };
        }
      ];
  };
}
