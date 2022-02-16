#!/bin/sh
echo "$0: $(lsof -d2 | grep $$ | awk '{ print $NF }')"
exec 2>/tmp/trap_sh
echo "$0: $(trap)"
echo "$0: start"
trap print EXIT
echo "$0: $(trap)"

print() {
  echo "$0: $(lsof -d2 | grep $$ | awk '{ print $NF }')"
  echo "$0: exiting"
  echo "$0: $(cat /tmp/trap_sh)"
}
