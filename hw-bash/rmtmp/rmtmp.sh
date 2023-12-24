#!/bin/bash

# Deletes all .tmp, .bak, .backup files in a directory specified in the 1st argument of the script.

if [ ! $# -eq 1 ]; then
    echo "Expected a path to a directory. Got $# arguments. Operation aborted"
    exit 1
fi

if [ ! -d $1 ]; then
    echo "'$1' is no a directory. Operation aborted."
    exit 2
fi

pushd $1 1>/dev/null

for ext in {bak,backup,tmp}; do
    if [ -f *.$ext ]; then
        echo "Removing '*.$ext' files."
        rm *.$ext
    else
        echo "No '*.$ext' files."
    fi
done

popd 1>/dev/null

