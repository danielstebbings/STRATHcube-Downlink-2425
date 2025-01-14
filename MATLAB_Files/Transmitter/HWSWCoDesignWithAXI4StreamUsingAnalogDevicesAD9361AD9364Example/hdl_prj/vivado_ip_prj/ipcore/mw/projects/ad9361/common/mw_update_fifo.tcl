save_bd_design 

set rx_enabled false
set tx_enabled false

switch -- $variant {
    "rx_bb" {
        set rx_enabled true
    }
    "tx_bb" {
        set tx_enabled true
    }
    "rxtx_bb" {
        set tx_enabled true
        set rx_enabled true
    }
}

puts $boardName
set AXIM "01"
switch --  $boardName {
    "zc706" {
        set AXIM "01"
    }
    "zcu102" {
        set AXIM "04"
    }
}

puts $rx_enabled
puts $tx_enabled

    # Create instance: clk_wiz_0, and set properties
      set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
      set_property -dict [ list \
       CONFIG.CLKIN1_JITTER_PS {250.0} \
       CONFIG.CLKOUT1_JITTER {163.925} \
       CONFIG.CLKOUT1_PHASE_ERROR {191.950} \
       CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {160} \
       CONFIG.MMCM_CLKFBOUT_MULT_F {25.000} \
       CONFIG.MMCM_CLKIN1_PERIOD {25.000} \
       CONFIG.MMCM_CLKOUT0_DIVIDE_F {6.250} \
       CONFIG.PRIM_IN_FREQ {40} \
       CONFIG.RESET_PORT {resetn} \
       CONFIG.RESET_TYPE {ACTIVE_LOW} \
     ] $clk_wiz_0
    
     # Create instance: proc_sys_reset_0, and set properties
      set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]
    
      set_property -dict [ list \
       CONFIG.FREQ_HZ {40000000} \
     ] [get_bd_pins /util_mw_clkconstr/clk_out]

	set_property -dict [list CONFIG.FREQ_HZ [expr 1000000 * $BBSampleRate]] [get_bd_pins util_mw_clkconstr/clk_out]
    set_property -dict [list CONFIG.PRIM_IN_FREQ [expr $BBSampleRate] ] [get_bd_cells clk_wiz_0]


    
     # connect_bd_net -net sys_ps7_FCLK_RESET2_N [get_bd_pins clk_wiz_0/resetn] [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins sys_ps7/FCLK_RESET2_N]
     connect_bd_net -net sys_cpu_resetn [get_bd_pins clk_wiz_0/resetn] [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins sys_rstgen/peripheral_aresetn]
    

      set_property -dict [list CONFIG.CLKOUT0_REQUESTED_OUT_FREQ $BBSampleRate] [get_bd_cells util_mw_clkconstr]
      set_property -dict [list CONFIG.CLKOUT1_REQUESTED_OUT_FREQ $DUTClockFreq] [get_bd_cells clk_wiz_0]
      connect_bd_net -net clk_wiz_0_locked [get_bd_pins clk_wiz_0/locked] [get_bd_pins proc_sys_reset_0/dcm_locked]



disconnect_bd_net /util_ad9361_divclk_clk_out [get_bd_pins axi_cpu_interconnect/M0[expr {$AXIM}]_ACLK]
connect_bd_net [get_bd_pins axi_cpu_interconnect/M0[expr {$AXIM}]_ACLK] [get_bd_pins clk_wiz_0/clk_out1]

disconnect_bd_net /util_ad9361_divclk_reset_peripheral_aresetn [get_bd_pins axi_cpu_interconnect/M0[expr {$AXIM}]_ARESETN]
connect_bd_net [get_bd_pins axi_cpu_interconnect/M0[expr {$AXIM}]_ARESETN] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]

# Connecting DMA streaming clock to the DUT clock 

disconnect_bd_net /util_ad9361_divclk_clk_out [get_bd_pins axi_dma_s2mm/s_axis_aclk]
disconnect_bd_net /util_ad9361_divclk_clk_out [get_bd_pins axi_dma_mm2s/m_axis_aclk]
connect_bd_net [get_bd_pins axi_dma_s2mm/s_axis_aclk] [get_bd_pins clk_wiz_0/clk_out1]
connect_bd_net [get_bd_pins axi_dma_mm2s/m_axis_aclk] [get_bd_pins clk_wiz_0/clk_out1]

