# shellcheck shell=sh


# https://github.com/Homebrew/homebrew-command-not-found
#
HB_CNF_HANDLER="${HOMEBREW_TAPS}/homebrew/homebrew-command-not-found/handler.sh"
if $MACOS && [ -f "${HB_CNF_HANDLER}" ]; then
  . "${HB_CNF_HANDLER}"
fi
