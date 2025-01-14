
#Tx Cleanup

set util_ad9361_reset [create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 util_ad9361_reset]
mw_connect_pin util_ad9361_reset/slowest_sync_clk axi_ad9361/l_clk
mw_connect_pin util_ad9361_reset/ext_reset_in sys_rstgen/peripheral_aresetn

set dac_upack_name util_ad9361_dac_upack

set HWNUMCHAN [get_property CONFIG.NUM_OF_CHANNELS [get_bd_cells ${dac_upack_name}]]

for {set ch 0} {$ch < $HWNUMCHAN} {incr ch} {
    mw_disconnect_pin ${dac_upack_name}/fifo_rd_data_${ch}
    mw_disconnect_pin ${dac_upack_name}/enable_${ch}
}
mw_disconnect_pin ${dac_upack_name}/reset
mw_disconnect_pin ${dac_upack_name}/fifo_rd_en
mw_disconnect_pin ${dac_upack_name}/fifo_rd_underflow

# Add the DAC Latch and Bypass_tx
set dac_latch [create_bd_cell -type ip -vlnv mathworks.com:user:util_mw_dac_reg:1.0 dac_latch]
set bypass_tx [create_bd_cell -type ip -vlnv mathworks.com:user:util_mw_bypass_user_logic:1.0 bypass_tx]

mw_connect_pin bypass_tx/AXI4_Lite_ACLK [mw_project_get ipcore_clk_net]
mw_connect_pin bypass_tx/AXI4_Lite_ARESETN util_ad9361_reset/peripheral_aresetn

set sys_cpu_interconnect_index [expr $sys_cpu_interconnect_index + 1]
ad_cpu_interconnect 0x43C20000 bypass_tx

set i_count [expr $sys_cpu_interconnect_index - 1]
set i_str "M$i_count"
   if {$i_count < 10} {
     set i_str "M0$i_count"
    }

set i_clkvar "_ACLK"
set i_resetnvar "_ARESETN"
mw_disconnect_pin axi_cpu_interconnect/$i_str$i_clkvar
mw_disconnect_pin axi_cpu_interconnect/$i_str$i_resetnvar
mw_connect_pin axi_cpu_interconnect/$i_str$i_clkvar [mw_project_get ipcore_clk_net]
mw_connect_pin axi_cpu_interconnect/$i_str$i_resetnvar util_ad9361_reset/peripheral_aresetn

set_property CONFIG.NUM_CHAN $HWNUMCHAN $dac_latch
set_property CONFIG.NUM_CHAN $HWNUMCHAN $bypass_tx

mw_connect_pin dac_latch/clk [mw_project_get ipcore_clk_net]
mw_connect_pin dac_latch/rst util_ad9361_reset/peripheral_reset
mw_connect_pin dac_latch/dac_valid bypass_tx/mux_valid_out_0
mw_connect_pin ${dac_upack_name}/reset util_ad9361_reset/peripheral_reset

mw_connect_pin bypass_tx/IPCORE_CLK [mw_project_get ipcore_clk_net]
mw_connect_pin bypass_tx/IPCORE_RESETN util_ad9361_reset/peripheral_aresetn

# DAC_FIFO instantiation
create_bd_cell -type ip -vlnv analog.com:user:util_rfifo:1.0 axi_ad9361_dac_fifo
set_property -dict [list CONFIG.DIN_DATA_WIDTH {16} CONFIG.DOUT_DATA_WIDTH {16} CONFIG.DIN_ADDRESS_WIDTH {4}] [get_bd_cells axi_ad9361_dac_fifo]
mw_connect_pin axi_ad9361/l_clk axi_ad9361_dac_fifo/dout_clk
mw_connect_pin axi_ad9361/rst axi_ad9361_dac_fifo/dout_rst
mw_connect_pin axi_ad9361_dac_fifo/din_clk [mw_project_get ipcore_clk_net]
mw_connect_pin util_ad9361_reset/peripheral_aresetn axi_ad9361_dac_fifo/din_rstn
mw_connect_pin axi_ad9361_dac_fifo/dout_enable_0 axi_ad9361/dac_enable_i0
mw_connect_pin axi_ad9361_dac_fifo/dout_valid_0 axi_ad9361/dac_valid_i0
mw_connect_pin axi_ad9361_dac_fifo/dout_data_0 axi_ad9361/dac_data_i0
mw_connect_pin axi_ad9361_dac_fifo/dout_enable_1 axi_ad9361/dac_enable_q0
mw_connect_pin axi_ad9361_dac_fifo/dout_valid_1 axi_ad9361/dac_valid_q0
mw_connect_pin axi_ad9361_dac_fifo/dout_data_1 axi_ad9361/dac_data_q0
mw_connect_pin axi_ad9361_dac_fifo/dout_enable_2 axi_ad9361/dac_enable_i1
mw_connect_pin axi_ad9361_dac_fifo/dout_valid_2 axi_ad9361/dac_valid_i1
mw_connect_pin axi_ad9361_dac_fifo/dout_data_2 axi_ad9361/dac_data_i1
mw_connect_pin axi_ad9361_dac_fifo/dout_enable_3 axi_ad9361/dac_enable_q1
mw_connect_pin axi_ad9361_dac_fifo/dout_valid_3 axi_ad9361/dac_valid_q1
mw_connect_pin axi_ad9361_dac_fifo/dout_data_3 axi_ad9361/dac_data_q1
mw_connect_pin axi_ad9361_dac_fifo/dout_unf axi_ad9361/dac_dunf

# Wire the DAC Upack and Bypass_tx
for {set ch 0} {$ch < $HWNUMCHAN} {incr ch} {
    mw_connect_pin bypass_tx/bypass_data_in_${ch} ${dac_upack_name}/fifo_rd_data_${ch}
    mw_connect_pin dac_latch/dac_data_in_${ch} bypass_tx/mux_data_out_${ch} 
    mw_connect_pin dac_latch/dac_data_out_${ch} axi_ad9361_dac_fifo/din_data_${ch} 
    mw_connect_pin ${dac_upack_name}/enable_${ch} axi_ad9361_dac_fifo/din_enable_${ch} 
}
mw_connect_pin ${dac_upack_name}/fifo_rd_en axi_ad9361_dac_fifo/din_valid_0
mw_connect_pin ${dac_upack_name}/fifo_rd_underflow axi_ad9361_dac_fifo/din_unf

