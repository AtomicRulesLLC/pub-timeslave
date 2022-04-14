set CORE_NAME Time_Servo
set TOP_MODULE timeServo
set DESCRIPTION "Time Servo Module"

set SRC_FILES [glob *.v]
set LOGO ../common/images/ARlogo256X.png

source ../common/scripts/create_ip.tcl

set AXI_CLOCK s_axi_aclk

set axi_ifc [list \
                 s_axi \
                 ]

set N 32

# s_axi interface does not use std clock name
foreach i $axi_ifc {
    ipx::associate_bus_interfaces -busif $i -clock $AXI_CLOCK [ipx::current_core]
}

set validPorts  [list]
set validSizes  [list 0]

for {set i 0} {$i < $N} {incr i} {

    lappend validPorts $i
    lappend validSizes [expr $i + 1]
}

ipx::add_user_parameter NumCDC [ipx::current_core]
set_property value_resolve_type user [ipx::get_user_parameters NumCDC -of_objects [ipx::current_core]]
#set_property display_name {NumCDC} [ipgui::get_guiparamspec -name "NumCDC" -component [ipx::current_core] ]
#set_property widget {comboBox} [ipgui::get_guiparamspec -name "NumCDC" -component [ipx::current_core] ]
set_property value 1 [ipx::get_user_parameters NumCDC -of_objects [ipx::current_core]]

set_property value_format long [ipx::get_user_parameters NumCDC -of_objects [ipx::current_core]]
set_property value_validation_type list [ipx::get_user_parameters NumCDC -of_objects [ipx::current_core]]
set_property value_validation_list $validSizes [ipx::get_user_parameters NumCDC -of_objects [ipx::current_core]]
ipgui::add_param -name {NumCDC} -component [ipx::current_core] -display_name {NumCDC} -show_label {true} -show_range {true} -widget {}



if {1} {
    set bi [ipx::add_bus_interface ref_clk [ipx::current_core]]
    set pm [ipx::add_bus_parameter ASSOCIATED_BUSIF $bi]
    set_property value ref_clk $pm
}

if {1} {


}

foreach j $validPorts {
    set bi [ipx::add_bus_interface now_clk_$j [ipx::current_core]]
    set pm [ipx::add_bus_parameter ASSOCIATED_BUSIF $bi]
    set_property value now_clk_$j $pm
    ipx::add_bus_interface now_clk_$j [ipx::current_core]
    set_property abstraction_type_vlnv xilinx.com:signal:clock_rtl:1.0 [ipx::get_bus_interfaces now_clk_$j -of_objects [ipx::current_core]]
    set_property bus_type_vlnv xilinx.com:signal:clock:1.0 [ipx::get_bus_interfaces now_clk_$j -of_objects [ipx::current_core]]
    ipx::add_port_map CLK [ipx::get_bus_interfaces now_clk_$j -of_objects [ipx::current_core]]
    set_property physical_name now_clk_$j [ipx::get_port_maps CLK -of_objects [ipx::get_bus_interfaces now_clk_$j -of_objects [ipx::current_core]]]
}

foreach j $validPorts {

    set var "eval [list set NumCDC]"
set_property driver_value $j [ipx::get_ports now_clk_$j -of_objects [ipx::current_core]]
set_property enablement_dependency [concat {$NumCDC} ">" $j] [ipx::get_ports now_clk_$j -of_objects [ipx::current_core]]
set_property enablement_dependency [concat {$NumCDC} ">" $j] [ipx::get_ports now_$j -of_objects [ipx::current_core]]
set_property enablement_dependency [concat {$NumCDC} ">" $j] [ipx::get_ports now_pps_$j -of_objects [ipx::current_core]]

}


set_property value 1 [ipx::get_user_parameters NumCDC -of_objects [ipx::current_core]]

ar_ipi_finish



