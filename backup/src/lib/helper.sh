#!/bin/sh

#
# helper shell library (sets bash strict mode by default).

. ../bin/color.sh#######################################
# show info message with > symbol in grey bold if DEBUG is set to 1, unless QUIET is set to 1
# Globals:
#   DEBUG              Show if DEBUG set to 1, unless QUIET is set to 1 (default: 0).
#   QUIET              Do not show message if set to 1, takes precedence over VERBOSE/DRY_RUN (default: 0).
# Arguments:
#   message            Message to show.
#   --desc             Show description and exit.
#   --help             Show help from man page and exit.
#   --manrepo          Show repository from man page and exit.
#   --version          Show version from man page and exit.
# Optional Arguments:
#   --debug            Show debug messages.
#   --dryrun           Show commands that will be executed.
#   --no-quiet         Do not silent output for commands which silent error by default (git top, etc.).
#   --quiet            Silent output.
#   --verbose          Show verbose messages.
#   --warning          Show warning messages.
# Output:
#   Message to stdout.
#######################################
debug() {
  fromman debug "$@" || exit 0

  # <html><h2>Show Debug Messages</h2>
  # <p><strong><code>$DEBUG</code></strong> (Default: 0).</p>
  # <p><strong><code>Debug messages are shown if set to 1.</code></strong></p>
  # <p>Activate with either of:</p>
  # <ul>
  # <li><code>DEBUG=1</code></li>
  # <li><code>--debug</code></li>
  # </ul>
  # </html>
  DEBUG="${DEBUG:-0}"

  if [ "${QUIET-0}" -ne 1 ] && [ "${DEBUG-}" -eq 1 ]; then
    add=''; content=''; line=''; sep=' '
    sets="$(set +o | tr '\n' ';')"
    set +o nounset  # set +u
    add=""; content=""; suffix=""
    if command -v caller >/dev/null; then
      i=0
      while c="$(caller "${i}")"; do
        if [ "$(echo "${c}" | awk '{ print $2 }')" = 'die' ] \
          || [ "$(basename "$(echo "${c}" | awk '{ print $3 }')")" = 'helper.sh' ]; then
          i="$((i+1))"
        else
          break
        fi
      done
      file="$(basename "$(echo "${c}" | awk '{ print $3 }')")"
      line="$(echo "${c}" | awk '{ print $1 }')"
    fi

    [ "${file-}" ] || file="$(basename "$(psargs '' | awk '{ print $1 }')" 2>/dev/null || true)"
    [ ! "${file-}" ] || add="$(greyinvert "${file}${line:+[${line}]}"): "

    for arg do
      content="${content}${suffix}${arg}=$(eval echo "\$${arg}")"
      suffix=", "
    done

    if [ ! "${content}" ] && [ "${add-}" ]; then
      add="${add%??}" # if no args, remove trailing ": "
    elif [ ! "${content}" ]; then
      sep=''
    fi

    printf '%b\n' "$(greybold '+')${sep}${add}$(greydim "${content}")" >&2
    eval "${sets}"  # set -u, if it was set before
    unset add arg c content sep sets suffix
  fi
}

#######################################
# show message (success or error) with symbol (✓, x respectively) based on status code, unless QUIET is set and exit
# Globals:
#   QUIET              Do not show message if set (but 0), takes precedence over VERBOSE/DRY_RUN (default: unset).
# Arguments:
#   message            Message to show.
#   --desc             Show description and exit.
#   --help             Show help from man page and exit.
#   --manrepo          Show repository from man page and exit.
#   --version          Show version from man page and exit.
# Optional Arguments:
#   --debug            Show debug messages.
#   --dryrun           Show commands that will be executed.
#   --no-quiet         Do not silent output for commands which silent error by default (git top, etc.).
#   --quiet            Silent output.
#   --verbose          Show verbose messages.
#   --warning          Show warning messages.
# Note:
#  Do not use command substitution in the message when false || die.
#  Previous error code is overwritten by the command substitution return code.
#  $ cd "$(dirname "${input}")" 2>/dev/null || die Directory not Found: "$(dirname "${input}")"
# Output:
#   Message to stderr if error and stdout for success.
# Returns:
#   1-255 for error, 0 for success.
#######################################
die() {
  rc=$?
  fromman die "$@" || exit 0

  if [ "${QUIET-0}" -ne 1 ]; then
    case "${rc}" in
      0) success "$@" ;;
      *) error "$@" ;;
    esac
  fi
  exit "${rc}"
}

