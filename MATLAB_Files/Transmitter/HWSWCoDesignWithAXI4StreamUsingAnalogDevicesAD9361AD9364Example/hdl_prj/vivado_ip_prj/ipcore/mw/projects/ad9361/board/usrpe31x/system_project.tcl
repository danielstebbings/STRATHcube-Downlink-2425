# Add the files

set project_files [list \
  "${adi_prj_dir}/system_constr.xdc" \
  "${ad_hdl_dir}/library/xilinx/common/ad_iobuf.v"]
 
add_files -norecurse -fileset sources_1 $project_files

# Set the script to be sourced
set system_bd_script ${ad_hdl_dir}/projects/usrpe31x/system_bd.tcl
set IP_AXIM 4


