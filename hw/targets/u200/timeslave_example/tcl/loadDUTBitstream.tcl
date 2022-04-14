# Program the DUT
# After setting env var use
# vivado -mode batch -source <pathto>/loadDUTBitstream.tcl
# to load a bitstream from the command line
open_hw
connect_hw_server
open_hw_target
set_property PROGRAM.FILE "$env(DUT_BITSTREAM)" [current_hw_device]
# set_property PROBES.FILE {} [current_hw_device]
puts "AR-NOTE About to program DUT with $env(DUT_BITSTREAM) ..."

# ERROR: [Labtools 27-3303] Incorrect bitstream assigned to device. Bitstream
# was generated for part [...], target device (with IDCODE
# revision 1) is compatible with es2 revision bitstreams.
# To allow the bitstream to be programmed to the device, use "set_param
# xicom.use_bitstream_version_check false" tcl command.

# set_param xicom.use_bitstream_version_check false

# WARNING: [Xicom 50-99] Incorrect bitstream assigned to device. Bitstream was
# generated for part [...], target device (with IDCODE revision
# 1) is compatible with es2 revision bitstreams.

program_hw_devices [current_hw_device]
puts "AR-NOTE Programming Done"
close_hw_target
