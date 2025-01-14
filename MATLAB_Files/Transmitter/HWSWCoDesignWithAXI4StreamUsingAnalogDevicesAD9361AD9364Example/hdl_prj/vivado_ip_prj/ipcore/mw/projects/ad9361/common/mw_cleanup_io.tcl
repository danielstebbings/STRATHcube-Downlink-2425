#############
# DAC
#############

set dac_upack_name util_ad9361_dac_upack
set dac_fifo_name axi_ad9361_dac_fifo
set dac_latch_name dac_latch
set bypass_tx_name bypass_tx
set HWNUMCHAN [get_property CONFIG.NUM_OF_CHANNELS [get_bd_cells ${dac_fifo_name}]]

mw_create_const gnd_ad9361_dac_data 16 0
for {set ch 0} {$ch < $HWNUMCHAN} {incr ch} {
    if { ![mw_is_connected axi_ad9361_dac_fifo/din_data_${ch}] } {
        mw_connect_pin axi_ad9361_dac_fifo/din_data_${ch} const_gnd_ad9361_dac_data
    }
}

# First, wire the valid signal
if { ![mw_is_connected ${dac_latch_name}/dac_valid] } {
    mw_connect_pin ${dac_latch_name}/dac_valid ${bypass_tx_name}/mux_valid_out_0
}

if { ![mw_is_connected ${bypass_tx_name}/dut_valid_in] } {
    mw_connect_pin ${bypass_tx_name}/dut_valid_in ${dac_upack_name}/fifo_rd_valid
}

# Sweep the channels
set nValid -1
for {set ch 0} {$ch < $HWNUMCHAN} {incr ch} {
    # Only one valid line per every two channels (I+Q)
    if { [expr {$ch % 2} == 0 ] } {
        incr nValid
        if { ![mw_is_connected ${bypass_tx_name}/bypass_valid_in_${nValid}] } {
            mw_connect_pin ${bypass_tx_name}/bypass_valid_in_${nValid} ${dac_upack_name}/fifo_rd_valid
        }
    }
    if { ![mw_is_connected ${dac_fifo_name}/din_valid_in_${ch}] } {
        mw_connect_pin ${bypass_tx_name}/mux_valid_out_${nValid} ${dac_fifo_name}/din_valid_in_${ch}
    }
    if { ![mw_is_connected ${bypass_tx_name}/bypass_data_in_${ch}] } {
        mw_connect_pin ${bypass_tx_name}/bypass_data_in_${ch} ${dac_upack_name}/fifo_rd_data_${ch}
    }

    if {$variant == "tx_bb" || $variant == "rxtx_bb"} {
    	if {$BBSampleRate != $DUTClockFreq} {
	    	if { ![mw_is_connected /concat_IQ_bb_tx0/In[expr {$ch}]] } {
        		delete_bd_objs [get_bd_cells bb_tx[expr {$ch/2}]_I] [get_bd_cells bb_tx[expr {$ch/2}]_Q]
			delete_bd_objs [get_bd_cells dma_tx[expr {$ch/2}]_I] [get_bd_cells dma_tx[expr {$ch/2}]_Q]
			set_property -dict [list CONFIG.TDATA_NUM_BYTES {4} CONFIG.TSTRB_WIDTH {4} CONFIG.TKEEP_WIDTH {4}] [get_bd_cells fifo_baseband_tx0]
			set_property -dict [list CONFIG.TDATA_NUM_BYTES {4} CONFIG.TSTRB_WIDTH {4} CONFIG.TKEEP_WIDTH {4}] [get_bd_cells fifo_dma_tx0]			
			set_property -dict [list CONFIG.NUM_PORTS {2}] [get_bd_cells concat_IQ_bb_tx0]
			set_property -dict [list CONFIG.NUM_PORTS {2}] [get_bd_cells concat_IQ_dma_tx0]
			connect_bd_net [get_bd_pins bypass_tx/dut_data_in_[expr {$ch}]] [get_bd_pins util_ad9361_dac_upack/fifo_rd_data_[expr {$ch}]]
   		   }
    	}
	}

	if { ![mw_is_connected ${bypass_tx_name}/dut_data_in_${ch}] } {
        mw_connect_pin ${bypass_tx_name}/dut_data_in_${ch} ${dac_upack_name}/fifo_rd_data_${ch}
    }
    if { ![mw_is_connected ${dac_upack_name}/enable_${ch}] } {
        mw_connect_pin ${dac_upack_name}/enable_${ch} ${dac_fifo_name}/din_enable_${ch}
    }
}

#############
# ADC
#############

