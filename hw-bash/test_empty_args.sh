#!/bin/bash +e

echo "Test 'empty args' started."

./del_tmp.sh > /dev/null 2>&1
retcode=$?
if [ ! $retcode -eq 1 ]; then
    echo "Expexted retcode 1. Got '$retcode'."
    exit 1
fi

echo "Test 'empty args' passed."

