open_project vivado_prj.xpr
set boardName {ccfmc_lvds}
set project {adrv9361z7035}
set mw_hdl_dir {ipcore/mw}
set ad_hdl_dir {ipcore/adi}
set variant {rxtx}
set mw_board_name {adrv9361z7035}
set mw_adi_boardname {adrv9361z7035/ccfmc_lvds}
set HasAXIMaster {true}
set HasAXISlave {true}
set HDLVerifierAXI {off}
update_ip_catalog -delete_ip {./ipcore/HDL_Chirp_ip_v1_0/component.xml} -repo_path {./ipcore} -quiet
update_ip_catalog -add_ip {./ipcore/HDL_Chirp_ip_v1_0.zip} -repo_path {./ipcore}
update_ip_catalog
set HDLCODERIPVLNV [get_property VLNV [get_ipdefs -filter {NAME==HDL_Chirp_ip && VERSION==1.0}]]
set HDLCODERIPINST HDL_Chirp_ip_0
set BDFILEPATH [get_files -quiet system.bd]
open_bd_design $BDFILEPATH
create_bd_cell -type ip -vlnv $HDLCODERIPVLNV $HDLCODERIPINST
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins util_mw_clkconstr/clk_out]] [get_bd_pins $HDLCODERIPINST/AXI4_Lite_ACLK] [get_bd_pins util_mw_clkconstr/clk_out]
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins util_ad9361_divclk_reset/peripheral_aresetn]] [get_bd_pins $HDLCODERIPINST/AXI4_Lite_ARESETN] [get_bd_pins util_ad9361_divclk_reset/peripheral_aresetn]
connect_bd_intf_net [get_bd_intf_pins $HDLCODERIPINST/AXI4_Lite] [get_bd_intf_pins axi_cpu_interconnect/M05_AXI]
create_bd_addr_seg -range 0x10000 -offset 0x43C00000 [get_bd_addr_spaces sys_ps7/Data] [get_bd_addr_segs $HDLCODERIPINST/AXI4_Lite/reg0] SEG_${HDLCODERIPINST}_reg0
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins util_ad9361_adc_fifo/dout_data_0]] [get_bd_pins $HDLCODERIPINST/baseband_rx0I_in] [get_bd_pins util_ad9361_adc_fifo/dout_data_0]
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins bypass_rx/dut_data_in_0]] [get_bd_pins $HDLCODERIPINST/dma_rx0I_out] [get_bd_pins bypass_rx/dut_data_in_0]
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins util_ad9361_adc_fifo/dout_data_1]] [get_bd_pins $HDLCODERIPINST/baseband_rx0Q_in] [get_bd_pins util_ad9361_adc_fifo/dout_data_1]
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins bypass_rx/dut_data_in_1]] [get_bd_pins $HDLCODERIPINST/dma_rx0Q_out] [get_bd_pins bypass_rx/dut_data_in_1]
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins util_ad9361_adc_fifo/dout_data_2]] [get_bd_pins $HDLCODERIPINST/baseband_rx1I_in] [get_bd_pins util_ad9361_adc_fifo/dout_data_2]
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins bypass_rx/dut_data_in_2]] [get_bd_pins $HDLCODERIPINST/dma_rx1I_out] [get_bd_pins bypass_rx/dut_data_in_2]
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins util_ad9361_adc_fifo/dout_data_3]] [get_bd_pins $HDLCODERIPINST/baseband_rx1Q_in] [get_bd_pins util_ad9361_adc_fifo/dout_data_3]
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins bypass_rx/dut_data_in_3]] [get_bd_pins $HDLCODERIPINST/dma_rx1Q_out] [get_bd_pins bypass_rx/dut_data_in_3]
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins util_ad9361_adc_fifo/dout_valid_0]] [get_bd_pins $HDLCODERIPINST/baseband_rx_valid_in] [get_bd_pins util_ad9361_adc_fifo/dout_valid_0]
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins bypass_rx/dut_valid_in]] [get_bd_pins $HDLCODERIPINST/dma_rx_valid_out] [get_bd_pins bypass_rx/dut_valid_in]
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins util_ad9361_dac_upack/fifo_rd_data_0]] [get_bd_pins $HDLCODERIPINST/dma_tx0I_in] [get_bd_pins util_ad9361_dac_upack/fifo_rd_data_0]
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins bypass_tx/dut_data_in_0]] [get_bd_pins $HDLCODERIPINST/baseband_tx0I_out] [get_bd_pins bypass_tx/dut_data_in_0]
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins util_ad9361_dac_upack/fifo_rd_data_1]] [get_bd_pins $HDLCODERIPINST/dma_tx0Q_in] [get_bd_pins util_ad9361_dac_upack/fifo_rd_data_1]
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins bypass_tx/dut_data_in_1]] [get_bd_pins $HDLCODERIPINST/baseband_tx0Q_out] [get_bd_pins bypass_tx/dut_data_in_1]
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins util_ad9361_dac_upack/fifo_rd_valid]] [get_bd_pins $HDLCODERIPINST/dma_tx_valid_in] [get_bd_pins util_ad9361_dac_upack/fifo_rd_valid]
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins bypass_tx/dut_valid_in]] [get_bd_pins $HDLCODERIPINST/baseband_tx_valid_out] [get_bd_pins bypass_tx/dut_valid_in]
connect_bd_intf_net [get_bd_intf_pins $HDLCODERIPINST/AXI4_Stream_Write_Master] [get_bd_intf_pins axi_dma_s2mm/s_axis]
connect_bd_intf_net [get_bd_intf_pins $HDLCODERIPINST/AXI4_Stream_Read_Slave] [get_bd_intf_pins axi_dma_mm2s/m_axis]
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins util_mw_clkconstr/clk_out]] [get_bd_pins $HDLCODERIPINST/IPCORE_CLK] [get_bd_pins util_mw_clkconstr/clk_out]
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins util_ad9361_divclk_reset/peripheral_aresetn]] [get_bd_pins $HDLCODERIPINST/IPCORE_RESETN] [get_bd_pins util_ad9361_divclk_reset/peripheral_aresetn]
add_files -norecurse {mw/projects/ad9361/board/adrv9361z7035/ccfmc_lvds/system_top.v}
update_compile_order -fileset sources_1
validate_bd_design
save_bd_design
close_project
exit
