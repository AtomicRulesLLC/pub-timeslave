set ip_files [list Counter.v \
                  FIFO1.v \
                  FIFO10.v \
                  FIFO2.v \
                  FIFO20.v \
                  FIFOL1.v \
                  FIFOL10.v \
                  SizedFIFO0.v \
                  SyncBit.v \
                  SyncFIFO.v \
                  SyncHandshake.v \
                  SyncPulse.v \
                  SyncRegister.v \
                  SyncResetA.v \
]
ipx::infer_core -as_library true [pwd]
set_property vendor {bluespec.com} [ipx::current_core]
set_property display_name {Bluespec Verilog Library} [ipx::current_core]
set_property description {Bluespec Verilog Library} [ipx::current_core]

foreach g [ipx::get_file_groups] {
    foreach f [ipx::get_files -of_objects $g] {        
        set name [get_property NAME $f]
        if { [lsearch -exact $ip_files $name] < 0 } {
            ipx::remove_file $name $g 
        }
    }
}

ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
