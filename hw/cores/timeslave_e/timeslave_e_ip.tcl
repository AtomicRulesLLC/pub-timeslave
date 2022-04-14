set CORE_NAME TimeSlave_Egress
set TOP_MODULE mkEgressMerge
set DESCRIPTION "Timeslave Egress Merge module"
set VERSION 1.0

source ../common/scripts/create_ip.tcl

ipx::associate_bus_interfaces -busif s_axi -clock clk [ipx::current_core]
ipx::associate_bus_interfaces -busif tx_ptp_tstamp -clock clk [ipx::current_core]
ipx::associate_bus_interfaces -busif mac_m_axis -clock clk [ipx::current_core]
ipx::associate_bus_interfaces -busif usr_s_axis -clock clk [ipx::current_core]

# Set some tool tips and descriptions
set desc ""
ar_ipi_add_parameter Stream_Width  long 64 [list 8 16 32 64] "Stream Byte Width"  $desc $desc

ar_ipi_finish

