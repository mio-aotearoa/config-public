{ den, ... }:
{
  den.aspects.sudo-fprint-ssh-bypass = {
    description = "Skip fprintd for sudo over SSH (PAM pam_exec bypass)";
    nixos =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      let
        # Determine if fprintd authentication is actively enabled for the sudo PAM stack.
        isSudoFprintEnabled = config.security.pam.services.sudo.fprintAuth or false;
        # pam_exec uses a clean env (often empty PATH). Pin tools via runtimeInputs.
        pamSudoSshBypass = pkgs.writeShellApplication {
          name = "pam-sudo-ssh-bypass";
          runtimeInputs = [
            pkgs.coreutils
            pkgs.gawk
            pkgs.gnugrep
            pkgs.gnused
            pkgs.systemd
          ];
          text = ''
            # pam_exec starts with a clean env (no SSH_*). sudo also env_resets.
            # Detect remoteness via the invoking process's logind session instead.
            # That stays correct inside tmux: panes are in tmux-spawn-*.scope, but
            # walking parents (or XDG_SESSION_ID) reaches the real session-N.scope.
            # Local / local-started tmux => Remote=no => ask fingerprint.
            # SSH / SSH-started tmux => Remote=yes => skip fingerprint.

            ppid_of() {
              awk '/^PPid:/ { print $2 }' /proc/"$1"/status 2>/dev/null
            }

            find_sid() {
              local pid="$1" sid
              while [ -n "$pid" ] && [ "$pid" -gt 1 ]; do
                if [ -r /proc/"$pid"/cgroup ]; then
                  sid=$(sed -n 's/.*session-\([0-9]\+\)\.scope.*/\1/p' /proc/"$pid"/cgroup | head -n1)
                  if [ -n "$sid" ]; then
                    echo "$sid"
                    return 0
                  fi
                fi
                if [ -r /proc/"$pid"/environ ]; then
                  sid=$(tr '\0' '\n' < /proc/"$pid"/environ | sed -n 's/^XDG_SESSION_ID=//p' | head -n1)
                  if [ -n "$sid" ]; then
                    echo "$sid"
                    return 0
                  fi
                fi
                pid=$(ppid_of "$pid")
              done
              return 1
            }

            # Script PPID is sudo; sudo's parent is the invoking client.
            sudo_pid=$PPID
            client_pid=$(ppid_of "$sudo_pid")
            if [ -z "$client_pid" ] || [ "$client_pid" -le 1 ]; then
              exit 1
            fi

            sid=$(find_sid "$client_pid" || true)
            if [ -n "$sid" ]; then
              remote=$(loginctl show-session "$sid" -p Remote --value 2>/dev/null || true)
              if [ "$remote" = "yes" ]; then
                exit 0
              fi
              # Explicit local session (including local-started tmux): do not
              # fall through to SSH_* — those can appear after SSH attach via
              # tmux update-environment while the session origin is still local.
              exit 1
            fi

            # Fallback when no logind session was found: SSH_* on the client.
            if [ -r /proc/"$client_pid"/environ ] &&
              tr '\0' '\n' < /proc/"$client_pid"/environ |
                grep -qE '^(SSH_CONNECTION|SSH_CLIENT|SSH_TTY)='; then
              exit 0
            fi

            exit 1
          '';
        };
      in
      {
        # Only evaluate and inject this PAM rule if fprintd is configured for sudo.
        security.pam.services.sudo.rules.auth.skip_fprintd_for_ssh = lib.mkIf isSudoFprintEnabled {
          enable = true;

          # Dynamically order this rule to execute immediately before the fprintd rule.
          # This guarantees that the [success=1] control flag skips exactly the fprintd module.
          order = config.security.pam.services.sudo.rules.auth.fprintd.order - 1;

          # If the script succeeds (exit 0), skip the next 1 module (pam_fprintd.so).
          # If the script fails (exit 1), ignore the failure and evaluate the biometric module normally.
          control = "[success=1 default=ignore]";

          modulePath = "${pkgs.pam}/lib/security/pam_exec.so";

          args = [
            "quiet"
            "${pamSudoSshBypass}/bin/pam-sudo-ssh-bypass"
          ];
        };
      };
  };
}
