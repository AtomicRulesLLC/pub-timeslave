# fpgaTop_ubts1a.xdc - Constraints for Alveo U200 design
# Copyright (c) 2016-2022 Atomic Rules LLC - ALL RIGHTS RESERVED

set_property PACKAGE_PIN AW20       [get_ports sys300_clk_p]
set_property IOSTANDARD DIFF_SSTL12 [get_ports sys300_clk_p];
set_property PACKAGE_PIN AW19       [get_ports sys300_clk_n]
set_property IOSTANDARD DIFF_SSTL12 [get_ports sys300_clk_n];

set_property PACKAGE_PIN M11     [get_ports {enet_refclk_p[0]}]   ;# QSFP0/CMAC0 Upper (distal from pci fingers)

# QSFP control/status signals...
set_property PACKAGE_PIN BD18    [get_ports {qsfp_lp[0]}]
#set_property PACKAGE_PIN AV22    [get_ports {qsfp_lp[1]}]
set_property IOSTANDARD LVCMOS12 [get_ports {qsfp_lp[*]}]

set_property PACKAGE_PIN BE17    [get_ports {qsfp_rst_l[0]}]
#set_property PACKAGE_PIN BC18    [get_ports {qsfp_rst_l[1]}]
set_property IOSTANDARD LVCMOS12 [get_ports {qsfp_rst_l[*]}]

set_property PACKAGE_PIN BE20    [get_ports {qsfp_prsnt_l[0]}]
#set_property PACKAGE_PIN BC19    [get_ports {qsfp_prsnt_l[1]}]
set_property IOSTANDARD LVCMOS12 [get_ports {qsfp_prsnt_l[*]}]

set_property PACKAGE_PIN BE21    [get_ports {qsfp_int_l[0]}]
#set_property PACKAGE_PIN AV21    [get_ports {qsfp_int_l[1]}]
set_property IOSTANDARD LVCMOS12 [get_ports {qsfp_int_l[*]}]

set_property PACKAGE_PIN BE16    [get_ports {qsfp_modsel_l[0]}]
#set_property PACKAGE_PIN AY20    [get_ports {qsfp_modsel_l[1]}]
set_property IOSTANDARD LVCMOS12 [get_ports {qsfp_modsel_l[*]}]


# 300 MHz init_clk
create_clock -period 3.333 -name sysclk300 [get_ports sys300_clk_p]

# 156.25 MHz enet ref clk
create_clock -period 6.4 [get_ports enet_refclk_p[0]]
#create_clock -period 6.4 [get_ports enet_refclk_p[1]]

# Clock crossing in Time Servo  sysclock 300MHz ref clock to rx/tx clocks 322MHz
set_max_delay 3.0 -datapath_only -from [get_clocks rxoutclk_out[0]] -to [get_clocks sysclk300] 
set_max_delay 3.0 -datapath_only -from [get_clocks txoutclk_out[0]] -to [get_clocks sysclk300] 
set_max_delay 3.0 -datapath_only -from [get_clocks sysclk300] -to [get_clocks rxoutclk_out[0]] 
set_max_delay 3.0 -datapath_only -from [get_clocks sysclk300] -to [get_clocks txoutclk_out[0]] 

#Clock crossings back and forth from axi_100 clock
set_max_delay 3.0 -datapath_only -from [get_clocks clk_100] -to [get_clocks enet_refclk_p[0]] 
set_max_delay 3.0 -datapath_only -from [get_clocks clk_100] -to [get_clocks txoutclk_out[0]] 
set_max_delay 10.0 -datapath_only -from [get_clocks enet_refclk_p[0]] -to [get_clocks clk_100] 
set_max_delay 10.0 -datapath_only -from [get_clocks txoutclk_out[0]] -to [get_clocks clk_100] 


set_max_delay 3.0 -datapath_only -from [get_clocks enet_refclk_p[0]] -to [get_clocks txoutclk_out[0]] 
set_max_delay 3.0 -datapath_only -from [get_clocks rxoutclk_out[0]] -to [get_clocks enet_refclk_p[0]] 
set_max_delay 3.0 -datapath_only -from [get_clocks rxoutclk_out[0]] -to [get_clocks txoutclk_out[0]] 
set_max_delay 3.0 -datapath_only -from [get_clocks txoutclk_out[0]] -to [get_clocks rxoutclk_out[0]] 
