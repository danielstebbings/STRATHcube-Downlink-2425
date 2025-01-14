# Add the clocking core
set util_mw_clkconstr [create_bd_cell -type ip \
    -vlnv mathworks.com:user:util_mw_clkconstr:* util_mw_clkconstr]

if { $project == "usrpe31x"} {
    create_bd_cell -type ip -vlnv analog.com:user:util_clkdiv:1.0 util_ad9361_divclk
    create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 clk_div_sel
    mw_disconnect_pin axi_ad9361/l_clk
    mw_disconnect_pin axi_ad9361/clk
    mw_connect_pin util_mw_clkconstr/clk_out axi_ad9361_l_clk
    mw_connect_pin util_ad9361_divclk/clk axi_ad9361/l_clk
    mw_connect_pin axi_ad9361/clk axi_ad9361/l_clk
    mw_connect_pin util_ad9361_divclk/clk_sel clk_div_sel/dout
    mw_connect_pin util_mw_clkconstr/clk util_ad9361_divclk/clk_out
    mw_disconnect_pin axi_ad9361_dac_fifo/dout_clk
    mw_connect_pin axi_ad9361_dac_fifo/dout_clk axi_ad9361/l_clk
    mw_disconnect_pin util_ad9361_adc_fifo/din_clk
    mw_connect_pin util_ad9361_adc_fifo/din_clk axi_ad9361/l_clk
    add_files -norecurse -fileset sources_1 $mw_ad9361/board/usrpe31x/mw_usrpe31x_timing.xdc
} else {
    mw_disconnect_pin util_ad9361_divclk/clk_out
    mw_connect_pin util_mw_clkconstr/clk_out util_ad9361_divclk_clk_out
    mw_connect_pin util_mw_clkconstr/clk util_ad9361_divclk/clk_out
}

set_property CONFIG.CLKOUT0_REQUESTED_OUT_FREQ $DUT_DATA_RATE_MHZ $util_mw_clkconstr

# Fixup the constraints
set clk_tcl [add_files -norecurse -fileset sources_1 $mw_ad9361/common/mw_clk_constr.tcl]
set_property PROCESSING_ORDER LATE $clk_tcl

# Lower clock rate of PS clock 0 to fix sporadic timing failures
# Original clock rate is 100MHz, dropping as low as 80MHz introduces new failures
# on the ZC706 with FMC5.
# Commenting the code below as this frequency doesnot match with the FSBL.
if 0 {
     set psname [get_property name [get_bd_cells sys_ps*]]
     if { $psname == "sys_ps8" } { 
        set_property -dict [list CONFIG.PSU__CRL_APB__PL0_REF_CTRL__FREQMHZ {85}] [get_bd_cells sys_ps8]
     } else {
        set_property -dict [list CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {85}] [get_bd_cells sys_ps7]
     }
}
mw_cleanup_orphan_nets

regenerate_bd_layout
