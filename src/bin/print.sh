#!/bin/sh

#######################################
# print message base on exit code and exit
# Arguments:
#   [--warning]   print warning
# Returns:
#   based on previous exit code
#######################################
print() (
  rc=$?
  export PROMPT_EOL_MARK=''
  warn='--warning'
  [ "$1" != "${warn}" ] || { rc="${warn}"; shift; }
  case $rc in
    "${warn}") printf '\e[33m%s' ！;;
    0) printf '\e[32m%s' ✔ ;;
    *)
      printf '\e[31m%s' ✘
      exit="exit $rc"
      ;;
  esac
  printf '\e[0m%s\n' " $*"
  eval "${exit-}"
)
