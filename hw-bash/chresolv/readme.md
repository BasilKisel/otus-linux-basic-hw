# Description
chresolv.sh - rewrites /etc/resolv.conf nameservers to exactly 2 nameservers, which are specified with script arguments.

# Tests
Tests are grouped in "tests" directory.
They are all scripts with a pattern of "test_\*.sh".
A relative symbolic link "chresolv.sh" should refer to the actual chresolv.sh script.

Test scripts do not change "/etc/resolv.conf", but create stubs and refer to them with "CHRESOLV_STUB_FILE" env variable.
