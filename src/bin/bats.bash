#!/bin/bash

: "${BASH_SOURCE:?Must Run in BASH}"

basename="${BASH_SOURCE[0]##*/}"
top="$(git super)"

: "${top:?Must be Run from a GIT Repository}"
export GIT_QUIET=1
if ! git -C "${top}" config -f .gitmodules "submodule.${basename}.path" &>/dev/null; then
  git -C "${top}" submodule add --branch main --quiet --name "${basename}" \
    "https://github.com/j5pu/${basename}.git" "${basename}"
  git -C "${top}" add .gitmodules
  git -C "${top}" commit --quiet -a -m "submodule: ${basename}"
  git -C "${top}" push --quiet
fi

git -C "${top}" submodule --quiet update --remote "${basename}" 2>/tmp/.submodule

if [ "${BASH_SOURCE[0]##*/}" = "${0##*/}" ]; then
  "${top}/${basename}/bin/${basename}" "$@"
else
  . "${top}/${basename}/bin/${basename}" "$@"
  unset basename
fi
