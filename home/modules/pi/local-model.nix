{ lib, config, pkgs, ... }:

# Wires pi to the local Unsloth Studio model on nightman. Studio serves an
# OpenAI-compatible endpoint at http://localhost:8888/v1, gated behind a
# bearer token. Pi reads custom providers from ~/.pi/agent/models.json, and
# a non-built-in provider must carry its own baseUrl + apiKey there (pi has
# no env-var fallback for unknown providers).
#
# The API key is a secret, so it can't live in the nix store. Instead we
# render models.json at activation time from the opnix secret at
# /var/lib/opnix/secrets/unslothApiKey (mode 0444, fetched by opnix.nix on
# nightman only). The render is a deep-merge, so any user-added providers in
# models.json survive across activations; only the `unsloth` provider is
# nix-owned.
#
# Default model/provider are left untouched (kimi-k2.6 via opencode stays
# the default) — select the local model in pi with `/model` or
# `unsloth/Qwen3.6-35B-A3B-MTP-GGUF`.

let
  secretFile = "/var/lib/opnix/secrets/unslothApiKey";
  modelsFile = "${config.home.homeDirectory}/.pi/agent/models.json";

  # The id must match what Studio registers (its /v1/models id), which is the
  # HF repo id of the loaded GGUF.
  modelId = "unsloth/Qwen3.6-35B-A3B-MTP-GGUF";
  baseUrl = "http://localhost:8888/v1";
in
{
  # Render ~/.pi/agent/models.json from the opnix secret. Skips cleanly on
  # hosts without the secret (i.e. anything but nightman), leaving any
  # existing models.json as-is.
  home.activation.piUnslothProvider =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      secret="${secretFile}"
      out="${modelsFile}"

      if [ ! -r "$secret" ]; then
        echo "pi: unsloth API key not present at $secret; skipping local provider."
      else
        key=$(cat "$secret")
        mkdir -p "$(dirname "$out")"

        new=$(${pkgs.jq}/bin/jq -n \
          --arg key "$key" \
          --arg base "${baseUrl}" \
          --arg id "${modelId}" \
          '{
            providers: {
              unsloth: {
                baseUrl: $base,
                apiKey: $key,
                api: "openai-completions",
                models: [
                  {
                    id: $id,
                    name: "Qwen3.6 35B-A3B MTP (local)",
                    reasoning: false,
                    input: ["text", "image"],
                    contextWindow: 32768,
                    maxTokens: 8192,
                    cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 }
                  }
                ]
              }
            }
          }')

        tmp=$(mktemp)
        if [ -f "$out" ]; then
          # Deep-merge: preserves other providers; replaces the unsloth one.
          ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$out" <(echo "$new") > "$tmp"
        else
          echo "$new" > "$tmp"
        fi
        mv "$tmp" "$out"
        chmod 600 "$out"
        echo "pi: wrote unsloth local provider to $out"
      fi
    '';
}