# Loop around unused ADC pins
set adc_pack_name util_ad9361_adc_pack
set adc_fifo_name util_ad9361_adc_fifo
set bypass_rx_name bypass_rx
set HWNUMCHAN [get_property CONFIG.NUM_OF_CHANNELS [get_bd_cells ${adc_fifo_name}]]

# First, map channel 0
if { ![mw_is_connected ${bypass_rx_name}/dut_valid_in] } {
    mw_connect_pin ${adc_fifo_name}/dout_valid_0 ${bypass_rx_name}/dut_valid_in 
}
if { ![mw_is_connected ${bypass_rx_name}/bypass_valid_in_0] } {
    mw_connect_pin ${adc_fifo_name}/dout_valid_0 ${bypass_rx_name}/bypass_valid_in_0 
}

# Now, sweep the remaining channels
set nValid -1 
for {set ch 0} {$ch < $HWNUMCHAN} {incr ch} {
    # Only one valid line per every two channels (I+Q)
    if { [expr {$ch % 2} == 0 ] } {
        incr nValid
        if { ![mw_is_connected ${bypass_rx_name}/bypass_valid_in_${nValid}] } {
            mw_connect_pin ${adc_fifo_name}/dout_valid_${ch} ${bypass_rx_name}/bypass_valid_in_${nValid}
        }
    }
    if { ![mw_is_connected ${adc_pack_name}/fifo_wr_en] } {
        mw_connect_pin ${adc_pack_name}/fifo_wr_en ${bypass_rx_name}/mux_valid_out_0
    }
    if { ![mw_is_connected ${adc_pack_name}/fifo_wr_data_${ch}] } {
        mw_connect_pin ${bypass_rx_name}/mux_data_out_${ch} ${adc_pack_name}/fifo_wr_data_${ch}
    }
    if { ![mw_is_connected ${adc_pack_name}/enable_${ch}] } {
        mw_connect_pin ${adc_fifo_name}/dout_enable_${ch} ${adc_pack_name}/enable_${ch}
    }

    if {$variant == "rx_bb" || $variant == "rxtx_bb"} {
    	if {$BBSampleRate != $DUTClockFreq} {
	    	if { ![mw_is_connected /bb_rx[expr {$ch/2}]_I/Dout] } {
        		delete_bd_objs [get_bd_cells bb_rx[expr {$ch/2}]_I] [get_bd_cells bb_rx[expr {$ch/2}]_Q]
			delete_bd_objs [get_bd_cells dma_rx[expr {$ch/2}]_I] [get_bd_cells dma_rx[expr {$ch/2}]_Q]
			set_property -dict [list CONFIG.TDATA_NUM_BYTES {4} CONFIG.TSTRB_WIDTH {4} CONFIG.TKEEP_WIDTH {4}] [get_bd_cells fifo_baseband_rx0]
			set_property -dict [list CONFIG.TDATA_NUM_BYTES {4} CONFIG.TSTRB_WIDTH {4} CONFIG.TKEEP_WIDTH {4}] [get_bd_cells fifo_dma_rx0]			
			set_property -dict [list CONFIG.NUM_PORTS {2}] [get_bd_cells concat_IQ_bb_rx0]
			set_property -dict [list CONFIG.NUM_PORTS {2}] [get_bd_cells concat_IQ_dma_rx0]
			connect_bd_net [get_bd_pins bypass_rx/dut_data_in_[expr {$ch}]] [get_bd_pins util_ad9361_adc_fifo/dout_data_[expr {$ch}]]
   		   }
    	}
	}

	if { ![mw_is_connected ${bypass_rx_name}/bypass_data_in_${ch}] } {
        mw_connect_pin ${adc_fifo_name}/dout_data_${ch} ${bypass_rx_name}/bypass_data_in_${ch}
    }
	if { ![mw_is_connected ${bypass_rx_name}/dut_data_in_${ch}] } {
        mw_connect_pin ${adc_fifo_name}/dout_data_${ch} ${bypass_rx_name}/dut_data_in_${ch}
    }
}

#############
# GPIO
#############

# Cleanup the unused GPIO Mux pins
set MW_GPIO_BYPASS 4

foreach gpio_mux [get_bd_cells -quiet gpio_mux*] {
    set mux_name [get_property Name $gpio_mux]
    set nports [get_property CONFIG.NUM_PORTS $gpio_mux]
    for {set idx 0} {$idx < $nports} {incr idx} {
        if { !([mw_is_connected ${mux_name}/port_${idx}_i] || 
            [mw_is_connected ${mux_name}/port_${idx}_o]) } {
            # Unused, set to default state
            set_property CONFIG.PORT_${idx}_TYPE $MW_GPIO_BYPASS $gpio_mux
        }
    }
}

mw_cleanup_orphan_nets
