# Description
rmtmp.sh - deletes all .tmp, .bak, .backup files in a directory specified in the 1st argument of the script.

# Tests
Tests are grouped in "tests" directory.
They are all scripts with a pattern of "test_\*.sh".
All of them rely on "test_tmp" - a directory to keep test files for test_\*.sh scripts.
A relative symbolic link "rmtmp.sh" should refer to the actual rmtmp.sh script.