if { $rx_enabled == "true" } { 

      # Create instance: fifo_baseband_rx0, and set properties
      set fifo_baseband_rx0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_baseband_rx0 ]
      set_property -dict [ list \
       CONFIG.Clock_Type_AXI {Independent_Clock} \
       CONFIG.Empty_Threshold_Assert_Value_axis {1021} \
       CONFIG.Empty_Threshold_Assert_Value_rach {13} \
       CONFIG.Empty_Threshold_Assert_Value_rdch {1021} \
       CONFIG.Empty_Threshold_Assert_Value_wach {13} \
       CONFIG.Empty_Threshold_Assert_Value_wdch {1021} \
       CONFIG.Empty_Threshold_Assert_Value_wrch {13} \
       CONFIG.Enable_Safety_Circuit {true} \
       CONFIG.FIFO_Implementation_axis {Independent_Clocks_Block_RAM} \
       CONFIG.FIFO_Implementation_rach {Independent_Clocks_Distributed_RAM} \
       CONFIG.FIFO_Implementation_rdch {Independent_Clocks_Block_RAM} \
       CONFIG.FIFO_Implementation_wach {Independent_Clocks_Distributed_RAM} \
       CONFIG.FIFO_Implementation_wdch {Independent_Clocks_Block_RAM} \
       CONFIG.FIFO_Implementation_wrch {Independent_Clocks_Distributed_RAM} \
       CONFIG.Fifo_Implementation {Independent_Clocks_Block_RAM} \
       CONFIG.Full_Flags_Reset_Value {1} \
       CONFIG.Full_Threshold_Assert_Value {1021} \
       CONFIG.Full_Threshold_Assert_Value_rach {15} \
       CONFIG.Full_Threshold_Assert_Value_wach {15} \
       CONFIG.Full_Threshold_Assert_Value_wrch {15} \
       CONFIG.Full_Threshold_Negate_Value {1020} \
       CONFIG.INTERFACE_TYPE {AXI_STREAM} \
       CONFIG.Input_Data_Width {32} \
       CONFIG.Output_Data_Width {32} \
       CONFIG.Reset_Type {Asynchronous_Reset} \
       CONFIG.TDATA_NUM_BYTES {8} \
       CONFIG.TKEEP_WIDTH {8} \
       CONFIG.TSTRB_WIDTH {8} \
       CONFIG.TUSER_WIDTH {0} \
       CONFIG.synchronization_stages_axi {4} \
     ] $fifo_baseband_rx0
    
      # Create instance: fifo_dma_rx0, and set properties
      set fifo_dma_rx0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_dma_rx0 ]
      set_property -dict [ list \
       CONFIG.Clock_Type_AXI {Independent_Clock} \
       CONFIG.Empty_Threshold_Assert_Value_axis {1021} \
       CONFIG.Empty_Threshold_Assert_Value_rach {13} \
       CONFIG.Empty_Threshold_Assert_Value_rdch {1021} \
       CONFIG.Empty_Threshold_Assert_Value_wach {13} \
       CONFIG.Empty_Threshold_Assert_Value_wdch {1021} \
       CONFIG.Empty_Threshold_Assert_Value_wrch {13} \
       CONFIG.Enable_Safety_Circuit {true} \
       CONFIG.FIFO_Implementation_axis {Independent_Clocks_Block_RAM} \
       CONFIG.FIFO_Implementation_rach {Independent_Clocks_Distributed_RAM} \
       CONFIG.FIFO_Implementation_rdch {Independent_Clocks_Block_RAM} \
       CONFIG.FIFO_Implementation_wach {Independent_Clocks_Distributed_RAM} \
       CONFIG.FIFO_Implementation_wdch {Independent_Clocks_Block_RAM} \
       CONFIG.FIFO_Implementation_wrch {Independent_Clocks_Distributed_RAM} \
       CONFIG.Fifo_Implementation {Independent_Clocks_Block_RAM} \
       CONFIG.Full_Flags_Reset_Value {1} \
       CONFIG.Full_Threshold_Assert_Value {1021} \
       CONFIG.Full_Threshold_Assert_Value_rach {15} \
       CONFIG.Full_Threshold_Assert_Value_wach {15} \
       CONFIG.Full_Threshold_Assert_Value_wrch {15} \
       CONFIG.Full_Threshold_Negate_Value {1020} \
       CONFIG.INTERFACE_TYPE {AXI_STREAM} \
       CONFIG.Input_Data_Width {32} \
       CONFIG.Output_Data_Width {32} \
       CONFIG.Reset_Type {Asynchronous_Reset} \
       CONFIG.TDATA_NUM_BYTES {8} \
       CONFIG.TKEEP_WIDTH {8} \
       CONFIG.TSTRB_WIDTH {8} \
       CONFIG.TUSER_WIDTH {0} \
       CONFIG.synchronization_stages_axi {4} \
     ] $fifo_dma_rx0

    
      # Create instance: concat_IQ_bb_rx0, and set properties
      set concat_IQ_bb_rx0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 concat_IQ_bb_rx0 ]
      set_property -dict [ list \
       CONFIG.IN0_WIDTH {16} \
       CONFIG.IN1_WIDTH {16} \
       CONFIG.IN2_WIDTH {16} \
       CONFIG.IN3_WIDTH {16} \
     ] $concat_IQ_bb_rx0
	set_property -dict [list CONFIG.NUM_PORTS {4}] [get_bd_cells concat_IQ_bb_rx0]

    
      # Create instance: concat_IQ_dma_rx0, and set properties
      set concat_IQ_dma_rx0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 concat_IQ_dma_rx0 ]
      set_property -dict [ list \
       CONFIG.IN0_WIDTH {16} \
       CONFIG.IN1_WIDTH {16} \
       CONFIG.IN2_WIDTH {16} \
       CONFIG.IN3_WIDTH {16} \
     ] $concat_IQ_dma_rx0
        set_property -dict [list CONFIG.NUM_PORTS {4}] [get_bd_cells concat_IQ_dma_rx0]

      # Create instance: bb_rx0_Q, and set properties
      set bb_rx0_Q [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 bb_rx0_Q ]
      set_property -dict [ list \
       CONFIG.DIN_FROM {31} \
       CONFIG.DIN_TO {16} \
       CONFIG.DOUT_WIDTH {16} \
     ] $bb_rx0_Q
    
      # Create instance: bb_rx0_I, and set properties
      set bb_rx0_I [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 bb_rx0_I ]
      set_property -dict [ list \
       CONFIG.DIN_FROM {15} \
       CONFIG.DOUT_WIDTH {16} \
     ] $bb_rx0_I
    
      # Create instance: dma_rx0_Q, and set properties
      set dma_rx0_Q [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 dma_rx0_Q ]
      set_property -dict [ list \
       CONFIG.DIN_FROM {31} \
       CONFIG.DIN_TO {16} \
       CONFIG.DOUT_WIDTH {16} \
     ] $dma_rx0_Q
    
      # Create instance: dma_rx0_I, and set properties
      set dma_rx0_I [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 dma_rx0_I ]
      set_property -dict [ list \
       CONFIG.DIN_FROM {15} \
       CONFIG.DOUT_WIDTH {16} \
     ] $dma_rx0_I
    
      # Create instance: bb_rx1_Q, and set properties
      set bb_rx1_Q [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 bb_rx1_Q ]
      set_property -dict [ list \
       CONFIG.DIN_FROM {31} \
       CONFIG.DIN_TO {16} \
       CONFIG.DOUT_WIDTH {16} \
     ] $bb_rx1_Q
    
      # Create instance: bb_rx1_I, and set properties
      set bb_rx1_I [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 bb_rx1_I ]
      set_property -dict [ list \
       CONFIG.DIN_FROM {15} \
       CONFIG.DOUT_WIDTH {16} \
     ] $bb_rx1_I
    
      # Create instance: dma_rx1_Q, and set properties
      set dma_rx1_Q [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 dma_rx1_Q ]
      set_property -dict [ list \
       CONFIG.DIN_FROM {31} \
       CONFIG.DIN_TO {16} \
       CONFIG.DOUT_WIDTH {16} \
     ] $dma_rx1_Q
    
      # Create instance: dma_rx1_I, and set properties
      set dma_rx1_I [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 dma_rx1_I ]
      set_property -dict [ list \
       CONFIG.DIN_FROM {15} \
       CONFIG.DOUT_WIDTH {16} \
     ] $dma_rx1_I

	set_property -dict [list CONFIG.DIN_TO {32} CONFIG.DIN_FROM {47} CONFIG.DIN_WIDTH {64} CONFIG.DIN_FROM {47} CONFIG.DOUT_WIDTH {16}] [get_bd_cells dma_rx1_I]
	set_property -dict [list CONFIG.DIN_TO {48} CONFIG.DIN_FROM {63} CONFIG.DIN_WIDTH {64} CONFIG.DIN_FROM {63} CONFIG.DOUT_WIDTH {16}] [get_bd_cells dma_rx1_Q]
	set_property -dict [list CONFIG.DIN_TO {32} CONFIG.DIN_FROM {47} CONFIG.DIN_WIDTH {64} CONFIG.DIN_FROM {47} CONFIG.DOUT_WIDTH {16}] [get_bd_cells bb_rx1_I]
	set_property -dict [list CONFIG.DIN_TO {48} CONFIG.DIN_FROM {63} CONFIG.DIN_WIDTH {64} CONFIG.DIN_TO {48} CONFIG.DOUT_WIDTH {16}] [get_bd_cells bb_rx1_Q]
	set_property -dict [list CONFIG.DIN_WIDTH {64} CONFIG.DIN_TO {16} CONFIG.DIN_FROM {31}] [get_bd_cells bb_rx0_Q]
	set_property -dict [list CONFIG.DIN_WIDTH {64} CONFIG.DIN_TO {0} CONFIG.DIN_FROM {15}] [get_bd_cells bb_rx0_I]
	set_property -dict [list CONFIG.DIN_WIDTH {64} CONFIG.DIN_TO {0} CONFIG.DIN_FROM {15}] [get_bd_cells dma_rx0_I]
	set_property -dict [list CONFIG.DIN_WIDTH {64} CONFIG.DIN_TO {16} CONFIG.DIN_FROM {31}] [get_bd_cells dma_rx0_Q]

      connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins fifo_baseband_rx0/m_aclk] [get_bd_pins fifo_dma_rx0/s_aclk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk]    
      
      # connect_bd_net -net dac_latch_dac_data_out_3_net [get_bd_pins axi_ad9361_dac_fifo/din_data_3] [get_bd_pins dac_latch/dac_data_out_3]
      connect_bd_net -net fifo_baseband_rx0_m_axis_tdata [get_bd_pins fifo_baseband_rx0/m_axis_tdata] [get_bd_pins bb_rx0_Q/Din] [get_bd_pins bb_rx0_I/Din] [get_bd_pins bb_rx1_Q/Din] [get_bd_pins bb_rx1_I/Din]
      # connect_bd_net -net fifo_baseband_rx0_m_axis_tvalid [get_bd_pins WLANHDL_160Mhz_ip_0/baseband_rx_valid_in] [get_bd_pins fifo_baseband_rx0/m_axis_tvalid]
      # connect_bd_net -net fifo_dma_tx0_m_axis_tvalid [get_bd_pins WLANHDL_160Mhz_ip_0/dma_tx_valid_in] [get_bd_pins fifo_dma_tx0/m_axis_tvalid]
      connect_bd_net -net fifo_dma_rx0_m_axis_tdata [get_bd_pins fifo_dma_rx0/m_axis_tdata] [get_bd_pins dma_rx0_Q/Din] [get_bd_pins dma_rx0_I/Din] [get_bd_pins dma_rx1_Q/Din] [get_bd_pins dma_rx1_I/Din]
      connect_bd_net -net fifo_dma_rx0_m_axis_tvalid [get_bd_pins bypass_rx/dut_valid_in] [get_bd_pins fifo_dma_rx0/m_axis_tvalid]
      connect_bd_net [get_bd_pins fifo_dma_rx0/s_aresetn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
    
      connect_bd_net -net util_ad9361_adc_fifo_dout_data_0 [get_bd_pins bypass_rx/bypass_data_in_0] [get_bd_pins util_ad9361_adc_fifo/dout_data_0] [get_bd_pins concat_IQ_bb_rx0/In0]
      connect_bd_net -net util_ad9361_adc_fifo_dout_data_1 [get_bd_pins bypass_rx/bypass_data_in_1] [get_bd_pins util_ad9361_adc_fifo/dout_data_1] [get_bd_pins concat_IQ_bb_rx0/In1]
      
      connect_bd_net -net util_ad9361_adc_fifo_dout_data_2 [get_bd_pins bypass_rx/bypass_data_in_2] [get_bd_pins util_ad9361_adc_fifo/dout_data_2] [get_bd_pins concat_IQ_bb_rx0/In2]
      connect_bd_net -net util_ad9361_adc_fifo_dout_data_3 [get_bd_pins bypass_rx/bypass_data_in_3] [get_bd_pins util_ad9361_adc_fifo/dout_data_3] [get_bd_pins concat_IQ_bb_rx0/In3]
	  connect_bd_net -net util_ad9361_adc_fifo_dout_valid_0 [get_bd_pins bypass_rx/bypass_valid_in_0] [get_bd_pins fifo_baseband_rx0/s_axis_tvalid] [get_bd_pins util_ad9361_adc_fifo/dout_valid_0]
    #  connect_bd_net -net util_ad9361_divclk_clk_out [get_bd_pins axi_ad9361_adc_dma/fifo_wr_clk] [get_bd_pins axi_ad9361_dac_dma/m_axis_aclk] [get_bd_pins axi_ad9361_dac_fifo/din_clk] [get_bd_pins clk_wiz_0/clk_in1] [get_bd_pins fifo_baseband_rx0/s_aclk] [get_bd_pins fifo_dma_rx0/m_aclk] [get_bd_pins util_mw_clkconstr/clk_out]
    #  connect_bd_net -net util_ad9361_divclk_reset_peripheral_aresetn [get_bd_pins axi_ad9361_dac_fifo/din_rstn]  [get_bd_pins fifo_baseband_rx0/s_aresetn] [get_bd_pins util_ad9361_adc_fifo/dout_rstn] [get_bd_pins util_ad9361_divclk_reset/peripheral_aresetn]
    	connect_bd_net [get_bd_pins axi_ad9361_adc_dma/fifo_wr_clk] [get_bd_pins axi_ad9361_dac_dma/m_axis_aclk] [get_bd_pins axi_ad9361_dac_fifo/din_clk] [get_bd_pins clk_wiz_0/clk_in1] [get_bd_pins fifo_baseband_rx0/s_aclk] [get_bd_pins fifo_dma_rx0/m_aclk] [get_bd_pins util_mw_clkconstr/clk_out]
      connect_bd_net [get_bd_pins axi_ad9361_dac_fifo/din_rstn]  [get_bd_pins fifo_baseband_rx0/s_aresetn] [get_bd_pins util_ad9361_adc_fifo/dout_rstn] [get_bd_pins util_ad9361_divclk_reset/peripheral_aresetn]

    
      connect_bd_net -net concat_IQ_bb_rx0_dout [get_bd_pins fifo_baseband_rx0/s_axis_tdata] [get_bd_pins concat_IQ_bb_rx0/dout]
      connect_bd_net -net concat_IQ_dma_rx0_dout [get_bd_pins fifo_dma_rx0/s_axis_tdata] [get_bd_pins concat_IQ_dma_rx0/dout]
     # connect_bd_net -net bb_rx0_Q_Dout [get_bd_pins WLANHDL_160Mhz_ip_0/baseband_rx0Q_in] [get_bd_pins bb_rx0_Q/Dout]
     # connect_bd_net -net bb_rx0_I_Dout [get_bd_pins WLANHDL_160Mhz_ip_0/baseband_rx0I_in] [get_bd_pins bb_rx0_I/Dout]
     # connect_bd_net -net dma_tx0_Q_Dout [get_bd_pins WLANHDL_160Mhz_ip_0/dma_tx0Q_in] [get_bd_pins dma_tx0_Q/Dout]
     # connect_bd_net -net dma_tx0_I_Dout [get_bd_pins WLANHDL_160Mhz_ip_0/dma_tx0I_in] [get_bd_pins dma_tx0_I/Dout]
      connect_bd_net -net dma_rx0_Q_Dout [get_bd_pins bypass_rx/dut_data_in_1] [get_bd_pins dma_rx0_Q/Dout]
      connect_bd_net -net dma_rx0_I_Dout [get_bd_pins bypass_rx/dut_data_in_0] [get_bd_pins dma_rx0_I/Dout]
      connect_bd_net -net dma_rx1_Q_Dout [get_bd_pins bypass_rx/dut_data_in_3] [get_bd_pins dma_rx1_Q/Dout]
      connect_bd_net -net dma_rx1_I_Dout [get_bd_pins bypass_rx/dut_data_in_2] [get_bd_pins dma_rx1_I/Dout]
}


