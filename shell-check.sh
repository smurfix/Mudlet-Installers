#!/bin/bash

function testFile {
  echo "testing $1"
  shellcheck "$1"
  ret=$?
  if [ "$ret" -ne 0 ]; then
    echo "There are problems in $1"
  fi
  return "$ret"
}

result=0
for f in *.sh osx/*.sh generic-linux/*.sh
do
  testFile "$f"
  ret=$?
  let result+=$ret
done

exit "$result"
