#!/bin/sh

for dir in `ls -d */ | cut -f1 -d'/'`
do
    echo "Compiling $dir ...\c"
    cd $dir
    go clean
    cd ..
    echo " done."
done
