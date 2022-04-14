# fpgaTop_uats1a.xdc - Constraints for Alveo U200 design
# Copyright (c) 2016-2022 Atomic Rules LLC - ALL RIGHTS RESERVED

# 100MHz from SYSCLK2...
set_property PACKAGE_PIN G17     [get_ports sys100_clk_p]
set_property PACKAGE_PIN G16     [get_ports sys100_clk_n]
set_property IOSTANDARD LVDS     [get_ports sys100_clk_p];
set_property IOSTANDARD LVDS     [get_ports sys100_clk_n];

set_property PACKAGE_PIN N36 [get_ports {enet_refclk_p}]   ;# QSFP Bank 131 REFCLK0 161.132 MHz

# 100 MHz 
create_clock -period 10.0  -name sysclk100  [get_ports sys100_clk_p]

# 156.25 MHz enet ref clk
create_clock -period 6.4 [get_ports enet_refclk_p[0]]

set_max_delay 3.0 -datapath_only -from [get_clocks clk_300_timeslave_cmac_clk_wiz_0_0] -to [get_clocks rxoutclk_out[0]] 
set_max_delay 3.0 -datapath_only -from [get_clocks clk_300_timeslave_cmac_clk_wiz_0_0] -to [get_clocks txoutclk_out[0]] 
set_max_delay 10.0 -datapath_only -from [get_clocks enet_refclk_p[0]] -to [get_clocks sysclk100] 
set_max_delay 3.0 -datapath_only -from [get_clocks enet_refclk_p[0]] -to [get_clocks txoutclk_out[0]] 
set_max_delay 3.0 -datapath_only -from [get_clocks rxoutclk_out[0]] -to [get_clocks clk_300_timeslave_cmac_clk_wiz_0_0] 
set_max_delay 3.0 -datapath_only -from [get_clocks rxoutclk_out[0]] -to [get_clocks enet_refclk_p[0]] 
set_max_delay 3.0 -datapath_only -from [get_clocks rxoutclk_out[0]] -to [get_clocks txoutclk_out[0]] 
set_max_delay 3.0 -datapath_only -from [get_clocks sysclk100] -to [get_clocks enet_refclk_p[0]] 
set_max_delay 3.0 -datapath_only -from [get_clocks sysclk100] -to [get_clocks txoutclk_out[0]] 
set_max_delay 3.0 -datapath_only -from [get_clocks txoutclk_out[0]] -to [get_clocks clk_300_timeslave_cmac_clk_wiz_0_0] 
set_max_delay 3.0 -datapath_only -from [get_clocks txoutclk_out[0]] -to [get_clocks rxoutclk_out[0]] 

set_property PACKAGE_PIN J18      [get_ports "HBM_CATTRIP"]       ;# Bank  68 VCCO - VCC1V8   - IO_L6N_T0U_N11_AD6N_68
set_property IOSTANDARD  LVCMOS18 [get_ports "HBM_CATTRIP"]       ;# Bank  68 VCCO - VCC1V8   - IO_L6N_T0U_N11_AD6N_68
set_property PULLDOWN TRUE        [get_ports "HBM_CATTRIP"]       ;# Bank  68 VCCO - VCC1V8   - IO_L6N_T0U_N11_AD6N_68
