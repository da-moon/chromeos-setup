#!/usr/bin/env bash
set -efuo pipefail ;
if ! crew --version >/dev/null 2>&1; then
  echo >&2 "ERROR: chromebrew not found"
  exit 1
fi
if ! sommelier.elf --version > /dev/null 2>&1; then
  echo >&2 "INFO: sommelier not found. installing ..."
  yes | crew install sommelier
fi
DRM_DEVICES_LIST=($(/usr/local/bin/find "/dev/dri" -name "renderD*"))
if [[ "${#DRM_DEVICES_LIST[@]}" -gt 1 ]]; then
  for dev in "${DRM_DEVICES_LIST[@]}"; do
    if [[ "$(/usr/local/bin/coreutils --coreutils-prog=readlink -f "/sys/class/drm/${dev}/device/driver")" =~ (bus/pci|drm) ]]; then
      SOMMELIER_DRM_DEVICE="/dev/dri/${dev##*/}"
      break
    fi
  done
else
  SOMMELIER_DRM_DEVICE="/dev/dri/${DRM_DEVICES_LIST[0]##*/}"
fi
# https://www.reddit.com/r/Crostini/comments/94wenl/how_to_get_other_chromeos_keyboard_shortcuts/
cat << EOF | sudo tee "/etc/init/sommelier.conf" > /dev/null ;
description "Sommelier"
start on start-user-session
stop on stopping ui
setuid "chronos"
setgid "chronos"
pre-start script
rm -f "/home/chronos/.Xauthority" 
touch "/home/chronos/.Xauthority"
mkdir -p "/usr/local/var/log"
end script
post-stop script
/usr/local/bin/killall Xwayland || true
/usr/local/bin/pkill -f sommelier.elf || true
[ -r "/usr/local/var/run/sommelier-wayland.pid" ] && /usr/local/bin/pkill -F "/usr/local/var/run/sommelier-wayland.pid" || true
[ -r "/usr/local/var/run/sommelier-xwayland.pid" ] && /usr/local/bin/pkill -F "/usr/local/var/run/sommelier-xwayland.pid" || true
exit 0 ;
end script
exec /usr/local/bin/sommelier.elf -X \\
	--noop-driver \\
	--no-exit-with-child \\
	--direct-scale \\
	--glamor \\
	--display="\${WAYLAND_DISPLAY}" \\
	--x-display="\${DISPLAY}" \\
	--scale="\${SCALE}" \\
	--force-drm-device="\${SOMMELIER_DRM_DEVICE}" \\
	--xwayland-path="/usr/local/bin/Xwayland" \\
	--xwayland-gl-driver-path="/usr/local/lib64/dri" \\
	--peer-cmd-prefix="/usr/local/lib64/ld-linux-x86-64.so.2" \\
	/bin/sh -c "/usr/local/bin/xauth generate :0 . trusted"  2>&1 | tee "/usr/local/var/log/sommelier.log" > /dev/null
respawn
env XDG_CONFIG_HOME=/usr/local/.config
env USER=chronos
env HOME=/home/chronos/user
env SCALE="0.4"
env DISPLAY=:0
env WAYLAND_DISPLAY=wayland-0
env SOMMELIER_ACCELERATORS=Super_L,<Alt>bracketleft,<Alt>bracketright
env SOMMELIER_VM_IDENTIFIER=chromebrew
env SOMMELIER_DRM_DEVICE="${SOMMELIER_DRM_DEVICE}"
env XDG_CONFIG_DIRS="/usr/local/etc/xdg"
env XDG_DATA_HOME="/usr/local/.config/.local/share"
env XDG_CONFIG_HOME="/usr/local/.config"
env XDG_SESSION_TYPE="wayland"
env XDG_CACHE_HOME="/usr/local/.cache"
env XDG_RUNTIME_DIR="/var/run/chrome"
env XDG_DATA_DIRS="/usr/local/share"
env LD_LIBRARY_PATH="/usr/local/lib64"
EOF
sudo initctl start sommelier
rm -f "/usr/local/etc/bash.d/sommelier" "/usr/local/etc/env.d/sommelier"