#######################################
# check if a command exists.
# Arguments:
#   --all               Find all paths.
#   --path              Use path (does not have any effect for: '--all' and '--bin', always searches in $PATH).
#   --value             Show value (does not have any effect for: '--all' and '--bin', always shows value).
#   executable          Executable to check (default: sudo if no image and not executable).
#   image               The image name (default: local).
# Common Arguments:
#   --man               Show help from man page and exit.
#   --desc              Show description and exit.
#   --manrepo           Show repository from man page and exit.
#   --vers              Show version from man page and exit.
# Optional Arguments:
#   --debug             Show debug messages.
#   --dryrun            Show commands that will be executed.
#   --no-quiet          Do not silent output for commands which silent error by default (git top, etc.).
#   --quiet             Silent output.
#   --verbose           Show verbose messages.
#   --warning           Show warning messages.
# Returns:
#   1 if it does not exist.
#######################################
has() {
  fromman has "$@" || exit 0

  doc() { docker run -i --rm --entrypoint sh "${image}" -c "${1}"; }
  unset executable
  all=false; path=false; value=false
  unset image
  for arg; do
    case "${arg}" in
      -a|--all) all=true; value=true ;;
      -p|--path) path=true ;;
      -v|--value) value=true ;;
      -pv|-vp) path=true; value=true ;;
      -*) false || die Invalid Option: "${arg}";;
      *)
        if [ "${executable-}" ]; then
          image="${arg}"
        elif [ "${arg:-}" != '' ]; then
          executable="${arg}"
        fi
        ;;
    esac
  done

  executable="${executable:-sudo}"

  if [ "${image-}" ]; then
    docker --version >/dev/null || exit
    if $all; then
      rv="$(doc "which -a ${executable} || type -aP ${executable} || true")"
    elif $path; then
      rv="$(doc "{ which ${executable} || type -P ${executable}; } | head -1 || true")"
    else
      rv="$(doc "command -v ${executable} || true")"
    fi
  else
    if $all; then
      # shellcheck disable=SC3045
      rv="$(which -a "${executable}" || type -aP "${executable}" || true)"
    elif $path; then
      # shellcheck disable=SC3045
      rv="$({ which "${executable}" || type -P "${executable}"; } | head -1 || true)"
    else
      rv="$(command -v "${executable}" || true)"
    fi
  fi

  if [ "${rv-}" ] && $all; then
    tmp="$(mktemp)"
    for i in ${rv}; do
      r="$(real --resolved "${i}")"
      grep -q "^${r}$" "${tmp}" || echo "${r}" >> "${tmp}"
    done
    cat "${tmp}"
  elif [ "${rv-}" ]; then
    ! $value || echo "${rv}"
  else
    unset rv; unset -f doc
    return 1 2>/dev/null || exit 1
  fi
  unset all executable i path rv value; unset -f doc
}

