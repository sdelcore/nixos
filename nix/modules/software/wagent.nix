{ inputs, ... }: {
  imports = [ inputs.wagent.nixosModules.default ];

  # Local-LAN testing config — bound to 0.0.0.0 with no auth so the
  # phone can reach it via mDNS (`http://nightman.local:2468`) without
  # juggling tokens. Tighten when this leaves loopback for real.
  services.wagent = {
    enable = true;
    host = "0.0.0.0";
    port = 2468;
    cors = "*";
  };
}
