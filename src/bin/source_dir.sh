#!/bin/sh

#######################################
# sources all files in the first level of a directory, including hidden files
# Arguments:
#  directory    path of directory to source (default: cwd).
#######################################
source_dir () {
  if dir-has-files "${1:-.}"; then
    for i in "${1:-.}"/*; do
      # shellcheck disable=SC1090,SC1091
      . "${i}"
    done
    unset i
  fi
}
