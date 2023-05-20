#!/usr/bin/env bash
# && git clone --quiet "https://github.com/aquaproj/aqua-registry" "${AQUA_ROOT_DIR}/standard-registry" > /dev/null \
# echo "export AQUA_GLOBAL_CONFIG=\"\${AQUA_ROOT_DIR}/aqua.yaml:\${AQUA_ROOT_DIR}/standard-registry/aqua-all.yaml\" ;" ; \
set -efuo pipefail ;

git rev-parse --is-inside-work-tree >/dev/null 2>&1 ; \
REPO_ROOT="$(git rev-parse --show-toplevel)" ; \
REPO_ROOT="$(readlink -f "${REPO_ROOT}")"; \
ENV_FILE_PATH="${XDG_CONFIG_HOME%/*}/etc/env.d/aqua" ; \
AQUA_ROOT_DIR="${XDG_CONFIG_HOME%/*}/aquaproj-aqua" ; \
# shellcheck disable=SC1090
{ \
  mkdir -p "${AQUA_ROOT_DIR}/bin" "$(dirname "${ENV_FILE_PATH}")" \
  && [ -d "${AQUA_ROOT_DIR}/standard-registry" ] && rm -r "${AQUA_ROOT_DIR}/standard-registry" \
  && { \
    echo "export AQUA_ROOT_DIR=\"${AQUA_ROOT_DIR}\";" ; \
    echo "export AQUA_GLOBAL_CONFIG=\"\${AQUA_ROOT_DIR}/aqua.yaml\" ;" ; \
    echo "export PATH=\"\${AQUA_ROOT_DIR}/bin:\${PATH}\" ;" ; \
  } | tee "${ENV_FILE_PATH}" > /dev/null 2>&1 \
  && chmod +x "${ENV_FILE_PATH}" ; \
} || exit 1 \
&& [ -d "${AQUA_ROOT_DIR}" ] \
&& { \
  chown -R "$(id -u "${USER}"):$(id -g "${USER}")" "${AQUA_ROOT_DIR}" || exit 1 ; 
} || exit 1 \
&& [ -r "${ENV_FILE_PATH}" ] && source "${ENV_FILE_PATH}" || exit 1 \
&& curl \
  -fsSLo - \
  "https://raw.githubusercontent.com/aquaproj/aqua-installer/main/aqua-installer" \
  | bash \
&& aqua -v || exit 1 \
&& { \
  ln -sf "${REPO_ROOT}" "${AQUA_ROOT_DIR}/aqua.yaml" ; \
} || exit 1 ;
# && aqua policy allow "${AQUA_ROOT_DIR}/standard-registry/aqua-policy.yaml" || exit 1 \
# && aqua i -l -a || exit 1 ;
# TODO add upstart job to update registry
# https://aquaproj.github.io/docs/guides/install-all-packages/

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