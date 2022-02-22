#!/bin/sh
if test -t 2; then
  echo entro
  exec 3>&2 2>/tmp/trap_sh
  trap print EXIT
fi
echo "$0: $(lsof -d2 | grep $$ | awk '{ print $NF }')"
echo "$0: $(trap)"
echo "$0: start"
>&2 echo Was Sent to STDERR when exec 2 /tmp/trap_sh
echo "$0: $(trap)"

print() {
  echo "$0: $(lsof -d2 | grep $$ | awk '{ print $NF }')"
  echo "$0: exiting"
  echo "$0: cat /tmp/trap_sh:"
  cat /tmp/trap_sh
  exec 2>&3 3>&-
  echo "$0: FD 3: closed"
  >&2 echo Was Sent to STDERR when FD was closed
  echo "$0: cat /tmp/trap_sh (does not have what it was sent after closing FD):"
  cat /tmp/trap_sh
}
