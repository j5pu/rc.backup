#!/bin/sh

set -eu

if test -t 2; then
  EXIT_STDERR="$(mktemp)"
  exec 4>&2 2>"${EXIT_STDERR}"
  trap _stderr EXIT
fi

# Sets BASH pipe failure 'set -o pipefail' when 1, set to 0 to disable it (default: 1)
PIPEFAIL="${PIPEFAIL-1}"
# Quiets any stderr/$XTRACE/$XVERBOSE when 1 (default: 0)
QQUIET="${QQUIET-0}"
# Sets shell xtrace 'set -x' when 1 (default: 0)
XTRACE="${XTRACE-0}"
# Sets shell verbose 'set -x' when 1 (default: 0)
XVERBOSE="${XVERBOSE-0}"

[ "${XTRACE-0}" -eq 0 ] || set -x
[ "${XVERBOSE-0}" -eq 0 ] || set -v
# shellcheck disable=SC3040
{ [ ! "${BASH_VERSION-}" ] || [ "${PIPEFAIL-1}" -eq 0 ]; } || {
  set -o pipefail
  pipefail='set +o pipefail'
}

#######################################
# set trap and prints stderr on exit if error
# Globals:
#   EXIT_STDERR
#   PIPEFAIL
#   QQUIET
#   XTRACE
#   XVERBOSE
# Arguments:
#   None
# Examples:
#   PIPEFAIL=0 XTRACE=1 XVERBOSE=1 . exit-stderr.sh
#   QQUIET=1 . exit-stderr.sh
#######################################
_stderr() {
  # set -u err not caught in signal EXIT.
  # if lsof is posix then use: stderr="$(lsof -d2 | grep $$ | awk '{ print $NF }')"
  rc=$?
  ${pipefail-}
  echo $- | grep -qv -E 'x|v' || { set +xv; was_debug=1; }

  ! type realpath >/dev/null || { file="$(realpath /dev/stderr)"; EXIT_STDERR="$(realpath "${EXIT_STDERR-}")"; }
  ! type lsof >/dev/null || file="$(lsof -d2 | grep $$ | awk '{ print $NF }')"
  [ "${file-}" ] || ! type readlink || file="$(readlink -f /dev/stderr)"
  file="${file:-${EXIT_STDERR-}}"
  [ "${file}" = "${EXIT_STDERR-}" ] || print --warning "$0:" "${EXIT_STDERR-}" != "${file}"

  if test -s "${file}"; then
    # Unset debug so grep unbound works and grep + 2 times just in case set -x and set +x was put in the middle.
    grep -qv -m2 '^\+\{0,\} ' "${file}" || was_debug=1

    if [ $rc -eq 0 ] && grep -qE ': unbound variable$|: parameter null or not set' "${file}"; then
      rc=1
    fi

    if { [ "${was_debug-0}" -eq 1 ] || [ $rc -ne 0 ]; } && [ "${QQUIET-0}" -eq 0 ]; then
      sed "s/^\(+\)\1\{0,\} /$(printf '\e[35m%s' 'debug> ') &$(printf '\e[0m%s' '')/g; \
        /^.*\[35mdebug>/!s/^/$(printf '\e[31m%s' 'stderr>')$(printf '\e[0m%s' ' ')/g" "${file}"
    fi
  fi
  exit "${rc}"
}

