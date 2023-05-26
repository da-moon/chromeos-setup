#!/usr/bin/env bash
set -xeuo pipefail
CARCH="$(uname -m)"
if [ "$CARCH" = "i686" ] ; then
  export KEYBASE_SKIP_64_BIT=1
elif [ "$CARCH" = "x86_64" ] ; then
  export KEYBASE_SKIP_32_BIT=1
elif [ "$CARCH" = "aarch64" ] || [ "$CARCH" = "armv7h" ] ; then
  export KEYBASE_BUILD_ARM_ONLY=1
else
  echo "Unknown arch: $CARCH"
  exit 1
fi
# packaging/linux/systemd/keybase.service
srcdir="$(mktemp -d)"
pushd "${srcdir}" > /dev/null 2>&1 \
&& git clone --bare "https://github.com/keybase/client" ".git" \
&& git config --local --bool core.bare false \
&& git reset HEAD -- . \
&& git reset --hard \
&& (
  export KEYBASE_NO_GUI=true ;
  export KEYBASE_NO_GUI="true" ;
  "$srcdir/packaging/linux/build_binaries.sh" prerelease "$srcdir/build_dir" ;
) \
&& find \
  -type f \
  -executable \
  -exec sh -c '
  [ "$(file -b --mime-type {})" ==  "application/x-executable" ] && 
  [ "$(file -b --mime-encoding {})" == "binary" ]
  ' \; -print0 \
| xargs -0 -r -I {} cp "{}" "${XDG_CONFIG_HOME%/*}/bin" \
&& keybase --version \
&& popd > /dev/null 2>&1
