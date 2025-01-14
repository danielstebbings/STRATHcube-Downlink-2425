# Source the AXIS files
source $mw_hdl_dir/projects/axis/common/axis_bd.tcl

switch -- $project {
  "fmcomms5" {
        set HPPORT 1
  }
  default {
        set HPPORT 3
  }
}

# Configure the DMA
proc setup_stream_dma_config { direction stream_width HPPORT} {
    
    set config [dma_create_config $direction $stream_width]
    
    switch [mw_project_get cpu_type] {
        zynq7_arm {
            if {$direction == "mm2s"} {
                dict set config "port" 0
                dict set config "intr" 0
                dict set config "addr" 0x40020000
            } else {
                dict set config "port" $HPPORT
                dict set config "intr" 1
                dict set config "addr" 0x40030000
            }
        }
		zynqmp_arm {
            if {$direction == "mm2s"} {
                dict set config "port" 0
                dict set config "intr" 0
                dict set config "addr" 0x80020000    
            } else {
                dict set config "port" $HPPORT
                dict set config "intr" 1
                dict set config "addr" 0x80030000
            }
		}
    }
    
    dict set config "m_clk" sys_cpu_clk
    dict set config "m_rstn" sys_cpu_resetn
    dict set config "s_clk" sys_cpu_clk
    dict set config "s_rstn" sys_cpu_resetn

    return [ps_common_dma_config $config]
}

set stream_width 32
set mm2s_config [setup_stream_dma_config mm2s $stream_width $HPPORT]
set s2mm_config [setup_stream_dma_config s2mm $stream_width $HPPORT]

set mm2s_dma [setup_dma $mm2s_config]
set s2mm_dma [setup_dma $s2mm_config]

# connect the AXIS clocks to ipcore clock
mw_disconnect_pin axi_dma_mm2s/m_axis_aclk
mw_disconnect_pin axi_dma_s2mm/s_axis_aclk
mw_connect_pin axi_dma_mm2s/m_axis_aclk [mw_project_get ipcore_clk_net]
mw_connect_pin axi_dma_s2mm/s_axis_aclk [mw_project_get ipcore_clk_net]


if { [info exists AXIS_USE_PASSTHROUGH] && $AXIS_USE_PASSTHROUGH } {
    set fifo [mw_stream_passthrough $stream_width false]
}
