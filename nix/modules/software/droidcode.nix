{ inputs, pkgs, ... }:
let
  droidcodeStatic = inputs.droidcode.packages.${pkgs.stdenv.hostPlatform.system}.default;
  port = 5173;
in
{
  # Caddy serves the prebuilt Vite dist on `:5173` (matching the dev
  # port — fine on a server that doesn't run `npm run dev`). SPA
  # fallback rewrites unknown paths to /index.html so TanStack Router
  # deep links work over a refresh. Local-LAN testing only — no TLS,
  # no auth.
  services.caddy = {
    enable = true;
    virtualHosts.":${toString port}".extraConfig = ''
      root * ${droidcodeStatic}/share/droidcode
      encode zstd gzip
      try_files {path} /index.html
      file_server
    '';
  };
}
