#!/usr/bin/env -S bash --noprofile --norc

set -euo pipefail

git rev-parse --is-inside-work-tree >/dev/null 2>&1
REPO_ROOT="$(git rev-parse --show-toplevel)"
REPO_ROOT="$(readlink -f "${REPO_ROOT}")"
ENV_FILE_PATH="${XDG_CONFIG_HOME%/*}/etc/env.d/aqua"
AQUA_ROOT_DIR="${AQUA_ROOT_DIR:-${XDG_CONFIG_HOME%/*}/aquaproj-aqua}"
AQUA_STANDARD_REGISTRY_PATH="${AQUA_STANDARD_REGISTRY_PATH:-${AQUA_ROOT_DIR}/standard-registry}"
{
  mkdir -p "${AQUA_ROOT_DIR}/bin" "$(dirname "${ENV_FILE_PATH}")" \
    && {
      echo "export AQUA_ROOT_DIR=\"${AQUA_ROOT_DIR}\";"
      echo "export AQUA_STANDARD_REGISTRY_PATH=\"${AQUA_STANDARD_REGISTRY_PATH}\";"
      echo "export AQUA_GLOBAL_CONFIG=\"\${AQUA_STANDARD_REGISTRY_PATH}/aqua-all.yaml\" ;"
      echo "export PATH=\"\${AQUA_ROOT_DIR}/bin:\${PATH}\" ;"
    } | tee "${ENV_FILE_PATH}" >/dev/null 2>&1 \
    && chmod +x "${ENV_FILE_PATH}"
} || exit 1
  [ -d "${AQUA_ROOT_DIR}" ] && {
  chown -R "$(id -u "${USER}"):$(id -g "${USER}")" "${AQUA_ROOT_DIR}" || exit 1
} || exit 1
[ -r "${ENV_FILE_PATH}" ] && source "${ENV_FILE_PATH}" || exit 1
[ -z "$(command -v "aqua")" ] && {
  curl \
    -fsSLo - \
    "https://raw.githubusercontent.com/aquaproj/aqua-installer/main/aqua-installer" \
    | bash \
    && aqua -v >/dev/null 2>&1 || exit 1
}
[ ! -d "${AQUA_STANDARD_REGISTRY_PATH}" ] \
  && git clone --quiet "https://github.com/aquaproj/aqua-registry" "${AQUA_STANDARD_REGISTRY_PATH}"
  pushd "${AQUA_STANDARD_REGISTRY_PATH}" >/dev/null  2>&1
  git reset --hard >/dev/null  2>&1
  git pull >/dev/null  2>&1
  aqua policy allow "aqua-policy.yaml" || exit 1
  popd >/dev/null 2>&1
# shellcheck disable=SC1090
# NOTE: we are using sed for OS detection because default grep
# in chromeos is built with --disable-perl-regexp flag; this
# means that -P flag cannot be used but with sed, we can isolate
# ID value in `/etc/os-release` without any issues
if [ "$(sed -nr -e '/^ID=/{s/ID=//p}' '/etc/os-release')" == "chromeos" ]; then
  [ -r "${REPO_ROOT}.aqua.yaml" ] && {
    ln -sf "${REPO_ROOT}" "${AQUA_ROOT_DIR}/aqua.yaml"
  }
  UPSTART_FILE="/etc/init/aqua.conf"
  cat <<EOF | sudo tee "${UPSTART_FILE}" >/dev/null
description "service for updating aqua after logging in"
start on start-user-session
task
script
(
  if [ -r "$(command -v aqua)" ];then
    if [ -d "${AQUA_STANDARD_REGISTRY_PATH}" ] && [ -r "${AQUA_STANDARD_REGISTRY_PATH}/aqua-policy.yaml" ] ; then
      (
        set -x ;
        $(command -v git) -C "${AQUA_STANDARD_REGISTRY_PATH}" reset --hard >/dev/null  2>&1 ;
        $(command -v git) -C "${AQUA_STANDARD_REGISTRY_PATH}" pull  >/dev/null  2>&1 ;
        $(command -v aqua) policy allow "${AQUA_STANDARD_REGISTRY_PATH}/aqua-policy.yaml" || exit 1 ;
      ) ;
    fi ;
    (
      set -x ;
      $(command -v aqua) update-aqua ;
      $(command -v aqua) i -l -a ;
    ) ;
    for BIN in \$($(command -v find) "\${AQUA_ROOT_DIR}/bin" -type l);do
      BIN="\$(basename "\${BIN}")" ;
      if $(command -v aqua) which "\${BIN}" >/dev/null  2>&1; then
        SRC="\$($(command -v aqua) which "\${BIN}")" ;
        DST="${XDG_CONFIG_HOME%/*}/bin/\${BIN}" ;
        if [ "\${SRC}" != "\${DST}"  ]; then
          (
            set -x ;
            $(command -v ln) -sf "\${SRC}" "\${DST}" ;
          ) ;
       fi
     fi ;
  done ;
fi ;
) > "\$TMPDIR/$(basename -s.conf "${UPSTART_FILE}")-\$(date +'%H-%M-%S-%N').log" 2>&1
end script
setuid "$(id -un)"
setgid "$(id -un)"
chdir "${TMPDIR}"
env AQUA_ROOT_DIR="${AQUA_ROOT_DIR}"
env AQUA_GLOBAL_CONFIG="${AQUA_GLOBAL_CONFIG}"
env TMPDIR="${TMPDIR}"
EOF
  if [ -n "${GITHUB_TOKEN+x}" ] && [ -n "${GITHUB_TOKEN}" ]; then
    echo "env GITHUB_TOKEN='${GITHUB_TOKEN}'" | sudo tee -a "/etc/init/aqua.conf" >/dev/null
  fi
  sudo initctl stop "$(basename -s.conf "${UPSTART_FILE}")" || true
  rm -f "${TMPDIR}/$(basename -s.conf "${UPSTART_FILE}")"* || true
  sudo initctl start "$(basename -s.conf "${UPSTART_FILE}")" &
  # sleep 3 ;
  # tail -f "${TMPDIR}/$(basename -s.conf "${UPSTART_FILE}")"*".log"
fi

# https://stackoverflow.com/a/20774563
# AQUA_REGISTRY_REF="$( \
# curl -fsSLo - \
#   "https://api.github.com/repos/aquaproj/aqua-registry/releases/latest" \
# | sed -rn -e '/tag_name/{
#   s/tag_name//g;
#   s/[,":[:space:]]*//g ;
#   p;
#   }'
# )" \
# && { \
#   echo "registries:" ; \
#   echo "- type: standard" ; \
#   echo "  ref: ${AQUA_REGISTRY_REF}"; \
# } | tee "${AQUA_GLOBAL_CONFIG}" > /dev/null 2>&1 \
