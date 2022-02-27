# shellcheck shell=sh

# Path with sudo command
SUDOC="$([ ! -x /usr/bin/sudo ] || printf '%s' /usr/bin/sudo)"; export SUDOC
