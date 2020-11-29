#!/usr/bin/env bash

# Get the value of the symbol name suppied

FILE_CONTENTS1=$(cat "$1" | cut -f1)
FILE_CONTENTS2=$(cat "$1" | cut -f2)
FILE_CONTENTS3=$(cat "$1" | cut -f3)
FILE_CONTENTS4=$(cat "$1" | cut -f4)
FILE_CONTENTS=$(echo "$FILE_CONTENTS1"; echo "$FILE_CONTENTS2"; echo "$FILE_CONTENTS3"; echo "$FILE_CONTENTS4")

pat="\b(....)\s(${2})\b"

while IFS="" read -r p || [ -n "$p" ]
do
  if [[ "$p" =~ $pat ]]; then
    val=${BASH_REMATCH[1]}
    printf "%d" $((16#$val))
    exit 0
  fi

done  < <(printf '%s\n' "$FILE_CONTENTS")

exit -1
