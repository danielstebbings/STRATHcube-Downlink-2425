set hdf [lindex $argv 0]
set XSDK_PATH [lindex $argv 1]
hsi::open_hw_design $hdf
hsi::set_repo_path ${XSDK_PATH}/data/embeddedsw