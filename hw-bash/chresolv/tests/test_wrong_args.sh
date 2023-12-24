#!/bin/bash

echo "$0: test started."

export CHRESOLV_STUB_FILE=./test_wrong_args_resolve.conf
ref_attr=./ref_attr
touch --date "1970-01-01" "$CHRESOLV_STUB_FILE" "$ref_attr"

ns1="77.88.8.8"
ns2="77.88.8.1"

./chresolv.sh "$ns1" "$ns2" "foobar" > /dev/null
retcode=$?
if [ $retcode -ne 2 ]
then
    echo "$0: expected retcode '2', got '$retcode'"
    exit 1
fi
if [ "$CHRESOLV_STUB_FILE" -nt "$ref_attr" ]
then
    echo "$0: test failed: test '$CHRESOLV_STUB_FILE' file has been modified."
    exit 2
fi

./chresolv.sh "$ns1" > /dev/null
retcode=$?
if [ $retcode -ne 2 ]
then
    echo "$0: expected retcode '2', got '$retcode'"
    exit 3
fi
if [ "$CHRESOLV_STUB_FILE" -nt "$ref_attr" ]
then
    echo "$0: test failed: test '$CHRESOLV_STUB_FILE' file has been modified."
    exit 4
fi

./chresolv.sh "$ns1" "$ns1" > /dev/null
retcode=$?
if [ $retcode -ne 3 ]
then
    echo "$0: expected retcode '3', got '$retcode'"
    exit 5
fi
if [ "$CHRESOLV_STUB_FILE" -nt "$ref_attr" ]
then
    echo "$0: test failed: test '$CHRESOLV_STUB_FILE' file has been modified."
    exit 6
fi


rm -f "$CHRESOLV_STUB_FILE" "$ref_attr"

echo "$0: test passed."
