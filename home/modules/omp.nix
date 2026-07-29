{ lib, config, pkgs, ... }:

# oh-my-pi (omp) — batteries-included coding harness with LSP, hash-anchored
# edits, and subagents. OMP discovers the LiteLLM model catalog at runtime;
# Nix owns only the provider connection.

let
  modelsFile = "${config.home.homeDirectory}/.omp/agent/models.yml";
  baseUrl = "http://llm.ai.tap/v1";
in
{
  # omp loads ~/.omp/agent/AGENTS.md as global instructions; share the same
  # file Claude Code, opencode, and codex use.
  home.file.".omp/agent/AGENTS.md".source = ./claude-code/CLAUDE.md;

  # Install omp via the native installer. --binary pins the standalone-binary
  # path so the installer never falls back to a bun-based source install; it
  # drops omp into ~/.local/bin and leaves shell rc files alone. Update by
  # re-running the installer (rm ~/.local/bin/omp + activate).
  # The installer shells out to grep/sed/uname/mktemp, which aren't in
  # home-manager's minimal activation PATH.
  home.activation.installOmp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${lib.makeBinPath (with pkgs; [ curl coreutils gnugrep gnused ])}:$PATH"
    if [ ! -f "$HOME/.local/bin/omp" ]; then
      echo "Installing oh-my-pi..."
      ${pkgs.curl}/bin/curl -fsSL https://omp.sh/install | ${pkgs.bash}/bin/bash -s -- --binary
    else
      echo "oh-my-pi is already installed at $HOME/.local/bin/omp"
    fi
  '';

  home.activation.ompLitellmProvider =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      out="${modelsFile}"
      mkdir -p "$(dirname "$out")"

      new=$(${pkgs.jq}/bin/jq -n \
        --arg base "${baseUrl}" \
        --arg keyCommand "!${pkgs.coreutils}/bin/cat /var/lib/opnix/secrets/litellmApiKey" \
        '{
        providers: {
          litellm: {
            baseUrl: $base,
            apiKey: $keyCommand,
            api: "openai-completions",
            auth: "apiKey",
            discovery: { type: "litellm" }
          }
        }
      }')

      tmp=$(mktemp)
      if [ -f "$out" ]; then
        ${pkgs.yq}/bin/yq -y -s '(.[0] * .[1]) | del(.providers.litellm.models)' "$out" <(echo "$new") > "$tmp"
      else
        echo "$new" | ${pkgs.yq}/bin/yq -y . > "$tmp"
      fi
      mv "$tmp" "$out"
      chmod 600 "$out"
      echo "omp: configured LiteLLM model discovery in $out"
    '';
}
