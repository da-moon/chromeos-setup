#!/usr/bin/env bash
set -xeuo pipefail
if ! crew --version >/dev/null 2>&1; then
  echo >&2 "ERROR: chromebrew not found"
  exit 1
fi
if [ -z "$(command -v "pinentry")" ]; then
  yes | crew install pinentry
fi
CARCH="$(uname -m)"
if [ "$CARCH" = "i686" ]; then
  export KEYBASE_SKIP_64_BIT=1
elif [ "$CARCH" = "x86_64" ]; then
  export KEYBASE_SKIP_32_BIT=1
elif [ "$CARCH" = "aarch64" ] || [ "$CARCH" = "armv7h" ]; then
  export KEYBASE_BUILD_ARM_ONLY=1
else
  echo "Unknown arch: $CARCH"
  exit 1
fi
# packaging/linux/systemd/keybase.service
srcdir="$(mktemp -d)"
pushd "${srcdir}" >/dev/null  2>&1 \
  && git clone --bare "https://github.com/keybase/client" ".git" \
  && git config --local --bool core.bare false \
  && git reset HEAD -- . \
  && git reset --hard \
  && (
    export CGO_ENABLED=1
    export CGO_LDFLAGS="-g -O2"
    export KEYBASE_NO_GUI=true
    export KEYBASE_NO_GUI="true"
    "$srcdir/packaging/linux/build_binaries.sh" prerelease "$srcdir/build_dir"
  ) \
  && find \
    -type f \
    -executable \
    -exec sh -c ' \
  { \
    [ "$(file -b --mime-type "{}")" = "application/x-executable" ] \
    || [ "$(file -b --mime-type "{}")" = "application/x-pie-executable" ] ; \
  } && [ "$(file -b --mime-encoding "{}")" = "binary" ]' \; \
    -print0 \
  | xargs -0 -r -I {} cp "{}" "${XDG_CONFIG_HOME%/*}/bin" \
  && keybase --version \
  && popd >/dev/null 2>&1
  # NOTE: for non-chromeos systemd machines
  if systemctl --version > /dev/null 2>&1 ; then
    SERVICES=($(find "packaging/linux/systemd" -type f -name '*.service' -exec sh -c 'basename {}'  \;))
    sudo cp packaging/linux/systemd/*.service "/usr/lib/systemd/user" ;
    find \
    -type f \
    -executable \
    -exec sh -c ' \
    { \
      [ "$(file -b --mime-type "{}")" = "application/x-executable" ] \
      || [ "$(file -b --mime-type "{}")" = "application/x-pie-executable" ] ; \
    } && [ "$(file -b --mime-encoding "{}")" = "binary" ] \
    && basename {}' \; \
    | sudo xargs -r -I {} ln -sf "/usr/local/bin/{}" "/usr/bin/{}" ;
    sudo systemctl daemon-reload
    sudo systemctl --machine="$(id -un)@.host" --user daemon-reload
    for SERVICE in "${SERVICES[@]}"; do
      systemctl --machine="$(id -un)@.host" --user enable --now "${SERVICE}"
    done
  fi
