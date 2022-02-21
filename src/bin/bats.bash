#!/bin/bash

: "${BASH_SOURCE:?Must Run in BASH}"

basename="${BASH_SOURCE[0]##*/}"

# GIT Super Project Top Level
#
export BATS_TOP

if BATS_TOP="$(git rev-parse --show-superproject-working-tree --show-toplevel)"; then
  cd "$(echo "${BATS_TOP}" | head -1)" || exit
  directory="_${basename}"
  if ! git config -f .gitmodules submodule."${basename}".path &>/dev/null; then
    git submodule add --quiet --name "${basename}" "https://github.com/j5pu/${basename}.git" "${directory}"
    git add .gitmodules
    git commit --quiet -m "submodule: ${basename}"
    git push --quiet
  fi
fi
git submodule update --quiet --init "${directory}"

if [ "${BASH_SOURCE[0]##*/}" = "${0##*/}" ]; then
  "./${directory}/${basename}" "$@"
else
  . "./${directory}/${basename}" "$@"
  unset basename directory
fi
