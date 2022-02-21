#!/bin/sh

if test -t 2; then
  EXIT_STDERR="$(mktemp)"
  exec 2>"${EXIT_STDERR}"
  trap print EXIT
fi

#######################################
# set trap and prints stderr on exit if error
# Arguments:
#   None
#######################################
exit_stderr() {
  # set -u err not caught in signal EXIT.
  # if lsof is posix then use: stderr="$(lsof -d2 | grep $$ | awk '{ print $NF }')"
  rc=$?
  if test -s "${EXIT_STDERR-}"; then
    if [ $rc -eq 0 ] && grep -qE ': unbound variable$|: parameter null or not set' "${EXIT_STDERR}"; then rc=1; fi
    if echo $- | grep -q x || [ $rc -ne 0 ]; then
      sed "s/^/$(printf '\e[35m%s' '>')$(printf '\e[0m%s' ' ')/" "${EXIT_STDERR}"
    fi
  fi
  exit "${rc}"
}
