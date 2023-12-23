#!/bin/bash +e

echo "Test 'remove tmp files' started."

test_dir=./test_tmp

pushd $test_dir 1>/dev/null

declare -a reg_files
reg_files=(reg_1 reg_tmp reg_backup.txt reg_bak)
touch ${reg_files[@]}

declare -a tmp_files
tmp_files=(file.tmp file.bak file.backup)
touch ${tmp_files[@]}

popd 1>/dev/null

./del_tmp.sh $test_dir > /dev/null 2>&1
retcode=$?

if [ ! $retcode -eq 0 ]; then
    echo "Expexted retcode 0. Got '$retcode'."
    exit 1
fi

pushd $test_dir 1>/dev/null

for tmp_file in ${tmp_files[@]}; do
    if [ -f $tmp_file ]
    then
        echo "'$tmp_file' has not been deleted. Test failed."
        exit 2
    fi
done

for reg_file in ${reg_files[@]}; do
    if [ ! -f $reg_file ]
    then
        echo "'$reg_file' has been deleted. Test failed."
        exit 3
    fi
done

rm ${reg_files[@]} 1>/dev/null 2>&1
rm ${tmp_files[@]} 1>/dev/null 2>&1

popd 1>/dev/null

echo "Test 'remove tmp files' passed."

