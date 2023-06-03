#!/usr/bin/env bash

UPSTART_FILE="/etc/init/remount.conf"
  cat <<EOF | sudo tee "${UPSTART_FILE}" >/dev/null
description "Permissive mounts under user HOME"
start on start-user-session
stop on runlevel [!2345]
task
script
(
  for mnt in \$( $(command -v findmnt) --list --submounts --noheadings --nofsroot  --output TARGET .. );do
    (
      set -x ;
      $(command -v mount) --internal-only --options "remount,exec,suid,symfollow" "\${mnt}"
    );
  done
    (
      set -x ;
      $(command -v mount) -o mode=1777,nodev -t tmpfs tmpfs "\${TMPDIR}"
    );
) > "\$TMPDIR/$(basename -s.conf "${UPSTART_FILE}")-\$(date +'%H-%M-%S-%N').log" 2>&1
end script
chdir "${HOME}"
env TMPDIR="${TMPDIR}"
EOF
sudo initctl stop "$(basename -s.conf "${UPSTART_FILE}")" || true
rm -f "${TMPDIR}/$(basename -s.conf "${UPSTART_FILE}")"* || true
sudo initctl start "$(basename -s.conf "${UPSTART_FILE}")" &
# sleep 3 ;
# cat "${UPSTART_FILE}"
# tail -f "${TMPDIR}/$(basename -s.conf "${UPSTART_FILE}")"*".log"
