#!/bin/sh

umask 002

# RC completions: sourced by $RC_PROFILE at the end
#
export RC_COMPLETIONS_D="${RC}/completions.d"

# rc.d compat dir: sourced in order ??-*.sh by $RC_PROFILE after $RC_PROFILE_D,
# install here if depend on $RC_PROFILE_D
#
export RC_D="${RC}/rc.d"

# RC $PATH compat dir: sourced in order by $RC_PROFILE after $RC_PROFILE_D,
# they can have a variable already defined in $RC_PROFILE_D
#
export RC_PATHS_D="${RC}/paths.d"

# RC profile.d compat dir: no order or dependencies, sourced by $RC_PROFILE
#
export RC_PROFILE_D="${RC}/profile.d"

# RC share
#
export RC_SHARE="${RC}/share"

. source_dir.sh

source_dir "${RC_PROFILE_D}"

if i="$(dir-to-colon " ${RC_PATHS_D}")"; then
  export PATH="${i}"
fi

if i="$(dir-to-colon /etc/paths.d)"; then
  export PATH="${PATH}:${i}"
fi

unset MANPATH
if i="$(dir-to-colon /etc/manpaths.d)"; then
  export MANPATH="${i}:${MANPATH-}"
fi
if i="$(dir-to-colon "${RC_MANPATHS_D}")"; then
  export MANPATH="${i}:${MANPATH-}"
fi

unset INFOPATH
if i="$(dir-to-colon "${RC_INFOPATHS_D}")"; then
  export INFOPATH="${i}${INFOPATH:+:${INFOPATH}}"
fi

. bash4.sh
source_dir "${RC_D}"
