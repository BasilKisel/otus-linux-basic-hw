#!/bin/bash

echo "$0: test started."

export CHRESOLV_STUB_FILE=./test_unreadable_resolve.conf
touch "$CHRESOLV_STUB_FILE"
chmod 222 "$CHRESOLV_STUB_FILE"

ns1="77.88.8.8"
ns2="77.88.8.1"
./chresolv.sh "$ns1" "$ns2" > /dev/null
retcode=$?
if [ $retcode -ne 4 ]
then
    echo "$0: expected retcode '4', got '$retcode'"
    exit 1
fi

rm -f "$CHRESOLV_STUB_FILE"

echo "$0: test passed."
