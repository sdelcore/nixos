{ config, lib, pkgs, primaryUser, ... }:

let
  hostName = config.networking.hostName;

  # Map hostname to SSH host key type
  hostKeyTypes = {
    dayman = "ed25519";
    nightman = "rsa";
  };
  hostKeyType = hostKeyTypes.${hostName} or "ed25519";

  # Script to convert PKCS#8 ed25519 keys to OpenSSH format
  # (1Password SDK returns PKCS#8, but OpenSSH needs its native format)
  pkcs8ToOpenssh = pkgs.writeScript "pkcs8-to-openssh" ''
    #!${pkgs.python3}/bin/python3
    import sys
    import base64
    import struct

    def convert(input_path, output_path):
        with open(input_path, "r") as f:
            pem = f.read()

        # Check if already OpenSSH format
        if "BEGIN OPENSSH PRIVATE KEY" in pem:
            with open(output_path, "w") as f:
                f.write(pem)
            return

        # Parse PKCS#8 PEM
        lines = pem.strip().split("\n")
        b64 = "".join(lines[1:-1])
        der = base64.b64decode(b64)

        # Extract ed25519 private seed (32 bytes at offset 16) and public key (32 bytes at offset 51)
        private_seed = der[16:48]
        public_key = der[51:83]

        def encode_string(s):
            if isinstance(s, str):
                s = s.encode()
            return struct.pack(">I", len(s)) + s

        key_type = b"ssh-ed25519"
        pubkey_blob = encode_string(key_type) + encode_string(public_key)

        checkint = struct.pack(">I", 0x12345678)
        private_blob = (
            checkint + checkint +
            encode_string(key_type) +
            encode_string(public_key) +
            encode_string(private_seed + public_key) +
            encode_string(b"")
        )

        # Padding with 1, 2, 3... sequence
        pad_len = 8 - (len(private_blob) % 8)
        if pad_len == 8:
            pad_len = 0
        for i in range(1, pad_len + 1):
            private_blob += bytes([i])

        openssh_key = (
            b"openssh-key-v1\x00" +
            encode_string(b"none") +
            encode_string(b"none") +
            encode_string(b"") +
            struct.pack(">I", 1) +
            encode_string(pubkey_blob) +
            encode_string(private_blob)
        )

        b64_key = base64.b64encode(openssh_key).decode()
        key_lines = [b64_key[i:i+70] for i in range(0, len(b64_key), 70)]

        with open(output_path, "w") as f:
            f.write("-----BEGIN OPENSSH PRIVATE KEY-----\n")
            for line in key_lines:
                f.write(line + "\n")
            f.write("-----END OPENSSH PRIVATE KEY-----\n")

    if __name__ == "__main__":
        convert(sys.argv[1], sys.argv[2])
  '';