if { $tx_enabled == "true" } { 

      # Create instance: fifo_dma_tx0, and set properties
      set fifo_dma_tx0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_dma_tx0 ]
      set_property -dict [ list \
       CONFIG.Clock_Type_AXI {Independent_Clock} \
       CONFIG.Empty_Threshold_Assert_Value_axis {1021} \
       CONFIG.Empty_Threshold_Assert_Value_rach {13} \
       CONFIG.Empty_Threshold_Assert_Value_rdch {1021} \
       CONFIG.Empty_Threshold_Assert_Value_wach {13} \
       CONFIG.Empty_Threshold_Assert_Value_wdch {1021} \
       CONFIG.Empty_Threshold_Assert_Value_wrch {13} \
       CONFIG.Enable_Safety_Circuit {true} \
       CONFIG.FIFO_Implementation_axis {Independent_Clocks_Block_RAM} \
       CONFIG.FIFO_Implementation_rach {Independent_Clocks_Distributed_RAM} \
       CONFIG.FIFO_Implementation_rdch {Independent_Clocks_Block_RAM} \
       CONFIG.FIFO_Implementation_wach {Independent_Clocks_Distributed_RAM} \
       CONFIG.FIFO_Implementation_wdch {Independent_Clocks_Block_RAM} \
       CONFIG.FIFO_Implementation_wrch {Independent_Clocks_Distributed_RAM} \
       CONFIG.Fifo_Implementation {Independent_Clocks_Block_RAM} \
       CONFIG.Full_Flags_Reset_Value {1} \
       CONFIG.Full_Threshold_Assert_Value {1021} \
       CONFIG.Full_Threshold_Assert_Value_rach {15} \
       CONFIG.Full_Threshold_Assert_Value_wach {15} \
       CONFIG.Full_Threshold_Assert_Value_wrch {15} \
       CONFIG.Full_Threshold_Negate_Value {1020} \
       CONFIG.INTERFACE_TYPE {AXI_STREAM} \
       CONFIG.Input_Data_Width {32} \
       CONFIG.Output_Data_Width {32} \
       CONFIG.Reset_Type {Asynchronous_Reset} \
       CONFIG.TDATA_NUM_BYTES {8} \
       CONFIG.TKEEP_WIDTH {8} \
       CONFIG.TSTRB_WIDTH {8} \
       CONFIG.TUSER_WIDTH {0} \
       CONFIG.synchronization_stages_axi {4} \
     ] $fifo_dma_tx0
    
      # Create instance: fifo_baseband_tx0, and set properties
      set fifo_baseband_tx0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_baseband_tx0 ]
      set_property -dict [ list \
       CONFIG.Clock_Type_AXI {Independent_Clock} \
       CONFIG.Empty_Threshold_Assert_Value_axis {1021} \
       CONFIG.Empty_Threshold_Assert_Value_rach {13} \
       CONFIG.Empty_Threshold_Assert_Value_rdch {1021} \
       CONFIG.Empty_Threshold_Assert_Value_wach {13} \
       CONFIG.Empty_Threshold_Assert_Value_wdch {1021} \
       CONFIG.Empty_Threshold_Assert_Value_wrch {13} \
       CONFIG.Enable_Safety_Circuit {true} \
       CONFIG.FIFO_Implementation_axis {Independent_Clocks_Block_RAM} \
       CONFIG.FIFO_Implementation_rach {Independent_Clocks_Distributed_RAM} \
       CONFIG.FIFO_Implementation_rdch {Independent_Clocks_Block_RAM} \
       CONFIG.FIFO_Implementation_wach {Independent_Clocks_Distributed_RAM} \
       CONFIG.FIFO_Implementation_wdch {Independent_Clocks_Block_RAM} \
       CONFIG.FIFO_Implementation_wrch {Independent_Clocks_Distributed_RAM} \
       CONFIG.Fifo_Implementation {Independent_Clocks_Block_RAM} \
       CONFIG.Full_Flags_Reset_Value {1} \
       CONFIG.Full_Threshold_Assert_Value {1021} \
       CONFIG.Full_Threshold_Assert_Value_rach {15} \
       CONFIG.Full_Threshold_Assert_Value_wach {15} \
       CONFIG.Full_Threshold_Assert_Value_wrch {15} \
       CONFIG.Full_Threshold_Negate_Value {1020} \
       CONFIG.INTERFACE_TYPE {AXI_STREAM} \
       CONFIG.Input_Data_Width {32} \
       CONFIG.Output_Data_Width {32} \
       CONFIG.Reset_Type {Asynchronous_Reset} \
       CONFIG.TDATA_NUM_BYTES {8} \
       CONFIG.TKEEP_WIDTH {8} \
       CONFIG.TSTRB_WIDTH {8} \
       CONFIG.TUSER_WIDTH {0} \
       CONFIG.synchronization_stages_axi {4} \
     ] $fifo_baseband_tx0
    
      # Create instance: concat_IQ_dma_tx0, and set properties
      set concat_IQ_dma_tx0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 concat_IQ_dma_tx0 ]
      set_property -dict [ list \
       CONFIG.IN0_WIDTH {16} \
       CONFIG.IN1_WIDTH {16} \
       CONFIG.IN2_WIDTH {16} \
       CONFIG.IN3_WIDTH {16} \
     ] $concat_IQ_dma_tx0
    
