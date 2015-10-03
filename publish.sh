#!/bin/bash

MESSAGE=$1

if [ -z "$1" ]; then
    echo "There is no commit message."
    exit 1
fi

LASTTAG=`git describe --abbrev=0 --tags`
NUM=`echo $LASTTAG | sed 's/day\([0-9]*\)/\1/'`
NEXT=$(($NUM + 1))
DAY=`printf "day%03d" $NEXT`

git add -A .
git commit -m "$DAY: $1"
git tag $DAY
git push origin master
git push --tags

zip -r ../day004.zip * -x bin/* publish.sh

