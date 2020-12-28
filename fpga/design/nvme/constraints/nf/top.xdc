#========================================================
# Vivado constraint file for mpsoc_kvs_platform
# Based on Vivado 2016.4
# Author: Yisong Chang (changyisong@ict.ac.cn)
# Date: 17/08/2017
#========================================================

# PCIe RP #0 GT reference clock
create_clock -period 10.000 -name pcie_rc_ref_clk_0 -waveform {0.000 5.000} [get_ports pcie_rc_gt_ref_clk_0_clk_p]

set_property PACKAGE_PIN AA10 [get_ports {pcie_rc_gt_ref_clk_0_clk_p[0]}]

# PCIe RP #1 GT reference clock
create_clock -period 10.000 -name pcie_rc_ref_clk_1 -waveform {0.000 5.000} [get_ports pcie_rc_gt_ref_clk_1_clk_p]

set_property PACKAGE_PIN W10 [get_ports {pcie_rc_gt_ref_clk_1_clk_p[0]}]

# PCIe RC GT physical location
set_property LOC GTHE4_CHANNEL_X0Y16 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[4].*gen_gthe4_channel_inst[3].GTHE4_CHANNEL_PRIM_INST}]
set_property LOC GTHE4_CHANNEL_X0Y17 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[4].*gen_gthe4_channel_inst[2].GTHE4_CHANNEL_PRIM_INST}]
set_property LOC GTHE4_CHANNEL_X0Y18 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[4].*gen_gthe4_channel_inst[1].GTHE4_CHANNEL_PRIM_INST}]
set_property LOC GTHE4_CHANNEL_X0Y19 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[4].*gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST}]
set_property LOC GTHE4_CHANNEL_X0Y20 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[5].*gen_gthe4_channel_inst[3].GTHE4_CHANNEL_PRIM_INST}]
set_property LOC GTHE4_CHANNEL_X0Y21 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[5].*gen_gthe4_channel_inst[2].GTHE4_CHANNEL_PRIM_INST}]
set_property LOC GTHE4_CHANNEL_X0Y22 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[5].*gen_gthe4_channel_inst[1].GTHE4_CHANNEL_PRIM_INST}]
set_property LOC GTHE4_CHANNEL_X0Y23 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[5].*gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST}]

# PCIe RP #0 perstn physical location
set_property PACKAGE_PIN B6 [get_ports pcie_rc_perstn_0]
set_property IOSTANDARD LVCMOS18 [get_ports pcie_rc_perstn_0]

# PCIe RP #1 perstn physical location
set_property PACKAGE_PIN C5 [get_ports pcie_rc_perstn_1]
set_property IOSTANDARD LVCMOS18 [get_ports pcie_rc_perstn_1]

# PCIe RP #0 link up LED
set_property PACKAGE_PIN A9 [get_ports pcie_rc_user_link_up_0]
set_property IOSTANDARD LVCMOS18 [get_ports pcie_rc_user_link_up_0]

# PCIe RP #1 link up LED
set_property PACKAGE_PIN A10 [get_ports pcie_rc_user_link_up_1]
set_property IOSTANDARD LVCMOS18 [get_ports pcie_rc_user_link_up_1]

# Timing exceptions
set_clock_groups -name async_pl_clk0_pcie_0 -asynchronous \
		-group [get_clocks clk_pl_0] \
		-group [get_clocks -include_generated_clocks pcie_rc_ref_clk_0]

set_clock_groups -name async_pl_clk0_pcie_1 -asynchronous \
		-group [get_clocks clk_pl_0] \
		-group [get_clocks -include_generated_clocks pcie_rc_ref_clk_1]

