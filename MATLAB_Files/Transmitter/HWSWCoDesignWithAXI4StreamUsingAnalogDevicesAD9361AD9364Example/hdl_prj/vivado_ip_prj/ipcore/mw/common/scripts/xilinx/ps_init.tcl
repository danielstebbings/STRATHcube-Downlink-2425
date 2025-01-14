set hdf [lindex $argv 0]
hsi::open_hw_design $hdf
hsi::close_hw_design [hsi::current_hw_design]