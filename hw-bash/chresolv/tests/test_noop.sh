#!/bin/bash

echo "$0: test started."

export CHRESOLV_STUB_FILE=./test_noop_resolve.conf
ref_attr=./ref_attr
ns1="77.88.8.8"
ns2="77.88.8.1"
echo -e "\nnameserver $ns1\nnameserver $ns2\n" > "$CHRESOLV_STUB_FILE"
touch --date "1970-01-01" "$CHRESOLV_STUB_FILE" "$ref_attr"

./chresolv.sh "$ns1" "$ns2" > /dev/null
retcode=$?
if [ $retcode -ne 0 ]
then
    echo "$0: expected retcode '0', got '$retcode'"
    exit 1
fi
if [ "$CHRESOLV_STUB_FILE" -nt "$ref_attr" ]
then
    echo "$0: test failed: test '$CHRESOLV_STUB_FILE' file has been modified."
    exit 2
fi

rm -f "$CHRESOLV_STUB_FILE" "$ref_attr"

echo "$0: test passed."