set_property -dict [list CONFIG.NUM_PORTS {4}] [get_bd_cells concat_IQ_dma_tx0]

      # Create instance: concat_IQ_bb_tx0, and set properties
      set concat_IQ_bb_tx0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 concat_IQ_bb_tx0 ]
      set_property -dict [ list \
       CONFIG.IN0_WIDTH {16} \
       CONFIG.IN1_WIDTH {16} \
       CONFIG.IN2_WIDTH {16} \
       CONFIG.IN3_WIDTH {16} \
     ] $concat_IQ_bb_tx0
set_property -dict [list CONFIG.NUM_PORTS {4}] [get_bd_cells concat_IQ_bb_tx0]

    
      # Create instance: dma_tx0_Q, and set properties
      set dma_tx0_Q [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 dma_tx0_Q ]
      set_property -dict [ list \
       CONFIG.DIN_FROM {31} \
       CONFIG.DIN_TO {16} \
       CONFIG.DOUT_WIDTH {16} \
     ] $dma_tx0_Q
    
      # Create instance: dma_tx0_I, and set properties
      set dma_tx0_I [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 dma_tx0_I ]
      set_property -dict [ list \
       CONFIG.DIN_FROM {15} \
       CONFIG.DOUT_WIDTH {16} \
     ] $dma_tx0_I
    
      # Create instance: bb_tx0_Q, and set properties
      set bb_tx0_Q [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 bb_tx0_Q ]
      set_property -dict [ list \
       CONFIG.DIN_FROM {31} \
       CONFIG.DIN_TO {16} \
       CONFIG.DOUT_WIDTH {16} \
     ] $bb_tx0_Q
    
      # Create instance: bb_tx0_I, and set properties
      set bb_tx0_I [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 bb_tx0_I ]
      set_property -dict [ list \
       CONFIG.DIN_FROM {15} \
       CONFIG.DOUT_WIDTH {16} \
     ] $bb_tx0_I
    
      # Create instance: dma_tx1_Q, and set properties
      set dma_tx1_Q [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 dma_tx1_Q ]
      set_property -dict [ list \
       CONFIG.DIN_FROM {31} \
       CONFIG.DIN_TO {16} \
       CONFIG.DOUT_WIDTH {16} \
     ] $dma_tx1_Q
    
      # Create instance: dma_tx1_I, and set properties
      set dma_tx1_I [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 dma_tx1_I ]
      set_property -dict [ list \
       CONFIG.DIN_FROM {15} \
       CONFIG.DOUT_WIDTH {16} \
     ] $dma_tx1_I
    
      # Create instance: bb_tx1_Q, and set properties
      set bb_tx1_Q [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 bb_tx1_Q ]
      set_property -dict [ list \
       CONFIG.DIN_FROM {31} \
       CONFIG.DIN_TO {16} \
       CONFIG.DOUT_WIDTH {16} \
     ] $bb_tx1_Q
    
      # Create instance: bb_tx1_I, and set properties
      set bb_tx1_I [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 bb_tx1_I ]
      set_property -dict [ list \
       CONFIG.DIN_FROM {15} \
       CONFIG.DOUT_WIDTH {16} \
     ] $bb_tx1_I