in
{
  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";

    # User password
    secrets."${primaryUser}Passwd" = {
      reference = "op://Infrastructure/${primaryUser}/password";
      mode = "0400";
    };

    # User SSH keys (from sdelcoreSSH entry, RSA)
    secrets."${primaryUser}SshPrivateKey" = {
      reference = "op://Infrastructure/${primaryUser}SSH/private key";
      mode = "0400";
    };
    secrets."${primaryUser}SshPublicKey" = {
      reference = "op://Infrastructure/${primaryUser}SSH/public key";
      mode = "0444";
    };

    # Host SSH keys (per-host entries)
    secrets."${hostName}HostKeyPrivate" = {
      reference = "op://Infrastructure/${hostName}/private key";
      mode = "0400";
    };
    secrets."${hostName}HostKeyPublic" = {
      reference = "op://Infrastructure/${hostName}/public key";
      mode = "0444";
    };

    # Exa API key for OpenCode web search
    secrets."exaApiKey" = {
      reference = "op://Infrastructure/exa/credential";
      mode = "0444";  # User-readable for opencode
    };

    # YubiKey U2F public key
    secrets."yubikeyU2fKeys" = {
      reference = "op://Infrastructure/yubikey/u2f_keys";
      mode = "0400";
    };
  };

  # Set user password after opnix fetches the hash
  systemd.services.opnix-set-user-password = {
    description = "Set user password from opnix secret";
    after = [ "opnix-secrets.service" ];
    wants = [ "opnix-secrets.service" ];
    before = [ "getty.target" "sshd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      if [ -f /var/lib/opnix/secrets/${primaryUser}Passwd ]; then
        ${pkgs.shadow}/bin/chpasswd -e <<< "${primaryUser}:$(cat /var/lib/opnix/secrets/${primaryUser}Passwd)"
      fi
    '';
  };

  # Deploy user SSH keys to home directory and authorized_keys
  systemd.services.opnix-deploy-user-ssh-keys = {
    description = "Deploy user SSH keys from opnix to home";
    after = [ "opnix-secrets.service" ];
    wants = [ "opnix-secrets.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      PRIV="/var/lib/opnix/secrets/${primaryUser}SshPrivateKey"
      PUB="/var/lib/opnix/secrets/${primaryUser}SshPublicKey"
      SSH_DIR="/home/${primaryUser}/.ssh"
      AUTH_KEYS="$SSH_DIR/authorized_keys"

      if [ -f "$PRIV" ] && [ -f "$PUB" ]; then
        mkdir -p "$SSH_DIR"

        # Convert PKCS#8 to OpenSSH format (1Password SDK returns PKCS#8 for ed25519)
        ${pkcs8ToOpenssh} "$PRIV" "$SSH_DIR/id_rsa"
        cp "$PUB" "$SSH_DIR/id_rsa.pub"
        chmod 600 "$SSH_DIR/id_rsa"
        chmod 644 "$SSH_DIR/id_rsa.pub"

        # Add public key to authorized_keys if not already present
        PUB_KEY=$(cat "$PUB")
        if [ -f "$AUTH_KEYS" ]; then
          grep -qF "$PUB_KEY" "$AUTH_KEYS" || echo "$PUB_KEY" >> "$AUTH_KEYS"
        else
          echo "$PUB_KEY" > "$AUTH_KEYS"
        fi
        chmod 600 "$AUTH_KEYS"

        chown -R ${primaryUser}:users "$SSH_DIR"
      fi
    '';
  };

  # Deploy YubiKey U2F keys to user config
  systemd.services.opnix-deploy-yubikey = {
    description = "Deploy YubiKey U2F keys from opnix";
    after = [ "opnix-secrets.service" ];
    wants = [ "opnix-secrets.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      U2F_KEYS="/var/lib/opnix/secrets/yubikeyU2fKeys"
      YUBICO_DIR="/home/${primaryUser}/.config/Yubico"

      if [ -f "$U2F_KEYS" ]; then
        mkdir -p "$YUBICO_DIR"
        cp "$U2F_KEYS" "$YUBICO_DIR/u2f_keys"
        chmod 600 "$YUBICO_DIR/u2f_keys"
        chown -R ${primaryUser}:users "$YUBICO_DIR"
      fi
    '';
  };

  # Deploy host SSH keys to /etc/ssh/
  systemd.services.opnix-deploy-host-ssh-keys = {
    description = "Deploy host SSH keys from opnix";
    after = [ "opnix-secrets.service" ];
    wants = [ "opnix-secrets.service" ];
    before = [ "sshd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      PRIV="/var/lib/opnix/secrets/${hostName}HostKeyPrivate"
      PUB="/var/lib/opnix/secrets/${hostName}HostKeyPublic"
      KEY_TYPE="${hostKeyType}"

      if [ -f "$PRIV" ] && [ -f "$PUB" ]; then
        cp "$PRIV" "/etc/ssh/ssh_host_''${KEY_TYPE}_key"
        cp "$PUB" "/etc/ssh/ssh_host_''${KEY_TYPE}_key.pub"
        chmod 600 "/etc/ssh/ssh_host_''${KEY_TYPE}_key"
        chmod 644 "/etc/ssh/ssh_host_''${KEY_TYPE}_key.pub"
        chown root:root "/etc/ssh/ssh_host_''${KEY_TYPE}_key"
        chown root:root "/etc/ssh/ssh_host_''${KEY_TYPE}_key.pub"
      fi
    '';
  };
}
