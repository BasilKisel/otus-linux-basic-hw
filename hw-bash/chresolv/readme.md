# Description
chresolv.sh - rewrites /etc/resolv.conf nameservers to exactly 2 nameservers, which are specified as an script arguments.

# Tests
Tests are grouped in "tests" directory.
They are all scripts with a pattern of "test_\*.sh".
A relative symbolic link "chresolv.sh" should refer to the actual chresolv.sh script.

Test scripts does not change "/etc/resolv.conf", but create stubs and refers to them with env variable "CHRESOLV_STUB_FILE".
