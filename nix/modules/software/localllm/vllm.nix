{ inputs, pkgs, ... }:

let
  unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs) system;
    config = {
      allowUnfree = true;
      # vllm 0.16.0 is marked insecure. The headline issue is CVE-2026-27893
      # (RCE via trust_remote_code bypass when loading untrusted models); the
      # rest are DoS or info-leak issues that require an exposed API server.
      # We run vllm as a local on-demand CLI, never as an unattended service,
      # and only load models we picked ourselves, so the practical risk is
      # low. nixpkgs has not yet packaged the patched 0.20.0. Drop this allow
      # once unstable ships vllm >= 0.20.0.
      #
      # Note: the interpreter prefix tracks the default python, so this name
      # changes whenever nixpkgs bumps python3 (3.13 -> 3.14 as of the
      # 2026-07-29 unstable bump).
      permittedInsecurePackages = [ "python3.14-vllm-0.16.0" ];
    };
    overlays = [
      (final: prev: {
        python3Packages = prev.python3Packages.overrideScope (pythonFinal: pythonPrev: {
          # outlines is a runtime dep of vllm. It gates its test phase on
          # `doCheck = !config.cudaSupport`, and this nixpkgs instance leaves
          # cudaSupport at its default, so the tests are on — dragging in the
          # whole nativeCheckInputs list, including tensorflow. tensorflow is
          # tensorflow-bin, which only ships prebuilt wheels for interpreters
          # upstream publishes for, and there is no python 3.14 wheel yet:
          #   error: tensorflow-bin: unsupported configuration: x86_64-linux_314
          # We do not care about outlines' own test suite (most of it is
          # already disabled upstream as network-dependent), so turn the check
          # phase off rather than flipping cudaSupport, which would silently
          # rebuild vllm as a CUDA package. Drop this once tensorflow-bin has
          # a 3.14 wheel.
          outlines = pythonPrev.outlines.overridePythonAttrs (old: {
            doCheck = false;
            nativeCheckInputs = [ ];
          });

          # model-hosting-container-standards is AWS's SageMaker hosting shim,
          # pulled in as a runtime dep of vllm (so it cannot just be dropped).
          # Package version is unchanged at 0.1.14 across this bump; these
          # tests only started failing because the default interpreter moved
          # from python 3.13 to 3.14. The breakage is real, not flaky —
          # decorator/env-var handler registration no longer takes effect, so
          # the SageMaker /ping and /invocations override machinery is broken.
          # That machinery is only used when vllm runs inside a SageMaker
          # container; we run it as a local CLI, so skip these rather than
          # lose the other ~700 tests. Drop once upstream supports 3.14.
          model-hosting-container-standards =
            pythonPrev.model-hosting-container-standards.overridePythonAttrs (old: {
              disabledTests = (old.disabledTests or [ ]) ++ [
                # Handler override registration is a no-op under 3.14
                "test_customer_script_functions_auto_loaded"
                "test_environment_variable_overrides_decorators"
                "test_customer_sets_environment_variables"
                "test_customer_writes_script_file"
                "test_customer_priority_understanding"
                "test_customer_decorator_usage_with_server_response"
                "test_register_handlers_priority_vs_script_functions"
                "test_framework_routes_are_created_automatically"
                # SimpleNamespace lacks adapter_co* attr under 3.14
                "test_nested_jmespath_transformations"
              ];
            });
        });
      })
    ];
  };

  # Unstable vllm 0.16.0's csrc/cpu/utils.hpp calls `at::cpu::L2_cache_size()`,
  # which was removed from the libtorch version unstable currently ships.
  # The function it lives in is only used by CPU inference kernels (we run on
  # CUDA), so replace the call with a 256 KiB constant to unblock the build.
  # Drop this override once nixpkgs unstable updates libtorch or vllm.
  vllm = unstable.vllm.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace csrc/cpu/utils.hpp \
        --replace-fail \
          "const uint32_t l2_cache_size = at::cpu::L2_cache_size();" \
          "const uint32_t l2_cache_size = 256 * 1024;"
    '';
  });
in
{
  # vLLM as a CLI only — no systemd service. vLLM pre-allocates ~90% of
  # VRAM on startup for its KV cache, so it should not run unattended.
  # Launch manually with `vllm serve <model>`.
  environment.systemPackages = [ vllm ];
}
