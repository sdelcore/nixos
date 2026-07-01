{ pkgs, ... }:

# Readwise CLI (https://readwise.io/cli) — "a CLI for everything you've read",
# published to npm as @readwise/cli. Packaged from the registry tarball since
# it isn't in nixpkgs.
let
  readwise-cli = pkgs.buildNpmPackage rec {
    pname = "readwise-cli";
    version = "0.5.8";

    src = pkgs.fetchzip {
      url = "https://registry.npmjs.org/@readwise/cli/-/cli-${version}.tgz";
      hash = "sha256-sj1VcNsRpsnnj4ZQD78xrFotJqO5abt14yjNvn5fY/M=";
    };

    # The npm tarball ships no lockfile and upstream pins one dependency to
    # "latest", so supply a locally generated, fully pinned lock to keep the
    # build reproducible.
    postPatch = ''
      cp ${./package-lock.json} package-lock.json
    '';

    npmDepsHash = "sha256-nMfBVK24R6niz+wC36rj9WItG8kgg10iH+5WItAs7ag=";

    # dist/ is prebuilt in the tarball; skip the tsc build step.
    dontNpmBuild = true;
  };
in
{
  home.packages = [ readwise-cli ];
}