#######################################
# show error message with x symbol in red, unless QUIET is set to 1
# Globals:
#   QUIET              Do not show message if set to 1, takes precedence over VERBOSE/DRY_RUN (default: 0).
# Arguments:
#   message            Message to show.
#   --desc             Show description and exit.
#   --help             Show help from man page and exit.
#   --manrepo          Show repository from man page and exit.
#   --version          Show version from man page and exit.
# Optional Arguments:
#   --debug            Show debug messages.
#   --dryrun           Show commands that will be executed.
#   --no-quiet         Do not silent output for commands which silent error by default (git top, etc.).
#   --quiet            Silent output.
#   --verbose          Show verbose messages.
#   --warning          Show warning messages.
# Output:
#   Message to stderr.
#######################################
error() {
  fromman error "$@" || exit 0

  # <html><h2>Silent Output</h2>
  # <p><strong><code>$QUIET</code></strong> (Default: 0).</p>
  # <p><strong><code>The following messages are shown if set to 0:</code></strong></p>
  # <ul>
  # <li><code>error</code></li>
  # <li><code>success</code></li>
  # </ul>
  # <p><strong><code>If set to 0, other messages are shown base on the variable value:</code></strong></p>
  # <ul>
  # <li><code>debug</code>: $DEBUG</li>
  # <li><code>verbose</code>: $VERBOSE</li>
  # <li><code>warning</code>: $WARNING</li>
  # </ul>
  # <p>Activate with either of:</p>
  # <ul>
  # <li><code>QUIET=1</code></li>
  # <li><code>--quiet</code></li>
  # </ul>
  # <p><strong><code>Note:</code></strong></p>
  # <p>Takes precedence over $DEBUG, $VERBOSE and $WARNING.</p>
  # </html>
  QUIET="${QUIET:-0}"

  if [ "${QUIET-0}" -ne 1 ]; then
    add=''; line=''; sep=' '
    if command -v caller >/dev/null; then
      i=0
      while c="$(caller "${i}")"; do
        if [ "$(echo "${c}" | awk '{ print $2 }')" = 'die' ] \
          || [ "$(basename "$(echo "${c}" | awk '{ print $3 }')")" = 'helper.sh' ]; then
          i="$((i+1))"
        else
          break
        fi
      done
      file="$(basename "$(echo "${c}" | awk '{ print $3 }')")"
      line="$(echo "${c}" | awk '{ print $1 }')"
    fi

    [ "${file-}" ] || file="$(basename "$(psargs '' | awk '{ print $1 }')" 2>/dev/null || true)"
    [ ! "${file-}" ] || add="$(redbg "${file}${line:+[${line}]}"): "

    if [ "$#" -eq 0 ] && [ "${add-}" ]; then
      add="${add%??}" # if no args, remove trailing ": "
    elif [ "$#" -eq 0 ]; then
      sep=''
    fi

    if [ "${WHITE-}" ]; then
       [ ! "${add}" ] || printf '%b\n' "$(redbold "x${sep}${add}")" >&2
      [ "$#" -eq 0 ] || echo "$@" >&2
    else
       printf '%b\n' "$(redbold 'x')${sep}${add}$(redbold "$*")" >&2
    fi

    unset add c file line sep
  fi
}

#######################################
# parse common long optional arguments.
# Output:
#   Message to stderr if error and stdout for success.
# Arguments:
#   --desc             Show description and exit.
#   --help             Show help from man page and exit.
#   --manrepo          Show repository from man page and exit.
#   --version          Show version from man page and exit.
# Optional Arguments:
#   --debug            Show debug messages.
#   --dryrun           Show commands that will be executed.
#   --no-quiet         Do not silent output for commands which silent error by default (git top, etc.).
#   --quiet            Silent output.
#   --verbose          Show verbose messages.
#   --warning          Show warning messages.
#   --white            Multi line error message.
# Returns:
#   1-255 for error, 0 for success.
#######################################
parse() {
  case "${1-}" in
    --no-quiet) eval 'QUIET=0' ;;
    --debug|--dry-run|--qquiet|--quiet|--verbose|--warning|--white)
      eval "$(echo "${arg#--}" | tr '[:lower:]' '[:upper:]' | sed 's/-/_/')=1" ;;
    --*) fromman parse "$@" || exit 0 ;;
  esac
}

#######################################
# parent process args (cmd/command and args part of ps)
# if in a subshell or cmd of the current shell if running in a subshell.
# $$ is defined to return the process ID of the parent in a subshell; from the man page under "Special Parameters":
# expands to the process ID of the shell. In a () subshell, it expands to the process ID of the current shell,
# not the subshell.
# Arguments:
#   --desc             Show description and exit.
#   --help             Show help from man page and exit.
#   --manrepo          Show repository from man page and exit.
#   --version          Show version from man page and exit.
# Outputs:
#   Process (ps) args.
# Returns:
#   1 if error during installation of procps or not know to install ps or --usage and not man page.
#######################################
psargs() {
  fromman psargs "$@" || exit 0

  if command -v ps >/dev/null; then
    if ! ps -p $$ -o args= 2>/dev/null; then
      ps -o pid= -o args= | awk '/$$/ { $1=$1 };1' | grep "^$$ " | cut -d '' -f 2-
    fi
  fi
}

