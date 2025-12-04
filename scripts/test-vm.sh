#!/usr/bin/env bash
set -euo pipefail

# VM Test Script - Build and run NixOS configurations as VMs for verification

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAKE_DIR="$(dirname "$SCRIPT_DIR")"

# Default values
MEMORY="4G"
CORES="2"
SSH_PORT="2222"
HEADLESS=false
BUILD_ONLY=false
RUN_ONLY=false
VERBOSE=false

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] <hostname>

Build and run a NixOS configuration as a VM for testing.

OPTIONS:
    -m, --memory SIZE     Memory allocation (default: $MEMORY)
    -c, --cores NUM       Number of CPU cores (default: $CORES)
    -p, --ssh-port PORT   SSH port forwarding (default: $SSH_PORT)
    -H, --headless        Run VM without display (use SSH to connect)
    -b, --build-only      Only build the VM, don't run it
    -r, --run-only        Only run existing VM (skip build)
    -v, --verbose         Verbose output
    -h, --help            Show this help message

EXAMPLES:
    $(basename "$0") dayman                    # Build and run dayman VM
    $(basename "$0") -H -p 2222 nightman       # Run headless with SSH on port 2222
    $(basename "$0") -b dayman                 # Only build, don't run
    $(basename "$0") -m 8G -c 4 dayman         # Run with 8GB RAM and 4 cores

CONNECTING TO HEADLESS VM:
    ssh -p 2222 localhost

EOF
    exit 0
}

log() {
    echo "[$(date '+%H:%M:%S')] $*"
}

log_verbose() {
    if [[ "$VERBOSE" == true ]]; then
        log "$*"
    fi
}

error() {
    echo "[ERROR] $*" >&2
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--memory)
            MEMORY="$2"
            shift 2
            ;;
        -c|--cores)
            CORES="$2"
            shift 2
            ;;
        -p|--ssh-port)
            SSH_PORT="$2"
            shift 2
            ;;
        -H|--headless)
            HEADLESS=true
            shift
            ;;
        -b|--build-only)
            BUILD_ONLY=true
            shift
            ;;
        -r|--run-only)
            RUN_ONLY=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        -*)
            error "Unknown option: $1"
            ;;
        *)
            HOSTNAME="$1"
            shift
            ;;
    esac
done

# Validate hostname
if [[ -z "${HOSTNAME:-}" ]]; then
    error "Hostname is required. Use -h for help."
fi

# Check if configuration exists
if ! nix flake show "$FLAKE_DIR" 2>/dev/null | grep -q "nixosConfigurations.*$HOSTNAME"; then
    log "Available configurations:"
    nix flake show "$FLAKE_DIR" 2>/dev/null | grep -A 100 "nixosConfigurations" | head -20
    error "Configuration '$HOSTNAME' not found in flake"
fi

VM_SCRIPT="$FLAKE_DIR/result/bin/run-${HOSTNAME}-vm"

# Build VM
if [[ "$RUN_ONLY" != true ]]; then
    log "Building VM for '$HOSTNAME'..."
    log_verbose "Running: nixos-rebuild build-vm --flake $FLAKE_DIR#$HOSTNAME --impure"

    cd "$FLAKE_DIR"
    if nixos-rebuild build-vm --flake ".#$HOSTNAME" --impure; then
        log "Build successful!"
    else
        error "Build failed"
    fi
fi

# Exit if build-only
if [[ "$BUILD_ONLY" == true ]]; then
    log "Build complete. VM script at: $VM_SCRIPT"
    exit 0
fi

# Check VM script exists
if [[ ! -x "$VM_SCRIPT" ]]; then
    error "VM script not found at $VM_SCRIPT. Did the build succeed?"
fi

# Prepare QEMU options
QEMU_OPTS="-m $MEMORY -smp $CORES"

# Add SSH port forwarding
QEMU_OPTS="$QEMU_OPTS -nic user,model=virtio,hostfwd=tcp::${SSH_PORT}-:22"

# Add headless options
if [[ "$HEADLESS" == true ]]; then
    QEMU_OPTS="$QEMU_OPTS -nographic"
    log "Running in headless mode. Connect via: ssh -p $SSH_PORT localhost"
else
    log "Running with graphical display"
fi

# Run VM
log "Starting VM '$HOSTNAME'..."
log "  Memory: $MEMORY"
log "  Cores: $CORES"
log "  SSH Port: $SSH_PORT"
log ""
log "Press Ctrl+A then X to exit QEMU (headless) or close the window (graphical)"
log ""

export QEMU_OPTS
exec "$VM_SCRIPT"
