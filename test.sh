#!/bin/sh

tmp="$(mktemp -d)"
A="${tmp}/Ala prueba"; mkdir -p "${A}/bin"
a="${tmp}/hola"; mkdir "${a}"

tmp_d="${tmp}/compat_d"; mkdir "${tmp_d}"

cat > "${tmp_d}"/a <<'EOF'
${A}/bin

${a}
/tmp/nada
EOF

b="${tmp}/Hola subnormal"; mkdir "${b}"
c="${tmp}/c"; mkdir "${c}"
cat > "${tmp_d}"/b <<EOF
${b}

nothing
${c}
EOF
source_dir () {
  if test -d "${1}" && [ -n "$(find "${1}" -maxdepth 1 -type f)" ]; then
    for i in "${1}"/*; do
      # shellcheck disable=SC1090,SC1091
      . "${i}"
    done
    unset files i
  fi
}

cat "${tmp_d}"/*
f () {
  i="$(awk 'NF { print $0 }' "${1}"/* 2>/dev/null | while read -r i; do
    i="$(eval echo "$i")"
    ! test -d "${i}" || printf '%s:' "${i}"
  done)"
  [ "${i-}" ] && printf '%s' "${i%?}"
}

i="$(f "${tmp_d}")"
echo $?
echo "${i}"
#PATH="${PATH}:${i:+:${i}}"