#######################################
# show message based on return code
# Arguments:
#   [--warning]   print warning
# Returns:
#   based on previous exit code
#######################################
show() (
  rc=$?
  export PROMPT_EOL_MARK=''
  warn='--warning'
  [ "$1" != "${warn}" ] || { rc="${warn}"; shift; }
  case $rc in
    "${warn}") yellowbold ！; rc=0 ;;
    0) greenbold ✔ ;;
    *) redbold ✘ ;;
  esac
  printf '%s\n' " $*"
  exit $rc
)

#######################################
# trap set by 'stderr' function to show stderr on EXIT and format output based on stderr and/or 'set -x' for posix
# Globals:
#   EXIT_STDERR
#   QQUIET
#   SETOPTS
# Arguments:
#   None
#######################################
_stderr() {
  # set -u err not caught in signal EXIT.
  # if lsof is posix then use: stderr="$(lsof -d2 | grep $$ | awk '{ print $NF }')"
  rc=$?
  set +xv
  ! grep -q -E 'set \+x|set \+v' "${SETOPTS-}" 2>/dev/null || was_debug=1

  # Quiets any stderr/$XTRACE/$XVERBOSE when 1 (default: 0)
  #
  QQUIET="${QQUIET-0}"

  if test -s "${EXIT_STDERR-}"; then
    # Unset debug so grep unbound works and grep + 2 times just in case set -x and set +x was put in the middle.
    grep -qv -m2 '^\+\{0,\} ' "${EXIT_STDERR}" || was_debug=1

    if [ $rc -eq 0 ] && grep -qE ': unbound variable$|: parameter null or not set' "${EXIT_STDERR}"; then
      rc=1
    fi
    if { [ "${was_debug-0}" -eq 1 ] || [ $rc -ne 0 ]; } && [ "${QQUIET-0}" -eq 0 ]; then
      sed "s/^\(+\)\1\{0,\} /$(magentabold 'debug>')  &/g; \
        /^.*\[.*debug>/!s/^/$(redbold 'stderr>') /g" "${EXIT_STDERR}"
    fi
  fi
  exit "${rc}"
}

#######################################
# sets trap with '_stderr' function on EXIT and redirects stderr to FD 4
# Globals:
#   EXIT_STDERR
# Examples:
#   . helpers.sh && stderr
#   STDERR=1 . helpers.sh
# Caution:
#   New different shell can not be started when stderr is redirected (i.e.: from zsh starting bash)
#   New shells inherit 'test -t 2' (exec also maintains the redirect), therefore $EXIT_STDERR exported.
#######################################
stderr() {
  xtrace
  if test -t 2; then
    EXIT_STDERR="$(mktemp)"; export EXIT_STDERR
    exec 4>&2 2>"${EXIT_STDERR}"
    trap _stderr EXIT
  fi
}

strict() {
  # File with commands to be executed to restore shell opts with '. "${SETOPTS-}"'
  #
  export SETOPTS
  [ "${SETOPTS-}" ] || SETOPTS="$(mktemp)"

  # <html><h2>Bash Strict Mode</h2>
  # <p><strong><code>$STRICT</code></strong> set to 0 when sourcing helper.sh to not set strict mode (Default: 1).</p>
  # <h3>Examples</h3>
  # <dl>
  # <dt>No strict mode:</dt>
  # <dd>
  # <pre><code class="language-bash">STRICT=0 . helper.sh
  # </code></pre>
  # </dd>
  # </dl>
  # <h3>Links</h3>
  # <ul>
  # <li><a href="http://redsymbol.net/articles/unofficial-bash-strict-mode/">Unofficial Bash Strict Mode</a></li>
  # </ul>
  # </html>
  STRICT="${STRICT:-1}"

  if [ "${STRICT-1}" -eq 1 ] && [ ! "${PS1-}" ]; then
    echo "set +eu" > "${SETOPTS}"
    set -eu
    if [ "${BASH_VERSION-}" ]; then
      # SHELLOPTS exported for BASH so that new shells inherit '-x'
      export SHELLOPTS
      # shellcheck disable=SC3040
      set -o pipefail
      echo "set +o pipefail" >> "${SETOPTS}"
      . "${SETOPTS}"
      # shellcheck disable=SC3028,SC3054
      [ ! "${BASH_VERSINFO[0]}" -gt 4 ] \
        || { shopt -s inherit_errexit; echo "shopt -u inherit_errexit" >> "${SETOPTS}"; }
    fi
  fi

  # Sets shell xtrace 'set -x' when 1 (default: 0)
  XTRACE="${XTRACE-0}"
  [ "${XTRACE-0}" -eq 0 ] || set -x

  # Sets shell verbose 'set -x' when 1 (default: 0)
  XVERBOSE="${XVERBOSE-0}"
  [ "${XVERBOSE-0}" -eq 0 ] || set -v
}

