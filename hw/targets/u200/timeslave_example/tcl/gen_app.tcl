## HSI script to create hello_world app.
## Run with "hsi -source script.tcl -tclargs designName appName".
if {$argc == 0} {
    set designName ubes1a
} else {
    set designName [lindex $argv 0]
}
if {$argc < 2} {
    set appName app
} else {
    set appName [lindex $argv 1]
}
set hw_plat_dir hw_platform
file mkdir $hw_plat_dir
file copy -force ../vivado/$designName/$designName.runs/impl_1/fpgaTop.sysdef $hw_plat_dir/fpgaTop.hdf
# common::load_feature hsi
# set_repo_path {}
# open_hw_design also copies over .bit file.
open_hw_design $hw_plat_dir/fpgaTop.hdf
# get_cells -filter {IP_TYPE==PROCESSOR}
# get_sw_processor
set target_proc arkafx1_0_eyescan_wrapper_0_eyescan_i_mb_ps_microblaze_1
# set bsp_dir bsp
# get_sw_cores -filter {TYPE==OS}
set sw_des [create_sw_design sw_design_1 -proc ${target_proc} -os standalone]
# add_library {}
# generate_bsp -verbose -compile -dir ${bsp_dir}
# generate_app -sapp -proc ${target_proc}
# report_property [get_sw_processor]
# get_mem_ranges -of [get_cells [get_sw_processor]]
# Change memory sections:
set imem arkafx1_0_eyescan_wrapper_0_eyescan_i_mb_ps_microblaze_1_local_memory_ilmb_bram_if_cntlr
set dmem arkafx1_0_eyescan_wrapper_0_eyescan_i_mb_ps_microblaze_1_local_memory_dlmb_bram_if_cntlr
set shared_bram arkafx1_0_eyescan_wrapper_0_eyescan_i_mb_ps_axi_bram_ctrl_1
set_property CODE_MEMORY $imem $sw_des
set_property BSS_MEMORY  $dmem $sw_des
set_property DATA_MEMORY $dmem $sw_des
report_property [current_sw_design]
# report_property [get_mem_ranges $imem]
# report_property [get_mem_ranges $dmem]
# report_property [get_mem_ranges -of [get_cells $target_proc] $shared_bram]
generate_app -app empty_application -dir ${appName} -proc ${target_proc}
