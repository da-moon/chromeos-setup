#!/usr/bin/env bash

cat << 'EOF' | sudo tee "/etc/init/remount.conf" > /dev/null ;
description "Permissive mounts under user HOME"
start on start-user-session
stop on stopping ui
post-start script
(
set -x
for mnt in $( /bin/findmnt --list --submounts --noheadings --nofsroot  --output TARGET "${HOME%/*}");do
  /bin/mount --internal-only --options "remount,exec,suid,symfollow" "${mnt}"
done
) > "/tmp/remount.done" 2>&1
end script
env HOME="/home/chronos/user"
EOF
sudo initctl start remount ;