#######################################
# show success message in white with green ✓ symbol, unless QUIET is set to 1
# Globals:
#   QUIET              Do not show message if set to 1, takes precedence over VERBOSE/DRY_RUN (default: 0).
# Arguments:
#   message            Message to show.
#   --desc             Show description and exit.
#   --help             Show help from man page and exit.
#   --manrepo          Show repository from man page and exit.
#   --version          Show version from man page and exit.
# Optional Arguments:
#   --debug            Show debug messages.
#   --dryrun           Show commands that will be executed.
#   --no-quiet         Do not silent output for commands which silent error by default (git top, etc.).
#   --quiet            Silent output.
#   --verbose          Show verbose messages.
#   --warning          Show warning messages.
# Output:
#   Message to stdout.
#######################################
success() {
  fromman success "$@" || exit 0

  if [ "${QUIET-0}" -ne 1 ]; then
    sep=''
    [ "$#" -eq 0 ] || sep=' '
    printf '%b\n' "$(greenbold '✓')${sep}$*"
    unset sep
  fi
}

#######################################
# show verbose/dry-run message with > symbol in grey dim if VERBOSE or DRY_RUN are set, unless QUIET is set to 1
# Globals:
#   DRY_RUN            Show message if set to 1, unless QUIET is set to 1 (default: 0).
#   QUIET              Do not show message if set to 1, takes precedence over VERBOSE/DRY_RUN (default: 0).
#   VERBOSE            Shows message if set to 1, unless QUIET is set to 1 (default: 0).
# Arguments:
#   message            Message to show.
#   --desc             Show description and exit.
#   --help             Show help from man page and exit.
#   --manrepo          Show repository from man page and exit.
#   --version          Show version from man page and exit.
# Optional Arguments:
#   --debug            Show debug messages.
#   --dryrun           Show commands that will be executed.
#   --no-quiet         Do not silent output for commands which silent error by default (git top, etc.).
#   --quiet            Silent output.
#   --verbose          Show verbose messages.
#   --warning          Show warning messages.
# Output:
#   Message to stdout.
#######################################
verbose() {
  fromman verbose "$@" || exit 0

  # <html><h2>Dry Run</h2>
  # <p><strong><code>$DRY_RUN</code></strong> (Default: 0).</p>
  # <p>Activate with either of:</p>
  # <ul>
  # <li><code>DRY_RUN=1</code></li>
  # <li><code>--dryrun</code></li>
  # </ul>
  # </html>
  DRY_RUN="${DRY_RUN:-0}"

  # <html><h2>Show Verbose Messages</h2>
  # <p><strong><code>$VERBOSE</code></strong>  (Default: 0).</p>
  # <p><strong><code>Verbose messages are shown if set to 1.</code></strong></p>
  # <p>Activate with either of:</p>
  # <ul>
  # <li><code>VERBOSE=1</code></li>
  # <li><code>--verbose</code></li>
  # </ul>
  # </html>
  VERBOSE="${VERBOSE:-0}"

  if [ "${QUIET-0}" -ne 1 ] && { [ "${VERBOSE}" -eq 1 ] || [ "${DRY_RUN-}" -eq 1 ]; }; then
    sep=''
    [ "$#" -eq 0 ] || sep=' '
    printf '%b\n' "$(cyanbold '>')${sep}$(cyandim "$*")"
    unset sep
  fi
}

