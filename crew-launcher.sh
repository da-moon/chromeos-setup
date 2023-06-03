#!/usr/bin/env bash
set -efuo pipefail
if ! crew --version >/dev/null 2>&1; then
  echo >&2 "ERROR: chromebrew not found"
  exit 1
fi
if ! crew-launcher  >/dev/null  2>&1; then
  echo >&2 "INFO: crew-launcher not found. installing ..."
  yes | crew install crew_launcher
fi
rm -f "${XDG_CONFIG_HOME%/*}/etc/env.d/crew_launcher"
cat <<'EOF'  | sudo tee "/etc/init/crew-launcher.conf" >/dev/null
description "Crewlauncher"
start on started sommelier
stop on stopping ui
expect fork
setuid "chronos"
setgid "chronos"
pre-start script
crew-launcher stop-server
end script
pre-stop script
  crew-launcher stop-server
end script
exec crew-launcher start-server
env XDG_CONFIG_HOME=/usr/local/.config
env USER=chronos
env HOME=/home/chronos/user
env WAYLAND_DISPLAY=wayland-0
env DISPLAY=:0
env LD_LIBRARY_PATH=/usr/local/lib64
EOF
sudo initctl start crew-launcher
