#!/usr/bin/env bash
set -efuo pipefail ;
if ! crew --version >/dev/null 2>&1; then
  echo >&2 "ERROR: chromebrew not found"
  exit 1
fi
if ! syncthing --version  > /dev/null 2>&1; then
  echo >&2 "INFO: syncthing not found. installing ..."
  yes | crew install syncthing
fi
[ ! -d "${XDG_CONFIG_HOME%/*}/syncthing" ] && mkdir -p "${XDG_CONFIG_HOME%/*}/etc/syncthing"
[ ! -d "${XDG_CONFIG_HOME%/*}/share/syncthing" ] && mkdir -p "${XDG_CONFIG_HOME%/*}/share/syncthing"
curl -fsSL "https://raw.githubusercontent.com/syncthing/syncthing/main/etc/linux-upstart/system/syncthing.conf" \
| envsubst \
| sed -r \
  -e "s/start on .*/start on start-user-session/g" \
  -e "s/(exec)\s+(.*syncthing)/\1 \2 --no-browser --home=\/usr\/local\/syncthing/g" \
| sudo tee "/etc/init/syncthing.conf" > /dev/null ;
sudo initctl start syncthing
