#!/usr/bin/env bash
set -efuo pipefail ;
if ! crew --version >/dev/null 2>&1; then
  echo >&2 "ERROR: chromebrew not found"
  exit 1
fi
tmp="$(mktemp -d)" ;
! { crew list installed | grep -qEo 'libseccomp($|\W)' ; } && { yes | crew install "libseccomp" || exit 1 ; } || true \
&& pushd "${tmp}" > /dev/null 2>&1 \
&& (
  set -x \
  && git clone  --quiet --bare "https://github.com/opencontainers/runc.git" ".git" || exit 1 \
  && git config --local --bool "core.bare" "false" || exit 1 \
  && git reset  --quiet --hard "HEAD" || exit 1 ; \
) || exit 1 \
&& ( \
  MAKEFLAGS="-j$(nproc)" \
  && set -x \
  && export CGO_ENABLED="1" \
  && export CGO_LDFLAGS="-g -O2" \
  && export MAKEFLAGS \
  && make BUILDTAGS="seccomp apparmor selinux" || exit 1 ; \
) || exit 1 \
&& ( \
  set -x \
  && install -D -m0755 "runc" "/usr/local/bin/runc" \
  && install -D -m0644 "contrib/completions/bash/runc" "/usr/local/share/bash-completion/completions/runc" ; \
) || exit 1
popd > /dev/null 2>&1 \
&& rm -r "${tmp}" \
&& runc --version ;