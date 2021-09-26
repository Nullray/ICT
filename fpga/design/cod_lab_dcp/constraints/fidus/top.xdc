#========================================================
# Vivado constraint file for mpsoc_kvs_platform
# Based on Vivado 2016.4
# Author: Yisong Chang (changyisong@ict.ac.cn)
# Date: 17/08/2017
#========================================================

# PCIe RP #0 GT reference clock
create_clock -period 10.000 -name pcie_rc_ref_clk_0 -waveform {0.000 5.000} [get_ports pcie_rc_gt_ref_clk_0_clk_p]

set_property PACKAGE_PIN AB35 [get_ports {pcie_rc_gt_ref_clk_0_clk_n[0]}]
set_property PACKAGE_PIN AB34 [get_ports {pcie_rc_gt_ref_clk_0_clk_p[0]}]

# PCIe RP #1 GT reference clock
create_clock -period 10.000 -name pcie_rc_ref_clk_1 -waveform {0.000 5.000} [get_ports pcie_rc_gt_ref_clk_1_clk_p]

set_property PACKAGE_PIN W33 [get_ports {pcie_rc_gt_ref_clk_1_clk_n[0]}]
set_property PACKAGE_PIN W32 [get_ports {pcie_rc_gt_ref_clk_1_clk_p[0]}]

# PCIe RC GT physical location
set_property LOC GTYE4_CHANNEL_X0Y4 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[1].*gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST}]
set_property LOC GTYE4_CHANNEL_X0Y5 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[1].*gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST}]
set_property LOC GTYE4_CHANNEL_X0Y6 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[1].*gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST}]
set_property LOC GTYE4_CHANNEL_X0Y7 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[1].*gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST}]
set_property LOC GTYE4_CHANNEL_X0Y8 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[2].*gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST}]
set_property LOC GTYE4_CHANNEL_X0Y9 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[2].*gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST}]
set_property LOC GTYE4_CHANNEL_X0Y10 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[2].*gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST}]
set_property LOC GTYE4_CHANNEL_X0Y11 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[2].*gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST}]

# PCIe RP #0 perstn physical location
set_property PACKAGE_PIN H9 [get_ports pcie_rc_perstn_0]
set_property IOSTANDARD LVCMOS18 [get_ports pcie_rc_perstn_0]

# PCIe RP #1 perstn physical location
set_property PACKAGE_PIN J8 [get_ports pcie_rc_perstn_1]
set_property IOSTANDARD LVCMOS18 [get_ports pcie_rc_perstn_1]

# PCIe RP #0 link up LED
set_property PACKAGE_PIN A4 [get_ports pcie_rc_user_link_up_0]
set_property IOSTANDARD LVCMOS18 [get_ports pcie_rc_user_link_up_0]

# PCIe RP #1 link up LED
set_property PACKAGE_PIN A5 [get_ports pcie_rc_user_link_up_1]
set_property IOSTANDARD LVCMOS18 [get_ports pcie_rc_user_link_up_1]

# Timing exceptions
set_clock_groups -name async_pl_clk0_pcie_0 -asynchronous \
		-group [get_clocks clk_pl_0] \
		-group [get_clocks -include_generated_clocks pcie_rc_ref_clk_0]

set_clock_groups -name async_pl_clk0_pcie_1 -asynchronous \
		-group [get_clocks clk_pl_0] \
		-group [get_clocks -include_generated_clocks pcie_rc_ref_clk_1]

