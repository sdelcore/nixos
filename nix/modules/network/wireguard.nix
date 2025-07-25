{ config, pkgs, ... }:

{
  imports = [
    ../../secrets/secrets.nix
  ];
  networking.firewall = {
    allowedUDPPorts = [ 51820  ]; # Clients and peers can use the same port, see listenport
    # if packets are still dropped, they will show up in dmesg
    logReversePathDrops = true;
    # wireguard trips rpfilter up
    extraCommands = ''
      ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN
      ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN
    '';
    extraStopCommands = ''
      ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN || true
      ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN || true
    '';
  };

  sops.secrets."wireguard/dayman/public_key" = { 
    path = "/etc/nixos/configs/wg/wireguard-publickey.conf";
    mode = "0600";
  };
  sops.secrets."wireguard/dayman/private_key" = {
    path = "/etc/nixos/configs/wg/wireguard-privatekey.conf";
    mode = "0600";
  };
  sops.secrets."wireguard/home/public_key" = {
    path = "/etc/nixos/configs/wg/wireguard-home-publickey.conf";
    mode = "0600";
  };

  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "10.0.1.7/32" ];
      dns = [ "10.0.0.1" ];
      privateKeyFile = "/etc/nixos/configs/wg/wireguard-privatekey.conf";
      autostart = true;
      
      peers = [
        {
          publicKey = "/etc/nixos/configs/wg/wireguard-home-publickey.conf";
          allowedIPs = [ "10.0.0.0/24" "10.0.1.0/24" ];
          endpoint = "wireguard.sdelcore.com:51820";
          #persistentKeepalive = 25;
        }
      ];
    };
  };

  #environment.etc = {
  #  # Wireguard
  #  "NetworkManager/system-connections/home.nmconnection".text = {
  #    text = ''
  #      [connection]
  #      id=home
  #      uuid=4003bf2b-d548-43fd-9f9f-67ce2409df0a
  #      type=wireguard
  #      autoconnect=false
  #      interface-name=wg0
  #      permissions=user:sdelcore:;

  #      [wireguard]
  #      listen-port=51820
  #      private-key=${config.config.sops.secrets."wireguard/dayman/private_key"}

  #      [wireguard-peer.${config.config.sops.secrets."wireguard/home/public_key"}]
  #      endpoint=${config.config.sops.secrets."wireguard/endpoint"}
  #      preshared-key-flags=0
  #      allowed-ips=0.0.0.0/0;

  #      [ipv4]
  #      address1=10.0.1.7/32
  #      dns=10.0.0.1;
  #      method=manual

  #      [ipv6]
  #      addr-gen-mode=default
  #      method=disabled

  #      [proxy]
  #    '';
  #    mode = "0600";
  #  };
  #};

}
