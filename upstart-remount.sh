#!/usr/bin/env bash

# $(command -v mount) -o mode=1777,nodev -t tmpfs tmpfs "${TMPDIR}" ;
UPSTART_FILE="/etc/init/remount.conf"
  cat <<EOF | sudo tee "${UPSTART_FILE}" >/dev/null
description "Permissive mounts under user HOME"
# start on (started boot-services and stopped cgroups and started lockbox-cache and stopped tracefs-init and stopped startup)
start on start-user-session
stop on stopping ui
respawn
pre-start script
(
  for mnt in $( /usr/local/bin/findmnt --list --submounts --noheadings --nofsroot  --output TARGET .. );do
    (
      set -x ;
      mount --internal-only --options "remount,exec,suid,symfollow" "${mnt}" ;
    );
  done
  (
    set -x ;
    mkdir -p "/usr/local/tmp" "/usr/local/var/tmp" ;
    mount -o mode=1777,nodev -t tmpfs tmpfs "/usr/local/tmp" ;
    mount --bind "/usr/local/var/tmp" "/usr/local/tmp"
  );
  (
    set -x ;
    mkdir -p "/usr/local/tmp/crew/dest" ;
  );
  (
    set -x ;
    chown -R "chronos:chronos" "/usr/local/tmp" ;
    chown -R "chronos:chronos" "/usr/local/var/tmp" ;
  );
) > "$TMPDIR/remount-$(date +'%H-%M-%S-%N').log" 2>&1
end script
script
  while :; do sleep 10; done
end script
pre-stop script
(
  umount -l "/usr/local/tmp";
  rm -rf "/usr/local/var/tmp" ;
)
end script
chdir "/home/chronos/user"
env TMPDIR="/tmp"
EOF
sudo initctl stop "$(basename -s.conf "${UPSTART_FILE}")" || true
rm -f "${TMPDIR}/$(basename -s.conf "${UPSTART_FILE}")"* || true
sudo initctl start "$(basename -s.conf "${UPSTART_FILE}")" &
# sleep 3 ;
# cat "${UPSTART_FILE}"
# tail -f "/tmp/$(basename -s.conf "${UPSTART_FILE}")"*".log"
