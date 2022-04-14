################################################################################
# Description :
# The IP delivered with the project, $source_dir, only contains the
# source files. This file builds the IP into a $build_dir directory.
#############################################################################}}}

# Process the global arguments setting into the array argName.
# each argument must exactly match an existing member of validArgs
proc ar_check_and_set_args {argName} {
    upvar $argName ARGS
    set largv $::argv

    set validArgs [array names ARGS]

    while {[llength $largv] > 1} {
        set largv [lassign $largv nm val]
        if { [lsearch -exact $validArgs "$nm"] == -1 } {
            error "Incorrect option `$nm`"
        }
        set ARGS($nm) $val
    }
    if {[llength $largv]} {
        error "Missing option valid in $::argv"
    }
}

# Entry point
proc ar_build_proj_ip { argName core_files bd_files}  {
    upvar $argName ARGS

    parray ARGS
    if { [catch "ar_check_and_set_args ARGS" err] } {
        puts stderr $err
        exit -1
    }

    # Handle overwrite option
    set build_dir $ARGS(build_dir)
    if { [ file exists ${build_dir} ] } {
        if { $ARGS(-overwrite) } {
            puts "${build_dir} exists, deleting (overwrite=1)"
            file delete -force $build_dir
        } else {
            puts "${build_dir} exists, updating missing IP (overwrite=0)"
        }
    }

    ar_build_proj_ip_worker ARGS $core_files $bd_files
}

#
proc ar_build_proj_ip_worker {argName core_files bd_files}  {
    upvar $argName ARGS

    set build_dir $ARGS(build_dir)
    set part $ARGS(part)
    puts "Building Managed IP Project"
    create_project -force managed_ip_project ./${build_dir}/managed_ip_project -part $part -ip
    set_property simulator_language Verilog [current_project]

    set run_list [list]

    foreach core $core_files {
        set result [ar_build_ip ARGS xci $core]
        if { $result == "" }  continue
        lappend run_list $result
    }

    foreach core $bd_files {
        set result [ar_build_ip ARGS bd $core]
        if { $result == "" }  continue
        lappend run_list $result
    }

    if {$run_list != "" && $ARGS(-synth)} {
        puts "**********************************"
        puts "* Synthesizing ${run_list}"
        puts "**********************************"
        foreach run ${run_list} {reset_run ${run}}
        launch_runs -jobs $ARGS(-max-jobs) ${run_list}
        foreach run ${run_list} {wait_on_run $run}
    }

    puts "Done Building IP"
    return
}

# Core is name of core to build, type = [xci|bd]
# returns  list of jobs to run
proc ar_build_ip {argName type core} {
    upvar $argName ARGS

    set source_dir $ARGS(source_dir)
    set build_dir $ARGS(build_dir)

    # ip_gen_src expected in sub core script
    set ip_gen_src $ARGS(build_dir)

    # if the directory exists, skip it.
    set dname [file join $ip_gen_src [format "%s" $core]]
    if { [file exists $dname] } {
        puts "IP director $dname exists,  skipping..."
        return
    }

    puts "**********************************"
    puts "* Generating Files for ${type} : ${core}"
    puts "**********************************"

    source ./${source_dir}/${core}.tcl

    if {$type == "bd"} {
        close_bd_design [get_bd_designs ${core}]
    }

    set_property generate_synth_checkpoint true [get_files ${ip_gen_src}/${core}/${core}.${type}]
    if {$type == "bd"} {
        if $ARGS(bd-single-dcp) {
            puts "Set ${core} Synth checkpoint mode - Singular"
            set_property synth_checkpoint_mode Singular [get_files ${ip_gen_src}/${core}/${core}.${type}]
        }
    }
    generate_target all [get_files ${ip_gen_src}/${core}/${core}.${type}]

    if {$type == "xci"} {
        create_ip_run [get_files -of_objects [get_fileset sources_1] ${ip_gen_src}/${core}/${core}.${type}]
    } elseif {$type == "bd"} {
        export_ip_user_files -of_objects [get_files ${ip_gen_src}/${core}/${core}.${type}] -no_script -sync -force -quiet
        set bd_run [create_ip_run [get_files -of_objects [get_fileset sources_1] ${ip_gen_src}/${core}/${core}.${type}]]
    }

    # Generate the return elements for the proc to manage post run
    if {$type == "xci"} {
        set run_list ${core}_synth_1
    } elseif {$type == "bd"} {
        set run_list ${bd_run}
    }

    return $run_list
}
