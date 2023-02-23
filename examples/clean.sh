#!/bin/sh

for dir in `ls -d */ | cut -f1 -d'/'`
do
    echo "Clean $dir ...\c"
    cd $dir
    go clean
    cd ..
    echo " done."
done
