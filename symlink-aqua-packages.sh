#!/usr/bin/env bash
set -efuo pipefail
if ! aqua --version >/dev/null 2>&1; then
  echo >&2 "ERROR: aqua not found"
  exit 1
fi
: "${AQUA_ROOT_DIR:?Variable not set or empty}"
AQUA_BIN_DIR="${AQUA_ROOT_DIR}/bin"
if [ ! -d "${AQUA_BIN_DIR}" ]; then
  echo >&2 "ERROR: aqua bin directory (${AQUA_BIN_DIR}) does not exist"
  exit 1
fi
while read BIN; do
  if aqua which "${BIN}" >/dev/null  2>&1; then
    SRC="$(aqua which "${BIN}")"
    DST="${XDG_CONFIG_HOME%/*}/bin/${BIN}"
    if [ "${SRC}" != "${DST}"  ]; then
      ( 
        set -x
        ln -sf "${SRC}" "${DST}"
      )
    fi
  fi
done < <(find "${AQUA_BIN_DIR}" -type l -exec basename {} \;)
