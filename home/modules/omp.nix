{ lib, config, pkgs, ... }:

# oh-my-pi (omp) — fork of the pi coding agent with a batteries-included tool
# harness (LSP, hash-anchored edits, subagents). Installed as a standalone
# binary and wired to the same LiteLLM gateway pi uses (see pi/local-model.nix
# for the full rationale). omp reads custom providers from
# ~/.omp/agent/models.yml — same provider schema as pi's models.json, but
# YAML — so the render deep-merges through yq instead of jq. The apiKey is a
# secret, so the file is rendered at activation from the opnix secret rather
# than living in the nix store; user-added providers survive across
# activations, only the `litellm` provider is nix-owned.

let
  secretFile = "/var/lib/opnix/secrets/litellmApiKey";
  modelsFile = "${config.home.homeDirectory}/.omp/agent/models.yml";

  # model ids must match the model_name entries in the LiteLLM config
  # (homelab repo: nixos/stacks/ai/compose.yml). The chatgpt/* entries go
  # live when homelab #97 deploys.
  baseUrl = "http://llm.ai.tap/v1";
in
{
  # omp loads ~/.omp/agent/AGENTS.md as global instructions; share the same
  # file Claude Code, opencode, codex, and pi use.
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
      secret="${secretFile}"
      out="${modelsFile}"

      if [ ! -r "$secret" ]; then
        echo "omp: litellm API key not present at $secret; skipping litellm provider."
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
                  { id: "local/Qwen3.6-35B-A3B-MTP", name: "Qwen3.6 35B-A3B MTP (local)", reasoning: false, input: ["text"], contextWindow: 32768, maxTokens: 8192, cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 } },
                  { id: "chatgpt/gpt-5.6-sol", name: "GPT-5.6 Sol (ChatGPT sub)", reasoning: true, input: ["text", "image"], contextWindow: 400000, maxTokens: 128000, cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 } },
                  { id: "chatgpt/gpt-5.6-terra", name: "GPT-5.6 Terra (ChatGPT sub)", reasoning: true, input: ["text", "image"], contextWindow: 400000, maxTokens: 128000, cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 } },
                  { id: "chatgpt/gpt-5.6-luna", name: "GPT-5.6 Luna (ChatGPT sub)", reasoning: true, input: ["text", "image"], contextWindow: 400000, maxTokens: 128000, cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 } },
                  { id: "chatgpt/gpt-5.5", name: "GPT-5.5 (ChatGPT sub)", reasoning: true, input: ["text", "image"], contextWindow: 400000, maxTokens: 128000, cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 } }
                ]
              }
            }
          }')

        tmp=$(mktemp)
        if [ -f "$out" ]; then
          ${pkgs.yq}/bin/yq -y -s '.[0] * .[1]' "$out" <(echo "$new") > "$tmp"
        else
          echo "$new" | ${pkgs.yq}/bin/yq -y . > "$tmp"
        fi
        mv "$tmp" "$out"
        chmod 600 "$out"
        echo "omp: wrote litellm provider to $out"
      fi
    '';
}
