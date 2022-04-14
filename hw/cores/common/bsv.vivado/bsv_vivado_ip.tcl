# Vivado Tcl script to package as library

set ip_files [list SizedFIFO.v \
                  FIFO18E2_WRAPPER.v \
                  FIFO36E2_WRAPPER.v \
                  BRAM2.v            \
                  RegFile.v          \
                  bsv_vivado_ip.tcl  \
                  UltraRAM_SDP.v     \
                  BRAM_SDP.v     \
                 ]
ipx::infer_core -as_library true [pwd]
set_property vendor {bluespec.com} [ipx::current_core]
set_property display_name {Bluespec Verilog Library (Vivado-Specific Files)} [ipx::current_core]
set_property description {Bluespec Verilog Library (Vivado-Specific Files)} [ipx::current_core]

foreach g [ipx::get_file_groups] {
    foreach f [lsort [ipx::get_files -of_objects $g]] {
        set name [get_property NAME $f]
        if { [lsearch -exact $ip_files $name] < 0 } {
            ipx::remove_file $name $g
        }
    }
}

ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
