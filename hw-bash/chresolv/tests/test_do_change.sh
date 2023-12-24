#!/bin/bash

echo "$0: test started."

export CHRESOLV_STUB_FILE=./test_do_change_resolve.conf
ref_attr=./ref_attr

ns1="77.88.8.8"
ns2="77.88.8.1"

# test: no nameservers in a config file on a script startup
rm -f "$CHRESOLV_STUB_FILE" "$ref_attr"
touch --date "1970-01-01" "$CHRESOLV_STUB_FILE" "$ref_attr"
./chresolv.sh "$ns1" "$ns2" > /dev/null
retcode=$?
if [ $retcode -ne 0 ]
then
    echo "$0: expected retcode '0', got '$retcode'"
    exit 1
fi
if [ ! "$CHRESOLV_STUB_FILE" -nt "$ref_attr" ]
then
    echo "$0: test failed: test '$CHRESOLV_STUB_FILE' file has not been modified."
    exit 2
fi
matched_ns_cnt=$(grep -s -c -E "^nameserver[[:space:]]+($ns1|$ns2)" "$CHRESOLV_STUB_FILE")
total_ns_cnt=$(grep -s -c -E "^nameserver" "$CHRESOLV_STUB_FILE")
if [ "$matched_ns_cnt" -ne "$total_ns_cnt" -o "$matched_ns_cnt" -ne 2 ]
then
    echo "$0: test failed: nameservers in '$CHRESOLV_STUB_FILE' does not match the specification of '$ns1', '$ns2'."
    exit 3
fi

# test: one out of two nameservers in a config file matches the spec on a script startup
echo -e "nameserver $ns1\nnameserver foobar\n" > "$CHRESOLV_STUB_FILE"
touch --date "1970-01-01" "$CHRESOLV_STUB_FILE" "$ref_attr"
./chresolv.sh "$ns1" "$ns2" > /dev/null
retcode=$?
if [ $retcode -ne 0 ]
then
    echo "$0: expected retcode '0', got '$retcode'"
    exit 4
fi
if [ ! "$CHRESOLV_STUB_FILE" -nt "$ref_attr" ]
then
    echo "$0: test failed: test '$CHRESOLV_STUB_FILE' file has not been modified."
    exit 5
fi
matched_ns_cnt=$(grep -s -c -E "^nameserver[[:space:]]+($ns1|$ns2)" "$CHRESOLV_STUB_FILE")
total_ns_cnt=$(grep -s -c -E "^nameserver" "$CHRESOLV_STUB_FILE")
if [ "$matched_ns_cnt" -ne "$total_ns_cnt" -o "$matched_ns_cnt" -ne 2 ]
then
    echo "$0: test failed: nameservers in '$CHRESOLV_STUB_FILE' does not match the specification of '$ns1', '$ns2'."
    exit 6
fi

# test: two out of three nameservers in a config file matches the spec on a script startup
echo -e "nameserver $ns1\nnameserver $ns2\nnameserver foobar\n" > "$CHRESOLV_STUB_FILE"
touch --date "1970-01-01" "$CHRESOLV_STUB_FILE" "$ref_attr"
./chresolv.sh "$ns1" "$ns2" > /dev/null
retcode=$?
if [ $retcode -ne 0 ]
then
    echo "$0: expected retcode '0', got '$retcode'"
    exit 7
fi
if [ ! "$CHRESOLV_STUB_FILE" -nt "$ref_attr" ]
then
    echo "$0: test failed: test '$CHRESOLV_STUB_FILE' file has not been modified."
    exit 8
fi
matched_ns_cnt=$(grep -s -c -E "^nameserver[[:space:]]+($ns1|$ns2)" "$CHRESOLV_STUB_FILE")
total_ns_cnt=$(grep -s -c -E "^nameserver" "$CHRESOLV_STUB_FILE")
if [ "$matched_ns_cnt" -ne "$total_ns_cnt" -o "$matched_ns_cnt" -ne 2 ]
then
    echo "$0: test failed: nameservers in '$CHRESOLV_STUB_FILE' does not match the specification of '$ns1', '$ns2'."
    exit 9
fi


rm -f "$CHRESOLV_STUB_FILE" "$ref_attr"

echo "$0: test passed."
