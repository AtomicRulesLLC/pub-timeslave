
################################################################
# This is a generated script based on design: timeslave_cmac
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2021.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source timeslave_cmac_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcu200-fsgd2104-2-e
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name timeslave_cmac

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES:
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\
xilinx.com:ip:cmac_usplus:3.*\
xilinx.com:ip:jtag_axi:1.*\
xilinx.com:ip:axis_data_fifo:2.*\
atomicrules.com:time:timeslave:1.*\
xilinx.com:ip:xlconstant:1.*\
xilinx.com:ip:proc_sys_reset:5.*\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: resets
proc create_hier_cell_resets { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_resets() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I -type clk clk_100MHz
  create_bd_pin -dir I -type rst clk_100_reset
  create_bd_pin -dir I -type rst ext_reset_in
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_aresetn
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_aresetn1
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_aresetn2
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_reset
  create_bd_pin -dir I -type clk ref_clk_300
  create_bd_pin -dir I -type clk slowest_sync_clk
  create_bd_pin -dir I -type clk slowest_sync_clk1

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.* proc_sys_reset_0 ]

  # Create instance: proc_sys_reset_1, and set properties
  set proc_sys_reset_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.* proc_sys_reset_1 ]

  # Create instance: proc_sys_reset_2, and set properties
  set proc_sys_reset_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.* proc_sys_reset_2 ]

  # Create instance: rst_clk_100MHz_100M, and set properties
  set rst_clk_100MHz_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.* rst_clk_100MHz_100M ]

  # Create port connections
  connect_bd_net -net Net [get_bd_pins slowest_sync_clk1] [get_bd_pins proc_sys_reset_2/slowest_sync_clk]
  connect_bd_net -net cmac_usplus_0_gt_txusrclk2 [get_bd_pins slowest_sync_clk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk]
  connect_bd_net -net cmac_usplus_0_usr_tx_reset [get_bd_pins ext_reset_in] [get_bd_pins proc_sys_reset_0/ext_reset_in]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins peripheral_aresetn2] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
  connect_bd_net -net proc_sys_reset_1_peripheral_aresetn [get_bd_pins peripheral_aresetn] [get_bd_pins proc_sys_reset_1/peripheral_aresetn]
  connect_bd_net -net proc_sys_reset_2_peripheral_reset [get_bd_pins peripheral_reset] [get_bd_pins proc_sys_reset_2/peripheral_reset]
  connect_bd_net -net ref_clk_0_1 [get_bd_pins ref_clk_300] [get_bd_pins proc_sys_reset_1/slowest_sync_clk]
  connect_bd_net -net rst_clk_100MHz_100M_peripheral_aresetn [get_bd_pins peripheral_aresetn1] [get_bd_pins rst_clk_100MHz_100M/peripheral_aresetn]
  connect_bd_net -net s_axi_aclk_0_1 [get_bd_pins clk_100MHz] [get_bd_pins rst_clk_100MHz_100M/slowest_sync_clk]
  connect_bd_net -net s_axi_sreset_0_1 [get_bd_pins clk_100_reset] [get_bd_pins proc_sys_reset_1/ext_reset_in] [get_bd_pins proc_sys_reset_2/ext_reset_in] [get_bd_pins rst_clk_100MHz_100M/ext_reset_in]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set gt [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 gt ]

  set gt_ref [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 gt_ref ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {156250000} \
   ] $gt_ref


  # Create ports
  set clk_100MHz [ create_bd_port -dir I -type clk clk_100MHz ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_RESET {clk_100_reset} \
 ] $clk_100MHz
  set clk_100_reset [ create_bd_port -dir I -type rst clk_100_reset ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $clk_100_reset
  set ref_clk_300 [ create_bd_port -dir I -type clk -freq_hz 300000000 ref_clk_300 ]

  # Create instance: cmac_usplus_0, and set properties
  set cmac_usplus_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:cmac_usplus:3.* cmac_usplus_0 ]
  set_property -dict [ list \
   CONFIG.CMAC_CAUI4_MODE {1} \
   CONFIG.CMAC_CORE_SELECT {CMACE4_X0Y7} \
   CONFIG.ENABLE_AXI_INTERFACE {1} \
   CONFIG.ENABLE_PIPELINE_REG {1} \
   CONFIG.ENABLE_TIME_STAMPING {1} \
   CONFIG.GT_GROUP_SELECT {X1Y48~X1Y51} \
   CONFIG.GT_REF_CLK_FREQ {156.25} \
   CONFIG.GT_RX_BUFFER_BYPASS {NA} \
   CONFIG.INCLUDE_AUTO_NEG_LT_LOGIC {1} \
   CONFIG.INCLUDE_RS_FEC {1} \
   CONFIG.INCLUDE_STATISTICS_COUNTERS {1} \
   CONFIG.LANE1_GT_LOC {X1Y48} \
   CONFIG.LANE2_GT_LOC {X1Y49} \
   CONFIG.LANE3_GT_LOC {X1Y50} \
   CONFIG.LANE4_GT_LOC {X1Y51} \
   CONFIG.NUM_LANES {4x25} \
   CONFIG.RX_CHECK_ACK {0} \
   CONFIG.RX_CHECK_PREAMBLE {1} \
   CONFIG.RX_CHECK_SFD {1} \
   CONFIG.RX_EQ_MODE {AUTO} \
   CONFIG.RX_FORWARD_CONTROL_FRAMES {1} \
   CONFIG.RX_GT_BUFFER {NA} \
   CONFIG.RX_MAX_PACKET_LEN {16383} \
   CONFIG.USER_INTERFACE {AXIS} \
 ] $cmac_usplus_0

  # Create instance: jtag_axi_0, and set properties
  set jtag_axi_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:jtag_axi:1.* jtag_axi_0 ]

  # Create instance: jtag_axi_0_axi_periph, and set properties
  set jtag_axi_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.* jtag_axi_0_axi_periph ]
  set_property -dict [ list \
   CONFIG.NUM_MI {2} \
 ] $jtag_axi_0_axi_periph

  # Create instance: loopback_fifo, and set properties
  set loopback_fifo [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.* loopback_fifo ]

  # Create instance: resets
  create_hier_cell_resets [current_bd_instance .] resets

  # Create instance: timeslave_0, and set properties
  set timeslave_0 [ create_bd_cell -type ip -vlnv atomicrules.com:time:timeslave:1.* timeslave_0 ]

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.* xlconstant_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net axis_data_fifo_0_M_AXIS [get_bd_intf_pins loopback_fifo/M_AXIS] [get_bd_intf_pins timeslave_0/usr_s_axis]
  connect_bd_intf_net -intf_net cmac_usplus_0_axis_rx [get_bd_intf_pins cmac_usplus_0/axis_rx] [get_bd_intf_pins timeslave_0/mac_s_axis]
  connect_bd_intf_net -intf_net cmac_usplus_0_gt_serial_port [get_bd_intf_ports gt] [get_bd_intf_pins cmac_usplus_0/gt_serial_port]
  connect_bd_intf_net -intf_net gt_ref_clk_0_1 [get_bd_intf_ports gt_ref] [get_bd_intf_pins cmac_usplus_0/gt_ref_clk]
  connect_bd_intf_net -intf_net jtag_axi_0_M_AXI [get_bd_intf_pins jtag_axi_0/M_AXI] [get_bd_intf_pins jtag_axi_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net jtag_axi_0_axi_periph_M00_AXI [get_bd_intf_pins cmac_usplus_0/s_axi] [get_bd_intf_pins jtag_axi_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net jtag_axi_0_axi_periph_M01_AXI [get_bd_intf_pins jtag_axi_0_axi_periph/M01_AXI] [get_bd_intf_pins timeslave_0/s_axi]
  connect_bd_intf_net -intf_net timeslave_0_mac_m_axis [get_bd_intf_pins cmac_usplus_0/axis_tx] [get_bd_intf_pins timeslave_0/mac_m_axis]
  connect_bd_intf_net -intf_net timeslave_0_usr_m_axis [get_bd_intf_pins loopback_fifo/S_AXIS] [get_bd_intf_pins timeslave_0/usr_m_axis]

  # Create port connections
  connect_bd_net -net Net [get_bd_pins cmac_usplus_0/drp_clk] [get_bd_pins cmac_usplus_0/gt_ref_clk_out] [get_bd_pins cmac_usplus_0/init_clk] [get_bd_pins resets/slowest_sync_clk1]
  connect_bd_net -net cmac_usplus_0_gt_rxusrclk2 [get_bd_pins cmac_usplus_0/gt_rxusrclk2] [get_bd_pins timeslave_0/now_clk_0]
  connect_bd_net -net cmac_usplus_0_gt_txusrclk2 [get_bd_pins cmac_usplus_0/gt_txusrclk2] [get_bd_pins cmac_usplus_0/rx_clk] [get_bd_pins loopback_fifo/s_axis_aclk] [get_bd_pins resets/slowest_sync_clk] [get_bd_pins timeslave_0/now_clk_1] [get_bd_pins timeslave_0/now_clk_2] [get_bd_pins timeslave_0/now_clk_3] [get_bd_pins timeslave_0/s_axis_aclk]
  connect_bd_net -net cmac_usplus_0_rx_preambleout [get_bd_pins cmac_usplus_0/rx_preambleout] [get_bd_pins cmac_usplus_0/tx_preamblein]
  connect_bd_net -net cmac_usplus_0_rx_ptp_tstamp_out [get_bd_pins cmac_usplus_0/rx_ptp_tstamp_out] [get_bd_pins timeslave_0/ptp_rx_tstamp]
  connect_bd_net -net cmac_usplus_0_tx_ptp_tstamp_out [get_bd_pins cmac_usplus_0/tx_ptp_tstamp_out] [get_bd_pins timeslave_0/ptp_tx_tstamp]
  connect_bd_net -net cmac_usplus_0_tx_ptp_tstamp_valid_out [get_bd_pins cmac_usplus_0/tx_ptp_tstamp_valid_out] [get_bd_pins timeslave_0/ptp_tx_tstamp_valid]
  connect_bd_net -net cmac_usplus_0_usr_tx_reset [get_bd_pins cmac_usplus_0/usr_tx_reset] [get_bd_pins resets/ext_reset_in]
  connect_bd_net -net proc_sys_reset_1_peripheral_aresetn [get_bd_pins resets/peripheral_aresetn] [get_bd_pins timeslave_0/ref_rstn]
  connect_bd_net -net proc_sys_reset_2_peripheral_reset [get_bd_pins cmac_usplus_0/core_drp_reset] [get_bd_pins cmac_usplus_0/sys_reset] [get_bd_pins resets/peripheral_reset]
  connect_bd_net -net ref_clk_0_1 [get_bd_ports ref_clk_300] [get_bd_pins resets/ref_clk_300] [get_bd_pins timeslave_0/ref_clk]
  connect_bd_net -net resets_peripheral_aresetn2 [get_bd_pins loopback_fifo/s_axis_aresetn] [get_bd_pins resets/peripheral_aresetn2] [get_bd_pins timeslave_0/s_axis_rstn]
  connect_bd_net -net rst_clk_100MHz_100M_peripheral_aresetn [get_bd_pins jtag_axi_0/aresetn] [get_bd_pins jtag_axi_0_axi_periph/ARESETN] [get_bd_pins jtag_axi_0_axi_periph/M00_ARESETN] [get_bd_pins jtag_axi_0_axi_periph/M01_ARESETN] [get_bd_pins jtag_axi_0_axi_periph/S00_ARESETN] [get_bd_pins resets/peripheral_aresetn1] [get_bd_pins timeslave_0/s_axi_aresetn]
  connect_bd_net -net s_axi_aclk_0_1 [get_bd_ports clk_100MHz] [get_bd_pins cmac_usplus_0/s_axi_aclk] [get_bd_pins jtag_axi_0/aclk] [get_bd_pins jtag_axi_0_axi_periph/ACLK] [get_bd_pins jtag_axi_0_axi_periph/M00_ACLK] [get_bd_pins jtag_axi_0_axi_periph/M01_ACLK] [get_bd_pins jtag_axi_0_axi_periph/S00_ACLK] [get_bd_pins resets/clk_100MHz] [get_bd_pins timeslave_0/s_axi_aclk]
  connect_bd_net -net s_axi_sreset_0_1 [get_bd_ports clk_100_reset] [get_bd_pins cmac_usplus_0/s_axi_sreset] [get_bd_pins resets/clk_100_reset]
  connect_bd_net -net timeslave_0_now_0 [get_bd_pins cmac_usplus_0/ctl_rx_systemtimerin] [get_bd_pins timeslave_0/now_0]
  connect_bd_net -net timeslave_0_now_1 [get_bd_pins cmac_usplus_0/ctl_tx_systemtimerin] [get_bd_pins timeslave_0/now_1]
  connect_bd_net -net timeslave_0_tx_1588op [get_bd_pins cmac_usplus_0/tx_ptp_1588op_in] [get_bd_pins timeslave_0/tx_1588op]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins timeslave_0/pps_src] [get_bd_pins xlconstant_0/dout]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces jtag_axi_0/Data] [get_bd_addr_segs cmac_usplus_0/s_axi/Reg] -force
  assign_bd_address -offset 0x00020000 -range 0x00008000 -target_address_space [get_bd_addr_spaces jtag_axi_0/Data] [get_bd_addr_segs timeslave_0/s_axi/Mem0] -force
  assign_bd_address -offset 0x00031000 -range 0x00001000 -target_address_space [get_bd_addr_spaces jtag_axi_0/Data] [get_bd_addr_segs timeslave_0/s_axi/egress] -force
  assign_bd_address -offset 0x00032000 -range 0x00001000 -target_address_space [get_bd_addr_spaces jtag_axi_0/Data] [get_bd_addr_segs timeslave_0/s_axi/ingress] -force
  assign_bd_address -offset 0x00033000 -range 0x00001000 -target_address_space [get_bd_addr_spaces jtag_axi_0/Data] [get_bd_addr_segs timeslave_0/s_axi/timeservo] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""
