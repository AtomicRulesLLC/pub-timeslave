#----------------------------------------------------------------
# ubes1a - 100 GbE Ethernet Shell on the U200
#
# Assumes
# 156.25 MHz ref clk
# 300.00 MHz sys clock
#
#----------------------------------------------------------------

set vivadoJobs 1
if {[info exist ::env(VIVADO_JOBS)]} {
  set vivadoJobs $env(VIVADO_JOBS)
}
puts "vivadoJobs is $vivadoJobs"

set designName ubts1a
set projRoot ..
puts "AR-NOTE: Requires Vivado 2020.1 or newer"

set doBackEnd 0
if {$argc==1 && [string equal [lindex $argv 0] "doBackEnd"]} {
  puts "AR-NOTE: Will run back-end tools"
  set doBackEnd 1
}

puts "AR-NOTE: Setting up project for Xilinx Alveo U200..."
create_project $designName $designName -part xcu200-fsgd2104-2-e
set obj [current_project]
set_property "default_lib" "xil_defaultlib" $obj
set_property "simulator_language" "Mixed" $obj

# Needed for eyescan DRP bridge
set_property ip_repo_paths ../../../../cores [current_fileset]
update_ip_catalog -rebuild

puts "AR-NOTE: Generating IPI Block Diagrams..."
array unset bd_file
set bd_list [list timeslave_cmac]
foreach ss $bd_list {
    source $projRoot/tcl/genBD_${designName}_${ss}.tcl

    validate_bd_design
    regenerate_bd_layout
    save_bd_design
}

puts "AR-NOTE: Adding source for top level..."
set fpgaTopFile "fpgaTop_$designName.v"
puts "AR-NOTE: Using $fpgaTopFile for fpgaTop"
add_files -norecurse "$projRoot/rtl/$fpgaTopFile"

# Generate BD targets before adding lib/gen files.
foreach ss [array names bd_file] {
    generate_target all $bd_file($ss)
}

source ../../../common/vivado/add_bsv_files.tcl 
source ../../../common/vivado/commit_id.tcl
create_commit_xdc $projRoot

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
add_files -fileset constrs_1 -norecurse "$projRoot/constrs/fpgaTop_$designName.xdc"
add_files -fileset constrs_1 -norecurse "$projRoot/constrs/bitstream.xdc"
add_files -fileset constrs_1 -norecurse "$projRoot/constrs/physical.xdc"
set_property top fpgaTop_$designName [current_fileset]

source ../../../common/vivado/do_backend.tcl

puts "Done with $designName"