#######################################
# trap set by 'xtrace' function to show FD 19 on EXIT for bash
# Globals:
#   EXIT_XTRACE
#   QQUIET
# Arguments:
#   None
#######################################
_xtrace() {
  if test -s "${EXIT_XTRACE-}" && [ "${QQUIET-0}" -eq 0 ]; then
    sed "s/^\(+\)\1\{0,\} /$(magentabold 'debug>')  &/g" "${EXIT_XTRACE}"
  fi
}

#######################################
# sets trap with '_xtrace' function on EXIT and redirects 'set -x' to FD 19 for BASH
# Globals:
#   EXIT_XTRACE
# Arguments:
#   None
# Examples:
#   . helpers.sh && xtrace
#######################################
xtrace() {
  if [ "${BASH_VERSION-}" ] && [ ! "${EXIT_XTRACE-}" ]; then
    EXIT_XTRACE="$(mktemp)"; export EXIT_XTRACE
    # shellcheck disable=SC3023
    exec 19>"${EXIT_XTRACE}"
    export BASH_XTRACEFD=19
    trap _xtrace EXIT
  fi
}

#######################################
# show warning message with ! symbol in yellow if WARNING is set to 1, unless QUIET is set to 1
# Globals:
#   QUIET              Do not show message if set to 1, takes precedence over VERBOSE/DRY_RUN (default: 0).
#   WARNING            Shows message if is set to 1, unless QUIET is set to 1 (default: 0).
# Arguments:
#   message            Message to show.
#   --desc             Show description and exit.
#   --help             Show help from man page and exit.
#   --manrepo          Show repository from man page and exit.
#   --version          Show version from man page and exit.
# Optional Arguments:
#   --debug            Show debug messages.
#   --dryrun           Show commands that will be executed.
#   --no-quiet         Do not silent output for commands which silent error by default (git top, etc.).
#   --quiet            Silent output.
#   --verbose          Show verbose messages.
#   --warning          Show warning messages.
# Output:
#   Message to stderr.
#######################################
warning() {
  fromman warning "$@" || exit 0

  # <html><h2>Show Warning Messages</h2>
  # <p><strong><code>$WARNING</code></strong>  (Default: 0).</p>
  # <p><strong><code>Warning messages are shown if set to 1.</code></strong></p>
  # <p>Activate with either of:</p>
  # <ul>
  # <li><code>WARNING=1</code></li>
  # <li><code>--warning</code></li>
  # </ul>
  # </html>
  WARNING="${WARNING:-0}"

  if [ "${QUIET-0}" -ne 1 ] && [ "${WARNING}" -eq 1 ]; then
    add=''; line=''; sep=' '
    if command -v caller >/dev/null; then
      i=0
      while c="$(caller "${i}")"; do
        if [ "$(echo "${c}" | awk '{ print $2 }')" = 'die' ] \
          || [ "$(basename "$(echo "${c}" | awk '{ print $3 }')")" = 'helper.sh' ]; then
          i="$((i+1))"
        else
          break
        fi
      done
      file="$(basename "$(echo "${c}" | awk '{ print $3 }')")"
      line="$(echo "${c}" | awk '{ print $1 }')"
    fi

    [ "${file-}" ] || file="$(basename "$(psargs '' | awk '{ print $1 }')" 2>/dev/null || true)"
    [ ! "${file-}" ] || add="$(yellowinvert "${file}${line:+[${line}]}"): "

    if [ "$#" -eq 0 ]&& [ "${add-}" ]; then
      add="${add%??}" # if no args, remove trailing ": "
    elif [ "$#" -eq 0 ]; then
      sep=''
    fi

    printf '%b\n' "$(yellowbold '!')${sep}${add}$(yellowbold "$*")" >&2
    unset add c file line sep
  fi
}

[ "${STDERR-0}" -eq 0 ] || stderr
strict

####################################### Executed
#
if ! echo "${ZSH_EVAL_CONTEXT:-${0##*/}}" | grep -qE ":file$|^bash$|^dash$|^sh$"; then
  fromman "$0" "$@" || exit 0
fi
