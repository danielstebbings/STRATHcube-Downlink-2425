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
set HDLCODERIPVLNV [get_property VLNV [get_ipdefs -filter {NAME==HDL_Chirp_ip && VERSION==1.0}]]
set HDLCODERIPINST HDL_Chirp_ip_0
set BDFILEPATH [get_files -quiet system.bd]
source vivado_custom_update_prj.tcl
close_project
exit
