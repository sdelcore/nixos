{ lib, config, pkgs, ... }:

# Wires pi to the self-hosted LiteLLM gateway (the `ai` VM) as its single model
# source. LiteLLM fronts everything — OpenCode Zen (Claude/Kimi/GLM/DeepSeek/…),
# the local llama-swap models on nightman, etc. — so model management lives in
# one place (LiteLLM) instead of pi juggling per-provider keys. LiteLLM speaks
# an OpenAI-compatible API at http://llm.ai.tap/v1, gated by an API key.
#
# Pi reads custom providers from ~/.pi/agent/models.json, and a non-built-in
# provider must carry its own baseUrl + apiKey there (pi has no env-var fallback
# for unknown providers). The key is a secret, so it can't live in the nix
# store. Instead we render models.json at activation time from the opnix secret
# at /var/lib/opnix/secrets/litellmApiKey (mode 0444, fetched by opnix.nix). The
# render is a deep-merge, so any user-added providers in models.json survive
# across activations; only the `litellm` provider is nix-owned. On a host
# without the secret the activation cleanly no-ops.

let
  secretFile = "/var/lib/opnix/secrets/litellmApiKey";
  modelsFile = "${config.home.homeDirectory}/.pi/agent/models.json";

  # LiteLLM gateway on the `ai` VM (Traefik-routed). model ids below must match
  # the model_name entries declared in the LiteLLM config (homelab repo:
  # nixos/stacks/ai/compose.yml).
  baseUrl = "http://llm.ai.tap/v1";
in
{
  home.activation.piLitellmProvider =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      secret="${secretFile}"
      out="${modelsFile}"

      if [ ! -r "$secret" ]; then
        echo "pi: litellm API key not present at $secret; skipping litellm provider."
      else
        key=$(cat "$secret")
        mkdir -p "$(dirname "$out")"

        new=$(${pkgs.jq}/bin/jq -n \
          --arg key "$key" \
          --arg base "${baseUrl}" \
          '{
            providers: {
              litellm: {
                baseUrl: $base,
                apiKey: $key,
                api: "openai-completions",
                models: [
                  { id: "anthropic/claude-opus-4-8", name: "Claude Opus 4.8 (Zen)", reasoning: true, input: ["text", "image"], contextWindow: 200000, maxTokens: 32000, cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 } },
                  { id: "anthropic/claude-sonnet-5", name: "Claude Sonnet 5 (Zen)", reasoning: true, input: ["text", "image"], contextWindow: 200000, maxTokens: 32000, cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 } },
                  { id: "kimi/kimi-k2.7-code", name: "Kimi K2.7 Code (Zen)", reasoning: false, input: ["text"], contextWindow: 262144, maxTokens: 8192, cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 } },
                  { id: "glm/glm-5.2", name: "GLM 5.2 (Zen)", reasoning: false, input: ["text"], contextWindow: 131072, maxTokens: 8192, cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 } },
                  { id: "deepseek/deepseek-v4-pro", name: "DeepSeek V4 Pro (Zen)", reasoning: true, input: ["text"], contextWindow: 131072, maxTokens: 8192, cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 } },
                  { id: "local/Qwen3.6-35B-A3B-MTP", name: "Qwen3.6 35B-A3B MTP (local)", reasoning: false, input: ["text"], contextWindow: 32768, maxTokens: 8192, cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 } }
                ]
              }
            }
          }')

        tmp=$(mktemp)
        if [ -f "$out" ]; then
          # Deep-merge: preserves user providers; replaces the litellm one and
          # drops the retired `unsloth` provider from earlier configs.
          ${pkgs.jq}/bin/jq -s '(.[0] * .[1]) | del(.providers.unsloth)' "$out" <(echo "$new") > "$tmp"
        else
          echo "$new" > "$tmp"
        fi
        mv "$tmp" "$out"
        chmod 600 "$out"
        echo "pi: wrote litellm provider to $out"
      fi
    '';
}
