#!/bin/bash +e

echo "Test 'regular file' started."

test_dir=./test_tmp
reg_file=$test_dir/foobarbaz
touch $reg_file
if [ ! $? ]; then
    echo "Cannot make a file '$reg_file'. Test aborted."
    exit 1
fi

./del_tmp.sh $reg_file > /dev/null 2>&1
retcode=$?
if [ ! $retcode -eq 2 ]; then
    echo "Expexted retcode 2. Got '$retcode'."
    exit 2
fi

rm $reg_file
echo "Test 'regular file' passed."

