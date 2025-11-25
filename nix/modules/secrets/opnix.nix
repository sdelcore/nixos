{ config, lib, pkgs, primaryUser, ... }:

let
  hostName = config.networking.hostName;

  # Map hostname to SSH host key type
  hostKeyTypes = {
    dayman = "ed25519";
    nightman = "rsa";
  };
  hostKeyType = hostKeyTypes.${hostName} or "ed25519";
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
        cp "$PRIV" "$SSH_DIR/id_rsa"
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
