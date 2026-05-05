{ inputs, lib, config, pkgs, ... }:
let
  cfg = config.services.wagent;
  wagent = inputs.wagent.packages.${pkgs.system}.default;
  hostname = config.home.username; # filled below by osConfig if available

  wrapper = pkgs.writeShellScript "wagent-wrapper" ''
    set -eu

    # The Claude Code SDK that wagent wraps shells out to the `claude`
    # CLI. claude is typically installed via npm into ~/.local/bin
    # (not inside any nix profile), and other system tools live in
    # /run/current-system/sw/bin and /run/wrappers/bin. A systemd
    # user service's default PATH has none of those, so we set it
    # explicitly here. ~/.npm-global/bin is included so the pi
    # harness (installed via `npm install -g @mariozechner/pi-coding-agent`
    # by home/modules/pi/default.nix) is reachable too.
    export PATH="/run/wrappers/bin:/run/current-system/sw/bin:${config.home.homeDirectory}/.nix-profile/bin:${config.home.homeDirectory}/.local/bin:${config.home.homeDirectory}/.npm-global/bin:$PATH"

    # State + DB live under XDG_STATE_HOME so they survive
    # home-manager rebuilds and can be backed up.
    STATE_DIR="''${XDG_STATE_HOME:-${config.home.homeDirectory}/.local/state}/wagent"
    ${pkgs.coreutils}/bin/mkdir -p "$STATE_DIR"
    export WAGENT_DB="$STATE_DIR/wagent.sqlite"

    ${lib.optionalString (cfg.ghTokenPath != null) ''
      # GitHub PAT for shell-side `gh` calls inside subagents (e.g.
      # a coder persona running `gh pr list`). Sourced from the path
      # caller supplies; trimmed to drop trailing whitespace. Child
      # Bash processes spawned by the Claude SDK inherit this env.
      if [ -f ${cfg.ghTokenPath} ]; then
        GH_TOKEN=$(${pkgs.coreutils}/bin/cat ${cfg.ghTokenPath} | ${pkgs.coreutils}/bin/tr -d '[:space:]')
        export GH_TOKEN
      fi
    ''}

    ${lib.optionalString (cfg.authTokenPath != null) ''
      # Bearer-auth token. Required when bind isn't loopback. Refusing
      # to start on a non-loopback bind without a token in place is
      # safer than coming up unauthenticated on the network.
      if [ -f ${cfg.authTokenPath} ]; then
        WAGENT_AUTH_TOKEN=$(${pkgs.coreutils}/bin/cat ${cfg.authTokenPath} | ${pkgs.coreutils}/bin/tr -d '[:space:]')
        export WAGENT_AUTH_TOKEN
      elif [ "${cfg.bind}" != "127.0.0.1" ]; then
        echo "wagent: refusing to start — bind=${cfg.bind} requires WAGENT_AUTH_TOKEN but ${cfg.authTokenPath} is missing" >&2
        exit 1
      fi
    ''}
    ${lib.optionalString (cfg.authTokenPath == null && cfg.bind != "127.0.0.1") ''
      echo "wagent: refusing to start — bind=${cfg.bind} requires services.wagent.authTokenPath to be set" >&2
      exit 1
    ''}

    exec ${cfg.package}/bin/wagent
  '';

  hostsToml =
    if cfg.hosts == { }
    then null
    else pkgs.writeText "wagent-hosts.toml" (
      lib.concatStringsSep "\n" (lib.mapAttrsToList (name: h: ''
        [hosts.${name}]
        url = "${h.url}"
        ${lib.optionalString (h.defaultCwd != null) ''default_cwd = "${h.defaultCwd}"''}
        ${lib.optionalString (h.authTokenEnv != null) ''auth_token_env = "${h.authTokenEnv}"''}
        ${lib.optionalString (h.authTokenFile != null) ''auth_token_file = "${h.authTokenFile}"''}
      '') cfg.hosts)
    );
in
{
  options.services.wagent = {
    enable = lib.mkEnableOption "wagent — coding-agent HTTP+SSE daemon";

    package = lib.mkOption {
      type = lib.types.package;
      default = wagent;
      description = "The wagent package to install.";
    };

    bind = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = ''
        Address wagent's HTTP+SSE server binds to. Default loopback
        keeps wagent inaccessible from outside the host. Set to a
        tailscale interface (e.g. `100.x.y.z`) to allow other hosts
        (e.g. ARIA on ariaos) to drive this host's wagent via
        `wagent-on`. Non-loopback REQUIRES `authTokenPath` to be set.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 2468;
      description = "Port wagent listens on.";
    };

    authTokenPath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/var/lib/opnix/secrets/wagentAuthToken";
      description = ''
        Path to a file containing the bearer token wagent will require
        on every API request. Required when `bind` isn't loopback. The
        opnix module is the typical source — drop a secret reference
        like `op://Infrastructure/wagent-<host>/credential`, then
        point this option at the resulting file path.
      '';
    };

    ghTokenPath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/var/lib/opnix/secrets/ghToken";
      description = ''
        Optional path to a file containing a GitHub PAT. When set,
        the wagent wrapper exports it as `GH_TOKEN` so subagent Bash
        calls (e.g. `gh pr list`) work without an interactive
        `gh auth login` on the host.
      '';
    };

    hosts = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          url = lib.mkOption {
            type = lib.types.str;
            example = "http://dayman.tail.ts.net:2468";
            description = "Wagent endpoint, including scheme and port.";
          };
          defaultCwd = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Default cwd `wagent-on` uses when the caller doesn't override.";
          };
          authTokenEnv = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "WAGENT_DAYMAN_TOKEN";
            description = "Env var name the wagent-on CLI reads to find the bearer token.";
          };
          authTokenFile = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "/var/lib/opnix/secrets/wagentDaymanToken";
            description = "Path the wagent-on CLI reads to find the bearer token.";
          };
        };
      });
      default = { };
      description = ''
        Remote-host registry consumed by the `wagent-on` CLI on this
        machine. When set, this module writes
        `~/.config/wagent/hosts.toml` with the entries below; the CLI
        looks up host names there to know which wagent endpoint to
        dispatch to. Empty by default — leave alone unless this host
        is a controller (like ariaos) that drives wagent on peer
        hosts.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile = lib.mkIf (hostsToml != null) {
      "wagent/hosts.toml".source = hostsToml;
    };

    systemd.user.services.wagent = {
      Unit = {
        Description = "wagent — coding-agent HTTP+SSE daemon";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${wrapper}";
        Restart = "on-failure";
        RestartSec = 5;

        Environment = [
          "WAGENT_HOST=${cfg.bind}"
          "WAGENT_PORT=${toString cfg.port}"
          "WAGENT_CORS=*"
          "LOG_LEVEL=info"
        ];
      };

      Install.WantedBy = [ "default.target" ];
    };
  };
}
