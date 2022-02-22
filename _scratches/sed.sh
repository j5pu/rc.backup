#!/bin/sh

tmp="$(mktemp)"
# https://www.regular-expressions.info/refquick.html
cat > "${tmp}" <<EOF
+ a
++ aa
aa ++
0
++ a
+ a
a
b
+ a
++ a
EOF

: '
Find 1 or more "^x " would be "{1\}"
Find 2 or more "^x " would be "{1,\}"
Replaces with "debug> &" where "&" includes the matches found.
'
sed 's/^\(+\)\1\{1,\} /debug> &/g; ' "${tmp}"

echo
#sed 's/(?=(a{1,3}))/debug> /g' "${tmp}"; echo $?

sed 's/\b[a]{1,3}\b/debug> /g' "${tmp}"; echo $?
echo
sed -n '/^\+ /p' "${tmp}"

echo
sed -n '/^\+\{1,\} /p' "${tmp}"
echo
sed 's/^\(+\)\1\{0,\} /debug> &/g' "${tmp}"

echo
sed 's/^\(+\)\1\{0,\} /debug> &/g; /^debug> /!s/^/stderr> /g' "${tmp}"  # remembering, !s aplica a los que no son find
echo
sed '/^\+\{0,\} /s/^/debug> /g; /^debug> /!s/^/stderr> /g' "${tmp}"  # finding bit not remembering
echo
grep -m2 '^\+\{0,\} ' "${tmp}"
###################################
: '
-n limit to print the matched (otherwise print matched repeated of all)
'
# sed -n '/a/p' "${tmp}"  #
echo

: '
What does happen here? If we have a char, "packed" in a group (\(.\)), and this group (\1) repeats itself
one or more times (\1\{1,\}), then replace the matched part (&) by its
uppercase version (\U&).

DOES NOT WORK
'
# sed 's/\(.\)\1\{1,\}/\U&/g' "${tmp}" # Two or more
echo

: '
Replace 2 or more a with AAA
'
#sed 's/\(a\)\1\{1,\}/AAA/g' "${tmp}"

echo hola
#sed -n -e '/(?=\([a-z]{1,3}\))/p' "${tmp}"

#sed '/(?=(a{1,3}))/s/a/Z/g' /tmp/5; echo $?
