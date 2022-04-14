################################################################################
# This XDC is used only for OOC mode of synthesis, implementation
# This constraints file contains default clock frequencies to be used during
# out-of-context flows such as OOC Synthesis and Hierarchical Designs.
# This constraints file is not used in normal top-down synthesis (default flow
# of Vivado)
################################################################################
create_clock -name now_clk_0 -period 3.103 [get_ports now_clk_0]
create_clock -name now_clk_1 -period 3.103 [get_ports now_clk_1]
create_clock -name now_clk_2 -period 3.103 [get_ports now_clk_2]
create_clock -name now_clk_3 -period 3.103 [get_ports now_clk_3]
create_clock -name ref_clk -period 3.333 [get_ports ref_clk]
create_clock -name s_axi_aclk -period 10 [get_ports s_axi_aclk]
create_clock -name s_axis_aclk -period 3.103 [get_ports s_axis_aclk]
