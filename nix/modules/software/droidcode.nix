{ inputs, lib, config, pkgs, ... }:
let
  cfg = config.services.droidcode;
  droidcodeStatic = inputs.droidcode.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  options.services.droidcode = {
    enable = lib.mkEnableOption "DroidCode static web client (Caddy-served)";

    package = lib.mkOption {
      type = lib.types.package;
      default = droidcodeStatic;
      description = "The droidcode-static package to serve.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 5173;
      description = ''
        HTTP port Caddy listens on. Defaults to 5173 to match the Vite
        dev port — pick something else if `npm run dev` runs on the
        same host.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;
      virtualHosts.":${toString cfg.port}".extraConfig = ''
        root * ${cfg.package}/share/droidcode
        encode zstd gzip
        try_files {path} /index.html
        file_server
      '';
    };
  };
}
