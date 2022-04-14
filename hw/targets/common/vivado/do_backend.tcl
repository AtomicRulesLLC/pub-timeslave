# To be sourced by Vivado create_*.tcl scripts.
# Standardized backend process goes here...

if $doBackEnd {
    puts "INFO: SYNTHESIS of $designName"
    set_property flow {Vivado Synthesis 2016} [get_runs synth_1]
    set_property STEPS.SYNTH_DESIGN.ARGS.FANOUT_LIMIT 256 [get_runs synth_1]
    launch_runs synth_1 -jobs $vivadoJobs
    wait_on_run synth_1

    puts "INFO: IMPLEMENTATION of $designName"
    launch_runs impl_1 -to_step write_bitstream
    wait_on_run impl_1

    open_run impl_1
    set wns [get_property SLACK [get_timing_paths -delay_type max]]
    set whs [get_property SLACK [get_timing_paths -delay_type min]]
    write_checkpoint [format "%s_postroute" $designName]
    close_design

    if {(${wns} >= 0) && (${whs} >= 0)} {
      puts "INFO: Timing Summary: All Constraints Met for design $designName: WNS = ${wns}, WHS = ${whs}"
    } else {
      puts "ERROR: Timing Summary: Constraints Not Met for design $designName: WNS = ${wns}, WHS = ${whs}"
    }

    puts "INFO: doBackEnd completed for $designName"
}
