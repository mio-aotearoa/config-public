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
      in
      {
        # Fixed: sudo inside tmux over SSH now skips fprintd as well.
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

          # Pass the shell script as an argument to pam_exec.so
          args = [
            "quiet"
            "${pkgs.writeShellScript "pam-sudo-ssh-bypass" ''
              # pam_exec only passes its PAM environment (PAM_SERVICE, PAM_USER, ...)
              # here, not sudo's parent environment. Checking only this script's
              # environment therefore misses normal SSH sessions as well as sudo
              # started from a tmux pane, where the pane shell is a child of the
              # long-lived tmux server rather than sshd.
              env_has() {
                local file=$1 name=$2 entry
                [ -r "$file" ] || return 1
                while IFS= read -r -d "" entry; do
                  case "$entry" in
                    "$name="*) return 0 ;;
                  esac
                done 2>/dev/null < "$file"
                return 1
              }

              proc_parent() {
                local pid=$1 key value rest
                while read -r key value rest; do
                  if [ "$key" = "PPid:" ]; then
                    printf '%s' "$value"
                    return 0
                  fi
                done 2>/dev/null < "/proc/$pid/status"
                return 1
              }

              has_ssh_env() {
                local file=$1
                env_has "$file" SSH_CONNECTION \
                  || env_has "$file" SSH_CLIENT \
                  || env_has "$file" SSH_TTY
              }

              if [ -n "''${SSH_TTY:-}" ] || [ -n "''${SSH_CONNECTION:-}" ] || [ -n "''${SSH_CLIENT:-}" ]; then
                exit 0
              fi

              # Find the TMUX socket used by the invoking shell. The tmux server
              # can outlive the SSH connection that started it, so the pane
              # environment may be stale after detach/reattach. The currently
              # attached tmux client environment reflects the session in use now.
              tmux_socket=""
              pid=$PPID
              depth=32
              while [ "$pid" -gt 1 ] && [ "$depth" -gt 0 ]; do
                if [ -r "/proc/$pid/environ" ]; then
                  while IFS= read -r -d "" entry; do
                    case "$entry" in
                      TMUX=*)
                        tmux_socket=''${entry#TMUX=}
                        tmux_socket=''${tmux_socket%%,*}
                        break
                        ;;
                    esac
                  done 2>/dev/null < "/proc/$pid/environ"
                fi
                [ -n "$tmux_socket" ] && break
                pid=$(proc_parent "$pid") || break
                depth=$((depth - 1))
              done

              if [ -n "$tmux_socket" ] && [ -S "$tmux_socket" ]; then
                if tmux_clients=$("${pkgs.coreutils}/bin/timeout" 2 "${pkgs.tmux}/bin/tmux" -S "$tmux_socket" list-clients -F '#{client_pid}' 2>/dev/null); then
                  for client_pid in $tmux_clients; do
                    if has_ssh_env "/proc/$client_pid/environ"; then
                      exit 0
                    fi
                  done
                  # Reachable tmux server with no SSH-attached client: stay local
                  # even if an old pane environment still contains SSH variables.
                  exit 1
                fi
              fi

              # Direct SSH, or a tmux server we could not inspect: walk the
              # invoking shell/process ancestry instead of relying on this
              # helper's minimal PAM environment.
              pid=$PPID
              depth=32
              while [ "$pid" -gt 1 ] && [ "$depth" -gt 0 ]; do
                if has_ssh_env "/proc/$pid/environ"; then
                  exit 0
                fi
                pid=$(proc_parent "$pid") || break
                depth=$((depth - 1))
              done

              # Local session (e.g. seat0 physical hardware). Exit 1 tells PAM
              # to ignore this rule and evaluate fprintd normally.
              exit 1
            ''}"
          ];
        };
      };
  };
}
