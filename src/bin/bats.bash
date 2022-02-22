#!/bin/bash

: "${BASH_SOURCE:?Must Run in BASH}"

basename="${BASH_SOURCE[0]##*/}"

# GIT Super Project Top Level
#
export BATS_TOP

if BATS_TOP="$(git rev-parse --show-superproject-working-tree --show-toplevel)"; then
  cd "$(echo "${BATS_TOP}" | head -1)" || exit
  if ! git config -f .gitmodules submodule."${basename}".path &>/dev/null; then
    git submodule add --branch main --quiet --name "${basename}" "https://github.com/j5pu/${basename}.git" "${basename}"
    git add .gitmodules
    git commit --quiet -m "submodule: ${basename}"
    git push --quiet
  fi
fi
git submodule update --quiet --remote"${basename}"

if [ "${BASH_SOURCE[0]##*/}" = "${0##*/}" ]; then
  "./${basename}/bin/${basename}" "$@"
else
  . "./${basename}/bin/${basename}" "$@"
  unset basename
fi
