# Program the SPI flash
# After setting env var DUT_BITSTREAM use
# vivado -mode batch -source <pathto>/pgmSPIFlash.tcl
open_hw
connect_hw_server

set found false
foreach t [get_hw_targets] {
    open_hw_target $t
    set hwdev [get_hw_devices -quiet -filter {PART == "xcvu9p"}]
    if {[llength $hwdev] > 0} {
        set found true
        break
    } else {
        close_hw_target
    }
}
if {!$found} {
    error "Matching device not found!"
}
puts "target = $t"
puts "hw_device = $hwdev"

current_hw_device $hwdev

# set impl_dir [get_property DIRECTORY [get_runs impl_1]]
# set bit [lindex [glob ${impl_dir}/*.bit] 0]
set bit $env(DUT_BITSTREAM)
set_property PROGRAM.FILE $bit $hwdev
set binfile [file rootname $bit].bin

set mem_dev [lindex [get_cfgmem_parts {mt25qu512-spi-x1_x2_x4}] 0]
create_hw_cfgmem -hw_device $hwdev -mem_dev $mem_dev

set cfgmem [ get_property PROGRAM.HW_CFGMEM $hwdev ]

set_property PROGRAM.ADDRESS_RANGE  {use_file} $cfgmem
set_property PROGRAM.FILES [list $binfile] $cfgmem
set_property PROGRAM.UNUSED_PIN_TERMINATION {pull-none} $cfgmem
set_property PROGRAM.BLANK_CHECK  0 $cfgmem
set_property PROGRAM.ERASE  1 $cfgmem
set_property PROGRAM.CFG_PROGRAM  1 $cfgmem
set_property PROGRAM.VERIFY  1 $cfgmem
# set cfgmem_part [get_property CFGMEM_PART $cfgmem]
# set mem_type [get_property MEM_TYPE ${cfgmem_part}]
# if {![string equal [get_property PROGRAM.HW_CFGMEM_TYPE $hwdev] $mem_type} {}
# create_hw_bitstream -hw_device $hwdev [get_property PROGRAM.HW_CFGMEM_BITFILE $hwdev]

puts "AR-NOTE About to program SPI flash with $binfile..."

program_hw_devices $hwdev
program_hw_cfgmem -hw_cfgmem $cfgmem
# boot_hw_device $hwdev

puts "AR-NOTE Programming Done"
close_hw_target