set_property -dict [list CONFIG.DIN_TO {32} CONFIG.DIN_FROM {47} CONFIG.DIN_WIDTH {64} CONFIG.DIN_FROM {47} CONFIG.DOUT_WIDTH {16}] [get_bd_cells dma_tx1_I]
set_property -dict [list CONFIG.DIN_TO {48} CONFIG.DIN_FROM {63} CONFIG.DIN_WIDTH {64} CONFIG.DIN_FROM {63} CONFIG.DOUT_WIDTH {16}] [get_bd_cells dma_tx1_Q]
set_property -dict [list CONFIG.DIN_TO {32} CONFIG.DIN_FROM {47} CONFIG.DIN_WIDTH {64} CONFIG.DIN_FROM {47} CONFIG.DOUT_WIDTH {16}] [get_bd_cells bb_tx1_I]
set_property -dict [list CONFIG.DIN_TO {48} CONFIG.DIN_FROM {63} CONFIG.DIN_WIDTH {64} CONFIG.DIN_TO {48} CONFIG.DOUT_WIDTH {16}] [get_bd_cells bb_tx1_Q]
set_property -dict [list CONFIG.DIN_WIDTH {64} CONFIG.DIN_TO {16} CONFIG.DIN_FROM {31}] [get_bd_cells bb_tx0_Q]
set_property -dict [list CONFIG.DIN_WIDTH {64} CONFIG.DIN_TO {0} CONFIG.DIN_FROM {15}] [get_bd_cells bb_tx0_I]
set_property -dict [list CONFIG.DIN_WIDTH {64} CONFIG.DIN_TO {0} CONFIG.DIN_FROM {15}] [get_bd_cells dma_tx0_I]
set_property -dict [list CONFIG.DIN_WIDTH {64} CONFIG.DIN_TO {16} CONFIG.DIN_FROM {31}] [get_bd_cells dma_tx0_Q]


    
      connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins fifo_dma_tx0/m_aclk] [get_bd_pins fifo_baseband_tx0/s_aclk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk]

      connect_bd_net -net fifo_dma_tx0_m_axis_tdata [get_bd_pins fifo_dma_tx0/m_axis_tdata] [get_bd_pins dma_tx0_Q/Din] [get_bd_pins dma_tx0_I/Din] [get_bd_pins dma_tx1_Q/Din] [get_bd_pins dma_tx1_I/Din]
      connect_bd_net -net fifo_baseband_tx0_m_axis_tdata [get_bd_pins fifo_baseband_tx0/m_axis_tdata] [get_bd_pins bb_tx0_Q/Din] [get_bd_pins bb_tx0_I/Din] [get_bd_pins bb_tx1_Q/Din] [get_bd_pins bb_tx1_I/Din]
      connect_bd_net -net fifo_baseband_tx0_m_axis_tvalid [get_bd_pins bypass_tx/dut_valid_in] [get_bd_pins fifo_baseband_tx0/m_axis_tvalid]
      connect_bd_net [get_bd_pins fifo_baseband_tx0/s_aresetn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
      connect_bd_net [get_bd_pins bypass_tx/bypass_data_in_0] [get_bd_pins util_ad9361_dac_upack/fifo_rd_data_0] [get_bd_pins concat_IQ_dma_tx0/In0]
      connect_bd_net [get_bd_pins bypass_tx/bypass_data_in_1] [get_bd_pins util_ad9361_dac_upack/fifo_rd_data_1] [get_bd_pins concat_IQ_dma_tx0/In1]
      connect_bd_net [get_bd_pins bypass_tx/bypass_data_in_2] [get_bd_pins util_ad9361_dac_upack/fifo_rd_data_2] [get_bd_pins concat_IQ_dma_tx0/In2]
      connect_bd_net [get_bd_pins bypass_tx/bypass_data_in_3] [get_bd_pins util_ad9361_dac_upack/fifo_rd_data_3] [get_bd_pins concat_IQ_dma_tx0/In3]
      connect_bd_net [get_bd_pins bypass_tx/bypass_valid_in_0] [get_bd_pins bypass_tx/bypass_valid_in_1] [get_bd_pins fifo_dma_tx0/s_axis_tvalid] [get_bd_pins util_ad9361_dac_upack/fifo_rd_valid]
      
      #connect_bd_net -net util_ad9361_divclk_clk_out [get_bd_pins axi_ad9361_adc_dma/fifo_wr_clk] [get_bd_pins axi_ad9361_dac_dma/m_axis_aclk] [get_bd_pins axi_ad9361_dac_fifo/din_clk] [get_bd_pins clk_wiz_0/clk_in1] [get_bd_pins fifo_dma_tx0/s_aclk] [get_bd_pins fifo_baseband_tx0/m_aclk] [get_bd_pins util_ad9361_divclk_reset/slowest_sync_clk] [get_bd_pins util_mw_clkconstr/clk_out]
     # connect_bd_net -net util_ad9361_divclk_reset_peripheral_aresetn [get_bd_pins axi_ad9361_dac_fifo/din_rstn] [get_bd_pins fifo_dma_tx0/s_aresetn] [get_bd_pins util_ad9361_adc_fifo/dout_rstn] [get_bd_pins util_ad9361_divclk_reset/peripheral_aresetn]
    
      connect_bd_net [get_bd_pins axi_ad9361_adc_dma/fifo_wr_clk] [get_bd_pins axi_ad9361_dac_dma/m_axis_aclk] [get_bd_pins axi_ad9361_dac_fifo/din_clk] [get_bd_pins clk_wiz_0/clk_in1] [get_bd_pins fifo_dma_tx0/s_aclk] [get_bd_pins fifo_baseband_tx0/m_aclk] [get_bd_pins util_ad9361_divclk_reset/slowest_sync_clk] [get_bd_pins util_mw_clkconstr/clk_out]
      connect_bd_net [get_bd_pins axi_ad9361_dac_fifo/din_rstn] [get_bd_pins fifo_dma_tx0/s_aresetn] [get_bd_pins util_ad9361_adc_fifo/dout_rstn] [get_bd_pins util_ad9361_divclk_reset/peripheral_aresetn]

      connect_bd_net -net concat_IQ_dma_tx0_dout [get_bd_pins fifo_dma_tx0/s_axis_tdata] [get_bd_pins concat_IQ_dma_tx0/dout]
      connect_bd_net -net concat_IQ_bb_tx0_dout [get_bd_pins fifo_baseband_tx0/s_axis_tdata] [get_bd_pins concat_IQ_bb_tx0/dout]
      connect_bd_net -net bb_tx0_Q_Dout [get_bd_pins bypass_tx/dut_data_in_1] [get_bd_pins bb_tx0_Q/Dout]
      connect_bd_net -net bb_tx0_I_Dout [get_bd_pins bypass_tx/dut_data_in_0] [get_bd_pins bb_tx0_I/Dout]
      connect_bd_net -net bb_tx1_Q_Dout [get_bd_pins bypass_tx/dut_data_in_3] [get_bd_pins bb_tx1_Q/Dout]
      connect_bd_net -net bb_tx1_I_Dout [get_bd_pins bypass_tx/dut_data_in_2] [get_bd_pins bb_tx1_I/Dout]
}

set current_vivado_version [version -short]
if {$current_vivado_version eq "2023.1"} {


	switch --  $boardName {
		"zc706" {
			add_files -norecurse -fileset sources_1 $mw_ad9361/common/mmcm_clkwiz_zc706.xdc
		}
		"zcu102" {
			add_files -norecurse -fileset sources_1 $mw_ad9361/common/mmcm_clkwiz_zcu102.xdc
		}
	}


}
save_bd_design