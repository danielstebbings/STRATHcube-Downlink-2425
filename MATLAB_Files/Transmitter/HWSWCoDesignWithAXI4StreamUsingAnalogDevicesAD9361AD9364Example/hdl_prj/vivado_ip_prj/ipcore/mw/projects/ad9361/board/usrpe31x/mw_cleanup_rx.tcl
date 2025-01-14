# RX Cleanup

set adc_pack_name util_ad9361_adc_pack
set HWNUMCHAN [get_property CONFIG.NUM_OF_CHANNELS [get_bd_cells ${adc_pack_name}]]
set bypass_rx [create_bd_cell -type ip -vlnv mathworks.com:user:util_mw_bypass_user_logic:1.0 bypass_rx]

mw_disconnect_pin $adc_pack_name/reset 

mw_connect_pin bypass_rx/AXI4_Lite_ACLK [mw_project_get ipcore_clk_net]
mw_connect_pin bypass_rx/AXI4_Lite_ARESETN util_ad9361_reset/peripheral_aresetn

ad_cpu_interconnect 0x43C50000 bypass_rx

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
mw_connect_pin $adc_pack_name/reset util_ad9361_reset/peripheral_reset

set_property CONFIG.NUM_CHAN $HWNUMCHAN $bypass_rx

mw_connect_pin bypass_rx/IPCORE_CLK [mw_project_get ipcore_clk_net]
mw_connect_pin bypass_rx/IPCORE_RESETN util_ad9361_reset/peripheral_aresetn

for {set ch 0} {$ch < $HWNUMCHAN} {incr ch} {
    mw_disconnect_pin ${adc_pack_name}/fifo_wr_data_${ch}
    mw_disconnect_pin ${adc_pack_name}/fifo_wr_en
    mw_disconnect_pin ${adc_pack_name}/enable_${ch}
}
mw_disconnect_pin ${adc_pack_name}/fifo_wr_overflow

# ADC FIFO instantiation
create_bd_cell -type ip -vlnv analog.com:user:util_wfifo:1.0 util_ad9361_adc_fifo
set_property -dict [list CONFIG.DIN_DATA_WIDTH {16} CONFIG.DOUT_DATA_WIDTH {16} CONFIG.DIN_ADDRESS_WIDTH {4}] [get_bd_cells util_ad9361_adc_fifo]
mw_connect_pin axi_ad9361/rst util_ad9361_adc_fifo/din_rst
mw_connect_pin axi_ad9361/l_clk util_ad9361_adc_fifo/din_clk
mw_connect_pin util_ad9361_adc_fifo/dout_clk [mw_project_get ipcore_clk_net]
mw_connect_pin util_ad9361_reset/peripheral_aresetn util_ad9361_adc_fifo/dout_rstn
mw_connect_pin axi_ad9361/adc_enable_i0 util_ad9361_adc_fifo/din_enable_0
mw_connect_pin axi_ad9361/adc_valid_i0 util_ad9361_adc_fifo/din_valid_0
mw_connect_pin axi_ad9361/adc_data_i0 util_ad9361_adc_fifo/din_data_0
mw_connect_pin axi_ad9361/adc_enable_q0 util_ad9361_adc_fifo/din_enable_1
mw_connect_pin axi_ad9361/adc_valid_q0 util_ad9361_adc_fifo/din_valid_1
mw_connect_pin axi_ad9361/adc_data_q0 util_ad9361_adc_fifo/din_data_1
mw_connect_pin axi_ad9361/adc_enable_i1 util_ad9361_adc_fifo/din_enable_2
mw_connect_pin axi_ad9361/adc_valid_i1 util_ad9361_adc_fifo/din_valid_2
mw_connect_pin axi_ad9361/adc_data_i1 util_ad9361_adc_fifo/din_data_2
mw_connect_pin axi_ad9361/adc_enable_q1 util_ad9361_adc_fifo/din_enable_3
mw_connect_pin axi_ad9361/adc_valid_q1 util_ad9361_adc_fifo/din_valid_3
mw_connect_pin axi_ad9361/adc_data_q1 util_ad9361_adc_fifo/din_data_3
mw_connect_pin util_ad9361_adc_fifo/din_ovf axi_ad9361/adc_dovf

# Wire Bypass_rx and ADC pack
for {set ch 0} {$ch < $HWNUMCHAN} {incr ch} {
    mw_connect_pin bypass_rx/mux_data_out_${ch} ${adc_pack_name}/fifo_wr_data_${ch}
    mw_connect_pin ${adc_pack_name}/enable_${ch} util_ad9361_adc_fifo/dout_enable_${ch}
}
mw_connect_pin ${adc_pack_name}/fifo_wr_overflow util_ad9361_adc_fifo/dout_ovf

mw_project_set ipcore_rstn_net [get_bd_nets util_ad9361_reset_peripheral_aresetn_net]
mw_project_set ipcore_rst_net [get_bd_nets util_ad9361_reset_peripheral_reset_net]
mw_disconnect_pin axi_cpu_interconnect/M04_ARESETN
mw_connect_pin axi_cpu_interconnect/M04_ARESETN util_ad9361_reset/peripheral_aresetn
 
