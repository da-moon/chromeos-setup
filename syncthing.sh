#!/usr/bin/env bash
set -efuo pipefail
if ! syncthing  --version >/dev/null  2>&1; then
  if [ -z "$(command -v "aqua" 2>/dev/null)" ]; then
    syncthing --version >/dev/null  2>&1
  elif crew --version >/dev/null 2>&1; then
    yes | crew install syncthing
  fi
fi
if ! syncthing  --version >/dev/null  2>&1; then
  echo >&2 "ERROR: syncthing is not installed"
  exit 1
fi
[ ! -d "${XDG_CONFIG_HOME%/*}/syncthing" ] && mkdir -p "${XDG_CONFIG_HOME%/*}/etc/syncthing"
[ ! -d "${XDG_CONFIG_HOME%/*}/share/syncthing" ] && mkdir -p "${XDG_CONFIG_HOME%/*}/share/syncthing"
# curl -fsSL "https://raw.githubusercontent.com/syncthing/syncthing/main/etc/linux-upstart/system/syncthing.conf" \
#   | envsubst \
#   | sed -r \
#     -e "s/start on .*/start on start-user-session/g" \
#     -e "s/(exec)\s+(.*syncthing)/\1 \2 --no-browser --home=\/usr\/local\/syncthing/g" \
#   | sudo tee "/etc/init/syncthing.conf" >/dev/null
UPSTART_FILE="/etc/init/syncthing.conf"
  cat <<EOF | sudo tee "${UPSTART_FILE}" >/dev/null
description "Syncthing"
start on start-user-session
stop on runlevel [!2345]
respawn
script 
(
  set -x ;
  $(command -v syncthing 2>/dev/null) \
  --no-browser \
  --home=/usr/local/syncthing ;
) > "\$TMPDIR/$(basename -s.conf "${UPSTART_FILE}")-\$(date +'%H-%M-%S-%N').log" 2>&1
end script
env TMPDIR="${TMPDIR}"
env STNORESTART="yes"
env HOME="${HOME}"
setuid "$(id -un)"
setgid "$(id -gn)"
EOF
if [ -n "${AQUA_ROOT_DIR+x}" ] && [ -n "${AQUA_ROOT_DIR}" ]; then
  echo "env AQUA_ROOT_DIR='${AQUA_ROOT_DIR}'" | sudo tee -a "${UPSTART_FILE}" >/dev/null
fi
if [ -n "${AQUA_GLOBAL_CONFIG+x}" ] && [ -n "${AQUA_GLOBAL_CONFIG}" ]; then
  echo "env AQUA_GLOBAL_CONFIG='${AQUA_GLOBAL_CONFIG}'" | sudo tee -a "${UPSTART_FILE}" >/dev/null
fi
sudo initctl stop "$(basename -s.conf "${UPSTART_FILE}")" || true
rm -f "${TMPDIR}/$(basename -s.conf "${UPSTART_FILE}")"* || true
sudo initctl start "$(basename -s.conf "${UPSTART_FILE}")" &
# sleep 3 ;
# cat "${UPSTART_FILE}"
# tail -f "${TMPDIR}/$(basename -s.conf "${UPSTART_FILE}")"*".log"
