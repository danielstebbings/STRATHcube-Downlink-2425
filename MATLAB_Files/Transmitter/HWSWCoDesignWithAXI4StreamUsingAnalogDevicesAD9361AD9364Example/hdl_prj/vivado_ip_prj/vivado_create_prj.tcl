set_param board.repoPaths [get_property LOCAL_ROOT_DIR [xhub::get_xstores xilinx_board_store]]
create_project vivado_prj {} -part xc7z035ifbg676-2L -force
set_property target_language VHDL [current_project]
set defaultRepoPath {./ipcore}
set_property ip_repo_paths $defaultRepoPath [current_fileset]
update_ip_catalog
set ipList [glob -nocomplain -directory $defaultRepoPath *.zip]
foreach ipCore $ipList {
  set folderList [glob -nocomplain -directory $defaultRepoPath -type d *]
  if {[lsearch -exact $folderList [file rootname $ipCore]] == -1} {
    catch {update_ip_catalog -add_ip $ipCore -repo_path $defaultRepoPath}
  }
}
update_ip_catalog
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
source vivado_custom_block_design.tcl
# Use global synthesis for this project
set_property synth_checkpoint_mode None [get_files system.bd]
# Update output frequency on clock wizard based on target frequency
set_property -dict [list CONFIG.CLKOUT0_REQUESTED_OUT_FREQ {4.000}] [get_bd_cells util_mw_clkconstr]
save_bd_design
close_project
exit
