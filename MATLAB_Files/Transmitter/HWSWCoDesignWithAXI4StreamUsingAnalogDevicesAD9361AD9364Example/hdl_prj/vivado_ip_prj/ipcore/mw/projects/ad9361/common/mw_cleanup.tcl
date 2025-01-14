# Get the clock and reset nodes

# usrpe31x doesn't have clock division logic IP
if { $project == "usrpe31x" } {
	mw_project_set ipcore_clk_net [get_bd_nets axi_ad9361_l_clk]
	mw_project_set ipcore_rstn_net [get_bd_nets sys_cpu_resetn]
	mw_project_set ipcore_rst_net [get_bd_nets axi_ad9361_rst]
} else {
	mw_project_set ipcore_clk_net [get_bd_nets util_ad9361_divclk_clk_out]
	mw_project_set ipcore_rstn_net [get_bd_nets util_ad9361_divclk_reset_peripheral_aresetn]
	mw_project_set ipcore_rst_net [get_bd_nets util_ad9361_divclk_reset_peripheral_reset]
}
mw_project_set axi_cpu_interconnect [get_bd_cells axi_cpu_interconnect]

# Use the dummy helper to get the axi interconnect on the correct clock domain
set dummy_ip [mw_create_dummy_slave $IP_AXIM]
# Then remove the core
delete_bd_objs $dummy_ip

set STREAM_ENABLE false 
if { $HasAXIMaster || $HasAXISlave } {
    set STREAM_ENABLE true
}

if { $project == "usrpe31x" } {
    source $mw_ad9361/board/usrpe31x/mw_cleanup_tx.tcl
    source $mw_ad9361/board/usrpe31x/mw_cleanup_rx.tcl
} else {
    source $mw_ad9361/common/mw_cleanup_tx.tcl
    source $mw_ad9361/common/mw_cleanup_rx.tcl
}

if { $STREAM_ENABLE } {
    source $mw_ad9361/common/mw_setup_axis.tcl
}

source $mw_ad9361/common/mw_cleanup_gpio.tcl

source $mw_ad9361/common/mw_cleanup_clocking.tcl

mw_adi_add_status_led

mw_cleanup_orphan_nets

regenerate_bd_layout
