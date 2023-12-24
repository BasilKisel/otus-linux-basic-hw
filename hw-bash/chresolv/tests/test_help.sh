#!/bin/bash

echo "$0: test started."

export CHRESOLV_STUB_FILE=./test_help_resolve.conf
ref_attr=./ref_attr
touch --date "1970-01-01" "$CHRESOLV_STUB_FILE" "$ref_attr"

./chresolv.sh -h > /dev/null
retcode=$?
if [ $retcode -ne 1 ]
then
    echo "$0: expected retcode '1', got '$retcode'"
    exit 1
fi
if [ "$CHRESOLV_STUB_FILE" -nt "$ref_attr" ]
then
    echo "$0: test failed: test '$CHRESOLV_STUB_FILE' file has been modified."
    exit 2
fi

./chresolv.sh --help > /dev/null
retcode=$?
if [ $retcode -ne 1 ]
then
    echo "$0: expected retcode '1', got '$retcode'"
    exit 3
fi
if [ "$CHRESOLV_STUB_FILE" -nt "$ref_attr" ]
then
    echo "$0: test failed: test '$CHRESOLV_STUB_FILE' file has been modified."
    exit 4
fi

./chresolv.sh > /dev/null
retcode=$?
if [ $retcode -ne 1 ]
then
    echo "$0: expected retcode '1', got '$retcode'"
    exit 5
fi
if [ "$CHRESOLV_STUB_FILE" -nt "$ref_attr" ]
then
    echo "$0: test failed: test '$CHRESOLV_STUB_FILE' file has been modified."
    exit 6
fi

rm "$CHRESOLV_STUB_FILE" "$ref_attr"

echo "$0: test passed."
